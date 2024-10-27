import std/[streams, enumerate, assertions]
import schema, utils

type
  Builder* = object
    outp: Stream
    header: string
    nesting: int

proc openBuilder*(filename, header: string): Builder =
  Builder(outp: openFileStream(filename, fmWrite), header: header, nesting: 0)

proc openBuilder*(sizeHint: int; header: string): Builder =
  Builder(outp: newStringStream(newStringOfCap(sizeHint)), header: header, nesting: 0)

proc close*(b: Builder) =
  if b.outp != nil:
    b.outp.close()
  assert b.nesting == 0

proc put*(b: Builder; s: string) =
  write b.outp, s

proc put*(b: Builder; c: char) =
  write b.outp, c

proc addIndentation*(b: var Builder) =
  b.put '\n'
  for i in 1..b.nesting: b.put "  "

proc addNL*(b: var Builder) =
  b.put '\n'

proc addTree*(b: var Builder, kind: string) =
  b.addIndentation()
  if kind != "":
    b.put kind
  inc b.nesting

proc endTree*(b: var Builder) =
  assert b.nesting > 0
  dec b.nesting

template withSection*(b: var Builder, kind: string, body: untyped) =
  addTree b, kind
  body
  endTree b

template withBlock*(b: var Builder, body: untyped) =
  addTree b, ""
  body
  endTree b

proc addIdent*(b: var Builder, s: string) =
  let isKeyw = isKeyword(s)
  if isKeyw:
    b.put '`'
  b.put s
  if isKeyw:
    b.put '`'

proc addDoc*(b: var Builder, s: string) =
  if s != "":
    b.put " ## "
    b.put s

proc addBlockDoc*(b: var Builder, s: string) =
  if s != "":
    addTree b, ""
    b.put "## "
    b.put s
    endTree b

proc addStrLit*(b: var Builder; s: string) =
  b.put '"'
  b.put s
  b.put '"'

proc addIntLit*(b: var Builder; i: BiggestInt) =
  b.put $i

proc addRaw*(b: var Builder; s: string) =
  put b, s

proc generateEnum*(b: var Builder, enm: EnumInfo) =
  withSection(b, enm.name):
    if isPrivate notin enm.flags:
      b.addRaw "*"
    b.addRaw " {.size: sizeof(int32).} = enum"
    b.addDoc enm.description
    var prev = -1
    for i, val in enumerate(enm.values):
      if val.value == prev: continue
      withSection(b, val.name):
        if prev + 1 != val.value:
          b.addRaw " = "
          b.addIntLit val.value
        b.addDoc val.description
        prev = val.value

proc generateObject*(b: var Builder, obj: StructInfo) =
  withSection(b, obj.name):
    if isPrivate notin obj.flags:
      b.addRaw "*"
    b.addRaw " {.importc"
    if obj.importName != "":
      b.addRaw ": "
      b.addStrLit obj.importName
    b.addRaw ", header: "
    b.addStrLit b.header
    if isCompleteStruct in obj.flags:
      b.addRaw ", completeStruct"
    b.addRaw ", bycopy.} = object"
    b.addDoc obj.description
    for fld in obj.fields:
      # Group Matrix fields by rows
      if obj.name != "Matrix" or fld.name in ["m0", "m1", "m2", "m3"]: # row starts
        b.addTree("")
      b.addIdent fld.name
      if isPrivate notin fld.flags:
        b.addRaw "*"
      if obj.name == "Matrix" and fld.name notin ["m12", "m13", "m14", "m15"]: # row ends
        b.addRaw ", "
        continue
      b.addRaw ": "
      b.addRaw fld.`type`
      b.addDoc fld.description
      b.endTree()

proc generateProc*(b: var Builder, fnc: FunctionInfo) =
  withSection(b, if isFunc in fnc.flags: "func " else: "proc "):
    b.addRaw fnc.name
    if {isWrappedFunc, isAutoWrappedFunc} * fnc.flags != {}:
      b.addRaw "Impl"
    if isPrivate notin fnc.flags:
      b.addRaw "*"
    b.addRaw "("
    for i, param in enumerate(fnc.params):
      if i > 0:
        b.addRaw ", "
      b.addIdent param.name
      b.addRaw ": "
      b.addRaw param.`type`
    b.addRaw ")"
    if fnc.returnType != "void":
      b.addRaw ": "
      b.addRaw fnc.returnType
    b.addRaw " {.importc: "
    b.addStrLit fnc.importName
    if hasVarargs in fnc.flags:
      b.addRaw ", varargs"
    if isFunc notin fnc.flags:
      b.addRaw ", sideEffect"
    b.addRaw ".}"
    if isPrivate notin fnc.flags:
      b.addBlockDoc fnc.description

proc generateWrappedProc*(b: var Builder, fnc: FunctionInfo) =
  withSection(b, "proc "):
    b.addRaw fnc.name
    b.addRaw "*("
    for i, param in enumerate(fnc.params):
      if isArrayLen in param.flags:
        continue
      if i > 0:
        b.addRaw ", "
      b.addIdent param.name
      b.addRaw ": "
      if isString in param.flags:
        b.addRaw "string"
      elif {isOpenArray, isVarParam} * param.flags != {}:
        b.addRaw param.dirty # stores native nim type
      else:
        b.addRaw param.`type`
    b.addRaw ")"
    if fnc.returnType != "void":
      b.addRaw ": "
      if isString in fnc.flags:
        b.addRaw "string"
      else:
        b.addRaw fnc.returnType
    b.addRaw " ="
    b.addBlockDoc fnc.description
    withBlock(b):
      if isString in fnc.flags:
        b.addRaw "$"
      b.addRaw fnc.name
      b.addRaw "Impl("
      for i, param in enumerate(fnc.params):
        if i > 0:
          b.addRaw ", "
        if isOpenArray in param.flags:
          b.addRaw "cast["
          b.addRaw param.`type`
          b.addRaw "]("
        elif isVarParam in param.flags:
          b.addRaw "addr "
        if isArrayLen in param.flags:
          b.addIdent param.dirty # stores array name
          b.addRaw ".len."
          b.addRaw param.`type`
        else:
          b.addIdent param.name
        if isString in param.flags:
          b.addRaw ".cstring"
        if isOpenArray in param.flags:
          b.addRaw ")"
      b.addRaw ")"

proc genBindings*(b: var Builder; ctx: ApiContext;
                  moduleHeader, afterEnums, afterObjects, afterFuncs, moduleEnd: string) =
  b.addRaw moduleHeader
  # Generate enum definitions
  withSection(b, "type"):
    for enm in ctx.api.enums:
      generateEnum(b, enm)
      b.addNL()
  b.addNL()
  b.addRaw afterEnums
  # Generate type definitions
  withSection(b, "type"):
    for obj in ctx.api.structs:
      generateObject(b, obj)
      b.addNL()
    # Add type alias or missing type
    for alias in ctx.api.aliases:
      withSection(b, alias.name):
        if isDistinct in alias.flags:
          b.addRaw "* {.borrow: `.`.} = distinct "
        else:
          b.addRaw "* = "
        b.addRaw alias.`type`
        b.addDoc alias.description
    # Distinct procs for arrays
    for x in ctx.boundCheckedArrayAccessors:
      withSection(b, x.name):
        b.addRaw "* = distinct "
        b.addRaw x.`type`
  b.addRaw("\n\n")
  b.addRaw afterObjects
  # Generate procs
  b.addRaw "\n{.push callconv: cdecl, header: "
  b.addStrLit b.header
  b.addRaw ".}"
  for fnc in ctx.api.functions:
    generateProc(b, fnc)
    # b.addNL()
  b.addRaw "\n{.pop.}\n"
  b.addRaw afterFuncs
  b.addNL()
  # Generate getter procs
  for x in ctx.readOnlyFieldAccessors:
    b.addRaw "proc "
    b.addIdent x.name
    b.addRaw "*(x: "
    b.addRaw x.`type`
    b.addRaw "): "
    b.addRaw x.dirty # stores the returnType
    b.addRaw " {.inline.} = x."
    b.addIdent x.name
    b.addNL()
  # Generate wrapped functions
  for fnc in ctx.funcsToWrap:
    generateWrappedProc(b, fnc)
    b.addNL()
  b.addRaw moduleEnd
