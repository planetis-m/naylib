const lext = when defined(windows): ".dll" elif defined(macosx): ".dylib" else: ".so"
{.pragma: rlapi, cdecl, dynlib: "libraylib" & lext.}

const
  RaylibVersion* = "4.0"

  MaxShaderLocations* = 32 ## Maximum number of shader locations supported
  MaxMaterialMaps* = 12 ## Maximum number of shader maps supported
  MaxMeshVertexBuffers* = 7 ## Maximum vertex buffers (VBO) per mesh

type
  Vector2* {.bycopy.} = object ## Vector2, 2 components
    x*: float32 ## Vector x component
    y*: float32 ## Vector y component

  Vector3* {.bycopy.} = object ## Vector3, 3 components
    x*: float32 ## Vector x component
    y*: float32 ## Vector y component
    z*: float32 ## Vector z component

  Vector4* {.bycopy.} = object ## Vector4, 4 components
    x*: float32 ## Vector x component
    y*: float32 ## Vector y component
    z*: float32 ## Vector z component
    w*: float32 ## Vector w component
  Quaternion* = Vector4 ## Quaternion, 4 components (Vector4 alias)

  Matrix* {.bycopy.} = object ## Matrix, 4x4 components, column major, OpenGL style, right handed
    m0*, m4*, m8*, m12*: float32 ## Matrix first row (4 components)
    m1*, m5*, m9*, m13*: float32 ## Matrix second row (4 components)
    m2*, m6*, m10*, m14*: float32 ## Matrix third row (4 components)
    m3*, m7*, m11*, m15*: float32 ## Matrix fourth row (4 components)

  Color* {.bycopy.} = object ## Color, 4 components, R8G8B8A8 (32bit)
    r*: uint8 ## Color red value
    g*: uint8 ## Color green value
    b*: uint8 ## Color blue value
    a*: uint8 ## Color alpha value

  Rectangle* {.bycopy.} = object ## Rectangle, 4 components
    x*: float32 ## Rectangle top-left corner position x
    y*: float32 ## Rectangle top-left corner position y
    width*: float32 ## Rectangle width
    height*: float32 ## Rectangle height

  Image* {.bycopy.} = object ## Image, pixel data stored in CPU memory (RAM)
    data*: pointer ## Image raw data
    width*: int32 ## Image base width
    height*: int32 ## Image base height
    mipmaps*: int32 ## Mipmap levels, 1 by default
    format*: PixelFormat ## Data format (PixelFormat type)

  Texture* {.bycopy.} = object ## Texture, tex data stored in GPU memory (VRAM)
    id*: uint32 ## OpenGL texture id
    width*: int32 ## Texture base width
    height*: int32 ## Texture base height
    mipmaps*: int32 ## Mipmap levels, 1 by default
    format*: PixelFormat ## Data format (PixelFormat type)
  Texture2D* = Texture ## Texture2D, same as Texture
  TextureCubemap* = Texture ## TextureCubemap, same as Texture

  RenderTexture* {.bycopy.} = object ## RenderTexture, fbo for texture rendering
    id*: uint32 ## OpenGL framebuffer object id
    texture*: Texture ## Color buffer attachment texture
    depth*: Texture ## Depth buffer attachment texture
  RenderTexture2D* = RenderTexture ## RenderTexture2D, same as RenderTexture

  NPatchInfo* {.bycopy.} = object ## NPatchInfo, n-patch layout info
    source*: Rectangle ## Texture source rectangle
    left*: int32 ## Left border offset
    top*: int32 ## Top border offset
    right*: int32 ## Right border offset
    bottom*: int32 ## Bottom border offset
    layout*: NPatchLayout ## Layout of the n-patch: 3x3, 1x3 or 3x1

  GlyphInfo* {.bycopy.} = object ## GlyphInfo, font characters glyphs info
    value*: int32 ## Character value (Unicode)
    offsetX*: int32 ## Character offset X when drawing
    offsetY*: int32 ## Character offset Y when drawing
    advanceX*: int32 ## Character advance position X
    image*: Image ## Character image data

  Font* {.bycopy.} = object ## Font, font texture and GlyphInfo array data
    baseSize*: int32 ## Base size (default chars height)
    glyphCount*: int32 ## Number of glyph characters
    glyphPadding*: int32 ## Padding around the glyph characters
    texture*: Texture2D ## Texture atlas containing the glyphs
    recs*: ptr UncheckedArray[Rectangle] ## Rectangles in texture for the glyphs
    glyphs*: ptr UncheckedArray[GlyphInfo] ## Glyphs info data

  Camera3D* {.bycopy.} = object ## Camera, defines position/orientation in 3d space
    position*: Vector3 ## Camera position
    target*: Vector3 ## Camera target it looks-at
    up*: Vector3 ## Camera up vector (rotation over its axis)
    fovy*: float32 ## Camera field-of-view apperture in Y (degrees) in perspective, used as near plane width in orthographic
    projection*: CameraProjection ## Camera projection: CAMERA_PERSPECTIVE or CAMERA_ORTHOGRAPHIC
  Camera* = Camera3D ## Camera type fallback, defaults to Camera3D

  Camera2D* {.bycopy.} = object ## Camera2D, defines position/orientation in 2d space
    offset*: Vector2 ## Camera offset (displacement from target)
    target*: Vector2 ## Camera target (rotation and zoom origin)
    rotation*: float32 ## Camera rotation in degrees
    zoom*: float32 ## Camera zoom (scaling), should be 1.0f by default

  Mesh* {.bycopy.} = object ## Mesh, vertex data and vao/vbo
    vertexCount*: int32 ## Number of vertices stored in arrays
    triangleCount*: int32 ## Number of triangles stored (indexed or not)
    vertices*: ptr UncheckedArray[float32] ## Vertex position (XYZ - 3 components per vertex) (shader-location = 0)
    texcoords*: ptr UncheckedArray[float32] ## Vertex texture coordinates (UV - 2 components per vertex) (shader-location = 1)
    texcoords2*: ptr UncheckedArray[float32] ## Vertex second texture coordinates (useful for lightmaps) (shader-location = 5)
    normals*: ptr UncheckedArray[float32] ## Vertex normals (XYZ - 3 components per vertex) (shader-location = 2)
    tangents*: ptr UncheckedArray[float32] ## Vertex tangents (XYZW - 4 components per vertex) (shader-location = 4)
    colors*: ptr UncheckedArray[uint8] ## Vertex colors (RGBA - 4 components per vertex) (shader-location = 3)
    indices*: ptr UncheckedArray[uint16] ## Vertex indices (in case vertex data comes indexed)
    animVertices*: ptr UncheckedArray[float32] ## Animated vertex positions (after bones transformations)
    animNormals*: ptr UncheckedArray[float32] ## Animated normals (after bones transformations)
    boneIds*: ptr UncheckedArray[uint8] ## Vertex bone ids, max 255 bone ids, up to 4 bones influence by vertex (skinning)
    boneWeights*: ptr UncheckedArray[float32] ## Vertex bone weight, up to 4 bones influence by vertex (skinning)
    vaoId*: uint32 ## OpenGL Vertex Array Object id
    vboId*: ptr array[MaxMeshVertexBuffers, uint32] ## OpenGL Vertex Buffer Objects id (default vertex data)

  Shader* {.bycopy.} = object ## Shader
    id*: uint32 ## Shader program id
    locs*: ptr array[MaxShaderLocations, int32] ## Shader locations array (RL_MAX_SHADER_LOCATIONS)

  MaterialMap* {.bycopy.} = object ## MaterialMap
    texture*: Texture2D ## Material map texture
    color*: Color ## Material map color
    value*: float32 ## Material map value

  Material* {.bycopy.} = object ## Material, includes shader and maps
    shader*: Shader ## Material shader
    maps*: ptr array[MaxMaterialMaps, MaterialMap] ## Material maps array (MAX_MATERIAL_MAPS)
    params*: array[4, float32] ## Material generic parameters (if required)

  Transform* {.bycopy.} = object ## Transform, vectex transformation data
    translation*: Vector3 ## Translation
    rotation*: Quaternion ## Rotation
    scale*: Vector3 ## Scale

  BoneInfo* {.bycopy.} = object ## Bone, skeletal animation bone
    name*: array[32, char] ## Bone name
    parent*: int32 ## Bone parent

  Model* {.bycopy.} = object ## Model, meshes, materials and animation data
    transform*: Matrix ## Local transform matrix
    meshCount*: int32 ## Number of meshes
    materialCount*: int32 ## Number of materials
    meshes*: ptr UncheckedArray[Mesh] ## Meshes array
    materials*: ptr UncheckedArray[Material] ## Materials array
    meshMaterial*: ptr UncheckedArray[int32] ## Mesh material number
    boneCount*: int32 ## Number of bones
    bones*: ptr UncheckedArray[BoneInfo] ## Bones information (skeleton)
    bindPose*: ptr UncheckedArray[Transform] ## Bones base transformation (pose)

  ModelAnimation* {.bycopy.} = object ## ModelAnimation
    boneCount*: int32 ## Number of bones
    frameCount*: int32 ## Number of animation frames
    bones*: ptr UncheckedArray[BoneInfo] ## Bones information (skeleton)
    framePoses*: ptr UncheckedArray[ptr UncheckedArray[Transform]] ## Poses array by frame

  Ray* {.bycopy.} = object ## Ray, ray for raycasting
    position*: Vector3 ## Ray position (origin)
    direction*: Vector3 ## Ray direction

  RayCollision* {.bycopy.} = object ## RayCollision, ray hit information
    hit*: bool ## Did the ray hit something?
    distance*: float32 ## Distance to nearest hit
    point*: Vector3 ## Point of nearest hit
    normal*: Vector3 ## Surface normal of hit

  BoundingBox* {.bycopy.} = object ## BoundingBox
    min*: Vector3 ## Minimum vertex box-corner
    max*: Vector3 ## Maximum vertex box-corner

  Wave* {.bycopy.} = object ## Wave, audio wave data
    frameCount*: uint32 ## Total number of frames (considering channels)
    sampleRate*: uint32 ## Frequency (samples per second)
    sampleSize*: uint32 ## Bit depth (bits per sample): 8, 16, 32 (24 not supported)
    channels*: uint32 ## Number of channels (1-mono, 2-stereo, ...)
    data*: pointer ## Buffer data pointer

  AudioStream* {.bycopy.} = object ## AudioStream, custom audio stream
    buffer*: ptr RAudioBuffer ## Pointer to internal data used by the audio system
    sampleRate*: uint32 ## Frequency (samples per second)
    sampleSize*: uint32 ## Bit depth (bits per sample): 8, 16, 32 (24 not supported)
    channels*: uint32 ## Number of channels (1-mono, 2-stereo, ...)
  RAudioBuffer* {.importc: "rAudioBuffer", bycopy.} = object

  Sound* {.bycopy.} = object ## Sound
    stream*: AudioStream ## Audio stream
    frameCount*: uint32 ## Total number of frames (considering channels)

  Music* {.bycopy.} = object ## Music, audio stream, anything longer than ~10 seconds should be streamed
    stream*: AudioStream ## Audio stream
    frameCount*: uint32 ## Total number of frames (considering channels)
    looping*: bool ## Music looping enable
    ctxType*: int32 ## Type of music context (audio filetype)
    ctxData*: pointer ## Audio context data, depends on type

  VrDeviceInfo* {.bycopy.} = object ## VrDeviceInfo, Head-Mounted-Display device parameters
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

  VrStereoConfig* {.bycopy.} = object ## VrStereoConfig, VR stereo rendering configuration for simulator
    projection*: array[2, Matrix] ## VR projection matrices (per eye)
    viewOffset*: array[2, Matrix] ## VR view offset matrices (per eye)
    leftLensCenter*: array[2, float32] ## VR left lens center
    rightLensCenter*: array[2, float32] ## VR right lens center
    leftScreenCenter*: array[2, float32] ## VR left screen center
    rightScreenCenter*: array[2, float32] ## VR right screen center
    scale*: array[2, float32] ## VR distortion scale
    scaleIn*: array[2, float32] ## VR distortion scale in

  ConfigFlags* {.size: sizeof(cint).} = enum ## System/Window config flags
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
    InterlacedHint = 65536 ## Set to try enabling interlaced video format (for V3D)

  TraceLogLevel* {.size: sizeof(cint).} = enum ## Trace log level
    All ## Display all logs
    Trace ## Trace logging, intended for internal use only
    Debug ## Debug logging, used for internal debugging, it should be disabled on release builds
    Info ## Info logging, used for program execution info
    Warning ## Warning logging, used on recoverable failures
    Error ## Error logging, used on unrecoverable failures
    Fatal ## Fatal logging, used to abort program: exit(EXIT_FAILURE)
    None ## Disable logging

  KeyboardKey* {.size: sizeof(cint).} = enum ## Keyboard keys (US keyboard layout)
    Null = 0 ## Key: NULL, used for no key pressed
    Back = 4 ## Key: Android back button
    VolumeUp = 24 ## Key: Android volume up button
    VolumeDown = 25 ## Key: Android volume down button
    Space = 32 ## Key: Space
    Apostrophe = 39 ## Key: '
    Comma = 44 ## Key: ,
    Minus = 45 ## Key: -
    Period = 46 ## Key: .
    Slash = 47 ## Key: /
    Zero = 48 ## Key: 0
    One = 49 ## Key: 1
    Two = 50 ## Key: 2
    Three = 51 ## Key: 3
    Four = 52 ## Key: 4
    Five = 53 ## Key: 5
    Six = 54 ## Key: 6
    Seven = 55 ## Key: 7
    Eight = 56 ## Key: 8
    Nine = 57 ## Key: 9
    Semicolon = 59 ## Key: ;
    Equal = 61 ## Key: =
    A = 65 ## Key: A | a
    B = 66 ## Key: B | b
    C = 67 ## Key: C | c
    D = 68 ## Key: D | d
    E = 69 ## Key: E | e
    F = 70 ## Key: F | f
    G = 71 ## Key: G | g
    H = 72 ## Key: H | h
    I = 73 ## Key: I | i
    J = 74 ## Key: J | j
    K = 75 ## Key: K | k
    L = 76 ## Key: L | l
    M = 77 ## Key: M | m
    N = 78 ## Key: N | n
    O = 79 ## Key: O | o
    P = 80 ## Key: P | p
    Q = 81 ## Key: Q | q
    R = 82 ## Key: R | r
    S = 83 ## Key: S | s
    T = 84 ## Key: T | t
    U = 85 ## Key: U | u
    V = 86 ## Key: V | v
    W = 87 ## Key: W | w
    X = 88 ## Key: X | x
    Y = 89 ## Key: Y | y
    Z = 90 ## Key: Z | z
    LeftBracket = 91 ## Key: [
    Backslash = 92 ## Key: '\'
    RightBracket = 93 ## Key: ]
    Grave = 96 ## Key: `
    Escape = 256 ## Key: Esc
    Enter = 257 ## Key: Enter
    Tab = 258 ## Key: Tab
    Backspace = 259 ## Key: Backspace
    Insert = 260 ## Key: Ins
    Delete = 261 ## Key: Del
    Right = 262 ## Key: Cursor right
    Left = 263 ## Key: Cursor left
    Down = 264 ## Key: Cursor down
    Up = 265 ## Key: Cursor up
    PageUp = 266 ## Key: Page up
    PageDown = 267 ## Key: Page down
    Home = 268 ## Key: Home
    End = 269 ## Key: End
    CapsLock = 280 ## Key: Caps lock
    ScrollLock = 281 ## Key: Scroll down
    NumLock = 282 ## Key: Num lock
    PrintScreen = 283 ## Key: Print screen
    Pause = 284 ## Key: Pause
    F1 = 290 ## Key: F1
    F2 = 291 ## Key: F2
    F3 = 292 ## Key: F3
    F4 = 293 ## Key: F4
    F5 = 294 ## Key: F5
    F6 = 295 ## Key: F6
    F7 = 296 ## Key: F7
    F8 = 297 ## Key: F8
    F9 = 298 ## Key: F9
    F10 = 299 ## Key: F10
    F11 = 300 ## Key: F11
    F12 = 301 ## Key: F12
    Kp0 = 320 ## Key: Keypad 0
    Kp1 = 321 ## Key: Keypad 1
    Kp2 = 322 ## Key: Keypad 2
    Kp3 = 323 ## Key: Keypad 3
    Kp4 = 324 ## Key: Keypad 4
    Kp5 = 325 ## Key: Keypad 5
    Kp6 = 326 ## Key: Keypad 6
    Kp7 = 327 ## Key: Keypad 7
    Kp8 = 328 ## Key: Keypad 8
    Kp9 = 329 ## Key: Keypad 9
    KpDecimal = 330 ## Key: Keypad .
    KpDivide = 331 ## Key: Keypad /
    KpMultiply = 332 ## Key: Keypad *
    KpSubtract = 333 ## Key: Keypad -
    KpAdd = 334 ## Key: Keypad +
    KpEnter = 335 ## Key: Keypad Enter
    KpEqual = 336 ## Key: Keypad =
    LeftShift = 340 ## Key: Shift left
    LeftControl = 341 ## Key: Control left
    LeftAlt = 342 ## Key: Alt left
    LeftSuper = 343 ## Key: Super left
    RightShift = 344 ## Key: Shift right
    RightControl = 345 ## Key: Control right
    RightAlt = 346 ## Key: Alt right
    RightSuper = 347 ## Key: Super right
    KbMenu = 348 ## Key: KB menu

  MouseButton* {.size: sizeof(cint).} = enum ## Mouse buttons
    Left ## Mouse button left
    Right ## Mouse button right
    Middle ## Mouse button middle (pressed wheel)
    Side ## Mouse button side (advanced mouse device)
    Extra ## Mouse button extra (advanced mouse device)
    Forward ## Mouse button fordward (advanced mouse device)
    Back ## Mouse button back (advanced mouse device)

  MouseCursor* {.size: sizeof(cint).} = enum ## Mouse cursor
    Default ## Default pointer shape
    Arrow ## Arrow shape
    Ibeam ## Text writing cursor shape
    Crosshair ## Cross shape
    PointingHand ## Pointing hand cursor
    ResizeEw ## Horizontal resize/move arrow shape
    ResizeNs ## Vertical resize/move arrow shape
    ResizeNwse ## Top-left to bottom-right diagonal resize/move arrow shape
    ResizeNesw ## The top-right to bottom-left diagonal resize/move arrow shape
    ResizeAll ## The omni-directional resize/move cursor shape
    NotAllowed ## The operation-not-allowed shape

  GamepadButton* {.size: sizeof(cint).} = enum ## Gamepad buttons
    Unknown ## Unknown button, just for error checking
    LeftFaceUp ## Gamepad left DPAD up button
    LeftFaceRight ## Gamepad left DPAD right button
    LeftFaceDown ## Gamepad left DPAD down button
    LeftFaceLeft ## Gamepad left DPAD left button
    RightFaceUp ## Gamepad right button up (i.e. PS3: Triangle, Xbox: Y)
    RightFaceRight ## Gamepad right button right (i.e. PS3: Square, Xbox: X)
    RightFaceDown ## Gamepad right button down (i.e. PS3: Cross, Xbox: A)
    RightFaceLeft ## Gamepad right button left (i.e. PS3: Circle, Xbox: B)
    LeftTrigger1 ## Gamepad top/back trigger left (first), it could be a trailing button
    LeftTrigger2 ## Gamepad top/back trigger left (second), it could be a trailing button
    RightTrigger1 ## Gamepad top/back trigger right (one), it could be a trailing button
    RightTrigger2 ## Gamepad top/back trigger right (second), it could be a trailing button
    MiddleLeft ## Gamepad center buttons, left one (i.e. PS3: Select)
    Middle ## Gamepad center buttons, middle one (i.e. PS3: PS, Xbox: XBOX)
    MiddleRight ## Gamepad center buttons, right one (i.e. PS3: Start)
    LeftThumb ## Gamepad joystick pressed button left
    RightThumb ## Gamepad joystick pressed button right

  GamepadAxis* {.size: sizeof(cint).} = enum ## Gamepad axis
    LeftX ## Gamepad left stick X axis
    LeftY ## Gamepad left stick Y axis
    RightX ## Gamepad right stick X axis
    RightY ## Gamepad right stick Y axis
    LeftTrigger ## Gamepad back trigger left, pressure level: [1..-1]
    RightTrigger ## Gamepad back trigger right, pressure level: [1..-1]

  MaterialMapIndex* {.size: sizeof(cint).} = enum ## Material map index
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

  ShaderLocationIndex* {.size: sizeof(cint).} = enum ## Shader location index
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

  ShaderUniformDataType* {.size: sizeof(cint).} = enum ## Shader uniform data type
    Float ## Shader uniform type: float
    Vec2 ## Shader uniform type: vec2 (2 float)
    Vec3 ## Shader uniform type: vec3 (3 float)
    Vec4 ## Shader uniform type: vec4 (4 float)
    Int ## Shader uniform type: int
    Ivec2 ## Shader uniform type: ivec2 (2 int)
    Ivec3 ## Shader uniform type: ivec3 (3 int)
    Ivec4 ## Shader uniform type: ivec4 (4 int)
    Sampler2d ## Shader uniform type: sampler2d

  ShaderAttributeDataType* {.size: sizeof(cint).} = enum ## Shader attribute data types
    Float ## Shader attribute type: float
    Vec2 ## Shader attribute type: vec2 (2 float)
    Vec3 ## Shader attribute type: vec3 (3 float)
    Vec4 ## Shader attribute type: vec4 (4 float)

  PixelFormat* {.size: sizeof(cint).} = enum ## Pixel formats
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

  TextureFilter* {.size: sizeof(cint).} = enum ## Texture parameters: filter mode
    Point ## No filter, just pixel approximation
    Bilinear ## Linear filtering
    Trilinear ## Trilinear filtering (linear with mipmaps)
    Anisotropic4x ## Anisotropic filtering 4x
    Anisotropic8x ## Anisotropic filtering 8x
    Anisotropic16x ## Anisotropic filtering 16x

  TextureWrap* {.size: sizeof(cint).} = enum ## Texture parameters: wrap mode
    Repeat ## Repeats texture in tiled mode
    Clamp ## Clamps texture to edge pixel in tiled mode
    MirrorRepeat ## Mirrors and repeats the texture in tiled mode
    MirrorClamp ## Mirrors and clamps to border the texture in tiled mode

  CubemapLayout* {.size: sizeof(cint).} = enum ## Cubemap layouts
    AutoDetect ## Automatically detect layout type
    LineVertical ## Layout is defined by a vertical line with faces
    LineHorizontal ## Layout is defined by an horizontal line with faces
    CrossThreeByFour ## Layout is defined by a 3x4 cross with cubemap faces
    CrossFourByThree ## Layout is defined by a 4x3 cross with cubemap faces
    Panorama ## Layout is defined by a panorama image (equirectangular map)

  FontType* {.size: sizeof(cint).} = enum ## Font type, defines generation method
    Default ## Default font generation, anti-aliased
    Bitmap ## Bitmap font generation, no anti-aliasing
    Sdf ## SDF font generation, requires external shader

  BlendMode* {.size: sizeof(cint).} = enum ## Color blending modes (pre-defined)
    Alpha ## Blend textures considering alpha (default)
    Additive ## Blend textures adding colors
    Multiplied ## Blend textures multiplying colors
    AddColors ## Blend textures adding colors (alternative)
    SubtractColors ## Blend textures subtracting colors (alternative)
    Custom ## Belnd textures using custom src/dst factors (use rlSetBlendMode())

  Gesture* {.size: sizeof(cint).} = enum ## Gesture
    None = 0 ## No gesture
    Tap = 1 ## Tap gesture
    Doubletap = 2 ## Double tap gesture
    Hold = 4 ## Hold gesture
    Drag = 8 ## Drag gesture
    SwipeRight = 16 ## Swipe right gesture
    SwipeLeft = 32 ## Swipe left gesture
    SwipeUp = 64 ## Swipe up gesture
    SwipeDown = 128 ## Swipe down gesture
    PinchIn = 256 ## Pinch in gesture
    PinchOut = 512 ## Pinch out gesture

  CameraMode* {.size: sizeof(cint).} = enum ## Camera system modes
    Custom ## Custom camera
    Free ## Free camera
    Orbital ## Orbital camera
    FirstPerson ## First person camera
    ThirdPerson ## Third person camera

  CameraProjection* {.size: sizeof(cint).} = enum ## Camera projection
    Perspective ## Perspective projection
    Orthographic ## Orthographic projection

  NPatchLayout* {.size: sizeof(cint).} = enum ## N-patch layout
    NinePatch ## Npatch layout: 3x3 tiles
    ThreePatchVertical ## Npatch layout: 1x3 tiles
    ThreePatchHorizontal ## Npatch layout: 3x1 tiles

type va_list* {.importc: "va_list", header: "<stdarg.h>".} = object ## Only used by TraceLogCallback
proc vprintf*(format: cstring, args: va_list) {.cdecl, importc: "vprintf", header: "<stdio.h>".}

## Callbacks to hook some internal functions
## WARNING: This callbacks are intended for advance users
type
  TraceLogCallback* = proc (logLevel: cint; text: cstring; args: va_list) {.cdecl.} ## Logging: Redirect trace log messages
  LoadFileDataCallback* = proc (fileName: cstring; bytesRead: ptr uint32): ptr UncheckedArray[uint8] {.
      cdecl.} ## FileIO: Load binary data
  SaveFileDataCallback* = proc (fileName: cstring; data: pointer; bytesToWrite: uint32): bool {.
      cdecl.} ## FileIO: Save binary data
  LoadFileTextCallback* = proc (fileName: cstring): cstring {.cdecl.} ## FileIO: Load text data
  SaveFileTextCallback* = proc (fileName: cstring; text: cstring): bool {.cdecl.} ## FileIO: Save text data

  Enums = ConfigFlags|Gesture
  Flag*[E: Enums] = distinct uint32

proc flag*[E: Enums](e: varargs[E]): Flag[E] {.inline.} =
  var res = 0'u32
  for val in items(e):
    res = res or uint32(val)
  Flag[E](res)

const
  Menu* = KeyboardKey.R ## Key: Android menu button

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

proc initWindow*(width: int32, height: int32, title: cstring) {.importc: "InitWindow", rlapi.}
  ## Initialize window and OpenGL context
proc windowShouldClose*(): bool {.importc: "WindowShouldClose", rlapi.}
  ## Check if KEY_ESCAPE pressed or Close icon pressed
proc closeWindow*() {.importc: "CloseWindow", rlapi.}
  ## Close window and unload OpenGL context
proc isWindowReady*(): bool {.importc: "IsWindowReady", rlapi.}
  ## Check if window has been initialized successfully
proc isWindowFullscreen*(): bool {.importc: "IsWindowFullscreen", rlapi.}
  ## Check if window is currently fullscreen
proc isWindowHidden*(): bool {.importc: "IsWindowHidden", rlapi.}
  ## Check if window is currently hidden (only PLATFORM_DESKTOP)
proc isWindowMinimized*(): bool {.importc: "IsWindowMinimized", rlapi.}
  ## Check if window is currently minimized (only PLATFORM_DESKTOP)
proc isWindowMaximized*(): bool {.importc: "IsWindowMaximized", rlapi.}
  ## Check if window is currently maximized (only PLATFORM_DESKTOP)
proc isWindowFocused*(): bool {.importc: "IsWindowFocused", rlapi.}
  ## Check if window is currently focused (only PLATFORM_DESKTOP)
proc isWindowResized*(): bool {.importc: "IsWindowResized", rlapi.}
  ## Check if window has been resized last frame
proc isWindowState*(flag: ConfigFlags): bool {.importc: "IsWindowState", rlapi.}
  ## Check if one specific window flag is enabled
proc setWindowState*(flags: Flag[ConfigFlags]) {.importc: "SetWindowState", rlapi.}
  ## Set window configuration state using flags
proc clearWindowState*(flags: Flag[ConfigFlags]) {.importc: "ClearWindowState", rlapi.}
  ## Clear window configuration state flags
proc toggleFullscreen*() {.importc: "ToggleFullscreen", rlapi.}
  ## Toggle window state: fullscreen/windowed (only PLATFORM_DESKTOP)
proc maximizeWindow*() {.importc: "MaximizeWindow", rlapi.}
  ## Set window state: maximized, if resizable (only PLATFORM_DESKTOP)
proc minimizeWindow*() {.importc: "MinimizeWindow", rlapi.}
  ## Set window state: minimized, if resizable (only PLATFORM_DESKTOP)
proc restoreWindow*() {.importc: "RestoreWindow", rlapi.}
  ## Set window state: not minimized/maximized (only PLATFORM_DESKTOP)
proc setWindowIcon*(image: Image) {.importc: "SetWindowIcon", rlapi.}
  ## Set icon for window (only PLATFORM_DESKTOP)
proc setWindowTitle*(title: cstring) {.importc: "SetWindowTitle", rlapi.}
  ## Set title for window (only PLATFORM_DESKTOP)
proc setWindowPosition*(x: int32, y: int32) {.importc: "SetWindowPosition", rlapi.}
  ## Set window position on screen (only PLATFORM_DESKTOP)
proc setWindowMonitor*(monitor: int32) {.importc: "SetWindowMonitor", rlapi.}
  ## Set monitor for the current window (fullscreen mode)
proc setWindowMinSize*(width: int32, height: int32) {.importc: "SetWindowMinSize", rlapi.}
  ## Set window minimum dimensions (for FLAG_WINDOW_RESIZABLE)
proc setWindowSize*(width: int32, height: int32) {.importc: "SetWindowSize", rlapi.}
  ## Set window dimensions
proc getWindowHandle*(): pointer {.importc: "GetWindowHandle", rlapi.}
  ## Get native window handle
proc getScreenWidth*(): int32 {.importc: "GetScreenWidth", rlapi.}
  ## Get current screen width
proc getScreenHeight*(): int32 {.importc: "GetScreenHeight", rlapi.}
  ## Get current screen height
proc getRenderWidth*(): int32 {.importc: "GetRenderWidth", rlapi.}
  ## Get current render width (it considers HiDPI)
proc getRenderHeight*(): int32 {.importc: "GetRenderHeight", rlapi.}
  ## Get current render height (it considers HiDPI)
proc getMonitorCount*(): int32 {.importc: "GetMonitorCount", rlapi.}
  ## Get number of connected monitors
proc getCurrentMonitor*(): int32 {.importc: "GetCurrentMonitor", rlapi.}
  ## Get current connected monitor
proc getMonitorPosition*(monitor: int32): Vector2 {.importc: "GetMonitorPosition", rlapi.}
  ## Get specified monitor position
proc getMonitorWidth*(monitor: int32): int32 {.importc: "GetMonitorWidth", rlapi.}
  ## Get specified monitor width (max available by monitor)
proc getMonitorHeight*(monitor: int32): int32 {.importc: "GetMonitorHeight", rlapi.}
  ## Get specified monitor height (max available by monitor)
proc getMonitorPhysicalWidth*(monitor: int32): int32 {.importc: "GetMonitorPhysicalWidth", rlapi.}
  ## Get specified monitor physical width in millimetres
proc getMonitorPhysicalHeight*(monitor: int32): int32 {.importc: "GetMonitorPhysicalHeight", rlapi.}
  ## Get specified monitor physical height in millimetres
proc getMonitorRefreshRate*(monitor: int32): int32 {.importc: "GetMonitorRefreshRate", rlapi.}
  ## Get specified monitor refresh rate
proc getWindowPosition*(): Vector2 {.importc: "GetWindowPosition", rlapi.}
  ## Get window position XY on monitor
proc getWindowScaleDPI*(): Vector2 {.importc: "GetWindowScaleDPI", rlapi.}
  ## Get window scale DPI factor
proc getMonitorNamePriv(monitor: int32): cstring {.importc: "GetMonitorName", rlapi.}
proc setClipboardText*(text: cstring) {.importc: "SetClipboardText", rlapi.}
  ## Set clipboard text content
proc getClipboardTextPriv(): cstring {.importc: "GetClipboardText", rlapi.}
proc swapScreenBuffer*() {.importc: "SwapScreenBuffer", rlapi.}
  ## Swap back buffer with front buffer (screen drawing)
proc pollInputEvents*() {.importc: "PollInputEvents", rlapi.}
  ## Register all input events
proc waitTime*(ms: float32) {.importc: "WaitTime", rlapi.}
  ## Wait for some milliseconds (halt program execution)
proc showCursor*() {.importc: "ShowCursor", rlapi.}
  ## Shows cursor
proc hideCursor*() {.importc: "HideCursor", rlapi.}
  ## Hides cursor
proc isCursorHidden*(): bool {.importc: "IsCursorHidden", rlapi.}
  ## Check if cursor is not visible
proc enableCursor*() {.importc: "EnableCursor", rlapi.}
  ## Enables cursor (unlock cursor)
proc disableCursor*() {.importc: "DisableCursor", rlapi.}
  ## Disables cursor (lock cursor)
proc isCursorOnScreen*(): bool {.importc: "IsCursorOnScreen", rlapi.}
  ## Check if cursor is on the screen
proc clearBackground*(color: Color) {.importc: "ClearBackground", rlapi.}
  ## Set background color (framebuffer clear color)
proc beginDrawing*() {.importc: "BeginDrawing", rlapi.}
  ## Setup canvas (framebuffer) to start drawing
proc endDrawing*() {.importc: "EndDrawing", rlapi.}
  ## End canvas drawing and swap buffers (double buffering)
proc beginMode2D*(camera: Camera2D) {.importc: "BeginMode2D", rlapi.}
  ## Begin 2D mode with custom camera (2D)
proc endMode2D*() {.importc: "EndMode2D", rlapi.}
  ## Ends 2D mode with custom camera
proc beginMode3D*(camera: Camera3D) {.importc: "BeginMode3D", rlapi.}
  ## Begin 3D mode with custom camera (3D)
proc endMode3D*() {.importc: "EndMode3D", rlapi.}
  ## Ends 3D mode and returns to default 2D orthographic mode
proc beginTextureMode*(target: RenderTexture2D) {.importc: "BeginTextureMode", rlapi.}
  ## Begin drawing to render texture
proc endTextureMode*() {.importc: "EndTextureMode", rlapi.}
  ## Ends drawing to render texture
proc beginShaderMode*(shader: Shader) {.importc: "BeginShaderMode", rlapi.}
  ## Begin custom shader drawing
proc endShaderMode*() {.importc: "EndShaderMode", rlapi.}
  ## End custom shader drawing (use default shader)
proc beginBlendMode*(mode: BlendMode) {.importc: "BeginBlendMode", rlapi.}
  ## Begin blending mode (alpha, additive, multiplied, subtract, custom)
proc endBlendMode*() {.importc: "EndBlendMode", rlapi.}
  ## End blending mode (reset to default: alpha blending)
proc beginScissorMode*(x: int32, y: int32, width: int32, height: int32) {.importc: "BeginScissorMode", rlapi.}
  ## Begin scissor mode (define screen area for following drawing)
proc endScissorMode*() {.importc: "EndScissorMode", rlapi.}
  ## End scissor mode
proc beginVrStereoMode*(config: VrStereoConfig) {.importc: "BeginVrStereoMode", rlapi.}
  ## Begin stereo rendering (requires VR simulator)
proc endVrStereoMode*() {.importc: "EndVrStereoMode", rlapi.}
  ## End stereo rendering (requires VR simulator)
proc loadVrStereoConfig*(device: VrDeviceInfo): VrStereoConfig {.importc: "LoadVrStereoConfig", rlapi.}
  ## Load VR stereo config for VR simulator device parameters
proc unloadVrStereoConfig*(config: VrStereoConfig) {.importc: "UnloadVrStereoConfig", rlapi.}
  ## Unload VR stereo config
proc loadShader*(vsFileName: cstring, fsFileName: cstring): Shader {.importc: "LoadShader", rlapi.}
  ## Load shader from files and bind default locations
proc loadShaderFromMemory*(vsCode: cstring, fsCode: cstring): Shader {.importc: "LoadShaderFromMemory", rlapi.}
  ## Load shader from code strings and bind default locations
proc getShaderLocation*(shader: Shader, uniformName: cstring): int32 {.importc: "GetShaderLocation", rlapi.}
  ## Get shader uniform location
proc getShaderLocationAttrib*(shader: Shader, attribName: cstring): int32 {.importc: "GetShaderLocationAttrib", rlapi.}
  ## Get shader attribute location
proc setShaderValue*(shader: Shader, locIndex: int32, value: pointer, uniformType: ShaderUniformDataType) {.importc: "SetShaderValue", rlapi.}
  ## Set shader uniform value
proc setShaderValueV*(shader: Shader, locIndex: int32, value: pointer, uniformType: ShaderUniformDataType, count: int32) {.importc: "SetShaderValueV", rlapi.}
  ## Set shader uniform value vector
proc setShaderValueMatrix*(shader: Shader, locIndex: int32, mat: Matrix) {.importc: "SetShaderValueMatrix", rlapi.}
  ## Set shader uniform value (matrix 4x4)
proc setShaderValueTexture*(shader: Shader, locIndex: int32, texture: Texture2D) {.importc: "SetShaderValueTexture", rlapi.}
  ## Set shader uniform value for texture (sampler2d)
proc unloadShader*(shader: Shader) {.importc: "UnloadShader", rlapi.}
  ## Unload shader from GPU memory (VRAM)
proc getMouseRay*(mousePosition: Vector2, camera: Camera): Ray {.importc: "GetMouseRay", rlapi.}
  ## Get a ray trace from mouse position
proc getCameraMatrix*(camera: Camera): Matrix {.importc: "GetCameraMatrix", rlapi.}
  ## Get camera transform matrix (view matrix)
proc getCameraMatrix2D*(camera: Camera2D): Matrix {.importc: "GetCameraMatrix2D", rlapi.}
  ## Get camera 2d transform matrix
proc getWorldToScreen*(position: Vector3, camera: Camera): Vector2 {.importc: "GetWorldToScreen", rlapi.}
  ## Get the screen space position for a 3d world space position
proc getWorldToScreenEx*(position: Vector3, camera: Camera, width: int32, height: int32): Vector2 {.importc: "GetWorldToScreenEx", rlapi.}
  ## Get size position for a 3d world space position
proc getWorldToScreen2D*(position: Vector2, camera: Camera2D): Vector2 {.importc: "GetWorldToScreen2D", rlapi.}
  ## Get the screen space position for a 2d camera world space position
proc getScreenToWorld2D*(position: Vector2, camera: Camera2D): Vector2 {.importc: "GetScreenToWorld2D", rlapi.}
  ## Get the world space position for a 2d camera screen space position
proc setTargetFPS*(fps: int32) {.importc: "SetTargetFPS", rlapi.}
  ## Set target FPS (maximum)
proc getFPS*(): int32 {.importc: "GetFPS", rlapi.}
  ## Get current FPS
proc getFrameTime*(): float32 {.importc: "GetFrameTime", rlapi.}
  ## Get time in seconds for last frame drawn (delta time)
proc getTime*(): float {.importc: "GetTime", rlapi.}
  ## Get elapsed time in seconds since InitWindow()
proc takeScreenshot*(fileName: cstring) {.importc: "TakeScreenshot", rlapi.}
  ## Takes a screenshot of current screen (filename extension defines format)
proc setConfigFlags*(flags: Flag[ConfigFlags]) {.importc: "SetConfigFlags", rlapi.}
  ## Setup init configuration flags (view FLAGS)
proc traceLog*(logLevel: TraceLogLevel, text: cstring) {.importc: "TraceLog", varargs, rlapi.}
  ## Show trace log messages (LOG_DEBUG, LOG_INFO, LOG_WARNING, LOG_ERROR...)
proc setTraceLogLevel*(logLevel: TraceLogLevel) {.importc: "SetTraceLogLevel", rlapi.}
  ## Set the current threshold (minimum) log level
proc memAlloc(size: int32): pointer {.importc: "MemAlloc", rlapi.}
proc memRealloc(`ptr`: pointer, size: int32): pointer {.importc: "MemRealloc", rlapi.}
proc memFree(`ptr`: pointer) {.importc: "MemFree", rlapi.}
proc setTraceLogCallback*(callback: TraceLogCallback) {.importc: "SetTraceLogCallback", rlapi.}
  ## Set custom trace log
proc setLoadFileDataCallback*(callback: LoadFileDataCallback) {.importc: "SetLoadFileDataCallback", rlapi.}
  ## Set custom file binary data loader
proc setSaveFileDataCallback*(callback: SaveFileDataCallback) {.importc: "SetSaveFileDataCallback", rlapi.}
  ## Set custom file binary data saver
proc setLoadFileTextCallback*(callback: LoadFileTextCallback) {.importc: "SetLoadFileTextCallback", rlapi.}
  ## Set custom file text data loader
proc setSaveFileTextCallback*(callback: SaveFileTextCallback) {.importc: "SetSaveFileTextCallback", rlapi.}
  ## Set custom file text data saver
proc isFileDropped*(): bool {.importc: "IsFileDropped", rlapi.}
  ## Check if a file has been dropped into window
proc getDroppedFilesPriv(count: ptr int32): cstringArray {.importc: "GetDroppedFiles", rlapi.}
proc clearDroppedFiles*() {.importc: "ClearDroppedFiles", rlapi.}
  ## Clear dropped files paths buffer (free memory)
proc saveStorageValue*(position: uint32, value: int32): bool {.importc: "SaveStorageValue", rlapi.}
  ## Save integer value to storage file (to defined position), returns true on success
proc loadStorageValue*(position: uint32): int32 {.importc: "LoadStorageValue", rlapi.}
  ## Load integer value from storage file (from defined position)
proc isKeyPressed*(key: KeyboardKey): bool {.importc: "IsKeyPressed", rlapi.}
  ## Check if a key has been pressed once
proc isKeyDown*(key: KeyboardKey): bool {.importc: "IsKeyDown", rlapi.}
  ## Check if a key is being pressed
proc isKeyReleased*(key: KeyboardKey): bool {.importc: "IsKeyReleased", rlapi.}
  ## Check if a key has been released once
proc isKeyUp*(key: KeyboardKey): bool {.importc: "IsKeyUp", rlapi.}
  ## Check if a key is NOT being pressed
proc setExitKey*(key: KeyboardKey) {.importc: "SetExitKey", rlapi.}
  ## Set a custom key to exit program (default is ESC)
proc getKeyPressed*(): KeyboardKey {.importc: "GetKeyPressed", rlapi.}
  ## Get key pressed (keycode), call it multiple times for keys queued, returns 0 when the queue is empty
proc getCharPressed*(): int32 {.importc: "GetCharPressed", rlapi.}
  ## Get char pressed (unicode), call it multiple times for chars queued, returns 0 when the queue is empty
proc isGamepadAvailable*(gamepad: int32): bool {.importc: "IsGamepadAvailable", rlapi.}
  ## Check if a gamepad is available
proc getGamepadNamePriv(gamepad: int32): cstring {.importc: "GetGamepadName", rlapi.}
proc isGamepadButtonPressed*(gamepad: int32, button: GamepadButton): bool {.importc: "IsGamepadButtonPressed", rlapi.}
  ## Check if a gamepad button has been pressed once
proc isGamepadButtonDown*(gamepad: int32, button: GamepadButton): bool {.importc: "IsGamepadButtonDown", rlapi.}
  ## Check if a gamepad button is being pressed
proc isGamepadButtonReleased*(gamepad: int32, button: GamepadButton): bool {.importc: "IsGamepadButtonReleased", rlapi.}
  ## Check if a gamepad button has been released once
proc isGamepadButtonUp*(gamepad: int32, button: GamepadButton): bool {.importc: "IsGamepadButtonUp", rlapi.}
  ## Check if a gamepad button is NOT being pressed
proc getGamepadButtonPressed*(): GamepadButton {.importc: "GetGamepadButtonPressed", rlapi.}
  ## Get the last gamepad button pressed
proc getGamepadAxisCount*(gamepad: int32): int32 {.importc: "GetGamepadAxisCount", rlapi.}
  ## Get gamepad axis count for a gamepad
proc getGamepadAxisMovement*(gamepad: int32, axis: GamepadAxis): float32 {.importc: "GetGamepadAxisMovement", rlapi.}
  ## Get axis movement value for a gamepad axis
proc setGamepadMappings*(mappings: cstring): int32 {.importc: "SetGamepadMappings", rlapi.}
  ## Set internal gamepad mappings (SDL_GameControllerDB)
proc isMouseButtonPressed*(button: MouseButton): bool {.importc: "IsMouseButtonPressed", rlapi.}
  ## Check if a mouse button has been pressed once
proc isMouseButtonDown*(button: MouseButton): bool {.importc: "IsMouseButtonDown", rlapi.}
  ## Check if a mouse button is being pressed
proc isMouseButtonReleased*(button: MouseButton): bool {.importc: "IsMouseButtonReleased", rlapi.}
  ## Check if a mouse button has been released once
proc isMouseButtonUp*(button: MouseButton): bool {.importc: "IsMouseButtonUp", rlapi.}
  ## Check if a mouse button is NOT being pressed
proc getMouseX*(): int32 {.importc: "GetMouseX", rlapi.}
  ## Get mouse position X
proc getMouseY*(): int32 {.importc: "GetMouseY", rlapi.}
  ## Get mouse position Y
proc getMousePosition*(): Vector2 {.importc: "GetMousePosition", rlapi.}
  ## Get mouse position XY
proc getMouseDelta*(): Vector2 {.importc: "GetMouseDelta", rlapi.}
  ## Get mouse delta between frames
proc setMousePosition*(x: int32, y: int32) {.importc: "SetMousePosition", rlapi.}
  ## Set mouse position XY
proc setMouseOffset*(offsetX: int32, offsetY: int32) {.importc: "SetMouseOffset", rlapi.}
  ## Set mouse offset
proc setMouseScale*(scaleX: float32, scaleY: float32) {.importc: "SetMouseScale", rlapi.}
  ## Set mouse scaling
proc getMouseWheelMove*(): float32 {.importc: "GetMouseWheelMove", rlapi.}
  ## Get mouse wheel movement Y
proc setMouseCursor*(cursor: MouseCursor) {.importc: "SetMouseCursor", rlapi.}
  ## Set mouse cursor
proc getTouchX*(): int32 {.importc: "GetTouchX", rlapi.}
  ## Get touch position X for touch point 0 (relative to screen size)
proc getTouchY*(): int32 {.importc: "GetTouchY", rlapi.}
  ## Get touch position Y for touch point 0 (relative to screen size)
proc getTouchPosition*(index: int32): Vector2 {.importc: "GetTouchPosition", rlapi.}
  ## Get touch position XY for a touch point index (relative to screen size)
proc getTouchPointId*(index: int32): int32 {.importc: "GetTouchPointId", rlapi.}
  ## Get touch point identifier for given index
proc getTouchPointCount*(): int32 {.importc: "GetTouchPointCount", rlapi.}
  ## Get number of touch points
proc setGesturesEnabled*(flags: Flag[Gesture]) {.importc: "SetGesturesEnabled", rlapi.}
  ## Enable a set of gestures using flags
proc isGestureDetected*(gesture: Gesture): bool {.importc: "IsGestureDetected", rlapi.}
  ## Check if a gesture have been detected
proc getGestureDetected*(): Gesture {.importc: "GetGestureDetected", rlapi.}
  ## Get latest detected gesture
proc getGestureHoldDuration*(): float32 {.importc: "GetGestureHoldDuration", rlapi.}
  ## Get gesture hold time in milliseconds
proc getGestureDragVector*(): Vector2 {.importc: "GetGestureDragVector", rlapi.}
  ## Get gesture drag vector
proc getGestureDragAngle*(): float32 {.importc: "GetGestureDragAngle", rlapi.}
  ## Get gesture drag angle
proc getGesturePinchVector*(): Vector2 {.importc: "GetGesturePinchVector", rlapi.}
  ## Get gesture pinch delta
proc getGesturePinchAngle*(): float32 {.importc: "GetGesturePinchAngle", rlapi.}
  ## Get gesture pinch angle
proc setCameraMode*(camera: Camera, mode: CameraMode) {.importc: "SetCameraMode", rlapi.}
  ## Set camera mode (multiple camera modes available)
proc updateCamera*(camera: var Camera) {.importc: "UpdateCamera", rlapi.}
  ## Update camera position for selected mode
proc setCameraPanControl*(keyPan: KeyboardKey) {.importc: "SetCameraPanControl", rlapi.}
  ## Set camera pan key to combine with mouse movement (free camera)
proc setCameraAltControl*(keyAlt: KeyboardKey) {.importc: "SetCameraAltControl", rlapi.}
  ## Set camera alt key to combine with mouse movement (free camera)
proc setCameraSmoothZoomControl*(keySmoothZoom: KeyboardKey) {.importc: "SetCameraSmoothZoomControl", rlapi.}
  ## Set camera smooth zoom key to combine with mouse (free camera)
proc setCameraMoveControls*(keyFront: KeyboardKey, keyBack: KeyboardKey, keyRight: KeyboardKey, keyLeft: KeyboardKey, keyUp: KeyboardKey, keyDown: KeyboardKey) {.importc: "SetCameraMoveControls", rlapi.}
  ## Set camera move controls (1st person and 3rd person cameras)
proc setShapesTexture*(texture: Texture2D, source: Rectangle) {.importc: "SetShapesTexture", rlapi.}
  ## Set texture and rectangle to be used on shapes drawing
proc drawPixel*(posX: int32, posY: int32, color: Color) {.importc: "DrawPixel", rlapi.}
  ## Draw a pixel
proc drawPixelV*(position: Vector2, color: Color) {.importc: "DrawPixelV", rlapi.}
  ## Draw a pixel (Vector version)
proc drawLine*(startPosX: int32, startPosY: int32, endPosX: int32, endPosY: int32, color: Color) {.importc: "DrawLine", rlapi.}
  ## Draw a line
proc drawLineV*(startPos: Vector2, endPos: Vector2, color: Color) {.importc: "DrawLineV", rlapi.}
  ## Draw a line (Vector version)
proc drawLineEx*(startPos: Vector2, endPos: Vector2, thick: float32, color: Color) {.importc: "DrawLineEx", rlapi.}
  ## Draw a line defining thickness
proc drawLineBezier*(startPos: Vector2, endPos: Vector2, thick: float32, color: Color) {.importc: "DrawLineBezier", rlapi.}
  ## Draw a line using cubic-bezier curves in-out
proc drawLineBezierQuad*(startPos: Vector2, endPos: Vector2, controlPos: Vector2, thick: float32, color: Color) {.importc: "DrawLineBezierQuad", rlapi.}
  ## Draw line using quadratic bezier curves with a control point
proc drawLineBezierCubic*(startPos: Vector2, endPos: Vector2, startControlPos: Vector2, endControlPos: Vector2, thick: float32, color: Color) {.importc: "DrawLineBezierCubic", rlapi.}
  ## Draw line using cubic bezier curves with 2 control points
proc drawLineStripPriv(points: ptr UncheckedArray[Vector2], pointCount: int32, color: Color) {.importc: "DrawLineStrip", rlapi.}
proc drawCircle*(centerX: int32, centerY: int32, radius: float32, color: Color) {.importc: "DrawCircle", rlapi.}
  ## Draw a color-filled circle
proc drawCircleSector*(center: Vector2, radius: float32, startAngle: float32, endAngle: float32, segments: int32, color: Color) {.importc: "DrawCircleSector", rlapi.}
  ## Draw a piece of a circle
proc drawCircleSectorLines*(center: Vector2, radius: float32, startAngle: float32, endAngle: float32, segments: int32, color: Color) {.importc: "DrawCircleSectorLines", rlapi.}
  ## Draw circle sector outline
proc drawCircleGradient*(centerX: int32, centerY: int32, radius: float32, color1: Color, color2: Color) {.importc: "DrawCircleGradient", rlapi.}
  ## Draw a gradient-filled circle
proc drawCircleV*(center: Vector2, radius: float32, color: Color) {.importc: "DrawCircleV", rlapi.}
  ## Draw a color-filled circle (Vector version)
proc drawCircleLines*(centerX: int32, centerY: int32, radius: float32, color: Color) {.importc: "DrawCircleLines", rlapi.}
  ## Draw circle outline
proc drawEllipse*(centerX: int32, centerY: int32, radiusH: float32, radiusV: float32, color: Color) {.importc: "DrawEllipse", rlapi.}
  ## Draw ellipse
proc drawEllipseLines*(centerX: int32, centerY: int32, radiusH: float32, radiusV: float32, color: Color) {.importc: "DrawEllipseLines", rlapi.}
  ## Draw ellipse outline
proc drawRing*(center: Vector2, innerRadius: float32, outerRadius: float32, startAngle: float32, endAngle: float32, segments: int32, color: Color) {.importc: "DrawRing", rlapi.}
  ## Draw ring
proc drawRingLines*(center: Vector2, innerRadius: float32, outerRadius: float32, startAngle: float32, endAngle: float32, segments: int32, color: Color) {.importc: "DrawRingLines", rlapi.}
  ## Draw ring outline
proc drawRectangle*(posX: int32, posY: int32, width: int32, height: int32, color: Color) {.importc: "DrawRectangle", rlapi.}
  ## Draw a color-filled rectangle
proc drawRectangleV*(position: Vector2, size: Vector2, color: Color) {.importc: "DrawRectangleV", rlapi.}
  ## Draw a color-filled rectangle (Vector version)
proc drawRectangleRec*(rec: Rectangle, color: Color) {.importc: "DrawRectangleRec", rlapi.}
  ## Draw a color-filled rectangle
proc drawRectanglePro*(rec: Rectangle, origin: Vector2, rotation: float32, color: Color) {.importc: "DrawRectanglePro", rlapi.}
  ## Draw a color-filled rectangle with pro parameters
proc drawRectangleGradientV*(posX: int32, posY: int32, width: int32, height: int32, color1: Color, color2: Color) {.importc: "DrawRectangleGradientV", rlapi.}
  ## Draw a vertical-gradient-filled rectangle
proc drawRectangleGradientH*(posX: int32, posY: int32, width: int32, height: int32, color1: Color, color2: Color) {.importc: "DrawRectangleGradientH", rlapi.}
  ## Draw a horizontal-gradient-filled rectangle
proc drawRectangleGradientEx*(rec: Rectangle, col1: Color, col2: Color, col3: Color, col4: Color) {.importc: "DrawRectangleGradientEx", rlapi.}
  ## Draw a gradient-filled rectangle with custom vertex colors
proc drawRectangleLines*(posX: int32, posY: int32, width: int32, height: int32, color: Color) {.importc: "DrawRectangleLines", rlapi.}
  ## Draw rectangle outline
proc drawRectangleLinesEx*(rec: Rectangle, lineThick: float32, color: Color) {.importc: "DrawRectangleLinesEx", rlapi.}
  ## Draw rectangle outline with extended parameters
proc drawRectangleRounded*(rec: Rectangle, roundness: float32, segments: int32, color: Color) {.importc: "DrawRectangleRounded", rlapi.}
  ## Draw rectangle with rounded edges
proc drawRectangleRoundedLines*(rec: Rectangle, roundness: float32, segments: int32, lineThick: float32, color: Color) {.importc: "DrawRectangleRoundedLines", rlapi.}
  ## Draw rectangle with rounded edges outline
proc drawTriangle*(v1: Vector2, v2: Vector2, v3: Vector2, color: Color) {.importc: "DrawTriangle", rlapi.}
  ## Draw a color-filled triangle (vertex in counter-clockwise order!)
proc drawTriangleLines*(v1: Vector2, v2: Vector2, v3: Vector2, color: Color) {.importc: "DrawTriangleLines", rlapi.}
  ## Draw triangle outline (vertex in counter-clockwise order!)
proc drawTriangleFanPriv(points: ptr UncheckedArray[Vector2], pointCount: int32, color: Color) {.importc: "DrawTriangleFan", rlapi.}
proc drawTriangleStripPriv(points: ptr UncheckedArray[Vector2], pointCount: int32, color: Color) {.importc: "DrawTriangleStrip", rlapi.}
proc drawPoly*(center: Vector2, sides: int32, radius: float32, rotation: float32, color: Color) {.importc: "DrawPoly", rlapi.}
  ## Draw a regular polygon (Vector version)
proc drawPolyLines*(center: Vector2, sides: int32, radius: float32, rotation: float32, color: Color) {.importc: "DrawPolyLines", rlapi.}
  ## Draw a polygon outline of n sides
proc drawPolyLinesEx*(center: Vector2, sides: int32, radius: float32, rotation: float32, lineThick: float32, color: Color) {.importc: "DrawPolyLinesEx", rlapi.}
  ## Draw a polygon outline of n sides with extended parameters
proc checkCollisionRecs*(rec1: Rectangle, rec2: Rectangle): bool {.importc: "CheckCollisionRecs", rlapi.}
  ## Check collision between two rectangles
proc checkCollisionCircles*(center1: Vector2, radius1: float32, center2: Vector2, radius2: float32): bool {.importc: "CheckCollisionCircles", rlapi.}
  ## Check collision between two circles
proc checkCollisionCircleRec*(center: Vector2, radius: float32, rec: Rectangle): bool {.importc: "CheckCollisionCircleRec", rlapi.}
  ## Check collision between circle and rectangle
proc checkCollisionPointRec*(point: Vector2, rec: Rectangle): bool {.importc: "CheckCollisionPointRec", rlapi.}
  ## Check if point is inside rectangle
proc checkCollisionPointCircle*(point: Vector2, center: Vector2, radius: float32): bool {.importc: "CheckCollisionPointCircle", rlapi.}
  ## Check if point is inside circle
proc checkCollisionPointTriangle*(point: Vector2, p1: Vector2, p2: Vector2, p3: Vector2): bool {.importc: "CheckCollisionPointTriangle", rlapi.}
  ## Check if point is inside a triangle
proc checkCollisionLines*(startPos1: Vector2, endPos1: Vector2, startPos2: Vector2, endPos2: Vector2, collisionPoint: var Vector2): bool {.importc: "CheckCollisionLines", rlapi.}
  ## Check the collision between two lines defined by two points each, returns collision point by reference
proc checkCollisionPointLine*(point: Vector2, p1: Vector2, p2: Vector2, threshold: int32): bool {.importc: "CheckCollisionPointLine", rlapi.}
  ## Check if point belongs to line created between two points [p1] and [p2] with defined margin in pixels [threshold]
proc getCollisionRec*(rec1: Rectangle, rec2: Rectangle): Rectangle {.importc: "GetCollisionRec", rlapi.}
  ## Get collision rectangle for two rectangles collision
proc loadImage*(fileName: cstring): Image {.importc: "LoadImage", rlapi.}
  ## Load image from file into CPU memory (RAM)
proc loadImageRaw*(fileName: cstring, width: int32, height: int32, format: PixelFormat, headerSize: int32): Image {.importc: "LoadImageRaw", rlapi.}
  ## Load image from RAW file data
proc loadImageAnim*(fileName: cstring, frames: var int32): Image {.importc: "LoadImageAnim", rlapi.}
  ## Load image sequence from file (frames appended to image.data)
proc loadImageFromMemoryPriv(fileType: cstring, fileData: ptr UncheckedArray[uint8], dataSize: int32): Image {.importc: "LoadImageFromMemory", rlapi.}
proc loadImageFromTexture*(texture: Texture2D): Image {.importc: "LoadImageFromTexture", rlapi.}
  ## Load image from GPU texture data
proc loadImageFromScreen*(): Image {.importc: "LoadImageFromScreen", rlapi.}
  ## Load image from screen buffer and (screenshot)
proc unloadImage*(image: Image) {.importc: "UnloadImage", rlapi.}
  ## Unload image from CPU memory (RAM)
proc exportImage*(image: Image, fileName: cstring): bool {.importc: "ExportImage", rlapi.}
  ## Export image data to file, returns true on success
proc exportImageAsCode*(image: Image, fileName: cstring): bool {.importc: "ExportImageAsCode", rlapi.}
  ## Export image as code file defining an array of bytes, returns true on success
proc genImageColor*(width: int32, height: int32, color: Color): Image {.importc: "GenImageColor", rlapi.}
  ## Generate image: plain color
proc genImageGradientV*(width: int32, height: int32, top: Color, bottom: Color): Image {.importc: "GenImageGradientV", rlapi.}
  ## Generate image: vertical gradient
proc genImageGradientH*(width: int32, height: int32, left: Color, right: Color): Image {.importc: "GenImageGradientH", rlapi.}
  ## Generate image: horizontal gradient
proc genImageGradientRadial*(width: int32, height: int32, density: float32, inner: Color, outer: Color): Image {.importc: "GenImageGradientRadial", rlapi.}
  ## Generate image: radial gradient
proc genImageChecked*(width: int32, height: int32, checksX: int32, checksY: int32, col1: Color, col2: Color): Image {.importc: "GenImageChecked", rlapi.}
  ## Generate image: checked
proc genImageWhiteNoise*(width: int32, height: int32, factor: float32): Image {.importc: "GenImageWhiteNoise", rlapi.}
  ## Generate image: white noise
proc genImageCellular*(width: int32, height: int32, tileSize: int32): Image {.importc: "GenImageCellular", rlapi.}
  ## Generate image: cellular algorithm, bigger tileSize means bigger cells
proc imageCopy*(image: Image): Image {.importc: "ImageCopy", rlapi.}
  ## Create an image duplicate (useful for transformations)
proc imageFromImage*(image: Image, rec: Rectangle): Image {.importc: "ImageFromImage", rlapi.}
  ## Create an image from another image piece
proc imageText*(text: cstring, fontSize: int32, color: Color): Image {.importc: "ImageText", rlapi.}
  ## Create an image from text (default font)
proc imageTextEx*(font: Font, text: cstring, fontSize: float32, spacing: float32, tint: Color): Image {.importc: "ImageTextEx", rlapi.}
  ## Create an image from text (custom sprite font)
proc imageFormat*(image: var Image, newFormat: PixelFormat) {.importc: "ImageFormat", rlapi.}
  ## Convert image data to desired format
proc imageToPOT*(image: var Image, fill: Color) {.importc: "ImageToPOT", rlapi.}
  ## Convert image to POT (power-of-two)
proc imageCrop*(image: var Image, crop: Rectangle) {.importc: "ImageCrop", rlapi.}
  ## Crop an image to a defined rectangle
proc imageAlphaCrop*(image: var Image, threshold: float32) {.importc: "ImageAlphaCrop", rlapi.}
  ## Crop image depending on alpha value
proc imageAlphaClear*(image: var Image, color: Color, threshold: float32) {.importc: "ImageAlphaClear", rlapi.}
  ## Clear alpha channel to desired color
proc imageAlphaMask*(image: var Image, alphaMask: Image) {.importc: "ImageAlphaMask", rlapi.}
  ## Apply alpha mask to image
proc imageAlphaPremultiply*(image: var Image) {.importc: "ImageAlphaPremultiply", rlapi.}
  ## Premultiply alpha channel
proc imageResize*(image: var Image, newWidth: int32, newHeight: int32) {.importc: "ImageResize", rlapi.}
  ## Resize image (Bicubic scaling algorithm)
proc imageResizeNN*(image: var Image, newWidth: int32, newHeight: int32) {.importc: "ImageResizeNN", rlapi.}
  ## Resize image (Nearest-Neighbor scaling algorithm)
proc imageResizeCanvas*(image: var Image, newWidth: int32, newHeight: int32, offsetX: int32, offsetY: int32, fill: Color) {.importc: "ImageResizeCanvas", rlapi.}
  ## Resize canvas and fill with color
proc imageMipmaps*(image: var Image) {.importc: "ImageMipmaps", rlapi.}
  ## Compute all mipmap levels for a provided image
proc imageDither*(image: var Image, rBpp: int32, gBpp: int32, bBpp: int32, aBpp: int32) {.importc: "ImageDither", rlapi.}
  ## Dither image data to 16bpp or lower (Floyd-Steinberg dithering)
proc imageFlipVertical*(image: var Image) {.importc: "ImageFlipVertical", rlapi.}
  ## Flip image vertically
proc imageFlipHorizontal*(image: var Image) {.importc: "ImageFlipHorizontal", rlapi.}
  ## Flip image horizontally
proc imageRotateCW*(image: var Image) {.importc: "ImageRotateCW", rlapi.}
  ## Rotate image clockwise 90deg
proc imageRotateCCW*(image: var Image) {.importc: "ImageRotateCCW", rlapi.}
  ## Rotate image counter-clockwise 90deg
proc imageColorTint*(image: var Image, color: Color) {.importc: "ImageColorTint", rlapi.}
  ## Modify image color: tint
proc imageColorInvert*(image: var Image) {.importc: "ImageColorInvert", rlapi.}
  ## Modify image color: invert
proc imageColorGrayscale*(image: var Image) {.importc: "ImageColorGrayscale", rlapi.}
  ## Modify image color: grayscale
proc imageColorContrast*(image: var Image, contrast: float32) {.importc: "ImageColorContrast", rlapi.}
  ## Modify image color: contrast (-100 to 100)
proc imageColorBrightness*(image: var Image, brightness: int32) {.importc: "ImageColorBrightness", rlapi.}
  ## Modify image color: brightness (-255 to 255)
proc imageColorReplace*(image: var Image, color: Color, replace: Color) {.importc: "ImageColorReplace", rlapi.}
  ## Modify image color: replace color
proc loadImageColorsPriv(image: Image): ptr UncheckedArray[Color] {.importc: "LoadImageColors", rlapi.}
proc loadImagePalettePriv(image: Image, maxPaletteSize: int32, colorCount: ptr int32): ptr UncheckedArray[Color] {.importc: "LoadImagePalette", rlapi.}
proc unloadImageColorsPriv(colors: ptr UncheckedArray[Color]) {.importc: "UnloadImageColors", rlapi.}
proc unloadImagePalettePriv(colors: ptr UncheckedArray[Color]) {.importc: "UnloadImagePalette", rlapi.}
proc getImageAlphaBorder*(image: Image, threshold: float32): Rectangle {.importc: "GetImageAlphaBorder", rlapi.}
  ## Get image alpha border rectangle
proc getImageColor*(image: Image, x: int32, y: int32): Color {.importc: "GetImageColor", rlapi.}
  ## Get image pixel color at (x, y) position
proc imageClearBackground*(dst: var Image, color: Color) {.importc: "ImageClearBackground", rlapi.}
  ## Clear image background with given color
proc imageDrawPixel*(dst: var Image, posX: int32, posY: int32, color: Color) {.importc: "ImageDrawPixel", rlapi.}
  ## Draw pixel within an image
proc imageDrawPixelV*(dst: var Image, position: Vector2, color: Color) {.importc: "ImageDrawPixelV", rlapi.}
  ## Draw pixel within an image (Vector version)
proc imageDrawLine*(dst: var Image, startPosX: int32, startPosY: int32, endPosX: int32, endPosY: int32, color: Color) {.importc: "ImageDrawLine", rlapi.}
  ## Draw line within an image
proc imageDrawLineV*(dst: var Image, start: Vector2, `end`: Vector2, color: Color) {.importc: "ImageDrawLineV", rlapi.}
  ## Draw line within an image (Vector version)
proc imageDrawCircle*(dst: var Image, centerX: int32, centerY: int32, radius: int32, color: Color) {.importc: "ImageDrawCircle", rlapi.}
  ## Draw circle within an image
proc imageDrawCircleV*(dst: var Image, center: Vector2, radius: int32, color: Color) {.importc: "ImageDrawCircleV", rlapi.}
  ## Draw circle within an image (Vector version)
proc imageDrawRectangle*(dst: var Image, posX: int32, posY: int32, width: int32, height: int32, color: Color) {.importc: "ImageDrawRectangle", rlapi.}
  ## Draw rectangle within an image
proc imageDrawRectangleV*(dst: var Image, position: Vector2, size: Vector2, color: Color) {.importc: "ImageDrawRectangleV", rlapi.}
  ## Draw rectangle within an image (Vector version)
proc imageDrawRectangleRec*(dst: var Image, rec: Rectangle, color: Color) {.importc: "ImageDrawRectangleRec", rlapi.}
  ## Draw rectangle within an image
proc imageDrawRectangleLines*(dst: var Image, rec: Rectangle, thick: int32, color: Color) {.importc: "ImageDrawRectangleLines", rlapi.}
  ## Draw rectangle lines within an image
proc imageDraw*(dst: var Image, src: Image, srcRec: Rectangle, dstRec: Rectangle, tint: Color) {.importc: "ImageDraw", rlapi.}
  ## Draw a source image within a destination image (tint applied to source)
proc imageDrawText*(dst: var Image, text: cstring, posX: int32, posY: int32, fontSize: int32, color: Color) {.importc: "ImageDrawText", rlapi.}
  ## Draw text (using default font) within an image (destination)
proc imageDrawTextEx*(dst: var Image, font: Font, text: cstring, position: Vector2, fontSize: float32, spacing: float32, tint: Color) {.importc: "ImageDrawTextEx", rlapi.}
  ## Draw text (custom sprite font) within an image (destination)
proc loadTexture*(fileName: cstring): Texture2D {.importc: "LoadTexture", rlapi.}
  ## Load texture from file into GPU memory (VRAM)
proc loadTextureFromImage*(image: Image): Texture2D {.importc: "LoadTextureFromImage", rlapi.}
  ## Load texture from image data
proc loadTextureCubemap*(image: Image, layout: CubemapLayout): TextureCubemap {.importc: "LoadTextureCubemap", rlapi.}
  ## Load cubemap from image, multiple image cubemap layouts supported
proc loadRenderTexture*(width: int32, height: int32): RenderTexture2D {.importc: "LoadRenderTexture", rlapi.}
  ## Load texture for rendering (framebuffer)
proc unloadTexture*(texture: Texture2D) {.importc: "UnloadTexture", rlapi.}
  ## Unload texture from GPU memory (VRAM)
proc unloadRenderTexture*(target: RenderTexture2D) {.importc: "UnloadRenderTexture", rlapi.}
  ## Unload render texture from GPU memory (VRAM)
proc updateTexture*(texture: Texture2D, pixels: pointer) {.importc: "UpdateTexture", rlapi.}
  ## Update GPU texture with new data
proc updateTextureRec*(texture: Texture2D, rec: Rectangle, pixels: pointer) {.importc: "UpdateTextureRec", rlapi.}
  ## Update GPU texture rectangle with new data
proc genTextureMipmaps*(texture: var Texture2D) {.importc: "GenTextureMipmaps", rlapi.}
  ## Generate GPU mipmaps for a texture
proc setTextureFilter*(texture: Texture2D, filter: TextureFilter) {.importc: "SetTextureFilter", rlapi.}
  ## Set texture scaling filter mode
proc setTextureWrap*(texture: Texture2D, wrap: TextureWrap) {.importc: "SetTextureWrap", rlapi.}
  ## Set texture wrapping mode
proc drawTexture*(texture: Texture2D, posX: int32, posY: int32, tint: Color) {.importc: "DrawTexture", rlapi.}
  ## Draw a Texture2D
proc drawTextureV*(texture: Texture2D, position: Vector2, tint: Color) {.importc: "DrawTextureV", rlapi.}
  ## Draw a Texture2D with position defined as Vector2
proc drawTextureEx*(texture: Texture2D, position: Vector2, rotation: float32, scale: float32, tint: Color) {.importc: "DrawTextureEx", rlapi.}
  ## Draw a Texture2D with extended parameters
proc drawTextureRec*(texture: Texture2D, source: Rectangle, position: Vector2, tint: Color) {.importc: "DrawTextureRec", rlapi.}
  ## Draw a part of a texture defined by a rectangle
proc drawTextureQuad*(texture: Texture2D, tiling: Vector2, offset: Vector2, quad: Rectangle, tint: Color) {.importc: "DrawTextureQuad", rlapi.}
  ## Draw texture quad with tiling and offset parameters
proc drawTextureTiled*(texture: Texture2D, source: Rectangle, dest: Rectangle, origin: Vector2, rotation: float32, scale: float32, tint: Color) {.importc: "DrawTextureTiled", rlapi.}
  ## Draw part of a texture (defined by a rectangle) with rotation and scale tiled into dest.
proc drawTexturePro*(texture: Texture2D, source: Rectangle, dest: Rectangle, origin: Vector2, rotation: float32, tint: Color) {.importc: "DrawTexturePro", rlapi.}
  ## Draw a part of a texture defined by a rectangle with 'pro' parameters
proc drawTextureNPatch*(texture: Texture2D, nPatchInfo: NPatchInfo, dest: Rectangle, origin: Vector2, rotation: float32, tint: Color) {.importc: "DrawTextureNPatch", rlapi.}
  ## Draws a texture (or part of it) that stretches or shrinks nicely
proc drawTexturePolyPriv(texture: Texture2D, center: Vector2, points: ptr UncheckedArray[Vector2], texcoords: ptr UncheckedArray[Vector2], pointCount: int32, tint: Color) {.importc: "DrawTexturePoly", rlapi.}
proc fade*(color: Color, alpha: float32): Color {.importc: "Fade", rlapi.}
  ## Get color with alpha applied, alpha goes from 0.0f to 1.0f
proc colorToInt*(color: Color): int32 {.importc: "ColorToInt", rlapi.}
  ## Get hexadecimal value for a Color
proc colorNormalize*(color: Color): Vector4 {.importc: "ColorNormalize", rlapi.}
  ## Get Color normalized as float [0..1]
proc colorFromNormalized*(normalized: Vector4): Color {.importc: "ColorFromNormalized", rlapi.}
  ## Get Color from normalized values [0..1]
proc colorToHSV*(color: Color): Vector3 {.importc: "ColorToHSV", rlapi.}
  ## Get HSV values for a Color, hue [0..360], saturation/value [0..1]
proc colorFromHSV*(hue: float32, saturation: float32, value: float32): Color {.importc: "ColorFromHSV", rlapi.}
  ## Get a Color from HSV values, hue [0..360], saturation/value [0..1]
proc colorAlpha*(color: Color, alpha: float32): Color {.importc: "ColorAlpha", rlapi.}
  ## Get color with alpha applied, alpha goes from 0.0f to 1.0f
proc colorAlphaBlend*(dst: Color, src: Color, tint: Color): Color {.importc: "ColorAlphaBlend", rlapi.}
  ## Get src alpha-blended into dst color with tint
proc getColor*(hexValue: uint32): Color {.importc: "GetColor", rlapi.}
  ## Get Color structure from hexadecimal value
proc getPixelColor*(srcPtr: pointer, format: PixelFormat): Color {.importc: "GetPixelColor", rlapi.}
  ## Get Color from a source pixel pointer of certain format
proc setPixelColor*(dstPtr: pointer, color: Color, format: PixelFormat) {.importc: "SetPixelColor", rlapi.}
  ## Set color formatted into destination pixel pointer
proc getPixelDataSize*(width: int32, height: int32, format: PixelFormat): int32 {.importc: "GetPixelDataSize", rlapi.}
  ## Get pixel data size in bytes for certain format
proc getFontDefault*(): Font {.importc: "GetFontDefault", rlapi.}
  ## Get the default Font
proc loadFont*(fileName: cstring): Font {.importc: "LoadFont", rlapi.}
  ## Load font from file into GPU memory (VRAM)
proc loadFontExPriv(fileName: cstring, fontSize: int32, fontChars: ptr UncheckedArray[int32], glyphCount: int32): Font {.importc: "LoadFontEx", rlapi.}
proc loadFontFromImage*(image: Image, key: Color, firstChar: int32): Font {.importc: "LoadFontFromImage", rlapi.}
  ## Load font from Image (XNA style)
proc loadFontFromMemoryPriv(fileType: cstring, fileData: ptr UncheckedArray[uint8], dataSize: int32, fontSize: int32, fontChars: ptr UncheckedArray[int32], glyphCount: int32): Font {.importc: "LoadFontFromMemory", rlapi.}
proc loadFontDataPriv(fileData: ptr UncheckedArray[uint8], dataSize: int32, fontSize: int32, fontChars: ptr UncheckedArray[int32], glyphCount: int32, `type`: FontType): ptr UncheckedArray[GlyphInfo] {.importc: "LoadFontData", rlapi.}
proc genImageFontAtlasPriv(chars: ptr UncheckedArray[GlyphInfo], recs: ptr ptr UncheckedArray[Rectangle], glyphCount: int32, fontSize: int32, padding: int32, packMethod: int32): Image {.importc: "GenImageFontAtlas", rlapi.}
proc unloadFontDataPriv(chars: ptr UncheckedArray[GlyphInfo], glyphCount: int32) {.importc: "UnloadFontData", rlapi.}
proc unloadFont*(font: Font) {.importc: "UnloadFont", rlapi.}
  ## Unload Font from GPU memory (VRAM)
proc drawFPS*(posX: int32, posY: int32) {.importc: "DrawFPS", rlapi.}
  ## Draw current FPS
proc drawText*(text: cstring, posX: int32, posY: int32, fontSize: int32, color: Color) {.importc: "DrawText", rlapi.}
  ## Draw text (using default font)
proc drawTextEx*(font: Font, text: cstring, position: Vector2, fontSize: float32, spacing: float32, tint: Color) {.importc: "DrawTextEx", rlapi.}
  ## Draw text using font and additional parameters
proc drawTextPro*(font: Font, text: cstring, position: Vector2, origin: Vector2, rotation: float32, fontSize: float32, spacing: float32, tint: Color) {.importc: "DrawTextPro", rlapi.}
  ## Draw text using Font and pro parameters (rotation)
proc drawTextCodepoint*(font: Font, codepoint: int32, position: Vector2, fontSize: float32, tint: Color) {.importc: "DrawTextCodepoint", rlapi.}
  ## Draw one character (codepoint)
proc measureText*(text: cstring, fontSize: int32): int32 {.importc: "MeasureText", rlapi.}
  ## Measure string width for default font
proc measureTextEx*(font: Font, text: cstring, fontSize: float32, spacing: float32): Vector2 {.importc: "MeasureTextEx", rlapi.}
  ## Measure string size for Font
proc getGlyphIndex*(font: Font, codepoint: int32): int32 {.importc: "GetGlyphIndex", rlapi.}
  ## Get glyph index position in font for a codepoint (unicode character), fallback to '?' if not found
proc getGlyphInfo*(font: Font, codepoint: int32): GlyphInfo {.importc: "GetGlyphInfo", rlapi.}
  ## Get glyph font info data for a codepoint (unicode character), fallback to '?' if not found
proc getGlyphAtlasRec*(font: Font, codepoint: int32): Rectangle {.importc: "GetGlyphAtlasRec", rlapi.}
  ## Get glyph rectangle in font atlas for a codepoint (unicode character), fallback to '?' if not found
proc drawLine3D*(startPos: Vector3, endPos: Vector3, color: Color) {.importc: "DrawLine3D", rlapi.}
  ## Draw a line in 3D world space
proc drawPoint3D*(position: Vector3, color: Color) {.importc: "DrawPoint3D", rlapi.}
  ## Draw a point in 3D space, actually a small line
proc drawCircle3D*(center: Vector3, radius: float32, rotationAxis: Vector3, rotationAngle: float32, color: Color) {.importc: "DrawCircle3D", rlapi.}
  ## Draw a circle in 3D world space
proc drawTriangle3D*(v1: Vector3, v2: Vector3, v3: Vector3, color: Color) {.importc: "DrawTriangle3D", rlapi.}
  ## Draw a color-filled triangle (vertex in counter-clockwise order!)
proc drawTriangleStrip3DPriv(points: ptr UncheckedArray[Vector3], pointCount: int32, color: Color) {.importc: "DrawTriangleStrip3D", rlapi.}
proc drawCube*(position: Vector3, width: float32, height: float32, length: float32, color: Color) {.importc: "DrawCube", rlapi.}
  ## Draw cube
proc drawCubeV*(position: Vector3, size: Vector3, color: Color) {.importc: "DrawCubeV", rlapi.}
  ## Draw cube (Vector version)
proc drawCubeWires*(position: Vector3, width: float32, height: float32, length: float32, color: Color) {.importc: "DrawCubeWires", rlapi.}
  ## Draw cube wires
proc drawCubeWiresV*(position: Vector3, size: Vector3, color: Color) {.importc: "DrawCubeWiresV", rlapi.}
  ## Draw cube wires (Vector version)
proc drawCubeTexture*(texture: Texture2D, position: Vector3, width: float32, height: float32, length: float32, color: Color) {.importc: "DrawCubeTexture", rlapi.}
  ## Draw cube textured
proc drawCubeTextureRec*(texture: Texture2D, source: Rectangle, position: Vector3, width: float32, height: float32, length: float32, color: Color) {.importc: "DrawCubeTextureRec", rlapi.}
  ## Draw cube with a region of a texture
proc drawSphere*(centerPos: Vector3, radius: float32, color: Color) {.importc: "DrawSphere", rlapi.}
  ## Draw sphere
proc drawSphereEx*(centerPos: Vector3, radius: float32, rings: int32, slices: int32, color: Color) {.importc: "DrawSphereEx", rlapi.}
  ## Draw sphere with extended parameters
proc drawSphereWires*(centerPos: Vector3, radius: float32, rings: int32, slices: int32, color: Color) {.importc: "DrawSphereWires", rlapi.}
  ## Draw sphere wires
proc drawCylinder*(position: Vector3, radiusTop: float32, radiusBottom: float32, height: float32, slices: int32, color: Color) {.importc: "DrawCylinder", rlapi.}
  ## Draw a cylinder/cone
proc drawCylinderEx*(startPos: Vector3, endPos: Vector3, startRadius: float32, endRadius: float32, sides: int32, color: Color) {.importc: "DrawCylinderEx", rlapi.}
  ## Draw a cylinder with base at startPos and top at endPos
proc drawCylinderWires*(position: Vector3, radiusTop: float32, radiusBottom: float32, height: float32, slices: int32, color: Color) {.importc: "DrawCylinderWires", rlapi.}
  ## Draw a cylinder/cone wires
proc drawCylinderWiresEx*(startPos: Vector3, endPos: Vector3, startRadius: float32, endRadius: float32, sides: int32, color: Color) {.importc: "DrawCylinderWiresEx", rlapi.}
  ## Draw a cylinder wires with base at startPos and top at endPos
proc drawPlane*(centerPos: Vector3, size: Vector2, color: Color) {.importc: "DrawPlane", rlapi.}
  ## Draw a plane XZ
proc drawRay*(ray: Ray, color: Color) {.importc: "DrawRay", rlapi.}
  ## Draw a ray line
proc drawGrid*(slices: int32, spacing: float32) {.importc: "DrawGrid", rlapi.}
  ## Draw a grid (centered at (0, 0, 0))
proc loadModel*(fileName: cstring): Model {.importc: "LoadModel", rlapi.}
  ## Load model from files (meshes and materials)
proc loadModelFromMesh*(mesh: Mesh): Model {.importc: "LoadModelFromMesh", rlapi.}
  ## Load model from generated mesh (default material)
proc unloadModel*(model: Model) {.importc: "UnloadModel", rlapi.}
  ## Unload model (including meshes) from memory (RAM and/or VRAM)
proc unloadModelKeepMeshes*(model: Model) {.importc: "UnloadModelKeepMeshes", rlapi.}
  ## Unload model (but not meshes) from memory (RAM and/or VRAM)
proc getModelBoundingBox*(model: Model): BoundingBox {.importc: "GetModelBoundingBox", rlapi.}
  ## Compute model bounding box limits (considers all meshes)
proc drawModel*(model: Model, position: Vector3, scale: float32, tint: Color) {.importc: "DrawModel", rlapi.}
  ## Draw a model (with texture if set)
proc drawModelEx*(model: Model, position: Vector3, rotationAxis: Vector3, rotationAngle: float32, scale: Vector3, tint: Color) {.importc: "DrawModelEx", rlapi.}
  ## Draw a model with extended parameters
proc drawModelWires*(model: Model, position: Vector3, scale: float32, tint: Color) {.importc: "DrawModelWires", rlapi.}
  ## Draw a model wires (with texture if set)
proc drawModelWiresEx*(model: Model, position: Vector3, rotationAxis: Vector3, rotationAngle: float32, scale: Vector3, tint: Color) {.importc: "DrawModelWiresEx", rlapi.}
  ## Draw a model wires (with texture if set) with extended parameters
proc drawBoundingBox*(box: BoundingBox, color: Color) {.importc: "DrawBoundingBox", rlapi.}
  ## Draw bounding box (wires)
proc drawBillboard*(camera: Camera, texture: Texture2D, position: Vector3, size: float32, tint: Color) {.importc: "DrawBillboard", rlapi.}
  ## Draw a billboard texture
proc drawBillboardRec*(camera: Camera, texture: Texture2D, source: Rectangle, position: Vector3, size: Vector2, tint: Color) {.importc: "DrawBillboardRec", rlapi.}
  ## Draw a billboard texture defined by source
proc drawBillboardPro*(camera: Camera, texture: Texture2D, source: Rectangle, position: Vector3, up: Vector3, size: Vector2, origin: Vector2, rotation: float32, tint: Color) {.importc: "DrawBillboardPro", rlapi.}
  ## Draw a billboard texture defined by source and rotation
proc uploadMesh*(mesh: var Mesh, dynamic: bool) {.importc: "UploadMesh", rlapi.}
  ## Upload mesh vertex data in GPU and provide VAO/VBO ids
proc updateMeshBuffer*(mesh: Mesh, index: int32, data: pointer, dataSize: int32, offset: int32) {.importc: "UpdateMeshBuffer", rlapi.}
  ## Update mesh vertex data in GPU for a specific buffer index
proc unloadMesh*(mesh: Mesh) {.importc: "UnloadMesh", rlapi.}
  ## Unload mesh data from CPU and GPU
proc drawMesh*(mesh: Mesh, material: Material, transform: Matrix) {.importc: "DrawMesh", rlapi.}
  ## Draw a 3d mesh with material and transform
proc drawMeshInstancedPriv(mesh: Mesh, material: Material, transforms: ptr UncheckedArray[Matrix], instances: int32) {.importc: "DrawMeshInstanced", rlapi.}
proc exportMesh*(mesh: Mesh, fileName: cstring): bool {.importc: "ExportMesh", rlapi.}
  ## Export mesh data to file, returns true on success
proc getMeshBoundingBox*(mesh: Mesh): BoundingBox {.importc: "GetMeshBoundingBox", rlapi.}
  ## Compute mesh bounding box limits
proc genMeshTangents*(mesh: var Mesh) {.importc: "GenMeshTangents", rlapi.}
  ## Compute mesh tangents
proc genMeshBinormals*(mesh: var Mesh) {.importc: "GenMeshBinormals", rlapi.}
  ## Compute mesh binormals
proc genMeshPoly*(sides: int32, radius: float32): Mesh {.importc: "GenMeshPoly", rlapi.}
  ## Generate polygonal mesh
proc genMeshPlane*(width: float32, length: float32, resX: int32, resZ: int32): Mesh {.importc: "GenMeshPlane", rlapi.}
  ## Generate plane mesh (with subdivisions)
proc genMeshCube*(width: float32, height: float32, length: float32): Mesh {.importc: "GenMeshCube", rlapi.}
  ## Generate cuboid mesh
proc genMeshSphere*(radius: float32, rings: int32, slices: int32): Mesh {.importc: "GenMeshSphere", rlapi.}
  ## Generate sphere mesh (standard sphere)
proc genMeshHemiSphere*(radius: float32, rings: int32, slices: int32): Mesh {.importc: "GenMeshHemiSphere", rlapi.}
  ## Generate half-sphere mesh (no bottom cap)
proc genMeshCylinder*(radius: float32, height: float32, slices: int32): Mesh {.importc: "GenMeshCylinder", rlapi.}
  ## Generate cylinder mesh
proc genMeshCone*(radius: float32, height: float32, slices: int32): Mesh {.importc: "GenMeshCone", rlapi.}
  ## Generate cone/pyramid mesh
proc genMeshTorus*(radius: float32, size: float32, radSeg: int32, sides: int32): Mesh {.importc: "GenMeshTorus", rlapi.}
  ## Generate torus mesh
proc genMeshKnot*(radius: float32, size: float32, radSeg: int32, sides: int32): Mesh {.importc: "GenMeshKnot", rlapi.}
  ## Generate trefoil knot mesh
proc genMeshHeightmap*(heightmap: Image, size: Vector3): Mesh {.importc: "GenMeshHeightmap", rlapi.}
  ## Generate heightmap mesh from image data
proc genMeshCubicmap*(cubicmap: Image, cubeSize: Vector3): Mesh {.importc: "GenMeshCubicmap", rlapi.}
  ## Generate cubes-based map mesh from image data
proc loadMaterialsPriv(fileName: cstring, materialCount: ptr int32): ptr UncheckedArray[Material] {.importc: "LoadMaterials", rlapi.}
proc loadMaterialDefault*(): Material {.importc: "LoadMaterialDefault", rlapi.}
  ## Load default material (Supports: DIFFUSE, SPECULAR, NORMAL maps)
proc unloadMaterial*(material: Material) {.importc: "UnloadMaterial", rlapi.}
  ## Unload material from GPU memory (VRAM)
proc setMaterialTexture*(material: var Material, mapType: MaterialMapIndex, texture: Texture2D) {.importc: "SetMaterialTexture", rlapi.}
  ## Set texture for a material map type (MATERIAL_MAP_DIFFUSE, MATERIAL_MAP_SPECULAR...)
proc setModelMeshMaterial*(model: var Model, meshId: int32, materialId: int32) {.importc: "SetModelMeshMaterial", rlapi.}
  ## Set material for a mesh
proc loadModelAnimationsPriv(fileName: cstring, animCount: ptr uint32): ptr UncheckedArray[ModelAnimation] {.importc: "LoadModelAnimations", rlapi.}
proc updateModelAnimation*(model: Model, anim: ModelAnimation, frame: int32) {.importc: "UpdateModelAnimation", rlapi.}
  ## Update model animation pose
proc unloadModelAnimation*(anim: ModelAnimation) {.importc: "UnloadModelAnimation", rlapi.}
  ## Unload animation data
proc unloadModelAnimationsPriv(animations: ptr UncheckedArray[ModelAnimation], count: uint32) {.importc: "UnloadModelAnimations", rlapi.}
proc isModelAnimationValid*(model: Model, anim: ModelAnimation): bool {.importc: "IsModelAnimationValid", rlapi.}
  ## Check model animation skeleton match
proc checkCollisionSpheres*(center1: Vector3, radius1: float32, center2: Vector3, radius2: float32): bool {.importc: "CheckCollisionSpheres", rlapi.}
  ## Check collision between two spheres
proc checkCollisionBoxes*(box1: BoundingBox, box2: BoundingBox): bool {.importc: "CheckCollisionBoxes", rlapi.}
  ## Check collision between two bounding boxes
proc checkCollisionBoxSphere*(box: BoundingBox, center: Vector3, radius: float32): bool {.importc: "CheckCollisionBoxSphere", rlapi.}
  ## Check collision between box and sphere
proc getRayCollisionSphere*(ray: Ray, center: Vector3, radius: float32): RayCollision {.importc: "GetRayCollisionSphere", rlapi.}
  ## Get collision info between ray and sphere
proc getRayCollisionBox*(ray: Ray, box: BoundingBox): RayCollision {.importc: "GetRayCollisionBox", rlapi.}
  ## Get collision info between ray and box
proc getRayCollisionModel*(ray: Ray, model: Model): RayCollision {.importc: "GetRayCollisionModel", rlapi.}
  ## Get collision info between ray and model
proc getRayCollisionMesh*(ray: Ray, mesh: Mesh, transform: Matrix): RayCollision {.importc: "GetRayCollisionMesh", rlapi.}
  ## Get collision info between ray and mesh
proc getRayCollisionTriangle*(ray: Ray, p1: Vector3, p2: Vector3, p3: Vector3): RayCollision {.importc: "GetRayCollisionTriangle", rlapi.}
  ## Get collision info between ray and triangle
proc getRayCollisionQuad*(ray: Ray, p1: Vector3, p2: Vector3, p3: Vector3, p4: Vector3): RayCollision {.importc: "GetRayCollisionQuad", rlapi.}
  ## Get collision info between ray and quad
proc initAudioDevice*() {.importc: "InitAudioDevice", rlapi.}
  ## Initialize audio device and context
proc closeAudioDevice*() {.importc: "CloseAudioDevice", rlapi.}
  ## Close the audio device and context
proc isAudioDeviceReady*(): bool {.importc: "IsAudioDeviceReady", rlapi.}
  ## Check if audio device has been initialized successfully
proc setMasterVolume*(volume: float32) {.importc: "SetMasterVolume", rlapi.}
  ## Set master volume (listener)
proc loadWave*(fileName: cstring): Wave {.importc: "LoadWave", rlapi.}
  ## Load wave data from file
proc loadWaveFromMemoryPriv(fileType: cstring, fileData: ptr UncheckedArray[uint8], dataSize: int32): Wave {.importc: "LoadWaveFromMemory", rlapi.}
proc loadSound*(fileName: cstring): Sound {.importc: "LoadSound", rlapi.}
  ## Load sound from file
proc loadSoundFromWave*(wave: Wave): Sound {.importc: "LoadSoundFromWave", rlapi.}
  ## Load sound from wave data
proc updateSound*(sound: Sound, data: pointer, sampleCount: int32) {.importc: "UpdateSound", rlapi.}
  ## Update sound buffer with new data
proc unloadWave*(wave: Wave) {.importc: "UnloadWave", rlapi.}
  ## Unload wave data
proc unloadSound*(sound: Sound) {.importc: "UnloadSound", rlapi.}
  ## Unload sound
proc exportWave*(wave: Wave, fileName: cstring): bool {.importc: "ExportWave", rlapi.}
  ## Export wave data to file, returns true on success
proc exportWaveAsCode*(wave: Wave, fileName: cstring): bool {.importc: "ExportWaveAsCode", rlapi.}
  ## Export wave sample data to code (.h), returns true on success
proc playSound*(sound: Sound) {.importc: "PlaySound", rlapi.}
  ## Play a sound
proc stopSound*(sound: Sound) {.importc: "StopSound", rlapi.}
  ## Stop playing a sound
proc pauseSound*(sound: Sound) {.importc: "PauseSound", rlapi.}
  ## Pause a sound
proc resumeSound*(sound: Sound) {.importc: "ResumeSound", rlapi.}
  ## Resume a paused sound
proc playSoundMulti*(sound: Sound) {.importc: "PlaySoundMulti", rlapi.}
  ## Play a sound (using multichannel buffer pool)
proc stopSoundMulti*() {.importc: "StopSoundMulti", rlapi.}
  ## Stop any sound playing (using multichannel buffer pool)
proc getSoundsPlaying*(): int32 {.importc: "GetSoundsPlaying", rlapi.}
  ## Get number of sounds playing in the multichannel
proc isSoundPlaying*(sound: Sound): bool {.importc: "IsSoundPlaying", rlapi.}
  ## Check if a sound is currently playing
proc setSoundVolume*(sound: Sound, volume: float32) {.importc: "SetSoundVolume", rlapi.}
  ## Set volume for a sound (1.0 is max level)
proc setSoundPitch*(sound: Sound, pitch: float32) {.importc: "SetSoundPitch", rlapi.}
  ## Set pitch for a sound (1.0 is base level)
proc waveFormat*(wave: var Wave, sampleRate: int32, sampleSize: int32, channels: int32) {.importc: "WaveFormat", rlapi.}
  ## Convert wave data to desired format
proc waveCopy*(wave: Wave): Wave {.importc: "WaveCopy", rlapi.}
  ## Copy a wave to a new wave
proc waveCrop*(wave: var Wave, initSample: int32, finalSample: int32) {.importc: "WaveCrop", rlapi.}
  ## Crop a wave to defined samples range
proc loadWaveSamplesPriv(wave: Wave): ptr UncheckedArray[float32] {.importc: "LoadWaveSamples", rlapi.}
proc unloadWaveSamplesPriv(samples: ptr UncheckedArray[float32]) {.importc: "UnloadWaveSamples", rlapi.}
proc loadMusicStream*(fileName: cstring): Music {.importc: "LoadMusicStream", rlapi.}
  ## Load music stream from file
proc loadMusicStreamFromMemoryPriv(fileType: cstring, data: ptr UncheckedArray[uint8], dataSize: int32): Music {.importc: "LoadMusicStreamFromMemory", rlapi.}
proc unloadMusicStream*(music: Music) {.importc: "UnloadMusicStream", rlapi.}
  ## Unload music stream
proc playMusicStream*(music: Music) {.importc: "PlayMusicStream", rlapi.}
  ## Start music playing
proc isMusicStreamPlaying*(music: Music): bool {.importc: "IsMusicStreamPlaying", rlapi.}
  ## Check if music is playing
proc updateMusicStream*(music: Music) {.importc: "UpdateMusicStream", rlapi.}
  ## Updates buffers for music streaming
proc stopMusicStream*(music: Music) {.importc: "StopMusicStream", rlapi.}
  ## Stop music playing
proc pauseMusicStream*(music: Music) {.importc: "PauseMusicStream", rlapi.}
  ## Pause music playing
proc resumeMusicStream*(music: Music) {.importc: "ResumeMusicStream", rlapi.}
  ## Resume playing paused music
proc seekMusicStream*(music: Music, position: float32) {.importc: "SeekMusicStream", rlapi.}
  ## Seek music to a position (in seconds)
proc setMusicVolume*(music: Music, volume: float32) {.importc: "SetMusicVolume", rlapi.}
  ## Set volume for music (1.0 is max level)
proc setMusicPitch*(music: Music, pitch: float32) {.importc: "SetMusicPitch", rlapi.}
  ## Set pitch for a music (1.0 is base level)
proc getMusicTimeLength*(music: Music): float32 {.importc: "GetMusicTimeLength", rlapi.}
  ## Get music time length (in seconds)
proc getMusicTimePlayed*(music: Music): float32 {.importc: "GetMusicTimePlayed", rlapi.}
  ## Get current music time played (in seconds)
proc loadAudioStream*(sampleRate: uint32, sampleSize: uint32, channels: uint32): AudioStream {.importc: "LoadAudioStream", rlapi.}
  ## Load audio stream (to stream raw audio pcm data)
proc unloadAudioStream*(stream: AudioStream) {.importc: "UnloadAudioStream", rlapi.}
  ## Unload audio stream and free memory
proc updateAudioStream*(stream: AudioStream, data: pointer, frameCount: int32) {.importc: "UpdateAudioStream", rlapi.}
  ## Update audio stream buffers with data
proc isAudioStreamProcessed*(stream: AudioStream): bool {.importc: "IsAudioStreamProcessed", rlapi.}
  ## Check if any audio stream buffers requires refill
proc playAudioStream*(stream: AudioStream) {.importc: "PlayAudioStream", rlapi.}
  ## Play audio stream
proc pauseAudioStream*(stream: AudioStream) {.importc: "PauseAudioStream", rlapi.}
  ## Pause audio stream
proc resumeAudioStream*(stream: AudioStream) {.importc: "ResumeAudioStream", rlapi.}
  ## Resume audio stream
proc isAudioStreamPlaying*(stream: AudioStream): bool {.importc: "IsAudioStreamPlaying", rlapi.}
  ## Check if audio stream is playing
proc stopAudioStream*(stream: AudioStream) {.importc: "StopAudioStream", rlapi.}
  ## Stop audio stream
proc setAudioStreamVolume*(stream: AudioStream, volume: float32) {.importc: "SetAudioStreamVolume", rlapi.}
  ## Set volume for audio stream (1.0 is max level)
proc setAudioStreamPitch*(stream: AudioStream, pitch: float32) {.importc: "SetAudioStreamPitch", rlapi.}
  ## Set pitch for audio stream (1.0 is base level)
proc setAudioStreamBufferSizeDefault*(size: int32) {.importc: "SetAudioStreamBufferSizeDefault", rlapi.}
  ## Default size for new audio streams

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

proc loadModelAnimations*(fileName: string): seq[ModelAnimation] =
  ## Load model animations from file
  var len = 0'u32
  let data = loadModelAnimationsPriv(fileName.cstring, len.addr)
  if len <= 0:
    raise newException(IOError, "No model animations loaded from " & filename)
  result = newSeq[ModelAnimation](len.int)
  copyMem(result[0].addr, data, len.int * sizeof(ModelAnimation))
  #for i in 0..<len.int:
    #result[i] = data[i]
  memFree(data)

proc loadWaveSamples*(wave: Wave): seq[float32] =
  ## Load samples data from wave as a floats array
  let data = loadWaveSamplesPriv(wave)
  let len = int(wave.frameCount * wave.channels)
  result = newSeq[float32](len)
  copyMem(result[0].addr, data, len * sizeof(float32))
  memFree(data)

proc loadImageColors*(image: Image): seq[Color] =
  ## Load color data from image as a Color array (RGBA - 32bit)
  let data = loadImageColorsPriv(image)
  let len = int(image.width * image.height)
  result = newSeq[Color](len)
  copyMem(result[0].addr, data, len * sizeof(Color))
  memFree(data)

proc loadImagePalette*(image: Image, maxPaletteSize: int32): seq[Color] =
  ## Load colors palette from image as a Color array (RGBA - 32bit)
  var len = 0'i32
  let data = loadImagePalettePriv(image, maxPaletteSize, len.addr)
  result = newSeq[Color](len.int)
  copyMem(result[0].addr, data, len.int * sizeof(Color))
  memFree(data)

proc loadFontData*(fileData: openarray[uint8], fontSize: int32, fontChars: openarray[int32], `type`: FontType): seq[GlyphInfo] =
  ## Load font data for further use
  let data = loadFontDataPriv(cast[ptr UncheckedArray[uint8]](fileData), fileData.len.int32,
      fontSize, cast[ptr UncheckedArray[int32]](fontChars), fontChars.len.int32, `type`)
  result = newSeq[GlyphInfo](fontChars.len)
  copyMem(result[0].addr, data, fontChars.len * sizeof(GlyphInfo))
  memFree(data)

proc loadMaterials*(fileName: string): seq[Material] =
  ## Load materials from model file
  var len = 0'i32
  let data = loadMaterialsPriv(fileName.cstring, len.addr)
  if len <= 0:
    raise newException(IOError, "No materials loaded from " & filename)
  result = newSeq[Material](len.int)
  copyMem(result[0].addr, data, len.int * sizeof(Material))
  #for i in 0..<len.int:
    #result[i] = data[i]
  memFree(data)

proc drawLineStrip*(points: openarray[Vector2], color: Color) {.inline.} =
  ## Draw lines sequence
  drawLineStripPriv(cast[ptr UncheckedArray[Vector2]](points), points.len.int32, color)

proc drawTriangleFan*(points: openarray[Vector2], color: Color) =
  ## Draw a triangle fan defined by points (first vertex is the center)
  drawTriangleFanPriv(cast[ptr UncheckedArray[Vector2]](points), points.len.int32, color)

proc drawTriangleStrip*(points: openarray[Vector2], color: Color) =
  ## Draw a triangle strip defined by points
  drawTriangleStripPriv(cast[ptr UncheckedArray[Vector2]](points), points.len.int32, color)

proc loadImageFromMemory*(fileType: string, fileData: openarray[uint8]): Image =
  ## Load image from memory buffer, fileType refers to extension: i.e. '.png'
  result = loadImageFromMemoryPriv(fileType.cstring, cast[ptr UncheckedArray[uint8]](fileData), fileData.len.int32)

proc drawTexturePoly*(texture: Texture2D, center: Vector2, points: openarray[Vector2], texcoords: openarray[Vector2], tint: Color) =
  ## Draw a textured polygon
  drawTexturePolyPriv(texture, center, cast[ptr UncheckedArray[Vector2]](points), cast[ptr UncheckedArray[Vector2]](texcoords), points.len.int32, tint)

proc loadFontEx*(fileName: string, fontSize: int32, fontChars: openarray[int32]): Font =
  ## Load font from file with extended parameters, use an empty array for fontChars to load the default character set
  result = loadFontExPriv(fileName.cstring, fontSize,
      if fontChars.len == 0: nil else: cast[ptr UncheckedArray[int32]](fontChars), fontChars.len.int32)

proc loadFontFromMemory*(fileType: string, fileData: openarray[uint8], fontSize: int32, fontChars: openarray[int32]): Font =
  ## Load font from memory buffer, fileType refers to extension: i.e. '.ttf'
  result = loadFontFromMemoryPriv(fileType.cstring,
      cast[ptr UncheckedArray[uint8]](fileData), fileData.len.int32, fontSize,
      cast[ptr UncheckedArray[int32]](fontChars), fontChars.len.int32)

proc genImageFontAtlas*(chars: openarray[GlyphInfo], recs: var seq[Rectangle], fontSize: int32, padding: int32, packMethod: int32): Image =
  ## Generate image font atlas using chars info
  var data: ptr UncheckedArray[Rectangle] = nil
  result = genImageFontAtlasPriv(cast[ptr UncheckedArray[GlyphInfo]](chars), data.addr, chars.len.int32, fontSize, padding, packMethod)
  recs = newSeq[Rectangle](chars.len)
  copyMem(recs[0].addr, data, chars.len * sizeof(Rectangle))
  #for i in 0..<len.int:
    #result[i] = data[i]
  memFree(data)

proc drawTriangleStrip3D*(points: openarray[Vector3], color: Color) =
  ## Draw a triangle strip defined by points
  drawTriangleStrip3DPriv(cast[ptr UncheckedArray[Vector3]](points), points.len.int32, color)

proc drawMeshInstanced*(mesh: Mesh, material: Material, transforms: openarray[Matrix]) =
  ## Draw multiple mesh instances with material and different transforms
  drawMeshInstancedPriv(mesh, material, cast[ptr UncheckedArray[Matrix]](transforms), transforms.len.int32)

proc loadWaveFromMemory*(fileType: string, fileData: openarray[uint8]): Wave =
  ## Load wave from memory buffer, fileType refers to extension: i.e. '.wav'
  loadWaveFromMemoryPriv(fileType.cstring, cast[ptr UncheckedArray[uint8]](fileData), fileData.len.int32)

proc loadMusicStreamFromMemory*(fileType: string, data: openarray[uint8]): Music =
  ## Load music stream from data
  loadMusicStreamFromMemoryPriv(fileType.cstring, cast[ptr UncheckedArray[uint8]](data), data.len.int32)
