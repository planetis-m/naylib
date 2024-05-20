import
  compiler/[ast, parser, idents, astalgo, pathutils, condsyms, renderer,
  options, nimconf, extccomp, modulegraphs, lineinfos], std/[os, strutils]

# need to run ./koch checksums

proc expectKind(n: PNode, k: TNodeKind) =
  if n.kind != k:
    raise newException(ValueError, "Expected a node of kind " & $k & ", got " & $n.kind)

proc expectLen(n: PNode, len: int) =
  if n.len != len:
    raise newException(ValueError, "Expected a node with " & $len & " children, got " & $n.len)

proc str(n: PNode): string =
  case n.kind
  of nkStrLit..nkTripleStrLit:
    result = n.strVal
  of nkIdent:
    result = n.ident.s
  of nkSym:
    result = n.sym.name.s
  of nkOpenSymChoice, nkClosedSymChoice:
    result = n.sons[0].sym.name.s
  else:
    assert false

proc basename(n: PNode): PNode =
  case n.kind
  of nkIdent: result = n
  of nkPragmaExpr:
    result = basename(n[0])
  of nkPostfix, nkPrefix:
    result = basename(n[1])
  of nkAccQuoted:
    result = basename(n[0])
  else:
    assert false

proc eqIdent(a: string; b: string): bool =
  result = cmpIgnoreStyle(a, b) == 0

proc eqIdent(a: PNode, b: string): bool =
  result = cmpIgnoreStyle(a.basename.str, b) == 0

proc eqIdent(a, b: PNode): bool =
  result = cmpIgnoreStyle(a.basename.str, b.basename.str) == 0

type
  Context = object
    m: PNode # the high level wrapping code
    cache: IdentCache
    info: TLineInfo

proc ident(c: var Context; s: string): PNode =
  newIdentNode(getIdent(c.cache, s), c.info)

proc groupMatrixFieldsByRow(c: var Context; node: PNode): PNode =
  const MatN = 4 # assumes a 4x4 matrix
  case node.kind
  of nkTypeDef:
    if eqIdent(node[0], "Matrix"):
      let reclist = node[2][2]
      if reclist.len != MatN*MatN:
        result = node
        return
      result = newTree(nkTypeDef,
        node[0],
        newNode(nkEmpty),
        newTree(nkObjectTy,
          node[2][0],
          node[2][1]
        )
      )
      let newReclist = newNode(nkRecList)
      for i in countup(0, reclist.len-MatN, MatN):
        expectLen(reclist[i], 3)
        let newIdentDefs = newNode(nkIdentDefs)
        for j in countup(i, i+MatN-1):
          newIdentDefs.add reclist[j][0]
        newIdentDefs.add ident(c, "float32")
        newIdentDefs.add newNode(nkEmpty)
        newIdentDefs.comment = reclist[i+MatN-1].comment
        newReclist.add newIdentDefs
      result[2].add newReclist
    else:
      result = node
  else:
    result = copyNode(node)
    for child in node.items:
      result.add groupMatrixFieldsByRow(c, child)

const
  matmath = """
template `+`*(v1, v2: Matrix): T = add(v1, v2)
template `+=`*(v1: var Matrix, v2: Matrix) = v1 = add(v1, v2)
"""

proc preprocess(c: var Context; node: PNode): PNode =
  case node.kind
  of nkTypeSection:
    result = copyNode(node)
    for i in 0 ..< node.len:
      if node[i].kind == nkTypeDef:
        result.add groupMatrixFieldsByRow(c, node[i])
      else: result.add node[i]
  of nkProcDef:
    result = node
  else:
    result = copyNode(node)
    for child in node.items:
      result.add preprocess(c, child)

# proc postprocess(c: var Context; node: PNode) =
#   case node.kind
#   of nkTypeSection:
#     for i in 0 ..< node.len:
#       if node[i].kind == nkTypeDef:
#         handleObjectDecl(c, node[i], node[i].lastSon)
#   of nkProcDef:
#     handleProc(c, node)
#   else:
#     for i in 0 ..< node.safeLen: postprocess(c, node.sons[i])

proc main =
  # Create a new configuration and module graph
  let conf = newConfigRef()
  let cache = newIdentCache()
  let graph = newModuleGraph(cache, conf)
  # Initialize defines and load configurations
  condsyms.initDefines(conf.symbols)
  conf.projectName = "stdinfile"
  conf.projectFull = "stdinfile".AbsoluteFile
  conf.projectPath = canonicalizePath(conf, getCurrentDir().AbsoluteFile).AbsoluteDir
  conf.projectIsStdin = true
  loadConfigs(DefaultConfig, cache, conf, graph.idgen)
  # Initialize external compiler variables
  extccomp.initVars(conf)
  # Parse input file
  let filename = "input.nim"
  var node = parseString(readFile(filename), cache, conf)
  # Apply pre-/postprocessing steps
  var c = Context(m: newNode(nkStmtList), cache: cache, info: unknownLineInfo)
  node = preprocess(c, node)
  # postprocess(c, node)
  node.add c.m
  node.add newIdentNode(getIdent(c.cache, matmath), c.info)
  # Render the module to an output file
  renderModule(node, filename, {renderDocComments})

main()
