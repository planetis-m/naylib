## The raylib_parser produces JSON with the following structure.
## The type definitions are used by the deserializer to process the file.
import std/[streams, json, parsejson]
import eminim

type
  BaseInfo* = object of RootObj
    flags*: set[InfoFlags]

  InfoFlags* = enum
    isPrivate, isWrappedFunc, isAutoWrappedFunc, hasVarargs, isOpenArray, isPtArray,
    isVarParam, isDistinct, isCompleteStruct, isString, isFunc, isArrayLen

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
    `type`*, name*, dirty*: string

  StructInfo* = object of BaseInfo
    name*, importName*, description*: string
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

  ApiContext* = object
    api*: TopLevel
    readOnlyFieldAccessors*: seq[ParamInfo]
    boundCheckedArrayAccessors*: seq[AliasInfo]
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
