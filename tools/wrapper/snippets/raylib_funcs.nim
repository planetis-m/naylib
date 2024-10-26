
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
