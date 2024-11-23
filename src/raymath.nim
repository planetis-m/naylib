import std/math
from raylib import Vector2, Vector3, Vector4, Quaternion, Matrix
export Vector2, Vector3, Vector4, Quaternion, Matrix

type
  Float3* = array[3, float32]
  Float16* = array[16, float32]

func toFloatV*(v: Vector3): Float3 {.inline, noinit.} =
  ## Get Vector3 as float array
  # result = default(Float3)
  result[0] = v.x
  result[1] = v.y
  result[2] = v.z

func toFloatV*(mat: Matrix): Float16 {.inline, noinit.} =
  ## Get float array of matrix data
  # result = default(Float16)
  result[0] = mat.m0
  result[1] = mat.m1
  result[2] = mat.m2
  result[3] = mat.m3
  result[4] = mat.m4
  result[5] = mat.m5
  result[6] = mat.m6
  result[7] = mat.m7
  result[8] = mat.m8
  result[9] = mat.m9
  result[10] = mat.m10
  result[11] = mat.m11
  result[12] = mat.m12
  result[13] = mat.m13
  result[14] = mat.m14
  result[15] = mat.m15

func zero*(_: typedesc[Vector2]): Vector2 {.inline.} =
  ## Vector with components value 0'f32
  result = Vector2(x: 0, y: 0)

func one*(_: typedesc[Vector2]): Vector2 {.inline.} =
  ## Vector with components value 1'f32
  result = Vector2(x: 1, y: 1)

func unitX*(_: typedesc[Vector2]): Vector2 {.inline.} =
  ## Unit vector along X axis
  result = Vector2(x: 1, y: 0)

func unitY*(_: typedesc[Vector2]): Vector2 {.inline.} =
  ## Unit vector along Y axis
  result = Vector2(x: 0, y: 1)

func zero*(_: typedesc[Vector3]): Vector3 {.inline.} =
  ## Vector with components value 0'f32
  result = Vector3(x: 0, y: 0, z: 0)

func one*(_: typedesc[Vector3]): Vector3 {.inline.} =
  ## Vector with components value 1'f32
  result = Vector3(x: 1, y: 1, z: 1)

func unitX*(_: typedesc[Vector3]): Vector3 {.inline.} =
  ## Unit vector along X axis
  result = Vector3(x: 1, y: 0, z: 0)

func unitY*(_: typedesc[Vector3]): Vector3 {.inline.} =
  ## Unit vector along Y axis
  result = Vector3(x: 0, y: 1, z: 0)

func unitZ*(_: typedesc[Vector3]): Vector3 {.inline.} =
  ## Unit vector along Z axis
  result = Vector3(x: 0, y: 0, z: 1)

func zero*(_: typedesc[Vector4]): Vector4 {.inline.} =
  ## Vector with components value 0'f32
  result = Vector4(x: 0, y: 0, z: 0, w: 0)

func one*(_: typedesc[Vector4]): Vector4 {.inline.} =
  ## Vector with components value 1'f32
  result = Vector4(x: 1, y: 1, z: 1, w: 1)

func unitX*(_: typedesc[Vector4]): Vector4 {.inline.} =
  ## Unit vector along X axis
  result = Vector4(x: 1, y: 0, z: 0, w: 0)

func unitY*(_: typedesc[Vector4]): Vector4 {.inline.} =
  ## Unit vector along Y axis
  result = Vector4(x: 0, y: 1, z: 0, w: 0)

func unitZ*(_: typedesc[Vector4]): Vector4 {.inline.} =
  ## Unit vector along Z axis
  result = Vector4(x: 0, y: 0, z: 1, w: 0)

func unitW*(_: typedesc[Vector4]): Vector4 {.inline.} =
  ## Unit vector along W axis
  result = Vector4(x: 0, y: 0, z: 0, w: 1)

func identity*(_: typedesc[Matrix]): Matrix {.inline.} =
  ## Get identity matrix
  result = Matrix(m0: 1, m4: 0, m8: 0, m12: 0, m1: 0, m5: 1,
                  m9: 0, m13: 0, m2: 0, m6: 0, m10: 1, m14: 0,
                  m3: 0, m7: 0, m11: 0, m15: 1)

func identity*(_: typedesc[Quaternion]): Quaternion {.inline.} =
  ## Get identity quaternion
  result = Vector4(x: 0, y: 0, z: 0, w: 1).Quaternion

{.push callconv: cdecl, header: "raymath.h".}
func clamp*(value: float32, min: float32, max: float32): float32 {.importc: "Clamp".}
func lerp*(start: float32, `end`: float32, amount: float32): float32 {.importc: "Lerp".}
func normalize*(value: float32, start: float32, `end`: float32): float32 {.importc: "Normalize".}
func remap*(value: float32, inputStart: float32, inputEnd: float32, outputStart: float32, outputEnd: float32): float32 {.importc: "Remap".}
func wrap*(value: float32, min: float32, max: float32): float32 {.importc: "Wrap".}
func equals*(x: float32, y: float32): int32 {.importc: "FloatEquals".}
func add*(v1: Vector2, v2: Vector2): Vector2 {.importc: "Vector2Add".}
func addValue*(v: Vector2, add: float32): Vector2 {.importc: "Vector2AddValue".}
func subtract*(v1: Vector2, v2: Vector2): Vector2 {.importc: "Vector2Subtract".}
func subtractValue*(v: Vector2, sub: float32): Vector2 {.importc: "Vector2SubtractValue".}
func length*(v: Vector2): float32 {.importc: "Vector2Length".}
func lengthSqr*(v: Vector2): float32 {.importc: "Vector2LengthSqr".}
func dotProduct*(v1: Vector2, v2: Vector2): float32 {.importc: "Vector2DotProduct".}
proc crossProduct*(v1: Vector2, v2: Vector2): float32 {.importc: "Vector2CrossProduct", sideEffect.}
func distance*(v1: Vector2, v2: Vector2): float32 {.importc: "Vector2Distance".}
func distanceSqr*(v1: Vector2, v2: Vector2): float32 {.importc: "Vector2DistanceSqr".}
func angle*(v1: Vector2, v2: Vector2): float32 {.importc: "Vector2Angle".}
func lineAngle*(start: Vector2, `end`: Vector2): float32 {.importc: "Vector2LineAngle".}
func scale*(v: Vector2, scale: float32): Vector2 {.importc: "Vector2Scale".}
func multiply*(v1: Vector2, v2: Vector2): Vector2 {.importc: "Vector2Multiply".}
func negate*(v: Vector2): Vector2 {.importc: "Vector2Negate".}
func divide*(v1: Vector2, v2: Vector2): Vector2 {.importc: "Vector2Divide".}
func normalize*(v: Vector2): Vector2 {.importc: "Vector2Normalize".}
func transform*(v: Vector2, mat: Matrix): Vector2 {.importc: "Vector2Transform".}
func lerp*(v1: Vector2, v2: Vector2, amount: float32): Vector2 {.importc: "Vector2Lerp".}
func reflect*(v: Vector2, normal: Vector2): Vector2 {.importc: "Vector2Reflect".}
func min*(v1: Vector2, v2: Vector2): Vector2 {.importc: "Vector2Min".}
func max*(v1: Vector2, v2: Vector2): Vector2 {.importc: "Vector2Max".}
func rotate*(v: Vector2, angle: float32): Vector2 {.importc: "Vector2Rotate".}
func moveTowards*(v: Vector2, target: Vector2, maxDistance: float32): Vector2 {.importc: "Vector2MoveTowards".}
func invert*(v: Vector2): Vector2 {.importc: "Vector2Invert".}
func clamp*(v: Vector2, min: Vector2, max: Vector2): Vector2 {.importc: "Vector2Clamp".}
func clampValue*(v: Vector2, min: float32, max: float32): Vector2 {.importc: "Vector2ClampValue".}
func equals*(p: Vector2, q: Vector2): int32 {.importc: "Vector2Equals".}
func refract*(v: Vector2, n: Vector2, r: float32): Vector2 {.importc: "Vector2Refract".}
func add*(v1: Vector3, v2: Vector3): Vector3 {.importc: "Vector3Add".}
func addValue*(v: Vector3, add: float32): Vector3 {.importc: "Vector3AddValue".}
func subtract*(v1: Vector3, v2: Vector3): Vector3 {.importc: "Vector3Subtract".}
func subtractValue*(v: Vector3, sub: float32): Vector3 {.importc: "Vector3SubtractValue".}
func scale*(v: Vector3, scalar: float32): Vector3 {.importc: "Vector3Scale".}
func multiply*(v1: Vector3, v2: Vector3): Vector3 {.importc: "Vector3Multiply".}
func crossProduct*(v1: Vector3, v2: Vector3): Vector3 {.importc: "Vector3CrossProduct".}
func perpendicular*(v: Vector3): Vector3 {.importc: "Vector3Perpendicular".}
func length*(v: Vector3): float32 {.importc: "Vector3Length".}
func lengthSqr*(v: Vector3): float32 {.importc: "Vector3LengthSqr".}
func dotProduct*(v1: Vector3, v2: Vector3): float32 {.importc: "Vector3DotProduct".}
func distance*(v1: Vector3, v2: Vector3): float32 {.importc: "Vector3Distance".}
func distanceSqr*(v1: Vector3, v2: Vector3): float32 {.importc: "Vector3DistanceSqr".}
func angle*(v1: Vector3, v2: Vector3): float32 {.importc: "Vector3Angle".}
func negate*(v: Vector3): Vector3 {.importc: "Vector3Negate".}
func divide*(v1: Vector3, v2: Vector3): Vector3 {.importc: "Vector3Divide".}
func normalize*(v: Vector3): Vector3 {.importc: "Vector3Normalize".}
func project*(v1: Vector3, v2: Vector3): Vector3 {.importc: "Vector3Project".}
func reject*(v1: Vector3, v2: Vector3): Vector3 {.importc: "Vector3Reject".}
func orthoNormalize*(v1: var Vector3, v2: var Vector3) {.importc: "Vector3OrthoNormalize".}
func transform*(v: Vector3, mat: Matrix): Vector3 {.importc: "Vector3Transform".}
func rotateByQuaternion*(v: Vector3, q: Quaternion): Vector3 {.importc: "Vector3RotateByQuaternion".}
func rotateByAxisAngle*(v: Vector3, axis: Vector3, angle: float32): Vector3 {.importc: "Vector3RotateByAxisAngle".}
func moveTowards*(v: Vector3, target: Vector3, maxDistance: float32): Vector3 {.importc: "Vector3MoveTowards".}
func lerp*(v1: Vector3, v2: Vector3, amount: float32): Vector3 {.importc: "Vector3Lerp".}
func cubicHermite*(v1: Vector3, tangent1: Vector3, v2: Vector3, tangent2: Vector3, amount: float32): Vector3 {.importc: "Vector3CubicHermite".}
func reflect*(v: Vector3, normal: Vector3): Vector3 {.importc: "Vector3Reflect".}
func min*(v1: Vector3, v2: Vector3): Vector3 {.importc: "Vector3Min".}
func max*(v1: Vector3, v2: Vector3): Vector3 {.importc: "Vector3Max".}
func barycenter*(p: Vector3, a: Vector3, b: Vector3, c: Vector3): Vector3 {.importc: "Vector3Barycenter".}
func unproject*(source: Vector3, projection: Matrix, view: Matrix): Vector3 {.importc: "Vector3Unproject".}
func invert*(v: Vector3): Vector3 {.importc: "Vector3Invert".}
func clamp*(v: Vector3, min: Vector3, max: Vector3): Vector3 {.importc: "Vector3Clamp".}
func clampValue*(v: Vector3, min: float32, max: float32): Vector3 {.importc: "Vector3ClampValue".}
func equals*(p: Vector3, q: Vector3): int32 {.importc: "Vector3Equals".}
func refract*(v: Vector3, n: Vector3, r: float32): Vector3 {.importc: "Vector3Refract".}
func add*(v1: Vector4, v2: Vector4): Vector4 {.importc: "Vector4Add".}
func addValue*(v: Vector4, add: float32): Vector4 {.importc: "Vector4AddValue".}
func subtract*(v1: Vector4, v2: Vector4): Vector4 {.importc: "Vector4Subtract".}
func subtractValue*(v: Vector4, add: float32): Vector4 {.importc: "Vector4SubtractValue".}
func length*(v: Vector4): float32 {.importc: "Vector4Length".}
func lengthSqr*(v: Vector4): float32 {.importc: "Vector4LengthSqr".}
func dotProduct*(v1: Vector4, v2: Vector4): float32 {.importc: "Vector4DotProduct".}
func distance*(v1: Vector4, v2: Vector4): float32 {.importc: "Vector4Distance".}
func distanceSqr*(v1: Vector4, v2: Vector4): float32 {.importc: "Vector4DistanceSqr".}
func scale*(v: Vector4, scale: float32): Vector4 {.importc: "Vector4Scale".}
func multiply*(v1: Vector4, v2: Vector4): Vector4 {.importc: "Vector4Multiply".}
func negate*(v: Vector4): Vector4 {.importc: "Vector4Negate".}
func divide*(v1: Vector4, v2: Vector4): Vector4 {.importc: "Vector4Divide".}
func normalize*(v: Vector4): Vector4 {.importc: "Vector4Normalize".}
func min*(v1: Vector4, v2: Vector4): Vector4 {.importc: "Vector4Min".}
func max*(v1: Vector4, v2: Vector4): Vector4 {.importc: "Vector4Max".}
func lerp*(v1: Vector4, v2: Vector4, amount: float32): Vector4 {.importc: "Vector4Lerp".}
func moveTowards*(v: Vector4, target: Vector4, maxDistance: float32): Vector4 {.importc: "Vector4MoveTowards".}
func invert*(v: Vector4): Vector4 {.importc: "Vector4Invert".}
func equals*(p: Vector4, q: Vector4): int32 {.importc: "Vector4Equals".}
func determinant*(mat: Matrix): float32 {.importc: "MatrixDeterminant".}
func trace*(mat: Matrix): float32 {.importc: "MatrixTrace".}
func transpose*(mat: Matrix): Matrix {.importc: "MatrixTranspose".}
func invert*(mat: Matrix): Matrix {.importc: "MatrixInvert".}
func add*(left: Matrix, right: Matrix): Matrix {.importc: "MatrixAdd".}
func subtract*(left: Matrix, right: Matrix): Matrix {.importc: "MatrixSubtract".}
func multiply*(left: Matrix, right: Matrix): Matrix {.importc: "MatrixMultiply".}
func translate*(x: float32, y: float32, z: float32): Matrix {.importc: "MatrixTranslate".}
func rotate*(axis: Vector3, angle: float32): Matrix {.importc: "MatrixRotate".}
func rotateX*(angle: float32): Matrix {.importc: "MatrixRotateX".}
func rotateY*(angle: float32): Matrix {.importc: "MatrixRotateY".}
func rotateZ*(angle: float32): Matrix {.importc: "MatrixRotateZ".}
func rotateXYZ*(angle: Vector3): Matrix {.importc: "MatrixRotateXYZ".}
func rotateZYX*(angle: Vector3): Matrix {.importc: "MatrixRotateZYX".}
func scale*(x: float32, y: float32, z: float32): Matrix {.importc: "MatrixScale".}
func frustum*(left: float64, right: float64, bottom: float64, top: float64, nearPlane: float64, farPlane: float64): Matrix {.importc: "MatrixFrustum".}
func perspective*(fovY: float64, aspect: float64, nearPlane: float64, farPlane: float64): Matrix {.importc: "MatrixPerspective".}
func ortho*(left: float64, right: float64, bottom: float64, top: float64, nearPlane: float64, farPlane: float64): Matrix {.importc: "MatrixOrtho".}
func lookAt*(eye: Vector3, target: Vector3, up: Vector3): Matrix {.importc: "MatrixLookAt".}
func add*(q1: Quaternion, q2: Quaternion): Quaternion {.importc: "QuaternionAdd".}
func addValue*(q: Quaternion, add: float32): Quaternion {.importc: "QuaternionAddValue".}
func subtract*(q1: Quaternion, q2: Quaternion): Quaternion {.importc: "QuaternionSubtract".}
func subtractValue*(q: Quaternion, sub: float32): Quaternion {.importc: "QuaternionSubtractValue".}
func length*(q: Quaternion): float32 {.importc: "QuaternionLength".}
func normalize*(q: Quaternion): Quaternion {.importc: "QuaternionNormalize".}
func invert*(q: Quaternion): Quaternion {.importc: "QuaternionInvert".}
func multiply*(q1: Quaternion, q2: Quaternion): Quaternion {.importc: "QuaternionMultiply".}
func scale*(q: Quaternion, mul: float32): Quaternion {.importc: "QuaternionScale".}
func divide*(q1: Quaternion, q2: Quaternion): Quaternion {.importc: "QuaternionDivide".}
func lerp*(q1: Quaternion, q2: Quaternion, amount: float32): Quaternion {.importc: "QuaternionLerp".}
func nlerp*(q1: Quaternion, q2: Quaternion, amount: float32): Quaternion {.importc: "QuaternionNlerp".}
func slerp*(q1: Quaternion, q2: Quaternion, amount: float32): Quaternion {.importc: "QuaternionSlerp".}
func cubicHermiteSpline*(q1: Quaternion, outTangent1: Quaternion, q2: Quaternion, inTangent2: Quaternion, t: float32): Quaternion {.importc: "QuaternionCubicHermiteSpline".}
func fromVector3ToVector3*(`from`: Vector3, to: Vector3): Quaternion {.importc: "QuaternionFromVector3ToVector3".}
func fromMatrix*(mat: Matrix): Quaternion {.importc: "QuaternionFromMatrix".}
func toMatrix*(q: Quaternion): Matrix {.importc: "QuaternionToMatrix".}
func fromAxisAngle*(axis: Vector3, angle: float32): Quaternion {.importc: "QuaternionFromAxisAngle".}
func toAxisAngle*(q: Quaternion, outAxis: out Vector3, outAngle: out float32) {.importc: "QuaternionToAxisAngle".}
func fromEuler*(pitch: float32, yaw: float32, roll: float32): Quaternion {.importc: "QuaternionFromEuler".}
func toEuler*(q: Quaternion): Vector3 {.importc: "QuaternionToEuler".}
func transform*(q: Quaternion, mat: Matrix): Quaternion {.importc: "QuaternionTransform".}
func equals*(p: Quaternion, q: Quaternion): int32 {.importc: "QuaternionEquals".}
func decompose*(mat: Matrix, translation: out Vector3, rotation: out Quaternion, scale: out Vector3) {.importc: "MatrixDecompose".}
{.pop.}

template `=~`*[T: float32|Vector2|Vector3|Vector4|Quaternion](v1, v2: T): bool = equals(v1, v2)

template `+`*[T: Vector2|Vector3|Vector4|Quaternion|Matrix](v1, v2: T): T = add(v1, v2)
template `+=`*[T: Vector2|Vector3|Vector4|Quaternion|Matrix](v1: var T, v2: T) = v1 = add(v1, v2)
template `+`*[T: Vector2|Vector3|Vector4|Quaternion](v1: T, value: float32): T = addValue(v1, value)
template `+=`*[T: Vector2|Vector3|Vector4|Quaternion](v1: var T, value: float32) = v1 = addValue(v1, value)

template `-`*[T: Vector2|Vector3|Vector4|Quaternion|Matrix](v1, v2: T): T = subtract(v1, v2)
template `-=`*[T: Vector2|Vector3|Vector4|Quaternion|Matrix](v1: var T, v2: T) = v1 = subtract(v1, v2)
template `-`*[T: Vector2|Vector3|Vector4|Quaternion](v1: T, value: float32): T = subtractValue(v1, value)
template `-=`*[T: Vector2|Vector3|Vector4|Quaternion](v1: var T, value: float32) = v1 = subtractValue(v1, value)

template `*`*[T: Vector2|Vector3|Vector4|Quaternion|Matrix](v1, v2: T): T = multiply(v1, v2)
template `*=`*[T: Vector2|Vector3|Vector4|Quaternion|Matrix](v1: var T, v2: T) = v1 = multiply(v1, v2)
template `*`*[T: Vector2|Vector3|Vector4|Quaternion](v1: T, value: float32): T = scale(v1, value)
template `*=`*[T: Vector2|Vector3|Vector4|Quaternion](v1: var T, value: float32) = v1 = scale(v1, value)

template `/`*[T: Vector2|Vector3|Vector4|Quaternion|Matrix](v1, v2: T): T = divide(v1, v2)
template `/=`*[T: Vector2|Vector3|Vector4|Quaternion|Matrix](v1: var T, v2: T) = v1 = divide(v1, v2)
template `/`*[T: Vector2|Vector3|Vector4|Quaternion](v1: T, value: float32): T = scale(v1, 1'f32/value)
template `/=`*[T: Vector2|Vector3|Vector4|Quaternion](v1: var T, value: float32) = v1 = scale(v1, 1'f32/value)

template `-`*[T: Vector2|Vector3|Vector4](v1: T): T = negate(v1)
