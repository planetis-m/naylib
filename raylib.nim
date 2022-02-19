from unicode import Rune
import os
const cinclude = currentSourcePath().parentDir / "cinclude"
{.passC: "-I" & cinclude.}
{.passL: cinclude / "libraylib.a" & " -lGL -lm -lpthread -ldl -lrt -lX11 -DPLATFORM_DESKTOP".}

const
  RaylibVersion* = "4.1-dev"

type
  ConfigFlags* = distinct int32 ## System/Window config flags
  TraceLogLevel* = distinct int32 ## Trace log level
  KeyboardKey* = distinct int32 ## Keyboard keys (US keyboard layout)
  MouseButton* = distinct int32 ## Mouse buttons
  MouseCursor* = distinct int32 ## Mouse cursor
  GamepadButton* = distinct int32 ## Gamepad buttons
  GamepadAxis* = distinct int32 ## Gamepad axis
  MaterialMapIndex* = distinct int32 ## Material map index
  ShaderLocationIndex* = distinct int32 ## Shader location index
  ShaderUniformDataType* = distinct int32 ## Shader uniform data type
  ShaderAttributeDataType* = distinct int32 ## Shader attribute data types
  PixelFormat* = distinct int32 ## Pixel formats
  TextureFilter* = distinct int32 ## Texture parameters: filter mode
  TextureWrap* = distinct int32 ## Texture parameters: wrap mode
  CubemapLayout* = distinct int32 ## Cubemap layouts
  FontType* = distinct int32 ## Font type, defines generation method
  BlendMode* = distinct int32 ## Color blending modes (pre-defined)
  Gesture* = distinct int32 ## Gesture
  CameraMode* = distinct int32 ## Camera system modes
  CameraProjection* = distinct int32 ## Camera projection
  NPatchLayout* = distinct int32 ## N-patch layout

const
  FlagVsyncHint* = ConfigFlags(64) ## Set to try enabling V-Sync on GPU
  FlagFullscreenMode* = ConfigFlags(2) ## Set to run program in fullscreen
  FlagWindowResizable* = ConfigFlags(4) ## Set to allow resizable window
  FlagWindowUndecorated* = ConfigFlags(8) ## Set to disable window decoration (frame and buttons)
  FlagWindowHidden* = ConfigFlags(128) ## Set to hide window
  FlagWindowMinimized* = ConfigFlags(512) ## Set to minimize window (iconify)
  FlagWindowMaximized* = ConfigFlags(1024) ## Set to maximize window (expanded to monitor)
  FlagWindowUnfocused* = ConfigFlags(2048) ## Set to window non focused
  FlagWindowTopmost* = ConfigFlags(4096) ## Set to window always on top
  FlagWindowAlwaysRun* = ConfigFlags(256) ## Set to allow windows running while minimized
  FlagWindowTransparent* = ConfigFlags(16) ## Set to allow transparent framebuffer
  FlagWindowHighdpi* = ConfigFlags(8192) ## Set to support HighDPI
  FlagMsaa4xHint* = ConfigFlags(32) ## Set to try enabling MSAA 4X
  FlagInterlacedHint* = ConfigFlags(65536) ## Set to try enabling interlaced video format (for V3D)

  LogAll* = TraceLogLevel(0) ## Display all logs
  LogTrace* = TraceLogLevel(1) ## Trace logging, intended for internal use only
  LogDebug* = TraceLogLevel(2) ## Debug logging, used for internal debugging, it should be disabled on release builds
  LogInfo* = TraceLogLevel(3) ## Info logging, used for program execution info
  LogWarning* = TraceLogLevel(4) ## Warning logging, used on recoverable failures
  LogError* = TraceLogLevel(5) ## Error logging, used on unrecoverable failures
  LogFatal* = TraceLogLevel(6) ## Fatal logging, used to abort program: exit(EXIT_FAILURE)
  LogNone* = TraceLogLevel(7) ## Disable logging

  KeyNull* = KeyboardKey(0) ## Key: NULL, used for no key pressed
  KeyApostrophe* = KeyboardKey(39) ## Key: '
  KeyComma* = KeyboardKey(44) ## Key: ,
  KeyMinus* = KeyboardKey(45) ## Key: -
  KeyPeriod* = KeyboardKey(46) ## Key: .
  KeySlash* = KeyboardKey(47) ## Key: /
  KeyZero* = KeyboardKey(48) ## Key: 0
  KeyOne* = KeyboardKey(49) ## Key: 1
  KeyTwo* = KeyboardKey(50) ## Key: 2
  KeyThree* = KeyboardKey(51) ## Key: 3
  KeyFour* = KeyboardKey(52) ## Key: 4
  KeyFive* = KeyboardKey(53) ## Key: 5
  KeySix* = KeyboardKey(54) ## Key: 6
  KeySeven* = KeyboardKey(55) ## Key: 7
  KeyEight* = KeyboardKey(56) ## Key: 8
  KeyNine* = KeyboardKey(57) ## Key: 9
  KeySemicolon* = KeyboardKey(59) ## Key: ;
  KeyEqual* = KeyboardKey(61) ## Key: =
  KeyA* = KeyboardKey(65) ## Key: A | a
  KeyB* = KeyboardKey(66) ## Key: B | b
  KeyC* = KeyboardKey(67) ## Key: C | c
  KeyD* = KeyboardKey(68) ## Key: D | d
  KeyE* = KeyboardKey(69) ## Key: E | e
  KeyF* = KeyboardKey(70) ## Key: F | f
  KeyG* = KeyboardKey(71) ## Key: G | g
  KeyH* = KeyboardKey(72) ## Key: H | h
  KeyI* = KeyboardKey(73) ## Key: I | i
  KeyJ* = KeyboardKey(74) ## Key: J | j
  KeyK* = KeyboardKey(75) ## Key: K | k
  KeyL* = KeyboardKey(76) ## Key: L | l
  KeyM* = KeyboardKey(77) ## Key: M | m
  KeyN* = KeyboardKey(78) ## Key: N | n
  KeyO* = KeyboardKey(79) ## Key: O | o
  KeyP* = KeyboardKey(80) ## Key: P | p
  KeyQ* = KeyboardKey(81) ## Key: Q | q
  KeyR* = KeyboardKey(82) ## Key: R | r
  KeyS* = KeyboardKey(83) ## Key: S | s
  KeyT* = KeyboardKey(84) ## Key: T | t
  KeyU* = KeyboardKey(85) ## Key: U | u
  KeyV* = KeyboardKey(86) ## Key: V | v
  KeyW* = KeyboardKey(87) ## Key: W | w
  KeyX* = KeyboardKey(88) ## Key: X | x
  KeyY* = KeyboardKey(89) ## Key: Y | y
  KeyZ* = KeyboardKey(90) ## Key: Z | z
  KeyLeftBracket* = KeyboardKey(91) ## Key: [
  KeyBackslash* = KeyboardKey(92) ## Key: '\'
  KeyRightBracket* = KeyboardKey(93) ## Key: ]
  KeyGrave* = KeyboardKey(96) ## Key: `
  KeySpace* = KeyboardKey(32) ## Key: Space
  KeyEscape* = KeyboardKey(256) ## Key: Esc
  KeyEnter* = KeyboardKey(257) ## Key: Enter
  KeyTab* = KeyboardKey(258) ## Key: Tab
  KeyBackspace* = KeyboardKey(259) ## Key: Backspace
  KeyInsert* = KeyboardKey(260) ## Key: Ins
  KeyDelete* = KeyboardKey(261) ## Key: Del
  KeyRight* = KeyboardKey(262) ## Key: Cursor right
  KeyLeft* = KeyboardKey(263) ## Key: Cursor left
  KeyDown* = KeyboardKey(264) ## Key: Cursor down
  KeyUp* = KeyboardKey(265) ## Key: Cursor up
  KeyPageUp* = KeyboardKey(266) ## Key: Page up
  KeyPageDown* = KeyboardKey(267) ## Key: Page down
  KeyHome* = KeyboardKey(268) ## Key: Home
  KeyEnd* = KeyboardKey(269) ## Key: End
  KeyCapsLock* = KeyboardKey(280) ## Key: Caps lock
  KeyScrollLock* = KeyboardKey(281) ## Key: Scroll down
  KeyNumLock* = KeyboardKey(282) ## Key: Num lock
  KeyPrintScreen* = KeyboardKey(283) ## Key: Print screen
  KeyPause* = KeyboardKey(284) ## Key: Pause
  KeyF1* = KeyboardKey(290) ## Key: F1
  KeyF2* = KeyboardKey(291) ## Key: F2
  KeyF3* = KeyboardKey(292) ## Key: F3
  KeyF4* = KeyboardKey(293) ## Key: F4
  KeyF5* = KeyboardKey(294) ## Key: F5
  KeyF6* = KeyboardKey(295) ## Key: F6
  KeyF7* = KeyboardKey(296) ## Key: F7
  KeyF8* = KeyboardKey(297) ## Key: F8
  KeyF9* = KeyboardKey(298) ## Key: F9
  KeyF10* = KeyboardKey(299) ## Key: F10
  KeyF11* = KeyboardKey(300) ## Key: F11
  KeyF12* = KeyboardKey(301) ## Key: F12
  KeyLeftShift* = KeyboardKey(340) ## Key: Shift left
  KeyLeftControl* = KeyboardKey(341) ## Key: Control left
  KeyLeftAlt* = KeyboardKey(342) ## Key: Alt left
  KeyLeftSuper* = KeyboardKey(343) ## Key: Super left
  KeyRightShift* = KeyboardKey(344) ## Key: Shift right
  KeyRightControl* = KeyboardKey(345) ## Key: Control right
  KeyRightAlt* = KeyboardKey(346) ## Key: Alt right
  KeyRightSuper* = KeyboardKey(347) ## Key: Super right
  KeyKbMenu* = KeyboardKey(348) ## Key: KB menu
  KeyKp0* = KeyboardKey(320) ## Key: Keypad 0
  KeyKp1* = KeyboardKey(321) ## Key: Keypad 1
  KeyKp2* = KeyboardKey(322) ## Key: Keypad 2
  KeyKp3* = KeyboardKey(323) ## Key: Keypad 3
  KeyKp4* = KeyboardKey(324) ## Key: Keypad 4
  KeyKp5* = KeyboardKey(325) ## Key: Keypad 5
  KeyKp6* = KeyboardKey(326) ## Key: Keypad 6
  KeyKp7* = KeyboardKey(327) ## Key: Keypad 7
  KeyKp8* = KeyboardKey(328) ## Key: Keypad 8
  KeyKp9* = KeyboardKey(329) ## Key: Keypad 9
  KeyKpDecimal* = KeyboardKey(330) ## Key: Keypad .
  KeyKpDivide* = KeyboardKey(331) ## Key: Keypad /
  KeyKpMultiply* = KeyboardKey(332) ## Key: Keypad *
  KeyKpSubtract* = KeyboardKey(333) ## Key: Keypad -
  KeyKpAdd* = KeyboardKey(334) ## Key: Keypad +
  KeyKpEnter* = KeyboardKey(335) ## Key: Keypad Enter
  KeyKpEqual* = KeyboardKey(336) ## Key: Keypad =
  KeyBack* = KeyboardKey(4) ## Key: Android back button
  KeyMenu* = KeyboardKey(82) ## Key: Android menu button
  KeyVolumeUp* = KeyboardKey(24) ## Key: Android volume up button
  KeyVolumeDown* = KeyboardKey(25) ## Key: Android volume down button

  MouseButtonLeft* = MouseButton(0) ## Mouse button left
  MouseButtonRight* = MouseButton(1) ## Mouse button right
  MouseButtonMiddle* = MouseButton(2) ## Mouse button middle (pressed wheel)
  MouseButtonSide* = MouseButton(3) ## Mouse button side (advanced mouse device)
  MouseButtonExtra* = MouseButton(4) ## Mouse button extra (advanced mouse device)
  MouseButtonForward* = MouseButton(5) ## Mouse button fordward (advanced mouse device)
  MouseButtonBack* = MouseButton(6) ## Mouse button back (advanced mouse device)

  MouseCursorDefault* = MouseCursor(0) ## Default pointer shape
  MouseCursorArrow* = MouseCursor(1) ## Arrow shape
  MouseCursorIbeam* = MouseCursor(2) ## Text writing cursor shape
  MouseCursorCrosshair* = MouseCursor(3) ## Cross shape
  MouseCursorPointingHand* = MouseCursor(4) ## Pointing hand cursor
  MouseCursorResizeEw* = MouseCursor(5) ## Horizontal resize/move arrow shape
  MouseCursorResizeNs* = MouseCursor(6) ## Vertical resize/move arrow shape
  MouseCursorResizeNwse* = MouseCursor(7) ## Top-left to bottom-right diagonal resize/move arrow shape
  MouseCursorResizeNesw* = MouseCursor(8) ## The top-right to bottom-left diagonal resize/move arrow shape
  MouseCursorResizeAll* = MouseCursor(9) ## The omni-directional resize/move cursor shape
  MouseCursorNotAllowed* = MouseCursor(10) ## The operation-not-allowed shape

  GamepadButtonUnknown* = GamepadButton(0) ## Unknown button, just for error checking
  GamepadButtonLeftFaceUp* = GamepadButton(1) ## Gamepad left DPAD up button
  GamepadButtonLeftFaceRight* = GamepadButton(2) ## Gamepad left DPAD right button
  GamepadButtonLeftFaceDown* = GamepadButton(3) ## Gamepad left DPAD down button
  GamepadButtonLeftFaceLeft* = GamepadButton(4) ## Gamepad left DPAD left button
  GamepadButtonRightFaceUp* = GamepadButton(5) ## Gamepad right button up (i.e. PS3: Triangle, Xbox: Y)
  GamepadButtonRightFaceRight* = GamepadButton(6) ## Gamepad right button right (i.e. PS3: Square, Xbox: X)
  GamepadButtonRightFaceDown* = GamepadButton(7) ## Gamepad right button down (i.e. PS3: Cross, Xbox: A)
  GamepadButtonRightFaceLeft* = GamepadButton(8) ## Gamepad right button left (i.e. PS3: Circle, Xbox: B)
  GamepadButtonLeftTrigger1* = GamepadButton(9) ## Gamepad top/back trigger left (first), it could be a trailing button
  GamepadButtonLeftTrigger2* = GamepadButton(10) ## Gamepad top/back trigger left (second), it could be a trailing button
  GamepadButtonRightTrigger1* = GamepadButton(11) ## Gamepad top/back trigger right (one), it could be a trailing button
  GamepadButtonRightTrigger2* = GamepadButton(12) ## Gamepad top/back trigger right (second), it could be a trailing button
  GamepadButtonMiddleLeft* = GamepadButton(13) ## Gamepad center buttons, left one (i.e. PS3: Select)
  GamepadButtonMiddle* = GamepadButton(14) ## Gamepad center buttons, middle one (i.e. PS3: PS, Xbox: XBOX)
  GamepadButtonMiddleRight* = GamepadButton(15) ## Gamepad center buttons, right one (i.e. PS3: Start)
  GamepadButtonLeftThumb* = GamepadButton(16) ## Gamepad joystick pressed button left
  GamepadButtonRightThumb* = GamepadButton(17) ## Gamepad joystick pressed button right

  GamepadAxisLeftX* = GamepadAxis(0) ## Gamepad left stick X axis
  GamepadAxisLeftY* = GamepadAxis(1) ## Gamepad left stick Y axis
  GamepadAxisRightX* = GamepadAxis(2) ## Gamepad right stick X axis
  GamepadAxisRightY* = GamepadAxis(3) ## Gamepad right stick Y axis
  GamepadAxisLeftTrigger* = GamepadAxis(4) ## Gamepad back trigger left, pressure level: [1..-1]
  GamepadAxisRightTrigger* = GamepadAxis(5) ## Gamepad back trigger right, pressure level: [1..-1]

  MaterialMapAlbedo* = MaterialMapIndex(0) ## Albedo material (same as: MATERIAL_MAP_DIFFUSE)
  MaterialMapMetalness* = MaterialMapIndex(1) ## Metalness material (same as: MATERIAL_MAP_SPECULAR)
  MaterialMapNormal* = MaterialMapIndex(2) ## Normal material
  MaterialMapRoughness* = MaterialMapIndex(3) ## Roughness material
  MaterialMapOcclusion* = MaterialMapIndex(4) ## Ambient occlusion material
  MaterialMapEmission* = MaterialMapIndex(5) ## Emission material
  MaterialMapHeight* = MaterialMapIndex(6) ## Heightmap material
  MaterialMapCubemap* = MaterialMapIndex(7) ## Cubemap material (NOTE: Uses GL_TEXTURE_CUBE_MAP)
  MaterialMapIrradiance* = MaterialMapIndex(8) ## Irradiance material (NOTE: Uses GL_TEXTURE_CUBE_MAP)
  MaterialMapPrefilter* = MaterialMapIndex(9) ## Prefilter material (NOTE: Uses GL_TEXTURE_CUBE_MAP)
  MaterialMapBrdf* = MaterialMapIndex(10) ## Brdf material

  ShaderLocVertexPosition* = ShaderLocationIndex(0) ## Shader location: vertex attribute: position
  ShaderLocVertexTexcoord01* = ShaderLocationIndex(1) ## Shader location: vertex attribute: texcoord01
  ShaderLocVertexTexcoord02* = ShaderLocationIndex(2) ## Shader location: vertex attribute: texcoord02
  ShaderLocVertexNormal* = ShaderLocationIndex(3) ## Shader location: vertex attribute: normal
  ShaderLocVertexTangent* = ShaderLocationIndex(4) ## Shader location: vertex attribute: tangent
  ShaderLocVertexColor* = ShaderLocationIndex(5) ## Shader location: vertex attribute: color
  ShaderLocMatrixMvp* = ShaderLocationIndex(6) ## Shader location: matrix uniform: model-view-projection
  ShaderLocMatrixView* = ShaderLocationIndex(7) ## Shader location: matrix uniform: view (camera transform)
  ShaderLocMatrixProjection* = ShaderLocationIndex(8) ## Shader location: matrix uniform: projection
  ShaderLocMatrixModel* = ShaderLocationIndex(9) ## Shader location: matrix uniform: model (transform)
  ShaderLocMatrixNormal* = ShaderLocationIndex(10) ## Shader location: matrix uniform: normal
  ShaderLocVectorView* = ShaderLocationIndex(11) ## Shader location: vector uniform: view
  ShaderLocColorDiffuse* = ShaderLocationIndex(12) ## Shader location: vector uniform: diffuse color
  ShaderLocColorSpecular* = ShaderLocationIndex(13) ## Shader location: vector uniform: specular color
  ShaderLocColorAmbient* = ShaderLocationIndex(14) ## Shader location: vector uniform: ambient color
  ShaderLocMapAlbedo* = ShaderLocationIndex(15) ## Shader location: sampler2d texture: albedo (same as: SHADER_LOC_MAP_DIFFUSE)
  ShaderLocMapMetalness* = ShaderLocationIndex(16) ## Shader location: sampler2d texture: metalness (same as: SHADER_LOC_MAP_SPECULAR)
  ShaderLocMapNormal* = ShaderLocationIndex(17) ## Shader location: sampler2d texture: normal
  ShaderLocMapRoughness* = ShaderLocationIndex(18) ## Shader location: sampler2d texture: roughness
  ShaderLocMapOcclusion* = ShaderLocationIndex(19) ## Shader location: sampler2d texture: occlusion
  ShaderLocMapEmission* = ShaderLocationIndex(20) ## Shader location: sampler2d texture: emission
  ShaderLocMapHeight* = ShaderLocationIndex(21) ## Shader location: sampler2d texture: height
  ShaderLocMapCubemap* = ShaderLocationIndex(22) ## Shader location: samplerCube texture: cubemap
  ShaderLocMapIrradiance* = ShaderLocationIndex(23) ## Shader location: samplerCube texture: irradiance
  ShaderLocMapPrefilter* = ShaderLocationIndex(24) ## Shader location: samplerCube texture: prefilter
  ShaderLocMapBrdf* = ShaderLocationIndex(25) ## Shader location: sampler2d texture: brdf

  ShaderUniformFloat* = ShaderUniformDataType(0) ## Shader uniform type: float
  ShaderUniformVec2* = ShaderUniformDataType(1) ## Shader uniform type: vec2 (2 float)
  ShaderUniformVec3* = ShaderUniformDataType(2) ## Shader uniform type: vec3 (3 float)
  ShaderUniformVec4* = ShaderUniformDataType(3) ## Shader uniform type: vec4 (4 float)
  ShaderUniformInt* = ShaderUniformDataType(4) ## Shader uniform type: int
  ShaderUniformIvec2* = ShaderUniformDataType(5) ## Shader uniform type: ivec2 (2 int)
  ShaderUniformIvec3* = ShaderUniformDataType(6) ## Shader uniform type: ivec3 (3 int)
  ShaderUniformIvec4* = ShaderUniformDataType(7) ## Shader uniform type: ivec4 (4 int)
  ShaderUniformSampler2d* = ShaderUniformDataType(8) ## Shader uniform type: sampler2d

  ShaderAttribFloat* = ShaderAttributeDataType(0) ## Shader attribute type: float
  ShaderAttribVec2* = ShaderAttributeDataType(1) ## Shader attribute type: vec2 (2 float)
  ShaderAttribVec3* = ShaderAttributeDataType(2) ## Shader attribute type: vec3 (3 float)
  ShaderAttribVec4* = ShaderAttributeDataType(3) ## Shader attribute type: vec4 (4 float)

  PixelformatUncompressedGrayscale* = PixelFormat(1) ## 8 bit per pixel (no alpha)
  PixelformatUncompressedGrayAlpha* = PixelFormat(2) ## 8*2 bpp (2 channels)
  PixelformatUncompressedR5g6b5* = PixelFormat(3) ## 16 bpp
  PixelformatUncompressedR8g8b8* = PixelFormat(4) ## 24 bpp
  PixelformatUncompressedR5g5b5a1* = PixelFormat(5) ## 16 bpp (1 bit alpha)
  PixelformatUncompressedR4g4b4a4* = PixelFormat(6) ## 16 bpp (4 bit alpha)
  PixelformatUncompressedR8g8b8a8* = PixelFormat(7) ## 32 bpp
  PixelformatUncompressedR32* = PixelFormat(8) ## 32 bpp (1 channel - float)
  PixelformatUncompressedR32g32b32* = PixelFormat(9) ## 32*3 bpp (3 channels - float)
  PixelformatUncompressedR32g32b32a32* = PixelFormat(10) ## 32*4 bpp (4 channels - float)
  PixelformatCompressedDxt1Rgb* = PixelFormat(11) ## 4 bpp (no alpha)
  PixelformatCompressedDxt1Rgba* = PixelFormat(12) ## 4 bpp (1 bit alpha)
  PixelformatCompressedDxt3Rgba* = PixelFormat(13) ## 8 bpp
  PixelformatCompressedDxt5Rgba* = PixelFormat(14) ## 8 bpp
  PixelformatCompressedEtc1Rgb* = PixelFormat(15) ## 4 bpp
  PixelformatCompressedEtc2Rgb* = PixelFormat(16) ## 4 bpp
  PixelformatCompressedEtc2EacRgba* = PixelFormat(17) ## 8 bpp
  PixelformatCompressedPvrtRgb* = PixelFormat(18) ## 4 bpp
  PixelformatCompressedPvrtRgba* = PixelFormat(19) ## 4 bpp
  PixelformatCompressedAstc4x4Rgba* = PixelFormat(20) ## 8 bpp
  PixelformatCompressedAstc8x8Rgba* = PixelFormat(21) ## 2 bpp

  TextureFilterPoint* = TextureFilter(0) ## No filter, just pixel approximation
  TextureFilterBilinear* = TextureFilter(1) ## Linear filtering
  TextureFilterTrilinear* = TextureFilter(2) ## Trilinear filtering (linear with mipmaps)
  TextureFilterAnisotropic4x* = TextureFilter(3) ## Anisotropic filtering 4x
  TextureFilterAnisotropic8x* = TextureFilter(4) ## Anisotropic filtering 8x
  TextureFilterAnisotropic16x* = TextureFilter(5) ## Anisotropic filtering 16x

  TextureWrapRepeat* = TextureWrap(0) ## Repeats texture in tiled mode
  TextureWrapClamp* = TextureWrap(1) ## Clamps texture to edge pixel in tiled mode
  TextureWrapMirrorRepeat* = TextureWrap(2) ## Mirrors and repeats the texture in tiled mode
  TextureWrapMirrorClamp* = TextureWrap(3) ## Mirrors and clamps to border the texture in tiled mode

  CubemapLayoutAutoDetect* = CubemapLayout(0) ## Automatically detect layout type
  CubemapLayoutLineVertical* = CubemapLayout(1) ## Layout is defined by a vertical line with faces
  CubemapLayoutLineHorizontal* = CubemapLayout(2) ## Layout is defined by an horizontal line with faces
  CubemapLayoutCrossThreeByFour* = CubemapLayout(3) ## Layout is defined by a 3x4 cross with cubemap faces
  CubemapLayoutCrossFourByThree* = CubemapLayout(4) ## Layout is defined by a 4x3 cross with cubemap faces
  CubemapLayoutPanorama* = CubemapLayout(5) ## Layout is defined by a panorama image (equirectangular map)

  FontDefault* = FontType(0) ## Default font generation, anti-aliased
  FontBitmap* = FontType(1) ## Bitmap font generation, no anti-aliasing
  FontSdf* = FontType(2) ## SDF font generation, requires external shader

  BlendAlpha* = BlendMode(0) ## Blend textures considering alpha (default)
  BlendAdditive* = BlendMode(1) ## Blend textures adding colors
  BlendMultiplied* = BlendMode(2) ## Blend textures multiplying colors
  BlendAddColors* = BlendMode(3) ## Blend textures adding colors (alternative)
  BlendSubtractColors* = BlendMode(4) ## Blend textures subtracting colors (alternative)
  BlendAlphaPremul* = BlendMode(5) ## Blend premultiplied textures considering alpha
  BlendCustom* = BlendMode(6) ## Blend textures using custom src/dst factors (use rlSetBlendMode())

  GestureNone* = Gesture(0) ## No gesture
  GestureTap* = Gesture(1) ## Tap gesture
  GestureDoubletap* = Gesture(2) ## Double tap gesture
  GestureHold* = Gesture(4) ## Hold gesture
  GestureDrag* = Gesture(8) ## Drag gesture
  GestureSwipeRight* = Gesture(16) ## Swipe right gesture
  GestureSwipeLeft* = Gesture(32) ## Swipe left gesture
  GestureSwipeUp* = Gesture(64) ## Swipe up gesture
  GestureSwipeDown* = Gesture(128) ## Swipe down gesture
  GesturePinchIn* = Gesture(256) ## Pinch in gesture
  GesturePinchOut* = Gesture(512) ## Pinch out gesture

  CameraCustom* = CameraMode(0) ## Custom camera
  CameraFree* = CameraMode(1) ## Free camera
  CameraOrbital* = CameraMode(2) ## Orbital camera
  CameraFirstPerson* = CameraMode(3) ## First person camera
  CameraThirdPerson* = CameraMode(4) ## Third person camera

  CameraPerspective* = CameraProjection(0) ## Perspective projection
  CameraOrthographic* = CameraProjection(1) ## Orthographic projection

  NpatchNinePatch* = NPatchLayout(0) ## Npatch layout: 3x3 tiles
  NpatchThreePatchVertical* = NPatchLayout(1) ## Npatch layout: 1x3 tiles
  NpatchThreePatchHorizontal* = NPatchLayout(2) ## Npatch layout: 3x1 tiles

  MaterialMapDiffuse* = MaterialMapAlbedo
  MaterialMapSpecular* = MaterialMapMetalness

  ShaderLocMapDiffuse* = ShaderLocMapAlbedo
  ShaderLocMapSpecular* = ShaderLocMapMetalness
  # Taken from raylib/src/config.h
  MaxShaderLocations* = 32 ## Maximum number of shader locations supported
  MaxMaterialMaps* = 12 ## Maximum number of shader maps supported
  MaxMeshVertexBuffers* = 7 ## Maximum vertex buffers (VBO) per mesh

type
  Enums = ConfigFlags|Gesture
  Flag*[E: Enums] = distinct uint32

proc flag*[E: Enums](e: varargs[E]): Flag[E] {.inline.} =
  var res = 0'u32
  for val in items(e):
    res = res or uint32(val)
  Flag[E](res)

type
  Vector2* {.header: "raylib.h", bycopy.} = object ## Vector2, 2 components
    x*: float32 ## Vector x component
    y*: float32 ## Vector y component

  Vector3* {.header: "raylib.h", bycopy.} = object ## Vector3, 3 components
    x*: float32 ## Vector x component
    y*: float32 ## Vector y component
    z*: float32 ## Vector z component

  Vector4* {.header: "raylib.h", bycopy.} = object ## Vector4, 4 components
    x*: float32 ## Vector x component
    y*: float32 ## Vector y component
    z*: float32 ## Vector z component
    w*: float32 ## Vector w component
  Quaternion* = Vector4 ## Quaternion, 4 components (Vector4 alias)

  Matrix* {.header: "raylib.h", bycopy.} = object ## Matrix, 4x4 components, column major, OpenGL style, right handed
    m0*, m4*, m8*, m12*: float32 ## Matrix first row (4 components)
    m1*, m5*, m9*, m13*: float32 ## Matrix second row (4 components)
    m2*, m6*, m10*, m14*: float32 ## Matrix third row (4 components)
    m3*, m7*, m11*, m15*: float32 ## Matrix fourth row (4 components)

  Color* {.header: "raylib.h", bycopy.} = object ## Color, 4 components, R8G8B8A8 (32bit)
    r*: uint8 ## Color red value
    g*: uint8 ## Color green value
    b*: uint8 ## Color blue value
    a*: uint8 ## Color alpha value

  Rectangle* {.header: "raylib.h", bycopy.} = object ## Rectangle, 4 components
    x*: float32 ## Rectangle top-left corner position x
    y*: float32 ## Rectangle top-left corner position y
    width*: float32 ## Rectangle width
    height*: float32 ## Rectangle height

  Image* {.header: "raylib.h", bycopy.} = object ## Image, pixel data stored in CPU memory (RAM)
    data*: pointer ## Image raw data
    width*: int32 ## Image base width
    height*: int32 ## Image base height
    mipmaps*: int32 ## Mipmap levels, 1 by default
    format*: PixelFormat ## Data format (PixelFormat type)

  Texture* {.header: "raylib.h", bycopy.} = object ## Texture, tex data stored in GPU memory (VRAM)
    id*: uint32 ## OpenGL texture id
    width*: int32 ## Texture base width
    height*: int32 ## Texture base height
    mipmaps*: int32 ## Mipmap levels, 1 by default
    format*: PixelFormat ## Data format (PixelFormat type)
  Texture2D* = Texture ## Texture2D, same as Texture
  TextureCubemap* = Texture ## TextureCubemap, same as Texture

  RenderTexture* {.header: "raylib.h", bycopy.} = object ## RenderTexture, fbo for texture rendering
    id*: uint32 ## OpenGL framebuffer object id
    texture*: Texture ## Color buffer attachment texture
    depth*: Texture ## Depth buffer attachment texture
  RenderTexture2D* = RenderTexture ## RenderTexture2D, same as RenderTexture

  NPatchInfo* {.header: "raylib.h", bycopy.} = object ## NPatchInfo, n-patch layout info
    source*: Rectangle ## Texture source rectangle
    left*: int32 ## Left border offset
    top*: int32 ## Top border offset
    right*: int32 ## Right border offset
    bottom*: int32 ## Bottom border offset
    layout*: NPatchLayout ## Layout of the n-patch: 3x3, 1x3 or 3x1

  GlyphInfo* {.header: "raylib.h", bycopy.} = object ## GlyphInfo, font characters glyphs info
    value*: int32 ## Character value (Unicode)
    offsetX*: int32 ## Character offset X when drawing
    offsetY*: int32 ## Character offset Y when drawing
    advanceX*: int32 ## Character advance position X
    image*: Image ## Character image data

  Font* {.header: "raylib.h", bycopy.} = object ## Font, font texture and GlyphInfo array data
    baseSize*: int32 ## Base size (default chars height)
    glyphCount: int32 ## Number of glyph characters
    glyphPadding*: int32 ## Padding around the glyph characters
    texture*: Texture2D ## Texture atlas containing the glyphs
    recs: ptr UncheckedArray[Rectangle] ## Rectangles in texture for the glyphs
    glyphs: ptr UncheckedArray[GlyphInfo] ## Glyphs info data

  Camera3D* {.header: "raylib.h", bycopy.} = object ## Camera, defines position/orientation in 3d space
    position*: Vector3 ## Camera position
    target*: Vector3 ## Camera target it looks-at
    up*: Vector3 ## Camera up vector (rotation over its axis)
    fovy*: float32 ## Camera field-of-view apperture in Y (degrees) in perspective, used as near plane width in orthographic
    projection*: CameraProjection ## Camera projection: CAMERA_PERSPECTIVE or CAMERA_ORTHOGRAPHIC
  Camera* = Camera3D ## Camera type fallback, defaults to Camera3D

  Camera2D* {.header: "raylib.h", bycopy.} = object ## Camera2D, defines position/orientation in 2d space
    offset*: Vector2 ## Camera offset (displacement from target)
    target*: Vector2 ## Camera target (rotation and zoom origin)
    rotation*: float32 ## Camera rotation in degrees
    zoom*: float32 ## Camera zoom (scaling), should be 1.0f by default

  Mesh* {.header: "raylib.h", bycopy.} = object ## Mesh, vertex data and vao/vbo
    vertexCount: int32 ## Number of vertices stored in arrays
    triangleCount: int32 ## Number of triangles stored (indexed or not)
    vertices: ptr UncheckedArray[float32] ## Vertex position (XYZ - 3 components per vertex) (shader-location = 0)
    texcoords: ptr UncheckedArray[float32] ## Vertex texture coordinates (UV - 2 components per vertex) (shader-location = 1)
    texcoords2: ptr UncheckedArray[float32] ## Vertex second texture coordinates (useful for lightmaps) (shader-location = 5)
    normals: ptr UncheckedArray[float32] ## Vertex normals (XYZ - 3 components per vertex) (shader-location = 2)
    tangents: ptr UncheckedArray[float32] ## Vertex tangents (XYZW - 4 components per vertex) (shader-location = 4)
    colors: ptr UncheckedArray[uint8] ## Vertex colors (RGBA - 4 components per vertex) (shader-location = 3)
    indices: ptr UncheckedArray[uint16] ## Vertex indices (in case vertex data comes indexed)
    animVertices: ptr UncheckedArray[float32] ## Animated vertex positions (after bones transformations)
    animNormals: ptr UncheckedArray[float32] ## Animated normals (after bones transformations)
    boneIds: ptr UncheckedArray[uint8] ## Vertex bone ids, max 255 bone ids, up to 4 bones influence by vertex (skinning)
    boneWeights: ptr UncheckedArray[float32] ## Vertex bone weight, up to 4 bones influence by vertex (skinning)
    vaoId*: uint32 ## OpenGL Vertex Array Object id
    vboId: ptr array[MaxMeshVertexBuffers, uint32] ## OpenGL Vertex Buffer Objects id (default vertex data)

  Shader* {.header: "raylib.h", bycopy.} = object ## Shader
    id*: uint32 ## Shader program id
    locs: ptr array[MaxShaderLocations, int32] ## Shader locations array (RL_MAX_SHADER_LOCATIONS)

  MaterialMap* {.header: "raylib.h", bycopy.} = object ## MaterialMap
    texture*: Texture2D ## Material map texture
    color*: Color ## Material map color
    value*: float32 ## Material map value

  Material* {.header: "raylib.h", bycopy.} = object ## Material, includes shader and maps
    shader*: Shader ## Material shader
    maps: ptr array[MaxMaterialMaps, MaterialMap] ## Material maps array (MAX_MATERIAL_MAPS)
    params*: array[4, float32] ## Material generic parameters (if required)

  Transform* {.header: "raylib.h", bycopy.} = object ## Transform, vectex transformation data
    translation*: Vector3 ## Translation
    rotation*: Quaternion ## Rotation
    scale*: Vector3 ## Scale

  BoneInfo* {.header: "raylib.h", bycopy.} = object ## Bone, skeletal animation bone
    name*: array[32, char] ## Bone name
    parent*: int32 ## Bone parent

  Model* {.header: "raylib.h", bycopy.} = object ## Model, meshes, materials and animation data
    transform*: Matrix ## Local transform matrix
    meshCount: int32 ## Number of meshes
    materialCount: int32 ## Number of materials
    meshes: ptr UncheckedArray[Mesh] ## Meshes array
    materials: ptr UncheckedArray[Material] ## Materials array
    meshMaterial: ptr UncheckedArray[int32] ## Mesh material number
    boneCount: int32 ## Number of bones
    bones: ptr UncheckedArray[BoneInfo] ## Bones information (skeleton)
    bindPose: ptr UncheckedArray[Transform] ## Bones base transformation (pose)

  ModelAnimation* {.header: "raylib.h", bycopy.} = object ## ModelAnimation
    boneCount: int32 ## Number of bones
    frameCount: int32 ## Number of animation frames
    bones: ptr UncheckedArray[BoneInfo] ## Bones information (skeleton)
    framePoses: ptr UncheckedArray[ptr UncheckedArray[Transform]] ## Poses array by frame

  Ray* {.header: "raylib.h", bycopy.} = object ## Ray, ray for raycasting
    position*: Vector3 ## Ray position (origin)
    direction*: Vector3 ## Ray direction

  RayCollision* {.header: "raylib.h", bycopy.} = object ## RayCollision, ray hit information
    hit*: bool ## Did the ray hit something?
    distance*: float32 ## Distance to nearest hit
    point*: Vector3 ## Point of nearest hit
    normal*: Vector3 ## Surface normal of hit

  BoundingBox* {.header: "raylib.h", bycopy.} = object ## BoundingBox
    min*: Vector3 ## Minimum vertex box-corner
    max*: Vector3 ## Maximum vertex box-corner

  Wave* {.header: "raylib.h", bycopy.} = object ## Wave, audio wave data
    frameCount*: uint32 ## Total number of frames (considering channels)
    sampleRate*: uint32 ## Frequency (samples per second)
    sampleSize*: uint32 ## Bit depth (bits per sample): 8, 16, 32 (24 not supported)
    channels*: uint32 ## Number of channels (1-mono, 2-stereo, ...)
    data*: pointer ## Buffer data pointer

  AudioStream* {.header: "raylib.h", bycopy.} = object ## AudioStream, custom audio stream
    buffer*: ptr RAudioBuffer ## Pointer to internal data used by the audio system
    sampleRate*: uint32 ## Frequency (samples per second)
    sampleSize*: uint32 ## Bit depth (bits per sample): 8, 16, 32 (24 not supported)
    channels*: uint32 ## Number of channels (1-mono, 2-stereo, ...)
  RAudioBuffer* {.importc: "rAudioBuffer", header: "raylib.h", bycopy.} = object

  Sound* {.header: "raylib.h", bycopy.} = object ## Sound
    stream*: AudioStream ## Audio stream
    frameCount*: uint32 ## Total number of frames (considering channels)

  Music* {.header: "raylib.h", bycopy.} = object ## Music, audio stream, anything longer than ~10 seconds should be streamed
    stream*: AudioStream ## Audio stream
    frameCount*: uint32 ## Total number of frames (considering channels)
    looping*: bool ## Music looping enable
    ctxType*: int32 ## Type of music context (audio filetype)
    ctxData*: pointer ## Audio context data, depends on type

  VrDeviceInfo* {.header: "raylib.h", bycopy.} = object ## VrDeviceInfo, Head-Mounted-Display device parameters
    hResolution*: int32 ## Horizontal resolution in pixels
    vResolution*: int32 ## Vertical resolution in pixels
    hScreenSize*: float32 ## Horizontal size in meters
    vScreenSize*: float32 ## Vertical size in meters
    vScreenCenter*: float32 ## Screen center in meters
    eyeToScreenDistance*: float32 ## Distance between eye and display in meters
    lensSeparationDistance*: float32 ## Lens separation distance in meters
    interpupillaryDistance*: float32 ## IPD (distance between pupils) in meters
    lensDistortionValues*: array[4, float32] ## Lens distortion constant parameters
    chromaAbCorrection*: array[4, float32] ## Chromatic aberration correction parameters

  VrStereoConfig* {.header: "raylib.h", bycopy.} = object ## VrStereoConfig, VR stereo rendering configuration for simulator
    projection*: array[2, Matrix] ## VR projection matrices (per eye)
    viewOffset*: array[2, Matrix] ## VR view offset matrices (per eye)
    leftLensCenter*: array[2, float32] ## VR left lens center
    rightLensCenter*: array[2, float32] ## VR right lens center
    leftScreenCenter*: array[2, float32] ## VR left screen center
    rightScreenCenter*: array[2, float32] ## VR right screen center
    scale*: array[2, float32] ## VR distortion scale
    scaleIn*: array[2, float32] ## VR distortion scale in

  FontRecs* = distinct Font
  FontGlyphs* = distinct Font
  MeshVertices* = distinct Mesh
  MeshTexcoords* = distinct Mesh
  MeshTexcoords2* = distinct Mesh
  MeshNormals* = distinct Mesh
  MeshTangents* = distinct Mesh
  MeshColors* = distinct Mesh
  MeshIndices* = distinct Mesh
  MeshAnimVertices* = distinct Mesh
  MeshAnimNormals* = distinct Mesh
  MeshBoneIds* = distinct Mesh
  MeshBoneWeights* = distinct Mesh
  MeshVboId* = distinct Mesh
  ShaderLocs* = distinct Shader
  MaterialMaps* = distinct Material
  ModelMeshes* = distinct Model
  ModelMaterials* = distinct Model
  ModelMeshMaterial* = distinct Model
  ModelBones* = distinct Model
  ModelBindPose* = distinct Model
  ModelAnimationBones* = distinct ModelAnimation
  ModelAnimationFramePoses* = distinct ModelAnimation

type va_list* {.importc: "va_list", header: "<stdarg.h>".} = object ## Only used by TraceLogCallback
proc vsprintf*(s: cstring, format: cstring, args: va_list) {.cdecl, importc: "vsprintf", header: "<stdio.h>".}

## Callbacks to hook some internal functions
## WARNING: This callbacks are intended for advance users
type
  TraceLogCallback* = proc (logLevel: TraceLogLevel; text: cstring; args: va_list) {.
      cdecl.} ## Logging: Redirect trace log messages
  LoadFileDataCallback* = proc (fileName: cstring; bytesRead: ptr uint32): ptr UncheckedArray[uint8] {.
      cdecl.} ## FileIO: Load binary data
  SaveFileDataCallback* = proc (fileName: cstring; data: pointer; bytesToWrite: uint32): bool {.
      cdecl.} ## FileIO: Save binary data
  LoadFileTextCallback* = proc (fileName: cstring): cstring {.cdecl.} ## FileIO: Load text data
  SaveFileTextCallback* = proc (fileName: cstring; text: cstring): bool {.cdecl.} ## FileIO: Save text data

const
  LightGray* = Color(r: 200, g: 200, b: 200, a: 255)
  Gray* = Color(r: 130, g: 130, b: 130, a: 255)
  DarkGray* = Color(r: 80, g: 80, b: 80, a: 255)
  Yellow* = Color(r: 253, g: 249, b: 0, a: 255)
  Gold* = Color(r: 255, g: 203, b: 0, a: 255)
  Orange* = Color(r: 255, g: 161, b: 0, a: 255)
  Pink* = Color(r: 255, g: 109, b: 194, a: 255)
  Red* = Color(r: 230, g: 41, b: 55, a: 255)
  Maroon* = Color(r: 190, g: 33, b: 55, a: 255)
  Green* = Color(r: 0, g: 228, b: 48, a: 255)
  Lime* = Color(r: 0, g: 158, b: 47, a: 255)
  DarkGreen* = Color(r: 0, g: 117, b: 44, a: 255)
  SkyBlue* = Color(r: 102, g: 191, b: 255, a: 255)
  Blue* = Color(r: 0, g: 121, b: 241, a: 255)
  DarkBlue* = Color(r: 0, g: 82, b: 172, a: 255)
  Purple* = Color(r: 200, g: 122, b: 255, a: 255)
  Violet* = Color(r: 135, g: 60, b: 190, a: 255)
  DarkPurple* = Color(r: 112, g: 31, b: 126, a: 255)
  Beige* = Color(r: 211, g: 176, b: 131, a: 255)
  Brown* = Color(r: 127, g: 106, b: 79, a: 255)
  DarkBrown* = Color(r: 76, g: 63, b: 47, a: 255)
  White* = Color(r: 255, g: 255, b: 255, a: 255)
  Black* = Color(r: 0, g: 0, b: 0, a: 255)
  Blank* = Color(r: 0, g: 0, b: 0, a: 0)
  Magenta* = Color(r: 255, g: 0, b: 255, a: 255)
  RayWhite* = Color(r: 245, g: 245, b: 245, a: 255)

{.push callconv: cdecl, header: "raylib.h".}
proc initWindow*(width: int32, height: int32, title: cstring) {.importc: "InitWindow".}
  ## Initialize window and OpenGL context
proc windowShouldClose*(): bool {.importc: "WindowShouldClose".}
  ## Check if KEY_ESCAPE pressed or Close icon pressed
proc closeWindow*() {.importc: "CloseWindow".}
  ## Close window and unload OpenGL context
proc isWindowReady*(): bool {.importc: "IsWindowReady".}
  ## Check if window has been initialized successfully
proc isWindowFullscreen*(): bool {.importc: "IsWindowFullscreen".}
  ## Check if window is currently fullscreen
proc isWindowHidden*(): bool {.importc: "IsWindowHidden".}
  ## Check if window is currently hidden (only PLATFORM_DESKTOP)
proc isWindowMinimized*(): bool {.importc: "IsWindowMinimized".}
  ## Check if window is currently minimized (only PLATFORM_DESKTOP)
proc isWindowMaximized*(): bool {.importc: "IsWindowMaximized".}
  ## Check if window is currently maximized (only PLATFORM_DESKTOP)
proc isWindowFocused*(): bool {.importc: "IsWindowFocused".}
  ## Check if window is currently focused (only PLATFORM_DESKTOP)
proc isWindowResized*(): bool {.importc: "IsWindowResized".}
  ## Check if window has been resized last frame
proc isWindowState*(flag: ConfigFlags): bool {.importc: "IsWindowState".}
  ## Check if one specific window flag is enabled
proc setWindowState*(flags: Flag[ConfigFlags]) {.importc: "SetWindowState".}
  ## Set window configuration state using flags (only PLATFORM_DESKTOP)
proc clearWindowState*(flags: Flag[ConfigFlags]) {.importc: "ClearWindowState".}
  ## Clear window configuration state flags
proc toggleFullscreen*() {.importc: "ToggleFullscreen".}
  ## Toggle window state: fullscreen/windowed (only PLATFORM_DESKTOP)
proc maximizeWindow*() {.importc: "MaximizeWindow".}
  ## Set window state: maximized, if resizable (only PLATFORM_DESKTOP)
proc minimizeWindow*() {.importc: "MinimizeWindow".}
  ## Set window state: minimized, if resizable (only PLATFORM_DESKTOP)
proc restoreWindow*() {.importc: "RestoreWindow".}
  ## Set window state: not minimized/maximized (only PLATFORM_DESKTOP)
proc setWindowIcon*(image: Image) {.importc: "SetWindowIcon".}
  ## Set icon for window (only PLATFORM_DESKTOP)
proc setWindowTitle*(title: cstring) {.importc: "SetWindowTitle".}
  ## Set title for window (only PLATFORM_DESKTOP)
proc setWindowPosition*(x: int32, y: int32) {.importc: "SetWindowPosition".}
  ## Set window position on screen (only PLATFORM_DESKTOP)
proc setWindowMonitor*(monitor: int32) {.importc: "SetWindowMonitor".}
  ## Set monitor for the current window (fullscreen mode)
proc setWindowMinSize*(width: int32, height: int32) {.importc: "SetWindowMinSize".}
  ## Set window minimum dimensions (for FLAG_WINDOW_RESIZABLE)
proc setWindowSize*(width: int32, height: int32) {.importc: "SetWindowSize".}
  ## Set window dimensions
proc setWindowOpacity*(opacity: float32) {.importc: "SetWindowOpacity".}
  ## Set window opacity [0.0f..1.0f] (only PLATFORM_DESKTOP)
proc getWindowHandle*(): pointer {.importc: "GetWindowHandle".}
  ## Get native window handle
proc getScreenWidth*(): int32 {.importc: "GetScreenWidth".}
  ## Get current screen width
proc getScreenHeight*(): int32 {.importc: "GetScreenHeight".}
  ## Get current screen height
proc getRenderWidth*(): int32 {.importc: "GetRenderWidth".}
  ## Get current render width (it considers HiDPI)
proc getRenderHeight*(): int32 {.importc: "GetRenderHeight".}
  ## Get current render height (it considers HiDPI)
proc getMonitorCount*(): int32 {.importc: "GetMonitorCount".}
  ## Get number of connected monitors
proc getCurrentMonitor*(): int32 {.importc: "GetCurrentMonitor".}
  ## Get current connected monitor
proc getMonitorPosition*(monitor: int32): Vector2 {.importc: "GetMonitorPosition".}
  ## Get specified monitor position
proc getMonitorWidth*(monitor: int32): int32 {.importc: "GetMonitorWidth".}
  ## Get specified monitor width (max available by monitor)
proc getMonitorHeight*(monitor: int32): int32 {.importc: "GetMonitorHeight".}
  ## Get specified monitor height (max available by monitor)
proc getMonitorPhysicalWidth*(monitor: int32): int32 {.importc: "GetMonitorPhysicalWidth".}
  ## Get specified monitor physical width in millimetres
proc getMonitorPhysicalHeight*(monitor: int32): int32 {.importc: "GetMonitorPhysicalHeight".}
  ## Get specified monitor physical height in millimetres
proc getMonitorRefreshRate*(monitor: int32): int32 {.importc: "GetMonitorRefreshRate".}
  ## Get specified monitor refresh rate
proc getWindowPosition*(): Vector2 {.importc: "GetWindowPosition".}
  ## Get window position XY on monitor
proc getWindowScaleDPI*(): Vector2 {.importc: "GetWindowScaleDPI".}
  ## Get window scale DPI factor
proc getMonitorNamePriv(monitor: int32): cstring {.importc: "GetMonitorName".}
proc setClipboardText*(text: cstring) {.importc: "SetClipboardText".}
  ## Set clipboard text content
proc getClipboardTextPriv(): cstring {.importc: "GetClipboardText".}
proc swapScreenBuffer*() {.importc: "SwapScreenBuffer".}
  ## Swap back buffer with front buffer (screen drawing)
proc pollInputEvents*() {.importc: "PollInputEvents".}
  ## Register all input events
proc waitTime*(ms: float32) {.importc: "WaitTime".}
  ## Wait for some milliseconds (halt program execution)
proc showCursor*() {.importc: "ShowCursor".}
  ## Shows cursor
proc hideCursor*() {.importc: "HideCursor".}
  ## Hides cursor
proc isCursorHidden*(): bool {.importc: "IsCursorHidden".}
  ## Check if cursor is not visible
proc enableCursor*() {.importc: "EnableCursor".}
  ## Enables cursor (unlock cursor)
proc disableCursor*() {.importc: "DisableCursor".}
  ## Disables cursor (lock cursor)
proc isCursorOnScreen*(): bool {.importc: "IsCursorOnScreen".}
  ## Check if cursor is on the screen
proc clearBackground*(color: Color) {.importc: "ClearBackground".}
  ## Set background color (framebuffer clear color)
proc beginDrawing*() {.importc: "BeginDrawing".}
  ## Setup canvas (framebuffer) to start drawing
proc endDrawing*() {.importc: "EndDrawing".}
  ## End canvas drawing and swap buffers (double buffering)
proc beginMode2D*(camera: Camera2D) {.importc: "BeginMode2D".}
  ## Begin 2D mode with custom camera (2D)
proc endMode2D*() {.importc: "EndMode2D".}
  ## Ends 2D mode with custom camera
proc beginMode3D*(camera: Camera3D) {.importc: "BeginMode3D".}
  ## Begin 3D mode with custom camera (3D)
proc endMode3D*() {.importc: "EndMode3D".}
  ## Ends 3D mode and returns to default 2D orthographic mode
proc beginTextureMode*(target: RenderTexture2D) {.importc: "BeginTextureMode".}
  ## Begin drawing to render texture
proc endTextureMode*() {.importc: "EndTextureMode".}
  ## Ends drawing to render texture
proc beginShaderMode*(shader: Shader) {.importc: "BeginShaderMode".}
  ## Begin custom shader drawing
proc endShaderMode*() {.importc: "EndShaderMode".}
  ## End custom shader drawing (use default shader)
proc beginBlendMode*(mode: BlendMode) {.importc: "BeginBlendMode".}
  ## Begin blending mode (alpha, additive, multiplied, subtract, custom)
proc endBlendMode*() {.importc: "EndBlendMode".}
  ## End blending mode (reset to default: alpha blending)
proc beginScissorMode*(x: int32, y: int32, width: int32, height: int32) {.importc: "BeginScissorMode".}
  ## Begin scissor mode (define screen area for following drawing)
proc endScissorMode*() {.importc: "EndScissorMode".}
  ## End scissor mode
proc beginVrStereoMode*(config: VrStereoConfig) {.importc: "BeginVrStereoMode".}
  ## Begin stereo rendering (requires VR simulator)
proc endVrStereoMode*() {.importc: "EndVrStereoMode".}
  ## End stereo rendering (requires VR simulator)
proc loadVrStereoConfig*(device: VrDeviceInfo): VrStereoConfig {.importc: "LoadVrStereoConfig".}
  ## Load VR stereo config for VR simulator device parameters
proc unloadVrStereoConfig*(config: VrStereoConfig) {.importc: "UnloadVrStereoConfig".}
  ## Unload VR stereo config
proc loadShader*(vsFileName: cstring, fsFileName: cstring): Shader {.importc: "LoadShader".}
  ## Load shader from files and bind default locations
proc loadShaderFromMemory*(vsCode: cstring, fsCode: cstring): Shader {.importc: "LoadShaderFromMemory".}
  ## Load shader from code strings and bind default locations
proc getShaderLocation*(shader: Shader, uniformName: cstring): int32 {.importc: "GetShaderLocation".}
  ## Get shader uniform location
proc getShaderLocationAttrib*(shader: Shader, attribName: cstring): int32 {.importc: "GetShaderLocationAttrib".}
  ## Get shader attribute location
proc setShaderValue*(shader: Shader, locIndex: int32, value: pointer, uniformType: ShaderUniformDataType) {.importc: "SetShaderValue".}
  ## Set shader uniform value
proc setShaderValueV*(shader: Shader, locIndex: int32, value: pointer, uniformType: ShaderUniformDataType, count: int32) {.importc: "SetShaderValueV".}
  ## Set shader uniform value vector
proc setShaderValueMatrix*(shader: Shader, locIndex: int32, mat: Matrix) {.importc: "SetShaderValueMatrix".}
  ## Set shader uniform value (matrix 4x4)
proc setShaderValueTexture*(shader: Shader, locIndex: int32, texture: Texture2D) {.importc: "SetShaderValueTexture".}
  ## Set shader uniform value for texture (sampler2d)
proc unloadShader*(shader: Shader) {.importc: "UnloadShader".}
  ## Unload shader from GPU memory (VRAM)
proc getMouseRay*(mousePosition: Vector2, camera: Camera): Ray {.importc: "GetMouseRay".}
  ## Get a ray trace from mouse position
proc getCameraMatrix*(camera: Camera): Matrix {.importc: "GetCameraMatrix".}
  ## Get camera transform matrix (view matrix)
proc getCameraMatrix2D*(camera: Camera2D): Matrix {.importc: "GetCameraMatrix2D".}
  ## Get camera 2d transform matrix
proc getWorldToScreen*(position: Vector3, camera: Camera): Vector2 {.importc: "GetWorldToScreen".}
  ## Get the screen space position for a 3d world space position
proc getWorldToScreenEx*(position: Vector3, camera: Camera, width: int32, height: int32): Vector2 {.importc: "GetWorldToScreenEx".}
  ## Get size position for a 3d world space position
proc getWorldToScreen2D*(position: Vector2, camera: Camera2D): Vector2 {.importc: "GetWorldToScreen2D".}
  ## Get the screen space position for a 2d camera world space position
proc getScreenToWorld2D*(position: Vector2, camera: Camera2D): Vector2 {.importc: "GetScreenToWorld2D".}
  ## Get the world space position for a 2d camera screen space position
proc setTargetFPS*(fps: int32) {.importc: "SetTargetFPS".}
  ## Set target FPS (maximum)
proc getFPS*(): int32 {.importc: "GetFPS".}
  ## Get current FPS
proc getFrameTime*(): float32 {.importc: "GetFrameTime".}
  ## Get time in seconds for last frame drawn (delta time)
proc getTime*(): float {.importc: "GetTime".}
  ## Get elapsed time in seconds since InitWindow()
proc takeScreenshot*(fileName: cstring) {.importc: "TakeScreenshot".}
  ## Takes a screenshot of current screen (filename extension defines format)
proc setConfigFlags*(flags: Flag[ConfigFlags]) {.importc: "SetConfigFlags".}
  ## Setup init configuration flags (view FLAGS)
proc traceLog*(logLevel: TraceLogLevel, text: cstring) {.importc: "TraceLog", varargs.}
  ## Show trace log messages (LOG_DEBUG, LOG_INFO, LOG_WARNING, LOG_ERROR...)
proc setTraceLogLevel*(logLevel: TraceLogLevel) {.importc: "SetTraceLogLevel".}
  ## Set the current threshold (minimum) log level
proc memAlloc(size: int32): pointer {.importc: "MemAlloc".}
proc memRealloc(`ptr`: pointer, size: int32): pointer {.importc: "MemRealloc".}
proc memFree(`ptr`: pointer) {.importc: "MemFree".}
proc setTraceLogCallback*(callback: TraceLogCallback) {.importc: "SetTraceLogCallback".}
  ## Set custom trace log
proc setLoadFileDataCallback*(callback: LoadFileDataCallback) {.importc: "SetLoadFileDataCallback".}
  ## Set custom file binary data loader
proc setSaveFileDataCallback*(callback: SaveFileDataCallback) {.importc: "SetSaveFileDataCallback".}
  ## Set custom file binary data saver
proc setLoadFileTextCallback*(callback: LoadFileTextCallback) {.importc: "SetLoadFileTextCallback".}
  ## Set custom file text data loader
proc setSaveFileTextCallback*(callback: SaveFileTextCallback) {.importc: "SetSaveFileTextCallback".}
  ## Set custom file text data saver
proc isFileDropped*(): bool {.importc: "IsFileDropped".}
  ## Check if a file has been dropped into window
proc getDroppedFilesPriv(count: ptr int32): cstringArray {.importc: "GetDroppedFiles".}
proc clearDroppedFiles*() {.importc: "ClearDroppedFiles".}
  ## Clear dropped files paths buffer (free memory)
proc saveStorageValue*(position: uint32, value: int32): bool {.importc: "SaveStorageValue".}
  ## Save integer value to storage file (to defined position), returns true on success
proc loadStorageValue*(position: uint32): int32 {.importc: "LoadStorageValue".}
  ## Load integer value from storage file (from defined position)
proc isKeyPressed*(key: KeyboardKey): bool {.importc: "IsKeyPressed".}
  ## Check if a key has been pressed once
proc isKeyDown*(key: KeyboardKey): bool {.importc: "IsKeyDown".}
  ## Check if a key is being pressed
proc isKeyReleased*(key: KeyboardKey): bool {.importc: "IsKeyReleased".}
  ## Check if a key has been released once
proc isKeyUp*(key: KeyboardKey): bool {.importc: "IsKeyUp".}
  ## Check if a key is NOT being pressed
proc setExitKey*(key: KeyboardKey) {.importc: "SetExitKey".}
  ## Set a custom key to exit program (default is ESC)
proc getKeyPressed*(): KeyboardKey {.importc: "GetKeyPressed".}
  ## Get key pressed (keycode), call it multiple times for keys queued, returns 0 when the queue is empty
proc getCharPressed*(): int32 {.importc: "GetCharPressed".}
  ## Get char pressed (unicode), call it multiple times for chars queued, returns 0 when the queue is empty
proc isGamepadAvailable*(gamepad: int32): bool {.importc: "IsGamepadAvailable".}
  ## Check if a gamepad is available
proc getGamepadNamePriv(gamepad: int32): cstring {.importc: "GetGamepadName".}
proc isGamepadButtonPressed*(gamepad: int32, button: GamepadButton): bool {.importc: "IsGamepadButtonPressed".}
  ## Check if a gamepad button has been pressed once
proc isGamepadButtonDown*(gamepad: int32, button: GamepadButton): bool {.importc: "IsGamepadButtonDown".}
  ## Check if a gamepad button is being pressed
proc isGamepadButtonReleased*(gamepad: int32, button: GamepadButton): bool {.importc: "IsGamepadButtonReleased".}
  ## Check if a gamepad button has been released once
proc isGamepadButtonUp*(gamepad: int32, button: GamepadButton): bool {.importc: "IsGamepadButtonUp".}
  ## Check if a gamepad button is NOT being pressed
proc getGamepadButtonPressed*(): GamepadButton {.importc: "GetGamepadButtonPressed".}
  ## Get the last gamepad button pressed
proc getGamepadAxisCount*(gamepad: int32): int32 {.importc: "GetGamepadAxisCount".}
  ## Get gamepad axis count for a gamepad
proc getGamepadAxisMovement*(gamepad: int32, axis: GamepadAxis): float32 {.importc: "GetGamepadAxisMovement".}
  ## Get axis movement value for a gamepad axis
proc setGamepadMappings*(mappings: cstring): int32 {.importc: "SetGamepadMappings".}
  ## Set internal gamepad mappings (SDL_GameControllerDB)
proc isMouseButtonPressed*(button: MouseButton): bool {.importc: "IsMouseButtonPressed".}
  ## Check if a mouse button has been pressed once
proc isMouseButtonDown*(button: MouseButton): bool {.importc: "IsMouseButtonDown".}
  ## Check if a mouse button is being pressed
proc isMouseButtonReleased*(button: MouseButton): bool {.importc: "IsMouseButtonReleased".}
  ## Check if a mouse button has been released once
proc isMouseButtonUp*(button: MouseButton): bool {.importc: "IsMouseButtonUp".}
  ## Check if a mouse button is NOT being pressed
proc getMouseX*(): int32 {.importc: "GetMouseX".}
  ## Get mouse position X
proc getMouseY*(): int32 {.importc: "GetMouseY".}
  ## Get mouse position Y
proc getMousePosition*(): Vector2 {.importc: "GetMousePosition".}
  ## Get mouse position XY
proc getMouseDelta*(): Vector2 {.importc: "GetMouseDelta".}
  ## Get mouse delta between frames
proc setMousePosition*(x: int32, y: int32) {.importc: "SetMousePosition".}
  ## Set mouse position XY
proc setMouseOffset*(offsetX: int32, offsetY: int32) {.importc: "SetMouseOffset".}
  ## Set mouse offset
proc setMouseScale*(scaleX: float32, scaleY: float32) {.importc: "SetMouseScale".}
  ## Set mouse scaling
proc getMouseWheelMove*(): float32 {.importc: "GetMouseWheelMove".}
  ## Get mouse wheel movement Y
proc setMouseCursor*(cursor: MouseCursor) {.importc: "SetMouseCursor".}
  ## Set mouse cursor
proc getTouchX*(): int32 {.importc: "GetTouchX".}
  ## Get touch position X for touch point 0 (relative to screen size)
proc getTouchY*(): int32 {.importc: "GetTouchY".}
  ## Get touch position Y for touch point 0 (relative to screen size)
proc getTouchPosition*(index: int32): Vector2 {.importc: "GetTouchPosition".}
  ## Get touch position XY for a touch point index (relative to screen size)
proc getTouchPointId*(index: int32): int32 {.importc: "GetTouchPointId".}
  ## Get touch point identifier for given index
proc getTouchPointCount*(): int32 {.importc: "GetTouchPointCount".}
  ## Get number of touch points
proc setGesturesEnabled*(flags: Flag[Gesture]) {.importc: "SetGesturesEnabled".}
  ## Enable a set of gestures using flags
proc isGestureDetected*(gesture: Gesture): bool {.importc: "IsGestureDetected".}
  ## Check if a gesture have been detected
proc getGestureDetected*(): Gesture {.importc: "GetGestureDetected".}
  ## Get latest detected gesture
proc getGestureHoldDuration*(): float32 {.importc: "GetGestureHoldDuration".}
  ## Get gesture hold time in milliseconds
proc getGestureDragVector*(): Vector2 {.importc: "GetGestureDragVector".}
  ## Get gesture drag vector
proc getGestureDragAngle*(): float32 {.importc: "GetGestureDragAngle".}
  ## Get gesture drag angle
proc getGesturePinchVector*(): Vector2 {.importc: "GetGesturePinchVector".}
  ## Get gesture pinch delta
proc getGesturePinchAngle*(): float32 {.importc: "GetGesturePinchAngle".}
  ## Get gesture pinch angle
proc setCameraMode*(camera: Camera, mode: CameraMode) {.importc: "SetCameraMode".}
  ## Set camera mode (multiple camera modes available)
proc updateCamera*(camera: var Camera) {.importc: "UpdateCamera".}
  ## Update camera position for selected mode
proc setCameraPanControl*(keyPan: KeyboardKey) {.importc: "SetCameraPanControl".}
  ## Set camera pan key to combine with mouse movement (free camera)
proc setCameraAltControl*(keyAlt: KeyboardKey) {.importc: "SetCameraAltControl".}
  ## Set camera alt key to combine with mouse movement (free camera)
proc setCameraSmoothZoomControl*(keySmoothZoom: KeyboardKey) {.importc: "SetCameraSmoothZoomControl".}
  ## Set camera smooth zoom key to combine with mouse (free camera)
proc setCameraMoveControls*(keyFront: KeyboardKey, keyBack: KeyboardKey, keyRight: KeyboardKey, keyLeft: KeyboardKey, keyUp: KeyboardKey, keyDown: KeyboardKey) {.importc: "SetCameraMoveControls".}
  ## Set camera move controls (1st person and 3rd person cameras)
proc setShapesTexture*(texture: Texture2D, source: Rectangle) {.importc: "SetShapesTexture".}
  ## Set texture and rectangle to be used on shapes drawing
proc drawPixel*(posX: int32, posY: int32, color: Color) {.importc: "DrawPixel".}
  ## Draw a pixel
proc drawPixelV*(position: Vector2, color: Color) {.importc: "DrawPixelV".}
  ## Draw a pixel (Vector version)
proc drawLine*(startPosX: int32, startPosY: int32, endPosX: int32, endPosY: int32, color: Color) {.importc: "DrawLine".}
  ## Draw a line
proc drawLineV*(startPos: Vector2, endPos: Vector2, color: Color) {.importc: "DrawLineV".}
  ## Draw a line (Vector version)
proc drawLineEx*(startPos: Vector2, endPos: Vector2, thick: float32, color: Color) {.importc: "DrawLineEx".}
  ## Draw a line defining thickness
proc drawLineBezier*(startPos: Vector2, endPos: Vector2, thick: float32, color: Color) {.importc: "DrawLineBezier".}
  ## Draw a line using cubic-bezier curves in-out
proc drawLineBezierQuad*(startPos: Vector2, endPos: Vector2, controlPos: Vector2, thick: float32, color: Color) {.importc: "DrawLineBezierQuad".}
  ## Draw line using quadratic bezier curves with a control point
proc drawLineBezierCubic*(startPos: Vector2, endPos: Vector2, startControlPos: Vector2, endControlPos: Vector2, thick: float32, color: Color) {.importc: "DrawLineBezierCubic".}
  ## Draw line using cubic bezier curves with 2 control points
proc drawLineStripPriv(points: ptr UncheckedArray[Vector2], pointCount: int32, color: Color) {.importc: "DrawLineStrip".}
proc drawCircle*(centerX: int32, centerY: int32, radius: float32, color: Color) {.importc: "DrawCircle".}
  ## Draw a color-filled circle
proc drawCircleSector*(center: Vector2, radius: float32, startAngle: float32, endAngle: float32, segments: int32, color: Color) {.importc: "DrawCircleSector".}
  ## Draw a piece of a circle
proc drawCircleSectorLines*(center: Vector2, radius: float32, startAngle: float32, endAngle: float32, segments: int32, color: Color) {.importc: "DrawCircleSectorLines".}
  ## Draw circle sector outline
proc drawCircleGradient*(centerX: int32, centerY: int32, radius: float32, color1: Color, color2: Color) {.importc: "DrawCircleGradient".}
  ## Draw a gradient-filled circle
proc drawCircleV*(center: Vector2, radius: float32, color: Color) {.importc: "DrawCircleV".}
  ## Draw a color-filled circle (Vector version)
proc drawCircleLines*(centerX: int32, centerY: int32, radius: float32, color: Color) {.importc: "DrawCircleLines".}
  ## Draw circle outline
proc drawEllipse*(centerX: int32, centerY: int32, radiusH: float32, radiusV: float32, color: Color) {.importc: "DrawEllipse".}
  ## Draw ellipse
proc drawEllipseLines*(centerX: int32, centerY: int32, radiusH: float32, radiusV: float32, color: Color) {.importc: "DrawEllipseLines".}
  ## Draw ellipse outline
proc drawRing*(center: Vector2, innerRadius: float32, outerRadius: float32, startAngle: float32, endAngle: float32, segments: int32, color: Color) {.importc: "DrawRing".}
  ## Draw ring
proc drawRingLines*(center: Vector2, innerRadius: float32, outerRadius: float32, startAngle: float32, endAngle: float32, segments: int32, color: Color) {.importc: "DrawRingLines".}
  ## Draw ring outline
proc drawRectangle*(posX: int32, posY: int32, width: int32, height: int32, color: Color) {.importc: "DrawRectangle".}
  ## Draw a color-filled rectangle
proc drawRectangleV*(position: Vector2, size: Vector2, color: Color) {.importc: "DrawRectangleV".}
  ## Draw a color-filled rectangle (Vector version)
proc drawRectangleRec*(rec: Rectangle, color: Color) {.importc: "DrawRectangleRec".}
  ## Draw a color-filled rectangle
proc drawRectanglePro*(rec: Rectangle, origin: Vector2, rotation: float32, color: Color) {.importc: "DrawRectanglePro".}
  ## Draw a color-filled rectangle with pro parameters
proc drawRectangleGradientV*(posX: int32, posY: int32, width: int32, height: int32, color1: Color, color2: Color) {.importc: "DrawRectangleGradientV".}
  ## Draw a vertical-gradient-filled rectangle
proc drawRectangleGradientH*(posX: int32, posY: int32, width: int32, height: int32, color1: Color, color2: Color) {.importc: "DrawRectangleGradientH".}
  ## Draw a horizontal-gradient-filled rectangle
proc drawRectangleGradientEx*(rec: Rectangle, col1: Color, col2: Color, col3: Color, col4: Color) {.importc: "DrawRectangleGradientEx".}
  ## Draw a gradient-filled rectangle with custom vertex colors
proc drawRectangleLines*(posX: int32, posY: int32, width: int32, height: int32, color: Color) {.importc: "DrawRectangleLines".}
  ## Draw rectangle outline
proc drawRectangleLinesEx*(rec: Rectangle, lineThick: float32, color: Color) {.importc: "DrawRectangleLinesEx".}
  ## Draw rectangle outline with extended parameters
proc drawRectangleRounded*(rec: Rectangle, roundness: float32, segments: int32, color: Color) {.importc: "DrawRectangleRounded".}
  ## Draw rectangle with rounded edges
proc drawRectangleRoundedLines*(rec: Rectangle, roundness: float32, segments: int32, lineThick: float32, color: Color) {.importc: "DrawRectangleRoundedLines".}
  ## Draw rectangle with rounded edges outline
proc drawTriangle*(v1: Vector2, v2: Vector2, v3: Vector2, color: Color) {.importc: "DrawTriangle".}
  ## Draw a color-filled triangle (vertex in counter-clockwise order!)
proc drawTriangleLines*(v1: Vector2, v2: Vector2, v3: Vector2, color: Color) {.importc: "DrawTriangleLines".}
  ## Draw triangle outline (vertex in counter-clockwise order!)
proc drawTriangleFanPriv(points: ptr UncheckedArray[Vector2], pointCount: int32, color: Color) {.importc: "DrawTriangleFan".}
proc drawTriangleStripPriv(points: ptr UncheckedArray[Vector2], pointCount: int32, color: Color) {.importc: "DrawTriangleStrip".}
proc drawPoly*(center: Vector2, sides: int32, radius: float32, rotation: float32, color: Color) {.importc: "DrawPoly".}
  ## Draw a regular polygon (Vector version)
proc drawPolyLines*(center: Vector2, sides: int32, radius: float32, rotation: float32, color: Color) {.importc: "DrawPolyLines".}
  ## Draw a polygon outline of n sides
proc drawPolyLinesEx*(center: Vector2, sides: int32, radius: float32, rotation: float32, lineThick: float32, color: Color) {.importc: "DrawPolyLinesEx".}
  ## Draw a polygon outline of n sides with extended parameters
proc checkCollisionRecs*(rec1: Rectangle, rec2: Rectangle): bool {.importc: "CheckCollisionRecs".}
  ## Check collision between two rectangles
proc checkCollisionCircles*(center1: Vector2, radius1: float32, center2: Vector2, radius2: float32): bool {.importc: "CheckCollisionCircles".}
  ## Check collision between two circles
proc checkCollisionCircleRec*(center: Vector2, radius: float32, rec: Rectangle): bool {.importc: "CheckCollisionCircleRec".}
  ## Check collision between circle and rectangle
proc checkCollisionPointRec*(point: Vector2, rec: Rectangle): bool {.importc: "CheckCollisionPointRec".}
  ## Check if point is inside rectangle
proc checkCollisionPointCircle*(point: Vector2, center: Vector2, radius: float32): bool {.importc: "CheckCollisionPointCircle".}
  ## Check if point is inside circle
proc checkCollisionPointTriangle*(point: Vector2, p1: Vector2, p2: Vector2, p3: Vector2): bool {.importc: "CheckCollisionPointTriangle".}
  ## Check if point is inside a triangle
proc checkCollisionLines*(startPos1: Vector2, endPos1: Vector2, startPos2: Vector2, endPos2: Vector2, collisionPoint: var Vector2): bool {.importc: "CheckCollisionLines".}
  ## Check the collision between two lines defined by two points each, returns collision point by reference
proc checkCollisionPointLine*(point: Vector2, p1: Vector2, p2: Vector2, threshold: int32): bool {.importc: "CheckCollisionPointLine".}
  ## Check if point belongs to line created between two points [p1] and [p2] with defined margin in pixels [threshold]
proc getCollisionRec*(rec1: Rectangle, rec2: Rectangle): Rectangle {.importc: "GetCollisionRec".}
  ## Get collision rectangle for two rectangles collision
proc loadImage*(fileName: cstring): Image {.importc: "LoadImage".}
  ## Load image from file into CPU memory (RAM)
proc loadImageRaw*(fileName: cstring, width: int32, height: int32, format: PixelFormat, headerSize: int32): Image {.importc: "LoadImageRaw".}
  ## Load image from RAW file data
proc loadImageAnim*(fileName: cstring, frames: var int32): Image {.importc: "LoadImageAnim".}
  ## Load image sequence from file (frames appended to image.data)
proc loadImageFromMemoryPriv(fileType: cstring, fileData: ptr UncheckedArray[uint8], dataSize: int32): Image {.importc: "LoadImageFromMemory".}
proc loadImageFromTexture*(texture: Texture2D): Image {.importc: "LoadImageFromTexture".}
  ## Load image from GPU texture data
proc loadImageFromScreen*(): Image {.importc: "LoadImageFromScreen".}
  ## Load image from screen buffer and (screenshot)
proc unloadImage*(image: Image) {.importc: "UnloadImage".}
  ## Unload image from CPU memory (RAM)
proc exportImage*(image: Image, fileName: cstring): bool {.importc: "ExportImage".}
  ## Export image data to file, returns true on success
proc exportImageAsCode*(image: Image, fileName: cstring): bool {.importc: "ExportImageAsCode".}
  ## Export image as code file defining an array of bytes, returns true on success
proc genImageColor*(width: int32, height: int32, color: Color): Image {.importc: "GenImageColor".}
  ## Generate image: plain color
proc genImageGradientV*(width: int32, height: int32, top: Color, bottom: Color): Image {.importc: "GenImageGradientV".}
  ## Generate image: vertical gradient
proc genImageGradientH*(width: int32, height: int32, left: Color, right: Color): Image {.importc: "GenImageGradientH".}
  ## Generate image: horizontal gradient
proc genImageGradientRadial*(width: int32, height: int32, density: float32, inner: Color, outer: Color): Image {.importc: "GenImageGradientRadial".}
  ## Generate image: radial gradient
proc genImageChecked*(width: int32, height: int32, checksX: int32, checksY: int32, col1: Color, col2: Color): Image {.importc: "GenImageChecked".}
  ## Generate image: checked
proc genImageWhiteNoise*(width: int32, height: int32, factor: float32): Image {.importc: "GenImageWhiteNoise".}
  ## Generate image: white noise
proc genImageCellular*(width: int32, height: int32, tileSize: int32): Image {.importc: "GenImageCellular".}
  ## Generate image: cellular algorithm, bigger tileSize means bigger cells
proc imageCopy*(image: Image): Image {.importc: "ImageCopy".}
  ## Create an image duplicate (useful for transformations)
proc imageFromImage*(image: Image, rec: Rectangle): Image {.importc: "ImageFromImage".}
  ## Create an image from another image piece
proc imageText*(text: cstring, fontSize: int32, color: Color): Image {.importc: "ImageText".}
  ## Create an image from text (default font)
proc imageTextEx*(font: Font, text: cstring, fontSize: float32, spacing: float32, tint: Color): Image {.importc: "ImageTextEx".}
  ## Create an image from text (custom sprite font)
proc imageFormat*(image: var Image, newFormat: PixelFormat) {.importc: "ImageFormat".}
  ## Convert image data to desired format
proc imageToPOT*(image: var Image, fill: Color) {.importc: "ImageToPOT".}
  ## Convert image to POT (power-of-two)
proc imageCrop*(image: var Image, crop: Rectangle) {.importc: "ImageCrop".}
  ## Crop an image to a defined rectangle
proc imageAlphaCrop*(image: var Image, threshold: float32) {.importc: "ImageAlphaCrop".}
  ## Crop image depending on alpha value
proc imageAlphaClear*(image: var Image, color: Color, threshold: float32) {.importc: "ImageAlphaClear".}
  ## Clear alpha channel to desired color
proc imageAlphaMask*(image: var Image, alphaMask: Image) {.importc: "ImageAlphaMask".}
  ## Apply alpha mask to image
proc imageAlphaPremultiply*(image: var Image) {.importc: "ImageAlphaPremultiply".}
  ## Premultiply alpha channel
proc imageResize*(image: var Image, newWidth: int32, newHeight: int32) {.importc: "ImageResize".}
  ## Resize image (Bicubic scaling algorithm)
proc imageResizeNN*(image: var Image, newWidth: int32, newHeight: int32) {.importc: "ImageResizeNN".}
  ## Resize image (Nearest-Neighbor scaling algorithm)
proc imageResizeCanvas*(image: var Image, newWidth: int32, newHeight: int32, offsetX: int32, offsetY: int32, fill: Color) {.importc: "ImageResizeCanvas".}
  ## Resize canvas and fill with color
proc imageMipmaps*(image: var Image) {.importc: "ImageMipmaps".}
  ## Compute all mipmap levels for a provided image
proc imageDither*(image: var Image, rBpp: int32, gBpp: int32, bBpp: int32, aBpp: int32) {.importc: "ImageDither".}
  ## Dither image data to 16bpp or lower (Floyd-Steinberg dithering)
proc imageFlipVertical*(image: var Image) {.importc: "ImageFlipVertical".}
  ## Flip image vertically
proc imageFlipHorizontal*(image: var Image) {.importc: "ImageFlipHorizontal".}
  ## Flip image horizontally
proc imageRotateCW*(image: var Image) {.importc: "ImageRotateCW".}
  ## Rotate image clockwise 90deg
proc imageRotateCCW*(image: var Image) {.importc: "ImageRotateCCW".}
  ## Rotate image counter-clockwise 90deg
proc imageColorTint*(image: var Image, color: Color) {.importc: "ImageColorTint".}
  ## Modify image color: tint
proc imageColorInvert*(image: var Image) {.importc: "ImageColorInvert".}
  ## Modify image color: invert
proc imageColorGrayscale*(image: var Image) {.importc: "ImageColorGrayscale".}
  ## Modify image color: grayscale
proc imageColorContrast*(image: var Image, contrast: float32) {.importc: "ImageColorContrast".}
  ## Modify image color: contrast (-100 to 100)
proc imageColorBrightness*(image: var Image, brightness: int32) {.importc: "ImageColorBrightness".}
  ## Modify image color: brightness (-255 to 255)
proc imageColorReplace*(image: var Image, color: Color, replace: Color) {.importc: "ImageColorReplace".}
  ## Modify image color: replace color
proc loadImageColorsPriv(image: Image): ptr UncheckedArray[Color] {.importc: "LoadImageColors".}
proc loadImagePalettePriv(image: Image, maxPaletteSize: int32, colorCount: ptr int32): ptr UncheckedArray[Color] {.importc: "LoadImagePalette".}
proc unloadImageColorsPriv(colors: ptr UncheckedArray[Color]) {.importc: "UnloadImageColors".}
proc unloadImagePalettePriv(colors: ptr UncheckedArray[Color]) {.importc: "UnloadImagePalette".}
proc getImageAlphaBorder*(image: Image, threshold: float32): Rectangle {.importc: "GetImageAlphaBorder".}
  ## Get image alpha border rectangle
proc getImageColor*(image: Image, x: int32, y: int32): Color {.importc: "GetImageColor".}
  ## Get image pixel color at (x, y) position
proc imageClearBackground*(dst: var Image, color: Color) {.importc: "ImageClearBackground".}
  ## Clear image background with given color
proc imageDrawPixel*(dst: var Image, posX: int32, posY: int32, color: Color) {.importc: "ImageDrawPixel".}
  ## Draw pixel within an image
proc imageDrawPixelV*(dst: var Image, position: Vector2, color: Color) {.importc: "ImageDrawPixelV".}
  ## Draw pixel within an image (Vector version)
proc imageDrawLine*(dst: var Image, startPosX: int32, startPosY: int32, endPosX: int32, endPosY: int32, color: Color) {.importc: "ImageDrawLine".}
  ## Draw line within an image
proc imageDrawLineV*(dst: var Image, start: Vector2, `end`: Vector2, color: Color) {.importc: "ImageDrawLineV".}
  ## Draw line within an image (Vector version)
proc imageDrawCircle*(dst: var Image, centerX: int32, centerY: int32, radius: int32, color: Color) {.importc: "ImageDrawCircle".}
  ## Draw circle within an image
proc imageDrawCircleV*(dst: var Image, center: Vector2, radius: int32, color: Color) {.importc: "ImageDrawCircleV".}
  ## Draw circle within an image (Vector version)
proc imageDrawRectangle*(dst: var Image, posX: int32, posY: int32, width: int32, height: int32, color: Color) {.importc: "ImageDrawRectangle".}
  ## Draw rectangle within an image
proc imageDrawRectangleV*(dst: var Image, position: Vector2, size: Vector2, color: Color) {.importc: "ImageDrawRectangleV".}
  ## Draw rectangle within an image (Vector version)
proc imageDrawRectangleRec*(dst: var Image, rec: Rectangle, color: Color) {.importc: "ImageDrawRectangleRec".}
  ## Draw rectangle within an image
proc imageDrawRectangleLines*(dst: var Image, rec: Rectangle, thick: int32, color: Color) {.importc: "ImageDrawRectangleLines".}
  ## Draw rectangle lines within an image
proc imageDraw*(dst: var Image, src: Image, srcRec: Rectangle, dstRec: Rectangle, tint: Color) {.importc: "ImageDraw".}
  ## Draw a source image within a destination image (tint applied to source)
proc imageDrawText*(dst: var Image, text: cstring, posX: int32, posY: int32, fontSize: int32, color: Color) {.importc: "ImageDrawText".}
  ## Draw text (using default font) within an image (destination)
proc imageDrawTextEx*(dst: var Image, font: Font, text: cstring, position: Vector2, fontSize: float32, spacing: float32, tint: Color) {.importc: "ImageDrawTextEx".}
  ## Draw text (custom sprite font) within an image (destination)
proc loadTexture*(fileName: cstring): Texture2D {.importc: "LoadTexture".}
  ## Load texture from file into GPU memory (VRAM)
proc loadTextureFromImage*(image: Image): Texture2D {.importc: "LoadTextureFromImage".}
  ## Load texture from image data
proc loadTextureCubemap*(image: Image, layout: CubemapLayout): TextureCubemap {.importc: "LoadTextureCubemap".}
  ## Load cubemap from image, multiple image cubemap layouts supported
proc loadRenderTexture*(width: int32, height: int32): RenderTexture2D {.importc: "LoadRenderTexture".}
  ## Load texture for rendering (framebuffer)
proc unloadTexture*(texture: Texture2D) {.importc: "UnloadTexture".}
  ## Unload texture from GPU memory (VRAM)
proc unloadRenderTexture*(target: RenderTexture2D) {.importc: "UnloadRenderTexture".}
  ## Unload render texture from GPU memory (VRAM)
proc updateTexture*(texture: Texture2D, pixels: pointer) {.importc: "UpdateTexture".}
  ## Update GPU texture with new data
proc updateTextureRec*(texture: Texture2D, rec: Rectangle, pixels: pointer) {.importc: "UpdateTextureRec".}
  ## Update GPU texture rectangle with new data
proc genTextureMipmaps*(texture: var Texture2D) {.importc: "GenTextureMipmaps".}
  ## Generate GPU mipmaps for a texture
proc setTextureFilter*(texture: Texture2D, filter: TextureFilter) {.importc: "SetTextureFilter".}
  ## Set texture scaling filter mode
proc setTextureWrap*(texture: Texture2D, wrap: TextureWrap) {.importc: "SetTextureWrap".}
  ## Set texture wrapping mode
proc drawTexture*(texture: Texture2D, posX: int32, posY: int32, tint: Color) {.importc: "DrawTexture".}
  ## Draw a Texture2D
proc drawTextureV*(texture: Texture2D, position: Vector2, tint: Color) {.importc: "DrawTextureV".}
  ## Draw a Texture2D with position defined as Vector2
proc drawTextureEx*(texture: Texture2D, position: Vector2, rotation: float32, scale: float32, tint: Color) {.importc: "DrawTextureEx".}
  ## Draw a Texture2D with extended parameters
proc drawTextureRec*(texture: Texture2D, source: Rectangle, position: Vector2, tint: Color) {.importc: "DrawTextureRec".}
  ## Draw a part of a texture defined by a rectangle
proc drawTextureQuad*(texture: Texture2D, tiling: Vector2, offset: Vector2, quad: Rectangle, tint: Color) {.importc: "DrawTextureQuad".}
  ## Draw texture quad with tiling and offset parameters
proc drawTextureTiled*(texture: Texture2D, source: Rectangle, dest: Rectangle, origin: Vector2, rotation: float32, scale: float32, tint: Color) {.importc: "DrawTextureTiled".}
  ## Draw part of a texture (defined by a rectangle) with rotation and scale tiled into dest.
proc drawTexturePro*(texture: Texture2D, source: Rectangle, dest: Rectangle, origin: Vector2, rotation: float32, tint: Color) {.importc: "DrawTexturePro".}
  ## Draw a part of a texture defined by a rectangle with 'pro' parameters
proc drawTextureNPatch*(texture: Texture2D, nPatchInfo: NPatchInfo, dest: Rectangle, origin: Vector2, rotation: float32, tint: Color) {.importc: "DrawTextureNPatch".}
  ## Draws a texture (or part of it) that stretches or shrinks nicely
proc drawTexturePolyPriv(texture: Texture2D, center: Vector2, points: ptr UncheckedArray[Vector2], texcoords: ptr UncheckedArray[Vector2], pointCount: int32, tint: Color) {.importc: "DrawTexturePoly".}
proc fade*(color: Color, alpha: float32): Color {.importc: "Fade".}
  ## Get color with alpha applied, alpha goes from 0.0f to 1.0f
proc colorToInt*(color: Color): int32 {.importc: "ColorToInt".}
  ## Get hexadecimal value for a Color
proc colorNormalize*(color: Color): Vector4 {.importc: "ColorNormalize".}
  ## Get Color normalized as float [0..1]
proc colorFromNormalized*(normalized: Vector4): Color {.importc: "ColorFromNormalized".}
  ## Get Color from normalized values [0..1]
proc colorToHSV*(color: Color): Vector3 {.importc: "ColorToHSV".}
  ## Get HSV values for a Color, hue [0..360], saturation/value [0..1]
proc colorFromHSV*(hue: float32, saturation: float32, value: float32): Color {.importc: "ColorFromHSV".}
  ## Get a Color from HSV values, hue [0..360], saturation/value [0..1]
proc colorAlpha*(color: Color, alpha: float32): Color {.importc: "ColorAlpha".}
  ## Get color with alpha applied, alpha goes from 0.0f to 1.0f
proc colorAlphaBlend*(dst: Color, src: Color, tint: Color): Color {.importc: "ColorAlphaBlend".}
  ## Get src alpha-blended into dst color with tint
proc getColor*(hexValue: uint32): Color {.importc: "GetColor".}
  ## Get Color structure from hexadecimal value
proc getPixelColor*(srcPtr: pointer, format: PixelFormat): Color {.importc: "GetPixelColor".}
  ## Get Color from a source pixel pointer of certain format
proc setPixelColor*(dstPtr: pointer, color: Color, format: PixelFormat) {.importc: "SetPixelColor".}
  ## Set color formatted into destination pixel pointer
proc getPixelDataSize*(width: int32, height: int32, format: PixelFormat): int32 {.importc: "GetPixelDataSize".}
  ## Get pixel data size in bytes for certain format
proc getFontDefault*(): Font {.importc: "GetFontDefault".}
  ## Get the default Font
proc loadFont*(fileName: cstring): Font {.importc: "LoadFont".}
  ## Load font from file into GPU memory (VRAM)
proc loadFontExPriv(fileName: cstring, fontSize: int32, fontChars: ptr UncheckedArray[int32], glyphCount: int32): Font {.importc: "LoadFontEx".}
proc loadFontFromImage*(image: Image, key: Color, firstChar: int32): Font {.importc: "LoadFontFromImage".}
  ## Load font from Image (XNA style)
proc loadFontFromMemoryPriv(fileType: cstring, fileData: ptr UncheckedArray[uint8], dataSize: int32, fontSize: int32, fontChars: ptr UncheckedArray[int32], glyphCount: int32): Font {.importc: "LoadFontFromMemory".}
proc loadFontDataPriv(fileData: ptr UncheckedArray[uint8], dataSize: int32, fontSize: int32, fontChars: ptr UncheckedArray[int32], glyphCount: int32, `type`: FontType): ptr UncheckedArray[GlyphInfo] {.importc: "LoadFontData".}
proc genImageFontAtlasPriv(chars: ptr UncheckedArray[GlyphInfo], recs: ptr ptr UncheckedArray[Rectangle], glyphCount: int32, fontSize: int32, padding: int32, packMethod: int32): Image {.importc: "GenImageFontAtlas".}
proc unloadFontDataPriv(chars: ptr UncheckedArray[GlyphInfo], glyphCount: int32) {.importc: "UnloadFontData".}
proc unloadFont*(font: Font) {.importc: "UnloadFont".}
  ## Unload font from GPU memory (VRAM)
proc exportFontAsCode*(font: Font, fileName: cstring): bool {.importc: "ExportFontAsCode".}
  ## Export font as code file, returns true on success
proc drawFPS*(posX: int32, posY: int32) {.importc: "DrawFPS".}
  ## Draw current FPS
proc drawText*(text: cstring, posX: int32, posY: int32, fontSize: int32, color: Color) {.importc: "DrawText".}
  ## Draw text (using default font)
proc drawTextEx*(font: Font, text: cstring, position: Vector2, fontSize: float32, spacing: float32, tint: Color) {.importc: "DrawTextEx".}
  ## Draw text using font and additional parameters
proc drawTextPro*(font: Font, text: cstring, position: Vector2, origin: Vector2, rotation: float32, fontSize: float32, spacing: float32, tint: Color) {.importc: "DrawTextPro".}
  ## Draw text using Font and pro parameters (rotation)
proc drawTextCodepoint*(font: Font, codepoint: Rune, position: Vector2, fontSize: float32, tint: Color) {.importc: "DrawTextCodepoint".}
  ## Draw one character (codepoint)
proc drawTextCodepointsPriv(font: Font, codepoints: ptr UncheckedArray[int32], count: int32, position: Vector2, fontSize: float32, spacing: float32, tint: Color) {.importc: "DrawTextCodepoints".}
proc measureText*(text: cstring, fontSize: int32): int32 {.importc: "MeasureText".}
  ## Measure string width for default font
proc measureTextEx*(font: Font, text: cstring, fontSize: float32, spacing: float32): Vector2 {.importc: "MeasureTextEx".}
  ## Measure string size for Font
proc getGlyphIndex*(font: Font, codepoint: Rune): int32 {.importc: "GetGlyphIndex".}
  ## Get glyph index position in font for a codepoint (unicode character), fallback to '?' if not found
proc getGlyphInfo*(font: Font, codepoint: Rune): GlyphInfo {.importc: "GetGlyphInfo".}
  ## Get glyph font info data for a codepoint (unicode character), fallback to '?' if not found
proc getGlyphAtlasRec*(font: Font, codepoint: Rune): Rectangle {.importc: "GetGlyphAtlasRec".}
  ## Get glyph rectangle in font atlas for a codepoint (unicode character), fallback to '?' if not found
proc drawLine3D*(startPos: Vector3, endPos: Vector3, color: Color) {.importc: "DrawLine3D".}
  ## Draw a line in 3D world space
proc drawPoint3D*(position: Vector3, color: Color) {.importc: "DrawPoint3D".}
  ## Draw a point in 3D space, actually a small line
proc drawCircle3D*(center: Vector3, radius: float32, rotationAxis: Vector3, rotationAngle: float32, color: Color) {.importc: "DrawCircle3D".}
  ## Draw a circle in 3D world space
proc drawTriangle3D*(v1: Vector3, v2: Vector3, v3: Vector3, color: Color) {.importc: "DrawTriangle3D".}
  ## Draw a color-filled triangle (vertex in counter-clockwise order!)
proc drawTriangleStrip3DPriv(points: ptr UncheckedArray[Vector3], pointCount: int32, color: Color) {.importc: "DrawTriangleStrip3D".}
proc drawCube*(position: Vector3, width: float32, height: float32, length: float32, color: Color) {.importc: "DrawCube".}
  ## Draw cube
proc drawCubeV*(position: Vector3, size: Vector3, color: Color) {.importc: "DrawCubeV".}
  ## Draw cube (Vector version)
proc drawCubeWires*(position: Vector3, width: float32, height: float32, length: float32, color: Color) {.importc: "DrawCubeWires".}
  ## Draw cube wires
proc drawCubeWiresV*(position: Vector3, size: Vector3, color: Color) {.importc: "DrawCubeWiresV".}
  ## Draw cube wires (Vector version)
proc drawCubeTexture*(texture: Texture2D, position: Vector3, width: float32, height: float32, length: float32, color: Color) {.importc: "DrawCubeTexture".}
  ## Draw cube textured
proc drawCubeTextureRec*(texture: Texture2D, source: Rectangle, position: Vector3, width: float32, height: float32, length: float32, color: Color) {.importc: "DrawCubeTextureRec".}
  ## Draw cube with a region of a texture
proc drawSphere*(centerPos: Vector3, radius: float32, color: Color) {.importc: "DrawSphere".}
  ## Draw sphere
proc drawSphereEx*(centerPos: Vector3, radius: float32, rings: int32, slices: int32, color: Color) {.importc: "DrawSphereEx".}
  ## Draw sphere with extended parameters
proc drawSphereWires*(centerPos: Vector3, radius: float32, rings: int32, slices: int32, color: Color) {.importc: "DrawSphereWires".}
  ## Draw sphere wires
proc drawCylinder*(position: Vector3, radiusTop: float32, radiusBottom: float32, height: float32, slices: int32, color: Color) {.importc: "DrawCylinder".}
  ## Draw a cylinder/cone
proc drawCylinderEx*(startPos: Vector3, endPos: Vector3, startRadius: float32, endRadius: float32, sides: int32, color: Color) {.importc: "DrawCylinderEx".}
  ## Draw a cylinder with base at startPos and top at endPos
proc drawCylinderWires*(position: Vector3, radiusTop: float32, radiusBottom: float32, height: float32, slices: int32, color: Color) {.importc: "DrawCylinderWires".}
  ## Draw a cylinder/cone wires
proc drawCylinderWiresEx*(startPos: Vector3, endPos: Vector3, startRadius: float32, endRadius: float32, sides: int32, color: Color) {.importc: "DrawCylinderWiresEx".}
  ## Draw a cylinder wires with base at startPos and top at endPos
proc drawPlane*(centerPos: Vector3, size: Vector2, color: Color) {.importc: "DrawPlane".}
  ## Draw a plane XZ
proc drawRay*(ray: Ray, color: Color) {.importc: "DrawRay".}
  ## Draw a ray line
proc drawGrid*(slices: int32, spacing: float32) {.importc: "DrawGrid".}
  ## Draw a grid (centered at (0, 0, 0))
proc loadModel*(fileName: cstring): Model {.importc: "LoadModel".}
  ## Load model from files (meshes and materials)
proc loadModelFromMesh*(mesh: Mesh): Model {.importc: "LoadModelFromMesh".}
  ## Load model from generated mesh (default material)
proc unloadModel*(model: Model) {.importc: "UnloadModel".}
  ## Unload model (including meshes) from memory (RAM and/or VRAM)
proc unloadModelKeepMeshes*(model: Model) {.importc: "UnloadModelKeepMeshes".}
  ## Unload model (but not meshes) from memory (RAM and/or VRAM)
proc getModelBoundingBox*(model: Model): BoundingBox {.importc: "GetModelBoundingBox".}
  ## Compute model bounding box limits (considers all meshes)
proc drawModel*(model: Model, position: Vector3, scale: float32, tint: Color) {.importc: "DrawModel".}
  ## Draw a model (with texture if set)
proc drawModelEx*(model: Model, position: Vector3, rotationAxis: Vector3, rotationAngle: float32, scale: Vector3, tint: Color) {.importc: "DrawModelEx".}
  ## Draw a model with extended parameters
proc drawModelWires*(model: Model, position: Vector3, scale: float32, tint: Color) {.importc: "DrawModelWires".}
  ## Draw a model wires (with texture if set)
proc drawModelWiresEx*(model: Model, position: Vector3, rotationAxis: Vector3, rotationAngle: float32, scale: Vector3, tint: Color) {.importc: "DrawModelWiresEx".}
  ## Draw a model wires (with texture if set) with extended parameters
proc drawBoundingBox*(box: BoundingBox, color: Color) {.importc: "DrawBoundingBox".}
  ## Draw bounding box (wires)
proc drawBillboard*(camera: Camera, texture: Texture2D, position: Vector3, size: float32, tint: Color) {.importc: "DrawBillboard".}
  ## Draw a billboard texture
proc drawBillboardRec*(camera: Camera, texture: Texture2D, source: Rectangle, position: Vector3, size: Vector2, tint: Color) {.importc: "DrawBillboardRec".}
  ## Draw a billboard texture defined by source
proc drawBillboardPro*(camera: Camera, texture: Texture2D, source: Rectangle, position: Vector3, up: Vector3, size: Vector2, origin: Vector2, rotation: float32, tint: Color) {.importc: "DrawBillboardPro".}
  ## Draw a billboard texture defined by source and rotation
proc uploadMesh*(mesh: var Mesh, dynamic: bool) {.importc: "UploadMesh".}
  ## Upload mesh vertex data in GPU and provide VAO/VBO ids
proc updateMeshBuffer*(mesh: Mesh, index: int32, data: pointer, dataSize: int32, offset: int32) {.importc: "UpdateMeshBuffer".}
  ## Update mesh vertex data in GPU for a specific buffer index
proc unloadMesh*(mesh: Mesh) {.importc: "UnloadMesh".}
  ## Unload mesh data from CPU and GPU
proc drawMesh*(mesh: Mesh, material: Material, transform: Matrix) {.importc: "DrawMesh".}
  ## Draw a 3d mesh with material and transform
proc drawMeshInstancedPriv(mesh: Mesh, material: Material, transforms: ptr UncheckedArray[Matrix], instances: int32) {.importc: "DrawMeshInstanced".}
proc exportMesh*(mesh: Mesh, fileName: cstring): bool {.importc: "ExportMesh".}
  ## Export mesh data to file, returns true on success
proc getMeshBoundingBox*(mesh: Mesh): BoundingBox {.importc: "GetMeshBoundingBox".}
  ## Compute mesh bounding box limits
proc genMeshTangents*(mesh: var Mesh) {.importc: "GenMeshTangents".}
  ## Compute mesh tangents
proc genMeshBinormals*(mesh: var Mesh) {.importc: "GenMeshBinormals".}
  ## Compute mesh binormals
proc genMeshPoly*(sides: int32, radius: float32): Mesh {.importc: "GenMeshPoly".}
  ## Generate polygonal mesh
proc genMeshPlane*(width: float32, length: float32, resX: int32, resZ: int32): Mesh {.importc: "GenMeshPlane".}
  ## Generate plane mesh (with subdivisions)
proc genMeshCube*(width: float32, height: float32, length: float32): Mesh {.importc: "GenMeshCube".}
  ## Generate cuboid mesh
proc genMeshSphere*(radius: float32, rings: int32, slices: int32): Mesh {.importc: "GenMeshSphere".}
  ## Generate sphere mesh (standard sphere)
proc genMeshHemiSphere*(radius: float32, rings: int32, slices: int32): Mesh {.importc: "GenMeshHemiSphere".}
  ## Generate half-sphere mesh (no bottom cap)
proc genMeshCylinder*(radius: float32, height: float32, slices: int32): Mesh {.importc: "GenMeshCylinder".}
  ## Generate cylinder mesh
proc genMeshCone*(radius: float32, height: float32, slices: int32): Mesh {.importc: "GenMeshCone".}
  ## Generate cone/pyramid mesh
proc genMeshTorus*(radius: float32, size: float32, radSeg: int32, sides: int32): Mesh {.importc: "GenMeshTorus".}
  ## Generate torus mesh
proc genMeshKnot*(radius: float32, size: float32, radSeg: int32, sides: int32): Mesh {.importc: "GenMeshKnot".}
  ## Generate trefoil knot mesh
proc genMeshHeightmap*(heightmap: Image, size: Vector3): Mesh {.importc: "GenMeshHeightmap".}
  ## Generate heightmap mesh from image data
proc genMeshCubicmap*(cubicmap: Image, cubeSize: Vector3): Mesh {.importc: "GenMeshCubicmap".}
  ## Generate cubes-based map mesh from image data
proc loadMaterialsPriv(fileName: cstring, materialCount: ptr int32): ptr UncheckedArray[Material] {.importc: "LoadMaterials".}
proc loadMaterialDefault*(): Material {.importc: "LoadMaterialDefault".}
  ## Load default material (Supports: DIFFUSE, SPECULAR, NORMAL maps)
proc unloadMaterial*(material: Material) {.importc: "UnloadMaterial".}
  ## Unload material from GPU memory (VRAM)
proc setMaterialTexture*(material: var Material, mapType: MaterialMapIndex, texture: Texture2D) {.importc: "SetMaterialTexture".}
  ## Set texture for a material map type (MATERIAL_MAP_DIFFUSE, MATERIAL_MAP_SPECULAR...)
proc setModelMeshMaterial*(model: var Model, meshId: int32, materialId: int32) {.importc: "SetModelMeshMaterial".}
  ## Set material for a mesh
proc loadModelAnimationsPriv(fileName: cstring, animCount: ptr uint32): ptr UncheckedArray[ModelAnimation] {.importc: "LoadModelAnimations".}
proc updateModelAnimation*(model: Model, anim: ModelAnimation, frame: int32) {.importc: "UpdateModelAnimation".}
  ## Update model animation pose
proc unloadModelAnimation*(anim: ModelAnimation) {.importc: "UnloadModelAnimation".}
  ## Unload animation data
proc unloadModelAnimationsPriv(animations: ptr UncheckedArray[ModelAnimation], count: uint32) {.importc: "UnloadModelAnimations".}
proc isModelAnimationValid*(model: Model, anim: ModelAnimation): bool {.importc: "IsModelAnimationValid".}
  ## Check model animation skeleton match
proc checkCollisionSpheres*(center1: Vector3, radius1: float32, center2: Vector3, radius2: float32): bool {.importc: "CheckCollisionSpheres".}
  ## Check collision between two spheres
proc checkCollisionBoxes*(box1: BoundingBox, box2: BoundingBox): bool {.importc: "CheckCollisionBoxes".}
  ## Check collision between two bounding boxes
proc checkCollisionBoxSphere*(box: BoundingBox, center: Vector3, radius: float32): bool {.importc: "CheckCollisionBoxSphere".}
  ## Check collision between box and sphere
proc getRayCollisionSphere*(ray: Ray, center: Vector3, radius: float32): RayCollision {.importc: "GetRayCollisionSphere".}
  ## Get collision info between ray and sphere
proc getRayCollisionBox*(ray: Ray, box: BoundingBox): RayCollision {.importc: "GetRayCollisionBox".}
  ## Get collision info between ray and box
proc getRayCollisionModel*(ray: Ray, model: Model): RayCollision {.importc: "GetRayCollisionModel".}
  ## Get collision info between ray and model
proc getRayCollisionMesh*(ray: Ray, mesh: Mesh, transform: Matrix): RayCollision {.importc: "GetRayCollisionMesh".}
  ## Get collision info between ray and mesh
proc getRayCollisionTriangle*(ray: Ray, p1: Vector3, p2: Vector3, p3: Vector3): RayCollision {.importc: "GetRayCollisionTriangle".}
  ## Get collision info between ray and triangle
proc getRayCollisionQuad*(ray: Ray, p1: Vector3, p2: Vector3, p3: Vector3, p4: Vector3): RayCollision {.importc: "GetRayCollisionQuad".}
  ## Get collision info between ray and quad
proc initAudioDevice*() {.importc: "InitAudioDevice".}
  ## Initialize audio device and context
proc closeAudioDevice*() {.importc: "CloseAudioDevice".}
  ## Close the audio device and context
proc isAudioDeviceReady*(): bool {.importc: "IsAudioDeviceReady".}
  ## Check if audio device has been initialized successfully
proc setMasterVolume*(volume: float32) {.importc: "SetMasterVolume".}
  ## Set master volume (listener)
proc loadWave*(fileName: cstring): Wave {.importc: "LoadWave".}
  ## Load wave data from file
proc loadWaveFromMemoryPriv(fileType: cstring, fileData: ptr UncheckedArray[uint8], dataSize: int32): Wave {.importc: "LoadWaveFromMemory".}
proc loadSound*(fileName: cstring): Sound {.importc: "LoadSound".}
  ## Load sound from file
proc loadSoundFromWave*(wave: Wave): Sound {.importc: "LoadSoundFromWave".}
  ## Load sound from wave data
proc updateSound*(sound: Sound, data: pointer, sampleCount: int32) {.importc: "UpdateSound".}
  ## Update sound buffer with new data
proc unloadWave*(wave: Wave) {.importc: "UnloadWave".}
  ## Unload wave data
proc unloadSound*(sound: Sound) {.importc: "UnloadSound".}
  ## Unload sound
proc exportWave*(wave: Wave, fileName: cstring): bool {.importc: "ExportWave".}
  ## Export wave data to file, returns true on success
proc exportWaveAsCode*(wave: Wave, fileName: cstring): bool {.importc: "ExportWaveAsCode".}
  ## Export wave sample data to code (.h), returns true on success
proc playSound*(sound: Sound) {.importc: "PlaySound".}
  ## Play a sound
proc stopSound*(sound: Sound) {.importc: "StopSound".}
  ## Stop playing a sound
proc pauseSound*(sound: Sound) {.importc: "PauseSound".}
  ## Pause a sound
proc resumeSound*(sound: Sound) {.importc: "ResumeSound".}
  ## Resume a paused sound
proc playSoundMulti*(sound: Sound) {.importc: "PlaySoundMulti".}
  ## Play a sound (using multichannel buffer pool)
proc stopSoundMulti*() {.importc: "StopSoundMulti".}
  ## Stop any sound playing (using multichannel buffer pool)
proc getSoundsPlaying*(): int32 {.importc: "GetSoundsPlaying".}
  ## Get number of sounds playing in the multichannel
proc isSoundPlaying*(sound: Sound): bool {.importc: "IsSoundPlaying".}
  ## Check if a sound is currently playing
proc setSoundVolume*(sound: Sound, volume: float32) {.importc: "SetSoundVolume".}
  ## Set volume for a sound (1.0 is max level)
proc setSoundPitch*(sound: Sound, pitch: float32) {.importc: "SetSoundPitch".}
  ## Set pitch for a sound (1.0 is base level)
proc setSoundPan*(sound: Sound, pan: float32) {.importc: "SetSoundPan".}
  ## Set pan for a sound (0.5 is center)
proc waveCopy*(wave: Wave): Wave {.importc: "WaveCopy".}
  ## Copy a wave to a new wave
proc waveCrop*(wave: var Wave, initSample: int32, finalSample: int32) {.importc: "WaveCrop".}
  ## Crop a wave to defined samples range
proc waveFormat*(wave: var Wave, sampleRate: int32, sampleSize: int32, channels: int32) {.importc: "WaveFormat".}
  ## Convert wave data to desired format
proc loadWaveSamplesPriv(wave: Wave): ptr UncheckedArray[float32] {.importc: "LoadWaveSamples".}
proc unloadWaveSamplesPriv(samples: ptr UncheckedArray[float32]) {.importc: "UnloadWaveSamples".}
proc loadMusicStream*(fileName: cstring): Music {.importc: "LoadMusicStream".}
  ## Load music stream from file
proc loadMusicStreamFromMemoryPriv(fileType: cstring, data: ptr UncheckedArray[uint8], dataSize: int32): Music {.importc: "LoadMusicStreamFromMemory".}
proc unloadMusicStream*(music: Music) {.importc: "UnloadMusicStream".}
  ## Unload music stream
proc playMusicStream*(music: Music) {.importc: "PlayMusicStream".}
  ## Start music playing
proc isMusicStreamPlaying*(music: Music): bool {.importc: "IsMusicStreamPlaying".}
  ## Check if music is playing
proc updateMusicStream*(music: Music) {.importc: "UpdateMusicStream".}
  ## Updates buffers for music streaming
proc stopMusicStream*(music: Music) {.importc: "StopMusicStream".}
  ## Stop music playing
proc pauseMusicStream*(music: Music) {.importc: "PauseMusicStream".}
  ## Pause music playing
proc resumeMusicStream*(music: Music) {.importc: "ResumeMusicStream".}
  ## Resume playing paused music
proc seekMusicStream*(music: Music, position: float32) {.importc: "SeekMusicStream".}
  ## Seek music to a position (in seconds)
proc setMusicVolume*(music: Music, volume: float32) {.importc: "SetMusicVolume".}
  ## Set volume for music (1.0 is max level)
proc setMusicPitch*(music: Music, pitch: float32) {.importc: "SetMusicPitch".}
  ## Set pitch for a music (1.0 is base level)
proc setMusicPan*(music: Music, pan: float32) {.importc: "SetMusicPan".}
  ## Set pan for a music (0.5 is center)
proc getMusicTimeLength*(music: Music): float32 {.importc: "GetMusicTimeLength".}
  ## Get music time length (in seconds)
proc getMusicTimePlayed*(music: Music): float32 {.importc: "GetMusicTimePlayed".}
  ## Get current music time played (in seconds)
proc loadAudioStream*(sampleRate: uint32, sampleSize: uint32, channels: uint32): AudioStream {.importc: "LoadAudioStream".}
  ## Load audio stream (to stream raw audio pcm data)
proc unloadAudioStream*(stream: AudioStream) {.importc: "UnloadAudioStream".}
  ## Unload audio stream and free memory
proc updateAudioStream*(stream: AudioStream, data: pointer, frameCount: int32) {.importc: "UpdateAudioStream".}
  ## Update audio stream buffers with data
proc isAudioStreamProcessed*(stream: AudioStream): bool {.importc: "IsAudioStreamProcessed".}
  ## Check if any audio stream buffers requires refill
proc playAudioStream*(stream: AudioStream) {.importc: "PlayAudioStream".}
  ## Play audio stream
proc pauseAudioStream*(stream: AudioStream) {.importc: "PauseAudioStream".}
  ## Pause audio stream
proc resumeAudioStream*(stream: AudioStream) {.importc: "ResumeAudioStream".}
  ## Resume audio stream
proc isAudioStreamPlaying*(stream: AudioStream): bool {.importc: "IsAudioStreamPlaying".}
  ## Check if audio stream is playing
proc stopAudioStream*(stream: AudioStream) {.importc: "StopAudioStream".}
  ## Stop audio stream
proc setAudioStreamVolume*(stream: AudioStream, volume: float32) {.importc: "SetAudioStreamVolume".}
  ## Set volume for audio stream (1.0 is max level)
proc setAudioStreamPitch*(stream: AudioStream, pitch: float32) {.importc: "SetAudioStreamPitch".}
  ## Set pitch for audio stream (1.0 is base level)
proc setAudioStreamPan*(stream: AudioStream, pan: float32) {.importc: "SetAudioStreamPan".}
  ## Set pan for audio stream (0.5 is centered)
proc setAudioStreamBufferSizeDefault*(size: int32) {.importc: "SetAudioStreamBufferSizeDefault".}
  ## Default size for new audio streams
{.pop.}

proc `=destroy`*(x: var Image) =
  if x.data != nil: unloadImage(x)
proc `=copy`*(dest: var Image; source: Image) =
  if dest.data != source.data:
    `=destroy`(dest)
    wasMoved(dest)
    dest = imageCopy(source)

proc `=destroy`*(x: var Texture) =
  if x.id > 0: unloadTexture(x)
proc `=copy`*(dest: var Texture; source: Texture) {.error.}

proc `=destroy`*(x: var RenderTexture) =
  if x.id > 0: unloadRenderTexture(x)
proc `=copy`*(dest: var RenderTexture; source: RenderTexture) {.error.}

proc `=destroy`*(x: var Font) =
  if x.texture.id > 0: unloadFont(x)
proc `=copy`*(dest: var Font; source: Font) {.error.}

proc `=destroy`*(x: var Mesh) =
  if x.vboId != nil: unloadMesh(x)
proc `=copy`*(dest: var Mesh; source: Mesh) {.error.}

proc `=destroy`*(x: var Shader) =
  if x.id > 0: unloadShader(x)
proc `=copy`*(dest: var Shader; source: Shader) {.error.}

proc `=destroy`*(x: var Material) =
  if x.maps != nil: unloadMaterial(x)
proc `=copy`*(dest: var Material; source: Material) {.error.}

proc `=destroy`*(x: var Model) =
  if x.meshes != nil: unloadModel(x)
proc `=copy`*(dest: var Model; source: Model) {.error.}

proc `=destroy`*(x: var ModelAnimation) =
  if x.framePoses != nil: unloadModelAnimation(x)
proc `=copy`*(dest: var ModelAnimation; source: ModelAnimation) {.error.}

proc `=destroy`*(x: var Wave) =
  if x.data != nil: unloadWave(x)
proc `=copy`*(dest: var Wave; source: Wave) =
  if dest.data != source.data:
    `=destroy`(dest)
    wasMoved(dest)
    dest = waveCopy(source)

proc `=destroy`*(x: var AudioStream) =
  if x.buffer != nil: unloadAudioStream(x)
proc `=copy`*(dest: var AudioStream; source: AudioStream) {.error.}

proc `=destroy`*(x: var Sound) =
  if x.stream.buffer != nil: unloadSound(x)
proc `=copy`*(dest: var Sound; source: Sound) {.error.}

proc `=destroy`*(x: var Music) =
  if x.stream.buffer != nil: unloadMusicStream(x)
proc `=copy`*(dest: var Music; source: Music) {.error.}

type
  CSeq*[T] = object
    len: int
    data: ptr UncheckedArray[T]

proc `=destroy`*[T](x: var CSeq[T]) =
  if x.data != nil:
    for i in 0..<x.len: `=destroy`(x.data[i])
    memFree(x.data)
proc `=copy`*[T](dest: var CSeq[T]; source: CSeq[T]) =
  if dest.data != source.data:
    `=destroy`(dest)
    wasMoved(dest)
    dest.len = source.len
    if dest.len > 0:
      dest.data = cast[typeof(dest.data)](memAlloc(dest.len.int32))
      for i in 0..<dest.len: dest.data[i] = source.data[i]

proc `[]`*[T](x: CSeq[T], i: int): lent T =
  rangeCheck x.data != nil and i.uint < x.len.uint
  result = x.data[i]

proc `[]`*[T](x: var CSeq[T], i: int): var T =
  rangeCheck x.data != nil and i.uint < x.len.uint
  result = x.data[i]

proc `[]=`*[T](x: var CSeq[T], i: int, val: sink T) =
  rangeCheck x.data != nil and i.uint < x.len.uint
  x.data[i] = val

proc len*[T](x: CSeq[T]): int {.inline.} = x.len

proc `@`*[T](x: CSeq[T]): seq[T] {.inline.} =
  newSeq(result, x.len)
  for i in 0..x.len-1: result[i] = x[i]

template toOpenArray*(x: CSeq, first, last: int): untyped =
  toOpenArray(x.data, first, last)

template toOpenArray*(x: CSeq): untyped =
  toOpenArray(x.data, 0, x.len-1)

proc glyphCount*(x: Font): int32 {.inline.} = x.glyphCount
proc vertexCount*(x: Mesh): int32 {.inline.} = x.vertexCount
proc triangleCount*(x: Mesh): int32 {.inline.} = x.triangleCount
proc meshCount*(x: Model): int32 {.inline.} = x.meshCount
proc materialCount*(x: Model): int32 {.inline.} = x.materialCount
proc boneCount*(x: Model): int32 {.inline.} = x.boneCount
proc boneCount*(x: ModelAnimation): int32 {.inline.} = x.boneCount
proc frameCount*(x: ModelAnimation): int32 {.inline.} = x.frameCount

proc getMonitorName*(monitor: int32): string {.inline.} =
  ## Get the human-readable, UTF-8 encoded name of the primary monitor
  result = $getMonitorNamePriv(monitor)

proc getClipboardText*(): string {.inline.} =
  ## Get clipboard text content
  result = $getClipboardTextPriv()

proc getDroppedFiles*(): seq[string] =
  ## Get dropped files names (memory should be freed)
  var count = 0'i32
  let dropfiles = getDroppedFilesPriv(count.addr)
  result = cstringArrayToSeq(dropfiles, count)

proc getGamepadName*(gamepad: int32): string {.inline.} =
  ## Get gamepad internal name id
  result = $getGamepadNamePriv(gamepad)

proc loadModelAnimations*(fileName: string): CSeq[ModelAnimation] =
  ## Load model animations from file
  var len = 0'u32
  let data = loadModelAnimationsPriv(fileName.cstring, len.addr)
  if len <= 0:
    raise newException(IOError, "No model animations loaded from " & filename)
  result = CSeq[ModelAnimation](len: len.int, data: data)

proc loadWaveSamples*(wave: Wave): CSeq[float32] =
  ## Load samples data from wave as a floats array
  let data = loadWaveSamplesPriv(wave)
  let len = int(wave.frameCount * wave.channels)
  result = CSeq[float32](len: len, data: data)

proc loadImageColors*(image: Image): CSeq[Color] =
  ## Load color data from image as a Color array (RGBA - 32bit)
  let data = loadImageColorsPriv(image)
  let len = int(image.width * image.height)
  result = CSeq[Color](len: len, data: data)

proc loadImagePalette*(image: Image; maxPaletteSize: int32): CSeq[Color] =
  ## Load colors palette from image as a Color array (RGBA - 32bit)
  var len = 0'i32
  let data = loadImagePalettePriv(image, maxPaletteSize, len.addr)
  result = CSeq[Color](len: len.int, data: data)

proc loadFontData*(fileData: openarray[uint8]; fontSize: int32; fontChars: openarray[int32];
    `type`: FontType): CSeq[GlyphInfo] =
  ## Load font data for further use
  let data = loadFontDataPriv(cast[ptr UncheckedArray[uint8]](fileData), fileData.len.int32,
      fontSize, cast[ptr UncheckedArray[int32]](fontChars), fontChars.len.int32, `type`)
  result = CSeq[GlyphInfo](len: fontChars.len, data: data)

proc loadMaterials*(fileName: string): CSeq[Material] =
  ## Load materials from model file
  var len = 0'i32
  let data = loadMaterialsPriv(fileName.cstring, len.addr)
  if len <= 0:
    raise newException(IOError, "No materials loaded from " & filename)
  result = CSeq[Material](len: len.int, data: data)

proc drawLineStrip*(points: openarray[Vector2]; color: Color) {.inline.} =
  ## Draw lines sequence
  drawLineStripPriv(cast[ptr UncheckedArray[Vector2]](points), points.len.int32, color)

proc drawTriangleFan*(points: openarray[Vector2]; color: Color) =
  ## Draw a triangle fan defined by points (first vertex is the center)
  drawTriangleFanPriv(cast[ptr UncheckedArray[Vector2]](points), points.len.int32, color)

proc drawTriangleStrip*(points: openarray[Vector2]; color: Color) =
  ## Draw a triangle strip defined by points
  drawTriangleStripPriv(cast[ptr UncheckedArray[Vector2]](points), points.len.int32, color)

proc loadImageFromMemory*(fileType: string; fileData: openarray[uint8]): Image =
  ## Load image from memory buffer, fileType refers to extension: i.e. '.png'
  result = loadImageFromMemoryPriv(fileType.cstring, cast[ptr UncheckedArray[uint8]](fileData),
      fileData.len.int32)

proc drawTexturePoly*(texture: Texture2D; center: Vector2; points: openarray[Vector2];
    texcoords: openarray[Vector2]; tint: Color) =
  ## Draw a textured polygon
  drawTexturePolyPriv(texture, center, cast[ptr UncheckedArray[Vector2]](points),
      cast[ptr UncheckedArray[Vector2]](texcoords), points.len.int32, tint)

proc loadFontEx*(fileName: string; fontSize: int32; fontChars: openarray[int32]): Font =
  ## Load font from file with extended parameters, use an empty array for fontChars to load the default character set
  result = loadFontExPriv(fileName.cstring, fontSize,
      if fontChars.len == 0: nil else: cast[ptr UncheckedArray[int32]](fontChars), fontChars.len.int32)

proc loadFontFromMemory*(fileType: string; fileData: openarray[uint8]; fontSize: int32;
    fontChars: openarray[int32]): Font =
  ## Load font from memory buffer, fileType refers to extension: i.e. '.ttf'
  result = loadFontFromMemoryPriv(fileType.cstring,
      cast[ptr UncheckedArray[uint8]](fileData), fileData.len.int32, fontSize,
      cast[ptr UncheckedArray[int32]](fontChars), fontChars.len.int32)

proc genImageFontAtlas*(chars: openarray[GlyphInfo]; recs: var CSeq[Rectangle]; fontSize: int32;
    padding: int32; packMethod: int32): Image =
  ## Generate image font atlas using chars info
  var data: ptr UncheckedArray[Rectangle] = nil
  result = genImageFontAtlasPriv(cast[ptr UncheckedArray[GlyphInfo]](chars), data.addr,
      chars.len.int32, fontSize, padding, packMethod)
  recs = CSeq[Rectangle](len: chars.len, data: data)

proc drawTriangleStrip3D*(points: openarray[Vector3]; color: Color) =
  ## Draw a triangle strip defined by points
  drawTriangleStrip3DPriv(cast[ptr UncheckedArray[Vector3]](points), points.len.int32, color)

proc drawMeshInstanced*(mesh: Mesh; material: Material; transforms: openarray[Matrix]) =
  ## Draw multiple mesh instances with material and different transforms
  drawMeshInstancedPriv(mesh, material, cast[ptr UncheckedArray[Matrix]](transforms),
      transforms.len.int32)

proc loadWaveFromMemory*(fileType: string; fileData: openarray[uint8]): Wave =
  ## Load wave from memory buffer, fileType refers to extension: i.e. '.wav'
  loadWaveFromMemoryPriv(fileType.cstring, cast[ptr UncheckedArray[uint8]](fileData),
      fileData.len.int32)

proc loadMusicStreamFromMemory*(fileType: string; data: openarray[uint8]): Music =
  ## Load music stream from data
  loadMusicStreamFromMemoryPriv(fileType.cstring, cast[ptr UncheckedArray[uint8]](data),
      data.len.int32)

proc drawTextCodepoints*(font: Font; codepoints: openarray[Rune]; position: Vector2;
    fontSize: float32; spacing: float32; tint: Color) =
  ## Draw multiple character (codepoint)
  drawTextCodepointsPriv(font, cast[ptr UncheckedArray[int32]](codepoints), codepoints.len.int32,
      position, fontSize, spacing, tint)

template drawing*(body: untyped) =
  ## Setup canvas (framebuffer) to start drawing
  beginDrawing()
  try:
    body
  finally: endDrawing()

template mode2D*(camera: Camera2D; body: untyped) =
  ## 2D mode with custom camera (2D)
  beginMode2D(camera)
  try:
    body
  finally: endMode2D()

template mode3D*(camera: Camera3D; body: untyped) =
  ## 3D mode with custom camera (3D)
  beginMode3D(camera)
  try:
    body
  finally: endMode3D()

template textureMode*(target: RenderTexture2D; body: untyped) =
  ## Drawing to render texture
  beginTextureMode(target)
  try:
    body
  finally: endTextureMode()

template shaderMode*(shader: Shader; body: untyped) =
  ## Custom shader drawing
  beginShaderMode(shader)
  try:
    body
  finally: endShaderMode()

template blendMode*(mode: BlendMode; body: untyped) =
  ## Blending mode (alpha, additive, multiplied, subtract, custom)
  beginBlendMode(mode)
  try:
    body
  finally: endBlendMode()

template scissorMode*(x, y, width, height: int32; body: untyped) =
  ## Scissor mode (define screen area for following drawing)
  beginScissorMode(x, y, width, height)
  try:
    body
  finally: endScissorMode()

template vrStereoMode*(config: VrStereoConfig; body: untyped) =
  ## Stereo rendering (requires VR simulator)
  beginVrStereoMode(config)
  try:
    body
  finally: endVrStereoMode()

template checkArrayAccess(a, x, len) =
  rangeCheck a != nil and x.uint32 < len.uint32

template recs*(x: Font): FontRecs = FontRecs(x)

proc `[]`*(x: FontRecs, i: int): Rectangle =
  checkArrayAccess(Font(x).recs, i, Font(x).glyphCount)
  result = Font(x).recs[i]

proc `[]`*(x: var FontRecs, i: int): var Rectangle =
  checkArrayAccess(Font(x).recs, i, Font(x).glyphCount)
  result = Font(x).recs[i]

proc `[]=`*(x: var FontRecs, i: int, val: Rectangle) =
  checkArrayAccess(Font(x).recs, i, Font(x).glyphCount)
  Font(x).recs[i] = val

template glyphs*(x: Font): FontGlyphs = FontGlyphs(x)

proc `[]`*(x: FontGlyphs, i: int): lent GlyphInfo =
  checkArrayAccess(Font(x).glyphs, i, Font(x).glyphCount)
  result = Font(x).glyphs[i]

proc `[]`*(x: var FontGlyphs, i: int): var GlyphInfo =
  checkArrayAccess(Font(x).glyphs, i, Font(x).glyphCount)
  result = Font(x).glyphs[i]

proc `[]=`*(x: var FontGlyphs, i: int, val: GlyphInfo) =
  checkArrayAccess(Font(x).glyphs, i, Font(x).glyphCount)
  Font(x).glyphs[i] = val

template vertices*(x: Mesh): MeshVertices = MeshVertices(x)

proc `[]`*(x: MeshVertices, i: int): Vector3 =
  checkArrayAccess(Mesh(x).vertices, i, Mesh(x).vertexCount)
  result = cast[ptr UncheckedArray[Vector3]](Mesh(x).vertices)[i]

proc `[]`*(x: var MeshVertices, i: int): var Vector3 =
  checkArrayAccess(Mesh(x).vertices, i, Mesh(x).vertexCount)
  result = cast[ptr UncheckedArray[Vector3]](Mesh(x).vertices)[i]

proc `[]=`*(x: var MeshVertices, i: int, val: Vector3) =
  checkArrayAccess(Mesh(x).vertices, i, Mesh(x).vertexCount)
  cast[ptr UncheckedArray[Vector3]](Mesh(x).vertices)[i] = val

template texcoords*(x: Mesh): MeshTexcoords = MeshTexcoords(x)

proc `[]`*(x: MeshTexcoords, i: int): Vector2 =
  checkArrayAccess(Mesh(x).texcoords, i, Mesh(x).vertexCount)
  result = cast[ptr UncheckedArray[Vector2]](Mesh(x).texcoords)[i]

proc `[]`*(x: var MeshTexcoords, i: int): var Vector2 =
  checkArrayAccess(Mesh(x).texcoords, i, Mesh(x).vertexCount)
  result = cast[ptr UncheckedArray[Vector2]](Mesh(x).texcoords)[i]

proc `[]=`*(x: var MeshTexcoords, i: int, val: Vector2) =
  checkArrayAccess(Mesh(x).texcoords, i, Mesh(x).vertexCount)
  cast[ptr UncheckedArray[Vector2]](Mesh(x).texcoords)[i] = val

template texcoords2*(x: Mesh): MeshTexcoords2 = MeshTexcoords2(x)

proc `[]`*(x: MeshTexcoords2, i: int): Vector2 =
  checkArrayAccess(Mesh(x).texcoords2, i, Mesh(x).vertexCount)
  result = cast[ptr UncheckedArray[Vector2]](Mesh(x).texcoords2)[i]

proc `[]`*(x: var MeshTexcoords2, i: int): var Vector2 =
  checkArrayAccess(Mesh(x).texcoords2, i, Mesh(x).vertexCount)
  result = cast[ptr UncheckedArray[Vector2]](Mesh(x).texcoords2)[i]

proc `[]=`*(x: var MeshTexcoords2, i: int, val: Vector2) =
  checkArrayAccess(Mesh(x).texcoords2, i, Mesh(x).vertexCount)
  cast[ptr UncheckedArray[Vector2]](Mesh(x).texcoords2)[i] = val

template normals*(x: Mesh): MeshNormals = MeshNormals(x)

proc `[]`*(x: MeshNormals, i: int): Vector3 =
  checkArrayAccess(Mesh(x).normals, i, Mesh(x).vertexCount)
  result = cast[ptr UncheckedArray[Vector3]](Mesh(x).normals)[i]

proc `[]`*(x: var MeshNormals, i: int): var Vector3 =
  checkArrayAccess(Mesh(x).normals, i, Mesh(x).vertexCount)
  result = cast[ptr UncheckedArray[Vector3]](Mesh(x).normals)[i]

proc `[]=`*(x: var MeshNormals, i: int, val: Vector3) =
  checkArrayAccess(Mesh(x).normals, i, Mesh(x).vertexCount)
  cast[ptr UncheckedArray[Vector3]](Mesh(x).normals)[i] = val

template tangents*(x: Mesh): MeshTangents = MeshTangents(x)

proc `[]`*(x: MeshTangents, i: int): Vector4 =
  checkArrayAccess(Mesh(x).tangents, i, Mesh(x).vertexCount)
  result = cast[ptr UncheckedArray[Vector4]](Mesh(x).tangents)[i]

proc `[]`*(x: var MeshTangents, i: int): var Vector4 =
  checkArrayAccess(Mesh(x).tangents, i, Mesh(x).vertexCount)
  result = cast[ptr UncheckedArray[Vector4]](Mesh(x).tangents)[i]

proc `[]=`*(x: var MeshTangents, i: int, val: Vector4) =
  checkArrayAccess(Mesh(x).tangents, i, Mesh(x).vertexCount)
  cast[ptr UncheckedArray[Vector4]](Mesh(x).tangents)[i] = val

template colors*(x: Mesh): MeshColors = MeshColors(x)

proc `[]`*(x: MeshColors, i: int): Color =
  checkArrayAccess(Mesh(x).colors, i, Mesh(x).vertexCount)
  result = cast[ptr UncheckedArray[Color]](Mesh(x).colors)[i]

proc `[]`*(x: var MeshColors, i: int): var Color =
  checkArrayAccess(Mesh(x).colors, i, Mesh(x).vertexCount)
  result = cast[ptr UncheckedArray[Color]](Mesh(x).colors)[i]

proc `[]=`*(x: var MeshColors, i: int, val: Color) =
  checkArrayAccess(Mesh(x).colors, i, Mesh(x).vertexCount)
  cast[ptr UncheckedArray[Color]](Mesh(x).colors)[i] = val

template indices*(x: Mesh): MeshIndices = MeshIndices(x)

proc `[]`*(x: MeshIndices, i: int): array[3, uint16] =
  checkArrayAccess(Mesh(x).indices, i, Mesh(x).triangleCount)
  result = cast[ptr UncheckedArray[typeof(result)]](Mesh(x).indices)[i]

proc `[]`*(x: var MeshIndices, i: int): var array[3, uint16] =
  checkArrayAccess(Mesh(x).indices, i, Mesh(x).triangleCount)
  result = cast[ptr UncheckedArray[typeof(result)]](Mesh(x).indices)[i]

proc `[]=`*(x: var MeshIndices, i: int, val: array[3, uint16]) =
  checkArrayAccess(Mesh(x).indices, i, Mesh(x).triangleCount)
  cast[ptr UncheckedArray[typeof(val)]](Mesh(x).indices)[i] = val

template animVertices*(x: Mesh): MeshAnimVertices = MeshAnimVertices(x)

proc `[]`*(x: MeshAnimVertices, i: int): Vector3 =
  checkArrayAccess(Mesh(x).animVertices, i, Mesh(x).vertexCount)
  result = cast[ptr UncheckedArray[Vector3]](Mesh(x).animVertices)[i]

proc `[]`*(x: var MeshAnimVertices, i: int): var Vector3 =
  checkArrayAccess(Mesh(x).animVertices, i, Mesh(x).vertexCount)
  result = cast[ptr UncheckedArray[Vector3]](Mesh(x).animVertices)[i]

proc `[]=`*(x: var MeshAnimVertices, i: int, val: Vector3) =
  checkArrayAccess(Mesh(x).animVertices, i, Mesh(x).vertexCount)
  cast[ptr UncheckedArray[Vector3]](Mesh(x).animVertices)[i] = val

template animNormals*(x: Mesh): MeshAnimNormals = MeshAnimNormals(x)

proc `[]`*(x: MeshAnimNormals, i: int): Vector3 =
  checkArrayAccess(Mesh(x).animNormals, i, Mesh(x).vertexCount)
  result = cast[ptr UncheckedArray[Vector3]](Mesh(x).animNormals)[i]

proc `[]`*(x: var MeshAnimNormals, i: int): var Vector3 =
  checkArrayAccess(Mesh(x).animNormals, i, Mesh(x).vertexCount)
  result = cast[ptr UncheckedArray[Vector3]](Mesh(x).animNormals)[i]

proc `[]=`*(x: var MeshAnimNormals, i: int, val: Vector3) =
  checkArrayAccess(Mesh(x).animNormals, i, Mesh(x).vertexCount)
  cast[ptr UncheckedArray[Vector3]](Mesh(x).animNormals)[i] = val

template boneIds*(x: Mesh): MeshBoneIds = MeshBoneIds(x)

proc `[]`*(x: MeshBoneIds, i: int): array[4, uint8] =
  checkArrayAccess(Mesh(x).boneIds, i, Mesh(x).vertexCount)
  result = cast[ptr UncheckedArray[typeof(result)]](Mesh(x).boneIds)[i]

proc `[]`*(x: var MeshBoneIds, i: int): var array[4, uint8] =
  checkArrayAccess(Mesh(x).boneIds, i, Mesh(x).vertexCount)
  result = cast[ptr UncheckedArray[typeof(result)]](Mesh(x).boneIds)[i]

proc `[]=`*(x: var MeshBoneIds, i: int, val: array[4, uint8]) =
  checkArrayAccess(Mesh(x).boneIds, i, Mesh(x).vertexCount)
  cast[ptr UncheckedArray[typeof(val)]](Mesh(x).boneIds)[i] = val

template boneWeights*(x: Mesh): MeshBoneWeights = MeshBoneWeights(x)

proc `[]`*(x: MeshBoneWeights, i: int): Vector4 =
  checkArrayAccess(Mesh(x).boneWeights, i, Mesh(x).vertexCount)
  result = cast[ptr UncheckedArray[Vector4]](Mesh(x).boneWeights)[i]

proc `[]`*(x: var MeshBoneWeights, i: int): var Vector4 =
  checkArrayAccess(Mesh(x).boneWeights, i, Mesh(x).vertexCount)
  result = cast[ptr UncheckedArray[Vector4]](Mesh(x).boneWeights)[i]

proc `[]=`*(x: var MeshBoneWeights, i: int, val: Vector4) =
  checkArrayAccess(Mesh(x).boneWeights, i, Mesh(x).vertexCount)
  cast[ptr UncheckedArray[Vector4]](Mesh(x).boneWeights)[i] = val

template vboId*(x: Mesh): MeshVboId = MeshVboId(x)

proc `[]`*(x: MeshVboId, i: int): uint32 =
  checkArrayAccess(Mesh(x).vboId, i, MaxMeshVertexBuffers)
  result = Mesh(x).vboId[i]

proc `[]`*(x: var MeshVboId, i: int): var uint32 =
  checkArrayAccess(Mesh(x).vboId, i, MaxMeshVertexBuffers)
  result = Mesh(x).vboId[i]

proc `[]=`*(x: var MeshVboId, i: int, val: uint32) =
  checkArrayAccess(Mesh(x).vboId, i, MaxMeshVertexBuffers)
  Mesh(x).vboId[i] = val

template locs*(x: Shader): ShaderLocs = ShaderLocs(x)

proc `[]`*(x: ShaderLocs, i: ShaderLocationIndex): int32 =
  checkArrayAccess(Shader(x).locs, i, MaxShaderLocations)
  result = Shader(x).locs[i.int]

proc `[]`*(x: var ShaderLocs, i: ShaderLocationIndex): var int32 =
  checkArrayAccess(Shader(x).locs, i, MaxShaderLocations)
  result = Shader(x).locs[i.int]

proc `[]=`*(x: var ShaderLocs, i: ShaderLocationIndex, val: int32) =
  checkArrayAccess(Shader(x).locs, i, MaxShaderLocations)
  Shader(x).locs[i.int] = val

template maps*(x: Material): MaterialMaps = MaterialMaps(x)

proc `[]`*(x: MaterialMaps, i: MaterialMapIndex): lent MaterialMap =
  checkArrayAccess(Material(x).maps, i, MaxMaterialMaps)
  result = Material(x).maps[i.int]

proc `[]`*(x: var MaterialMaps, i: MaterialMapIndex): var MaterialMap =
  checkArrayAccess(Material(x).maps, i, MaxMaterialMaps)
  result = Material(x).maps[i.int]

proc `[]=`*(x: var MaterialMaps, i: MaterialMapIndex, val: MaterialMap) =
  checkArrayAccess(Material(x).maps, i, MaxMaterialMaps)
  Material(x).maps[i.int] = val

template meshes*(x: Model): ModelMeshes = ModelMeshes(x)

proc `[]`*(x: ModelMeshes, i: int): lent Mesh =
  checkArrayAccess(Model(x).meshes, i, Model(x).meshCount)
  result = Model(x).meshes[i]

proc `[]`*(x: var ModelMeshes, i: int): var Mesh =
  checkArrayAccess(Model(x).meshes, i, Model(x).meshCount)
  result = Model(x).meshes[i]

proc `[]=`*(x: var ModelMeshes, i: int, val: Mesh) =
  checkArrayAccess(Model(x).meshes, i, Model(x).meshCount)
  Model(x).meshes[i] = val

template materials*(x: Model): ModelMaterials = ModelMaterials(x)

proc `[]`*(x: ModelMaterials, i: int): lent Material =
  checkArrayAccess(Model(x).materials, i, Model(x).materialCount)
  result = Model(x).materials[i]

proc `[]`*(x: var ModelMaterials, i: int): var Material =
  checkArrayAccess(Model(x).materials, i, Model(x).materialCount)
  result = Model(x).materials[i]

proc `[]=`*(x: var ModelMaterials, i: int, val: Material) =
  checkArrayAccess(Model(x).materials, i, Model(x).materialCount)
  Model(x).materials[i] = val

template meshMaterial*(x: Model): ModelMeshMaterial = ModelMeshMaterial(x)

proc `[]`*(x: ModelMeshMaterial, i: int): int32 =
  checkArrayAccess(Model(x).meshMaterial, i, Model(x).meshCount)
  result = Model(x).meshMaterial[i]

proc `[]`*(x: var ModelMeshMaterial, i: int): var int32 =
  checkArrayAccess(Model(x).meshMaterial, i, Model(x).meshCount)
  result = Model(x).meshMaterial[i]

proc `[]=`*(x: var ModelMeshMaterial, i: int, val: int32) =
  checkArrayAccess(Model(x).meshMaterial, i, Model(x).meshCount)
  Model(x).meshMaterial[i] = val

template bones*(x: Model): ModelBones = ModelBones(x)

proc `[]`*(x: ModelBones, i: int): lent BoneInfo =
  checkArrayAccess(Model(x).bones, i, Model(x).boneCount)
  result = Model(x).bones[i]

proc `[]`*(x: var ModelBones, i: int): var BoneInfo =
  checkArrayAccess(Model(x).bones, i, Model(x).boneCount)
  result = Model(x).bones[i]

proc `[]=`*(x: var ModelBones, i: int, val: BoneInfo) =
  checkArrayAccess(Model(x).bones, i, Model(x).boneCount)
  Model(x).bones[i] = val

template bindPose*(x: Model): ModelBindPose = ModelBindPose(x)

proc `[]`*(x: ModelBindPose, i: int): lent Transform =
  checkArrayAccess(Model(x).bindPose, i, Model(x).boneCount)
  result = Model(x).bindPose[i]

proc `[]`*(x: var ModelBindPose, i: int): var Transform =
  checkArrayAccess(Model(x).bindPose, i, Model(x).boneCount)
  result = Model(x).bindPose[i]

proc `[]=`*(x: var ModelBindPose, i: int, val: Transform) =
  checkArrayAccess(Model(x).bindPose, i, Model(x).boneCount)
  Model(x).bindPose[i] = val

template bones*(x: ModelAnimation): ModelAnimationBones = ModelAnimationBones(x)

proc `[]`*(x: ModelAnimationBones, i: int): lent BoneInfo =
  checkArrayAccess(ModelAnimation(x).bones, i, ModelAnimation(x).boneCount)
  result = ModelAnimation(x).bones[i]

proc `[]`*(x: var ModelAnimationBones, i: int): var BoneInfo =
  checkArrayAccess(ModelAnimation(x).bones, i, ModelAnimation(x).boneCount)
  result = ModelAnimation(x).bones[i]

proc `[]=`*(x: var ModelAnimationBones, i: int, val: BoneInfo) =
  checkArrayAccess(ModelAnimation(x).bones, i, ModelAnimation(x).boneCount)
  ModelAnimation(x).bones[i] = val

template framePoses*(x: ModelAnimation): ModelAnimationFramePoses = ModelAnimationFramePoses(x)

proc `[]`*(x: ModelAnimationFramePoses; i, j: int): lent Transform =
  checkArrayAccess(ModelAnimation(x).framePoses, i, ModelAnimation(x).frameCount)
  checkArrayAccess(ModelAnimation(x).framePoses[i], j, ModelAnimation(x).boneCount)
  result = ModelAnimation(x).framePoses[i][j]

proc `[]`*(x: var ModelAnimationFramePoses; i, j: int): var Transform =
  checkArrayAccess(ModelAnimation(x).framePoses, i, ModelAnimation(x).frameCount)
  checkArrayAccess(ModelAnimation(x).framePoses[i], j, ModelAnimation(x).boneCount)
  result = ModelAnimation(x).framePoses[i][j]

proc `[]=`*(x: var ModelAnimationFramePoses; i, j: int, val: Transform) =
  checkArrayAccess(ModelAnimation(x).framePoses, i, ModelAnimation(x).frameCount)
  checkArrayAccess(ModelAnimation(x).framePoses[i], j, ModelAnimation(x).boneCount)
  ModelAnimation(x).framePoses[i][j] = val
