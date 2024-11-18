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
