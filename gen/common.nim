import eminim, std/[algorithm, strutils, strscans, strformat, streams, parsejson]

const
  nimKeyw = ["addr", "and", "as", "asm",
    "bind", "block", "break",
    "case", "cast", "concept", "const", "continue", "converter",
    "defer", "discard", "distinct", "div", "do",
    "elif", "else", "end", "enum", "except", "export",
    "finally", "for", "from", "func",
    "if", "import", "in", "include", "interface", "is", "isnot", "iterator",
    "let",
    "macro", "method", "mixin", "mod",
    "nil", "not", "notin",
    "object", "of", "or", "out",
    "proc", "ptr",
    "raise", "ref", "return",
    "shl", "shr", "static",
    "template", "try", "tuple", "type",
    "using",
    "var",
    "when", "while",
    "xor",
    "yield"]

type
  Topmost* = object
    structs*: seq[StructInfo]
    enums*: seq[EnumInfo]
    functions*: seq[FunctionInfo]

  FunctionInfo* = object
    name*, description*, returnType*: string
    params*: Params
  Params* = seq[(string, string)]

  StructInfo* = object
    name*, description*: string
    fields*: seq[FieldInfo]

  FieldInfo* = object
    name*, `type`*, description*: string

  EnumInfo* = object
    name*, description*: string
    values*: seq[ValueInfo]

  ValueInfo* = object
    name*: string
    value*: int
    description*: string

proc initFromJson(dst: var Params; p: var JsonParser) =
  eat(p, tkCurlyLe)
  while p.tok != tkCurlyRi:
    if p.tok != tkString:
      raiseParseErr(p, "string literal as key")
    var keyValPair: (string, string)
    keyValPair[0] = move p.a
    discard getTok(p)
    eat(p, tkColon)
    initFromJson(keyValPair[1], p)
    dst.add keyValPair
    if p.tok != tkComma: break
    discard getTok(p)
  eat(p, tkCurlyRi)

proc parseApi*(fname: string): Topmost =
  var inp: FileStream
  try:
    inp = openFileStream(fname)
    result = inp.jsonTo(Topmost)
  finally:
    if inp != nil: inp.close()

proc addIndent*(result: var string, indent: int) =
  result.add("\n")
  for i in 1..indent:
    result.add(' ')

proc toNimType*(x: string): string =
  case x
  of "float":
    "float32"
  of "double":
    "float"
  of "short":
    "int16"
  of "long":
    "int64"
  of "rAudioBuffer":
    "RAudioBuffer"
  of "float3":
    "Float3"
  of "float16":
    "Float16"
  else: x

proc convertType*(s: string, sub: string, many: bool): string =
  var isVoid = false
  var isPointer = false
  var isDoublePointer = false
  var isChar = false
  var isUnsigned = false
  var isSizeT = false
  var isSigned = false
  for (token, isSep) in tokenize(s):
    if isSep: continue
    case token
    of "const":
      discard
    of "void":
      isVoid = true
    of "*":
      isPointer = true
    of "**":
      isDoublePointer = true
    of "char":
      isChar = true
    of "unsigned":
      isUnsigned = true
    of "size_t":
      isSizeT = true
    of "signed":
      isSigned = true
    of "int":
      discard
    else:
      result = toNimType(token)
  if result == "": result = "int32"
  if isSizeT:
    result = "csize_t"
  elif isChar:
    if isUnsigned:
      result = "uint8"
    else:
      result = "char"
  elif isUnsigned:
    result = "u" & result
  if sub != "":
    result = sub % result
  elif isChar and not isUnsigned:
    if isDoublePointer:
      result = "cstringArray"
    elif isPointer:
      result = "cstring"
  elif isPointer:
    if isVoid:
      result = "pointer"
    elif many:
      result = "ptr UncheckedArray[" & result & "]"
    else:
      result = "ptr " & result
  elif isDoublePointer:
    if isVoid:
      result = "ptr pointer"
    elif many:
      result = "ptr UncheckedArray[ptr " & result & "]"
    else:
      result = "ptr ptr " & result

proc hasMany*(x: string): bool {.inline.} =
  let x = strip(x, false, chars = Digits)
  x.endsWith("es") or (not x.endsWith("ss") and x.endsWith('s')) or
      endsWith(x.normalize, "data")

proc transFieldName*(x: string): (string, string) =
  var name: string
  var len: int
  if scanf(x, "$w[$i]$.", name, len):
    result = (name, &"array[{len}, $1]")
  else:
    if validIdentifier(x):
      result = (x, "")
    else:
      result = (replace(x, ",", "*,"), "")

proc camelCaseAscii*(s: string): string =
  var L = s.len
  while L > 0 and s[L-1] == '_': dec L
  result = newStringOfCap(L)
  var i = 0
  result.add s[i]
  inc i
  var flip = false
  while i < L:
    if s[i] == '_':
      flip = true
    else:
      if flip:
        result.add toUpperAscii(s[i])
        flip = false
      else: result.add toLowerAscii(s[i])
    inc i

proc allSequential*(x: seq[ValueInfo]): bool =
  var prev = x[0].value
  for i in 1..x.high:
    let xi = x[i].value
    if prev + 1 < xi:
      return false
    prev = xi
  result = true

proc uncapitalizeAscii*(s: string): string =
  if s.len == 0: result = ""
  else: result = toLowerAscii(s[0]) & substr(s, 1)

proc isKeyword*(s: string): bool {.inline.} = binarySearch(nimKeyw, s) >= 0
