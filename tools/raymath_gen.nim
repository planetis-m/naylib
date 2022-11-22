import common, std/[strutils, streams]
when defined(nimPreviewSlimSystem):
  import std/syncio

const
  raymathHeader = """
import std/math
from raylib import Vector2, Vector3, Vector4, Quaternion, Matrix
export Vector2, Vector3, Vector4, Quaternion, Matrix
"""
  excludedTypes = [
    "Vector2",
    "Vector3",
    "Vector4",
    "Matrix"
  ]
  raymathOps = """

template `+`*[T: Vector2|Vector3|Quaternion|Matrix](v1, v2: T): T = add(v1, v2)
template `+=`*[T: Vector2|Vector3|Quaternion|Matrix](v1: var T, v2: T) = v1 = add(v1, v2)
template `+`*[T: Vector2|Vector3|Quaternion](v1: T, value: float32): T = addValue(v1, value)
template `+=`*[T: Vector2|Vector3|Quaternion](v1: var T, value: float32) = v1 = addValue(v1, value)

template `-`*[T: Vector2|Vector3|Quaternion|Matrix](v1, v2: T): T = subtract(v1, v2)
template `-=`*[T: Vector2|Vector3|Quaternion|Matrix](v1: var T, v2: T) = v1 = subtract(v1, v2)
template `-`*[T: Vector2|Vector3|Quaternion](v1: T, value: float32): T = subtractValue(v1, value)
template `-=`*[T: Vector2|Vector3|Quaternion](v1: var T, value: float32) = v1 = subtractValue(v1, value)

template `*`*[T: Vector2|Vector3|Quaternion|Matrix](v1, v2: T): T = multiply(v1, v2)
template `*=`*[T: Vector2|Vector3|Quaternion|Matrix](v1: var T, v2: T) = v1 = multiply(v1, v2)
template `*`*[T: Vector2|Vector3|Quaternion](v1: T, value: float32): T = scale(v1, value)
template `*=`*[T: Vector2|Vector3|Quaternion](v1: var T, value: float32) = v1 = scale(v1, value)

template `/`*[T: Vector2|Vector3|Quaternion|Matrix](v1, v2: T): T = divide(v1, v2)
template `/=`*[T: Vector2|Vector3|Quaternion|Matrix](v1: var T, v2: T) = v1 = divide(v1, v2)
template `/`*[T: Vector2|Vector3|Quaternion](v1: T, value: float32): T = scale(v1, 1'f32/value)
template `/=`*[T: Vector2|Vector3|Quaternion](v1: var T, value: float32) = v1 = scale(v1, 1'f32/value)

template `-`*[T: Vector2|Vector3](v1: T): T = negate(v1)
"""

proc genBindings(t: TopLevel, fname: string, header, footer: string) =
  var buf = newStringOfCap(50)
  var indent = 0
  var otp: FileStream
  try:
    otp = openFileStream(fname, fmWrite)
    lit header
    # Generate type definitions
    lit "\ntype"
    scope:
      for obj in items(t.structs):
        if obj.name in excludedTypes: continue
        spaces
        ident capitalizeAscii(obj.name)
        lit "* {.bycopy.} = object"
        doc obj
        scope:
          for fld in items(obj.fields):
            spaces
            var name = fld.name
            ident name
            lit "*: "
            # let kind = getReplacement(obj.name, name, replacement)
            # if kind != "":
            #   lit kind
            #   continue
            var baseKind = ""
            let kind = convertType(fld.`type`, "", false, false, baseKind)
            lit kind
            doc fld
        lit "\n"
    # Generate functions
    lit "\n{.push callconv: cdecl, header: \"raymath.h\".}"
    for fnc in items(t.functions):
      lit "\nproc "
      var name = fnc.name
      if name notin ["Vector2Zero", "Vector2One", "Vector3Zero",
                     "Vector3One", "MatrixIdentity", "QuaternionIdentity"]:
        removePrefix(name, "Vector2")
        removePrefix(name, "Vector3")
        removePrefix(name, "Matrix")
        removePrefix(name, "Quaternion")
      ident uncapitalizeAscii(name)
      lit "*("
      var hasVarargs = false
      for i, param in fnc.params.pairs:
        if param.name == "args" and param.`type` == "...":
          hasVarargs = true
        else:
          if i > 0: lit ", "
          ident param.name
          lit ": "
          var baseKind = ""
          let kind = convertType(param.`type`, "", false, true, baseKind)
          lit kind
      lit ")"
      if fnc.returnType != "void":
        lit ": "
        var baseKind = ""
        let kind = convertType(fnc.returnType, "", false, true, baseKind)
        lit kind
      lit " {.importc: \""
      ident fnc.name
      lit "\""
      if hasVarargs:
        lit ", varargs"
      lit ".}"
      if fnc.description != "":
        scope:
          spaces
          lit "## "
          lit fnc.description
    lit "\n"
    lit footer
  finally:
    if otp != nil: otp.close()

const
  raymathApi = "../api/raymath_api.json"
  outputname = "../src/raymath.nim"

proc main =
  var t = parseApi(raymathApi)
  genBindings(t, outputname, raymathHeader, raymathOps)

main()
