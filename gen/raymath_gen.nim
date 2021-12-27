import common, std/[algorithm, streams, strformat]
import strutils except indent

const
  indWidth = 2
  header = """
from raylib import Vector2, Vector3, Vector4, Quaternion, Matrix

const lext = when defined(windows): ".dll" elif defined(macosx): ".dylib" else: ".so"
{.pragma: rmapi, cdecl, dynlib: "libraylib" & lext.}
"""
  excluded = [
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

const
  raylibApi = "../api/raymath_api.json"
  outputname = "../raymath.nim"

proc main =
  template ident(x: string) =
    buf.setLen 0
    let isKeyw = isKeyword(x)
    if isKeyw:
      buf.add '`'
    buf.add x
    if isKeyw:
      buf.add '`'
    otp.write buf
  template lit(x: string) = otp.write x
  template spaces =
    buf.setLen 0
    addIndent(buf, indent)
    otp.write buf
  template scope(body: untyped) =
    inc indent, indWidth
    body
    dec indent, indWidth
  template doc(x: untyped) =
    if x.description != "":
      lit " ## "
      lit x.description

  var top = parseApi(raylibApi)

  var buf = newStringOfCap(50)
  var indent = 0
  var otp: FileStream
  try:
    otp = openFileStream(outputname, fmWrite)
    lit header
    # Generate type definitions
    lit "\ntype"
    scope:
      for obj in items(top.structs):
        if obj.name in excluded: continue
        spaces
        ident capitalizeAscii(obj.name)
        lit "* {.bycopy.} = object"
        doc obj
        scope:
          for fld in items(obj.fields):
            spaces
            var (name, sub) = transFieldName(fld.name)
            ident name
            lit "*: "
            let kind = convertType(fld.`type`, sub, false)
            lit kind
            doc fld
        lit "\n"
    for fnc in items(top.functions):
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
      for i, (name, kind) in fnc.params.pairs:
        if name == "" and kind == "":
          hasVarargs = true
        else:
          if i > 0: lit ", "
          ident name
          lit ": "
          let kind = convertType(kind, "", false)
          lit kind
      lit ")"
      if fnc.returnType != "void":
        lit ": "
        let kind = convertType(fnc.returnType, "", false)
        ident kind
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
    lit raymathOps
  finally:
    if otp != nil: otp.close()

main()
