import std/strutils, utils

const
  TypeMapping = { # DON'T rearrange
    "char **": "cstringArray",
    "char *": "cstring",
    "char**": "cstringArray",
    "char*": "cstring",
    "void **": "ptr pointer",
    "void**": "ptr pointer",
    "void *": "pointer",
    "void*": "pointer",
    "double": "float64",
    "float16": "Float16",
    "float3": "Float3",
    "float": "float32",
    "long double": "float64",
    "ptrdiff_t": "int",
    "ssize_t": "int",
    "intptr_t": "int",
    "intmax_t": "BiggestInt",
    "int64_t": "int64",
    "int32_t": "int32",
    "int16_t": "int16",
    "int8_t": "int8",
    "bool": "bool",
    "short int": "int16",
    "short": "int16",
    "int": "int32",
    "long int": "int32",
    "long long int": "int64",
    "long long": "int64",
    "long": "int32",
    "signed char": "int8",
    "signed short int": "int16",
    "signed short": "int16",
    "signed int": "int32",
    "signed long int": "int32",
    "signed long long int": "int64",
    "signed long long": "int64",
    "signed long": "int32",
    "signed": "int32",
    "unsigned char": "uint8",
    "unsigned short int": "uint16",
    "unsigned short": "uint16",
    "unsigned int": "uint32",
    "unsigned long int": "uint32",
    "unsigned long long int": "uint64",
    "unsigned long long": "uint64",
    "unsigned long": "uint32",
    "unsigned": "uint32",
    "size_t": "uint",
    "uintptr_t": "uint",
    "uintmax_t": "BiggestUInt",
    "uint64_t": "uint64",
    "uint32_t": "uint32",
    "uint16_t": "uint16",
    "uint8_t": "uint8",
  }

type
  PointerType* = enum
    ptPtr
    ptVar
    ptOut
    ptArray
    ptOpenArray

proc convertPointerType(s: sink string, pointerType: PointerType): string =
  result = s
  if result.contains('*'):
    let pointerDepth = result.count('*')
    result = result.replace(" *", "")
    result = result.replace("*", "")
    for i in 1..pointerDepth - ord(pointerType in {ptVar, ptOut, ptOpenArray}):
      case pointerType:
      of ptPtr, ptVar, ptOut, ptOpenArray:
        result = "ptr " & result
      of ptArray:
        result = "ptr UncheckedArray[" & result & "]"
    case pointerType
    of ptVar: # can't be nested
      result = "var " & result
    of ptOut:
      result = "out " & result
    of ptOpenArray:
      result = "openArray[" & result & "]"
    else: discard

proc stripPrefixFromType(s: sink string; prefix: string): string =
  result = s
  if prefix.len == 0: return
  if result.startsWith(prefix) and not isDigit(result[prefix.len]):
    result.removePrefix(prefix)

proc normalizeArraySize(arraySize: sink string, prefix: string): string =
  result = stripPrefixFromType(arraySize, prefix)
  if result.isScreamingSnakeCaseAscii():
    result = result.camelCaseAscii()

proc convertArrayType(s: sink string; prefix: string; pointerType: PointerType): string =
  result = s
  if result.endsWith(']'):
    let openBracket = result.find('[')
    var arraySize = result[openBracket + 1 ..< result.high]
    arraySize = normalizeArraySize(arraySize, prefix)
    result = convertPointerType(result[0 ..< openBracket],
        if pointerType in {ptPtr, ptArray}: pointerType else: ptPtr) # nestable types
    result = "array[" & arraySize & ", " & result & "]"
  else:
    result = convertPointerType(result, pointerType)

proc convertType*(s: string; prefix = ""; pointerType = ptPtr): string =
  result = s.replace("const ", "")
  result = result.multiReplace(TypeMapping)
  result = stripPrefixFromType(result, prefix)
  result = convertArrayType(result, prefix, pointerType)

when isMainModule:
  import std/assertions

  assert convertType("rlDrawCall", "rl") == "DrawCall"
  assert convertType("BorderlessWindowed", prefix = "rl") == "BorderlessWindowed"
  assert convertType("int[RL_MAX_GAMEPADS]", "RL_") == "array[MaxGamepads, int32]"
  assert convertType("const rlDrawCall *", "rl", pointerType = ptArray) == "ptr UncheckedArray[DrawCall]"
  assert convertType("Transform **") == "ptr ptr Transform"
  assert convertType("Transform **", pointerType = ptArray) == "ptr UncheckedArray[ptr UncheckedArray[Transform]]"
  assert convertType("const char *") == "cstring"
  assert convertType("const char**") == "cstringArray"
  assert convertType("const char *[MAX_TEXT_COUNT]", pointerType = ptArray) == "array[MaxTextCount, cstring]"
  assert convertType("Image *", pointerType = ptOpenArray) == "openArray[Image]"
  assert convertType("Image *[4]", pointerType = ptVar) == "array[4, ptr Image]"
  assert convertType("Image *[4]", pointerType = ptArray) == "array[4, ptr UncheckedArray[Image]]"
  for cType, nType in TypeMapping.items:
    assert convertType(cType) == nType, "Failed converting: " & cType
