from raylib import Vector2, Vector3, Vector4, Quaternion, Matrix

const lext = when defined(windows): ".dll" elif defined(macosx): ".dylib" else: ".so"
{.pragma: rmapi, cdecl, dynlib: "libraylib" & lext.}

type
  Float3* {.bycopy.} = object ## NOTE: Helper types to be used instead of array return types for *ToFloat functions
    v*: array[3, float32]

  Float16* {.bycopy.} = object
    v*: array[16, float32]

proc clamp*(value: float32, min: float32, max: float32): float32 {.importc: "Clamp", rmapi.}
  ## Clamp float value
proc lerp*(start: float32, `end`: float32, amount: float32): float32 {.importc: "Lerp", rmapi.}
  ## Calculate linear interpolation between two floats
proc normalize*(value: float32, start: float32, `end`: float32): float32 {.importc: "Normalize", rmapi.}
  ## Normalize input value within input range
proc remap*(value: float32, inputStart: float32, inputEnd: float32, outputStart: float32, outputEnd: float32): float32 {.importc: "Remap", rmapi.}
  ## Remap input value within input range to output range
proc vector2Zero*(): Vector2 {.importc: "Vector2Zero", rmapi.}
  ## Vector with components value 0.0f
proc vector2One*(): Vector2 {.importc: "Vector2One", rmapi.}
  ## Vector with components value 1.0f
proc add*(v1: Vector2, v2: Vector2): Vector2 {.importc: "Vector2Add", rmapi.}
  ## Add two vectors (v1 + v2)
proc addValue*(v: Vector2, add: float32): Vector2 {.importc: "Vector2AddValue", rmapi.}
  ## Add vector and float value
proc subtract*(v1: Vector2, v2: Vector2): Vector2 {.importc: "Vector2Subtract", rmapi.}
  ## Subtract two vectors (v1 - v2)
proc subtractValue*(v: Vector2, sub: float32): Vector2 {.importc: "Vector2SubtractValue", rmapi.}
  ## Subtract vector by float value
proc length*(v: Vector2): float32 {.importc: "Vector2Length", rmapi.}
  ## Calculate vector length
proc lengthSqr*(v: Vector2): float32 {.importc: "Vector2LengthSqr", rmapi.}
  ## Calculate vector square length
proc dotProduct*(v1: Vector2, v2: Vector2): float32 {.importc: "Vector2DotProduct", rmapi.}
  ## Calculate two vectors dot product
proc distance*(v1: Vector2, v2: Vector2): float32 {.importc: "Vector2Distance", rmapi.}
  ## Calculate distance between two vectors
proc angle*(v1: Vector2, v2: Vector2): float32 {.importc: "Vector2Angle", rmapi.}
  ## Calculate angle from two vectors
proc scale*(v: Vector2, scale: float32): Vector2 {.importc: "Vector2Scale", rmapi.}
  ## Scale vector (multiply by value)
proc multiply*(v1: Vector2, v2: Vector2): Vector2 {.importc: "Vector2Multiply", rmapi.}
  ## Multiply vector by vector
proc negate*(v: Vector2): Vector2 {.importc: "Vector2Negate", rmapi.}
  ## Negate vector
proc divide*(v1: Vector2, v2: Vector2): Vector2 {.importc: "Vector2Divide", rmapi.}
  ## Divide vector by vector
proc normalize*(v: Vector2): Vector2 {.importc: "Vector2Normalize", rmapi.}
  ## Normalize provided vector
proc lerp*(v1: Vector2, v2: Vector2, amount: float32): Vector2 {.importc: "Vector2Lerp", rmapi.}
  ## Calculate linear interpolation between two vectors
proc reflect*(v: Vector2, normal: Vector2): Vector2 {.importc: "Vector2Reflect", rmapi.}
  ## Calculate reflected vector to normal
proc rotate*(v: Vector2, angle: float32): Vector2 {.importc: "Vector2Rotate", rmapi.}
  ## Rotate vector by angle
proc moveTowards*(v: Vector2, target: Vector2, maxDistance: float32): Vector2 {.importc: "Vector2MoveTowards", rmapi.}
  ## Move Vector towards target
proc vector3Zero*(): Vector3 {.importc: "Vector3Zero", rmapi.}
  ## Vector with components value 0.0f
proc vector3One*(): Vector3 {.importc: "Vector3One", rmapi.}
  ## Vector with components value 1.0f
proc add*(v1: Vector3, v2: Vector3): Vector3 {.importc: "Vector3Add", rmapi.}
  ## Add two vectors
proc addValue*(v: Vector3, add: float32): Vector3 {.importc: "Vector3AddValue", rmapi.}
  ## Add vector and float value
proc subtract*(v1: Vector3, v2: Vector3): Vector3 {.importc: "Vector3Subtract", rmapi.}
  ## Subtract two vectors
proc subtractValue*(v: Vector3, sub: float32): Vector3 {.importc: "Vector3SubtractValue", rmapi.}
  ## Subtract vector by float value
proc scale*(v: Vector3, scalar: float32): Vector3 {.importc: "Vector3Scale", rmapi.}
  ## Multiply vector by scalar
proc multiply*(v1: Vector3, v2: Vector3): Vector3 {.importc: "Vector3Multiply", rmapi.}
  ## Multiply vector by vector
proc crossProduct*(v1: Vector3, v2: Vector3): Vector3 {.importc: "Vector3CrossProduct", rmapi.}
  ## Calculate two vectors cross product
proc perpendicular*(v: Vector3): Vector3 {.importc: "Vector3Perpendicular", rmapi.}
  ## Calculate one vector perpendicular vector
proc length*(v: Vector3): float32 {.importc: "Vector3Length", rmapi.}
  ## Calculate vector length
proc lengthSqr*(v: Vector3): float32 {.importc: "Vector3LengthSqr", rmapi.}
  ## Calculate vector square length
proc dotProduct*(v1: Vector3, v2: Vector3): float32 {.importc: "Vector3DotProduct", rmapi.}
  ## Calculate two vectors dot product
proc distance*(v1: Vector3, v2: Vector3): float32 {.importc: "Vector3Distance", rmapi.}
  ## Calculate distance between two vectors
proc angle*(v1: Vector3, v2: Vector3): float32 {.importc: "Vector3Angle", rmapi.}
  ## Calculate angle between two vectors
proc negate*(v: Vector3): Vector3 {.importc: "Vector3Negate", rmapi.}
  ## Negate provided vector (invert direction)
proc divide*(v1: Vector3, v2: Vector3): Vector3 {.importc: "Vector3Divide", rmapi.}
  ## Divide vector by vector
proc normalize*(v: Vector3): Vector3 {.importc: "Vector3Normalize", rmapi.}
  ## Normalize provided vector
proc orthoNormalize*(v1: ptr Vector3, v2: ptr Vector3) {.importc: "Vector3OrthoNormalize", rmapi.}
  ## Orthonormalize provided vectors. Makes vectors normalized and orthogonal to each other. Gram-Schmidt function implementation
proc transform*(v: Vector3, mat: Matrix): Vector3 {.importc: "Vector3Transform", rmapi.}
  ## Transforms a Vector3 by a given Matrix
proc rotateByQuaternion*(v: Vector3, q: Quaternion): Vector3 {.importc: "Vector3RotateByQuaternion", rmapi.}
  ## Transform a vector by quaternion rotation
proc lerp*(v1: Vector3, v2: Vector3, amount: float32): Vector3 {.importc: "Vector3Lerp", rmapi.}
  ## Calculate linear interpolation between two vectors
proc reflect*(v: Vector3, normal: Vector3): Vector3 {.importc: "Vector3Reflect", rmapi.}
  ## Calculate reflected vector to normal
proc min*(v1: Vector3, v2: Vector3): Vector3 {.importc: "Vector3Min", rmapi.}
  ## Get min value for each pair of components
proc max*(v1: Vector3, v2: Vector3): Vector3 {.importc: "Vector3Max", rmapi.}
  ## Get max value for each pair of components
proc barycenter*(p: Vector3, a: Vector3, b: Vector3, c: Vector3): Vector3 {.importc: "Vector3Barycenter", rmapi.}
  ## Compute barycenter coordinates (u, v, w) for point p with respect to triangle (a, b, c). NOTE: Assumes P is on the plane of 
proc unproject*(source: Vector3, projection: Matrix, view: Matrix): Vector3 {.importc: "Vector3Unproject", rmapi.}
  ## Projects a Vector3 from screen space into object space. NOTE: We are avoiding calling other raymath functions despite availa
proc toFloatV*(v: Vector3): Float3 {.importc: "Vector3ToFloatV", rmapi.}
  ## Get Vector3 as float array
proc determinant*(mat: Matrix): float32 {.importc: "MatrixDeterminant", rmapi.}
  ## Compute matrix determinant
proc trace*(mat: Matrix): float32 {.importc: "MatrixTrace", rmapi.}
  ## Get the trace of the matrix (sum of the values along the diagonal)
proc transpose*(mat: Matrix): Matrix {.importc: "MatrixTranspose", rmapi.}
  ## Transposes provided matrix
proc invert*(mat: Matrix): Matrix {.importc: "MatrixInvert", rmapi.}
  ## Invert provided matrix
proc normalize*(mat: Matrix): Matrix {.importc: "MatrixNormalize", rmapi.}
  ## Normalize provided matrix
proc matrixIdentity*(): Matrix {.importc: "MatrixIdentity", rmapi.}
  ## Get identity matrix
proc add*(left: Matrix, right: Matrix): Matrix {.importc: "MatrixAdd", rmapi.}
  ## Add two matrices
proc subtract*(left: Matrix, right: Matrix): Matrix {.importc: "MatrixSubtract", rmapi.}
  ## Subtract two matrices (left - right)
proc multiply*(left: Matrix, right: Matrix): Matrix {.importc: "MatrixMultiply", rmapi.}
  ## Get two matrix multiplication. NOTE: When multiplying matrices... the order matters!
proc translate*(x: float32, y: float32, z: float32): Matrix {.importc: "MatrixTranslate", rmapi.}
  ## Get translation matrix
proc rotate*(axis: Vector3, angle: float32): Matrix {.importc: "MatrixRotate", rmapi.}
  ## Create rotation matrix from axis and angle. NOTE: Angle should be provided in radians
proc rotateX*(angle: float32): Matrix {.importc: "MatrixRotateX", rmapi.}
  ## Get x-rotation matrix (angle in radians)
proc rotateY*(angle: float32): Matrix {.importc: "MatrixRotateY", rmapi.}
  ## Get y-rotation matrix (angle in radians)
proc rotateZ*(angle: float32): Matrix {.importc: "MatrixRotateZ", rmapi.}
  ## Get z-rotation matrix (angle in radians)
proc rotateXYZ*(ang: Vector3): Matrix {.importc: "MatrixRotateXYZ", rmapi.}
  ## Get xyz-rotation matrix (angles in radians)
proc rotateZYX*(ang: Vector3): Matrix {.importc: "MatrixRotateZYX", rmapi.}
  ## Get zyx-rotation matrix (angles in radians)
proc scale*(x: float32, y: float32, z: float32): Matrix {.importc: "MatrixScale", rmapi.}
  ## Get scaling matrix
proc frustum*(left: float, right: float, bottom: float, top: float, near: float, far: float): Matrix {.importc: "MatrixFrustum", rmapi.}
  ## Get perspective projection matrix
proc perspective*(fovy: float, aspect: float, near: float, far: float): Matrix {.importc: "MatrixPerspective", rmapi.}
  ## Get perspective projection matrix. NOTE: Angle should be provided in radians
proc ortho*(left: float, right: float, bottom: float, top: float, near: float, far: float): Matrix {.importc: "MatrixOrtho", rmapi.}
  ## Get orthographic projection matrix
proc lookAt*(eye: Vector3, target: Vector3, up: Vector3): Matrix {.importc: "MatrixLookAt", rmapi.}
  ## Get camera look-at matrix (view matrix)
proc toFloatV*(mat: Matrix): Float16 {.importc: "MatrixToFloatV", rmapi.}
  ## Get float array of matrix data
proc add*(q1: Quaternion, q2: Quaternion): Quaternion {.importc: "QuaternionAdd", rmapi.}
  ## Add two quaternions
proc addValue*(q: Quaternion, add: float32): Quaternion {.importc: "QuaternionAddValue", rmapi.}
  ## Add quaternion and float value
proc subtract*(q1: Quaternion, q2: Quaternion): Quaternion {.importc: "QuaternionSubtract", rmapi.}
  ## Subtract two quaternions
proc subtractValue*(q: Quaternion, sub: float32): Quaternion {.importc: "QuaternionSubtractValue", rmapi.}
  ## Subtract quaternion and float value
proc quaternionIdentity*(): Quaternion {.importc: "QuaternionIdentity", rmapi.}
  ## Get identity quaternion
proc length*(q: Quaternion): float32 {.importc: "QuaternionLength", rmapi.}
  ## Computes the length of a quaternion
proc normalize*(q: Quaternion): Quaternion {.importc: "QuaternionNormalize", rmapi.}
  ## Normalize provided quaternion
proc invert*(q: Quaternion): Quaternion {.importc: "QuaternionInvert", rmapi.}
  ## Invert provided quaternion
proc multiply*(q1: Quaternion, q2: Quaternion): Quaternion {.importc: "QuaternionMultiply", rmapi.}
  ## Calculate two quaternion multiplication
proc scale*(q: Quaternion, mul: float32): Quaternion {.importc: "QuaternionScale", rmapi.}
  ## Scale quaternion by float value
proc divide*(q1: Quaternion, q2: Quaternion): Quaternion {.importc: "QuaternionDivide", rmapi.}
  ## Divide two quaternions
proc lerp*(q1: Quaternion, q2: Quaternion, amount: float32): Quaternion {.importc: "QuaternionLerp", rmapi.}
  ## Calculate linear interpolation between two quaternions
proc nlerp*(q1: Quaternion, q2: Quaternion, amount: float32): Quaternion {.importc: "QuaternionNlerp", rmapi.}
  ## Calculate slerp-optimized interpolation between two quaternions
proc slerp*(q1: Quaternion, q2: Quaternion, amount: float32): Quaternion {.importc: "QuaternionSlerp", rmapi.}
  ## Calculates spherical linear interpolation between two quaternions
proc fromVector3ToVector3*(`from`: Vector3, to: Vector3): Quaternion {.importc: "QuaternionFromVector3ToVector3", rmapi.}
  ## Calculate quaternion based on the rotation from one vector to another
proc fromMatrix*(mat: Matrix): Quaternion {.importc: "QuaternionFromMatrix", rmapi.}
  ## Get a quaternion for a given rotation matrix
proc toMatrix*(q: Quaternion): Matrix {.importc: "QuaternionToMatrix", rmapi.}
  ## Get a matrix for a given quaternion
proc fromAxisAngle*(axis: Vector3, angle: float32): Quaternion {.importc: "QuaternionFromAxisAngle", rmapi.}
  ## Get rotation quaternion for an angle and axis. NOTE: angle must be provided in radians
proc toAxisAngle*(q: Quaternion, outAxis: ptr Vector3, outAngle: ptr float32) {.importc: "QuaternionToAxisAngle", rmapi.}
  ## Get the rotation angle and axis for a given quaternion
proc fromEuler*(pitch: float32, yaw: float32, roll: float32): Quaternion {.importc: "QuaternionFromEuler", rmapi.}
  ## Get the quaternion equivalent to Euler angles. NOTE: Rotation order is ZYX
proc toEuler*(q: Quaternion): Vector3 {.importc: "QuaternionToEuler", rmapi.}
  ## Get the Euler angles equivalent to quaternion (roll, pitch, yaw). NOTE: Angles are returned in a Vector3 struct in radians
proc transform*(q: Quaternion, mat: Matrix): Quaternion {.importc: "QuaternionTransform", rmapi.}
  ## Transform a quaternion given a transformation matrix

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
