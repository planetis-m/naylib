import eminim, std/[algorithm, strscans, strformat, streams]
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
    #defines*: seq[DefineInfo]
    structs*: seq[StructInfo]
    callbacks*: seq[FunctionInfo]
    aliases*: seq[AliasInfo]
    enums*: seq[EnumInfo]
    functions*: seq[FunctionInfo]

  DefineType* = enum
    UNKNOWN, MACRO, GUARD, INT, LONG, FLOAT, DOUBLE, CHAR, STRING, COLOR
  DefineInfo* = object
    name*: string
    `type`*: DefineType
    value*, description*: string
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
  finally:
    if inp != nil: inp.close()

proc addIndent*(result: var string, indent: int) =
  result.add("\n")
  for i in 1..indent:
    result.add(' ')

proc toNimType*(x: string): string =
  ## Translates a single C identifier to the equivalent Nim type.
  ## Also used to make replacements.
  case x
  of "float":
    "float32"
  of "double":
    "float"
  of "short":
    "int16"
  of "long":
    "int64"
  of "float3":
    "Float3"
  of "float16":
    "Float16"
  else: x

proc convertType*(s: string, pattern: string, many, isVar: bool, baseKind: var string): string =
  ## Converts a C type to the equivalent Nim type.
  ## Should work with function parameters, return, and struct fields types.
  ## If a `pattern` is provided, it substitutes the found base type and returns it.
  ## `many` hints the generation of `ptr UncheckedArray` instead of `ptr`.
  ## NOTE: expects `s` to be formatted with spaces, `MyType*` needs to be `MyType *`
  var isVoid = false
  var isPointer = false
  var isDoublePointer = false
  var isChar = false
  var isUnsigned = false
  var isSizeT = false
  var isSigned = false
  for token, isSep in tokenize(s):
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
      var len = 0
      if scanf(token, "$w[$i]$.", result, len):
        result = "array[" & $len & ", " & toNimType(result) & "]"
      else: result = toNimType(token)
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
  baseKind = result
  if pattern != "":
    result = pattern % result
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
      if isVar:
        result = "var " & result
      else: result = "ptr " & result
  elif isDoublePointer:
    if isVoid:
      result = "ptr pointer"
    elif many:
      result = "ptr UncheckedArray[ptr " & result & "]"
    else:
      result = "ptr ptr " & result

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
