import eminim, std/[algorithm, strformat, streams, json]
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

proc isKeyword*(s: string): bool {.inline.} =
  ## Checks if an indentifier is a Nim keyword
  binarySearch(nimKeyw, s) >= 0

## The raylib_parser produces JSON with the following structure.
## The type definitions are used by the deserializer to process the file.
type
  TopLevel* = object
    # defines*: seq[DefineInfo]
    structs*: seq[StructInfo]
    callbacks*: seq[FunctionInfo]
    aliases*: seq[AliasInfo]
    enums*: seq[EnumInfo]
    functions*: seq[FunctionInfo]

  DefineType* = enum
    UNKNOWN, MACRO, GUARD, INT, LONG, FLOAT, FLOAT_MATH, DOUBLE, CHAR, STRING, COLOR

  DefineInfo* = object
    name*: string
    `type`*: DefineType
    value*: JsonNode
    description*: string
    isHex*: bool

  FunctionInfo* = object
    name*, description*, returnType*: string
    params*: seq[ParamInfo]

  ParamInfo* = object
    `type`*, name*: string

  StructInfo* = object
    name*, description*: string
    fields*: seq[FieldInfo]

  FieldInfo* = object
    `type`*, name*, description*: string

  EnumInfo* = object
    name*, description*: string
    values*: seq[ValueInfo]

  ValueInfo* = object
    name*: string
    value*: int
    description*: string

  AliasInfo* = object
    `type`*, name*, description*: string

proc parseApi*(fname: string): TopLevel =
  var inp: FileStream
  try:
    inp = openFileStream(fname)
    result = inp.jsonTo(TopLevel)
    for enm in mitems(result.enums):
      sort(enm.values, proc (x, y: ValueInfo): int = cmp(x.value, y.value))
  finally:
    if inp != nil: inp.close()

proc addIndent*(result: var string, indent: int) =
  result.add("\n")
  for i in 1..indent:
    result.add(' ')

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
  var tokens = s.splitWhitespace()

  for token in tokens:
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
        result.arraySize = result.arraySize.replace("RL_", "").camelCaseAscii()
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
  else:
    var result = cType
    result.removePrefix("rl")
    result

proc convertType*(s, pattern: string, many, isVar: bool, baseKind: var string): string =
  let typeInfo = parseType(s)
  result = toNimType(typeInfo.baseType)

  if typeInfo.isUnsigned:
    if result == "char":
      result = "uint8"
    else:
      result = "u" & result

  baseKind = result

  if pattern != "":
    return pattern % result

  if typeInfo.isDoublePointer:
    if result == "void":
      result = "ptr pointer"
    elif result == "char" and not typeInfo.isUnsigned:
      result = "cstringArray"
    elif many:
      result = &"ptr UncheckedArray[ptr {result}]"
    else:
      result = "ptr ptr " & result

  elif typeInfo.isPointer:
    if result == "void":
      result = "pointer"
    elif result == "char" and not typeInfo.isUnsigned:
      result = "cstring"
    elif many:
      result = &"ptr UncheckedArray[{result}]"
    else:
      if isVar:
        result = "var " & result
      else:
        result = "ptr " & result

  if typeInfo.isArray:
    result = &"array[{typeInfo.arraySize}, {result}]"

proc isPlural*(x: string): bool {.inline.} =
  ## Tries to determine if an identifier is plural
  let x = strip(x, false, chars = Digits)
  x.endsWith("es") or (not x.endsWith("ss") and x.endsWith('s')) or
      endsWith(x.normalize, "data")

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
