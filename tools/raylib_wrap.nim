
proc toEmbedded*(data: openArray[byte], width, height: int32, format: PixelFormat): EmbeddedImage {.inline.} =
  Image(data: addr data, width: width, height: height, mipmaps: 1, format: format).EmbeddedImage

proc toEmbedded*(data: openArray[byte], frameCount, sampleRate, sampleSize, channels: uint32): EmbeddedWave {.inline.} =
  Wave(data: addr data, frameCount: frameCount, sampleRate: sampleRate, sampleSize: sampleSize, channels: channels).EmbeddedWave

proc raiseResourceNotFound(fileName: string) {.noinline, noreturn.} =
  raise newException(IOError, "Could not load resource from " & fileName)

proc getMonitorName*(monitor: int32): string {.inline.} =
  ## Get the human-readable, UTF-8 encoded name of the primary monitor
  result = $getMonitorNamePriv(monitor)

proc getClipboardText*(): string {.inline.} =
  ## Get clipboard text content
  result = $getClipboardTextPriv()

proc getDroppedFiles*(): seq[string] =
  ## Get dropped files names
  let dropfiles = loadDroppedFilesPriv()
  result = cstringArrayToSeq(dropfiles.paths, dropfiles.count)
  unloadDroppedFilesPriv(dropfiles) # Clear internal buffers

proc getGamepadName*(gamepad: int32): string {.inline.} =
  ## Get gamepad internal name id
  result = $getGamepadNamePriv(gamepad)

proc exportDataAsCode*(data: openArray[uint8], fileName: string): bool =
  ## Export data to code (.h), returns true on success
  result = exportDataAsCodePriv(cast[ptr UncheckedArray[uint8]](data), data.len.uint32, fileName.cstring)

proc loadShader*(vsFileName, fsFileName: string): Shader =
  ## Load shader from files and bind default locations
  result = loadShaderPriv(if vsFileName.len == 0: nil else: vsFileName.cstring,
      if fsFileName.len == 0: nil else: fsFileName.cstring)

proc loadShaderFromMemory*(vsCode, fsCode: string): Shader =
  ## Load shader from code strings and bind default locations
  result = loadShaderFromMemoryPriv(if vsCode.len == 0: nil else: vsCode.cstring,
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
  setShaderValuePriv(shader, locIndex, addr value, kind(T))

proc setShaderValueV*[T: ShaderV](shader: Shader, locIndex: ShaderLocation, value: openArray[T]) =
  ## Set shader uniform value vector
  setShaderValueVPriv(shader, locIndex, cast[pointer](value), kind(T), value.len.int32)

proc loadModelAnimations*(fileName: string): RArray[ModelAnimation] =
  ## Load model animations from file
  var len = 0'u32
  let data = loadModelAnimationsPriv(fileName.cstring, addr len)
  if len <= 0:
    raiseResourceNotFound(fileName)
  result = RArray[ModelAnimation](len: len.int, data: data)

proc loadWaveSamples*(wave: Wave): RArray[float32] =
  ## Load samples data from wave as a floats array
  let data = loadWaveSamplesPriv(wave)
  let len = int(wave.frameCount * wave.channels)
  result = RArray[float32](len: len, data: data)

proc loadImageColors*(image: Image): RArray[Color] =
  ## Load color data from image as a Color array (RGBA - 32bit)
  let data = loadImageColorsPriv(image)
  let len = int(image.width * image.height)
  result = RArray[Color](len: len, data: data)

proc loadImagePalette*(image: Image; maxPaletteSize: int32): RArray[Color] =
  ## Load colors palette from image as a Color array (RGBA - 32bit)
  var len = 0'i32
  let data = loadImagePalettePriv(image, maxPaletteSize, addr len)
  result = RArray[Color](len: len, data: data)

proc loadMaterials*(fileName: string): RArray[Material] =
  ## Load materials from model file
  var len = 0'i32
  let data = loadMaterialsPriv(fileName.cstring, addr len)
  if len <= 0:
    raiseResourceNotFound(fileName)
  result = RArray[Material](len: len, data: data)

proc drawLineStrip*(points: openArray[Vector2]; color: Color) {.inline.} =
  ## Draw lines sequence
  drawLineStripPriv(cast[ptr UncheckedArray[Vector2]](points), points.len.int32, color)

proc drawTriangleFan*(points: openArray[Vector2]; color: Color) =
  ## Draw a triangle fan defined by points (first vertex is the center)
  drawTriangleFanPriv(cast[ptr UncheckedArray[Vector2]](points), points.len.int32, color)

proc drawTriangleStrip*(points: openArray[Vector2]; color: Color) =
  ## Draw a triangle strip defined by points
  drawTriangleStripPriv(cast[ptr UncheckedArray[Vector2]](points), points.len.int32, color)

proc checkCollisionPointPoly*(point: Vector2, points: openArray[Vector2]): bool =
  checkCollisionPointPolyPriv(point, cast[ptr UncheckedArray[Vector2]](points), points.len.int32)

proc loadImage*(fileName: string): Image =
  ## Load image from file into CPU memory (RAM)
  result = loadImagePriv(fileName.cstring)
  if result.data == nil: raiseResourceNotFound(fileName)

proc loadImageRaw*(fileName: string, width, height: int32, format: PixelFormat, headerSize: int32): Image =
  ## Load image sequence from file (frames appended to image.data)
  result = loadImageRawPriv(fileName.cstring, width, height, format, headerSize)
  if result.data == nil: raiseResourceNotFound(fileName)

proc loadImageFromMemory*(fileType: string; fileData: openArray[uint8]): Image =
  ## Load image from memory buffer, fileType refers to extension: i.e. '.png'
  result = loadImageFromMemoryPriv(fileType.cstring, cast[ptr UncheckedArray[uint8]](fileData),
      fileData.len.int32)
  if result.data == nil: raiseResourceNotFound("buffer")

proc loadImageFromTexture*(texture: Texture2D): Image =
  ## Load image from GPU texture data
  result = loadImageFromTexturePriv(texture)
  if result.data == nil: raiseResourceNotFound("texture")

type
  Pixel* = concept
    proc kind(x: typedesc[Self]): PixelFormat

template kind*(x: typedesc[Color]): PixelFormat = UncompressedR8g8b8a8

proc loadTextureFromData*[T: Pixel](pixels: openArray[T], width: int32, height: int32): Texture =
  ## Load texture using pixels
  assert getPixelDataSize(width, height, kind(T)) == pixels.len*sizeof(T),
      "Mismatch between expected and actual data size"
  let image = Image(data: cast[pointer](pixels), width: width, height: height,
      format: kind(T), mipmaps: 1).EmbeddedImage
  result = loadTextureFromImagePriv(image.Image)
  if result.id == 0: raiseResourceNotFound("buffer")

proc loadTexture*(fileName: string): Texture2D =
  ## Load texture from file into GPU memory (VRAM)
  result = loadTexturePriv(fileName.cstring)
  if result.id == 0: raiseResourceNotFound(fileName)

proc loadTextureFromImage*(image: Image): Texture2D =
  ## Load texture from image data
  result = loadTextureFromImagePriv(image)
  if result.id == 0: raiseResourceNotFound("image")

proc loadTextureCubemap*(image: Image, layout: CubemapLayout): TextureCubemap =
  ## Load cubemap from image, multiple image cubemap layouts supported
  result = loadTextureCubemapPriv(image, layout)
  if result.id == 0: raiseResourceNotFound("image")

proc loadRenderTexture*(width: int32, height: int32): RenderTexture2D =
  ## Load texture for rendering (framebuffer)
  result = loadRenderTexturePriv(width, height)
  if result.id == 0: raiseResourceNotFound("")

proc updateTexture*[T: Pixel](texture: Texture2D, pixels: openArray[T]) =
  ## Update GPU texture with new data
  assert getPixelDataSize(texture.width, texture.height, texture.format) == pixels.len*sizeof(T),
      "Mismatch between expected and actual data size"
  updateTexturePriv(texture, cast[pointer](pixels))

proc updateTexture*[T: Pixel](texture: Texture2D, rec: Rectangle, pixels: openArray[T]) =
  ## Update GPU texture rectangle with new data
  assert getPixelDataSize(rec.width, rec.height, texture.format) == pixels.len*sizeof(T),
      "Mismatch between expected and actual data size"
  updateTexturePriv(texture, rec, cast[pointer](pixels))

proc getPixelColor*[T: Pixel](pixel: T): Color =
  ## Get Color from a source pixel pointer of certain format
  getPixelColorPriv(addr pixel, kind(T))

proc setPixelColor*[T: Pixel](pixel: var T, color: Color) =
  ## Set color formatted into destination pixel pointer
  setPixelColorPriv(addr pixel, color, kind(T))

proc loadFontData*(fileData: openArray[uint8]; fontSize: int32; fontChars: openArray[int32];
    `type`: FontType): RArray[GlyphInfo] =
  ## Load font data for further use
  let data = loadFontDataPriv(cast[ptr UncheckedArray[uint8]](fileData), fileData.len.int32,
      fontSize, if fontChars.len == 0: nil else: cast[ptr UncheckedArray[int32]](fontChars),
      fontChars.len.int32, `type`)
  result = RArray[GlyphInfo](len: if fontChars.len == 0: 95 else: fontChars.len, data: data)

proc loadFontData*(fileData: openArray[uint8]; fontSize, glyphCount: int32;
    `type`: FontType): RArray[GlyphInfo] =
  let data = loadFontDataPriv(cast[ptr UncheckedArray[uint8]](fileData), fileData.len.int32,
      fontSize, nil, glyphCount, `type`)
  result = RArray[GlyphInfo](len: if glyphCount > 0: glyphCount else: 95, data: data)

proc loadFont*(fileName: string): Font =
  ## Load font from file into GPU memory (VRAM)
  result = loadFontPriv(fileName.cstring)
  if result.glyphs == nil or result.texture.id == 0: raiseResourceNotFound(fileName)

proc loadFont*(fileName: string; fontSize: int32; fontChars: openArray[int32]): Font =
  ## Load font from file with extended parameters, use an empty array for fontChars to load the default character set
  result = loadFontPriv(fileName.cstring, fontSize,
      if fontChars.len == 0: nil else: cast[ptr UncheckedArray[int32]](fontChars), fontChars.len.int32)
  if result.glyphs == nil or result.texture.id == 0: raiseResourceNotFound(fileName)

proc loadFont*(fileName: string; fontSize, glyphCount: int32): Font =
  result = loadFontPriv(fileName.cstring, fontSize, nil, glyphCount)
  if result.glyphs == nil or result.texture.id == 0: raiseResourceNotFound(fileName)

proc loadFontFromImage*(image: Image, key: Color, firstChar: int32): Font =
  ## Load font from Image (XNA style)
  result = loadFontFromImagePriv(image, key, firstChar)
  if result.glyphs == nil: raiseResourceNotFound("image")

proc loadFontFromMemory*(fileType: string; fileData: openArray[uint8]; fontSize: int32;
    fontChars: openArray[int32]): Font =
  ## Load font from memory buffer, fileType refers to extension: i.e. '.ttf'
  result = loadFontFromMemoryPriv(fileType.cstring,
      cast[ptr UncheckedArray[uint8]](fileData), fileData.len.int32, fontSize,
      if fontChars.len == 0: nil else: cast[ptr UncheckedArray[int32]](fontChars), fontChars.len.int32)
  if result.glyphs == nil or result.texture.id == 0: raiseResourceNotFound("buffer")

proc loadFontFromMemory*(fileType: string; fileData: openArray[uint8]; fontSize: int32;
    glyphCount: int32): Font =
  result = loadFontFromMemoryPriv(fileType.cstring, cast[ptr UncheckedArray[uint8]](fileData),
      fileData.len.int32, fontSize, nil, glyphCount)
  if result.glyphs == nil or result.texture.id == 0: raiseResourceNotFound("buffer")

proc loadFontFromData*(chars: sink RArray[GlyphInfo]; baseSize, padding: int32, packMethod: int32): Font =
  ## Load font using chars info
  result.baseSize = baseSize
  result.glyphCount = chars.len.int32
  result.glyphs = chars.data
  wasMoved(chars)
  let atlas = genImageFontAtlasPriv(result.glyphs, addr result.recs, result.glyphCount, baseSize,
      padding, packMethod)
  result.texture = loadTextureFromImage(atlas)
  if result.glyphs == nil or result.texture.id == 0: raiseResourceNotFound("image")

proc genImageFontAtlas*(chars: openArray[GlyphInfo]; recs: out RArray[Rectangle]; fontSize: int32;
    padding: int32; packMethod: int32): Image =
  ## Generate image font atlas using chars info
  var data: ptr UncheckedArray[Rectangle] = nil
  result = genImageFontAtlasPriv(cast[ptr UncheckedArray[GlyphInfo]](chars), addr data,
      chars.len.int32, fontSize, padding, packMethod)
  recs = RArray[Rectangle](len: chars.len, data: data)

proc drawTriangleStrip3D*(points: openArray[Vector3]; color: Color) =
  ## Draw a triangle strip defined by points
  drawTriangleStrip3DPriv(cast[ptr UncheckedArray[Vector3]](points), points.len.int32, color)

proc updateMeshBuffer*[T](mesh: var Mesh, index: int32, data: openArray[T], offset: int32) =
  ## Update mesh vertex data in GPU for a specific buffer index
  updateMeshBufferPriv(mesh, index, cast[ptr UncheckedArray[T]](data), data.len.int32, offset)

proc drawMeshInstanced*(mesh: Mesh; material: Material; transforms: openArray[Matrix]) =
  ## Draw multiple mesh instances with material and different transforms
  drawMeshInstancedPriv(mesh, material, cast[ptr UncheckedArray[Matrix]](transforms),
      transforms.len.int32)

proc loadWave*(fileName: string): Wave =
  ## Load wave data from file
  result = loadWavePriv(fileName.cstring)
  if result.data == nil: raiseResourceNotFound(fileName)

proc loadWaveFromMemory*(fileType: string; fileData: openArray[uint8]): Wave =
  ## Load wave from memory buffer, fileType refers to extension: i.e. '.wav'
  result = loadWaveFromMemoryPriv(fileType.cstring, cast[ptr UncheckedArray[uint8]](fileData),
      fileData.len.int32)
  if result.data == nil: raiseResourceNotFound("buffer")

proc loadSound*(fileName: string): Sound =
  ## Load sound from file
  result = loadSoundPriv(fileName.cstring)
  if result.stream.buffer == nil: raiseResourceNotFound(fileName)

proc loadSoundFromWave*(wave: Wave): Sound =
  ## Load sound from wave data
  result = loadSoundFromWavePriv(wave)
  if result.stream.buffer == nil: raiseResourceNotFound("wave")

proc updateSound*[T](sound: var Sound, data: openArray[T]) =
  ## Update sound buffer with new data
  updateSoundPriv(sound, cast[ptr UncheckedArray[T]](data), data.len.int32)

proc loadMusicStream*(fileName: string): Music =
  ## Load music stream from file
  result = loadMusicStreamPriv(fileName.cstring)
  if result.stream.buffer == nil: raiseResourceNotFound(fileName)

proc loadMusicStreamFromMemory*(fileType: string; data: openArray[uint8]): Music =
  ## Load music stream from data
  result = loadMusicStreamFromMemoryPriv(fileType.cstring, cast[ptr UncheckedArray[uint8]](data),
      data.len.int32)
  if result.stream.buffer == nil: raiseResourceNotFound("buffer")

proc updateAudioStream*[T](stream: var AudioStream, data: openArray[T]) =
  ## Update audio stream buffers with data
  updateAudioStreamPriv(stream, cast[ptr UncheckedArray[T]](data), data.len.int32)

proc drawTextCodepoints*(font: Font; codepoints: openArray[Rune]; position: Vector2;
    fontSize: float32; spacing: float32; tint: Color) =
  ## Draw multiple character (codepoint)
  drawTextCodepointsPriv(font, cast[ptr UncheckedArray[int32]](codepoints), codepoints.len.int32,
      position, fontSize, spacing, tint)

proc loadModel*(fileName: string): Model =
  ## Load model from files (meshes and materials)
  result = loadModelPriv(fileName.cstring)
  if result.meshes == nil and result.materials == nil and
      result.bones == nil and result.bindPose == nil:
    raiseResourceNotFound(fileName)

proc loadModelFromMesh*(mesh: sink Mesh): Model =
  ## Load model from generated mesh (default material)
  result = loadModelFromMeshPriv(mesh)
  wasMoved(mesh)
  if result.meshes == nil and result.materials == nil:
    raiseResourceNotFound("mesh")

proc loadModelFromSharedMesh*(mesh: Mesh): Model =
  ## NOTE: Model needs to be freed with unloadModelKeepMeshes
  ## Load model from generated mesh (default material)
  result = loadModelFromMeshPriv(mesh)
  if result.meshes == nil and result.materials == nil:
    raiseResourceNotFound("mesh")

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
