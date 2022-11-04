
proc toEmbedded*(data: openarray[byte], width, height: int32, format: PixelFormat): EmbeddedImage {.inline.} =
  Image(data: addr data, width: width, height: height, mipmaps: 1, format: format).EmbeddedImage

proc toEmbedded*(data: openarray[byte], frameCount, sampleRate, sampleSize, channels: uint32): EmbeddedWave {.inline.} =
  Wave(data: addr data, frameCount: frameCount, sampleRate: sampleRate, sampleSize: sampleSize, channels: channels).EmbeddedWave

proc raiseResourceNotFound(filename: string) {.noinline, noreturn.} =
  raise newException(IOError, "Could not load resource from " & filename)

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

proc exportDataAsCode*(data: openarray[uint8], fileName: string): bool =
  ## Export data to code (.h), returns true on success
  result = exportDataAsCodePriv(cast[ptr UncheckedArray[uint8]](data), data.len.uint32, fileName.string)

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
    proc value(x: Self): pointer

template kind*(x: typedesc[float32]): ShaderUniformDataType = ShaderUniformFloat
template value*(x: float32): pointer = x.addr

template kind*(x: typedesc[Vector2]): ShaderUniformDataType = ShaderUniformVec2
template value*(x: Vector2): pointer = x.addr

template kind*(x: typedesc[Vector3]): ShaderUniformDataType = ShaderUniformVec3
template value*(x: Vector3): pointer = x.addr

template kind*(x: typedesc[Vector4]): ShaderUniformDataType = ShaderUniformVec4
template value*(x: Vector4): pointer = x.addr

template kind*(x: typedesc[int32]): ShaderUniformDataType = ShaderUniformInt
template value*(x: int32): pointer = x.addr

template kind*(x: typedesc[array[2, int32]]): ShaderUniformDataType = ShaderUniformIvec2
template value*(x: array[2, int32]): pointer = x.addr

template kind*(x: typedesc[array[3, int32]]): ShaderUniformDataType = ShaderUniformIvec3
template value*(x: array[3, int32]): pointer = x.addr

template kind*(x: typedesc[array[4, int32]]): ShaderUniformDataType = ShaderUniformIvec4
template value*(x: array[4, int32]): pointer = x.addr

template kind*(x: typedesc[array[2, float32]]): ShaderUniformDataType = ShaderUniformVec2
template value*(x: array[2, float32]): pointer = x.addr

template kind*(x: typedesc[array[3, float32]]): ShaderUniformDataType = ShaderUniformVec3
template value*(x: array[3, float32]): pointer = x.addr

template kind*(x: typedesc[array[4, float32]]): ShaderUniformDataType = ShaderUniformVec4
template value*(x: array[4, float32]): pointer = x.addr

proc setShaderValue*[T: ShaderV](shader: Shader, locIndex: ShaderLocation, value: T) =
  ## Set shader uniform value
  setShaderValuePriv(shader, locIndex, value.value, kind(T))

proc setShaderValueV*[T: ShaderV](shader: Shader, locIndex: ShaderLocation, value: openarray[T]) =
  ## Set shader uniform value vector
  setShaderValueVPriv(shader, locIndex, cast[pointer](value), kind(T), value.len.int32)

proc loadModelAnimations*(fileName: string): CSeq[ModelAnimation] =
  ## Load model animations from file
  var len = 0'u32
  let data = loadModelAnimationsPriv(fileName.cstring, len.addr)
  if len <= 0:
    raiseResourceNotFound(filename)
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
  result = CSeq[Color](len: len, data: data)

proc loadMaterials*(fileName: string): CSeq[Material] =
  ## Load materials from model file
  var len = 0'i32
  let data = loadMaterialsPriv(fileName.cstring, len.addr)
  if len <= 0:
    raiseResourceNotFound(filename)
  result = CSeq[Material](len: len, data: data)

proc drawLineStrip*(points: openarray[Vector2]; color: Color) {.inline.} =
  ## Draw lines sequence
  drawLineStripPriv(cast[ptr UncheckedArray[Vector2]](points), points.len.int32, color)

proc drawTriangleFan*(points: openarray[Vector2]; color: Color) =
  ## Draw a triangle fan defined by points (first vertex is the center)
  drawTriangleFanPriv(cast[ptr UncheckedArray[Vector2]](points), points.len.int32, color)

proc drawTriangleStrip*(points: openarray[Vector2]; color: Color) =
  ## Draw a triangle strip defined by points
  drawTriangleStripPriv(cast[ptr UncheckedArray[Vector2]](points), points.len.int32, color)

proc checkCollisionPointPoly*(point: Vector2, points: openarray[Vector2]): bool =
  checkCollisionPointPolyPriv(point, cast[ptr UncheckedArray[Vector2]](points), points.len.int32)

proc loadImageFromMemory*(fileType: string; fileData: openarray[uint8]): Image =
  ## Load image from memory buffer, fileType refers to extension: i.e. '.png'
  result = loadImageFromMemoryPriv(fileType.cstring, cast[ptr UncheckedArray[uint8]](fileData),
      fileData.len.int32)

type
  Pixel* = concept
    proc kind(x: typedesc[Self]): PixelFormat
    proc value(x: Self): pointer

template kind*(x: typedesc[Color]): PixelFormat = PixelformatUncompressedR8g8b8a8
template value*(x: Color): pointer = x.addr

proc updateTexture*[T: Pixel](texture: Texture2D, pixels: openarray[T]) =
  ## Update GPU texture with new data
  updateTexturePriv(texture, cast[pointer](pixels))

proc updateTextureRec*[T: Pixel](texture: Texture2D, rec: Rectangle, pixels: openarray[T]) =
  ## Update GPU texture rectangle with new data
  updateTextureRecPriv(texture, rec, cast[pointer](pixels))

proc drawTexturePoly*(texture: Texture2D; center: Vector2; points: openarray[Vector2];
    texcoords: openarray[Vector2]; tint: Color) =
  ## Draw a textured polygon
  drawTexturePolyPriv(texture, center, cast[ptr UncheckedArray[Vector2]](points),
      cast[ptr UncheckedArray[Vector2]](texcoords), points.len.int32, tint)

proc getPixelColor*[T: Pixel](pixels: T): Color =
  ## Get Color from a source pixel pointer of certain format
  getPixelColorPriv(pixels.value, kind(T))

proc setPixelColor*[T: Pixel](pixels: T, color: Color) =
  ## Set color formatted into destination pixel pointer
  setPixelColorPriv(pixels.value, color, kind(T))

proc loadFontData*(fileData: openarray[uint8]; fontSize: int32; fontChars: openarray[int32];
    `type`: FontType): CSeq[GlyphInfo] =
  ## Load font data for further use
  let data = loadFontDataPriv(cast[ptr UncheckedArray[uint8]](fileData), fileData.len.int32,
      fontSize, if fontChars.len == 0: nil else: cast[ptr UncheckedArray[int32]](fontChars),
      fontChars.len.int32, `type`)
  result = CSeq[GlyphInfo](len: if fontChars.len == 0: 95 else: fontChars.len, data: data)

proc loadFontData*(fileData: openarray[uint8]; fontSize, glyphCount: int32;
    `type`: FontType): CSeq[GlyphInfo] =
  let data = loadFontDataPriv(cast[ptr UncheckedArray[uint8]](fileData), fileData.len.int32,
      fontSize, nil, glyphCount, `type`)
  result = CSeq[GlyphInfo](len: if glyphCount > 0: glyphCount else: 95, data: data)

proc loadFontEx*(fileName: string; fontSize: int32; fontChars: openarray[int32]): Font =
  ## Load font from file with extended parameters, use an empty array for fontChars to load the default character set
  result = loadFontExPriv(fileName.cstring, fontSize,
      if fontChars.len == 0: nil else: cast[ptr UncheckedArray[int32]](fontChars), fontChars.len.int32)

proc loadFontEx*(fileName: string; fontSize, glyphCount: int32): Font =
  result = loadFontExPriv(fileName.cstring, fontSize, nil, glyphCount)

proc loadFontFromMemory*(fileType: string; fileData: openarray[uint8]; fontSize: int32;
    fontChars: openarray[int32]): Font =
  ## Load font from memory buffer, fileType refers to extension: i.e. '.ttf'
  result = loadFontFromMemoryPriv(fileType.cstring,
      cast[ptr UncheckedArray[uint8]](fileData), fileData.len.int32, fontSize,
      if fontChars.len == 0: nil else: cast[ptr UncheckedArray[int32]](fontChars), fontChars.len.int32)

proc loadFontFromMemory*(fileType: string; fileData: openarray[uint8]; fontSize: int32;
    glyphCount: int32): Font =
  result = loadFontFromMemoryPriv(fileType.cstring, cast[ptr UncheckedArray[uint8]](fileData),
      fileData.len.int32, fontSize, nil, glyphCount)

proc loadFontFromData*(chars: sink CSeq[GlyphInfo]; baseSize, padding: int32, packMethod: int32): Font =
  ## Load font using chars info
  result.baseSize = baseSize
  result.glyphCount = chars.len.int32
  result.glyphs = chars.data
  wasMoved(chars)
  let atlas = genImageFontAtlasPriv(result.glyphs, result.recs.addr, result.glyphCount, baseSize,
      padding, packMethod)
  result.texture = loadTextureFromImage(atlas)
  if result.texture.id == 0:
    raise newException(IOError, "Error loading font from image.")

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
