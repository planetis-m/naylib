from raylib import CameraMode, CameraProjection, Vector2, Vector3, Matrix, Camera3D, Camera
from std/math import degToRad
import raymath

# -----------------------------------------------------------------------------------------
# Defines and Macros
# -----------------------------------------------------------------------------------------

const
  CameraMoveSpeed* = 5.4'f32 # Units per second
  CameraRotationSpeed* = 0.03'f32
  CameraPanSpeed* = 0.2'f32

  # Camera mouse movement sensitivity
  CameraMouseMoveSensitivity* = 0.003'f32

  # Camera orbital speed in CAMERA_ORBITAL mode
  CameraOrbitalSpeed* = 0.5'f32 # Radians per second

  CameraCullDistanceNear* = 0.01
  CameraCullDistanceFar* = 1000.0

# -----------------------------------------------------------------------------------------
# Module Functions Definition
# -----------------------------------------------------------------------------------------

func getCameraForward*(camera: Camera): Vector3 =
  ## Returns the camera's forward vector (normalized)
  normalize(camera.target - camera.position)

func getCameraUp*(camera: Camera): Vector3 =
  ## Returns the camera's up vector (normalized)
  ## Note: The up vector might not be perpendicular to the forward vector
  normalize(camera.up)

func getCameraRight*(camera: Camera): Vector3 =
  ## Returns the camera's right vector (normalized)
  let forward = getCameraForward(camera)
  let up = getCameraUp(camera)
  normalize(crossProduct(forward, up))

func moveForward*(camera: var Camera, distance: float32, moveInWorldPlane: bool) =
  ## Moves the camera in its forward direction
  var forward = getCameraForward(camera)

  if moveInWorldPlane:
    # Project vector onto world plane
    forward.y = 0
    forward = normalize(forward)

  # Scale by distance
  forward *= distance

  # Move position and target
  camera.position += forward
  camera.target += forward

func moveUp*(camera: var Camera, distance: float32) =
  ## Moves the camera in its up direction
  var up = getCameraUp(camera)

  # Scale by distance
  up *= distance

  # Move position and target
  camera.position += up
  camera.target += up

func moveRight*(camera: var Camera, distance: float32, moveInWorldPlane: bool) =
  ## Moves the camera target in its current right direction
  var right = getCameraRight(camera)

  if moveInWorldPlane:
    # Project vector onto world plane
    right.y = 0
    right = normalize(right)

  # Scale by distance
  right *= distance

  # Move position and target
  camera.position += right
  camera.target += right

func moveToTarget*(camera: var Camera, delta: float32) =
  ## Moves the camera position closer/farther to/from the camera target
  var distance = distance(camera.position, camera.target)

  # Apply delta
  distance += delta

  # Distance must be greater than 0
  if distance <= 0: distance = 0.001'f32

  # Set new distance by moving the position along the forward vector
  let forward = getCameraForward(camera)
  camera.position = camera.target + (forward * -distance)

func yaw*(camera: var Camera, angle: float32, rotateAroundTarget: bool) =
  ## Rotates the camera around its up vector
  ## Yaw is "looking left and right"
  ## If rotateAroundTarget is false, the camera rotates around its position
  ## Note: angle must be provided in radians
  # Rotation axis
  let up = getCameraUp(camera)

  # View vector
  var targetPosition = camera.target - camera.position

  # Rotate view vector around up axis
  targetPosition = rotateByAxisAngle(targetPosition, up, angle)

  if rotateAroundTarget:
    # Move position relative to target
    camera.position = camera.target - targetPosition
  else:
    # Move target relative to position
    camera.target = camera.position + targetPosition

func pitch*(camera: var Camera, angle: float32, lockView, rotateAroundTarget, rotateUp: bool) =
  ## Rotates the camera around its right vector, pitch is "looking up and down"
  ##  - lockView prevents camera overrotation (aka "somersaults")
  ##  - rotateAroundTarget defines if rotation is around target or around its position
  ##  - rotateUp rotates the up direction as well (typically only useful in CAMERA_FREE)
  ## NOTE: angle must be provided in radians
  # Up direction
  var angle = angle
  let up = getCameraUp(camera)

  # View vector
  var targetPosition = camera.target - camera.position

  if lockView:
    # In these camera modes we clamp the Pitch angle
    # to allow only viewing straight up or down.

    # Clamp view up
    var maxAngleUp = angle(up, targetPosition)
    maxAngleUp -= 0.001'f32 # avoid numerical errors
    if angle > maxAngleUp: angle = maxAngleUp

    # Clamp view down
    var maxAngleDown = angle(-up, targetPosition)
    maxAngleDown *= -1.0'f32 # downwards angle is negative
    maxAngleDown += 0.001'f32 # avoid numerical errors
    if angle < maxAngleDown: angle = maxAngleDown

  # Rotation axis
  let right = getCameraRight(camera)

  # Rotate view vector around right axis
  targetPosition = rotateByAxisAngle(targetPosition, right, angle)

  if rotateAroundTarget:
    # Move position relative to target
    camera.position = camera.target - targetPosition
  else:
    # Move target relative to position
    camera.target = camera.position + targetPosition

  if rotateUp:
    # Rotate up direction around right axis
    camera.up = rotateByAxisAngle(camera.up, right, angle)

func roll*(camera: var Camera, angle: float32) =
  ## Rotates the camera around its forward vector
  ## Roll is "turning your head sideways to the left or right"
  ## Note: angle must be provided in radians
  # Rotation axis
  let forward = getCameraForward(camera)

  # Rotate up direction around forward axis
  camera.up = rotateByAxisAngle(camera.up, forward, angle)

func getCameraViewMatrix*(camera: Camera): Matrix =
  ## Returns the camera view matrix
  lookAt(camera.position, camera.target, camera.up)

func getCameraProjectionMatrix*(camera: Camera, aspect: float32): Matrix =
  # Returns the camera projection matrix
  case camera.projection
  of Perspective:
    perspective(degToRad(camera.fovy), aspect, CameraCullDistanceNear, CameraCullDistanceFar)
  of Orthographic:
    let top = camera.fovy / 2.0
    let right = top * aspect
    ortho(-right, right, -top, top, CameraCullDistanceNear, CameraCullDistanceFar)
  else:
    identity(Matrix)
