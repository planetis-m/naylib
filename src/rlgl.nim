from raylib import PixelFormat, TextureFilter, BlendMode, ShaderLocationIndex,
  ShaderUniformDataType, ShaderAttributeDataType, MaxShaderLocations, Matrix
export PixelFormat, TextureFilter, BlendMode, ShaderLocationIndex, ShaderUniformDataType,
  ShaderAttributeDataType

const
  RlglVersion* = (4, 2, 0)

type
  VertexBuffer* {.bycopy.} = object ## Dynamic vertex buffers (position + texcoords + colors + indices arrays)
    elementCount*: int32 ## Number of elements in the buffer (QUADS)
    vertices*: ptr float32 ## Vertex position (XYZ - 3 components per vertex) (shader-location = 0)
    texcoords*: ptr float32 ## Vertex texture coordinates (UV - 2 components per vertex) (shader-location = 1)
    colors*: ptr uint8 ## Vertex colors (RGBA - 4 components per vertex) (shader-location = 3)
    indices*: ptr uint32 ## Vertex indices (in case vertex data comes indexed) (6 indices per quad)
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
    vertexBuffer*: ptr rlVertexBuffer ## Dynamic buffer(s) for vertex data
    draws*: ptr rlDrawCall ## Draw calls array, depends on textureId
    drawCounter*: int32 ## Draw calls counter
    currentDepth*: float32 ## Current depth value for next draw

  RlglData* {.bycopy.} = object
    currentBatch*: ptr rlRenderBatch ## Current render batch
    defaultBatch*: rlRenderBatch ## Default internal render batch
    vertexCounter*: int32 ## Current active render batch vertex counter (generic, used for all batches)
    texcoordx*: float32 ## Current active texture coordinate (added on glVertex*())
    texcoordy*: float32 ## Current active texture coordinate (added on glVertex*())
    normalx*: float32 ## Current active normal (added on glVertex*())
    normaly*: float32 ## Current active normal (added on glVertex*())
    normalz*: float32 ## Current active normal (added on glVertex*())
    colorr*: uint8 ## Current active color (added on glVertex*())
    colorg*: uint8 ## Current active color (added on glVertex*())
    colorb*: uint8 ## Current active color (added on glVertex*())
    colora*: uint8 ## Current active color (added on glVertex*())
    currentMatrixMode*: int32 ## Current matrix mode
    currentMatrix*: ptr Matrix ## Current matrix pointer
    modelview*: Matrix ## Default modelview matrix
    projection*: Matrix ## Default projection matrix
    transform*: Matrix ## Transform matrix to be used with rlTranslate, rlRotate, rlScale
    transformRequired*: bool ## Require transform matrix application to current draw-call vertex (if required)
    stack*: array[MaxMatrixStackSize, Matrix] ## Matrix stack for push/pop
    stackCounter*: int32 ## Matrix stack counter
    defaultTextureId*: uint32 ## Default texture used on shapes/poly drawing (required by shader)
    activeTextureId*: array[DefaultBatchMaxTextureUnits, uint32] ## Active texture ids to be enabled on batch drawing (0 active by default)
    defaultVShaderId*: uint32 ## Default vertex shader id (used by default shader program)
    defaultFShaderId*: uint32 ## Default fragment shader id (used by default shader program)
    defaultShaderId*: uint32 ## Default shader program id, supports vertex color and diffuse texture
    defaultShaderLocs*: ptr int32 ## Default shader locations pointer to be used on rendering
    currentShaderId*: uint32 ## Current shader id to be used on rendering (by default, defaultShaderId)
    currentShaderLocs*: ptr int32 ## Current shader locations pointer to be used on rendering (by default, defaultShaderLocs)
    stereoRender*: bool ## Stereo rendering flag
    projectionStereo*: array[2, Matrix] ## VR stereo rendering eyes projection matrices
    viewOffsetStereo*: array[2, Matrix] ## VR stereo rendering eyes view offset matrices
    currentBlendMode*: int32 ## Blending mode active
    glBlendSrcFactor*: int32 ## Blending source factor
    glBlendDstFactor*: int32 ## Blending destination factor
    glBlendEquation*: int32 ## Blending equation
    glBlendSrcFactorRGB*: int32 ## Blending source RGB factor
    glBlendDestFactorRGB*: int32 ## Blending destination RGB factor
    glBlendSrcFactorAlpha*: int32 ## Blending source alpha factor
    glBlendDestFactorAlpha*: int32 ## Blending destination alpha factor
    glBlendEquationRGB*: int32 ## Blending equation for RGB
    glBlendEquationAlpha*: int32 ## Blending equation for alpha
    glCustomBlendModeModified*: bool ## Custom blending factor and equation modification status
    framebufferWidth*: int32 ## Current framebuffer width
    framebufferHeight*: int32 ## Current framebuffer height

{.push callconv: cdecl, header: "rlgl.h".}
proc matrixMode*(mode: int32) {.importc: "rlMatrixMode".}
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
proc multMatrixf*(matf: var float32) {.importc: "rlMultMatrixf".}
  ## Multiply the current matrix by another matrix
proc frustum*(left: float, right: float, bottom: float, top: float, znear: float, zfar: float) {.importc: "rlFrustum".}
proc ortho*(left: float, right: float, bottom: float, top: float, znear: float, zfar: float) {.importc: "rlOrtho".}
proc viewport*(x: int32, y: int32, width: int32, height: int32) {.importc: "rlViewport".}
  ## Set the viewport area
proc rlBegin*(mode: int32) {.importc: "rlBegin".}
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
proc textureParameters*(id: uint32, param: int32, value: int32) {.importc: "rlTextureParameters".}
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
proc setCullFace*(mode: int32) {.importc: "rlSetCullFace".}
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
proc setBlendMode*(mode: int32) {.importc: "rlSetBlendMode".}
  ## Set blending mode
proc setBlendFactors*(glSrcFactor: int32, glDstFactor: int32, glEquation: int32) {.importc: "rlSetBlendFactors".}
  ## Set blending mode factor and equation (using OpenGL factors)
proc setBlendFactorsSeparate*(glSrcRGB: int32, glDstRGB: int32, glSrcAlpha: int32, glDstAlpha: int32, glEqRGB: int32, glEqAlpha: int32) {.importc: "rlSetBlendFactorsSeparate".}
  ## Set blending mode factors and equations separately (using OpenGL factors)
proc rlglInit*(width: int32, height: int32) {.importc: "rlglInit".}
  ## Initialize rlgl (buffers, shaders, textures, states)
proc rlglClose*() {.importc: "rlglClose".}
  ## De-inititialize rlgl (buffers, shaders, textures)
proc loadExtensions*(loader: pointer) {.importc: "rlLoadExtensions".}
  ## Load OpenGL extensions (loader function required)
proc getVersion*(): int32 {.importc: "rlGetVersion".}
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
proc getShaderLocsDefault*(): var int32 {.importc: "rlGetShaderLocsDefault".}
  ## Get default shader locations
proc loadRenderBatch*(numBuffers: int32, bufferElements: int32): rlRenderBatch {.importc: "rlLoadRenderBatch".}
  ## Load a render batch system
proc unloadRenderBatch*(batch: rlRenderBatch) {.importc: "rlUnloadRenderBatch".}
  ## Unload render batch system
proc drawRenderBatch*(batch: var rlRenderBatch) {.importc: "rlDrawRenderBatch".}
  ## Draw render batch data (Update->Draw->Reset)
proc setRenderBatchActive*(batch: var rlRenderBatch) {.importc: "rlSetRenderBatchActive".}
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
proc setVertexAttribute*(index: uint32, compSize: int32, `type`: int32, normalized: bool, stride: int32, pointer: pointer) {.importc: "rlSetVertexAttribute".}
proc setVertexAttributeDivisor*(index: uint32, divisor: int32) {.importc: "rlSetVertexAttributeDivisor".}
proc setVertexAttributeDefault*(locIndex: int32, value: pointer, attribType: int32, count: int32) {.importc: "rlSetVertexAttributeDefault".}
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
proc getGlTextureFormats*(format: int32, glInternalFormat: var uint32, glFormat: var uint32, glType: var uint32) {.importc: "rlGetGlTextureFormats".}
  ## Get OpenGL internal formats
proc getPixelFormatName*(format: uint32): cstring {.importc: "rlGetPixelFormatName".}
  ## Get name string for pixel format
proc unloadTexture*(id: uint32) {.importc: "rlUnloadTexture".}
  ## Unload texture from GPU memory
proc genTextureMipmaps*(id: uint32, width: int32, height: int32, format: int32, mipmaps: var int32) {.importc: "rlGenTextureMipmaps".}
  ## Generate mipmap data for selected texture
proc readTexturePixels*(id: uint32, width: int32, height: int32, format: int32): pointer {.importc: "rlReadTexturePixels".}
  ## Read texture pixel data
proc readScreenPixels*(width: int32, height: int32): var uint8 {.importc: "rlReadScreenPixels".}
  ## Read screen pixel data (color buffer)
proc loadFramebuffer*(width: int32, height: int32): uint32 {.importc: "rlLoadFramebuffer".}
  ## Load an empty framebuffer
proc framebufferAttach*(fboId: uint32, texId: uint32, attachType: int32, texType: int32, mipLevel: int32) {.importc: "rlFramebufferAttach".}
  ## Attach texture/renderbuffer to a framebuffer
proc framebufferComplete*(id: uint32): bool {.importc: "rlFramebufferComplete".}
  ## Verify framebuffer is complete
proc unloadFramebuffer*(id: uint32) {.importc: "rlUnloadFramebuffer".}
  ## Delete framebuffer from GPU
proc loadShaderCode*(vsCode: cstring, fsCode: cstring): uint32 {.importc: "rlLoadShaderCode".}
  ## Load shader from code strings
proc compileShader*(shaderCode: cstring, `type`: int32): uint32 {.importc: "rlCompileShader".}
  ## Compile custom shader and return shader id (type: RL_VERTEX_SHADER, RL_FRAGMENT_SHADER, RL_COMPUTE_SHADER)
proc loadShaderProgram*(vShaderId: uint32, fShaderId: uint32): uint32 {.importc: "rlLoadShaderProgram".}
  ## Load custom shader program
proc unloadShaderProgram*(id: uint32) {.importc: "rlUnloadShaderProgram".}
  ## Unload shader program
proc getLocationUniform*(shaderId: uint32, uniformName: cstring): int32 {.importc: "rlGetLocationUniform".}
  ## Get shader location uniform
proc getLocationAttrib*(shaderId: uint32, attribName: cstring): int32 {.importc: "rlGetLocationAttrib".}
  ## Get shader location attribute
proc setUniform*(locIndex: int32, value: pointer, uniformType: int32, count: int32) {.importc: "rlSetUniform".}
  ## Set shader value uniform
proc setUniformMatrix*(locIndex: int32, mat: Matrix) {.importc: "rlSetUniformMatrix".}
  ## Set shader value matrix
proc setUniformSampler*(locIndex: int32, textureId: uint32) {.importc: "rlSetUniformSampler".}
  ## Set shader value sampler
proc setShader*(id: uint32, locs: var int32) {.importc: "rlSetShader".}
  ## Set shader currently active (id and locations)
proc loadComputeShaderProgram*(shaderId: uint32): uint32 {.importc: "rlLoadComputeShaderProgram".}
  ## Load compute shader program
proc computeShaderDispatch*(groupX: uint32, groupY: uint32, groupZ: uint32) {.importc: "rlComputeShaderDispatch".}
  ## Dispatch compute shader (equivalent to *draw* for graphics pilepine)
proc loadShaderBuffer*(size: uint32, data: pointer, usageHint: int32): uint32 {.importc: "rlLoadShaderBuffer".}
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
proc getMatrixProjectionStereo*(eye: int32): Matrix {.importc: "rlGetMatrixProjectionStereo".}
proc getMatrixViewOffsetStereo*(eye: int32): Matrix {.importc: "rlGetMatrixViewOffsetStereo".}
