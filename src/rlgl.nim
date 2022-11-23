from raylib import PixelFormat, TextureFilter, BlendMode, ShaderLocationIndex,
  ShaderUniformDataType, ShaderAttributeDataType, MaxShaderLocations, Matrix, Vector2, Vector3, Color
export PixelFormat, TextureFilter, BlendMode, ShaderLocationIndex, ShaderUniformDataType,
  ShaderAttributeDataType, MaxShaderLocations, Matrix, Vector2, Vector3, Color

const
  RlglVersion* = (4, 2, 0)

type
  TextureParameter* = distinct int32
  MatrixMode* = distinct int32
  DrawMode* = distinct int32
  GlType* = distinct int32
  BufferUsageHint* = distinct int32
  ShaderType* = distinct int32

  UniformName* = distinct cstring
  AttribName* = distinct cstring

  GlVersion* = distinct int32
  FramebufferAttachType* = distinct int32
  FramebufferAttachTextureType* = distinct int32
  CullMode* = distinct int32

proc `==`*(a, b: TextureParameter): bool {.borrow.}
proc `==`*(a, b: MatrixMode): bool {.borrow.}
proc `==`*(a, b: DrawMode): bool {.borrow.}
proc `==`*(a, b: GlType): bool {.borrow.}
proc `==`*(a, b: BufferUsageHint): bool {.borrow.}
proc `==`*(a, b: ShaderType): bool {.borrow.}

proc `==`*(a, b: UniformName): bool {.borrow.}
proc `==`*(a, b: AttribName): bool {.borrow.}

proc `<`*(a, b: GlVersion): bool {.borrow.}
proc `<=`*(a, b: GlVersion): bool {.borrow.}
proc `==`*(a, b: GlVersion): bool {.borrow.}

proc `<`*(a, b: FramebufferAttachType): bool {.borrow.}
proc `<=`*(a, b: FramebufferAttachType): bool {.borrow.}
proc `==`*(a, b: FramebufferAttachType): bool {.borrow.}

proc `<`*(a, b: FramebufferAttachTextureType): bool {.borrow.}
proc `<=`*(a, b: FramebufferAttachTextureType): bool {.borrow.}
proc `==`*(a, b: FramebufferAttachTextureType): bool {.borrow.}

proc `==`*(a, b: CullMode): bool {.borrow.}

type
  rlglLoadProc* = proc (name: cstring): pointer ## OpenGL extension functions loader signature (same as GLADloadproc)

const
  Opengl11* = GlVersion(1) ## OpenGL 1.1
  Opengl21* = GlVersion(2) ## OpenGL 2.1 (GLSL 120)
  Opengl33* = GlVersion(3) ## OpenGL 3.3 (GLSL 330)
  Opengl43* = GlVersion(4) ## OpenGL 4.3 (using GLSL 330)
  OpenglEs20* = GlVersion(5) ## OpenGL ES 2.0 (GLSL 100)

  AttachmentColorChannel0* = FramebufferAttachType(0) ## Framebuffer attachmment type: color 0
  AttachmentColorChannel1* = FramebufferAttachType(1) ## Framebuffer attachmment type: color 1
  AttachmentColorChannel2* = FramebufferAttachType(2) ## Framebuffer attachmment type: color 2
  AttachmentColorChannel3* = FramebufferAttachType(3) ## Framebuffer attachmment type: color 3
  AttachmentColorChannel4* = FramebufferAttachType(4) ## Framebuffer attachmment type: color 4
  AttachmentColorChannel5* = FramebufferAttachType(5) ## Framebuffer attachmment type: color 5
  AttachmentColorChannel6* = FramebufferAttachType(6) ## Framebuffer attachmment type: color 6
  AttachmentColorChannel7* = FramebufferAttachType(7) ## Framebuffer attachmment type: color 7
  AttachmentDepth* = FramebufferAttachType(100) ## Framebuffer attachmment type: depth
  AttachmentStencil* = FramebufferAttachType(200) ## Framebuffer attachmment type: stencil

  AttachmentCubemapPositiveX* = FramebufferAttachTextureType(0) ## Framebuffer texture attachment type: cubemap, +X side
  AttachmentCubemapNegativeX* = FramebufferAttachTextureType(1) ## Framebuffer texture attachment type: cubemap, -X side
  AttachmentCubemapPositiveY* = FramebufferAttachTextureType(2) ## Framebuffer texture attachment type: cubemap, +Y side
  AttachmentCubemapNegativeY* = FramebufferAttachTextureType(3) ## Framebuffer texture attachment type: cubemap, -Y side
  AttachmentCubemapPositiveZ* = FramebufferAttachTextureType(4) ## Framebuffer texture attachment type: cubemap, +Z side
  AttachmentCubemapNegativeZ* = FramebufferAttachTextureType(5) ## Framebuffer texture attachment type: cubemap, -Z side
  AttachmentTexture2d* = FramebufferAttachTextureType(100) ## Framebuffer texture attachment type: texture2d
  AttachmentRenderbuffer* = FramebufferAttachTextureType(200) ## Framebuffer texture attachment type: renderbuffer

  CullFaceFront* = CullMode(0)
  CullFaceBack* = CullMode(1)

  DefaultBatchBufferElements = 8192 ## This is the maximum amount of elements (quads) per batch
                                    ## NOTE: Be careful with text, every letter maps to a quad
  DefaultBatchBuffers = 1 ## Default number of batch buffers (multi-buffering)
  DefaultBatchDrawCalls = 256 ## Default number of batch draw calls (by state changes: mode, texture)
  DefaultBatchMaxTextureUnits = 4 ## Maximum number of textures units that can be activated on batch drawing
  MaxMatrixStackSize = 32 ## Maximum size of Matrix stack
  # MaxShaderLocations = 32 ## Maximum number of shader locations supported
  CullDistanceNear = 0.01 ## Default near cull distance
  CullDistanceFar = 1000.0 ## Default far cull distance

  # Texture parameters (equivalent to OpenGL defines)
  TextureWrapS = TextureParameter(0x2802) ## GL_TEXTURE_WRAP_S
  TextureWrapT = TextureParameter(0x2803) ## GL_TEXTURE_WRAP_T
  TextureMagFilter = TextureParameter(0x2800) ## GL_TEXTURE_MAG_FILTER
  TextureMinFilter = TextureParameter(0x2801) ## GL_TEXTURE_MIN_FILTER

  TextureFilterNearest = TextureParameter(0x2600) ## GL_NEAREST
  TextureFilterLinear = TextureParameter(0x2601) ## GL_LINEAR
  TextureFilterMipNearest = TextureParameter(0x2700) ## GL_NEAREST_MIPMAP_NEAREST
  TextureFilterNearestMipLinear = TextureParameter(0x2702) ## GL_NEAREST_MIPMAP_LINEAR
  TextureFilterLinearMipNearest = TextureParameter(0x2701) ## GL_LINEAR_MIPMAP_NEAREST
  TextureFilterMipLinear = TextureParameter(0x2703) ## GL_LINEAR_MIPMAP_LINEAR
  TextureFilterAnisotropic = TextureParameter(0x3000) ## Anisotropic filter (custom identifier)
  TextureMipmapBiasRatio = TextureParameter(0x4000) ## Texture mipmap bias, percentage ratio (custom identifier)

  TextureWrapRepeat = TextureParameter(0x2901) ## GL_REPEAT
  TextureWrapClamp = TextureParameter(0x812F) ## GL_CLAMP_TO_EDGE
  TextureWrapMirrorRepeat = TextureParameter(0x8370) ## GL_MIRRORED_REPEAT
  TextureWrapMirrorClamp = TextureParameter(0x8742) ## GL_MIRROR_CLAMP_EXT

  # Matrix modes (equivalent to OpenGL)
  MatrixModelview = MatrixMode(0x1700) ## GL_MODELVIEW
  MatrixProjection = MatrixMode(0x1701) ## GL_PROJECTION
  MatrixTexture = MatrixMode(0x1702) ## GL_TEXTURE

  # Primitive assembly draw modes
  DrawLines = DrawMode(0x0001) ## GL_LINES
  DrawTriangles = DrawMode(0x0004) ## GL_TRIANGLES
  DrawQuads = DrawMode(0x0007) ## GL_QUADS

  # GL equivalent data types
  GlUnsignedByte = GlType(0x1401) ## GL_UNSIGNED_BYTE
  GlFloat = GlType(0x1406) ## GL_FLOAT

  # Buffer usage hint
  UsageStreamDraw = BufferUsageHint(0x88E0) ## GL_STREAM_DRAW
  UsageStreamRead = BufferUsageHint(0x88E1) ## GL_STREAM_READ
  UsageStreamCopy = BufferUsageHint(0x88E2) ## GL_STREAM_COPY
  UsageStaticDraw = BufferUsageHint(0x88E4) ## GL_STATIC_DRAW
  UsageStaticRead = BufferUsageHint(0x88E5) ## GL_STATIC_READ
  UsageStaticCopy = BufferUsageHint(0x88E6) ## GL_STATIC_COPY
  UsageDynamicDraw = BufferUsageHint(0x88E8) ## GL_DYNAMIC_DRAW
  UsageDynamicRead = BufferUsageHint(0x88E9) ## GL_DYNAMIC_READ
  UsageDynamicCopy = BufferUsageHint(0x88EA) ## GL_DYNAMIC_COPY

  # GL Shader type
  FragmentShader = ShaderType(0x8B30) ## GL_FRAGMENT_SHADER
  VertexShader = ShaderType(0x8B31) ## GL_VERTEX_SHADER
  ComputeShader = ShaderType(0x91B9) ## GL_COMPUTE_SHADER

  # Default shader vertex attribute names to set location points
  DefaultShaderAttribNamePosition* = AttribName("vertexPosition") ## Binded by default to shader location: 0
  DefaultShaderAttribNameTexcoord* = AttribName("vertexTexCoord") ## Binded by default to shader location: 1
  DefaultShaderAttribNameNormal* = AttribName("vertexNormal") ## Binded by default to shader location: 2
  DefaultShaderAttribNameColor* = AttribName("vertexColor") ## Binded by default to shader location: 3
  DefaultShaderAttribNameTangent* = AttribName("vertexTangent") ## Binded by default to shader location: 4
  DefaultShaderAttribNameTexcoord2* = AttribName("vertexTexCoord2") ## Binded by default to shader location: 5

  DefaultShaderUniformNameMvp* = UniformName("mvp") ## model-view-projection matrix
  DefaultShaderUniformNameView* = UniformName("matView") ## view matrix
  DefaultShaderUniformNameProjection* = UniformName("matProjection") ## projection matrix
  DefaultShaderUniformNameModel* = UniformName("matModel") ## model matrix
  DefaultShaderUniformNameNormal* = UniformName("matNormal") ## normal matrix (transpose(inverse(matModelView))
  DefaultShaderUniformNameColor* = UniformName("colDiffuse") ## color diffuse (base tint color, multiplied by texture color)
  DefaultShaderSampler2dNameTexture0* = UniformName("texture0") ## texture0 (texture slot active 0)
  DefaultShaderSampler2dNameTexture1* = UniformName("texture1") ## texture1 (texture slot active 1)
  DefaultShaderSampler2dNameTexture2* = UniformName("texture2") ## texture2 (texture slot active 2)

type
  VertexBuffer* {.bycopy.} = object ## Dynamic vertex buffers (position + texcoords + colors + indices arrays)
    elementCount*: int32 ## Number of elements in the buffer (QUADS)
    vertices: ptr UncheckedArray[float32] ## Vertex position (XYZ - 3 components per vertex) (shader-location = 0)
    texcoords: ptr UncheckedArray[float32] ## Vertex texture coordinates (UV - 2 components per vertex) (shader-location = 1)
    colors: ptr UncheckedArray[uint8] ## Vertex colors (RGBA - 4 components per vertex) (shader-location = 3)
    indices: ptr UncheckedArray[uint32] ## Vertex indices (in case vertex data comes indexed) (6 indices per quad)
    vaoId*: uint32 ## OpenGL Vertex Array Object id
    vboId*: array[4, uint32] ## OpenGL Vertex Buffer Objects id (4 types of vertex data)

  DrawCall* {.bycopy.} = object ## of those state-change happens (this is done in core module)
    mode*: int32 ## Drawing mode: LINES, TRIANGLES, QUADS
    vertexCount*: int32 ## Number of vertex of the draw
    vertexAlignment*: int32 ## Number of vertex required for index alignment (LINES, TRIANGLES)
    textureId*: uint32 ## Texture id to be used on the draw -> Use to create new draw call if changes

  RenderBatch* {.bycopy.} = object ## rlRenderBatch type
    bufferCount*: int32 ## Number of vertex buffers (multi-buffering support)
    currentBuffer*: int32 ## Current buffer tracking in case of multi-buffering
    vertexBuffer: ptr UncheckedArray[VertexBuffer] ## Dynamic buffer(s) for vertex data
    draws: ptr UncheckedArray[DrawCall] ## Draw calls array, depends on textureId
    drawCounter*: int32 ## Draw calls counter
    currentDepth*: float32 ## Current depth value for next draw

  VertexBufferVertices* = distinct VertexBuffer
  VertexBufferTexcoords* = distinct VertexBuffer
  VertexBufferColors* = distinct VertexBuffer
  VertexBufferIndices* = distinct VertexBuffer
  RenderBatchVertexBuffer* = distinct RenderBatch
  RenderBatchDraws* = distinct RenderBatch

{.push callconv: cdecl, header: "rlgl.h".}
proc matrixMode*(mode: MatrixMode) {.importc: "rlMatrixMode".}
  ## Choose the current matrix to be transformed
proc pushMatrix*() {.importc: "rlPushMatrix".}
  ## Push the current matrix to stack
proc popMatrix*() {.importc: "rlPopMatrix".}
  ## Pop lattest inserted matrix from stack
proc loadIdentity*() {.importc: "rlLoadIdentity".}
  ## Reset current matrix to identity matrix
proc translatef*(x: float32, y: float32, z: float32) {.importc: "rlTranslatef".}
  ## Multiply the current matrix by a translation matrix
proc rotatef*(angle: float32, x: float32, y: float32, z: float32) {.importc: "rlRotatef".}
  ## Multiply the current matrix by a rotation matrix
proc scalef*(x: float32, y: float32, z: float32) {.importc: "rlScalef".}
  ## Multiply the current matrix by a scaling matrix
proc multMatrixf*(matf: var array[16, float32]) {.importc: "rlMultMatrixf".}
  ## Multiply the current matrix by another matrix
proc frustum*(left: float, right: float, bottom: float, top: float, znear: float, zfar: float) {.importc: "rlFrustum".}
proc ortho*(left: float, right: float, bottom: float, top: float, znear: float, zfar: float) {.importc: "rlOrtho".}
proc viewport*(x: int32, y: int32, width: int32, height: int32) {.importc: "rlViewport".}
  ## Set the viewport area
proc rlBegin*(mode: DrawMode) {.importc: "rlBegin".}
  ## Initialize drawing mode (how to organize vertex)
proc rlEnd*() {.importc: "rlEnd".}
  ## Finish vertex providing
proc vertex2i*(x: int32, y: int32) {.importc: "rlVertex2i".}
  ## Define one vertex (position) - 2 int
proc vertex2f*(x: float32, y: float32) {.importc: "rlVertex2f".}
  ## Define one vertex (position) - 2 float
proc vertex3f*(x: float32, y: float32, z: float32) {.importc: "rlVertex3f".}
  ## Define one vertex (position) - 3 float
proc texCoord2f*(x: float32, y: float32) {.importc: "rlTexCoord2f".}
  ## Define one vertex (texture coordinate) - 2 float
proc normal3f*(x: float32, y: float32, z: float32) {.importc: "rlNormal3f".}
  ## Define one vertex (normal) - 3 float
proc color4ub*(r: uint8, g: uint8, b: uint8, a: uint8) {.importc: "rlColor4ub".}
  ## Define one vertex (color) - 4 byte
proc color3f*(x: float32, y: float32, z: float32) {.importc: "rlColor3f".}
  ## Define one vertex (color) - 3 float
proc color4f*(x: float32, y: float32, z: float32, w: float32) {.importc: "rlColor4f".}
  ## Define one vertex (color) - 4 float
proc enableVertexArray*(vaoId: uint32): bool {.importc: "rlEnableVertexArray".}
  ## Enable vertex array (VAO, if supported)
proc disableVertexArray*() {.importc: "rlDisableVertexArray".}
  ## Disable vertex array (VAO, if supported)
proc enableVertexBuffer*(id: uint32) {.importc: "rlEnableVertexBuffer".}
  ## Enable vertex buffer (VBO)
proc disableVertexBuffer*() {.importc: "rlDisableVertexBuffer".}
  ## Disable vertex buffer (VBO)
proc enableVertexBufferElement*(id: uint32) {.importc: "rlEnableVertexBufferElement".}
  ## Enable vertex buffer element (VBO element)
proc disableVertexBufferElement*() {.importc: "rlDisableVertexBufferElement".}
  ## Disable vertex buffer element (VBO element)
proc enableVertexAttribute*(index: uint32) {.importc: "rlEnableVertexAttribute".}
  ## Enable vertex attribute index
proc disableVertexAttribute*(index: uint32) {.importc: "rlDisableVertexAttribute".}
  ## Disable vertex attribute index
proc enableStatePointer*(vertexAttribType: int32, buffer: pointer) {.importc: "rlEnableStatePointer".}
  ## Enable attribute state pointer
proc disableStatePointer*(vertexAttribType: int32) {.importc: "rlDisableStatePointer".}
  ## Disable attribute state pointer
proc activeTextureSlot*(slot: int32) {.importc: "rlActiveTextureSlot".}
  ## Select and active a texture slot
proc enableTexture*(id: uint32) {.importc: "rlEnableTexture".}
  ## Enable texture
proc disableTexture*() {.importc: "rlDisableTexture".}
  ## Disable texture
proc enableTextureCubemap*(id: uint32) {.importc: "rlEnableTextureCubemap".}
  ## Enable texture cubemap
proc disableTextureCubemap*() {.importc: "rlDisableTextureCubemap".}
  ## Disable texture cubemap
proc textureParameters*(id: uint32, param: TextureParameter, value: int32) {.importc: "rlTextureParameters".}
  ## Set texture parameters (filter, wrap)
proc enableShader*(id: uint32) {.importc: "rlEnableShader".}
  ## Enable shader program
proc disableShader*() {.importc: "rlDisableShader".}
  ## Disable shader program
proc enableFramebuffer*(id: uint32) {.importc: "rlEnableFramebuffer".}
  ## Enable render texture (fbo)
proc disableFramebuffer*() {.importc: "rlDisableFramebuffer".}
  ## Disable render texture (fbo), return to default framebuffer
proc activeDrawBuffers*(count: int32) {.importc: "rlActiveDrawBuffers".}
  ## Activate multiple draw color buffers
proc enableColorBlend*() {.importc: "rlEnableColorBlend".}
  ## Enable color blending
proc disableColorBlend*() {.importc: "rlDisableColorBlend".}
  ## Disable color blending
proc enableDepthTest*() {.importc: "rlEnableDepthTest".}
  ## Enable depth test
proc disableDepthTest*() {.importc: "rlDisableDepthTest".}
  ## Disable depth test
proc enableDepthMask*() {.importc: "rlEnableDepthMask".}
  ## Enable depth write
proc disableDepthMask*() {.importc: "rlDisableDepthMask".}
  ## Disable depth write
proc enableBackfaceCulling*() {.importc: "rlEnableBackfaceCulling".}
  ## Enable backface culling
proc disableBackfaceCulling*() {.importc: "rlDisableBackfaceCulling".}
  ## Disable backface culling
proc setCullFace*(mode: CullMode) {.importc: "rlSetCullFace".}
  ## Set face culling mode
proc enableScissorTest*() {.importc: "rlEnableScissorTest".}
  ## Enable scissor test
proc disableScissorTest*() {.importc: "rlDisableScissorTest".}
  ## Disable scissor test
proc scissor*(x: int32, y: int32, width: int32, height: int32) {.importc: "rlScissor".}
  ## Scissor test
proc enableWireMode*() {.importc: "rlEnableWireMode".}
  ## Enable wire mode
proc disableWireMode*() {.importc: "rlDisableWireMode".}
  ## Disable wire mode
proc setLineWidth*(width: float32) {.importc: "rlSetLineWidth".}
  ## Set the line drawing width
proc getLineWidth*(): float32 {.importc: "rlGetLineWidth".}
  ## Get the line drawing width
proc enableSmoothLines*() {.importc: "rlEnableSmoothLines".}
  ## Enable line aliasing
proc disableSmoothLines*() {.importc: "rlDisableSmoothLines".}
  ## Disable line aliasing
proc enableStereoRender*() {.importc: "rlEnableStereoRender".}
  ## Enable stereo rendering
proc disableStereoRender*() {.importc: "rlDisableStereoRender".}
  ## Disable stereo rendering
proc isStereoRenderEnabled*(): bool {.importc: "rlIsStereoRenderEnabled".}
  ## Check if stereo render is enabled
proc clearColor*(r: uint8, g: uint8, b: uint8, a: uint8) {.importc: "rlClearColor".}
  ## Clear color buffer with color
proc clearScreenBuffers*() {.importc: "rlClearScreenBuffers".}
  ## Clear used screen buffers (color and depth)
proc checkErrors*() {.importc: "rlCheckErrors".}
  ## Check and log OpenGL error codes
proc setBlendMode*(mode: BlendMode) {.importc: "rlSetBlendMode".}
  ## Set blending mode
proc setBlendFactors*(glSrcFactor: int32, glDstFactor: int32, glEquation: int32) {.importc: "rlSetBlendFactors".}
  ## Set blending mode factor and equation (using OpenGL factors)
proc setBlendFactorsSeparate*(glSrcRGB: int32, glDstRGB: int32, glSrcAlpha: int32, glDstAlpha: int32, glEqRGB: int32, glEqAlpha: int32) {.importc: "rlSetBlendFactorsSeparate".}
  ## Set blending mode factors and equations separately (using OpenGL factors)
proc rlglInit*(width: int32, height: int32) {.importc: "rlglInit".}
  ## Initialize rlgl (buffers, shaders, textures, states)
proc rlglClose*() {.importc: "rlglClose".}
  ## De-inititialize rlgl (buffers, shaders, textures)
proc loadExtensions*(loader: rlglLoadProc) {.importc: "rlLoadExtensions".}
  ## Load OpenGL extensions (loader function required)
proc getVersion*(): GlVersion {.importc: "rlGetVersion".}
  ## Get current OpenGL version
proc setFramebufferWidth*(width: int32) {.importc: "rlSetFramebufferWidth".}
  ## Set current framebuffer width
proc getFramebufferWidth*(): int32 {.importc: "rlGetFramebufferWidth".}
  ## Get default framebuffer width
proc setFramebufferHeight*(height: int32) {.importc: "rlSetFramebufferHeight".}
  ## Set current framebuffer height
proc getFramebufferHeight*(): int32 {.importc: "rlGetFramebufferHeight".}
  ## Get default framebuffer height
proc getTextureIdDefault*(): uint32 {.importc: "rlGetTextureIdDefault".}
  ## Get default texture id
proc getShaderIdDefault*(): uint32 {.importc: "rlGetShaderIdDefault".}
  ## Get default shader id
proc getShaderLocsDefault*(): var ShaderLocation {.importc: "rlGetShaderLocsDefault".}
  ## Get default shader locations
proc loadRenderBatch*(numBuffers: int32, bufferElements: int32): RenderBatch {.importc: "rlLoadRenderBatch".}
  ## Load a render batch system
proc unloadRenderBatch*(batch: RenderBatch) {.importc: "rlUnloadRenderBatch".}
  ## Unload render batch system
proc drawRenderBatch*(batch: var RenderBatch) {.importc: "rlDrawRenderBatch".}
  ## Draw render batch data (Update->Draw->Reset)
proc setRenderBatchActive*(batch: var RenderBatch) {.importc: "rlSetRenderBatchActive".}
  ## Set the active render batch for rlgl (NULL for default internal)
proc drawRenderBatchActive*() {.importc: "rlDrawRenderBatchActive".}
  ## Update and draw internal render batch
proc checkRenderBatchLimit*(vCount: int32): bool {.importc: "rlCheckRenderBatchLimit".}
  ## Check internal buffer overflow for a given number of vertex
proc setTexture*(id: uint32) {.importc: "rlSetTexture".}
  ## Set current texture for render batch and check buffers limits
proc loadVertexArray*(): uint32 {.importc: "rlLoadVertexArray".}
  ## Load vertex array (vao) if supported
proc loadVertexBuffer*(buffer: pointer, size: int32, dynamic: bool): uint32 {.importc: "rlLoadVertexBuffer".}
  ## Load a vertex buffer attribute
proc loadVertexBufferElement*(buffer: pointer, size: int32, dynamic: bool): uint32 {.importc: "rlLoadVertexBufferElement".}
  ## Load a new attributes element buffer
proc updateVertexBuffer*(bufferId: uint32, data: pointer, dataSize: int32, offset: int32) {.importc: "rlUpdateVertexBuffer".}
  ## Update GPU buffer with new data
proc updateVertexBufferElements*(id: uint32, data: pointer, dataSize: int32, offset: int32) {.importc: "rlUpdateVertexBufferElements".}
  ## Update vertex buffer elements with new data
proc unloadVertexArray*(vaoId: uint32) {.importc: "rlUnloadVertexArray".}
proc unloadVertexBuffer*(vboId: uint32) {.importc: "rlUnloadVertexBuffer".}
proc setVertexAttribute*(index: uint32, compSize: int32, `type`: GlType, normalized: bool, stride: int32, pointer: pointer) {.importc: "rlSetVertexAttribute".}
proc setVertexAttributeDivisor*(index: uint32, divisor: int32) {.importc: "rlSetVertexAttributeDivisor".}
proc setVertexAttributeDefault*(locIndex: int32, value: pointer, attribType: ShaderAttributeDataType, count: int32) {.importc: "rlSetVertexAttributeDefault".}
  ## Set vertex attribute default value
proc drawVertexArray*(offset: int32, count: int32) {.importc: "rlDrawVertexArray".}
proc drawVertexArrayElements*(offset: int32, count: int32, buffer: pointer) {.importc: "rlDrawVertexArrayElements".}
proc drawVertexArrayInstanced*(offset: int32, count: int32, instances: int32) {.importc: "rlDrawVertexArrayInstanced".}
proc drawVertexArrayElementsInstanced*(offset: int32, count: int32, buffer: pointer, instances: int32) {.importc: "rlDrawVertexArrayElementsInstanced".}
proc loadTexture*(data: pointer, width: int32, height: int32, format: int32, mipmapCount: int32): uint32 {.importc: "rlLoadTexture".}
  ## Load texture in GPU
proc loadTextureDepth*(width: int32, height: int32, useRenderBuffer: bool): uint32 {.importc: "rlLoadTextureDepth".}
  ## Load depth texture/renderbuffer (to be attached to fbo)
proc loadTextureCubemap*(data: pointer, size: int32, format: int32): uint32 {.importc: "rlLoadTextureCubemap".}
  ## Load texture cubemap
proc updateTexture*(id: uint32, offsetX: int32, offsetY: int32, width: int32, height: int32, format: int32, data: pointer) {.importc: "rlUpdateTexture".}
  ## Update GPU texture with new data
proc getGlTextureFormats*(format: int32, glInternalFormat: out uint32, glFormat: out uint32, glType: out uint32) {.importc: "rlGetGlTextureFormats".}
  ## Get OpenGL internal formats
proc getPixelFormatName*(format: PixelFormat): cstring {.importc: "rlGetPixelFormatName".}
  ## Get name string for pixel format
proc unloadTexture*(id: uint32) {.importc: "rlUnloadTexture".}
  ## Unload texture from GPU memory
proc genTextureMipmaps*(id: uint32, width: int32, height: int32, format: int32, mipmaps: out int32) {.importc: "rlGenTextureMipmaps".}
  ## Generate mipmap data for selected texture
proc readTexturePixels*(id: uint32, width: int32, height: int32, format: int32): pointer {.importc: "rlReadTexturePixels".}
  ## Read texture pixel data
proc readScreenPixels*(width: int32, height: int32): var uint8 {.importc: "rlReadScreenPixels".}
  ## Read screen pixel data (color buffer)
proc loadFramebuffer*(width: int32, height: int32): uint32 {.importc: "rlLoadFramebuffer".}
  ## Load an empty framebuffer
proc framebufferAttach*(fboId: uint32, texId: uint32, attachType: FramebufferAttachType, texType: FramebufferAttachTextureType, mipLevel: int32) {.importc: "rlFramebufferAttach".}
  ## Attach texture/renderbuffer to a framebuffer
proc framebufferComplete*(id: uint32): bool {.importc: "rlFramebufferComplete".}
  ## Verify framebuffer is complete
proc unloadFramebuffer*(id: uint32) {.importc: "rlUnloadFramebuffer".}
  ## Delete framebuffer from GPU
proc loadShaderCode*(vsCode: cstring, fsCode: cstring): uint32 {.importc: "rlLoadShaderCode".}
  ## Load shader from code strings
proc compileShader*(shaderCode: cstring, `type`: ShaderType): uint32 {.importc: "rlCompileShader".}
  ## Compile custom shader and return shader id (type: RL_VERTEX_SHADER, RL_FRAGMENT_SHADER, RL_COMPUTE_SHADER)
proc loadShaderProgram*(vShaderId: uint32, fShaderId: uint32): uint32 {.importc: "rlLoadShaderProgram".}
  ## Load custom shader program
proc unloadShaderProgram*(id: uint32) {.importc: "rlUnloadShaderProgram".}
  ## Unload shader program
proc getLocationUniform*(shaderId: uint32, uniformName: UniformName): int32 {.importc: "rlGetLocationUniform".}
  ## Get shader location uniform
proc getLocationAttrib*(shaderId: uint32, attribName: AttribName): int32 {.importc: "rlGetLocationAttrib".}
  ## Get shader location attribute
proc setUniform*(locIndex: int32, value: pointer, uniformType: ShaderUniformDataType, count: int32) {.importc: "rlSetUniform".}
  ## Set shader value uniform
proc setUniformMatrix*(locIndex: int32, mat: Matrix) {.importc: "rlSetUniformMatrix".}
  ## Set shader value matrix
proc setUniformSampler*(locIndex: int32, textureId: uint32) {.importc: "rlSetUniformSampler".}
  ## Set shader value sampler
proc setShader*(id: uint32, locs: var ShaderLocation) {.importc: "rlSetShader".}
  ## Set shader currently active (id and locations)
proc loadComputeShaderProgram*(shaderId: uint32): uint32 {.importc: "rlLoadComputeShaderProgram".}
  ## Load compute shader program
proc computeShaderDispatch*(groupX: uint32, groupY: uint32, groupZ: uint32) {.importc: "rlComputeShaderDispatch".}
  ## Dispatch compute shader (equivalent to *draw* for graphics pilepine)
proc loadShaderBuffer*(size: uint32, data: pointer, usageHint: BufferUsageHint): uint32 {.importc: "rlLoadShaderBuffer".}
  ## Load shader storage buffer object (SSBO)
proc unloadShaderBuffer*(ssboId: uint32) {.importc: "rlUnloadShaderBuffer".}
  ## Unload shader storage buffer object (SSBO)
proc updateShaderBuffer*(id: uint32, data: pointer, dataSize: uint32, offset: uint32) {.importc: "rlUpdateShaderBuffer".}
  ## Update SSBO buffer data
proc bindShaderBuffer*(id: uint32, index: uint32) {.importc: "rlBindShaderBuffer".}
  ## Bind SSBO buffer
proc readShaderBuffer*(id: uint32, dest: pointer, count: uint32, offset: uint32) {.importc: "rlReadShaderBuffer".}
  ## Read SSBO buffer data (GPU->CPU)
proc copyShaderBuffer*(destId: uint32, srcId: uint32, destOffset: uint32, srcOffset: uint32, count: uint32) {.importc: "rlCopyShaderBuffer".}
  ## Copy SSBO data between buffers
proc getShaderBufferSize*(id: uint32): uint32 {.importc: "rlGetShaderBufferSize".}
  ## Get SSBO buffer size
proc bindImageTexture*(id: uint32, index: uint32, format: uint32, readonly: int32) {.importc: "rlBindImageTexture".}
  ## Bind image texture
proc getMatrixModelview*(): Matrix {.importc: "rlGetMatrixModelview".}
  ## Get internal modelview matrix
proc getMatrixProjection*(): Matrix {.importc: "rlGetMatrixProjection".}
  ## Get internal projection matrix
proc getMatrixTransform*(): Matrix {.importc: "rlGetMatrixTransform".}
  ## Get internal accumulated transform matrix
proc getMatrixProjectionStereo*(eye: int32): Matrix {.importc: "rlGetMatrixProjectionStereo".}
  ## Get internal projection matrix for stereo render (selected eye)
proc getMatrixViewOffsetStereo*(eye: int32): Matrix {.importc: "rlGetMatrixViewOffsetStereo".}
  ## Get internal view offset matrix for stereo render (selected eye)
proc setMatrixProjection*(proj: Matrix) {.importc: "rlSetMatrixProjection".}
  ## Set a custom projection matrix (replaces internal projection matrix)
proc setMatrixModelview*(view: Matrix) {.importc: "rlSetMatrixModelview".}
  ## Set a custom modelview matrix (replaces internal modelview matrix)
proc setMatrixProjectionStereo*(right: Matrix, left: Matrix) {.importc: "rlSetMatrixProjectionStereo".}
  ## Set eyes projection matrices for stereo rendering
proc setMatrixViewOffsetStereo*(right: Matrix, left: Matrix) {.importc: "rlSetMatrixViewOffsetStereo".}
  ## Set eyes view offsets matrices for stereo rendering
proc loadDrawCube*() {.importc: "rlLoadDrawCube".}
  ## Load and draw a cube
proc loadDrawQuad*() {.importc: "rlLoadDrawQuad".}
  ## Load and draw a quad
{.pop.}

proc `=destroy`*(x: var RenderBatch) =
  if x.vertexBuffer != nil: unloadRenderBatch(x)
proc `=copy`*(dest: var RenderBatch; source: RenderBatch) {.error.}

proc `=sink`*(dest: var VertexBuffer; source: VertexBuffer) {.error.}
proc `=copy`*(dest: var VertexBuffer; source: VertexBuffer) {.error.}

template drawMode*(mode: DrawMode; body: untyped) =
  ## Drawing mode (how to organize vertex)
  rlBegin(mode)
  try:
    body
  finally: rlEnd()

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

proc `[]`*(x: VertexBufferIndices, i: int): array[6, uint32] =
  checkArrayAccess(VertexBuffer(x).indices, i, VertexBuffer(x).elementCount)
  result = cast[ptr UncheckedArray[typeof(result)]](VertexBuffer(x).indices)[i]

proc `[]`*(x: var VertexBufferIndices, i: int): var array[6, uint32] =
  checkArrayAccess(VertexBuffer(x).indices, i, VertexBuffer(x).elementCount)
  result = cast[ptr UncheckedArray[typeof(result)]](VertexBuffer(x).indices)[i]

proc `[]=`*(x: var VertexBufferIndices, i: int, val: array[6, uint32]) =
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
