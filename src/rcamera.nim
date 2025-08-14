from raylib import Vector2, Vector3, Matrix, Camera3D, Camera, CameraProjection, CameraMode
export Vector2, Vector3, Matrix, Camera3D, Camera, CameraProjection, CameraMode

const
  CameraMoveSpeed* = 5.4'f32 # Units per second
  CameraRotationSpeed* = 0.03'f32
  CameraPanSpeed* = 0.2'f32

  # Camera mouse movement sensitivity
  CameraMouseMoveSensitivity* = 0.003'f32

  # Camera orbital speed in CAMERA_ORBITAL mode
  CameraOrbitalSpeed* = 0.5'f32 # Radians per second

  CameraCullDistanceNear* = 0.05
  CameraCullDistanceFar* = 4000.0


{.push callconv: cdecl, header: "rcamera.h".}
func getCameraForward*(camera {.byref.}: Camera): Vector3 {.importc: "GetCameraForward".}
func getCameraUp*(camera {.byref.}: Camera): Vector3 {.importc: "GetCameraUp".}
func getCameraRight*(camera {.byref.}: Camera): Vector3 {.importc: "GetCameraRight".}
func moveForward*(camera: var Camera, distance: float32, moveInWorldPlane: bool) {.importc: "CameraMoveForward".}
func moveUp*(camera: var Camera, distance: float32) {.importc: "CameraMoveUp".}
func moveRight*(camera: var Camera, distance: float32, moveInWorldPlane: bool) {.importc: "CameraMoveRight".}
func moveToTarget*(camera: var Camera, delta: float32) {.importc: "CameraMoveToTarget".}
func yaw*(camera: var Camera, angle: float32, rotateAroundTarget: bool) {.importc: "CameraYaw".}
func pitch*(camera: var Camera, angle: float32, lockView: bool, rotateAroundTarget: bool, rotateUp: bool) {.importc: "CameraPitch".}
func roll*(camera: var Camera, angle: float32) {.importc: "CameraRoll".}
func getCameraViewMatrix*(camera {.byref.}: Camera): Matrix {.importc: "GetCameraViewMatrix".}
func getCameraProjectionMatrix*(camera {.byref.}: Camera, aspect: float32): Matrix {.importc: "GetCameraProjectionMatrix".}
{.pop.}

