from raylib import PixelFormat, TextureFilter, BlendMode, ShaderLocationIndex,
  ShaderUniformDataType, ShaderAttributeDataType, MaxShaderLocations, ShaderLocation,
  Matrix, Vector2, Vector3, Color, ShaderLocsPtr
export PixelFormat, TextureFilter, BlendMode, ShaderLocationIndex, ShaderUniformDataType,
  ShaderAttributeDataType, MaxShaderLocations, ShaderLocation, Matrix, Vector2, Vector3,
  Color, ShaderLocsPtr

# Security check in case no GraphicsApiOpenGl* defined
const
  UseEmbeddedGraphicsApi = defined(GraphicsApiOpenGlEs2) or defined(GraphicsApiOpenGlEs3)

const
  RlglVersion* = (5, 1, 0)

  DefaultBatchBuffers* = 1 ## Default number of batch buffers (multi-buffering)
  DefaultBatchDrawCalls* = 256 ## Default number of batch draw calls (by state changes: mode, texture)
  DefaultBatchMaxTextureUnits* = 4 ## Maximum number of textures units that can be activated on batch drawing
  MaxMatrixStackSize* = 32 ## Maximum size of Matrix stack
  # MaxShaderLocations* = 32 ## Maximum number of shader locations supported
  CullDistanceNear* = 0.01 ## Default near cull distance
  CullDistanceFar* = 1000.0 ## Default far cull distance

when not UseEmbeddedGraphicsApi:
  const DefaultBatchBufferElements* = 8192 ## This is the maximum amount of elements (quads) per batch
                                           ## NOTE: Be careful with text, every letter maps to a quad
else:
  const DefaultBatchBufferElements* = 2048 ## We reduce memory sizes for embedded systems (RPI and HTML5)
                                           ## NOTE: On HTML5 (emscripten) this is allocated on heap,
                                           ## by default it's only 16MB!...just take care...

type
  rlglLoadProc* = proc (name: cstring): pointer ## OpenGL extension functions loader signature (same as GLADloadproc)

type
  GlVersion* {.size: sizeof(int32).} = enum ## OpenGL version
    Opengl11 = 1 ## OpenGL 1.1
    Opengl21 ## OpenGL 2.1 (GLSL 120)
    Opengl33 ## OpenGL 3.3 (GLSL 330)
    Opengl43 ## OpenGL 4.3 (using GLSL 330)
    OpenglEs20 ## OpenGL ES 2.0 (GLSL 100)
    OpenglEs30 ## OpenGL ES 3.0 (GLSL 300 es)

  FramebufferAttachType* {.size: sizeof(int32).} = enum ## Framebuffer attachment type
    ColorChannel0 ## Framebuffer attachment type: color 0
    ColorChannel1 ## Framebuffer attachment type: color 1
    ColorChannel2 ## Framebuffer attachment type: color 2
    ColorChannel3 ## Framebuffer attachment type: color 3
    ColorChannel4 ## Framebuffer attachment type: color 4
    ColorChannel5 ## Framebuffer attachment type: color 5
    ColorChannel6 ## Framebuffer attachment type: color 6
    ColorChannel7 ## Framebuffer attachment type: color 7
    Depth = 100 ## Framebuffer attachment type: depth
    Stencil = 200 ## Framebuffer attachment type: stencil

  FramebufferAttachTextureType* {.size: sizeof(int32).} = enum ## Framebuffer texture attachment type
    CubemapPositiveX ## Framebuffer texture attachment type: cubemap, +X side
    CubemapNegativeX ## Framebuffer texture attachment type: cubemap, -X side
    CubemapPositiveY ## Framebuffer texture attachment type: cubemap, +Y side
    CubemapNegativeY ## Framebuffer texture attachment type: cubemap, -Y side
    CubemapPositiveZ ## Framebuffer texture attachment type: cubemap, +Z side
    CubemapNegativeZ ## Framebuffer texture attachment type: cubemap, -Z side
    Texture2d = 100 ## Framebuffer texture attachment type: texture2d
    Renderbuffer = 200 ## Framebuffer texture attachment type: renderbuffer

  CullMode* {.size: sizeof(int32).} = enum ## Face culling mode
    FaceFront
    FaceBack

  TextureParameter* {.size: sizeof(int32).} = enum ## Texture parameters (equivalent to OpenGL defines)
    FilterNearest = 0x2600 ## GL_NEAREST
    FilterLinear = 0x2601 ## GL_LINEAR
    FilterMipNearest = 0x2700 ## GL_NEAREST_MIPMAP_NEAREST
    FilterLinearMipNearest = 0x2701 ## GL_LINEAR_MIPMAP_NEAREST
    FilterNearestMipLinear = 0x2702 ## GL_NEAREST_MIPMAP_LINEAR
    FilterMipLinear = 0x2703 ## GL_LINEAR_MIPMAP_LINEAR
    MagFilter = 0x2800 ## GL_TEXTURE_MAG_FILTER
    MinFilter = 0x2801 ## GL_TEXTURE_MIN_FILTER
    WrapS = 0x2802 ## GL_TEXTURE_WRAP_S
    WrapT = 0x2803 ## GL_TEXTURE_WRAP_T
    WrapRepeat = 0x2901 ## GL_REPEAT
    FilterAnisotropic = 0x3000 ## Anisotropic filter (custom identifier)
    MipmapBiasRatio = 0x4000 ## Texture mipmap bias, percentage ratio (custom identifier)
    WrapClamp = 0x812F ## GL_CLAMP_TO_EDGE
    WrapMirrorRepeat = 0x8370 ## GL_MIRRORED_REPEAT
    WrapMirrorClamp = 0x8742 ## GL_MIRROR_CLAMP_EXT

  MatrixMode* {.size: sizeof(int32).} = enum ## Matrix modes (equivalent to OpenGL)
    Modelview = 0x1700 ## GL_MODELVIEW
    Projection = 0x1701 ## GL_PROJECTION
    Texture = 0x1702 ## GL_TEXTURE

  DrawMode* {.size: sizeof(int32).} = enum ## Primitive assembly draw modes
    Lines = 0x0001 ## GL_LINES
    Triangles = 0x0004 ## GL_TRIANGLES
    Quads = 0x0007 ## GL_QUADS

  GlType* {.size: sizeof(int32).} = enum ## GL equivalent data types
    UnsignedByte = 0x1401 ## GL_UNSIGNED_BYTE
    Float = 0x1406 ## GL_FLOAT

  BufferUsageHint* {.size: sizeof(int32).} = enum ## GL buffer usage hint
    StreamDraw = 0x88E0 ## GL_STREAM_DRAW
    StreamRead = 0x88E1 ## GL_STREAM_READ
    StreamCopy = 0x88E2 ## GL_STREAM_COPY
    StaticDraw = 0x88E4 ## GL_STATIC_DRAW
    StaticRead = 0x88E5 ## GL_STATIC_READ
    StaticCopy = 0x88E6 ## GL_STATIC_COPY
    DynamicDraw = 0x88E8 ## GL_DYNAMIC_DRAW
    DynamicRead = 0x88E9 ## GL_DYNAMIC_READ
    DynamicCopy = 0x88EA ## GL_DYNAMIC_COPY

  ShaderType* {.size: sizeof(int32).} = enum ## GL Shader type
    FragmentShader = 0x8B30 ## GL_FRAGMENT_SHADER
    VertexShader = 0x8B31 ## GL_VERTEX_SHADER
    ComputeShader = 0x91B9 ## GL_COMPUTE_SHADER

  BlendFactor* {.size: sizeof(int32).} = enum ## GL blending factors
    Zero ## GL_ZERO
    One ## GL_ONE
    SrcColor = 0x0300 ## GL_SRC_COLOR
    OneMinusSrcColor = 0x0301 ## GL_ONE_MINUS_SRC_COLOR
    SrcAlpha = 0x0302 ## GL_SRC_ALPHA
    OneMinusSrcAlpha = 0x0303 ## GL_One_MINUS_SRC_ALPHA
    DstAlpha = 0x0304 ## GL_DST_ALPHA
    OneMinusDstAlpha = 0x0305 ## GL_ONE_MINUS_DST_ALPHA
    DstColor = 0x0306 ## GL_DST_COLOR
    OneMinusDstColor = 0x0307 ## GL_ONE_MINUS_DST_COLOR
    SrcAlphaSaturate = 0x0308 ## GL_SRC_ALPHA_SATURATE
    ConstantColor = 0x8001 ## GL_CONSTANT_COLOR
    OneMinusConstantColor = 0x8002 ## GL_ONE_MINUS_CONSTANT_COLOR
    ConstantAlpha = 0x8003 ## GL_CONSTANT_ALPHA
    OneMinusConstantAlpha = 0x8004 ## GL_ONE_MINUS_CONSTANT_ALPHA

  BlendFuncOrEq* {.size: sizeof(int32).} = enum ## GL blending functions/equations
    BlendColor = 0x8005 ## GL_BLEND_COLOR
    FuncAdd = 0x8006 ## GL_FUNC_ADD
    Min = 0x8007 ## GL_MIN
    Max = 0x8008 ## GL_MAX
    BlendEquation = 0x8009 ## GL_BLEND_EQUATION
    FuncSubtract = 0x800A ## GL_FUNC_SUBTRACT
    FuncReverseSubtract = 0x800B ## GL_FUNC_REVERSE_SUBTRACT
    BlendDstRgb = 0x80C8 ## GL_BLEND_DST_RGB
    BlendSrcRgb = 0x80C9 ## GL_BLEND_SRC_RGB
    BlendDstAlpha = 0x80CA ## GL_BLEND_DST_ALPHA
    BlendSrcAlpha = 0x80CB ## GL_BLEND_SRC_ALPHA
    BlendEquationAlpha = 0x883D ## GL_BLEND_EQUATION_ALPHA

  FramebufferTarget* {.size: sizeof(int32).} = enum
    ReadFramebuffer = 0x8CA8 ## GL_READ_FRAMEBUFFER
    DrawFramebuffer = 0x8CA9 ## GL_DRAW_FRAMEBUFFER

  DefaultShaderLocationIndex* {.size: sizeof(int32).} = enum ## Default shader vertex attribute locations
    AttribPosition = 0
    AttribTexcoord
    AttribNormal
    AttribColor
    AttribTangent
    AttribTexcoord2
    AttribLocationBoneIds
    AttribLocationBoneWeights
    AttribLocationIndices

  DefaultShaderVariableName* = enum ## Default shader vertex attribute names to set location points
    AttribPosition = "vertexPosition" ## Bound by default to shader location: 0
    AttribTexcoord = "vertexTexCoord" ## Bound by default to shader location: 1
    AttribNormal = "vertexNormal" ## Bound by default to shader location: 2
    AttribColor = "vertexColor" ## Bound by default to shader location: 3
    AttribTangent = "vertexTangent" ## Bound by default to shader location: 4
    AttribTexcoord2 = "vertexTexCoord2" ## Bound by default to shader location: 5
    AttribLocationBoneIds = "vertexBoneIds" ## Bound by default to shader location: 6
    AttribLocationBoneWeights = "vertexBoneWeights" ## Bound by default to shader location: 7
    UniformMvp = "mvp" ## model-view-projection matrix
    UniformView = "matView" ## view matrix
    UniformProjection = "matProjection" ## projection matrix
    UniformModel = "matModel" ## model matrix
    UniformNormal = "matNormal" ## normal matrix (transpose(inverse(matModelView))
    UniformColor = "colDiffuse" ## color diffuse (base tint color, multiplied by texture color)
    UniformBoneMatrices = "boneMatrices" ## bone matrices
    Sampler2dTexture0 = "texture0" ## texture0 (texture slot active 0)
    Sampler2dTexture1 = "texture1" ## texture1 (texture slot active 1)
    Sampler2dTexture2 = "texture2" ## texture2 (texture slot active 2)

template BlendEquationRgb*(_: typedesc[BlendFuncOrEq]): untyped = BlendEquation

template VertexBufferIndicesType(): untyped =
  when not UseEmbeddedGraphicsApi:
    ptr UncheckedArray[uint32]
  else:
    ptr UncheckedArray[uint16]

type
  VertexBuffer* {.importc: "rlVertexBuffer", header: "rlgl.h", completeStruct, bycopy.} = object ## Dynamic vertex buffers (position + texcoords + colors + indices arrays)
    elementCount: int32 ## Number of elements in the buffer (QUADS)
    vertices: ptr UncheckedArray[float32] ## Vertex position (XYZ - 3 components per vertex) (shader-location = 0)
    texcoords: ptr UncheckedArray[float32] ## Vertex texture coordinates (UV - 2 components per vertex) (shader-location = 1)
    normals: ptr UncheckedArray[float32] ## Vertex normal (XYZ - 3 components per vertex) (shader-location = 2)
    colors: ptr UncheckedArray[uint8] ## Vertex colors (RGBA - 4 components per vertex) (shader-location = 3)
    indices: VertexBufferIndicesType ## Vertex indices (in case vertex data comes indexed) (6 indices per quad)
    vaoId*: uint32 ## OpenGL Vertex Array Object id
    vboId*: array[5, uint32] ## OpenGL Vertex Buffer Objects id (5 types of vertex data)

  DrawCall* {.importc: "rlDrawCall", header: "rlgl.h", completeStruct, bycopy.} = object ## of those state-change happens (this is done in core module)
    mode*: int32 ## Drawing mode: LINES, TRIANGLES, QUADS
    vertexCount*: int32 ## Number of vertex of the draw
    vertexAlignment*: int32 ## Number of vertex required for index alignment (LINES, TRIANGLES)
    textureId*: uint32 ## Texture id to be used on the draw -> Use to create new draw call if changes

  RenderBatch* {.importc: "rlRenderBatch", header: "rlgl.h", completeStruct, bycopy.} = object ## rlRenderBatch type
    bufferCount: int32 ## Number of vertex buffers (multi-buffering support)
    currentBuffer*: int32 ## Current buffer tracking in case of multi-buffering
    vertexBuffer: ptr UncheckedArray[VertexBuffer] ## Dynamic buffer(s) for vertex data
    draws: ptr UncheckedArray[DrawCall] ## Draw calls array, depends on textureId
    drawCounter*: int32 ## Draw calls counter
    currentDepth*: float32 ## Current depth value for next draw

  VertexBufferVertices* = distinct VertexBuffer
  VertexBufferTexcoords* = distinct VertexBuffer
  VertexBufferNormals* = distinct VertexBuffer
  VertexBufferColors* = distinct VertexBuffer
  VertexBufferIndices* = distinct VertexBuffer
  RenderBatchVertexBuffer* = distinct RenderBatch
  RenderBatchDraws* = distinct RenderBatch


{.push callconv: cdecl, header: "rlgl.h".}
proc matrixMode*(mode: MatrixMode) {.importc: "rlMatrixMode", sideEffect.}
  ## Choose the current matrix to be transformed
proc pushMatrix*() {.importc: "rlPushMatrix", sideEffect.}
  ## Push the current matrix to stack
proc popMatrix*() {.importc: "rlPopMatrix", sideEffect.}
  ## Pop latest inserted matrix from stack
proc loadIdentity*() {.importc: "rlLoadIdentity", sideEffect.}
  ## Reset current matrix to identity matrix
proc translatef*(x: float32, y: float32, z: float32) {.importc: "rlTranslatef", sideEffect.}
  ## Multiply the current matrix by a translation matrix
proc rotatef*(angle: float32, x: float32, y: float32, z: float32) {.importc: "rlRotatef", sideEffect.}
  ## Multiply the current matrix by a rotation matrix
proc scalef*(x: float32, y: float32, z: float32) {.importc: "rlScalef", sideEffect.}
  ## Multiply the current matrix by a scaling matrix
proc multMatrixf*(matf: array[16, float32]) {.importc: "rlMultMatrixf", sideEffect.}
  ## Multiply the current matrix by another matrix
proc frustum*(left: float64, right: float64, bottom: float64, top: float64, znear: float64, zfar: float64) {.importc: "rlFrustum", sideEffect.}
proc ortho*(left: float64, right: float64, bottom: float64, top: float64, znear: float64, zfar: float64) {.importc: "rlOrtho", sideEffect.}
proc viewport*(x: int32, y: int32, width: int32, height: int32) {.importc: "rlViewport", sideEffect.}
  ## Set the viewport area
proc setClipPlanes*(nearPlane: float64, farPlane: float64) {.importc: "rlSetClipPlanes", sideEffect.}
  ## Set clip planes distances
proc getCullDistanceNear*(): float64 {.importc: "rlGetCullDistanceNear", sideEffect.}
  ## Get cull plane distance near
proc getCullDistanceFar*(): float64 {.importc: "rlGetCullDistanceFar", sideEffect.}
  ## Get cull plane distance far
proc rlBegin*(mode: DrawMode) {.importc: "rlBegin", sideEffect.}
  ## Initialize drawing mode (how to organize vertex)
proc rlEnd*() {.importc: "rlEnd", sideEffect.}
  ## Finish vertex providing
proc vertex2i*(x: int32, y: int32) {.importc: "rlVertex2i", sideEffect.}
  ## Define one vertex (position) - 2 int
proc vertex2f*(x: float32, y: float32) {.importc: "rlVertex2f", sideEffect.}
  ## Define one vertex (position) - 2 float
proc vertex3f*(x: float32, y: float32, z: float32) {.importc: "rlVertex3f", sideEffect.}
  ## Define one vertex (position) - 3 float
proc texCoord2f*(x: float32, y: float32) {.importc: "rlTexCoord2f", sideEffect.}
  ## Define one vertex (texture coordinate) - 2 float
proc normal3f*(x: float32, y: float32, z: float32) {.importc: "rlNormal3f", sideEffect.}
  ## Define one vertex (normal) - 3 float
proc color4ub*(r: uint8, g: uint8, b: uint8, a: uint8) {.importc: "rlColor4ub", sideEffect.}
  ## Define one vertex (color) - 4 byte
proc color3f*(x: float32, y: float32, z: float32) {.importc: "rlColor3f", sideEffect.}
  ## Define one vertex (color) - 3 float
proc color4f*(x: float32, y: float32, z: float32, w: float32) {.importc: "rlColor4f", sideEffect.}
  ## Define one vertex (color) - 4 float
proc enableVertexArray*(vaoId: uint32): bool {.importc: "rlEnableVertexArray", sideEffect.}
  ## Enable vertex array (VAO, if supported)
proc disableVertexArray*() {.importc: "rlDisableVertexArray", sideEffect.}
  ## Disable vertex array (VAO, if supported)
proc enableVertexBuffer*(id: uint32) {.importc: "rlEnableVertexBuffer", sideEffect.}
  ## Enable vertex buffer (VBO)
proc disableVertexBuffer*() {.importc: "rlDisableVertexBuffer", sideEffect.}
  ## Disable vertex buffer (VBO)
proc enableVertexBufferElement*(id: uint32) {.importc: "rlEnableVertexBufferElement", sideEffect.}
  ## Enable vertex buffer element (VBO element)
proc disableVertexBufferElement*() {.importc: "rlDisableVertexBufferElement", sideEffect.}
  ## Disable vertex buffer element (VBO element)
proc enableVertexAttribute*(index: uint32) {.importc: "rlEnableVertexAttribute", sideEffect.}
  ## Enable vertex attribute index
proc disableVertexAttribute*(index: uint32) {.importc: "rlDisableVertexAttribute", sideEffect.}
  ## Disable vertex attribute index
proc enableStatePointer*(vertexAttribType: int32, buffer: pointer) {.importc: "rlEnableStatePointer", sideEffect.}
  ## Enable attribute state pointer
proc disableStatePointer*(vertexAttribType: int32) {.importc: "rlDisableStatePointer", sideEffect.}
  ## Disable attribute state pointer
proc activeTextureSlot*(slot: int32) {.importc: "rlActiveTextureSlot", sideEffect.}
  ## Select and active a texture slot
proc enableTexture*(id: uint32) {.importc: "rlEnableTexture", sideEffect.}
  ## Enable texture
proc disableTexture*() {.importc: "rlDisableTexture", sideEffect.}
  ## Disable texture
proc enableTextureCubemap*(id: uint32) {.importc: "rlEnableTextureCubemap", sideEffect.}
  ## Enable texture cubemap
proc disableTextureCubemap*() {.importc: "rlDisableTextureCubemap", sideEffect.}
  ## Disable texture cubemap
proc textureParameters*(id: uint32, param: TextureParameter, value: int32) {.importc: "rlTextureParameters", sideEffect.}
  ## Set texture parameters (filter, wrap)
proc cubemapParameters*(id: uint32, param: int32, value: int32) {.importc: "rlCubemapParameters", sideEffect.}
  ## Set cubemap parameters (filter, wrap)
proc enableShader*(id: uint32) {.importc: "rlEnableShader", sideEffect.}
  ## Enable shader program
proc disableShader*() {.importc: "rlDisableShader", sideEffect.}
  ## Disable shader program
proc enableFramebuffer*(id: uint32) {.importc: "rlEnableFramebuffer", sideEffect.}
  ## Enable render texture (fbo)
proc disableFramebuffer*() {.importc: "rlDisableFramebuffer", sideEffect.}
  ## Disable render texture (fbo), return to default framebuffer
proc getActiveFramebuffer*(): uint32 {.importc: "rlGetActiveFramebuffer", sideEffect.}
  ## Get the currently active render texture (fbo), 0 for default framebuffer
proc activeDrawBuffers*(count: int32) {.importc: "rlActiveDrawBuffers", sideEffect.}
  ## Activate multiple draw color buffers
proc blitFramebuffer*(srcX: int32, srcY: int32, srcWidth: int32, srcHeight: int32, dstX: int32, dstY: int32, dstWidth: int32, dstHeight: int32, bufferMask: int32) {.importc: "rlBlitFramebuffer", sideEffect.}
  ## Blit active framebuffer to main framebuffer
proc bindFramebuffer*(target: FramebufferTarget, framebuffer: uint32) {.importc: "rlBindFramebuffer", sideEffect.}
  ## Bind framebuffer (FBO)
proc enableColorBlend*() {.importc: "rlEnableColorBlend", sideEffect.}
  ## Enable color blending
proc disableColorBlend*() {.importc: "rlDisableColorBlend", sideEffect.}
  ## Disable color blending
proc enableDepthTest*() {.importc: "rlEnableDepthTest", sideEffect.}
  ## Enable depth test
proc disableDepthTest*() {.importc: "rlDisableDepthTest", sideEffect.}
  ## Disable depth test
proc enableDepthMask*() {.importc: "rlEnableDepthMask", sideEffect.}
  ## Enable depth write
proc disableDepthMask*() {.importc: "rlDisableDepthMask", sideEffect.}
  ## Disable depth write
proc enableBackfaceCulling*() {.importc: "rlEnableBackfaceCulling", sideEffect.}
  ## Enable backface culling
proc disableBackfaceCulling*() {.importc: "rlDisableBackfaceCulling", sideEffect.}
  ## Disable backface culling
proc colorMask*(r: bool, g: bool, b: bool, a: bool) {.importc: "rlColorMask", sideEffect.}
  ## Color mask control
proc setCullFace*(mode: CullMode) {.importc: "rlSetCullFace", sideEffect.}
  ## Set face culling mode
proc enableScissorTest*() {.importc: "rlEnableScissorTest", sideEffect.}
  ## Enable scissor test
proc disableScissorTest*() {.importc: "rlDisableScissorTest", sideEffect.}
  ## Disable scissor test
proc scissor*(x: int32, y: int32, width: int32, height: int32) {.importc: "rlScissor", sideEffect.}
  ## Scissor test
proc enablePointMode*() {.importc: "rlEnablePointMode", sideEffect.}
  ## Enable point mode
proc disablePointMode*() {.importc: "rlDisablePointMode", sideEffect.}
  ## Disable point mode
proc enableWireMode*() {.importc: "rlEnableWireMode", sideEffect.}
  ## Enable wire mode
proc disableWireMode*() {.importc: "rlDisableWireMode", sideEffect.}
  ## Disable wire mode
proc setLineWidth*(width: float32) {.importc: "rlSetLineWidth", sideEffect.}
  ## Set the line drawing width
proc getLineWidth*(): float32 {.importc: "rlGetLineWidth", sideEffect.}
  ## Get the line drawing width
proc enableSmoothLines*() {.importc: "rlEnableSmoothLines", sideEffect.}
  ## Enable line aliasing
proc disableSmoothLines*() {.importc: "rlDisableSmoothLines", sideEffect.}
  ## Disable line aliasing
proc enableStereoRender*() {.importc: "rlEnableStereoRender", sideEffect.}
  ## Enable stereo rendering
proc disableStereoRender*() {.importc: "rlDisableStereoRender", sideEffect.}
  ## Disable stereo rendering
proc isStereoRenderEnabled*(): bool {.importc: "rlIsStereoRenderEnabled", sideEffect.}
  ## Check if stereo render is enabled
proc clearColor*(r: uint8, g: uint8, b: uint8, a: uint8) {.importc: "rlClearColor", sideEffect.}
  ## Clear color buffer with color
proc clearScreenBuffers*() {.importc: "rlClearScreenBuffers", sideEffect.}
  ## Clear used screen buffers (color and depth)
proc checkErrors*() {.importc: "rlCheckErrors", sideEffect.}
  ## Check and log OpenGL error codes
proc setBlendMode*(mode: BlendMode) {.importc: "rlSetBlendMode", sideEffect.}
  ## Set blending mode
proc setBlendFactors*(glSrcFactor: BlendFactor, glDstFactor: BlendFactor, glEquation: BlendFuncOrEq) {.importc: "rlSetBlendFactors", sideEffect.}
  ## Set blending mode factor and equation (using OpenGL factors)
proc setBlendFactorsSeparate*(glSrcRGB: BlendFactor, glDstRGB: BlendFactor, glSrcAlpha: BlendFactor, glDstAlpha: BlendFactor, glEqRGB: BlendFuncOrEq, glEqAlpha: BlendFuncOrEq) {.importc: "rlSetBlendFactorsSeparate", sideEffect.}
  ## Set blending mode factors and equations separately (using OpenGL factors)
proc rlglInit*(width: int32, height: int32) {.importc: "rlglInit", sideEffect.}
  ## Initialize rlgl (buffers, shaders, textures, states)
proc rlglClose*() {.importc: "rlglClose", sideEffect.}
  ## De-initialize rlgl (buffers, shaders, textures)
proc loadExtensions*(loader: rlglLoadProc) {.importc: "rlLoadExtensions", sideEffect.}
  ## Load OpenGL extensions (loader function required)
proc getVersion*(): GlVersion {.importc: "rlGetVersion", sideEffect.}
  ## Get current OpenGL version
proc setFramebufferWidth*(width: int32) {.importc: "rlSetFramebufferWidth", sideEffect.}
  ## Set current framebuffer width
proc getFramebufferWidth*(): int32 {.importc: "rlGetFramebufferWidth", sideEffect.}
  ## Get default framebuffer width
proc setFramebufferHeight*(height: int32) {.importc: "rlSetFramebufferHeight", sideEffect.}
  ## Set current framebuffer height
proc getFramebufferHeight*(): int32 {.importc: "rlGetFramebufferHeight", sideEffect.}
  ## Get default framebuffer height
proc getTextureIdDefault*(): uint32 {.importc: "rlGetTextureIdDefault", sideEffect.}
  ## Get default texture id
proc getShaderIdDefault*(): uint32 {.importc: "rlGetShaderIdDefault", sideEffect.}
  ## Get default shader id
proc getShaderLocsDefault*(): ShaderLocsPtr {.importc: "rlGetShaderLocsDefault", sideEffect.}
  ## Get default shader locations
proc loadRenderBatch*(numBuffers: int32, bufferElements: int32): RenderBatch {.importc: "rlLoadRenderBatch", sideEffect.}
  ## Load a render batch system
proc unloadRenderBatch(batch: RenderBatch) {.importc: "rlUnloadRenderBatch", sideEffect.}
proc drawRenderBatch*(batch: var RenderBatch) {.importc: "rlDrawRenderBatch", sideEffect.}
  ## Draw render batch data (Update->Draw->Reset)
proc setRenderBatchActive*(batch: var RenderBatch) {.importc: "rlSetRenderBatchActive", sideEffect.}
  ## Set the active render batch for rlgl (NULL for default internal)
proc drawRenderBatchActive*() {.importc: "rlDrawRenderBatchActive", sideEffect.}
  ## Update and draw internal render batch
proc checkRenderBatchLimit*(vCount: int32): bool {.importc: "rlCheckRenderBatchLimit", sideEffect.}
  ## Check internal buffer overflow for a given number of vertex
proc setTexture*(id: uint32) {.importc: "rlSetTexture", sideEffect.}
  ## Set current texture for render batch and check buffers limits
proc loadVertexArray*(): uint32 {.importc: "rlLoadVertexArray", sideEffect.}
  ## Load vertex array (vao) if supported
proc loadVertexBuffer*(buffer: pointer, size: int32, dynamic: bool): uint32 {.importc: "rlLoadVertexBuffer", sideEffect.}
  ## Load a vertex buffer object
proc loadVertexBufferElement*(buffer: pointer, size: int32, dynamic: bool): uint32 {.importc: "rlLoadVertexBufferElement", sideEffect.}
  ## Load vertex buffer elements object
proc updateVertexBuffer*(bufferId: uint32, data: pointer, dataSize: int32, offset: int32) {.importc: "rlUpdateVertexBuffer", sideEffect.}
  ## Update vertex buffer object data on GPU buffer
proc updateVertexBufferElements*(id: uint32, data: pointer, dataSize: int32, offset: int32) {.importc: "rlUpdateVertexBufferElements", sideEffect.}
  ## Update vertex buffer elements data on GPU buffer
proc unloadVertexArray*(vaoId: uint32) {.importc: "rlUnloadVertexArray", sideEffect.}
  ## Unload vertex array (vao)
proc unloadVertexBuffer*(vboId: uint32) {.importc: "rlUnloadVertexBuffer", sideEffect.}
  ## Unload vertex buffer object
proc setVertexAttribute*(index: uint32, compSize: int32, `type`: GlType, normalized: bool, stride: int32, offset: int32) {.importc: "rlSetVertexAttribute", sideEffect.}
  ## Set vertex attribute data configuration
proc setVertexAttributeDivisor*(index: uint32, divisor: int32) {.importc: "rlSetVertexAttributeDivisor", sideEffect.}
  ## Set vertex attribute data divisor
proc setVertexAttributeDefault*(locIndex: ShaderLocation, value: pointer, attribType: ShaderAttributeDataType, count: int32) {.importc: "rlSetVertexAttributeDefault", sideEffect.}
  ## Set vertex attribute default value, when attribute to provided
proc drawVertexArray*(offset: int32, count: int32) {.importc: "rlDrawVertexArray", sideEffect.}
  ## Draw vertex array (currently active vao)
proc drawVertexArrayElements*(offset: int32, count: int32, buffer: pointer) {.importc: "rlDrawVertexArrayElements", sideEffect.}
  ## Draw vertex array elements
proc drawVertexArrayInstanced*(offset: int32, count: int32, instances: int32) {.importc: "rlDrawVertexArrayInstanced", sideEffect.}
  ## Draw vertex array (currently active vao) with instancing
proc drawVertexArrayElementsInstanced*(offset: int32, count: int32, buffer: pointer, instances: int32) {.importc: "rlDrawVertexArrayElementsInstanced", sideEffect.}
  ## Draw vertex array elements with instancing
proc loadTexture*(data: pointer, width: int32, height: int32, format: int32, mipmapCount: int32): uint32 {.importc: "rlLoadTexture", sideEffect.}
  ## Load texture data
proc loadTextureDepth*(width: int32, height: int32, useRenderBuffer: bool): uint32 {.importc: "rlLoadTextureDepth", sideEffect.}
  ## Load depth texture/renderbuffer (to be attached to fbo)
proc loadTextureCubemap*(data: pointer, size: int32, format: PixelFormat, mipmapCount: int32): uint32 {.importc: "rlLoadTextureCubemap", sideEffect.}
  ## Load texture cubemap data
proc updateTexture*(id: uint32, offsetX: int32, offsetY: int32, width: int32, height: int32, format: PixelFormat, data: pointer) {.importc: "rlUpdateTexture", sideEffect.}
  ## Update texture with new data on GPU
proc getGlTextureFormats*(format: PixelFormat, glInternalFormat: out uint32, glFormat: out uint32, glType: out uint32) {.importc: "rlGetGlTextureFormats", sideEffect.}
  ## Get OpenGL internal formats
proc unloadTexture*(id: uint32) {.importc: "rlUnloadTexture", sideEffect.}
  ## Unload texture from GPU memory
proc genTextureMipmaps*(id: uint32, width: int32, height: int32, format: PixelFormat, mipmaps: out int32) {.importc: "rlGenTextureMipmaps", sideEffect.}
  ## Generate mipmap data for selected texture
proc readTexturePixels*(id: uint32, width: int32, height: int32, format: PixelFormat): pointer {.importc: "rlReadTexturePixels", sideEffect.}
  ## Read texture pixel data
proc readScreenPixels*(width: int32, height: int32): var uint8 {.importc: "rlReadScreenPixels", sideEffect.}
  ## Read screen pixel data (color buffer)
proc loadFramebuffer*(): uint32 {.importc: "rlLoadFramebuffer", sideEffect.}
  ## Load an empty framebuffer
proc framebufferAttach*(fboId: uint32, texId: uint32, attachType: FramebufferAttachType, texType: FramebufferAttachTextureType, mipLevel: int32) {.importc: "rlFramebufferAttach", sideEffect.}
  ## Attach texture/renderbuffer to a framebuffer
proc framebufferComplete*(id: uint32): bool {.importc: "rlFramebufferComplete", sideEffect.}
  ## Verify framebuffer is complete
proc unloadFramebuffer*(id: uint32) {.importc: "rlUnloadFramebuffer", sideEffect.}
  ## Delete framebuffer from GPU
proc loadShaderCodeImpl(vsCode: cstring, fsCode: cstring): uint32 {.importc: "rlLoadShaderCode", sideEffect.}
proc compileShaderImpl(shaderCode: cstring, `type`: ShaderType): uint32 {.importc: "rlCompileShader", sideEffect.}
proc loadShaderProgram*(vShaderId: uint32, fShaderId: uint32): uint32 {.importc: "rlLoadShaderProgram", sideEffect.}
  ## Load custom shader program
proc unloadShaderProgram*(id: uint32) {.importc: "rlUnloadShaderProgram", sideEffect.}
  ## Unload shader program
proc getLocationUniformImpl(shaderId: uint32, uniformName: cstring): ShaderLocation {.importc: "rlGetLocationUniform", sideEffect.}
proc getLocationAttribImpl(shaderId: uint32, attribName: cstring): ShaderLocation {.importc: "rlGetLocationAttrib", sideEffect.}
proc setUniform*(locIndex: ShaderLocation, value: pointer, uniformType: ShaderUniformDataType, count: int32) {.importc: "rlSetUniform", sideEffect.}
  ## Set shader value uniform
proc setUniformMatrix*(locIndex: ShaderLocation, mat: Matrix) {.importc: "rlSetUniformMatrix", sideEffect.}
  ## Set shader value matrix
proc setUniformMatrices*(locIndex: int32, mat: var Matrix, count: int32) {.importc: "rlSetUniformMatrices", sideEffect.}
  ## Set shader value matrices
proc setUniformSampler*(locIndex: ShaderLocation, textureId: uint32) {.importc: "rlSetUniformSampler", sideEffect.}
  ## Set shader value sampler
proc setShader*(id: uint32, locs: ShaderLocsPtr) {.importc: "rlSetShader", sideEffect.}
  ## Set shader currently active (id and locations)
proc loadComputeShaderProgram*(shaderId: uint32): uint32 {.importc: "rlLoadComputeShaderProgram", sideEffect.}
  ## Load compute shader program
proc computeShaderDispatch*(groupX: uint32, groupY: uint32, groupZ: uint32) {.importc: "rlComputeShaderDispatch", sideEffect.}
  ## Dispatch compute shader (equivalent to *draw* for graphics pipeline)
proc loadShaderBuffer*(size: uint32, data: pointer, usageHint: BufferUsageHint): uint32 {.importc: "rlLoadShaderBuffer", sideEffect.}
  ## Load shader storage buffer object (SSBO)
proc unloadShaderBuffer*(ssboId: uint32) {.importc: "rlUnloadShaderBuffer", sideEffect.}
  ## Unload shader storage buffer object (SSBO)
proc updateShaderBuffer*(id: uint32, data: pointer, dataSize: uint32, offset: uint32) {.importc: "rlUpdateShaderBuffer", sideEffect.}
  ## Update SSBO buffer data
proc bindShaderBuffer*(id: uint32, index: uint32) {.importc: "rlBindShaderBuffer", sideEffect.}
  ## Bind SSBO buffer
proc readShaderBuffer*(id: uint32, dest: pointer, count: uint32, offset: uint32) {.importc: "rlReadShaderBuffer", sideEffect.}
  ## Read SSBO buffer data (GPU->CPU)
proc copyShaderBuffer*(destId: uint32, srcId: uint32, destOffset: uint32, srcOffset: uint32, count: uint32) {.importc: "rlCopyShaderBuffer", sideEffect.}
  ## Copy SSBO data between buffers
proc getShaderBufferSize*(id: uint32): uint32 {.importc: "rlGetShaderBufferSize", sideEffect.}
  ## Get SSBO buffer size
proc bindImageTexture*(id: uint32, index: uint32, format: PixelFormat, readonly: bool) {.importc: "rlBindImageTexture", sideEffect.}
  ## Bind image texture
proc getMatrixModelview*(): Matrix {.importc: "rlGetMatrixModelview", sideEffect.}
  ## Get internal modelview matrix
proc getMatrixProjection*(): Matrix {.importc: "rlGetMatrixProjection", sideEffect.}
  ## Get internal projection matrix
proc getMatrixTransform*(): Matrix {.importc: "rlGetMatrixTransform", sideEffect.}
  ## Get internal accumulated transform matrix
proc getMatrixProjectionStereo*(eye: int32): Matrix {.importc: "rlGetMatrixProjectionStereo", sideEffect.}
  ## Get internal projection matrix for stereo render (selected eye)
proc getMatrixViewOffsetStereo*(eye: int32): Matrix {.importc: "rlGetMatrixViewOffsetStereo", sideEffect.}
  ## Get internal view offset matrix for stereo render (selected eye)
proc setMatrixProjection*(proj: Matrix) {.importc: "rlSetMatrixProjection", sideEffect.}
  ## Set a custom projection matrix (replaces internal projection matrix)
proc setMatrixModelview*(view: Matrix) {.importc: "rlSetMatrixModelview", sideEffect.}
  ## Set a custom modelview matrix (replaces internal modelview matrix)
proc setMatrixProjectionStereo*(right: Matrix, left: Matrix) {.importc: "rlSetMatrixProjectionStereo", sideEffect.}
  ## Set eyes projection matrices for stereo rendering
proc setMatrixViewOffsetStereo*(right: Matrix, left: Matrix) {.importc: "rlSetMatrixViewOffsetStereo", sideEffect.}
  ## Set eyes view offsets matrices for stereo rendering
proc loadDrawCube*() {.importc: "rlLoadDrawCube", sideEffect.}
  ## Load and draw a cube
proc loadDrawQuad*() {.importc: "rlLoadDrawQuad", sideEffect.}
  ## Load and draw a quad
{.pop.}

proc elementCount*(x: VertexBuffer): int32 {.inline.} = x.elementCount
proc bufferCount*(x: RenderBatch): int32 {.inline.} = x.bufferCount

proc loadShaderCode*(vsCode: string, fsCode: string): uint32 =
  ## Load shader from code strings
  loadShaderCodeImpl(if vsCode.len == 0: nil else: vsCode.cstring, if fsCode.len == 0: nil else: fsCode.cstring)

proc compileShader*(shaderCode: string, `type`: ShaderType): uint32 =
  ## Compile custom shader and return shader id (type: RL_VERTEX_SHADER, RL_FRAGMENT_SHADER, RL_COMPUTE_SHADER)
  compileShaderImpl(shaderCode.cstring, `type`)

proc getLocationUniform*(shaderId: uint32, uniformName: string): ShaderLocation =
  ## Get shader location uniform
  getLocationUniformImpl(shaderId, uniformName.cstring)

proc getLocationAttrib*(shaderId: uint32, attribName: string): ShaderLocation =
  ## Get shader location attribute
  getLocationAttribImpl(shaderId, attribName.cstring)

proc `=destroy`*(x: RenderBatch) =
  unloadRenderBatch(x)
proc `=dup`*(source: RenderBatch): RenderBatch {.error.}
proc `=copy`*(dest: var RenderBatch; source: RenderBatch) {.error.}

proc `=dup`*(source: VertexBuffer): VertexBuffer {.error.}
proc `=copy`*(dest: var VertexBuffer; source: VertexBuffer) {.error.}
proc `=sink`*(dest: var VertexBuffer; source: VertexBuffer) {.error.}

template drawMode*(mode: DrawMode; body: untyped) =
  ## Drawing mode (how to organize vertex)
  rlBegin(mode)
  try:
    body
  finally:
    rlEnd()

template vertices*(x: VertexBuffer): VertexBufferVertices = VertexBufferVertices(x)
template texcoords*(x: VertexBuffer): VertexBufferTexcoords = VertexBufferTexcoords(x)
template colors*(x: VertexBuffer): VertexBufferColors = VertexBufferColors(x)
template indices*(x: VertexBuffer): VertexBufferIndices = VertexBufferIndices(x)
template vertexBuffer*(x: RenderBatch): RenderBatchVertexBuffer = RenderBatchVertexBuffer(x)
template draws*(x: RenderBatch): RenderBatchDraws = RenderBatchDraws(x)

proc raiseIndexDefect(i, n: int) {.noinline, noreturn.} =
  raise newException(IndexDefect, "index " & $i & " not in 0 .. " & $n)

template checkArrayAccess(a, x, len) =
  when compileOption("boundChecks"):
    {.line.}:
      if x < 0 or x >= len:
        raiseIndexDefect(x, len-1)

proc `[]`*(x: VertexBufferVertices, i: int): Vector3 =
  checkArrayAccess(VertexBuffer(x).vertices, i, 4*VertexBuffer(x).elementCount)
  result = cast[ptr UncheckedArray[Vector3]](VertexBuffer(x).vertices)[i]

proc `[]`*(x: var VertexBufferVertices, i: int): var Vector3 =
  checkArrayAccess(VertexBuffer(x).vertices, i, 4*VertexBuffer(x).elementCount)
  result = cast[ptr UncheckedArray[Vector3]](VertexBuffer(x).vertices)[i]

proc `[]=`*(x: var VertexBufferVertices, i: int, val: Vector3) =
  checkArrayAccess(VertexBuffer(x).vertices, i, 4*VertexBuffer(x).elementCount)
  cast[ptr UncheckedArray[Vector3]](VertexBuffer(x).vertices)[i] = val

proc `[]`*(x: VertexBufferTexcoords, i: int): Vector2 =
  checkArrayAccess(VertexBuffer(x).texcoords, i, 4*VertexBuffer(x).elementCount)
  result = cast[ptr UncheckedArray[Vector2]](VertexBuffer(x).texcoords)[i]

proc `[]`*(x: var VertexBufferTexcoords, i: int): var Vector2 =
  checkArrayAccess(VertexBuffer(x).texcoords, i, 4*VertexBuffer(x).elementCount)
  result = cast[ptr UncheckedArray[Vector2]](VertexBuffer(x).texcoords)[i]

proc `[]=`*(x: var VertexBufferTexcoords, i: int, val: Vector2) =
  checkArrayAccess(VertexBuffer(x).texcoords, i, 4*VertexBuffer(x).elementCount)
  cast[ptr UncheckedArray[Vector2]](VertexBuffer(x).texcoords)[i] = val

proc `[]`*(x: VertexBufferColors, i: int): Color =
  checkArrayAccess(VertexBuffer(x).colors, i, 4*VertexBuffer(x).elementCount)
  result = cast[ptr UncheckedArray[Color]](VertexBuffer(x).colors)[i]

proc `[]`*(x: var VertexBufferColors, i: int): var Color =
  checkArrayAccess(VertexBuffer(x).colors, i, 4*VertexBuffer(x).elementCount)
  result = cast[ptr UncheckedArray[Color]](VertexBuffer(x).colors)[i]

proc `[]=`*(x: var VertexBufferColors, i: int, val: Color) =
  checkArrayAccess(VertexBuffer(x).colors, i, 4*VertexBuffer(x).elementCount)
  cast[ptr UncheckedArray[Color]](VertexBuffer(x).colors)[i] = val

when not UseEmbeddedGraphicsApi:
  type IndicesArr* = array[6, uint32]
else:
  type IndicesArr* = array[6, uint16]

proc `[]`*(x: VertexBufferIndices, i: int): IndicesArr =
  checkArrayAccess(VertexBuffer(x).indices, i, VertexBuffer(x).elementCount)
  result = cast[ptr UncheckedArray[typeof(result)]](VertexBuffer(x).indices)[i]

proc `[]`*(x: var VertexBufferIndices, i: int): var IndicesArr =
  checkArrayAccess(VertexBuffer(x).indices, i, VertexBuffer(x).elementCount)
  result = cast[ptr UncheckedArray[typeof(result)]](VertexBuffer(x).indices)[i]

proc `[]=`*(x: var VertexBufferIndices, i: int, val: IndicesArr) =
  checkArrayAccess(VertexBuffer(x).indices, i, VertexBuffer(x).elementCount)
  cast[ptr UncheckedArray[typeof(val)]](VertexBuffer(x).indices)[i] = val

proc `[]`*(x: RenderBatchVertexBuffer, i: int): lent VertexBuffer =
  checkArrayAccess(RenderBatch(x).vertexBuffer, i, RenderBatch(x).bufferCount)
  result = RenderBatch(x).vertexBuffer[i]

proc `[]`*(x: var RenderBatchVertexBuffer, i: int): var VertexBuffer =
  checkArrayAccess(RenderBatch(x).vertexBuffer, i, RenderBatch(x).bufferCount)
  result = RenderBatch(x).vertexBuffer[i]

proc `[]`*(x: RenderBatchDraws, i: int): lent DrawCall =
  checkArrayAccess(RenderBatch(x).draws, i, DefaultBatchDrawCalls)
  result = RenderBatch(x).draws[i]

proc `[]`*(x: var RenderBatchDraws, i: int): var DrawCall =
  checkArrayAccess(RenderBatch(x).draws, i, DefaultBatchDrawCalls)
  result = RenderBatch(x).draws[i]

proc getPixelFormatName*(format: PixelFormat): string =
  ## Get name string for pixel format
  case format
  of UncompressedGrayscale: "GRAYSCALE" # 8 bit per pixel (no alpha)
  of UncompressedGrayAlpha: "GRAY_ALPHA" # 8*2 bpp (2 channels)
  of UncompressedR5g6b5: "R5G6B5" # 16 bpp
  of UncompressedR8g8b8: "R8G8B8" # 24 bpp
  of UncompressedR5g5b5a1: "R5G5B5A1" # 16 bpp (1 bit alpha)
  of UncompressedR4g4b4a4: "R4G4B4A4" # 16 bpp (4 bit alpha)
  of UncompressedR8g8b8a8: "R8G8B8A8" # 32 bpp
  of UncompressedR32: "R32" # 32 bpp (1 channel - float)
  of UncompressedR32g32b32: "R32G32B32" # 32*3 bpp (3 channels - float)
  of UncompressedR32g32b32a32: "R32G32B32A32" # 32*4 bpp (4 channels - float)
  of UncompressedR16: "R16" ## 16 bpp (1 channel - half float)
  of UncompressedR16g16b16: "R16G16B16" ## 16*3 bpp (3 channels - half float)
  of UncompressedR16g16b16a16: "R16G16B16A16" ## 16*4 bpp (4 channels - half float)
  of CompressedDxt1Rgb: "DXT1_RGB" # 4 bpp (no alpha)
  of CompressedDxt1Rgba: "DXT1_RGBA" # 4 bpp (1 bit alpha)
  of CompressedDxt3Rgba: "DXT3_RGBA" # 8 bpp
  of CompressedDxt5Rgba: "DXT5_RGBA" # 8 bpp
  of CompressedEtc1Rgb: "ETC1_RGB" # 4 bpp
  of CompressedEtc2Rgb: "ETC2_RGB" # 4 bpp
  of CompressedEtc2EacRgba: "ETC2_RGBA" # 8 bpp
  of CompressedPvrtRgb: "PVRT_RGB" # 4 bpp
  of CompressedPvrtRgba: "PVRT_RGBA" # 4 bpp
  of CompressedAstc4x4Rgba: "ASTC_4x4_RGBA" # 8 bpp
  of CompressedAstc8x8Rgba: "ASTC_8x8_RGBA" # 2 bpp
