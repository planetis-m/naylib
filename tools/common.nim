import eminim, std/[algorithm, strformat, streams, json, parsejson]
import strutils except indent

const
  indWidth* = 2
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

## The raylib_parser produces JSON with the following structure.
## The type definitions are used by the deserializer to process the file.
type
  BaseInfo* = object of RootObj
    flags*: set[InfoFlags]

  InfoFlags* = enum
    isPrivate, isWrappedFunc, hasVarargs, isOpenArray, isVarParam, isOutParam,
    isDistinct, isCompleteStruct, isMangled, isString, isFunc, isArrayLength

  TopLevel* = object
    defines*: seq[DefineInfo]
    structs*: seq[StructInfo]
    callbacks*: seq[FunctionInfo]
    aliases*: seq[AliasInfo]
    enums*: seq[EnumInfo]
    functions*: seq[FunctionInfo]

  DefineType* = enum
    UNKNOWN, MACRO, GUARD, INT, LONG, FLOAT, FLOAT_MATH, DOUBLE, CHAR, STRING, COLOR

  DefineValue* = distinct string

  DefineInfo* = object of BaseInfo
    name*: string
    `type`*: DefineType
    value*: DefineValue
    description*: string

  FunctionInfo* = object of BaseInfo
    name*, importName*, description*, returnType*: string
    params*: seq[ParamInfo]

  ParamInfo* = object of BaseInfo
    `type`*, baseType*, name*: string

  StructInfo* = object of BaseInfo
    name*, description*: string
    fields*: seq[FieldInfo]

  FieldInfo* = object of BaseInfo
    `type`*, name*, description*: string

  EnumInfo* = object of BaseInfo
    name*, description*: string
    values*: seq[ValueInfo]

  ValueInfo* = object of BaseInfo
    name*: string
    value*: int
    description*: string

  AliasInfo* = object of BaseInfo
    `type`*, name*, description*: string

  PropertyInfo* = tuple[struct, field, `type`: string]

  ApiContext* = object
    api*: TopLevel
    readOnlyFieldAccessors*: seq[PropertyInfo]
    boundCheckedArrayAccessors*: seq[PropertyInfo]
    funcsToWrap*: seq[FunctionInfo]

proc initFromJson*(dst: var DefineValue; p: var JsonParser) =
  if p.tok == tkNull:
    dst = DefineValue""
    discard getTok(p)
  elif p.tok in {tkString, tkFloat, tkInt}:
    dst = DefineValue(p.a)
    discard getTok(p)
  else:
    raiseParseErr(p, "unkown define value")

proc parseApi*(fname: string): TopLevel =
  var inp: FileStream
  try:
    inp = openFileStream(fname)
    result = inp.jsonTo(TopLevel)
  finally:
    if inp != nil: inp.close()

proc getReplacement*(x, y: string, replacements: openarray[(string, string, string)]): string =
  # Manual replacements for some fields
  result = ""
  for a, b, pattern in replacements.items:
    if x == a and y == b:
      return pattern

proc camelCaseAscii*(s: string): string

type
  TypeInfo = object
    baseType: string
    isPointer: bool
    isDoublePointer: bool
    isUnsigned: bool
    isArray: bool
    arraySize: string

proc parseType(s: string): TypeInfo =
  result = TypeInfo()
  for token, isSep in tokenize(s):
    if isSep: continue
    case token
    of "unsigned": result.isUnsigned = true
    of "const", "signed": discard
    else:
      if "*" in token:
        result.isPointer = true
        if "**" in token: result.isDoublePointer = true

      let openBracket = token.find('[')
      let closeBracket = token.find(']')
      if openBracket != -1 and closeBracket != -1 and openBracket < closeBracket:
        result.isArray = true
        if result.baseType == "":
          result.baseType = token[0 ..< openBracket]
        result.arraySize = token[openBracket + 1 ..< closeBracket]
        removePrefix(result.arraySize, "RL_")
        result.arraySize = camelCaseAscii(result.arraySize)
      elif result.baseType == "":
        result.baseType = token
  if result.baseType == "":
    result.baseType = "int32"

proc toNimType(cType: string): string =
  case cType
  of "float": "float32"
  of "double": "float"
  of "short": "int16"
  of "long": "int64"
  of "int": "int32"
  of "float3": "Float3"
  of "float16": "Float16"
  of "size_t": "csize_t"
  of "char": "char"
  of "rlVertexBuffer": "VertexBuffer"
  of "rlRenderBatch": "RenderBatch"
  of "rlDrawCall": "DrawCall"
  else: cType

proc convertType*(s, pattern: string, many, isVar: bool): (string, string) =
  let typeInfo = parseType(s)
  var nimType = toNimType(typeInfo.baseType)

  if typeInfo.isUnsigned:
    if nimType == "char":
      nimType = "uint8"
    else:
      nimType = "u" & nimType

  let baseType = nimType

  if pattern != "":
    return (pattern % nimType, baseType)

  if typeInfo.isDoublePointer:
    if nimType == "void":
      nimType = "ptr pointer"
    elif nimType == "char" and not typeInfo.isUnsigned:
      nimType = "cstringArray"
    elif many:
      nimType = &"ptr UncheckedArray[ptr {nimType}]"
    else:
      nimType = "ptr ptr " & nimType

  elif typeInfo.isPointer:
    if nimType == "void":
      nimType = "pointer"
    elif nimType == "char" and not typeInfo.isUnsigned:
      nimType = "cstring"
    elif many:
      nimType = &"ptr UncheckedArray[{nimType}]"
    else:
      if isVar:
        nimType = "var " & nimType
      else:
        nimType = "ptr " & nimType

  if typeInfo.isArray:
    nimType = &"array[{typeInfo.arraySize}, {nimType}]"

  result = (nimType, baseType)

proc convertType*(s: string, many: bool): (string, string) =
  convertType(s, "", many, true)

proc isPlural*(x: string): bool {.inline.} =
  ## Tries to determine if an identifier is plural
  let x = strip(x, false, chars = Digits)
  x.endsWith("es") or (not (x.endsWith("ss") or x.endsWith("radius") or
      x.endsWith("Pos")) and x.endsWith('s')) or endsWith(x.normalize, "data")

proc camelCaseAscii*(s: string): string =
  ## Converts snake_case to CamelCase
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

proc uncapitalizeAscii*(s: string): string =
  if s.len == 0: result = ""
  else: result = toLowerAscii(s[0]) & substr(s, 1)

proc isKeyword*(s: string): bool {.inline.} =
  ## Checks if an indentifier is a Nim keyword
  binarySearch(nimKeyw, s) >= 0

proc addIndent*(result: var string, indent: int) =
  result.add("\n")
  for i in 1..indent:
    result.add(' ')

# used internally by the genBindings procs
template ident*(x: string) =
  buf.setLen 0
  let isKeyw = isKeyword(x)
  if isKeyw:
    buf.add '`'
  buf.add x
  if isKeyw:
    buf.add '`'
  otp.write buf
template lit*(x: string) = otp.write x
template spaces* =
  buf.setLen 0
  addIndent(buf, indent)
  otp.write buf
template scope*(body: untyped) =
  inc indent, indWidth
  body
  dec indent, indWidth
template doc*(x: untyped) =
  if x.description != "":
    lit " ## "
    lit x.description
