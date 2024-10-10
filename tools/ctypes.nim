import std/strutils

const
  TypeMapping = {
    "char **": "cstringArray",
    "char**": "cstringArray",
    "void **": "ptr pointer",
    "void**": "ptr pointer",
    "char *": "cstring",
    "char*": "cstring",
    "void *": "pointer",
    "void*": "pointer",
    "signed char": "int8",
    "unsigned char": "uint8",
    "short int": "int16",
    "short": "int16",
    "signed short int": "int16",
    "signed short": "int16",
    "unsigned short int": "uint16",
    "unsigned short": "uint16",
    "int": "int32",
    "signed int": "int32",
    "signed": "int32",
    "unsigned int": "uint32",
    "unsigned": "uint32",
    "long int": "int32",
    "long": "int32",
    "signed long int": "int32",
    "signed long": "int32",
    "unsigned long int": "uint32",
    "unsigned long": "uint32",
    "long long int": "int64",
    "long long": "int64",
    "signed long long int": "int64",
    "signed long long": "int64",
    "unsigned long long int": "uint64",
    "unsigned long long": "uint64",
    "float": "float32",
    "double": "float64",
    "long double": "float64",
    "bool": "bool",
    "size_t": "uint",
    "ssize_t": "int",
    "ptrdiff_t": "int",
    "int8_t": "int8",
    "uint8_t": "uint8",
    "int16_t": "int16",
    "uint16_t": "uint16",
    "int32_t": "int32",
    "uint32_t": "uint32",
    "int64_t": "int64",
    "uint64_t": "uint64",
    "intptr_t": "int",
    "uintptr_t": "uint",
    "intmax_t": "BiggestInt",
    "uintmax_t": "BiggestUInt",
    "float3": "Float3",
    "float16": "Float16",
    "rlVertexBuffer": "VertexBuffer",
    "rlRenderBatch": "RenderBatch",
    "rlDrawCall": "DrawCall",
  }

type
  PointerType* = enum
    ptPtr
    ptVar
    ptOut
    ptArray
    ptOpenArray

proc convertPointerType(s: string, pointerType: PointerType): string =
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

proc convertArrayType(s: string, pointerType: PointerType): string =
  result = s
  if result.endsWith("]"):
    let openBracket = result.find('[')
    let arraySize = result[openBracket + 1 ..< result.high]
    result = convertPointerType(result[0 ..< openBracket], pointerType)
    result = "array[" & arraySize & ", " & result & "]"
  else:
    result = convertPointerType(result, pointerType)

proc convertType*(s: string; pointerType = ptPtr): string =
  result = s.replace("const ", "")
  result = result.multiReplace(TypeMapping)
  result = convertArrayType(result, pointerType)

when isMainModule:
  assert convertType("Transform **", ptArray) == "ptr UncheckedArray[ptr UncheckedArray[Transform]]"
  assert convertType("unsigned int *") == "ptr uint32"
  assert convertType("void **") == "ptr pointer"
  assert convertType("void *") == "pointer"
  assert convertType("const char *") == "cstring"
  assert convertType("const char**") == "cstringArray"
  assert convertType("char **") == "cstringArray"
  assert convertType("Image *", ptOpenArray) == "openArray[Image]"
  assert convertType("const char *[MAX_TEXT_COUNT]", ptOpenArray) == "array[MAX_TEXT_COUNT, cstring]"
