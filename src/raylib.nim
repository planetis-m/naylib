from std/strutils import addf, toHex
from std/unicode import Rune
from std/syncio import writeFile
import std/[assertions, paths]
const raylibDir = currentSourcePath().Path.parentDir / Path"raylib"

{.passC: "-I" & raylibDir.string.}
{.passC: "-I" & string(raylibDir / Path"external/glfw/include").}
{.passC: "-I" & string(raylibDir / Path"external/glfw/deps/mingw").}
{.passC: "-Wall -D_GNU_SOURCE -Wno-missing-braces -Werror=pointer-arith".}
when defined(emscripten):
  {.passC: "-DPLATFORM_WEB".}
  when defined(GraphicsApiOpenGlEs3):
    {.passC: "-DGRAPHICS_API_OPENGL_ES3".}
    {.passL: "-sFULL_ES3 -sMAX_WEBGL_VERSION=2".}
  else: {.passC: "-DGRAPHICS_API_OPENGL_ES2".}
  {.passL: "-sUSE_GLFW=3 -sWASM=1 -sTOTAL_MEMORY=67108864".} # 64MiB
  {.passL: "-sEXPORTED_RUNTIME_METHODS=ccall".}
  when compileOption("threads"):
    const NaylibWebPthreadPoolSize {.intdefine.} = 2
    {.passL: "-sPTHREAD_POOL_SIZE=" & $NaylibWebPthreadPoolSize.}
  when defined(NaylibWebAsyncify): {.passL: "-sASYNCIFY".}
  when defined(NaylibWebResources):
    const NaylibWebResourcesPath {.strdefine.} = "resources"
    {.passL: "-sFORCE_FILESYSTEM=1 --preload-file " & NaylibWebResourcesPath.}

  type emCallbackFunc* = proc() {.cdecl.}
  proc emscriptenSetMainLoop*(f: emCallbackFunc, fps, simulateInfiniteLoop: int32) {.
      cdecl, importc: "emscripten_set_main_loop", header: "<emscripten.h>".}

elif defined(android):
  const AndroidNdk {.strdefine.} = "/opt/android-ndk"
  const ProjectLibraryName = "main"
  {.passC: "-I" & string(AndroidNdk.Path / Path"sources/android/native_app_glue").}

  {.passC: "-DPLATFORM_ANDROID".}
  when defined(GraphicsApiOpenGlEs3): {.passC: "-DGRAPHICS_API_OPENGL_ES3".}
  else: {.passC: "-DGRAPHICS_API_OPENGL_ES2".}
  {.passC: "-ffunction-sections -funwind-tables -fstack-protector-strong -fPIE -fPIC".}
  {.passC: "-Wa,--noexecstack -Wformat -no-canonical-prefixes".}

  {.passL: "-Wl,-soname,lib" & ProjectLibraryName & ".so -Wl,--exclude-libs,libatomic.a".}
  {.passL: "-Wl,--build-id -Wl,-z,noexecstack -Wl,-z,relro -Wl,-z,now -Wl,--warn-shared-textrel".}
  {.passL: "-Wl,--fatal-warnings -u ANativeActivity_onCreate -Wl,-no-undefined".}
  {.passL: "-llog -landroid -lEGL -lGLESv2 -lOpenSLES -lc -lm -ldl".}

else:
  {.passC: "-DPLATFORM_DESKTOP_GLFW".}
  when defined(GraphicsApiOpenGl11): {.passC: "-DGRAPHICS_API_OPENGL_11".}
  elif defined(GraphicsApiOpenGl21): {.passC: "-DGRAPHICS_API_OPENGL_21".}
  elif defined(GraphicsApiOpenGl43): {.passC: "-DGRAPHICS_API_OPENGL_43".}
  elif defined(GraphicsApiOpenGlEs2): {.passC: "-DGRAPHICS_API_OPENGL_ES2".}
  elif defined(GraphicsApiOpenGlEs3): {.passC: "-DGRAPHICS_API_OPENGL_ES3".}
  else: {.passC: "-DGRAPHICS_API_OPENGL_33".}

  when defined(windows):
    when defined(tcc): {.passL: "-lopengl32 -lgdi32 -lwinmm -lshell32".}
    else: {.passL: "-static-libgcc -lopengl32 -lgdi32 -lwinmm".}

  elif defined(macosx):
    {.passL: "-framework OpenGL -framework Cocoa -framework IOKit -framework CoreAudio -framework CoreVideo".}

  elif defined(drm):
    {.passC: staticExec("pkg-config libdrm --cflags").}
    {.passC: "-DPLATFORM_DRM -DGRAPHICS_API_OPENGL_ES2 -DEGL_NO_X11".}
    # pkg-config glesv2 egl libdrm gbm --libs
    # nanosleep: -lrt, miniaudio linux 32bit ARM: -ldl -lpthread -lm -latomic
    {.passL: "-lGLESv2 -lEGL -ldrm -lgbm -lrt -ldl -lpthread -lm -latomic".}

  else:
    when defined(linux):
      {.passC: "-fPIC".}
      {.passL: "-lGL -lrt -lm -lpthread -ldl".} # pkg-config gl --libs, nanosleep, miniaudio linux

    elif defined(bsd):
      {.passC: staticExec("pkg-config ossaudio --variable=includedir").}
      {.passL: "-lGL -lrt -lossaudio -lpthread -lm -ldl".} # pkg-config gl ossaudio --libs, nanosleep, miniaudio BSD

    when defined(wayland):
      {.passC: "-D_GLFW_WAYLAND".}
      # pkg-config wayland-client wayland-cursor wayland-egl xkbcommon --libs
      {.passL: "-lwayland-client -lwayland-cursor -lwayland-egl -lxkbcommon".}
      const wlProtocolsDir = raylibDir / Path"external/glfw/deps/wayland"

      proc wlGenerate(protocol: Path, basename: string) =
        discard staticExec("wayland-scanner client-header " & protocol.string & " " &
            string(raylibDir / Path(basename & ".h")))
        discard staticExec("wayland-scanner private-code " & protocol.string & " " &
            string(raylibDir / Path(basename & "-code.h")))

      static:
        wlGenerate(wlProtocolsDir / Path"wayland.xml", "wayland-client-protocol")
        wlGenerate(wlProtocolsDir / Path"xdg-shell.xml", "xdg-shell-client-protocol")
        wlGenerate(wlProtocolsDir / Path"xdg-decoration-unstable-v1.xml",
            "xdg-decoration-unstable-v1-client-protocol")
        wlGenerate(wlProtocolsDir / Path"viewporter.xml", "viewporter-client-protocol")
        wlGenerate(wlProtocolsDir / Path"relative-pointer-unstable-v1.xml",
            "relative-pointer-unstable-v1-client-protocol")
        wlGenerate(wlProtocolsDir / Path"pointer-constraints-unstable-v1.xml",
            "pointer-constraints-unstable-v1-client-protocol")
        wlGenerate(wlProtocolsDir / Path"fractional-scale-v1.xml", "fractional-scale-v1-client-protocol")
        wlGenerate(wlProtocolsDir / Path"xdg-activation-v1.xml", "xdg-activation-v1-client-protocol")
        wlGenerate(wlProtocolsDir / Path"idle-inhibit-unstable-v1.xml",
            "idle-inhibit-unstable-v1-client-protocol")

    else:
      {.passC: "-D_GLFW_X11".}
      # pkg-config x11 xrandr xinerama xi xcursor --libs
      {.passL: "-lX11 -lXrandr -lXinerama -lXi -lXcursor".}

when defined(emscripten): discard
elif defined(android): discard
elif defined(macosx): {.compile(raylibDir / Path"rglfw.c", "-x objective-c").}
else: {.compile: raylibDir / Path"rglfw.c".}
{.compile: raylibDir / Path"rshapes.c".}
{.compile: raylibDir / Path"rtextures.c".}
{.compile: raylibDir / Path"rtext.c".}
{.compile: raylibDir / Path"utils.c".}
{.compile: raylibDir / Path"rmodels.c".}
{.compile: raylibDir / Path"raudio.c".}
{.compile: raylibDir / Path"rcore.c".}
when defined(android):
  {.compile: AndroidNdk.Path / Path"sources/android/native_app_glue/android_native_app_glue.c".}

const
  RaylibVersion* = (5, 5, 0)

  # Taken from raylib/src/config.h
  MaxShaderLocations* = 32 ## Maximum number of shader locations supported
  MaxMaterialMaps* = 12 ## Maximum number of shader maps supported
  MaxMeshVertexBuffers* = 9 ## Maximum vertex buffers (VBO) per mesh

type
  ConfigFlags* {.size: sizeof(int32).} = enum ## System/Window config flags
    FullscreenMode = 2 ## Set to run program in fullscreen
    WindowResizable = 4 ## Set to allow resizable window
    WindowUndecorated = 8 ## Set to disable window decoration (frame and buttons)
    WindowTransparent = 16 ## Set to allow transparent framebuffer
    Msaa4xHint = 32 ## Set to try enabling MSAA 4X
    VsyncHint = 64 ## Set to try enabling V-Sync on GPU
    WindowHidden = 128 ## Set to hide window
    WindowAlwaysRun = 256 ## Set to allow windows running while minimized
    WindowMinimized = 512 ## Set to minimize window (iconify)
    WindowMaximized = 1024 ## Set to maximize window (expanded to monitor)
    WindowUnfocused = 2048 ## Set to window non focused
    WindowTopmost = 4096 ## Set to window always on top
    WindowHighdpi = 8192 ## Set to support HighDPI
    WindowMousePassthrough = 16384 ## Set to support mouse passthrough, only supported when FLAG_WINDOW_UNDECORATED
    BorderlessWindowedMode = 32768 ## Set to run program in borderless windowed mode
    InterlacedHint = 65536 ## Set to try enabling interlaced video format (for V3D)

  TraceLogLevel* {.size: sizeof(int32).} = enum ## Trace log level
    All ## Display all logs
    Trace ## Trace logging, intended for internal use only
    Debug ## Debug logging, used for internal debugging, it should be disabled on release builds
    Info ## Info logging, used for program execution info
    Warning ## Warning logging, used on recoverable failures
    Error ## Error logging, used on unrecoverable failures
    Fatal ## Fatal logging, used to abort program: exit(EXIT_FAILURE)
    None ## Disable logging

  KeyboardKey* {.size: sizeof(int32).} = enum ## Keyboard keys (US keyboard layout)
    Null ## Key: NULL, used for no key pressed
    Back = 4 ## Key: Android back button
    Menu ## Key: Android menu button
    VolumeUp = 24 ## Key: Android volume up button
    VolumeDown ## Key: Android volume down button
    Space = 32 ## Key: Space
    Apostrophe = 39 ## Key: '
    Comma = 44 ## Key: ,
    Minus ## Key: -
    Period ## Key: .
    Slash ## Key: /
    Zero ## Key: 0
    One ## Key: 1
    Two ## Key: 2
    Three ## Key: 3
    Four ## Key: 4
    Five ## Key: 5
    Six ## Key: 6
    Seven ## Key: 7
    Eight ## Key: 8
    Nine ## Key: 9
    Semicolon = 59 ## Key: ;
    Equal = 61 ## Key: =
    A = 65 ## Key: A | a
    B ## Key: B | b
    C ## Key: C | c
    D ## Key: D | d
    E ## Key: E | e
    F ## Key: F | f
    G ## Key: G | g
    H ## Key: H | h
    I ## Key: I | i
    J ## Key: J | j
    K ## Key: K | k
    L ## Key: L | l
    M ## Key: M | m
    N ## Key: N | n
    O ## Key: O | o
    P ## Key: P | p
    Q ## Key: Q | q
    R ## Key: R | r
    S ## Key: S | s
    T ## Key: T | t
    U ## Key: U | u
    V ## Key: V | v
    W ## Key: W | w
    X ## Key: X | x
    Y ## Key: Y | y
    Z ## Key: Z | z
    LeftBracket ## Key: [
    Backslash ## Key: '\'
    RightBracket ## Key: ]
    Grave = 96 ## Key: `
    Escape = 256 ## Key: Esc
    Enter ## Key: Enter
    Tab ## Key: Tab
    Backspace ## Key: Backspace
    Insert ## Key: Ins
    Delete ## Key: Del
    Right ## Key: Cursor right
    Left ## Key: Cursor left
    Down ## Key: Cursor down
    Up ## Key: Cursor up
    PageUp ## Key: Page up
    PageDown ## Key: Page down
    Home ## Key: Home
    End ## Key: End
    CapsLock = 280 ## Key: Caps lock
    ScrollLock ## Key: Scroll down
    NumLock ## Key: Num lock
    PrintScreen ## Key: Print screen
    Pause ## Key: Pause
    F1 = 290 ## Key: F1
    F2 ## Key: F2
    F3 ## Key: F3
    F4 ## Key: F4
    F5 ## Key: F5
    F6 ## Key: F6
    F7 ## Key: F7
    F8 ## Key: F8
    F9 ## Key: F9
    F10 ## Key: F10
    F11 ## Key: F11
    F12 ## Key: F12
    Kp0 = 320 ## Key: Keypad 0
    Kp1 ## Key: Keypad 1
    Kp2 ## Key: Keypad 2
    Kp3 ## Key: Keypad 3
    Kp4 ## Key: Keypad 4
    Kp5 ## Key: Keypad 5
    Kp6 ## Key: Keypad 6
    Kp7 ## Key: Keypad 7
    Kp8 ## Key: Keypad 8
    Kp9 ## Key: Keypad 9
    KpDecimal ## Key: Keypad .
    KpDivide ## Key: Keypad /
    KpMultiply ## Key: Keypad *
    KpSubtract ## Key: Keypad -
    KpAdd ## Key: Keypad +
    KpEnter ## Key: Keypad Enter
    KpEqual ## Key: Keypad =
    LeftShift = 340 ## Key: Shift left
    LeftControl ## Key: Control left
    LeftAlt ## Key: Alt left
    LeftSuper ## Key: Super left
    RightShift ## Key: Shift right
    RightControl ## Key: Control right
    RightAlt ## Key: Alt right
    RightSuper ## Key: Super right
    KbMenu ## Key: KB menu

  MouseButton* {.size: sizeof(int32).} = enum ## Mouse buttons
    Left ## Mouse button left
    Right ## Mouse button right
    Middle ## Mouse button middle (pressed wheel)
    Side ## Mouse button side (advanced mouse device)
    Extra ## Mouse button extra (advanced mouse device)
    Forward ## Mouse button forward (advanced mouse device)
    Back ## Mouse button back (advanced mouse device)

  MouseCursor* {.size: sizeof(int32).} = enum ## Mouse cursor
    Default ## Default pointer shape
    Arrow ## Arrow shape
    Ibeam ## Text writing cursor shape
    Crosshair ## Cross shape
    PointingHand ## Pointing hand cursor
    ResizeEw ## Horizontal resize/move arrow shape
    ResizeNs ## Vertical resize/move arrow shape
    ResizeNwse ## Top-left to bottom-right diagonal resize/move arrow shape
    ResizeNesw ## The top-right to bottom-left diagonal resize/move arrow shape
    ResizeAll ## The omnidirectional resize/move cursor shape
    NotAllowed ## The operation-not-allowed shape

  GamepadButton* {.size: sizeof(int32).} = enum ## Gamepad buttons
    Unknown ## Unknown button, just for error checking
    LeftFaceUp ## Gamepad left DPAD up button
    LeftFaceRight ## Gamepad left DPAD right button
    LeftFaceDown ## Gamepad left DPAD down button
    LeftFaceLeft ## Gamepad left DPAD left button
    RightFaceUp ## Gamepad right button up (i.e. PS3: Triangle, Xbox: Y)
    RightFaceRight ## Gamepad right button right (i.e. PS3: Circle, Xbox: B)
    RightFaceDown ## Gamepad right button down (i.e. PS3: Cross, Xbox: A)
    RightFaceLeft ## Gamepad right button left (i.e. PS3: Square, Xbox: X)
    LeftTrigger1 ## Gamepad top/back trigger left (first), it could be a trailing button
    LeftTrigger2 ## Gamepad top/back trigger left (second), it could be a trailing button
    RightTrigger1 ## Gamepad top/back trigger right (first), it could be a trailing button
    RightTrigger2 ## Gamepad top/back trigger right (second), it could be a trailing button
    MiddleLeft ## Gamepad center buttons, left one (i.e. PS3: Select)
    Middle ## Gamepad center buttons, middle one (i.e. PS3: PS, Xbox: XBOX)
    MiddleRight ## Gamepad center buttons, right one (i.e. PS3: Start)
    LeftThumb ## Gamepad joystick pressed button left
    RightThumb ## Gamepad joystick pressed button right

  GamepadAxis* {.size: sizeof(int32).} = enum ## Gamepad axis
    LeftX ## Gamepad left stick X axis
    LeftY ## Gamepad left stick Y axis
    RightX ## Gamepad right stick X axis
    RightY ## Gamepad right stick Y axis
    LeftTrigger ## Gamepad back trigger left, pressure level: [1..-1]
    RightTrigger ## Gamepad back trigger right, pressure level: [1..-1]

  MaterialMapIndex* {.size: sizeof(int32).} = enum ## Material map index
    Albedo ## Albedo material (same as: MATERIAL_MAP_DIFFUSE)
    Metalness ## Metalness material (same as: MATERIAL_MAP_SPECULAR)
    Normal ## Normal material
    Roughness ## Roughness material
    Occlusion ## Ambient occlusion material
    Emission ## Emission material
    Height ## Heightmap material
    Cubemap ## Cubemap material (NOTE: Uses GL_TEXTURE_CUBE_MAP)
    Irradiance ## Irradiance material (NOTE: Uses GL_TEXTURE_CUBE_MAP)
    Prefilter ## Prefilter material (NOTE: Uses GL_TEXTURE_CUBE_MAP)
    Brdf ## Brdf material

  ShaderLocationIndex* {.size: sizeof(int32).} = enum ## Shader location index
    VertexPosition ## Shader location: vertex attribute: position
    VertexTexcoord01 ## Shader location: vertex attribute: texcoord01
    VertexTexcoord02 ## Shader location: vertex attribute: texcoord02
    VertexNormal ## Shader location: vertex attribute: normal
    VertexTangent ## Shader location: vertex attribute: tangent
    VertexColor ## Shader location: vertex attribute: color
    MatrixMvp ## Shader location: matrix uniform: model-view-projection
    MatrixView ## Shader location: matrix uniform: view (camera transform)
    MatrixProjection ## Shader location: matrix uniform: projection
    MatrixModel ## Shader location: matrix uniform: model (transform)
    MatrixNormal ## Shader location: matrix uniform: normal
    VectorView ## Shader location: vector uniform: view
    ColorDiffuse ## Shader location: vector uniform: diffuse color
    ColorSpecular ## Shader location: vector uniform: specular color
    ColorAmbient ## Shader location: vector uniform: ambient color
    MapAlbedo ## Shader location: sampler2d texture: albedo (same as: SHADER_LOC_MAP_DIFFUSE)
    MapMetalness ## Shader location: sampler2d texture: metalness (same as: SHADER_LOC_MAP_SPECULAR)
    MapNormal ## Shader location: sampler2d texture: normal
    MapRoughness ## Shader location: sampler2d texture: roughness
    MapOcclusion ## Shader location: sampler2d texture: occlusion
    MapEmission ## Shader location: sampler2d texture: emission
    MapHeight ## Shader location: sampler2d texture: height
    MapCubemap ## Shader location: samplerCube texture: cubemap
    MapIrradiance ## Shader location: samplerCube texture: irradiance
    MapPrefilter ## Shader location: samplerCube texture: prefilter
    MapBrdf ## Shader location: sampler2d texture: brdf
    VertexBoneids ## Shader location: vertex attribute: boneIds
    VertexBoneweights ## Shader location: vertex attribute: boneWeights
    BoneMatrices ## Shader location: array of matrices uniform: boneMatrices

  ShaderUniformDataType* {.size: sizeof(int32).} = enum ## Shader uniform data type
    Float ## Shader uniform type: float
    Vec2 ## Shader uniform type: vec2 (2 float)
    Vec3 ## Shader uniform type: vec3 (3 float)
    Vec4 ## Shader uniform type: vec4 (4 float)
    Int ## Shader uniform type: int
    Ivec2 ## Shader uniform type: ivec2 (2 int)
    Ivec3 ## Shader uniform type: ivec3 (3 int)
    Ivec4 ## Shader uniform type: ivec4 (4 int)
    Sampler2d ## Shader uniform type: sampler2d

  ShaderAttributeDataType* {.size: sizeof(int32).} = enum ## Shader attribute data types
    Float ## Shader attribute type: float
    Vec2 ## Shader attribute type: vec2 (2 float)
    Vec3 ## Shader attribute type: vec3 (3 float)
    Vec4 ## Shader attribute type: vec4 (4 float)

  PixelFormat* {.size: sizeof(int32).} = enum ## Pixel formats
    UncompressedGrayscale = 1 ## 8 bit per pixel (no alpha)
    UncompressedGrayAlpha ## 8*2 bpp (2 channels)
    UncompressedR5g6b5 ## 16 bpp
    UncompressedR8g8b8 ## 24 bpp
    UncompressedR5g5b5a1 ## 16 bpp (1 bit alpha)
    UncompressedR4g4b4a4 ## 16 bpp (4 bit alpha)
    UncompressedR8g8b8a8 ## 32 bpp
    UncompressedR32 ## 32 bpp (1 channel - float)
    UncompressedR32g32b32 ## 32*3 bpp (3 channels - float)
    UncompressedR32g32b32a32 ## 32*4 bpp (4 channels - float)
    UncompressedR16 ## 16 bpp (1 channel - half float)
    UncompressedR16g16b16 ## 16*3 bpp (3 channels - half float)
    UncompressedR16g16b16a16 ## 16*4 bpp (4 channels - half float)
    CompressedDxt1Rgb ## 4 bpp (no alpha)
    CompressedDxt1Rgba ## 4 bpp (1 bit alpha)
    CompressedDxt3Rgba ## 8 bpp
    CompressedDxt5Rgba ## 8 bpp
    CompressedEtc1Rgb ## 4 bpp
    CompressedEtc2Rgb ## 4 bpp
    CompressedEtc2EacRgba ## 8 bpp
    CompressedPvrtRgb ## 4 bpp
    CompressedPvrtRgba ## 4 bpp
    CompressedAstc4x4Rgba ## 8 bpp
    CompressedAstc8x8Rgba ## 2 bpp

  TextureFilter* {.size: sizeof(int32).} = enum ## Texture parameters: filter mode
    Point ## No filter, just pixel approximation
    Bilinear ## Linear filtering
    Trilinear ## Trilinear filtering (linear with mipmaps)
    Anisotropic4x ## Anisotropic filtering 4x
    Anisotropic8x ## Anisotropic filtering 8x
    Anisotropic16x ## Anisotropic filtering 16x

  TextureWrap* {.size: sizeof(int32).} = enum ## Texture parameters: wrap mode
    Repeat ## Repeats texture in tiled mode
    Clamp ## Clamps texture to edge pixel in tiled mode
    MirrorRepeat ## Mirrors and repeats the texture in tiled mode
    MirrorClamp ## Mirrors and clamps to border the texture in tiled mode

  CubemapLayout* {.size: sizeof(int32).} = enum ## Cubemap layouts
    AutoDetect ## Automatically detect layout type
    LineVertical ## Layout is defined by a vertical line with faces
    LineHorizontal ## Layout is defined by a horizontal line with faces
    CrossThreeByFour ## Layout is defined by a 3x4 cross with cubemap faces
    CrossFourByThree ## Layout is defined by a 4x3 cross with cubemap faces

  FontType* {.size: sizeof(int32).} = enum ## Font type, defines generation method
    Default ## Default font generation, anti-aliased
    Bitmap ## Bitmap font generation, no anti-aliasing
    Sdf ## SDF font generation, requires external shader

  BlendMode* {.size: sizeof(int32).} = enum ## Color blending modes (pre-defined)
    Alpha ## Blend textures considering alpha (default)
    Additive ## Blend textures adding colors
    Multiplied ## Blend textures multiplying colors
    AddColors ## Blend textures adding colors (alternative)
    SubtractColors ## Blend textures subtracting colors (alternative)
    AlphaPremultiply ## Blend premultiplied textures considering alpha
    Custom ## Blend textures using custom src/dst factors (use rlSetBlendFactors())
    CustomSeparate ## Blend textures using custom rgb/alpha separate src/dst factors (use rlSetBlendFactorsSeparate())

  Gesture* {.size: sizeof(int32).} = enum ## Gesture
    None ## No gesture
    Tap ## Tap gesture
    Doubletap ## Double tap gesture
    Hold = 4 ## Hold gesture
    Drag = 8 ## Drag gesture
    SwipeRight = 16 ## Swipe right gesture
    SwipeLeft = 32 ## Swipe left gesture
    SwipeUp = 64 ## Swipe up gesture
    SwipeDown = 128 ## Swipe down gesture
    PinchIn = 256 ## Pinch in gesture
    PinchOut = 512 ## Pinch out gesture

  CameraMode* {.size: sizeof(int32).} = enum ## Camera system modes
    Custom ## Camera custom, controlled by user (UpdateCamera() does nothing)
    Free ## Camera free mode
    Orbital ## Camera orbital, around target, zoom supported
    FirstPerson ## Camera first person
    ThirdPerson ## Camera third person

  CameraProjection* {.size: sizeof(int32).} = enum ## Camera projection
    Perspective ## Perspective projection
    Orthographic ## Orthographic projection

  NPatchLayout* {.size: sizeof(int32).} = enum ## N-patch layout
    NinePatch ## Npatch layout: 3x3 tiles
    ThreePatchVertical ## Npatch layout: 1x3 tiles
    ThreePatchHorizontal ## Npatch layout: 3x1 tiles

  ShaderLocation* = distinct int32 ## Shader location

  FlagsEnum = ConfigFlags|Gesture
  Flags*[E: FlagsEnum] = distinct uint32

proc flags*[E: FlagsEnum](e: varargs[E]): Flags[E] {.inline.} =
  var res: uint32 = 0
  for val in items(e):
    res = res or uint32(val)
  Flags[E](res)

template Diffuse*(_: typedesc[MaterialMapIndex]): untyped = Albedo
template Specular*(_: typedesc[MaterialMapIndex]): untyped = Metalness

template MapDiffuse*(_: typedesc[ShaderLocationIndex]): untyped = MapAlbedo
template MapSpecular*(_: typedesc[ShaderLocationIndex]): untyped = MapMetalness

type
  Vector2* {.importc, header: "naylib.h", completeStruct, bycopy.} = object ## Vector2, 2 components
    x*: float32 ## Vector x component
    y*: float32 ## Vector y component

  Vector3* {.importc, header: "naylib.h", completeStruct, bycopy.} = object ## Vector3, 3 components
    x*: float32 ## Vector x component
    y*: float32 ## Vector y component
    z*: float32 ## Vector z component

  Vector4* {.importc, header: "naylib.h", completeStruct, bycopy.} = object ## Vector4, 4 components
    x*: float32 ## Vector x component
    y*: float32 ## Vector y component
    z*: float32 ## Vector z component
    w*: float32 ## Vector w component

  Matrix* {.importc, header: "naylib.h", completeStruct, bycopy.} = object ## Matrix, 4x4 components, column major, OpenGL style, right-handed
    m0*, m4*, m8*, m12*: float32 ## Matrix first row (4 components)
    m1*, m5*, m9*, m13*: float32 ## Matrix second row (4 components)
    m2*, m6*, m10*, m14*: float32 ## Matrix third row (4 components)
    m3*, m7*, m11*, m15*: float32 ## Matrix fourth row (4 components)

  Color* {.importc, header: "naylib.h", completeStruct, bycopy.} = object ## Color, 4 components, R8G8B8A8 (32bit)
    r*: uint8 ## Color red value
    g*: uint8 ## Color green value
    b*: uint8 ## Color blue value
    a*: uint8 ## Color alpha value

  Rectangle* {.importc: "rlRectangle", header: "naylib.h", completeStruct, bycopy.} = object ## Rectangle, 4 components
    x*: float32 ## Rectangle top-left corner position x
    y*: float32 ## Rectangle top-left corner position y
    width*: float32 ## Rectangle width
    height*: float32 ## Rectangle height

  Image* {.importc, header: "naylib.h", completeStruct, bycopy.} = object ## Image, pixel data stored in CPU memory (RAM)
    data*: pointer ## Image raw data
    width*: int32 ## Image base width
    height*: int32 ## Image base height
    mipmaps*: int32 ## Mipmap levels, 1 by default
    format*: PixelFormat ## Data format (PixelFormat type)

  Texture* {.importc, header: "naylib.h", completeStruct, bycopy.} = object ## Texture, tex data stored in GPU memory (VRAM)
    id*: uint32 ## OpenGL texture id
    width*: int32 ## Texture base width
    height*: int32 ## Texture base height
    mipmaps*: int32 ## Mipmap levels, 1 by default
    format*: PixelFormat ## Data format (PixelFormat type)

  RenderTexture* {.importc, header: "naylib.h", completeStruct, bycopy.} = object ## RenderTexture, fbo for texture rendering
    id*: uint32 ## OpenGL framebuffer object id
    texture*: Texture ## Color buffer attachment texture
    depth*: Texture ## Depth buffer attachment texture

  NPatchInfo* {.importc, header: "naylib.h", completeStruct, bycopy.} = object ## NPatchInfo, n-patch layout info
    source*: Rectangle ## Texture source rectangle
    left*: int32 ## Left border offset
    top*: int32 ## Top border offset
    right*: int32 ## Right border offset
    bottom*: int32 ## Bottom border offset
    layout*: NPatchLayout ## Layout of the n-patch: 3x3, 1x3 or 3x1

  GlyphInfo* {.importc, header: "naylib.h", completeStruct, bycopy.} = object ## GlyphInfo, font characters glyphs info
    value*: int32 ## Character value (Unicode)
    offsetX*: int32 ## Character offset X when drawing
    offsetY*: int32 ## Character offset Y when drawing
    advanceX*: int32 ## Character advance position X
    image*: Image ## Character image data

  Font* {.importc, header: "naylib.h", completeStruct, bycopy.} = object ## Font, font texture and GlyphInfo array data
    baseSize*: int32 ## Base size (default chars height)
    glyphCount: int32 ## Number of glyph characters
    glyphPadding*: int32 ## Padding around the glyph characters
    texture*: Texture2D ## Texture atlas containing the glyphs
    recs: ptr UncheckedArray[Rectangle] ## Rectangles in texture for the glyphs
    glyphs: ptr UncheckedArray[GlyphInfo] ## Glyphs info data

  Camera3D* {.importc, header: "naylib.h", completeStruct, bycopy.} = object ## Camera, defines position/orientation in 3d space
    position*: Vector3 ## Camera position
    target*: Vector3 ## Camera target it looks-at
    up*: Vector3 ## Camera up vector (rotation over its axis)
    fovy*: float32 ## Camera field-of-view aperture in Y (degrees) in perspective, used as near plane width in orthographic
    projection*: CameraProjection ## Camera projection: CAMERA_PERSPECTIVE or CAMERA_ORTHOGRAPHIC

  Camera2D* {.importc, header: "naylib.h", completeStruct, bycopy.} = object ## Camera2D, defines position/orientation in 2d space
    offset*: Vector2 ## Camera offset (displacement from target)
    target*: Vector2 ## Camera target (rotation and zoom origin)
    rotation*: float32 ## Camera rotation in degrees
    zoom*: float32 ## Camera zoom (scaling), should be 1.0f by default

  Mesh* {.importc, header: "naylib.h", completeStruct, bycopy.} = object ## Mesh, vertex data and vao/vbo
    vertexCount: int32 ## Number of vertices stored in arrays
    triangleCount: int32 ## Number of triangles stored (indexed or not)
    vertices: ptr UncheckedArray[float32] ## Vertex position (XYZ - 3 components per vertex) (shader-location = 0)
    texcoords: ptr UncheckedArray[float32] ## Vertex texture coordinates (UV - 2 components per vertex) (shader-location = 1)
    texcoords2: ptr UncheckedArray[float32] ## Vertex texture second coordinates (UV - 2 components per vertex) (shader-location = 5)
    normals: ptr UncheckedArray[float32] ## Vertex normals (XYZ - 3 components per vertex) (shader-location = 2)
    tangents: ptr UncheckedArray[float32] ## Vertex tangents (XYZW - 4 components per vertex) (shader-location = 4)
    colors: ptr UncheckedArray[uint8] ## Vertex colors (RGBA - 4 components per vertex) (shader-location = 3)
    indices: ptr UncheckedArray[uint16] ## Vertex indices (in case vertex data comes indexed)
    animVertices: ptr UncheckedArray[float32] ## Animated vertex positions (after bones transformations)
    animNormals: ptr UncheckedArray[float32] ## Animated normals (after bones transformations)
    boneIds: ptr UncheckedArray[uint8] ## Vertex bone ids, max 255 bone ids, up to 4 bones influence by vertex (skinning) (shader-location = 6)
    boneWeights: ptr UncheckedArray[float32] ## Vertex bone weight, up to 4 bones influence by vertex (skinning) (shader-location = 7)
    boneMatrices: ptr UncheckedArray[Matrix] ## Bones animated transformation matrices
    boneCount: int32 ## Number of bones
    vaoId*: uint32 ## OpenGL Vertex Array Object id
    vboId: ptr UncheckedArray[uint32] ## OpenGL Vertex Buffer Objects id (default vertex data)

  Shader* {.importc, header: "naylib.h", completeStruct, bycopy.} = object ## Shader
    id*: uint32 ## Shader program id
    locs: ptr UncheckedArray[ShaderLocation] ## Shader locations array (RL_MAX_SHADER_LOCATIONS)

  MaterialMap* {.importc, header: "naylib.h", completeStruct, bycopy.} = object ## MaterialMap
    texture: Texture2D ## Material map texture
    color*: Color ## Material map color
    value*: float32 ## Material map value

  Material* {.importc, header: "naylib.h", completeStruct, bycopy.} = object ## Material, includes shader and maps
    shader: Shader ## Material shader
    maps: ptr UncheckedArray[MaterialMap] ## Material maps array (MAX_MATERIAL_MAPS)
    params*: array[4, float32] ## Material generic parameters (if required)

  Transform* {.importc, header: "naylib.h", completeStruct, bycopy.} = object ## Transform, vertex transformation data
    translation*: Vector3 ## Translation
    rotation*: Quaternion ## Rotation
    scale*: Vector3 ## Scale

  BoneInfo* {.importc, header: "naylib.h", completeStruct, bycopy.} = object ## Bone, skeletal animation bone
    name*: array[32, char] ## Bone name
    parent*: int32 ## Bone parent

  Model* {.importc, header: "naylib.h", completeStruct, bycopy.} = object ## Model, meshes, materials and animation data
    transform*: Matrix ## Local transform matrix
    meshCount: int32 ## Number of meshes
    materialCount: int32 ## Number of materials
    meshes: ptr UncheckedArray[Mesh] ## Meshes array
    materials: ptr UncheckedArray[Material] ## Materials array
    meshMaterial: ptr UncheckedArray[int32] ## Mesh material number
    boneCount: int32 ## Number of bones
    bones: ptr UncheckedArray[BoneInfo] ## Bones information (skeleton)
    bindPose: ptr UncheckedArray[Transform] ## Bones base transformation (pose)

  ModelAnimation* {.importc, header: "naylib.h", completeStruct, bycopy.} = object ## ModelAnimation
    boneCount: int32 ## Number of bones
    frameCount: int32 ## Number of animation frames
    bones: ptr UncheckedArray[BoneInfo] ## Bones information (skeleton)
    framePoses: ptr UncheckedArray[ptr UncheckedArray[Transform]] ## Poses array by frame
    name*: array[32, char] ## Animation name

  Ray* {.importc, header: "naylib.h", completeStruct, bycopy.} = object ## Ray, ray for raycasting
    position*: Vector3 ## Ray position (origin)
    direction*: Vector3 ## Ray direction (normalized)

  RayCollision* {.importc, header: "naylib.h", completeStruct, bycopy.} = object ## RayCollision, ray hit information
    hit*: bool ## Did the ray hit something?
    distance*: float32 ## Distance to the nearest hit
    point*: Vector3 ## Point of the nearest hit
    normal*: Vector3 ## Surface normal of hit

  BoundingBox* {.importc, header: "naylib.h", completeStruct, bycopy.} = object ## BoundingBox
    min*: Vector3 ## Minimum vertex box-corner
    max*: Vector3 ## Maximum vertex box-corner

  Wave* {.importc, header: "naylib.h", completeStruct, bycopy.} = object ## Wave, audio wave data
    frameCount*: uint32 ## Total number of frames (considering channels)
    sampleRate*: uint32 ## Frequency (samples per second)
    sampleSize*: uint32 ## Bit depth (bits per sample): 8, 16, 32 (24 not supported)
    channels*: uint32 ## Number of channels (1-mono, 2-stereo, ...)
    data*: pointer ## Buffer data pointer

  AudioStream* {.importc, header: "naylib.h", completeStruct, bycopy.} = object ## AudioStream, custom audio stream
    buffer: ptr rAudioBuffer ## Pointer to internal data used by the audio system
    processor: ptr rAudioProcessor ## Pointer to internal data processor, useful for audio effects
    sampleRate*: uint32 ## Frequency (samples per second)
    sampleSize*: uint32 ## Bit depth (bits per sample): 8, 16, 32 (24 not supported)
    channels*: uint32 ## Number of channels (1-mono, 2-stereo, ...)

  Sound* {.importc, header: "naylib.h", completeStruct, bycopy.} = object ## Sound
    stream*: AudioStream ## Audio stream
    frameCount*: uint32 ## Total number of frames (considering channels)

  Music* {.importc, header: "naylib.h", completeStruct, bycopy.} = object ## Music, audio stream, anything longer than ~10 seconds should be streamed
    stream*: AudioStream ## Audio stream
    frameCount*: uint32 ## Total number of frames (considering channels)
    looping*: bool ## Music looping enable
    ctxType*: int32 ## Type of music context (audio filetype)
    ctxData*: pointer ## Audio context data, depends on type

  VrDeviceInfo* {.importc, header: "naylib.h", completeStruct, bycopy.} = object ## VrDeviceInfo, Head-Mounted-Display device parameters
    hResolution*: int32 ## Horizontal resolution in pixels
    vResolution*: int32 ## Vertical resolution in pixels
    hScreenSize*: float32 ## Horizontal size in meters
    vScreenSize*: float32 ## Vertical size in meters
    eyeToScreenDistance*: float32 ## Distance between eye and display in meters
    lensSeparationDistance*: float32 ## Lens separation distance in meters
    interpupillaryDistance*: float32 ## IPD (distance between pupils) in meters
    lensDistortionValues*: array[4, float32] ## Lens distortion constant parameters
    chromaAbCorrection*: array[4, float32] ## Chromatic aberration correction parameters

  VrStereoConfig* {.importc, header: "naylib.h", completeStruct, bycopy.} = object ## VrStereoConfig, VR stereo rendering configuration for simulator
    projection*: array[2, Matrix] ## VR projection matrices (per eye)
    viewOffset*: array[2, Matrix] ## VR view offset matrices (per eye)
    leftLensCenter*: array[2, float32] ## VR left lens center
    rightLensCenter*: array[2, float32] ## VR right lens center
    leftScreenCenter*: array[2, float32] ## VR left screen center
    rightScreenCenter*: array[2, float32] ## VR right screen center
    scale*: array[2, float32] ## VR distortion scale
    scaleIn*: array[2, float32] ## VR distortion scale in

  FilePathList {.importc, header: "naylib.h", completeStruct, bycopy.} = object ## File path list
    capacity: uint32 ## Filepaths max entries
    count: uint32 ## Filepaths entries count
    paths: cstringArray ## Filepaths entries

  AutomationEvent* {.importc, header: "naylib.h", completeStruct, bycopy.} = object ## Automation event
    frame*: uint32 ## Event frame
    `type`*: uint32 ## Event type (AutomationEventType)
    params*: array[4, int32] ## Event parameters (if required)

  AutomationEventList* {.importc, header: "naylib.h", completeStruct, bycopy.} = object ## Automation event list
    capacity: uint32 ## Events max entries (MAX_AUTOMATION_EVENTS)
    count: uint32 ## Events entries count
    events: ptr UncheckedArray[AutomationEvent] ## Events entries

  Quaternion* {.borrow: `.`.} = distinct Vector4 ## Quaternion, 4 components (Vector4 alias)
  Texture2D* = Texture ## Texture2D, same as Texture
  TextureCubemap* = Texture ## TextureCubemap, same as Texture
  RenderTexture2D* = RenderTexture ## RenderTexture2D, same as RenderTexture
  Camera* = Camera3D ## Camera type fallback, defaults to Camera3D
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
  MeshBoneMatrices* = distinct Mesh
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

  rAudioBuffer {.importc, nodecl, bycopy.} = object
  rAudioProcessor {.importc, nodecl, bycopy.} = object

type va_list {.importc: "va_list", header: "<stdarg.h>".} = object ## Only used by TraceLogCallback
proc vsprintf(s: cstring, format: cstring, args: va_list) {.cdecl, importc: "vsprintf", header: "<stdio.h>".}

type
  ConstCstring {.importc: "const char *".} = cstring

## Callbacks to hook some internal functions
## WARNING: This callbacks are intended for advance users
type
  TraceLogCallbackImpl = proc (logLevel: int32; text: ConstCstring; args: va_list) {.
      cdecl.}
  LoadFileDataCallback* = proc (fileName: ConstCstring; bytesRead: ptr uint32): ptr UncheckedArray[uint8] {.
      cdecl.} ## FileIO: Load binary data
  SaveFileDataCallback* = proc (fileName: ConstCstring; data: pointer; bytesToWrite: uint32): bool {.
      cdecl.} ## FileIO: Save binary data
  LoadFileTextCallback* = proc (fileName: ConstCstring): cstring {.cdecl.} ## FileIO: Load text data
  SaveFileTextCallback* = proc (fileName: ConstCstring; text: cstring): bool {.cdecl.} ## FileIO: Save text data
  AudioCallback* = proc (bufferData: pointer, frames: uint32) {.cdecl.} ## Audio thread callback to request new data

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

{.push callconv: cdecl, header: "naylib.h".}
proc initWindowImpl(width: int32, height: int32, title: cstring) {.importc: "InitWindow", sideEffect.}
proc closeWindow*() {.importc: "rlCloseWindow", sideEffect.}
  ## Close window and unload OpenGL context
proc windowShouldClose*(): bool {.importc: "WindowShouldClose", sideEffect.}
  ## Check if application should close (KEY_ESCAPE pressed or windows close icon clicked)
proc isWindowReady*(): bool {.importc: "IsWindowReady", sideEffect.}
  ## Check if window has been initialized successfully
proc isWindowFullscreen*(): bool {.importc: "IsWindowFullscreen", sideEffect.}
  ## Check if window is currently fullscreen
proc isWindowHidden*(): bool {.importc: "IsWindowHidden", sideEffect.}
  ## Check if window is currently hidden
proc isWindowMinimized*(): bool {.importc: "IsWindowMinimized", sideEffect.}
  ## Check if window is currently minimized
proc isWindowMaximized*(): bool {.importc: "IsWindowMaximized", sideEffect.}
  ## Check if window is currently maximized
proc isWindowFocused*(): bool {.importc: "IsWindowFocused", sideEffect.}
  ## Check if window is currently focused
proc isWindowResized*(): bool {.importc: "IsWindowResized", sideEffect.}
  ## Check if window has been resized last frame
proc isWindowState*(flag: ConfigFlags): bool {.importc: "IsWindowState", sideEffect.}
  ## Check if one specific window flag is enabled
proc setWindowState*(flags: Flags[ConfigFlags]) {.importc: "SetWindowState", sideEffect.}
  ## Set window configuration state using flags
proc clearWindowState*(flags: Flags[ConfigFlags]) {.importc: "ClearWindowState", sideEffect.}
  ## Clear window configuration state flags
proc toggleFullscreen*() {.importc: "ToggleFullscreen", sideEffect.}
  ## Toggle window state: fullscreen/windowed, resizes monitor to match window resolution
proc toggleBorderlessWindowed*() {.importc: "ToggleBorderlessWindowed", sideEffect.}
  ## Toggle window state: borderless windowed, resizes window to match monitor resolution
proc maximizeWindow*() {.importc: "MaximizeWindow", sideEffect.}
  ## Set window state: maximized, if resizable
proc minimizeWindow*() {.importc: "MinimizeWindow", sideEffect.}
  ## Set window state: minimized, if resizable
proc restoreWindow*() {.importc: "RestoreWindow", sideEffect.}
  ## Set window state: not minimized/maximized
proc setWindowIcon*(image: Image) {.importc: "SetWindowIcon", sideEffect.}
  ## Set icon for window (single image, RGBA 32bit)
proc setWindowIconsImpl(images: ptr UncheckedArray[Image], count: int32) {.importc: "SetWindowIcons", sideEffect.}
proc setWindowTitleImpl(title: cstring) {.importc: "SetWindowTitle", sideEffect.}
proc setWindowPosition*(x: int32, y: int32) {.importc: "SetWindowPosition", sideEffect.}
  ## Set window position on screen
proc setWindowMonitor*(monitor: int32) {.importc: "SetWindowMonitor", sideEffect.}
  ## Set monitor for the current window
proc setWindowMinSize*(width: int32, height: int32) {.importc: "SetWindowMinSize", sideEffect.}
  ## Set window minimum dimensions (for FLAG_WINDOW_RESIZABLE)
proc setWindowMaxSize*(width: int32, height: int32) {.importc: "SetWindowMaxSize", sideEffect.}
  ## Set window maximum dimensions (for FLAG_WINDOW_RESIZABLE)
proc setWindowSize*(width: int32, height: int32) {.importc: "SetWindowSize", sideEffect.}
  ## Set window dimensions
proc setWindowOpacity*(opacity: float32) {.importc: "SetWindowOpacity", sideEffect.}
  ## Set window opacity [0.0f..1.0f]
proc setWindowFocused*() {.importc: "SetWindowFocused", sideEffect.}
  ## Set window focused
proc getWindowHandle*(): pointer {.importc: "GetWindowHandle", sideEffect.}
  ## Get native window handle
proc getScreenWidth*(): int32 {.importc: "GetScreenWidth", sideEffect.}
  ## Get current screen width
proc getScreenHeight*(): int32 {.importc: "GetScreenHeight", sideEffect.}
  ## Get current screen height
proc getRenderWidth*(): int32 {.importc: "GetRenderWidth", sideEffect.}
  ## Get current render width (it considers HiDPI)
proc getRenderHeight*(): int32 {.importc: "GetRenderHeight", sideEffect.}
  ## Get current render height (it considers HiDPI)
proc getMonitorCount*(): int32 {.importc: "GetMonitorCount", sideEffect.}
  ## Get number of connected monitors
proc getCurrentMonitor*(): int32 {.importc: "GetCurrentMonitor", sideEffect.}
  ## Get current monitor where window is placed
proc getMonitorPosition*(monitor: int32): Vector2 {.importc: "GetMonitorPosition", sideEffect.}
  ## Get specified monitor position
proc getMonitorWidth*(monitor: int32): int32 {.importc: "GetMonitorWidth", sideEffect.}
  ## Get specified monitor width (current video mode used by monitor)
proc getMonitorHeight*(monitor: int32): int32 {.importc: "GetMonitorHeight", sideEffect.}
  ## Get specified monitor height (current video mode used by monitor)
proc getMonitorPhysicalWidth*(monitor: int32): int32 {.importc: "GetMonitorPhysicalWidth", sideEffect.}
  ## Get specified monitor physical width in millimetres
proc getMonitorPhysicalHeight*(monitor: int32): int32 {.importc: "GetMonitorPhysicalHeight", sideEffect.}
  ## Get specified monitor physical height in millimetres
proc getMonitorRefreshRate*(monitor: int32): int32 {.importc: "GetMonitorRefreshRate", sideEffect.}
  ## Get specified monitor refresh rate
proc getWindowPosition*(): Vector2 {.importc: "GetWindowPosition", sideEffect.}
  ## Get window position XY on monitor
proc getWindowScaleDPI*(): Vector2 {.importc: "GetWindowScaleDPI", sideEffect.}
  ## Get window scale DPI factor
proc getMonitorNameImpl(monitor: int32): cstring {.importc: "GetMonitorName", sideEffect.}
proc setClipboardTextImpl(text: cstring) {.importc: "SetClipboardText", sideEffect.}
proc getClipboardTextImpl(): cstring {.importc: "GetClipboardText", sideEffect.}
proc enableEventWaiting*() {.importc: "EnableEventWaiting", sideEffect.}
  ## Enable waiting for events on EndDrawing(), no automatic event polling
proc disableEventWaiting*() {.importc: "DisableEventWaiting", sideEffect.}
  ## Disable waiting for events on EndDrawing(), automatic events polling
proc showCursor*() {.importc: "rlShowCursor", sideEffect.}
  ## Shows cursor
proc hideCursor*() {.importc: "HideCursor", sideEffect.}
  ## Hides cursor
proc isCursorHidden*(): bool {.importc: "IsCursorHidden", sideEffect.}
  ## Check if cursor is not visible
proc enableCursor*() {.importc: "EnableCursor", sideEffect.}
  ## Enables cursor (unlock cursor)
proc disableCursor*() {.importc: "DisableCursor", sideEffect.}
  ## Disables cursor (lock cursor)
proc isCursorOnScreen*(): bool {.importc: "IsCursorOnScreen", sideEffect.}
  ## Check if cursor is on the screen
proc clearBackground*(color: Color) {.importc: "ClearBackground", sideEffect.}
  ## Set background color (framebuffer clear color)
proc beginDrawing*() {.importc: "BeginDrawing", sideEffect.}
  ## Setup canvas (framebuffer) to start drawing
proc endDrawing*() {.importc: "EndDrawing", sideEffect.}
  ## End canvas drawing and swap buffers (double buffering)
proc beginMode2D*(camera: Camera2D) {.importc: "BeginMode2D", sideEffect.}
  ## Begin 2D mode with custom camera (2D)
proc endMode2D*() {.importc: "EndMode2D", sideEffect.}
  ## Ends 2D mode with custom camera
proc beginMode3D*(camera: Camera3D) {.importc: "BeginMode3D", sideEffect.}
  ## Begin 3D mode with custom camera (3D)
proc endMode3D*() {.importc: "EndMode3D", sideEffect.}
  ## Ends 3D mode and returns to default 2D orthographic mode
proc beginTextureMode*(target: RenderTexture2D) {.importc: "BeginTextureMode", sideEffect.}
  ## Begin drawing to render texture
proc endTextureMode*() {.importc: "EndTextureMode", sideEffect.}
  ## Ends drawing to render texture
proc beginShaderMode*(shader: Shader) {.importc: "BeginShaderMode", sideEffect.}
  ## Begin custom shader drawing
proc endShaderMode*() {.importc: "EndShaderMode", sideEffect.}
  ## End custom shader drawing (use default shader)
proc beginBlendMode*(mode: BlendMode) {.importc: "BeginBlendMode", sideEffect.}
  ## Begin blending mode (alpha, additive, multiplied, subtract, custom)
proc endBlendMode*() {.importc: "EndBlendMode", sideEffect.}
  ## End blending mode (reset to default: alpha blending)
proc beginScissorMode*(x: int32, y: int32, width: int32, height: int32) {.importc: "BeginScissorMode", sideEffect.}
  ## Begin scissor mode (define screen area for following drawing)
proc endScissorMode*() {.importc: "EndScissorMode", sideEffect.}
  ## End scissor mode
proc beginVrStereoMode*(config: VrStereoConfig) {.importc: "BeginVrStereoMode", sideEffect.}
  ## Begin stereo rendering (requires VR simulator)
proc endVrStereoMode*() {.importc: "EndVrStereoMode", sideEffect.}
  ## End stereo rendering (requires VR simulator)
proc loadVrStereoConfig*(device: VrDeviceInfo): VrStereoConfig {.importc: "LoadVrStereoConfig", sideEffect.}
  ## Load VR stereo config for VR simulator device parameters
proc unloadVrStereoConfig(config: VrStereoConfig) {.importc: "UnloadVrStereoConfig", sideEffect.}
proc loadShaderImpl(vsFileName: cstring, fsFileName: cstring): Shader {.importc: "LoadShader", sideEffect.}
proc loadShaderFromMemoryImpl(vsCode: cstring, fsCode: cstring): Shader {.importc: "LoadShaderFromMemory", sideEffect.}
func isShaderValid*(shader: Shader): bool {.importc: "IsShaderValid".}
  ## Check if a shader is valid (loaded on GPU)
proc getShaderLocationImpl(shader: Shader, uniformName: cstring): ShaderLocation {.importc: "GetShaderLocation", sideEffect.}
proc getShaderLocationAttribImpl(shader: Shader, attribName: cstring): ShaderLocation {.importc: "GetShaderLocationAttrib", sideEffect.}
proc setShaderValueImpl(shader: Shader, locIndex: ShaderLocation, value: pointer, uniformType: ShaderUniformDataType) {.importc: "SetShaderValue", sideEffect.}
proc setShaderValueVImpl(shader: Shader, locIndex: ShaderLocation, value: pointer, uniformType: ShaderUniformDataType, count: int32) {.importc: "SetShaderValueV", sideEffect.}
proc setShaderValueMatrix*(shader: Shader, locIndex: ShaderLocation, mat: Matrix) {.importc: "SetShaderValueMatrix", sideEffect.}
  ## Set shader uniform value (matrix 4x4)
proc setShaderValueTexture*(shader: Shader, locIndex: ShaderLocation, texture: Texture2D) {.importc: "SetShaderValueTexture", sideEffect.}
  ## Set shader uniform value for texture (sampler2d)
proc unloadShader(shader: Shader) {.importc: "UnloadShader", sideEffect.}
proc getScreenToWorldRay*(position: Vector2, camera: Camera): Ray {.importc: "GetScreenToWorldRay", sideEffect.}
  ## Get a ray trace from screen position (i.e mouse)
proc getScreenToWorldRay*(position: Vector2, camera: Camera, width: int32, height: int32): Ray {.importc: "GetScreenToWorldRayEx", sideEffect.}
  ## Get a ray trace from screen position (i.e mouse) in a viewport
proc getWorldToScreen*(position: Vector3, camera: Camera): Vector2 {.importc: "GetWorldToScreen", sideEffect.}
  ## Get the screen space position for a 3d world space position
proc getWorldToScreen*(position: Vector3, camera: Camera, width: int32, height: int32): Vector2 {.importc: "GetWorldToScreenEx", sideEffect.}
  ## Get size position for a 3d world space position
func getWorldToScreen2D*(position: Vector2, camera: Camera2D): Vector2 {.importc: "GetWorldToScreen2D".}
  ## Get the screen space position for a 2d camera world space position
func getScreenToWorld2D*(position: Vector2, camera: Camera2D): Vector2 {.importc: "GetScreenToWorld2D".}
  ## Get the world space position for a 2d camera screen space position
func getCameraMatrix*(camera: Camera): Matrix {.importc: "GetCameraMatrix".}
  ## Get camera transform matrix (view matrix)
func getCameraMatrix2D*(camera: Camera2D): Matrix {.importc: "GetCameraMatrix2D".}
  ## Get camera 2d transform matrix
proc setTargetFPS*(fps: int32) {.importc: "SetTargetFPS", sideEffect.}
  ## Set target FPS (maximum)
proc getFrameTime*(): float32 {.importc: "GetFrameTime", sideEffect.}
  ## Get time in seconds for last frame drawn (delta time)
proc getTime*(): float64 {.importc: "GetTime", sideEffect.}
  ## Get elapsed time in seconds since InitWindow()
proc getFPS*(): int32 {.importc: "GetFPS", sideEffect.}
  ## Get current FPS
proc swapScreenBuffer*() {.importc: "SwapScreenBuffer", sideEffect.}
  ## Swap back buffer with front buffer (screen drawing)
proc pollInputEvents*() {.importc: "PollInputEvents", sideEffect.}
  ## Register all input events
proc waitTime*(seconds: float64) {.importc: "WaitTime", sideEffect.}
  ## Wait for some time (halt program execution)
proc takeScreenshotImpl(fileName: cstring) {.importc: "TakeScreenshot", sideEffect.}
proc setConfigFlags*(flags: Flags[ConfigFlags]) {.importc: "SetConfigFlags", sideEffect.}
  ## Setup init configuration flags (view FLAGS)
proc traceLog*(logLevel: TraceLogLevel, text: cstring) {.importc: "TraceLog", varargs, sideEffect.}
  ## Show trace log messages (LOG_DEBUG, LOG_INFO, LOG_WARNING, LOG_ERROR...)
proc setTraceLogLevel*(logLevel: TraceLogLevel) {.importc: "SetTraceLogLevel", sideEffect.}
  ## Set the current threshold (minimum) log level
proc memAlloc(size: uint32): pointer {.importc: "MemAlloc", sideEffect.}
proc memRealloc(`ptr`: pointer, size: uint32): pointer {.importc: "MemRealloc", sideEffect.}
proc memFree(`ptr`: pointer) {.importc: "MemFree", sideEffect.}
proc setTraceLogCallbackImpl(callback: TraceLogCallbackImpl) {.importc: "SetTraceLogCallback", sideEffect.}
proc setLoadFileDataCallback*(callback: LoadFileDataCallback) {.importc: "SetLoadFileDataCallback", sideEffect.}
  ## Set custom file binary data loader
proc setSaveFileDataCallback*(callback: SaveFileDataCallback) {.importc: "SetSaveFileDataCallback", sideEffect.}
  ## Set custom file binary data saver
proc setLoadFileTextCallback*(callback: LoadFileTextCallback) {.importc: "SetLoadFileTextCallback", sideEffect.}
  ## Set custom file text data loader
proc setSaveFileTextCallback*(callback: SaveFileTextCallback) {.importc: "SetSaveFileTextCallback", sideEffect.}
  ## Set custom file text data saver
proc isFileDropped*(): bool {.importc: "IsFileDropped", sideEffect.}
  ## Check if a file has been dropped into window
proc loadDroppedFilesImpl(): FilePathList {.importc: "LoadDroppedFiles", sideEffect.}
proc unloadDroppedFilesImpl(files: FilePathList) {.importc: "UnloadDroppedFiles", sideEffect.}
proc loadAutomationEventListImpl(fileName: cstring): AutomationEventList {.importc: "LoadAutomationEventList", sideEffect.}
proc unloadAutomationEventList*(list: AutomationEventList) {.importc: "UnloadAutomationEventList", sideEffect.}
  ## Unload automation events list from file
proc exportAutomationEventListImpl(list: AutomationEventList, fileName: cstring): bool {.importc: "ExportAutomationEventList", sideEffect.}
proc setAutomationEventList*(list: var AutomationEventList) {.importc: "SetAutomationEventList", sideEffect.}
  ## Set automation event list to record to
proc setAutomationEventBaseFrame*(frame: int32) {.importc: "SetAutomationEventBaseFrame", sideEffect.}
  ## Set automation event internal base frame to start recording
proc startAutomationEventRecording*() {.importc: "StartAutomationEventRecording", sideEffect.}
  ## Start recording automation events (AutomationEventList must be set)
proc stopAutomationEventRecording*() {.importc: "StopAutomationEventRecording", sideEffect.}
  ## Stop recording automation events
proc playAutomationEvent*(event: AutomationEvent) {.importc: "PlayAutomationEvent", sideEffect.}
  ## Play a recorded automation event
proc isKeyPressed*(key: KeyboardKey): bool {.importc: "IsKeyPressed", sideEffect.}
  ## Check if a key has been pressed once
proc isKeyPressedRepeat*(key: KeyboardKey): bool {.importc: "IsKeyPressedRepeat", sideEffect.}
  ## Check if a key has been pressed again
proc isKeyDown*(key: KeyboardKey): bool {.importc: "IsKeyDown", sideEffect.}
  ## Check if a key is being pressed
proc isKeyReleased*(key: KeyboardKey): bool {.importc: "IsKeyReleased", sideEffect.}
  ## Check if a key has been released once
proc isKeyUp*(key: KeyboardKey): bool {.importc: "IsKeyUp", sideEffect.}
  ## Check if a key is NOT being pressed
proc getKeyPressed*(): KeyboardKey {.importc: "GetKeyPressed", sideEffect.}
  ## Get key pressed (keycode), call it multiple times for keys queued, returns 0 when the queue is empty
proc getCharPressed*(): int32 {.importc: "GetCharPressed", sideEffect.}
  ## Get char pressed (unicode), call it multiple times for chars queued, returns 0 when the queue is empty
proc setExitKey*(key: KeyboardKey) {.importc: "SetExitKey", sideEffect.}
  ## Set a custom key to exit program (default is ESC)
proc isGamepadAvailable*(gamepad: int32): bool {.importc: "IsGamepadAvailable", sideEffect.}
  ## Check if a gamepad is available
proc getGamepadNameImpl(gamepad: int32): cstring {.importc: "GetGamepadName", sideEffect.}
proc isGamepadButtonPressed*(gamepad: int32, button: GamepadButton): bool {.importc: "IsGamepadButtonPressed", sideEffect.}
  ## Check if a gamepad button has been pressed once
proc isGamepadButtonDown*(gamepad: int32, button: GamepadButton): bool {.importc: "IsGamepadButtonDown", sideEffect.}
  ## Check if a gamepad button is being pressed
proc isGamepadButtonReleased*(gamepad: int32, button: GamepadButton): bool {.importc: "IsGamepadButtonReleased", sideEffect.}
  ## Check if a gamepad button has been released once
proc isGamepadButtonUp*(gamepad: int32, button: GamepadButton): bool {.importc: "IsGamepadButtonUp", sideEffect.}
  ## Check if a gamepad button is NOT being pressed
proc getGamepadButtonPressed*(): GamepadButton {.importc: "GetGamepadButtonPressed", sideEffect.}
  ## Get the last gamepad button pressed
proc getGamepadAxisCount*(gamepad: int32): int32 {.importc: "GetGamepadAxisCount", sideEffect.}
  ## Get gamepad axis count for a gamepad
proc getGamepadAxisMovement*(gamepad: int32, axis: GamepadAxis): float32 {.importc: "GetGamepadAxisMovement", sideEffect.}
  ## Get axis movement value for a gamepad axis
proc setGamepadMappingsImpl(mappings: cstring): int32 {.importc: "SetGamepadMappings", sideEffect.}
proc setGamepadVibration*(gamepad: int32, leftMotor: float32, rightMotor: float32, duration: float32) {.importc: "SetGamepadVibration", sideEffect.}
  ## Set gamepad vibration for both motors (duration in seconds)
proc isMouseButtonPressed*(button: MouseButton): bool {.importc: "IsMouseButtonPressed", sideEffect.}
  ## Check if a mouse button has been pressed once
proc isMouseButtonDown*(button: MouseButton): bool {.importc: "IsMouseButtonDown", sideEffect.}
  ## Check if a mouse button is being pressed
proc isMouseButtonReleased*(button: MouseButton): bool {.importc: "IsMouseButtonReleased", sideEffect.}
  ## Check if a mouse button has been released once
proc isMouseButtonUp*(button: MouseButton): bool {.importc: "IsMouseButtonUp", sideEffect.}
  ## Check if a mouse button is NOT being pressed
proc getMouseX*(): int32 {.importc: "GetMouseX", sideEffect.}
  ## Get mouse position X
proc getMouseY*(): int32 {.importc: "GetMouseY", sideEffect.}
  ## Get mouse position Y
proc getMousePosition*(): Vector2 {.importc: "GetMousePosition", sideEffect.}
  ## Get mouse position XY
proc getMouseDelta*(): Vector2 {.importc: "GetMouseDelta", sideEffect.}
  ## Get mouse delta between frames
proc setMousePosition*(x: int32, y: int32) {.importc: "SetMousePosition", sideEffect.}
  ## Set mouse position XY
proc setMouseOffset*(offsetX: int32, offsetY: int32) {.importc: "SetMouseOffset", sideEffect.}
  ## Set mouse offset
proc setMouseScale*(scaleX: float32, scaleY: float32) {.importc: "SetMouseScale", sideEffect.}
  ## Set mouse scaling
proc getMouseWheelMove*(): float32 {.importc: "GetMouseWheelMove", sideEffect.}
  ## Get mouse wheel movement for X or Y, whichever is larger
proc getMouseWheelMoveV*(): Vector2 {.importc: "GetMouseWheelMoveV", sideEffect.}
  ## Get mouse wheel movement for both X and Y
proc setMouseCursor*(cursor: MouseCursor) {.importc: "SetMouseCursor", sideEffect.}
  ## Set mouse cursor
proc getTouchX*(): int32 {.importc: "GetTouchX", sideEffect.}
  ## Get touch position X for touch point 0 (relative to screen size)
proc getTouchY*(): int32 {.importc: "GetTouchY", sideEffect.}
  ## Get touch position Y for touch point 0 (relative to screen size)
proc getTouchPosition*(index: int32): Vector2 {.importc: "GetTouchPosition", sideEffect.}
  ## Get touch position XY for a touch point index (relative to screen size)
proc getTouchPointId*(index: int32): int32 {.importc: "GetTouchPointId", sideEffect.}
  ## Get touch point identifier for given index
proc getTouchPointCount*(): int32 {.importc: "GetTouchPointCount", sideEffect.}
  ## Get number of touch points
proc setGesturesEnabled*(flags: Flags[Gesture]) {.importc: "SetGesturesEnabled", sideEffect.}
  ## Enable a set of gestures using flags
proc isGestureDetected*(gesture: Gesture): bool {.importc: "IsGestureDetected", sideEffect.}
  ## Check if a gesture have been detected
proc getGestureDetected*(): Gesture {.importc: "GetGestureDetected", sideEffect.}
  ## Get latest detected gesture
proc getGestureHoldDuration*(): float32 {.importc: "GetGestureHoldDuration", sideEffect.}
  ## Get gesture hold time in seconds
proc getGestureDragVector*(): Vector2 {.importc: "GetGestureDragVector", sideEffect.}
  ## Get gesture drag vector
proc getGestureDragAngle*(): float32 {.importc: "GetGestureDragAngle", sideEffect.}
  ## Get gesture drag angle
proc getGesturePinchVector*(): Vector2 {.importc: "GetGesturePinchVector", sideEffect.}
  ## Get gesture pinch delta
proc getGesturePinchAngle*(): float32 {.importc: "GetGesturePinchAngle", sideEffect.}
  ## Get gesture pinch angle
proc updateCamera*(camera: var Camera, mode: CameraMode) {.importc: "UpdateCamera", sideEffect.}
  ## Update camera position for selected mode
proc updateCamera*(camera: var Camera, movement: Vector3, rotation: Vector3, zoom: float32) {.importc: "UpdateCameraPro", sideEffect.}
  ## Update camera movement/rotation
proc setShapesTexture*(texture: Texture2D, source: Rectangle) {.importc: "SetShapesTexture", sideEffect.}
  ## Set texture and rectangle to be used on shapes drawing
proc getShapesTexture*(): Texture2D {.importc: "GetShapesTexture", sideEffect.}
  ## Get texture that is used for shapes drawing
proc getShapesTextureRectangle*(): Rectangle {.importc: "GetShapesTextureRectangle", sideEffect.}
  ## Get texture source rectangle that is used for shapes drawing
proc drawPixel*(posX: int32, posY: int32, color: Color) {.importc: "DrawPixel", sideEffect.}
  ## Draw a pixel using geometry [Can be slow, use with care]
proc drawPixel*(position: Vector2, color: Color) {.importc: "DrawPixelV", sideEffect.}
  ## Draw a pixel using geometry (Vector version) [Can be slow, use with care]
proc drawLine*(startPosX: int32, startPosY: int32, endPosX: int32, endPosY: int32, color: Color) {.importc: "DrawLine", sideEffect.}
  ## Draw a line
proc drawLine*(startPos: Vector2, endPos: Vector2, color: Color) {.importc: "DrawLineV", sideEffect.}
  ## Draw a line (using gl lines)
proc drawLine*(startPos: Vector2, endPos: Vector2, thick: float32, color: Color) {.importc: "DrawLineEx", sideEffect.}
  ## Draw a line (using triangles/quads)
proc drawLineStripImpl(points: ptr UncheckedArray[Vector2], pointCount: int32, color: Color) {.importc: "DrawLineStrip", sideEffect.}
proc drawLineBezier*(startPos: Vector2, endPos: Vector2, thick: float32, color: Color) {.importc: "DrawLineBezier", sideEffect.}
  ## Draw line segment cubic-bezier in-out interpolation
proc drawCircle*(centerX: int32, centerY: int32, radius: float32, color: Color) {.importc: "DrawCircle", sideEffect.}
  ## Draw a color-filled circle
proc drawCircleSector*(center: Vector2, radius: float32, startAngle: float32, endAngle: float32, segments: int32, color: Color) {.importc: "DrawCircleSector", sideEffect.}
  ## Draw a piece of a circle
proc drawCircleSectorLines*(center: Vector2, radius: float32, startAngle: float32, endAngle: float32, segments: int32, color: Color) {.importc: "DrawCircleSectorLines", sideEffect.}
  ## Draw circle sector outline
proc drawCircleGradient*(centerX: int32, centerY: int32, radius: float32, inner: Color, outer: Color) {.importc: "DrawCircleGradient", sideEffect.}
  ## Draw a gradient-filled circle
proc drawCircle*(center: Vector2, radius: float32, color: Color) {.importc: "DrawCircleV", sideEffect.}
  ## Draw a color-filled circle (Vector version)
proc drawCircleLines*(centerX: int32, centerY: int32, radius: float32, color: Color) {.importc: "DrawCircleLines", sideEffect.}
  ## Draw circle outline
proc drawCircleLines*(center: Vector2, radius: float32, color: Color) {.importc: "DrawCircleLinesV", sideEffect.}
  ## Draw circle outline (Vector version)
proc drawEllipse*(centerX: int32, centerY: int32, radiusH: float32, radiusV: float32, color: Color) {.importc: "DrawEllipse", sideEffect.}
  ## Draw ellipse
proc drawEllipseLines*(centerX: int32, centerY: int32, radiusH: float32, radiusV: float32, color: Color) {.importc: "DrawEllipseLines", sideEffect.}
  ## Draw ellipse outline
proc drawRing*(center: Vector2, innerRadius: float32, outerRadius: float32, startAngle: float32, endAngle: float32, segments: int32, color: Color) {.importc: "DrawRing", sideEffect.}
  ## Draw ring
proc drawRingLines*(center: Vector2, innerRadius: float32, outerRadius: float32, startAngle: float32, endAngle: float32, segments: int32, color: Color) {.importc: "DrawRingLines", sideEffect.}
  ## Draw ring outline
proc drawRectangle*(posX: int32, posY: int32, width: int32, height: int32, color: Color) {.importc: "DrawRectangle", sideEffect.}
  ## Draw a color-filled rectangle
proc drawRectangle*(position: Vector2, size: Vector2, color: Color) {.importc: "DrawRectangleV", sideEffect.}
  ## Draw a color-filled rectangle (Vector version)
proc drawRectangle*(rec: Rectangle, color: Color) {.importc: "DrawRectangleRec", sideEffect.}
  ## Draw a color-filled rectangle
proc drawRectangle*(rec: Rectangle, origin: Vector2, rotation: float32, color: Color) {.importc: "DrawRectanglePro", sideEffect.}
  ## Draw a color-filled rectangle with pro parameters
proc drawRectangleGradientV*(posX: int32, posY: int32, width: int32, height: int32, top: Color, bottom: Color) {.importc: "DrawRectangleGradientV", sideEffect.}
  ## Draw a vertical-gradient-filled rectangle
proc drawRectangleGradientH*(posX: int32, posY: int32, width: int32, height: int32, left: Color, right: Color) {.importc: "DrawRectangleGradientH", sideEffect.}
  ## Draw a horizontal-gradient-filled rectangle
proc drawRectangleGradient*(rec: Rectangle, topLeft: Color, bottomLeft: Color, topRight: Color, bottomRight: Color) {.importc: "DrawRectangleGradientEx", sideEffect.}
  ## Draw a gradient-filled rectangle with custom vertex colors
proc drawRectangleLines*(posX: int32, posY: int32, width: int32, height: int32, color: Color) {.importc: "DrawRectangleLines", sideEffect.}
  ## Draw rectangle outline
proc drawRectangleLines*(rec: Rectangle, lineThick: float32, color: Color) {.importc: "DrawRectangleLinesEx", sideEffect.}
  ## Draw rectangle outline with extended parameters
proc drawRectangleRounded*(rec: Rectangle, roundness: float32, segments: int32, color: Color) {.importc: "DrawRectangleRounded", sideEffect.}
  ## Draw rectangle with rounded edges
proc drawRectangleRoundedLines*(rec: Rectangle, roundness: float32, segments: int32, color: Color) {.importc: "DrawRectangleRoundedLines", sideEffect.}
  ## Draw rectangle lines with rounded edges
proc drawRectangleRoundedLines*(rec: Rectangle, roundness: float32, segments: int32, lineThick: float32, color: Color) {.importc: "DrawRectangleRoundedLinesEx", sideEffect.}
  ## Draw rectangle with rounded edges outline
proc drawTriangle*(v1: Vector2, v2: Vector2, v3: Vector2, color: Color) {.importc: "DrawTriangle", sideEffect.}
  ## Draw a color-filled triangle (vertex in counter-clockwise order!)
proc drawTriangleLines*(v1: Vector2, v2: Vector2, v3: Vector2, color: Color) {.importc: "DrawTriangleLines", sideEffect.}
  ## Draw triangle outline (vertex in counter-clockwise order!)
proc drawTriangleFanImpl(points: ptr UncheckedArray[Vector2], pointCount: int32, color: Color) {.importc: "DrawTriangleFan", sideEffect.}
proc drawTriangleStripImpl(points: ptr UncheckedArray[Vector2], pointCount: int32, color: Color) {.importc: "DrawTriangleStrip", sideEffect.}
proc drawPoly*(center: Vector2, sides: int32, radius: float32, rotation: float32, color: Color) {.importc: "DrawPoly", sideEffect.}
  ## Draw a regular polygon (Vector version)
proc drawPolyLines*(center: Vector2, sides: int32, radius: float32, rotation: float32, color: Color) {.importc: "DrawPolyLines", sideEffect.}
  ## Draw a polygon outline of n sides
proc drawPolyLines*(center: Vector2, sides: int32, radius: float32, rotation: float32, lineThick: float32, color: Color) {.importc: "DrawPolyLinesEx", sideEffect.}
  ## Draw a polygon outline of n sides with extended parameters
proc drawSplineLinearImpl(points: ptr UncheckedArray[Vector2], pointCount: int32, thick: float32, color: Color) {.importc: "DrawSplineLinear", sideEffect.}
proc drawSplineBasisImpl(points: ptr UncheckedArray[Vector2], pointCount: int32, thick: float32, color: Color) {.importc: "DrawSplineBasis", sideEffect.}
proc drawSplineCatmullRomImpl(points: ptr UncheckedArray[Vector2], pointCount: int32, thick: float32, color: Color) {.importc: "DrawSplineCatmullRom", sideEffect.}
proc drawSplineBezierQuadraticImpl(points: ptr UncheckedArray[Vector2], pointCount: int32, thick: float32, color: Color) {.importc: "DrawSplineBezierQuadratic", sideEffect.}
proc drawSplineBezierCubicImpl(points: ptr UncheckedArray[Vector2], pointCount: int32, thick: float32, color: Color) {.importc: "DrawSplineBezierCubic", sideEffect.}
proc drawSplineSegmentLinear*(p1: Vector2, p2: Vector2, thick: float32, color: Color) {.importc: "DrawSplineSegmentLinear", sideEffect.}
  ## Draw spline segment: Linear, 2 points
proc drawSplineSegmentBasis*(p1: Vector2, p2: Vector2, p3: Vector2, p4: Vector2, thick: float32, color: Color) {.importc: "DrawSplineSegmentBasis", sideEffect.}
  ## Draw spline segment: B-Spline, 4 points
proc drawSplineSegmentCatmullRom*(p1: Vector2, p2: Vector2, p3: Vector2, p4: Vector2, thick: float32, color: Color) {.importc: "DrawSplineSegmentCatmullRom", sideEffect.}
  ## Draw spline segment: Catmull-Rom, 4 points
proc drawSplineSegmentBezierQuadratic*(p1: Vector2, c2: Vector2, p3: Vector2, thick: float32, color: Color) {.importc: "DrawSplineSegmentBezierQuadratic", sideEffect.}
  ## Draw spline segment: Quadratic Bezier, 2 points, 1 control point
proc drawSplineSegmentBezierCubic*(p1: Vector2, c2: Vector2, c3: Vector2, p4: Vector2, thick: float32, color: Color) {.importc: "DrawSplineSegmentBezierCubic", sideEffect.}
  ## Draw spline segment: Cubic Bezier, 2 points, 2 control points
func getSplinePointLinear*(startPos: Vector2, endPos: Vector2, t: float32): Vector2 {.importc: "GetSplinePointLinear".}
  ## Get (evaluate) spline point: Linear
func getSplinePointBasis*(p1: Vector2, p2: Vector2, p3: Vector2, p4: Vector2, t: float32): Vector2 {.importc: "GetSplinePointBasis".}
  ## Get (evaluate) spline point: B-Spline
func getSplinePointCatmullRom*(p1: Vector2, p2: Vector2, p3: Vector2, p4: Vector2, t: float32): Vector2 {.importc: "GetSplinePointCatmullRom".}
  ## Get (evaluate) spline point: Catmull-Rom
func getSplinePointBezierQuad*(p1: Vector2, c2: Vector2, p3: Vector2, t: float32): Vector2 {.importc: "GetSplinePointBezierQuad".}
  ## Get (evaluate) spline point: Quadratic Bezier
func getSplinePointBezierCubic*(p1: Vector2, c2: Vector2, c3: Vector2, p4: Vector2, t: float32): Vector2 {.importc: "GetSplinePointBezierCubic".}
  ## Get (evaluate) spline point: Cubic Bezier
func checkCollisionRecs*(rec1: Rectangle, rec2: Rectangle): bool {.importc: "CheckCollisionRecs".}
  ## Check collision between two rectangles
func checkCollisionCircles*(center1: Vector2, radius1: float32, center2: Vector2, radius2: float32): bool {.importc: "CheckCollisionCircles".}
  ## Check collision between two circles
func checkCollisionCircleRec*(center: Vector2, radius: float32, rec: Rectangle): bool {.importc: "CheckCollisionCircleRec".}
  ## Check collision between circle and rectangle
func checkCollisionCircleLine*(center: Vector2, radius: float32, p1: Vector2, p2: Vector2): bool {.importc: "CheckCollisionCircleLine".}
  ## Check if circle collides with a line created betweeen two points [p1] and [p2]
func checkCollisionPointRec*(point: Vector2, rec: Rectangle): bool {.importc: "CheckCollisionPointRec".}
  ## Check if point is inside rectangle
func checkCollisionPointCircle*(point: Vector2, center: Vector2, radius: float32): bool {.importc: "CheckCollisionPointCircle".}
  ## Check if point is inside circle
func checkCollisionPointTriangle*(point: Vector2, p1: Vector2, p2: Vector2, p3: Vector2): bool {.importc: "CheckCollisionPointTriangle".}
  ## Check if point is inside a triangle
func checkCollisionPointLine*(point: Vector2, p1: Vector2, p2: Vector2, threshold: int32): bool {.importc: "CheckCollisionPointLine".}
  ## Check if point belongs to line created between two points [p1] and [p2] with defined margin in pixels [threshold]
func checkCollisionPointPolyImpl(point: Vector2, points: ptr UncheckedArray[Vector2], pointCount: int32): bool {.importc: "CheckCollisionPointPoly".}
func checkCollisionLines*(startPos1: Vector2, endPos1: Vector2, startPos2: Vector2, endPos2: Vector2, collisionPoint: out Vector2): bool {.importc: "CheckCollisionLines".}
  ## Check the collision between two lines defined by two points each, returns collision point by reference
func getCollisionRec*(rec1: Rectangle, rec2: Rectangle): Rectangle {.importc: "GetCollisionRec".}
  ## Get collision rectangle for two rectangles collision
proc loadImageImpl(fileName: cstring): Image {.importc: "rlLoadImage", sideEffect.}
proc loadImageRawImpl(fileName: cstring, width: int32, height: int32, format: PixelFormat, headerSize: int32): Image {.importc: "LoadImageRaw", sideEffect.}
proc loadImageAnimImpl(fileName: cstring, frames: out int32): Image {.importc: "LoadImageAnim", sideEffect.}
proc loadImageAnimFromMemoryImpl(fileType: cstring, fileData: ptr UncheckedArray[uint8], dataSize: int32, frames: ptr UncheckedArray[int32]): Image {.importc: "LoadImageAnimFromMemory", sideEffect.}
proc loadImageFromMemoryImpl(fileType: cstring, fileData: ptr UncheckedArray[uint8], dataSize: int32): Image {.importc: "LoadImageFromMemory", sideEffect.}
proc loadImageFromTextureImpl(texture: Texture2D): Image {.importc: "LoadImageFromTexture", sideEffect.}
proc loadImageFromScreen*(): Image {.importc: "LoadImageFromScreen", sideEffect.}
  ## Load image from screen buffer and (screenshot)
func isImageValid*(image: Image): bool {.importc: "IsImageValid".}
  ## Check if an image is valid (data and parameters)
proc unloadImage(image: Image) {.importc: "UnloadImage", sideEffect.}
proc exportImageImpl(image: Image, fileName: cstring): bool {.importc: "ExportImage", sideEffect.}
proc exportImageToMemoryImpl(image: Image, fileType: cstring, fileSize: ptr int32): ptr uint8 {.importc: "ExportImageToMemory", sideEffect.}
proc exportImageAsCodeImpl(image: Image, fileName: cstring): bool {.importc: "ExportImageAsCode", sideEffect.}
func genImageColor*(width: int32, height: int32, color: Color): Image {.importc: "GenImageColor".}
  ## Generate image: plain color
func genImageGradientLinear*(width: int32, height: int32, direction: int32, start: Color, `end`: Color): Image {.importc: "GenImageGradientLinear".}
  ## Generate image: linear gradient, direction in degrees [0..360], 0=Vertical gradient
func genImageGradientRadial*(width: int32, height: int32, density: float32, inner: Color, outer: Color): Image {.importc: "GenImageGradientRadial".}
  ## Generate image: radial gradient
func genImageGradientSquare*(width: int32, height: int32, density: float32, inner: Color, outer: Color): Image {.importc: "GenImageGradientSquare".}
  ## Generate image: square gradient
func genImageChecked*(width: int32, height: int32, checksX: int32, checksY: int32, col1: Color, col2: Color): Image {.importc: "GenImageChecked".}
  ## Generate image: checked
func genImageWhiteNoise*(width: int32, height: int32, factor: float32): Image {.importc: "GenImageWhiteNoise".}
  ## Generate image: white noise
func genImagePerlinNoise*(width: int32, height: int32, offsetX: int32, offsetY: int32, scale: float32): Image {.importc: "GenImagePerlinNoise".}
  ## Generate image: perlin noise
func genImageCellular*(width: int32, height: int32, tileSize: int32): Image {.importc: "GenImageCellular".}
  ## Generate image: cellular algorithm, bigger tileSize means bigger cells
func genImageTextImpl(width: int32, height: int32, text: cstring): Image {.importc: "GenImageText".}
func imageCopy*(image: Image): Image {.importc: "ImageCopy".}
  ## Create an image duplicate (useful for transformations)
func imageFromImage*(image: Image, rec: Rectangle): Image {.importc: "ImageFromImage".}
  ## Create an image from another image piece
func imageFromChannel*(image: Image, selectedChannel: int32): Image {.importc: "ImageFromChannel".}
  ## Create an image from a selected channel of another image (GRAYSCALE)
func imageTextImpl(text: cstring, fontSize: int32, color: Color): Image {.importc: "ImageText".}
func imageTextImpl(font: Font, text: cstring, fontSize: float32, spacing: float32, tint: Color): Image {.importc: "ImageTextEx".}
func imageFormat*(image: var Image, newFormat: PixelFormat) {.importc: "ImageFormat".}
  ## Convert image data to desired format
func imageToPOT*(image: var Image, fill: Color) {.importc: "ImageToPOT".}
  ## Convert image to POT (power-of-two)
func imageCrop*(image: var Image, crop: Rectangle) {.importc: "ImageCrop".}
  ## Crop an image to a defined rectangle
func imageAlphaCrop*(image: var Image, threshold: float32) {.importc: "ImageAlphaCrop".}
  ## Crop image depending on alpha value
func imageAlphaClear*(image: var Image, color: Color, threshold: float32) {.importc: "ImageAlphaClear".}
  ## Clear alpha channel to desired color
func imageAlphaMask*(image: var Image, alphaMask: Image) {.importc: "ImageAlphaMask".}
  ## Apply alpha mask to image
func imageAlphaPremultiply*(image: var Image) {.importc: "ImageAlphaPremultiply".}
  ## Premultiply alpha channel
func imageBlurGaussian*(image: var Image, blurSize: int32) {.importc: "ImageBlurGaussian".}
  ## Apply Gaussian blur using a box blur approximation
func imageKernelConvolutionImpl(image: ptr Image, kernel: ptr UncheckedArray[float32], kernelSize: int32) {.importc: "ImageKernelConvolution".}
func imageResize*(image: var Image, newWidth: int32, newHeight: int32) {.importc: "ImageResize".}
  ## Resize image (Bicubic scaling algorithm)
func imageResizeNN*(image: var Image, newWidth: int32, newHeight: int32) {.importc: "ImageResizeNN".}
  ## Resize image (Nearest-Neighbor scaling algorithm)
func imageResizeCanvas*(image: var Image, newWidth: int32, newHeight: int32, offsetX: int32, offsetY: int32, fill: Color) {.importc: "ImageResizeCanvas".}
  ## Resize canvas and fill with color
func imageMipmaps*(image: var Image) {.importc: "ImageMipmaps".}
  ## Compute all mipmap levels for a provided image
func imageDither*(image: var Image, rBpp: int32, gBpp: int32, bBpp: int32, aBpp: int32) {.importc: "ImageDither".}
  ## Dither image data to 16bpp or lower (Floyd-Steinberg dithering)
func imageFlipVertical*(image: var Image) {.importc: "ImageFlipVertical".}
  ## Flip image vertically
func imageFlipHorizontal*(image: var Image) {.importc: "ImageFlipHorizontal".}
  ## Flip image horizontally
func imageRotate*(image: var Image, degrees: int32) {.importc: "ImageRotate".}
  ## Rotate image by input angle in degrees (-359 to 359)
func imageRotateCW*(image: var Image) {.importc: "ImageRotateCW".}
  ## Rotate image clockwise 90deg
func imageRotateCCW*(image: var Image) {.importc: "ImageRotateCCW".}
  ## Rotate image counter-clockwise 90deg
func imageColorTint*(image: var Image, color: Color) {.importc: "ImageColorTint".}
  ## Modify image color: tint
func imageColorInvert*(image: var Image) {.importc: "ImageColorInvert".}
  ## Modify image color: invert
func imageColorGrayscale*(image: var Image) {.importc: "ImageColorGrayscale".}
  ## Modify image color: grayscale
func imageColorContrast*(image: var Image, contrast: float32) {.importc: "ImageColorContrast".}
  ## Modify image color: contrast (-100 to 100)
func imageColorBrightness*(image: var Image, brightness: int32) {.importc: "ImageColorBrightness".}
  ## Modify image color: brightness (-255 to 255)
func imageColorReplace*(image: var Image, color: Color, replace: Color) {.importc: "ImageColorReplace".}
  ## Modify image color: replace color
proc loadImageColorsImpl(image: Image): ptr UncheckedArray[Color] {.importc: "LoadImageColors", sideEffect.}
proc loadImagePaletteImpl(image: Image, maxPaletteSize: int32, colorCount: ptr int32): ptr UncheckedArray[Color] {.importc: "LoadImagePalette", sideEffect.}
func getImageAlphaBorder*(image: Image, threshold: float32): Rectangle {.importc: "GetImageAlphaBorder".}
  ## Get image alpha border rectangle
func getImageColor*(image: Image, x: int32, y: int32): Color {.importc: "GetImageColor".}
  ## Get image pixel color at (x, y) position
func imageClearBackground*(dst: var Image, color: Color) {.importc: "ImageClearBackground".}
  ## Clear image background with given color
func imageDrawPixel*(dst: var Image, posX: int32, posY: int32, color: Color) {.importc: "ImageDrawPixel".}
  ## Draw pixel within an image
func imageDrawPixel*(dst: var Image, position: Vector2, color: Color) {.importc: "ImageDrawPixelV".}
  ## Draw pixel within an image (Vector version)
func imageDrawLine*(dst: var Image, startPosX: int32, startPosY: int32, endPosX: int32, endPosY: int32, color: Color) {.importc: "ImageDrawLine".}
  ## Draw line within an image
func imageDrawLine*(dst: var Image, start: Vector2, `end`: Vector2, color: Color) {.importc: "ImageDrawLineV".}
  ## Draw line within an image (Vector version)
func imageDrawLine*(dst: var Image, start: Vector2, `end`: Vector2, thick: int32, color: Color) {.importc: "ImageDrawLineEx".}
  ## Draw a line defining thickness within an image
func imageDrawCircle*(dst: var Image, centerX: int32, centerY: int32, radius: int32, color: Color) {.importc: "ImageDrawCircle".}
  ## Draw a filled circle within an image
func imageDrawCircle*(dst: var Image, center: Vector2, radius: int32, color: Color) {.importc: "ImageDrawCircleV".}
  ## Draw a filled circle within an image (Vector version)
func imageDrawCircleLines*(dst: var Image, centerX: int32, centerY: int32, radius: int32, color: Color) {.importc: "ImageDrawCircleLines".}
  ## Draw circle outline within an image
func imageDrawCircleLines*(dst: var Image, center: Vector2, radius: int32, color: Color) {.importc: "ImageDrawCircleLinesV".}
  ## Draw circle outline within an image (Vector version)
func imageDrawRectangle*(dst: var Image, posX: int32, posY: int32, width: int32, height: int32, color: Color) {.importc: "ImageDrawRectangle".}
  ## Draw rectangle within an image
func imageDrawRectangle*(dst: var Image, position: Vector2, size: Vector2, color: Color) {.importc: "ImageDrawRectangleV".}
  ## Draw rectangle within an image (Vector version)
func imageDrawRectangle*(dst: var Image, rec: Rectangle, color: Color) {.importc: "ImageDrawRectangleRec".}
  ## Draw rectangle within an image
func imageDrawRectangleLines*(dst: var Image, rec: Rectangle, thick: int32, color: Color) {.importc: "ImageDrawRectangleLines".}
  ## Draw rectangle lines within an image
func imageDrawTriangle*(dst: var Image, v1: Vector2, v2: Vector2, v3: Vector2, color: Color) {.importc: "ImageDrawTriangle".}
  ## Draw triangle within an image
func imageDrawTriangle*(dst: var Image, v1: Vector2, v2: Vector2, v3: Vector2, c1: Color, c2: Color, c3: Color) {.importc: "ImageDrawTriangleEx".}
  ## Draw triangle with interpolated colors within an image
func imageDrawTriangleLines*(dst: var Image, v1: Vector2, v2: Vector2, v3: Vector2, color: Color) {.importc: "ImageDrawTriangleLines".}
  ## Draw triangle outline within an image
func imageDrawTriangleFanImpl(dst: ptr Image, points: ptr UncheckedArray[Vector2], pointCount: int32, color: Color) {.importc: "ImageDrawTriangleFan".}
func imageDrawTriangleStripImpl(dst: ptr Image, points: ptr UncheckedArray[Vector2], pointCount: int32, color: Color) {.importc: "ImageDrawTriangleStrip".}
func imageDraw*(dst: var Image, src: Image, srcRec: Rectangle, dstRec: Rectangle, tint: Color) {.importc: "ImageDraw".}
  ## Draw a source image within a destination image (tint applied to source)
func imageDrawTextImpl(dst: ptr Image, text: cstring, posX: int32, posY: int32, fontSize: int32, color: Color) {.importc: "ImageDrawText".}
func imageDrawTextImpl(dst: ptr Image, font: Font, text: cstring, position: Vector2, fontSize: float32, spacing: float32, tint: Color) {.importc: "ImageDrawTextEx".}
proc loadTextureImpl(fileName: cstring): Texture2D {.importc: "LoadTexture", sideEffect.}
proc loadTextureFromImageImpl(image: Image): Texture2D {.importc: "LoadTextureFromImage", sideEffect.}
proc loadTextureCubemapImpl(image: Image, layout: CubemapLayout): TextureCubemap {.importc: "LoadTextureCubemap", sideEffect.}
proc loadRenderTextureImpl(width: int32, height: int32): RenderTexture2D {.importc: "LoadRenderTexture", sideEffect.}
func isTextureValid*(texture: Texture2D): bool {.importc: "IsTextureValid".}
  ## Check if a texture is valid (loaded in GPU)
proc unloadTexture(texture: Texture2D) {.importc: "UnloadTexture", sideEffect.}
func isRenderTextureValid*(target: RenderTexture2D): bool {.importc: "IsRenderTextureValid".}
  ## Check if a render texture is valid (loaded in GPU)
proc unloadRenderTexture(target: RenderTexture2D) {.importc: "UnloadRenderTexture", sideEffect.}
proc updateTextureImpl(texture: Texture2D, pixels: pointer) {.importc: "UpdateTexture", sideEffect.}
proc updateTextureImpl(texture: Texture2D, rec: Rectangle, pixels: pointer) {.importc: "UpdateTextureRec", sideEffect.}
proc genTextureMipmaps*(texture: var Texture2D) {.importc: "GenTextureMipmaps", sideEffect.}
  ## Generate GPU mipmaps for a texture
proc setTextureFilter*(texture: Texture2D, filter: TextureFilter) {.importc: "SetTextureFilter", sideEffect.}
  ## Set texture scaling filter mode
proc setTextureWrap*(texture: Texture2D, wrap: TextureWrap) {.importc: "SetTextureWrap", sideEffect.}
  ## Set texture wrapping mode
proc drawTexture*(texture: Texture2D, posX: int32, posY: int32, tint: Color) {.importc: "DrawTexture", sideEffect.}
  ## Draw a Texture2D
proc drawTexture*(texture: Texture2D, position: Vector2, tint: Color) {.importc: "DrawTextureV", sideEffect.}
  ## Draw a Texture2D with position defined as Vector2
proc drawTexture*(texture: Texture2D, position: Vector2, rotation: float32, scale: float32, tint: Color) {.importc: "DrawTextureEx", sideEffect.}
  ## Draw a Texture2D with extended parameters
proc drawTexture*(texture: Texture2D, source: Rectangle, position: Vector2, tint: Color) {.importc: "DrawTextureRec", sideEffect.}
  ## Draw a part of a texture defined by a rectangle
proc drawTexture*(texture: Texture2D, source: Rectangle, dest: Rectangle, origin: Vector2, rotation: float32, tint: Color) {.importc: "DrawTexturePro", sideEffect.}
  ## Draw a part of a texture defined by a rectangle with 'pro' parameters
proc drawTextureNPatch*(texture: Texture2D, nPatchInfo: NPatchInfo, dest: Rectangle, origin: Vector2, rotation: float32, tint: Color) {.importc: "DrawTextureNPatch", sideEffect.}
  ## Draws a texture (or part of it) that stretches or shrinks nicely
func colorNormalize*(color: Color): Vector4 {.importc: "ColorNormalize".}
  ## Get Color normalized as float [0..1]
func colorFromNormalized*(normalized: Vector4): Color {.importc: "ColorFromNormalized".}
  ## Get Color from normalized values [0..1]
func colorToHSV*(color: Color): Vector3 {.importc: "ColorToHSV".}
  ## Get HSV values for a Color, hue [0..360], saturation/value [0..1]
func colorFromHSV*(hue: float32, saturation: float32, value: float32): Color {.importc: "ColorFromHSV".}
  ## Get a Color from HSV values, hue [0..360], saturation/value [0..1]
func colorTint*(color: Color, tint: Color): Color {.importc: "ColorTint".}
  ## Get color multiplied with another color
func colorBrightness*(color: Color, factor: float32): Color {.importc: "ColorBrightness".}
  ## Get color with brightness correction, brightness factor goes from -1.0f to 1.0f
func colorContrast*(color: Color, contrast: float32): Color {.importc: "ColorContrast".}
  ## Get color with contrast correction, contrast values between -1.0f and 1.0f
func colorAlpha*(color: Color, alpha: float32): Color {.importc: "ColorAlpha".}
  ## Get color with alpha applied, alpha goes from 0.0f to 1.0f
func colorAlphaBlend*(dst: Color, src: Color, tint: Color): Color {.importc: "ColorAlphaBlend".}
  ## Get src alpha-blended into dst color with tint
func colorLerp*(color1: Color, color2: Color, factor: float32): Color {.importc: "ColorLerp".}
  ## Get color lerp interpolation between two colors, factor [0.0f..1.0f]
proc getPixelColorImpl(srcPtr: pointer, format: PixelFormat): Color {.importc: "GetPixelColor", sideEffect.}
proc setPixelColorImpl(dstPtr: pointer, color: Color, format: PixelFormat) {.importc: "SetPixelColor", sideEffect.}
func getPixelDataSize*(width: int32, height: int32, format: PixelFormat): int32 {.importc: "GetPixelDataSize".}
  ## Get pixel data size in bytes for certain format
proc getFontDefault*(): Font {.importc: "GetFontDefault", sideEffect.}
  ## Get the default Font
proc loadFontImpl(fileName: cstring): Font {.importc: "LoadFont", sideEffect.}
proc loadFontImpl(fileName: cstring, fontSize: int32, codepoints: ptr UncheckedArray[int32], codepointCount: int32): Font {.importc: "LoadFontEx", sideEffect.}
proc loadFontFromImageImpl(image: Image, key: Color, firstChar: int32): Font {.importc: "LoadFontFromImage", sideEffect.}
proc loadFontFromMemoryImpl(fileType: cstring, fileData: ptr UncheckedArray[uint8], dataSize: int32, fontSize: int32, codepoints: ptr UncheckedArray[int32], codepointCount: int32): Font {.importc: "LoadFontFromMemory", sideEffect.}
func isFontValid*(font: Font): bool {.importc: "IsFontValid".}
  ## Check if a font is valid (font data loaded, WARNING: GPU texture not checked)
proc loadFontDataImpl(fileData: ptr UncheckedArray[uint8], dataSize: int32, fontSize: int32, codepoints: ptr UncheckedArray[int32], codepointCount: int32, `type`: FontType): ptr UncheckedArray[GlyphInfo] {.importc: "LoadFontData", sideEffect.}
func genImageFontAtlasImpl(glyphs: ptr UncheckedArray[GlyphInfo], glyphRecs: ptr ptr UncheckedArray[Rectangle], glyphCount: int32, fontSize: int32, padding: int32, packMethod: int32): Image {.importc: "GenImageFontAtlas".}
proc unloadFont(font: Font) {.importc: "UnloadFont", sideEffect.}
proc exportFontAsCodeImpl(font: Font, fileName: cstring): bool {.importc: "ExportFontAsCode", sideEffect.}
proc drawFPS*(posX: int32, posY: int32) {.importc: "DrawFPS", sideEffect.}
  ## Draw current FPS
proc drawTextImpl(text: cstring, posX: int32, posY: int32, fontSize: int32, color: Color) {.importc: "rlDrawText", sideEffect.}
proc drawTextImpl(font: Font, text: cstring, position: Vector2, fontSize: float32, spacing: float32, tint: Color) {.importc: "rlDrawTextEx", sideEffect.}
proc drawTextImpl(font: Font, text: cstring, position: Vector2, origin: Vector2, rotation: float32, fontSize: float32, spacing: float32, tint: Color) {.importc: "DrawTextPro", sideEffect.}
proc drawTextCodepoint*(font: Font, codepoint: Rune, position: Vector2, fontSize: float32, tint: Color) {.importc: "DrawTextCodepoint", sideEffect.}
  ## Draw one character (codepoint)
proc drawTextCodepointsImpl(font: Font, codepoints: ptr UncheckedArray[int32], codepointCount: int32, position: Vector2, fontSize: float32, spacing: float32, tint: Color) {.importc: "DrawTextCodepoints", sideEffect.}
proc setTextLineSpacing*(spacing: int32) {.importc: "SetTextLineSpacing", sideEffect.}
  ## Set vertical line spacing when drawing with line-breaks
proc measureTextImpl(text: cstring, fontSize: int32): int32 {.importc: "MeasureText", sideEffect.}
func measureTextImpl(font: Font, text: cstring, fontSize: float32, spacing: float32): Vector2 {.importc: "MeasureTextEx".}
func getGlyphIndex*(font: Font, codepoint: Rune): int32 {.importc: "GetGlyphIndex".}
  ## Get glyph index position in font for a codepoint (unicode character), fallback to '?' if not found
func getGlyphInfo*(font: Font, codepoint: Rune): GlyphInfo {.importc: "GetGlyphInfo".}
  ## Get glyph font info data for a codepoint (unicode character), fallback to '?' if not found
func getGlyphAtlasRec*(font: Font, codepoint: Rune): Rectangle {.importc: "GetGlyphAtlasRec".}
  ## Get glyph rectangle in font atlas for a codepoint (unicode character), fallback to '?' if not found
proc drawLine3D*(startPos: Vector3, endPos: Vector3, color: Color) {.importc: "DrawLine3D", sideEffect.}
  ## Draw a line in 3D world space
proc drawPoint3D*(position: Vector3, color: Color) {.importc: "DrawPoint3D", sideEffect.}
  ## Draw a point in 3D space, actually a small line
proc drawCircle3D*(center: Vector3, radius: float32, rotationAxis: Vector3, rotationAngle: float32, color: Color) {.importc: "DrawCircle3D", sideEffect.}
  ## Draw a circle in 3D world space
proc drawTriangle3D*(v1: Vector3, v2: Vector3, v3: Vector3, color: Color) {.importc: "DrawTriangle3D", sideEffect.}
  ## Draw a color-filled triangle (vertex in counter-clockwise order!)
proc drawTriangleStrip3DImpl(points: ptr UncheckedArray[Vector3], pointCount: int32, color: Color) {.importc: "DrawTriangleStrip3D", sideEffect.}
proc drawCube*(position: Vector3, width: float32, height: float32, length: float32, color: Color) {.importc: "DrawCube", sideEffect.}
  ## Draw cube
proc drawCube*(position: Vector3, size: Vector3, color: Color) {.importc: "DrawCubeV", sideEffect.}
  ## Draw cube (Vector version)
proc drawCubeWires*(position: Vector3, width: float32, height: float32, length: float32, color: Color) {.importc: "DrawCubeWires", sideEffect.}
  ## Draw cube wires
proc drawCubeWires*(position: Vector3, size: Vector3, color: Color) {.importc: "DrawCubeWiresV", sideEffect.}
  ## Draw cube wires (Vector version)
proc drawSphere*(centerPos: Vector3, radius: float32, color: Color) {.importc: "DrawSphere", sideEffect.}
  ## Draw sphere
proc drawSphere*(centerPos: Vector3, radius: float32, rings: int32, slices: int32, color: Color) {.importc: "DrawSphereEx", sideEffect.}
  ## Draw sphere with extended parameters
proc drawSphereWires*(centerPos: Vector3, radius: float32, rings: int32, slices: int32, color: Color) {.importc: "DrawSphereWires", sideEffect.}
  ## Draw sphere wires
proc drawCylinder*(position: Vector3, radiusTop: float32, radiusBottom: float32, height: float32, slices: int32, color: Color) {.importc: "DrawCylinder", sideEffect.}
  ## Draw a cylinder/cone
proc drawCylinder*(startPos: Vector3, endPos: Vector3, startRadius: float32, endRadius: float32, sides: int32, color: Color) {.importc: "DrawCylinderEx", sideEffect.}
  ## Draw a cylinder with base at startPos and top at endPos
proc drawCylinderWires*(position: Vector3, radiusTop: float32, radiusBottom: float32, height: float32, slices: int32, color: Color) {.importc: "DrawCylinderWires", sideEffect.}
  ## Draw a cylinder/cone wires
proc drawCylinderWires*(startPos: Vector3, endPos: Vector3, startRadius: float32, endRadius: float32, sides: int32, color: Color) {.importc: "DrawCylinderWiresEx", sideEffect.}
  ## Draw a cylinder wires with base at startPos and top at endPos
proc drawCapsule*(startPos: Vector3, endPos: Vector3, radius: float32, slices: int32, rings: int32, color: Color) {.importc: "DrawCapsule", sideEffect.}
  ## Draw a capsule with the center of its sphere caps at startPos and endPos
proc drawCapsuleWires*(startPos: Vector3, endPos: Vector3, radius: float32, slices: int32, rings: int32, color: Color) {.importc: "DrawCapsuleWires", sideEffect.}
  ## Draw capsule wireframe with the center of its sphere caps at startPos and endPos
proc drawPlane*(centerPos: Vector3, size: Vector2, color: Color) {.importc: "DrawPlane", sideEffect.}
  ## Draw a plane XZ
proc drawRay*(ray: Ray, color: Color) {.importc: "DrawRay", sideEffect.}
  ## Draw a ray line
proc drawGrid*(slices: int32, spacing: float32) {.importc: "DrawGrid", sideEffect.}
  ## Draw a grid (centered at (0, 0, 0))
proc loadModelImpl(fileName: cstring): Model {.importc: "LoadModel", sideEffect.}
proc loadModelFromMeshImpl(mesh: Mesh): Model {.importc: "LoadModelFromMesh", sideEffect.}
func isModelValid*(model: Model): bool {.importc: "IsModelValid".}
  ## Check if a model is valid (loaded in GPU, VAO/VBOs)
proc unloadModel(model: Model) {.importc: "UnloadModel", sideEffect.}
proc getModelBoundingBox*(model: Model): BoundingBox {.importc: "GetModelBoundingBox", sideEffect.}
  ## Compute model bounding box limits (considers all meshes)
proc drawModel*(model: Model, position: Vector3, scale: float32, tint: Color) {.importc: "DrawModel", sideEffect.}
  ## Draw a model (with texture if set)
proc drawModel*(model: Model, position: Vector3, rotationAxis: Vector3, rotationAngle: float32, scale: Vector3, tint: Color) {.importc: "DrawModelEx", sideEffect.}
  ## Draw a model with extended parameters
proc drawModelWires*(model: Model, position: Vector3, scale: float32, tint: Color) {.importc: "DrawModelWires", sideEffect.}
  ## Draw a model wires (with texture if set)
proc drawModelWires*(model: Model, position: Vector3, rotationAxis: Vector3, rotationAngle: float32, scale: Vector3, tint: Color) {.importc: "DrawModelWiresEx", sideEffect.}
  ## Draw a model wires (with texture if set) with extended parameters
proc drawModelPoints*(model: Model, position: Vector3, scale: float32, tint: Color) {.importc: "DrawModelPoints", sideEffect.}
  ## Draw a model as points
proc drawModelPoints*(model: Model, position: Vector3, rotationAxis: Vector3, rotationAngle: float32, scale: Vector3, tint: Color) {.importc: "DrawModelPointsEx", sideEffect.}
  ## Draw a model as points with extended parameters
proc drawBoundingBox*(box: BoundingBox, color: Color) {.importc: "DrawBoundingBox", sideEffect.}
  ## Draw bounding box (wires)
proc drawBillboard*(camera: Camera, texture: Texture2D, position: Vector3, scale: float32, tint: Color) {.importc: "DrawBillboard", sideEffect.}
  ## Draw a billboard texture
proc drawBillboard*(camera: Camera, texture: Texture2D, source: Rectangle, position: Vector3, size: Vector2, tint: Color) {.importc: "DrawBillboardRec", sideEffect.}
  ## Draw a billboard texture defined by source
proc drawBillboard*(camera: Camera, texture: Texture2D, source: Rectangle, position: Vector3, up: Vector3, size: Vector2, origin: Vector2, rotation: float32, tint: Color) {.importc: "DrawBillboardPro", sideEffect.}
  ## Draw a billboard texture defined by source and rotation
proc uploadMesh*(mesh: var Mesh, dynamic: bool) {.importc: "UploadMesh", sideEffect.}
  ## Upload mesh vertex data in GPU and provide VAO/VBO ids
proc updateMeshBufferImpl(mesh: Mesh, index: int32, data: pointer, dataSize: int32, offset: int32) {.importc: "UpdateMeshBuffer", sideEffect.}
proc unloadMesh(mesh: Mesh) {.importc: "UnloadMesh", sideEffect.}
proc drawMesh*(mesh: Mesh, material: Material, transform: Matrix) {.importc: "DrawMesh", sideEffect.}
  ## Draw a 3d mesh with material and transform
proc drawMeshInstancedImpl(mesh: Mesh, material: Material, transforms: ptr UncheckedArray[Matrix], instances: int32) {.importc: "DrawMeshInstanced", sideEffect.}
func getMeshBoundingBox*(mesh: Mesh): BoundingBox {.importc: "GetMeshBoundingBox".}
  ## Compute mesh bounding box limits
proc genMeshTangents*(mesh: var Mesh) {.importc: "GenMeshTangents", sideEffect.}
  ## Compute mesh tangents
proc exportMeshImpl(mesh: Mesh, fileName: cstring): bool {.importc: "ExportMesh", sideEffect.}
proc exportMeshAsCodeImpl(mesh: Mesh, fileName: cstring): bool {.importc: "ExportMeshAsCode", sideEffect.}
proc genMeshPoly*(sides: int32, radius: float32): Mesh {.importc: "GenMeshPoly", sideEffect.}
  ## Generate polygonal mesh
proc genMeshPlane*(width: float32, length: float32, resX: int32, resZ: int32): Mesh {.importc: "GenMeshPlane", sideEffect.}
  ## Generate plane mesh (with subdivisions)
proc genMeshCube*(width: float32, height: float32, length: float32): Mesh {.importc: "GenMeshCube", sideEffect.}
  ## Generate cuboid mesh
proc genMeshSphere*(radius: float32, rings: int32, slices: int32): Mesh {.importc: "GenMeshSphere", sideEffect.}
  ## Generate sphere mesh (standard sphere)
proc genMeshHemiSphere*(radius: float32, rings: int32, slices: int32): Mesh {.importc: "GenMeshHemiSphere", sideEffect.}
  ## Generate half-sphere mesh (no bottom cap)
proc genMeshCylinder*(radius: float32, height: float32, slices: int32): Mesh {.importc: "GenMeshCylinder", sideEffect.}
  ## Generate cylinder mesh
proc genMeshCone*(radius: float32, height: float32, slices: int32): Mesh {.importc: "GenMeshCone", sideEffect.}
  ## Generate cone/pyramid mesh
proc genMeshTorus*(radius: float32, size: float32, radSeg: int32, sides: int32): Mesh {.importc: "GenMeshTorus", sideEffect.}
  ## Generate torus mesh
proc genMeshKnot*(radius: float32, size: float32, radSeg: int32, sides: int32): Mesh {.importc: "GenMeshKnot", sideEffect.}
  ## Generate trefoil knot mesh
proc genMeshHeightmap*(heightmap: Image, size: Vector3): Mesh {.importc: "GenMeshHeightmap", sideEffect.}
  ## Generate heightmap mesh from image data
proc genMeshCubicmap*(cubicmap: Image, cubeSize: Vector3): Mesh {.importc: "GenMeshCubicmap", sideEffect.}
  ## Generate cubes-based map mesh from image data
proc loadMaterialsImpl(fileName: cstring, materialCount: ptr int32): ptr UncheckedArray[Material] {.importc: "LoadMaterials", sideEffect.}
proc loadMaterialDefault*(): Material {.importc: "LoadMaterialDefault", sideEffect.}
  ## Load default material (Supports: DIFFUSE, SPECULAR, NORMAL maps)
func isMaterialValid*(material: Material): bool {.importc: "IsMaterialValid".}
  ## Check if a material is valid (shader assigned, map textures loaded in GPU)
proc unloadMaterial(material: Material) {.importc: "UnloadMaterial", sideEffect.}
proc loadModelAnimationsImpl(fileName: cstring, animCount: ptr int32): ptr UncheckedArray[ModelAnimation] {.importc: "LoadModelAnimations", sideEffect.}
proc updateModelAnimation*(model: Model, anim: ModelAnimation, frame: int32) {.importc: "UpdateModelAnimation", sideEffect.}
  ## Update model animation pose (CPU)
func updateModelAnimationBoneMatrices*(model: Model, anim: ModelAnimation, frame: int32) {.importc: "UpdateModelAnimationBoneMatrices".}
  ## Update model animation mesh bone matrices (GPU skinning)
proc unloadModelAnimation(anim: ModelAnimation) {.importc: "UnloadModelAnimation", sideEffect.}
func isModelAnimationValid*(model: Model, anim: ModelAnimation): bool {.importc: "IsModelAnimationValid".}
  ## Check model animation skeleton match
func checkCollisionSpheres*(center1: Vector3, radius1: float32, center2: Vector3, radius2: float32): bool {.importc: "CheckCollisionSpheres".}
  ## Check collision between two spheres
func checkCollisionBoxes*(box1: BoundingBox, box2: BoundingBox): bool {.importc: "CheckCollisionBoxes".}
  ## Check collision between two bounding boxes
func checkCollisionBoxSphere*(box: BoundingBox, center: Vector3, radius: float32): bool {.importc: "CheckCollisionBoxSphere".}
  ## Check collision between box and sphere
func getRayCollisionSphere*(ray: Ray, center: Vector3, radius: float32): RayCollision {.importc: "GetRayCollisionSphere".}
  ## Get collision info between ray and sphere
func getRayCollisionBox*(ray: Ray, box: BoundingBox): RayCollision {.importc: "GetRayCollisionBox".}
  ## Get collision info between ray and box
func getRayCollisionMesh*(ray: Ray, mesh: Mesh, transform: Matrix): RayCollision {.importc: "GetRayCollisionMesh".}
  ## Get collision info between ray and mesh
func getRayCollisionTriangle*(ray: Ray, p1: Vector3, p2: Vector3, p3: Vector3): RayCollision {.importc: "GetRayCollisionTriangle".}
  ## Get collision info between ray and triangle
func getRayCollisionQuad*(ray: Ray, p1: Vector3, p2: Vector3, p3: Vector3, p4: Vector3): RayCollision {.importc: "GetRayCollisionQuad".}
  ## Get collision info between ray and quad
proc initAudioDevice*() {.importc: "InitAudioDevice", sideEffect.}
  ## Initialize audio device and context
proc closeAudioDevice*() {.importc: "CloseAudioDevice", sideEffect.}
  ## Close the audio device and context
func isAudioDeviceReady*(): bool {.importc: "IsAudioDeviceReady".}
  ## Check if audio device has been initialized successfully
proc setMasterVolume*(volume: float32) {.importc: "SetMasterVolume", sideEffect.}
  ## Set master volume (listener)
proc getMasterVolume*(): float32 {.importc: "GetMasterVolume", sideEffect.}
  ## Get master volume (listener)
proc loadWaveImpl(fileName: cstring): Wave {.importc: "LoadWave", sideEffect.}
proc loadWaveFromMemoryImpl(fileType: cstring, fileData: ptr UncheckedArray[uint8], dataSize: int32): Wave {.importc: "LoadWaveFromMemory", sideEffect.}
func isWaveValid*(wave: Wave): bool {.importc: "IsWaveValid".}
  ## Checks if wave data is valid (data loaded and parameters)
proc loadSoundImpl(fileName: cstring): Sound {.importc: "LoadSound", sideEffect.}
proc loadSoundFromWaveImpl(wave: Wave): Sound {.importc: "LoadSoundFromWave", sideEffect.}
proc loadSoundAliasImpl(source: Sound): Sound {.importc: "LoadSoundAlias", sideEffect.}
func isSoundValid*(sound: Sound): bool {.importc: "IsSoundValid".}
  ## Checks if a sound is valid (data loaded and buffers initialized)
proc updateSoundImpl(sound: Sound, data: pointer, sampleCount: int32) {.importc: "UpdateSound", sideEffect.}
proc unloadWave(wave: Wave) {.importc: "UnloadWave", sideEffect.}
proc unloadSound(sound: Sound) {.importc: "UnloadSound", sideEffect.}
proc unloadSoundAlias(alias: Sound) {.importc: "UnloadSoundAlias", sideEffect.}
proc exportWaveImpl(wave: Wave, fileName: cstring): bool {.importc: "ExportWave", sideEffect.}
proc exportWaveAsCodeImpl(wave: Wave, fileName: cstring): bool {.importc: "ExportWaveAsCode", sideEffect.}
proc playSound*(sound: Sound) {.importc: "PlaySound", sideEffect.}
  ## Play a sound
proc stopSound*(sound: Sound) {.importc: "StopSound", sideEffect.}
  ## Stop playing a sound
proc pauseSound*(sound: Sound) {.importc: "PauseSound", sideEffect.}
  ## Pause a sound
proc resumeSound*(sound: Sound) {.importc: "ResumeSound", sideEffect.}
  ## Resume a paused sound
proc isSoundPlaying*(sound: Sound): bool {.importc: "IsSoundPlaying", sideEffect.}
  ## Check if a sound is currently playing
proc setSoundVolume*(sound: Sound, volume: float32) {.importc: "SetSoundVolume", sideEffect.}
  ## Set volume for a sound (1.0 is max level)
proc setSoundPitch*(sound: Sound, pitch: float32) {.importc: "SetSoundPitch", sideEffect.}
  ## Set pitch for a sound (1.0 is base level)
proc setSoundPan*(sound: Sound, pan: float32) {.importc: "SetSoundPan", sideEffect.}
  ## Set pan for a sound (0.5 is center)
func waveCopy*(wave: Wave): Wave {.importc: "WaveCopy".}
  ## Copy a wave to a new wave
func waveCrop*(wave: var Wave, initFrame: int32, finalFrame: int32) {.importc: "WaveCrop".}
  ## Crop a wave to defined frames range
func waveFormat*(wave: var Wave, sampleRate: int32, sampleSize: int32, channels: int32) {.importc: "WaveFormat".}
  ## Convert wave data to desired format
proc loadWaveSamplesImpl(wave: Wave): ptr UncheckedArray[float32] {.importc: "LoadWaveSamples", sideEffect.}
proc loadMusicStreamImpl(fileName: cstring): Music {.importc: "LoadMusicStream", sideEffect.}
proc loadMusicStreamFromMemoryImpl(fileType: cstring, data: ptr UncheckedArray[uint8], dataSize: int32): Music {.importc: "LoadMusicStreamFromMemory", sideEffect.}
func isMusicValid*(music: Music): bool {.importc: "IsMusicValid".}
  ## Checks if a music stream is valid (context and buffers initialized)
proc unloadMusicStream(music: Music) {.importc: "UnloadMusicStream", sideEffect.}
proc playMusicStream*(music: Music) {.importc: "PlayMusicStream", sideEffect.}
  ## Start music playing
proc isMusicStreamPlaying*(music: Music): bool {.importc: "IsMusicStreamPlaying", sideEffect.}
  ## Check if music is playing
proc updateMusicStream*(music: Music) {.importc: "UpdateMusicStream", sideEffect.}
  ## Updates buffers for music streaming
proc stopMusicStream*(music: Music) {.importc: "StopMusicStream", sideEffect.}
  ## Stop music playing
proc pauseMusicStream*(music: Music) {.importc: "PauseMusicStream", sideEffect.}
  ## Pause music playing
proc resumeMusicStream*(music: Music) {.importc: "ResumeMusicStream", sideEffect.}
  ## Resume playing paused music
proc seekMusicStream*(music: Music, position: float32) {.importc: "SeekMusicStream", sideEffect.}
  ## Seek music to a position (in seconds)
proc setMusicVolume*(music: Music, volume: float32) {.importc: "SetMusicVolume", sideEffect.}
  ## Set volume for music (1.0 is max level)
proc setMusicPitch*(music: Music, pitch: float32) {.importc: "SetMusicPitch", sideEffect.}
  ## Set pitch for a music (1.0 is base level)
proc setMusicPan*(music: Music, pan: float32) {.importc: "SetMusicPan", sideEffect.}
  ## Set pan for a music (0.5 is center)
func getMusicTimeLength*(music: Music): float32 {.importc: "GetMusicTimeLength".}
  ## Get music time length (in seconds)
proc getMusicTimePlayed*(music: Music): float32 {.importc: "GetMusicTimePlayed", sideEffect.}
  ## Get current music time played (in seconds)
proc loadAudioStreamImpl(sampleRate: uint32, sampleSize: uint32, channels: uint32): AudioStream {.importc: "LoadAudioStream", sideEffect.}
func isAudioStreamValid*(stream: AudioStream): bool {.importc: "IsAudioStreamValid".}
  ## Checks if an audio stream is valid (buffers initialized)
proc unloadAudioStream(stream: AudioStream) {.importc: "UnloadAudioStream", sideEffect.}
proc updateAudioStreamImpl(stream: AudioStream, data: pointer, frameCount: int32) {.importc: "UpdateAudioStream", sideEffect.}
proc isAudioStreamProcessed*(stream: AudioStream): bool {.importc: "IsAudioStreamProcessed", sideEffect.}
  ## Check if any audio stream buffers requires refill
proc playAudioStream*(stream: AudioStream) {.importc: "PlayAudioStream", sideEffect.}
  ## Play audio stream
proc pauseAudioStream*(stream: AudioStream) {.importc: "PauseAudioStream", sideEffect.}
  ## Pause audio stream
proc resumeAudioStream*(stream: AudioStream) {.importc: "ResumeAudioStream", sideEffect.}
  ## Resume audio stream
proc isAudioStreamPlaying*(stream: AudioStream): bool {.importc: "IsAudioStreamPlaying", sideEffect.}
  ## Check if audio stream is playing
proc stopAudioStream*(stream: AudioStream) {.importc: "StopAudioStream", sideEffect.}
  ## Stop audio stream
proc setAudioStreamVolume*(stream: AudioStream, volume: float32) {.importc: "SetAudioStreamVolume", sideEffect.}
  ## Set volume for audio stream (1.0 is max level)
proc setAudioStreamPitch*(stream: AudioStream, pitch: float32) {.importc: "SetAudioStreamPitch", sideEffect.}
  ## Set pitch for audio stream (1.0 is base level)
proc setAudioStreamPan*(stream: AudioStream, pan: float32) {.importc: "SetAudioStreamPan", sideEffect.}
  ## Set pan for audio stream (0.5 is centered)
proc setAudioStreamBufferSizeDefault*(size: int32) {.importc: "SetAudioStreamBufferSizeDefault", sideEffect.}
  ## Default size for new audio streams
proc setAudioStreamCallback*(stream: AudioStream, callback: AudioCallback) {.importc: "SetAudioStreamCallback", sideEffect.}
  ## Audio thread callback to request new data
proc attachAudioStreamProcessor*(stream: AudioStream, processor: AudioCallback) {.importc: "AttachAudioStreamProcessor", sideEffect.}
  ## Attach audio stream processor to stream, receives the samples as 'float'
proc detachAudioStreamProcessor*(stream: AudioStream, processor: AudioCallback) {.importc: "DetachAudioStreamProcessor", sideEffect.}
  ## Detach audio stream processor from stream
proc attachAudioMixedProcessor*(processor: AudioCallback) {.importc: "AttachAudioMixedProcessor", sideEffect.}
  ## Attach audio stream processor to the entire audio pipeline, receives the samples as 'float'
proc detachAudioMixedProcessor*(processor: AudioCallback) {.importc: "DetachAudioMixedProcessor", sideEffect.}
  ## Detach audio stream processor from the entire audio pipeline
{.pop.}

type
  WeakImage* = distinct Image
  WeakWave* = distinct Wave
  WeakFont* = distinct Font

  MaterialMapsPtr* = distinct typeof(Material.maps)
  ShaderLocsPtr* = distinct typeof(Shader.locs)
  SoundAlias* = distinct Sound

proc `=destroy`*(x: WeakImage) = discard
proc `=dup`*(source: WeakImage): WeakImage {.nodestroy.} = source
proc `=copy`*(dest: var WeakImage; source: WeakImage) {.nodestroy.} =
  dest = source

proc `=destroy`*(x: WeakWave) = discard
proc `=dup`*(source: WeakWave): WeakWave {.nodestroy.} = source
proc `=copy`*(dest: var WeakWave; source: WeakWave) {.nodestroy.} =
  dest = source

proc `=destroy`*(x: WeakFont) = discard
proc `=dup`*(source: WeakFont): WeakFont {.nodestroy.} = source
proc `=copy`*(dest: var WeakFont; source: WeakFont) {.nodestroy.} =
  dest = source

proc `=destroy`*(x: MaterialMap) = discard
proc `=wasMoved`*(x: var MaterialMap) {.error.}
proc `=dup`*(source: MaterialMap): MaterialMap {.error.}
proc `=copy`*(dest: var MaterialMap; source: MaterialMap) {.error.}
proc `=sink`*(dest: var MaterialMap; source: MaterialMap) {.error.}

# proc `=destroy`*(x: ShaderLocsPtr) = discard
# proc `=wasMoved`*(x: var ShaderLocsPtr) {.error.}
# proc `=dup`*(source: ShaderLocsPtr): ShaderLocsPtr {.error.}
# proc `=copy`*(dest: var ShaderLocsPtr; source: ShaderLocsPtr) {.error.}
# proc `=sink`*(dest: var ShaderLocsPtr; source: ShaderLocsPtr) {.error.}

proc `=destroy`*(x: Image) =
  unloadImage(x)
proc `=dup`*(source: Image): Image {.nodestroy.} =
  result = imageCopy(source)
proc `=copy`*(dest: var Image; source: Image) =
  if dest.data != source.data:
    dest = imageCopy(source) # generates =sink

proc `=destroy`*(x: Texture) =
  unloadTexture(x)
proc `=dup`*(source: Texture): Texture {.error.}
proc `=copy`*(dest: var Texture; source: Texture) {.error.}

proc `=destroy`*(x: RenderTexture) =
  unloadRenderTexture(x)
proc `=dup`*(source: RenderTexture): RenderTexture {.error.}
proc `=copy`*(dest: var RenderTexture; source: RenderTexture) {.error.}

proc `=destroy`*(x: Font) =
  unloadFont(x)
proc `=dup`*(source: Font): Font {.error.}
proc `=copy`*(dest: var Font; source: Font) {.error.}

proc `=destroy`*(x: Mesh) =
  unloadMesh(x)
proc `=dup`*(source: Mesh): Mesh {.error.}
proc `=copy`*(dest: var Mesh; source: Mesh) {.error.}

proc `=destroy`*(x: Shader) =
  unloadShader(x)
proc `=dup`*(source: Shader): Shader {.error.}
proc `=copy`*(dest: var Shader; source: Shader) {.error.}

proc `=destroy`*(x: Material) =
  unloadMaterial(x)
# proc `=dup`*(source: Material): Material {.error.}
proc `=copy`*(dest: var Material; source: Material) {.error.}

proc `=destroy`*(x: Model) =
  unloadModel(x)
proc `=dup`*(source: Model): Model {.error.}
proc `=copy`*(dest: var Model; source: Model) {.error.}

proc `=destroy`*(x: ModelAnimation) =
  unloadModelAnimation(x)
# proc `=dup`*(source: ModelAnimation): ModelAnimation {.error.}
proc `=copy`*(dest: var ModelAnimation; source: ModelAnimation) {.error.}

proc `=destroy`*(x: Wave) =
  unloadWave(x)
proc `=dup`*(source: Wave): Wave {.nodestroy.} =
  result = waveCopy(source)
proc `=copy`*(dest: var Wave; source: Wave) =
  if dest.data != source.data:
    dest = waveCopy(source)

proc `=destroy`*(x: AudioStream) =
  unloadAudioStream(x)
proc `=dup`*(source: AudioStream): AudioStream {.error.}
proc `=copy`*(dest: var AudioStream; source: AudioStream) {.error.}

proc `=destroy`*(x: Sound) =
  unloadSound(x)
proc `=dup`*(source: Sound): Sound {.error.}
proc `=copy`*(dest: var Sound; source: Sound) {.error.}

proc `=destroy`*(x: SoundAlias) =
  unloadSoundAlias(Sound(x))

proc `=destroy`*(x: Music) =
  unloadMusicStream(x)
proc `=dup`*(source: Music): Music {.error.}
proc `=copy`*(dest: var Music; source: Music) {.error.}

proc `=destroy`*(x: AutomationEventList) =
  unloadAutomationEventList(x)
proc `=dup`*(source: AutomationEventList): AutomationEventList {.error.}
proc `=copy`*(dest: var AutomationEventList; source: AutomationEventList) {.error.}

type
  RArray*[T] = object
    len: int
    data: ptr UncheckedArray[T]

proc `=destroy`*[T](x: RArray[T]) =
  if x.data != nil:
    for i in 0..<x.len: `=destroy`(x.data[i])
    memFree(x.data)
proc `=wasMoved`*[T](x: var RArray[T]) =
  x.data = nil
proc `=dup`*[T](source: RArray[T]): RArray[T] {.nodestroy.} =
  result.len = source.len
  if source.data != nil:
    result.data = cast[typeof(result.data)](memAlloc(result.len.uint32))
    for i in 0..<result.len: result.data[i] = `=dup`(source.data[i])
proc `=copy`*[T](dest: var RArray[T]; source: RArray[T]) =
  if dest.data != source.data:
    `=destroy`(dest)
    `=wasMoved`(dest)
    dest.len = source.len
    if source.data != nil:
      dest.data = cast[typeof(dest.data)](memAlloc(dest.len.uint32))
      for i in 0..<dest.len: dest.data[i] = source.data[i]

proc raiseIndexDefect(i, n: int) {.noinline, noreturn.} =
  raise newException(IndexDefect, "index " & $i & " not in 0 .. " & $n)

template checkArrayAccess(a, x, len) =
  when compileOption("boundChecks"):
    {.line.}:
      if x < 0 or x >= len:
        raiseIndexDefect(x, len-1)

proc `[]`*[T](x: RArray[T], i: int): lent T =
  checkArrayAccess(x.data, i, x.len)
  result = x.data[i]

proc `[]`*[T](x: var RArray[T], i: int): var T =
  checkArrayAccess(x.data, i, x.len)
  result = x.data[i]

proc `[]=`*[T](x: var RArray[T], i: int, val: sink T) =
  checkArrayAccess(x.data, i, x.len)
  x.data[i] = val

proc len*[T](x: RArray[T]): int {.inline.} = x.len

proc `@`*[T](x: RArray[T]): seq[T] {.inline.} =
  newSeq(result, x.len)
  for i in 0..x.len-1: result[i] = x[i]

template toOpenArray*(x: RArray, first, last: int): untyped =
  rangeCheck(first <= last)
  checkArrayAccess(last, x.len)
  toOpenArray(x.data, first, last)

template toOpenArray*(x: RArray): untyped =
  toOpenArray(x.data, 0, x.len-1)

proc capacity*(x: AutomationEventList): int {.inline.} = int(x.capacity)
proc len*(x: AutomationEventList): int {.inline.} = int(x.count)

proc `[]`*(x: AutomationEventList, i: int): lent AutomationEvent =
  checkArrayAccess(x.events, i, x.len)
  result = x.events[i]

proc `[]`*(x: var AutomationEventList, i: int): var AutomationEvent =
  checkArrayAccess(x.events, i, x.len)
  result = x.events[i]

proc `[]=`*(x: var AutomationEventList, i: int, val: sink AutomationEvent) =
  checkArrayAccess(x.events, i, x.len)
  x.events[i] = val

static:
  assert sizeof(Color) == 4*sizeof(uint8)
  assert sizeof(Vector2) == 2*sizeof(float32)
  assert sizeof(Vector3) == 3*sizeof(float32)
  assert sizeof(Vector4) == 4*sizeof(float32)

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

template boneMatrices*(x: Mesh): MeshBoneMatrices = MeshBoneMatrices(x)

proc `[]`*(x: MeshBoneMatrices, i: int): Matrix =
  checkArrayAccess(Mesh(x).boneMatrices, i, Mesh(x).boneCount)
  result = Mesh(x).boneMatrices[i]

proc `[]`*(x: var MeshBoneMatrices, i: int): var Matrix =
  checkArrayAccess(Mesh(x).boneMatrices, i, Mesh(x).boneCount)
  result = Mesh(x).boneMatrices[i]

proc `[]=`*(x: var MeshBoneMatrices, i: int, val: Matrix) =
  checkArrayAccess(Mesh(x).boneMatrices, i, Mesh(x).boneCount)
  Mesh(x).boneMatrices[i] = val

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

proc `locs=`*(x: var Shader; locs: ShaderLocsPtr) {.inline.} =
  x.locs = (typeof(x.locs))(locs)

template locs*(x: Shader): ShaderLocs = ShaderLocs(x)

proc `[]`*(x: ShaderLocs, i: ShaderLocationIndex): ShaderLocation =
  checkArrayAccess(Shader(x).locs, i.int, MaxShaderLocations)
  result = Shader(x).locs[i.int]

proc `[]`*(x: var ShaderLocs, i: ShaderLocationIndex): var ShaderLocation =
  checkArrayAccess(Shader(x).locs, i.int, MaxShaderLocations)
  result = Shader(x).locs[i.int]

proc `[]=`*(x: var ShaderLocs, i: ShaderLocationIndex, val: ShaderLocation) =
  checkArrayAccess(Shader(x).locs, i.int, MaxShaderLocations)
  Shader(x).locs[i.int] = val

proc `maps=`*(x: var Material; maps: MaterialMapsPtr) {.inline.} =
  x.maps = (typeof(x.maps))(maps)

template maps*(x: Material): MaterialMaps = MaterialMaps(x)

proc `[]`*(x: MaterialMaps, i: MaterialMapIndex): lent MaterialMap =
  checkArrayAccess(Material(x).maps, i.int, MaxMaterialMaps)
  result = Material(x).maps[i.int]

proc `[]`*(x: var MaterialMaps, i: MaterialMapIndex): var MaterialMap =
  checkArrayAccess(Material(x).maps, i.int, MaxMaterialMaps)
  result = Material(x).maps[i.int]

proc `[]=`*(x: var MaterialMaps, i: MaterialMapIndex, val: MaterialMap) =
  checkArrayAccess(Material(x).maps, i.int, MaxMaterialMaps)
  Material(x).maps[i.int] = val

proc `texture=`*(x: var MaterialMap, val: Texture) {.nodestroy, inline.} =
  ## Set texture for a material map type (Diffuse, Specular...)
  ## NOTE: Previous texture should be manually unloaded
  x.texture = val

template `texture=`*(x: var MaterialMap, val: Texture{call}) =
  {.error: "Cannot pass a rvalue, as `x` does not take ownership of the texture.".}

proc `shader=`*(x: var Material, val: Shader) {.nodestroy, inline.} =
  x.shader = val

template `shader=`*(x: var Material, val: Shader{call}) =
  {.error: "Cannot pass a rvalue, as `x` does not take ownership of the shader.".}

proc texture*(x: MaterialMap): lent Texture {.inline.} =
  result = x.texture

proc shader*(x: Material): lent Shader {.inline.} =
  result = x.shader

proc texture*(x: var MaterialMap): var Texture {.inline.} =
  result = x.texture

proc shader*(x: var Material): var Shader {.inline.} =
  result = x.shader

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
  ## Set the material for a mesh
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

proc glyphCount*(x: Font): int32 {.inline.} = x.glyphCount
proc vertexCount*(x: Mesh): int32 {.inline.} = x.vertexCount
proc triangleCount*(x: Mesh): int32 {.inline.} = x.triangleCount
proc boneCount*(x: Mesh): int32 {.inline.} = x.boneCount
proc meshCount*(x: Model): int32 {.inline.} = x.meshCount
proc materialCount*(x: Model): int32 {.inline.} = x.materialCount
proc boneCount*(x: Model): int32 {.inline.} = x.boneCount
proc boneCount*(x: ModelAnimation): int32 {.inline.} = x.boneCount
proc frameCount*(x: ModelAnimation): int32 {.inline.} = x.frameCount

proc setWindowIcons*(images: openArray[Image]) =
  ## Set icon for window (multiple images, RGBA 32bit)
  setWindowIconsImpl(cast[ptr UncheckedArray[Image]](images), images.len.int32)

proc setWindowTitle*(title: string) =
  ## Set title for window
  setWindowTitleImpl(title.cstring)

proc getMonitorName*(monitor: int32): string =
  ## Get the human-readable, UTF-8 encoded name of the specified monitor
  $getMonitorNameImpl(monitor)

proc setClipboardText*(text: string) =
  ## Set clipboard text content
  setClipboardTextImpl(text.cstring)

proc getClipboardText*(): string =
  ## Get clipboard text content
  $getClipboardTextImpl()

proc getShaderLocation*(shader: Shader, uniformName: string): ShaderLocation =
  ## Get shader uniform location
  getShaderLocationImpl(shader, uniformName.cstring)

proc getShaderLocationAttrib*(shader: Shader, attribName: string): ShaderLocation =
  ## Get shader attribute location
  getShaderLocationAttribImpl(shader, attribName.cstring)

proc takeScreenshot*(fileName: string) =
  ## Takes a screenshot of current screen (filename extension defines format)
  takeScreenshotImpl(fileName.cstring)

proc exportAutomationEventList*(list: AutomationEventList, fileName: string): bool =
  ## Export automation events list as text file
  exportAutomationEventListImpl(list, fileName.cstring)

proc getGamepadName*(gamepad: int32): string =
  ## Get gamepad internal name id
  $getGamepadNameImpl(gamepad)

proc setGamepadMappings*(mappings: string): int32 =
  ## Set internal gamepad mappings (SDL_GameControllerDB)
  setGamepadMappingsImpl(mappings.cstring)

proc drawLineStrip*(points: openArray[Vector2], color: Color) =
  ## Draw lines sequence (using gl lines)
  drawLineStripImpl(cast[ptr UncheckedArray[Vector2]](points), points.len.int32, color)

proc drawTriangleFan*(points: openArray[Vector2], color: Color) =
  ## Draw a triangle fan defined by points (first vertex is the center)
  drawTriangleFanImpl(cast[ptr UncheckedArray[Vector2]](points), points.len.int32, color)

proc drawTriangleStrip*(points: openArray[Vector2], color: Color) =
  ## Draw a triangle strip defined by points
  drawTriangleStripImpl(cast[ptr UncheckedArray[Vector2]](points), points.len.int32, color)

proc drawSplineLinear*(points: openArray[Vector2], thick: float32, color: Color) =
  ## Draw spline: Linear, minimum 2 points
  drawSplineLinearImpl(cast[ptr UncheckedArray[Vector2]](points), points.len.int32, thick, color)

proc drawSplineBasis*(points: openArray[Vector2], thick: float32, color: Color) =
  ## Draw spline: B-Spline, minimum 4 points
  drawSplineBasisImpl(cast[ptr UncheckedArray[Vector2]](points), points.len.int32, thick, color)

proc drawSplineCatmullRom*(points: openArray[Vector2], thick: float32, color: Color) =
  ## Draw spline: Catmull-Rom, minimum 4 points
  drawSplineCatmullRomImpl(cast[ptr UncheckedArray[Vector2]](points), points.len.int32, thick, color)

proc drawSplineBezierQuadratic*(points: openArray[Vector2], thick: float32, color: Color) =
  ## Draw spline: Quadratic Bezier, minimum 3 points (1 control point): [p1, c2, p3, c4...]
  drawSplineBezierQuadraticImpl(cast[ptr UncheckedArray[Vector2]](points), points.len.int32, thick, color)

proc drawSplineBezierCubic*(points: openArray[Vector2], thick: float32, color: Color) =
  ## Draw spline: Cubic Bezier, minimum 4 points (2 control points): [p1, c2, c3, p4, c5, c6...]
  drawSplineBezierCubicImpl(cast[ptr UncheckedArray[Vector2]](points), points.len.int32, thick, color)

proc checkCollisionPointPoly*(point: Vector2, points: openArray[Vector2]): bool =
  ## Check if point is within a polygon described by array of vertices
  checkCollisionPointPolyImpl(point, cast[ptr UncheckedArray[Vector2]](points), points.len.int32)

proc exportImage*(image: Image, fileName: string): bool =
  ## Export image data to file, returns true on success
  exportImageImpl(image, fileName.cstring)

proc exportImageAsCode*(image: Image, fileName: string): bool =
  ## Export image as code file defining an array of bytes, returns true on success
  exportImageAsCodeImpl(image, fileName.cstring)

proc genImageText*(width: int32, height: int32, text: string): Image =
  ## Generate image: grayscale image from text data
  genImageTextImpl(width, height, text.cstring)

proc imageText*(text: string, fontSize: int32, color: Color): Image =
  ## Create an image from text (default font)
  imageTextImpl(text.cstring, fontSize, color)

proc imageText*(font: Font, text: string, fontSize: float32, spacing: float32, tint: Color): Image =
  ## Create an image from text (custom sprite font)
  imageTextImpl(font, text.cstring, fontSize, spacing, tint)

proc imageKernelConvolution*(image: var Image, kernel: openArray[float32]) =
  ## Apply custom square convolution kernel to image
  imageKernelConvolutionImpl(addr image, cast[ptr UncheckedArray[float32]](kernel), kernel.len.int32)

proc imageDrawTriangleFan*(dst: var Image, points: openArray[Vector2], color: Color) =
  ## Draw a triangle fan defined by points within an image (first vertex is the center)
  imageDrawTriangleFanImpl(addr dst, cast[ptr UncheckedArray[Vector2]](points), points.len.int32, color)

proc imageDrawTriangleStrip*(dst: var Image, points: openArray[Vector2], color: Color) =
  ## Draw a triangle strip defined by points within an image
  imageDrawTriangleStripImpl(addr dst, cast[ptr UncheckedArray[Vector2]](points), points.len.int32, color)

proc imageDrawText*(dst: var Image, text: string, posX: int32, posY: int32, fontSize: int32, color: Color) =
  ## Draw text (using default font) within an image (destination)
  imageDrawTextImpl(addr dst, text.cstring, posX, posY, fontSize, color)

proc imageDrawText*(dst: var Image, font: Font, text: string, position: Vector2, fontSize: float32, spacing: float32, tint: Color) =
  ## Draw text (custom sprite font) within an image (destination)
  imageDrawTextImpl(addr dst, font, text.cstring, position, fontSize, spacing, tint)

proc exportFontAsCode*(font: Font, fileName: string): bool =
  ## Export font as code file, returns true on success
  exportFontAsCodeImpl(font, fileName.cstring)

proc drawText*(text: string, posX: int32, posY: int32, fontSize: int32, color: Color) =
  ## Draw text (using default font)
  drawTextImpl(text.cstring, posX, posY, fontSize, color)

proc drawText*(font: Font, text: string, position: Vector2, fontSize: float32, spacing: float32, tint: Color) =
  ## Draw text using font and additional parameters
  drawTextImpl(font, text.cstring, position, fontSize, spacing, tint)

proc drawText*(font: Font, text: string, position: Vector2, origin: Vector2, rotation: float32, fontSize: float32, spacing: float32, tint: Color) =
  ## Draw text using Font and pro parameters (rotation)
  drawTextImpl(font, text.cstring, position, origin, rotation, fontSize, spacing, tint)

proc measureText*(text: string, fontSize: int32): int32 =
  ## Measure string width for default font
  measureTextImpl(text.cstring, fontSize)

proc measureText*(font: Font, text: string, fontSize: float32, spacing: float32): Vector2 =
  ## Measure string size for Font
  measureTextImpl(font, text.cstring, fontSize, spacing)

proc drawTriangleStrip3D*(points: openArray[Vector3], color: Color) =
  ## Draw a triangle strip defined by points
  drawTriangleStrip3DImpl(cast[ptr UncheckedArray[Vector3]](points), points.len.int32, color)

proc exportMesh*(mesh: Mesh, fileName: string): bool =
  ## Export mesh data to file, returns true on success
  exportMeshImpl(mesh, fileName.cstring)

proc exportMeshAsCode*(mesh: Mesh, fileName: string): bool =
  ## Export mesh as code file (.h) defining multiple arrays of vertex attributes
  exportMeshAsCodeImpl(mesh, fileName.cstring)

proc exportWave*(wave: Wave, fileName: string): bool =
  ## Export wave data to file, returns true on success
  exportWaveImpl(wave, fileName.cstring)

proc exportWaveAsCode*(wave: Wave, fileName: string): bool =
  ## Export wave sample data to code (.h), returns true on success
  exportWaveAsCodeImpl(wave, fileName.cstring)

type
  RaylibError* = object of CatchableError

proc raiseRaylibError(msg: string) {.noinline, noreturn.} =
  raise newException(RaylibError, msg)

type
  TraceLogCallback* = proc (logLevel: TraceLogLevel; text: string) {.
      nimcall.} ## Logging: Redirect trace log messages

var
  traceLogCallback: TraceLogCallback # TraceLog callback function pointer

proc wrapperTraceLogCallback(logLevel: int32; text: cstring; args: va_list) {.cdecl.} =
  var buf = newString(128)
  vsprintf(buf.cstring, text, args)
  traceLogCallback(logLevel.TraceLogLevel, buf)

proc setTraceLogCallback*(callback: TraceLogCallback) =
  ## Set custom trace log
  traceLogCallback = callback
  setTraceLogCallbackImpl(cast[TraceLogCallbackImpl](wrapperTraceLogCallback))

proc toWeakImage*(data: openArray[byte], width, height: int32, format: PixelFormat): WeakImage {.inline.} =
  Image(data: cast[pointer](data), width: width, height: height, mipmaps: 1, format: format).WeakImage

proc toWeakWave*(data: openArray[byte], frameCount, sampleRate, sampleSize, channels: uint32): WeakWave {.inline.} =
  Wave(data: cast[pointer](data), frameCount: frameCount, sampleRate: sampleRate, sampleSize: sampleSize, channels: channels).WeakWave

proc initWindow*(width: int32, height: int32, title: string) =
  ## Initialize window and OpenGL context
  initWindowImpl(width, height, title.cstring)
  if not isWindowReady(): raiseRaylibError("Failed to create Window")

proc getDroppedFiles*(): seq[string] =
  ## Get dropped files names
  let dropfiles = loadDroppedFilesImpl()
  result = cstringArrayToSeq(dropfiles.paths, dropfiles.count)
  unloadDroppedFilesImpl(dropfiles) # Clear internal buffers

proc exportDataAsCode*(data: openArray[byte], fileName: string): bool =
  ## Export data to code (.nim), returns true on success
  result = false
  const TextBytesPerLine = 20
  # NOTE: Text data buffer size is estimated considering raw data size in bytes
  # and requiring 6 char bytes for every byte: "0x00, "
  var txtData = newStringOfCap(data.len*6 + 300)
  txtData.add("""
#
# DataAsCode exporter v1.0 - Raw data exported as an array of bytes
#
# more info and bugs-report:  github.com/raysan5/raylib
# feedback and support:       ray[at]raylib.com
#
# Copyright (c) 2022-2023 Ramon Santamaria (@raysan5)
#
""")
  # Get the file name from the path
  var (_, name, _) = splitFile(fileName.Path)
  txtData.addf("const $1Data: array[$2, byte] = [ ", name.string, data.len)
  for i in 0..data.high - 1:
    txtData.addf(
        if i mod TextBytesPerLine == 0: "0x$1,\n" else: "0x$1, ", data[i].toHex)
  txtData.addf("0x$1 ]\n", data[^1].toHex)
  try:
    writeFile(fileName, txtData)
    result = true
  except IOError:
    discard

  if result:
    traceLog(Info, "FILEIO: [%s] Data as code exported successfully", fileName)
  else:
    traceLog(Warning, "FILEIO: [%s] Failed to export data as code", fileName)

proc loadShader*(vsFileName, fsFileName: string): Shader =
  ## Load shader from files and bind default locations
  result = loadShaderImpl(if vsFileName.len == 0: nil else: vsFileName.cstring,
      if fsFileName.len == 0: nil else: fsFileName.cstring)

proc loadShaderFromMemory*(vsCode, fsCode: string): Shader =
  ## Load shader from code strings and bind default locations
  result = loadShaderFromMemoryImpl(if vsCode.len == 0: nil else: vsCode.cstring,
      if fsCode.len == 0: nil else: fsCode.cstring)

type
  ShaderV* = concept
    proc kind(x: typedesc[Self]): ShaderUniformDataType

template kind*(x: typedesc[float32]): ShaderUniformDataType = Float
template kind*(x: typedesc[Vector2]): ShaderUniformDataType = Vec2
template kind*(x: typedesc[Vector3]): ShaderUniformDataType = Vec3
template kind*(x: typedesc[Vector4]): ShaderUniformDataType = Vec4
template kind*(x: typedesc[int32]): ShaderUniformDataType = Int
template kind*(x: typedesc[array[2, int32]]): ShaderUniformDataType = Ivec2
template kind*(x: typedesc[array[3, int32]]): ShaderUniformDataType = Ivec3
template kind*(x: typedesc[array[4, int32]]): ShaderUniformDataType = Ivec4
template kind*(x: typedesc[array[2, float32]]): ShaderUniformDataType = Vec2
template kind*(x: typedesc[array[3, float32]]): ShaderUniformDataType = Vec3
template kind*(x: typedesc[array[4, float32]]): ShaderUniformDataType = Vec4

proc setShaderValue*[T: ShaderV](shader: Shader, locIndex: ShaderLocation, value: T) =
  ## Set shader uniform value
  setShaderValueImpl(shader, locIndex, addr value, kind(T))

proc setShaderValueV*[T: ShaderV](shader: Shader, locIndex: ShaderLocation, value: openArray[T]) =
  ## Set shader uniform value vector
  setShaderValueVImpl(shader, locIndex, cast[pointer](value), kind(T), value.len.int32)

proc loadModelAnimations*(fileName: string): RArray[ModelAnimation] =
  ## Load model animations from file
  var len = 0'i32
  let data = loadModelAnimationsImpl(fileName.cstring, addr len)
  if len <= 0: raiseRaylibError("Failed to load ModelAnimations from " & fileName)
  result = RArray[ModelAnimation](len: len.int, data: data)

proc loadWaveSamples*(wave: Wave): RArray[float32] =
  ## Load samples data from wave as a floats array
  let data = loadWaveSamplesImpl(wave)
  let len = int(wave.frameCount * wave.channels)
  result = RArray[float32](len: len, data: data)

proc loadImageColors*(image: Image): RArray[Color] =
  ## Load color data from image as a Color array (RGBA - 32bit)
  let data = loadImageColorsImpl(image)
  let len = int(image.width * image.height)
  result = RArray[Color](len: len, data: data)

proc loadImagePalette*(image: Image; maxPaletteSize: int32): RArray[Color] =
  ## Load colors palette from image as a Color array (RGBA - 32bit)
  var len = 0'i32
  let data = loadImagePaletteImpl(image, maxPaletteSize, addr len)
  result = RArray[Color](len: len, data: data)

proc loadMaterials*(fileName: string): RArray[Material] =
  ## Load materials from model file
  var len = 0'i32
  let data = loadMaterialsImpl(fileName.cstring, addr len)
  if len <= 0: raiseRaylibError("Failed to load Materials from " & fileName)
  result = RArray[Material](len: len, data: data)

proc loadImage*(fileName: string): Image =
  ## Load image from file into CPU memory (RAM)
  result = loadImageImpl(fileName.cstring)
  if not isImageValid(result): raiseRaylibError("Failed to load Image from " & fileName)

proc loadImageRaw*(fileName: string, width, height: int32, format: PixelFormat, headerSize: int32): Image =
  ## Load image sequence from file (frames appended to image.data)
  result = loadImageRawImpl(fileName.cstring, width, height, format, headerSize)
  if not isImageValid(result): raiseRaylibError("Failed to load Image from " & fileName)

proc loadImageAnim*(fileName: string, frames: out int32): Image =
  ## Load image sequence from file (frames appended to image.data)
  result = loadImageAnimImpl(fileName.cstring, frames)
  if not isImageValid(result): raiseRaylibError("Failed to load Image sequence from " & fileName)

proc loadImageAnimFromMemory*(fileType: string, fileData: openArray[uint8], frames: openArray[int32]): Image =
  ## Load image sequence from memory buffer
  result = loadImageAnimFromMemoryImpl(fileType.cstring, cast[ptr UncheckedArray[uint8]](fileData),
      fileData.len.int32, cast[ptr UncheckedArray[int32]](frames))
  if not isImageValid(result): raiseRaylibError("Failed to load Image sequence from buffer")

proc loadImageFromMemory*(fileType: string; fileData: openArray[uint8]): Image =
  ## Load image from memory buffer, fileType refers to extension: i.e. '.png'
  result = loadImageFromMemoryImpl(fileType.cstring, cast[ptr UncheckedArray[uint8]](fileData),
      fileData.len.int32)
  if not isImageValid(result): raiseRaylibError("Failed to load Image from buffer")

proc loadImageFromTexture*(texture: Texture2D): Image =
  ## Load image from GPU texture data
  result = loadImageFromTextureImpl(texture)
  if not isImageValid(result): raiseRaylibError("Failed to load Image from Texture")

proc exportImageToMemory*(image: Image, fileType: string): RArray[uint8] =
  ## Export image to memory buffer
  var len = 0'i32
  let data = exportImageToMemoryImpl(image, fileType.cstring, addr len)
  result = RArray[uint8](len: len, data: cast[ptr UncheckedArray[uint8]](data))

type
  Pixel* = concept
    proc kind(x: typedesc[Self]): PixelFormat

template kind*(x: typedesc[Color]): PixelFormat = UncompressedR8g8b8a8

template toColorArray*(a: openArray[byte]): untyped =
  ## Note: that `a` should be properly formatted, with a byte representation that aligns
  ## with the memory layout of the Color type.
  let newLen = a.len div sizeof(Color)
  assert(newLen * sizeof(Color) == a.len,
      "The length of the byte array is not a multiple of the size of the Color type")
  toOpenArray(cast[ptr UncheckedArray[Color]](addr a[0]), 0, newLen - 1)

proc loadTextureFromData*[T: Pixel](pixels: openArray[T], width: int32, height: int32): Texture =
  ## Load texture using pixels
  assert getPixelDataSize(width, height, kind(T)) == pixels.len*sizeof(T),
      "Mismatch between expected and actual data size"
  let image = Image(data: cast[pointer](pixels), width: width, height: height,
      format: kind(T), mipmaps: 1).WeakImage
  result = loadTextureFromImageImpl(image.Image)
  if not isTextureValid(result): raiseRaylibError("Failed to load Texture from buffer")

proc loadTexture*(fileName: string): Texture2D =
  ## Load texture from file into GPU memory (VRAM)
  result = loadTextureImpl(fileName.cstring)
  if not isTextureValid(result): raiseRaylibError("Failed to load Texture from " & fileName)

proc loadTextureFromImage*(image: Image): Texture2D =
  ## Load texture from image data
  result = loadTextureFromImageImpl(image)
  if not isTextureValid(result): raiseRaylibError("Failed to load Texture from Image")

proc loadTextureCubemap*(image: Image, layout: CubemapLayout): TextureCubemap =
  ## Load cubemap from image, multiple image cubemap layouts supported
  result = loadTextureCubemapImpl(image, layout)
  if not isTextureValid(result): raiseRaylibError("Failed to load Texture from Cubemap")

proc loadRenderTexture*(width: int32, height: int32): RenderTexture2D =
  ## Load texture for rendering (framebuffer)
  result = loadRenderTextureImpl(width, height)
  if not isRenderTextureValid(result): raiseRaylibError("Failed to load RenderTexture")

proc updateTexture*[T: Pixel](texture: Texture2D, pixels: openArray[T]) =
  ## Update GPU texture with new data
  assert texture.format == kind(T), "Incompatible texture format"
  assert getPixelDataSize(texture.width, texture.height, texture.format) == pixels.len*sizeof(T),
      "Mismatch between expected and actual data size"
  updateTextureImpl(texture, cast[pointer](pixels))

proc updateTexture*[T: Pixel](texture: Texture2D, rec: Rectangle, pixels: openArray[T]) =
  ## Update GPU texture rectangle with new data
  assert texture.format == kind(T), "Incompatible texture format"
  assert getPixelDataSize(rec.width.int32, rec.height.int32, texture.format) == pixels.len*sizeof(T),
      "Mismatch between expected and actual data size"
  updateTextureImpl(texture, rec, cast[pointer](pixels))

proc getPixelColor*[T: Pixel](pixel: T): Color =
  ## Get Color from a source pixel pointer of certain format
  assert getPixelDataSize(1, 1, kind(T)) == sizeof(T), "Pixel size does not match expected format"
  getPixelColorImpl(addr pixel, kind(T))

proc setPixelColor*[T: Pixel](pixel: var T, color: Color) =
  ## Set color formatted into destination pixel pointer
  assert getPixelDataSize(1, 1, kind(T)) == sizeof(T), "Pixel size does not match expected format"
  setPixelColorImpl(addr pixel, color, kind(T))

proc loadFontData*(fileData: openArray[uint8]; fontSize: int32; codepoints: openArray[int32];
    `type`: FontType): RArray[GlyphInfo] =
  ## Load font data for further use
  let data = loadFontDataImpl(cast[ptr UncheckedArray[uint8]](fileData), fileData.len.int32,
      fontSize, if codepoints.len == 0: nil else: cast[ptr UncheckedArray[int32]](codepoints),
      codepoints.len.int32, `type`)
  result = RArray[GlyphInfo](len: if codepoints.len == 0: 95 else: codepoints.len, data: data)

proc loadFontData*(fileData: openArray[uint8]; fontSize, glyphCount: int32;
    `type`: FontType): RArray[GlyphInfo] =
  let data = loadFontDataImpl(cast[ptr UncheckedArray[uint8]](fileData), fileData.len.int32,
      fontSize, nil, glyphCount, `type`)
  result = RArray[GlyphInfo](len: if glyphCount > 0: glyphCount else: 95, data: data)

proc loadFont*(fileName: string): Font =
  ## Load font from file into GPU memory (VRAM)
  result = loadFontImpl(fileName.cstring)
  if not isFontValid(result): raiseRaylibError("Failed to load Font from " & fileName)

proc loadFont*(fileName: string; fontSize: int32; codepoints: openArray[int32]): Font =
  ## Load font from file with extended parameters, use an empty array for codepoints to load the default character set
  result = loadFontImpl(fileName.cstring, fontSize,
      if codepoints.len == 0: nil else: cast[ptr UncheckedArray[int32]](codepoints), codepoints.len.int32)
  if not isFontValid(result): raiseRaylibError("Failed to load Font from " & fileName)

proc loadFont*(fileName: string; fontSize, glyphCount: int32): Font =
  result = loadFontImpl(fileName.cstring, fontSize, nil, glyphCount)
  if not isFontValid(result): raiseRaylibError("Failed to load Font from " & fileName)

proc loadFontFromImage*(image: Image, key: Color, firstChar: int32): Font =
  ## Load font from Image (XNA style)
  result = loadFontFromImageImpl(image, key, firstChar)
  if not isFontValid(result): raiseRaylibError("Failed to load Font from Image")

proc loadFontFromMemory*(fileType: string; fileData: openArray[uint8]; fontSize: int32;
    codepoints: openArray[int32]): Font =
  ## Load font from memory buffer, fileType refers to extension: i.e. '.ttf'
  result = loadFontFromMemoryImpl(fileType.cstring,
      cast[ptr UncheckedArray[uint8]](fileData), fileData.len.int32, fontSize,
      if codepoints.len == 0: nil else: cast[ptr UncheckedArray[int32]](codepoints), codepoints.len.int32)
  if not isFontValid(result): raiseRaylibError("Failed to load Font from buffer")

proc loadFontFromMemory*(fileType: string; fileData: openArray[uint8]; fontSize: int32;
    glyphCount: int32): Font =
  result = loadFontFromMemoryImpl(fileType.cstring, cast[ptr UncheckedArray[uint8]](fileData),
      fileData.len.int32, fontSize, nil, glyphCount)
  if not isFontValid(result): raiseRaylibError("Failed to load Font from buffer")

proc loadFontFromData*(chars: sink RArray[GlyphInfo]; baseSize, padding: int32, packMethod: int32): Font =
  ## Load font using chars info
  result.baseSize = baseSize
  result.glyphCount = chars.len.int32
  result.glyphs = chars.data
  wasMoved(chars)
  let atlas = genImageFontAtlasImpl(result.glyphs, addr result.recs, result.glyphCount, baseSize,
      padding, packMethod)
  result.texture = loadTextureFromImage(atlas)
  if not isFontValid(result): raiseRaylibError("Failed to load Font from Image")

proc loadAutomationEventList*(fileName: string): AutomationEventList =
  ## Load automation events list from file, NULL for empty list, capacity = MAX_AUTOMATION_EVENTS
  loadAutomationEventListImpl(if fileName.len == 0: nil else: fileName.cstring)

proc genImageFontAtlas*(chars: openArray[GlyphInfo]; recs: out RArray[Rectangle]; fontSize: int32;
    padding: int32; packMethod: int32): Image =
  ## Generate image font atlas using chars info
  var data: ptr UncheckedArray[Rectangle] = nil
  result = genImageFontAtlasImpl(cast[ptr UncheckedArray[GlyphInfo]](chars), addr data,
      chars.len.int32, fontSize, padding, packMethod)
  recs = RArray[Rectangle](len: chars.len, data: data)

proc updateMeshBuffer*[T](mesh: var Mesh, index: int32, data: openArray[T], offset: int32) =
  ## Update mesh vertex data in GPU for a specific buffer index
  updateMeshBufferImpl(mesh, index, cast[ptr UncheckedArray[T]](data), data.len.int32, offset)

proc drawMeshInstanced*(mesh: Mesh; material: Material; transforms: openArray[Matrix]) =
  ## Draw multiple mesh instances with material and different transforms
  drawMeshInstancedImpl(mesh, material, cast[ptr UncheckedArray[Matrix]](transforms),
      transforms.len.int32)

proc loadWave*(fileName: string): Wave =
  ## Load wave data from file
  result = loadWaveImpl(fileName.cstring)
  if not isWaveValid(result): raiseRaylibError("Failed to load Wave from " & fileName)

proc loadWaveFromMemory*(fileType: string; fileData: openArray[uint8]): Wave =
  ## Load wave from memory buffer, fileType refers to extension: i.e. '.wav'
  result = loadWaveFromMemoryImpl(fileType.cstring, cast[ptr UncheckedArray[uint8]](fileData),
      fileData.len.int32)
  if not isWaveValid(result): raiseRaylibError("Failed to load Wave from buffer")

proc loadSound*(fileName: string): Sound =
  ## Load sound from file
  result = loadSoundImpl(fileName.cstring)
  if not isSoundValid(result): raiseRaylibError("Failed to load Sound from " & fileName)

proc loadSoundAlias*(source: Sound): SoundAlias =
  ## Create a new sound that shares the same sample data as the source sound, does not own the sound data
  result = SoundAlias(loadSoundAliasImpl(source))
  if not isSoundValid(Sound(result)): raiseRaylibError("Failed to load SoundAlias from source")

proc loadSoundFromWave*(wave: Wave): Sound =
  ## Load sound from wave data
  result = loadSoundFromWaveImpl(wave)
  if not isSoundValid(result): raiseRaylibError("Failed to load Sound from Wave")

proc updateSound*[T](sound: var Sound, data: openArray[T]) =
  ## Update sound buffer with new data
  updateSoundImpl(sound, cast[ptr UncheckedArray[T]](data), data.len.int32)

proc loadMusicStream*(fileName: string): Music =
  ## Load music stream from file
  result = loadMusicStreamImpl(fileName.cstring)
  if not isMusicValid(result): raiseRaylibError("Failed to load Music from " & fileName)

proc loadMusicStreamFromMemory*(fileType: string; data: openArray[uint8]): Music =
  ## Load music stream from data
  result = loadMusicStreamFromMemoryImpl(fileType.cstring, cast[ptr UncheckedArray[uint8]](data),
      data.len.int32)
  if not isMusicValid(result): raiseRaylibError("Failed to load Music from buffer")

proc loadAudioStream*(sampleRate: uint32, sampleSize: uint32, channels: uint32): AudioStream =
  ## Load audio stream (to stream raw audio pcm data)
  result = loadAudioStreamImpl(sampleRate, sampleSize, channels)
  if not isAudioStreamValid(result): raiseRaylibError("Failed to load AudioStream")

proc updateAudioStream*[T](stream: var AudioStream, data: openArray[T]) =
  ## Update audio stream buffers with data
  updateAudioStreamImpl(stream, cast[ptr UncheckedArray[T]](data), data.len.int32)

proc drawTextCodepoints*(font: Font; codepoints: openArray[Rune]; position: Vector2;
    fontSize: float32; spacing: float32; tint: Color) =
  ## Draw multiple character (codepoint)
  drawTextCodepointsImpl(font, cast[ptr UncheckedArray[int32]](codepoints), codepoints.len.int32,
      position, fontSize, spacing, tint)

proc loadModel*(fileName: string): Model =
  ## Load model from files (meshes and materials)
  result = loadModelImpl(fileName.cstring)
  if not isModelValid(result): raiseRaylibError("Failed to load Model from " & fileName)

proc loadModelFromMesh*(mesh: sink Mesh): Model =
  ## Load model from generated mesh (default material)
  result = loadModelFromMeshImpl(mesh)
  wasMoved(mesh)
  if not isModelValid(result): raiseRaylibError("Failed to load Model from Mesh")

proc fade*(color: Color, alpha: float32): Color =
  ## Get color with alpha applied, alpha goes from 0.0 to 1.0
  let alpha = clamp(alpha, 0, 1)
  Color(r: color.r, g: color.g, b: color.b, a: uint8(255*alpha))

proc colorToInt*(color: Color): int32 =
  ## Get hexadecimal value for a Color
  int32((color.r.uint32 shl 24) or (color.g.uint32 shl 16) or (color.b.uint32 shl 8) or color.a.uint32)

proc getColor*(hexValue: uint32): Color =
  ## Get Color structure from hexadecimal value
  result = Color(
    r: uint8(hexValue shr 24 and 0xff),
    g: uint8(hexValue shr 16 and 0xff),
    b: uint8(hexValue shr 8 and 0xff),
    a: uint8(hexValue and 0xff)
  )

template drawing*(body: untyped) =
  ## Setup canvas (framebuffer) to start drawing
  beginDrawing()
  try:
    body
  finally:
    endDrawing()

template mode2D*(camera: Camera2D; body: untyped) =
  ## 2D mode with custom camera (2D)
  beginMode2D(camera)
  try:
    body
  finally:
    endMode2D()

template mode3D*(camera: Camera3D; body: untyped) =
  ## 3D mode with custom camera (3D)
  beginMode3D(camera)
  try:
    body
  finally:
    endMode3D()

template textureMode*(target: RenderTexture2D; body: untyped) =
  ## Drawing to render texture
  beginTextureMode(target)
  try:
    body
  finally:
    endTextureMode()

template shaderMode*(shader: Shader; body: untyped) =
  ## Custom shader drawing
  beginShaderMode(shader)
  try:
    body
  finally:
    endShaderMode()

template blendMode*(mode: BlendMode; body: untyped) =
  ## Blending mode (alpha, additive, multiplied, subtract, custom)
  beginBlendMode(mode)
  try:
    body
  finally:
    endBlendMode()

template scissorMode*(x, y, width, height: int32; body: untyped) =
  ## Scissor mode (define screen area for following drawing)
  beginScissorMode(x, y, width, height)
  try:
    body
  finally:
    endScissorMode()

template vrStereoMode*(config: VrStereoConfig; body: untyped) =
  ## Stereo rendering (requires VR simulator)
  beginVrStereoMode(config)
  try:
    body
  finally:
    endVrStereoMode()
