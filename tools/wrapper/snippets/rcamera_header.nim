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

