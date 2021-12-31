import common, std/[algorithm, strutils, streams, strformat]

const
  raymathHeader = """
from raylib import Vector2, Vector3, Vector4, Quaternion, Matrix

const lext = when defined(windows): ".dll" elif defined(macosx): ".dylib" else: ".so"
{.pragma: rmapi, cdecl, dynlib: "libraylib" & lext.}
"""
  excludedTypes = [
    "Vector2",
    "Vector3",
    "Vector4",
    "Matrix"
  ]
  raymathOps = """

template `+`*[T: Vector2 | Vector3 | Quaternion | Matrix](v1, v2: T): T = add(v1, v2)
template `+=`*[T: Vector2 | Vector3 | Quaternion | Matrix](v1: var T, v2: T) = v1 = add(v1, v2)
template `+`*[T: Vector2 | Vector3 | Quaternion](v1: T, value: float32): T = addValue(v1, value)
template `+=`*[T: Vector2 | Vector3 | Quaternion](v1: var T, value: float32) = v1 = addValue(v1, value)

template `-`*[T: Vector2 | Vector3 | Quaternion | Matrix](v1, v2: T): T = subtract(v1, v2)
template `-=`*[T: Vector2 | Vector3 | Quaternion | Matrix](v1: var T, v2: T) = v1 = subtract(v1, v2)
template `-`*[T: Vector2 | Vector3 | Quaternion](v1: T, value: float32): T = subtractValue(v1, value)
template `-=`*[T: Vector2 | Vector3 | Quaternion](v1: var T, value: float32) = v1 = subtractValue(v1, value)

template `*`*[T: Vector2 | Vector3 | Quaternion | Matrix](v1, v2: T): T = multiply(v1, v2)
template `*=`*[T: Vector2 | Vector3 | Quaternion | Matrix](v1: var T, v2: T) = v1 = multiply(v1, v2)
template `*`*[T: Vector2 | Vector3 | Quaternion](v1: T, value: float32): T = scale(v1, value)
template `*=`*[T: Vector2 | Vector3 | Quaternion](v1: var T, value: float32) = v1 = scale(v1, value)

template `/`*[T: Vector2 | Vector3 | Quaternion | Matrix](v1, v2: T): T = divide(v1, v2)
template `/=`*[T: Vector2 | Vector3 | Quaternion | Matrix](v1: var T, v2: T) = v1 = divide(v1, v2)
template `/`*[T: Vector2 | Vector3 | Quaternion](v1: T, value: float32): T = scale(v1, 1'f32/value)
template `/=`*[T: Vector2 | Vector3 | Quaternion](v1: var T, value: float32) = v1 = scale(v1, 1'f32/value)

template `-`*[T: Vector2 | Vector3](v1: T): T = negate(v1)
"""

proc genBindings(t: Topmost, fname: string, header, footer: string) =
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
            var (name, pat) = transFieldName(fld.name)
            ident name
            lit "*: "
            let kind = convertType(fld.`type`, pat, false)
            lit kind
            doc fld
        lit "\n"
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
      for i, (param, kind) in fnc.params.pairs:
        if param == "" and kind == "":
          hasVarargs = true
        else:
          if i > 0: lit ", "
          ident param
          lit ": "
          let kind = convertType(kind, "", false)
          lit kind
      lit ")"
      if fnc.returnType != "void":
        lit ": "
        let kind = convertType(fnc.returnType, "", false)
        lit kind
      lit " {.importc: \""
      ident fnc.name
      lit "\""
      if hasVarargs:
        lit ", varargs"
      lit ", rmapi.}"
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
  raylibApi = "../api/raymath_api.json"
  outputname = "../raymath.nim"

proc main =
  var t = parseApi(raylibApi)
  genBindings(t, outputname, raymathHeader, raymathOps)

main()
