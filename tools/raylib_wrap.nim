
type
  RaylibError* = object of CatchableError

proc raiseRaylibError(msg: string) {.noinline, noreturn.} =
  raise newException(RaylibError, msg)

type
  TraceLogCallback* = proc (logLevel: TraceLogLevel;
    text: string) {.nimcall.} ## Logging: Redirect trace log messages

var
  traceLogCallback: TraceLogCallback # TraceLog callback function pointer

proc wrapperTraceLogCallback(logLevel: int32; text: cstring; args: va_list) {.cdecl.} =
  var buf = newString(128)
  vsprintf(buf.cstring, text, args)
  traceLogCallback(logLevel.TraceLogLevel, buf)

proc setTraceLogCallback*(callback: TraceLogCallback) =
  ## Set custom trace log
  traceLogCallback = callback
  setTraceLogCallbackPriv(wrapperTraceLogCallback)

proc toWeakImage*(data: openArray[byte], width, height: int32, format: PixelFormat): WeakImage {.inline.} =
  Image(data: addr data, width: width, height: height, mipmaps: 1, format: format).WeakImage

proc toWeakWave*(data: openArray[byte], frameCount, sampleRate, sampleSize, channels: uint32): WeakWave {.inline.} =
  Wave(data: addr data, frameCount: frameCount, sampleRate: sampleRate, sampleSize: sampleSize, channels: channels).WeakWave

proc initWindow*(width: int32, height: int32, title: string) =
  ## Initialize window and OpenGL context
  initWindowPriv(width, height, title.cstring)
  if not isWindowReady(): raiseRaylibError("Failed to create Window")

proc setWindowIcons*(images: openArray[Image]) =
  ## Set icon for window (multiple images, RGBA 32bit, only PLATFORM_DESKTOP)
  setWindowIconsPriv(cast[ptr UncheckedArray[Image]](images), images.len.int32)

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
  var (_, name, _) = splitFile(fileName)
  txtData.addf("const $1Data: array[$2, byte] = [ ", name, data.len)
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
  var len = 0'i32
  let data = loadModelAnimationsPriv(fileName.cstring, addr len)
  if len <= 0: raiseRaylibError("Failed to load ModelAnimations from " & fileName)
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
  if len <= 0: raiseRaylibError("Failed to load Materials from " & fileName)
  result = RArray[Material](len: len, data: data)

proc drawLineStrip*(points: openArray[Vector2]; color: Color) {.inline.} =
  ## Draw lines sequence
  drawLineStripPriv(cast[ptr UncheckedArray[Vector2]](points), points.len.int32, color)

proc drawSplineLinear*(points: openArray[Vector2], thick: float32, color: Color) =
  ## Draw spline: Linear, minimum 2 points
  drawSplineLinearPriv(cast[ptr UncheckedArray[Vector2]](points), points.len.int32, thick, color)

proc drawSplineBasis*(points: openArray[Vector2], thick: float32, color: Color) =
  ## Draw spline: B-Spline, minimum 4 points
  drawSplineBasisPriv(cast[ptr UncheckedArray[Vector2]](points), points.len.int32, thick, color)

proc drawSplineCatmullRom*(points: openArray[Vector2], thick: float32, color: Color) =
  ## Draw spline: Catmull-Rom, minimum 4 points
  drawSplineCatmullRomPriv(cast[ptr UncheckedArray[Vector2]](points), points.len.int32, thick, color)

proc drawSplineBezierQuadratic*(points: openArray[Vector2], thick: float32, color: Color) =
  ## Draw spline: Quadratic Bezier, minimum 3 points (1 control point): [p1, c2, p3, c4...]
  drawSplineBezierQuadraticPriv(cast[ptr UncheckedArray[Vector2]](points), points.len.int32, thick, color)

proc drawSplineBezierCubic*(points: openArray[Vector2], thick: float32, color: Color) =
  ## Draw spline: Cubic Bezier, minimum 4 points (2 control points): [p1, c2, c3, p4, c5, c6...]
  drawSplineBezierCubicPriv(cast[ptr UncheckedArray[Vector2]](points), points.len.int32, thick, color)

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
  if not isImageReady(result): raiseRaylibError("Failed to load Image from " & fileName)

proc loadImageRaw*(fileName: string, width, height: int32, format: PixelFormat, headerSize: int32): Image =
  ## Load image sequence from file (frames appended to image.data)
  result = loadImageRawPriv(fileName.cstring, width, height, format, headerSize)
  if not isImageReady(result): raiseRaylibError("Failed to load Image from " & fileName)

proc loadImageSvg*(fileNameOrString: string, width, height: int32): Image =
  ## Load image from SVG file data or string with specified size
  result = loadImageSvgPriv(fileNameOrString.cstring, width, height)
  if not isImageReady(result): raiseRaylibError("Failed to load Image from SVG")

proc loadImageAnimFromMemory*(fileType: string, fileData: openArray[uint8], frames: openArray[int32]): Image =
  ## Load image sequence from memory buffer
  result = loadImageAnimFromMemoryPriv(fileType.cstring, cast[ptr UncheckedArray[uint8]](fileData),
      fileData.len.int32, cast[ptr UncheckedArray[int32]](frames))
  if not isImageReady(result): raiseRaylibError("Failed to load Image sequence from buffer")

proc loadImageFromMemory*(fileType: string; fileData: openArray[uint8]): Image =
  ## Load image from memory buffer, fileType refers to extension: i.e. '.png'
  result = loadImageFromMemoryPriv(fileType.cstring, cast[ptr UncheckedArray[uint8]](fileData),
      fileData.len.int32)
  if not isImageReady(result): raiseRaylibError("Failed to load Image from buffer")

proc loadImageFromTexture*(texture: Texture2D): Image =
  ## Load image from GPU texture data
  result = loadImageFromTexturePriv(texture)
  if not isImageReady(result): raiseRaylibError("Failed to load Image from Texture")

proc exportImageToMemory*(image: Image, fileType: string): RArray[uint8] =
  ## Export image to memory buffer
  var len = 0'i32
  let data = exportImageToMemoryPriv(image, fileType.cstring, addr len)
  result = RArray[uint8](len: len, data: cast[ptr UncheckedArray[uint8]](data))

proc imageKernelConvolution*(image: var Image, kernel: openArray[float32]) =
  ## Apply Custom Square image convolution kernel
  imageKernelConvolutionPriv(image, cast[ptr UncheckedArray[float32]](kernel), kernel.len.int32)

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
  result = loadTextureFromImagePriv(image.Image)
  if not isTextureReady(result): raiseRaylibError("Failed to load Texture from buffer")

proc loadTexture*(fileName: string): Texture2D =
  ## Load texture from file into GPU memory (VRAM)
  result = loadTexturePriv(fileName.cstring)
  if not isTextureReady(result): raiseRaylibError("Failed to load Texture from " & fileName)

proc loadTextureFromImage*(image: Image): Texture2D =
  ## Load texture from image data
  result = loadTextureFromImagePriv(image)
  if not isTextureReady(result): raiseRaylibError("Failed to load Texture from Image")

proc loadTextureCubemap*(image: Image, layout: CubemapLayout): TextureCubemap =
  ## Load cubemap from image, multiple image cubemap layouts supported
  result = loadTextureCubemapPriv(image, layout)
  if not isTextureReady(result): raiseRaylibError("Failed to load Texture from Cubemap")

proc loadRenderTexture*(width: int32, height: int32): RenderTexture2D =
  ## Load texture for rendering (framebuffer)
  result = loadRenderTexturePriv(width, height)
  if not isRenderTextureReady(result): raiseRaylibError("Failed to load RenderTexture")

proc updateTexture*[T: Pixel](texture: Texture2D, pixels: openArray[T]) =
  ## Update GPU texture with new data
  assert texture.format == kind(T), "Incompatible texture format"
  assert getPixelDataSize(texture.width, texture.height, texture.format) == pixels.len*sizeof(T),
      "Mismatch between expected and actual data size"
  updateTexturePriv(texture, cast[pointer](pixels))

proc updateTexture*[T: Pixel](texture: Texture2D, rec: Rectangle, pixels: openArray[T]) =
  ## Update GPU texture rectangle with new data
  assert texture.format == kind(T), "Incompatible texture format"
  assert getPixelDataSize(rec.width.int32, rec.height.int32, texture.format) == pixels.len*sizeof(T),
      "Mismatch between expected and actual data size"
  updateTexturePriv(texture, rec, cast[pointer](pixels))

proc getPixelColor*[T: Pixel](pixel: T): Color =
  ## Get Color from a source pixel pointer of certain format
  assert getPixelDataSize(1, 1, kind(T)) == sizeof(T), "Pixel size does not match expected format"
  getPixelColorPriv(addr pixel, kind(T))

proc setPixelColor*[T: Pixel](pixel: var T, color: Color) =
  ## Set color formatted into destination pixel pointer
  assert getPixelDataSize(1, 1, kind(T)) == sizeof(T), "Pixel size does not match expected format"
  setPixelColorPriv(addr pixel, color, kind(T))

proc loadFontData*(fileData: openArray[uint8]; fontSize: int32; codepoints: openArray[int32];
    `type`: FontType): RArray[GlyphInfo] =
  ## Load font data for further use
  let data = loadFontDataPriv(cast[ptr UncheckedArray[uint8]](fileData), fileData.len.int32,
      fontSize, if codepoints.len == 0: nil else: cast[ptr UncheckedArray[int32]](codepoints),
      codepoints.len.int32, `type`)
  result = RArray[GlyphInfo](len: if codepoints.len == 0: 95 else: codepoints.len, data: data)

proc loadFontData*(fileData: openArray[uint8]; fontSize, glyphCount: int32;
    `type`: FontType): RArray[GlyphInfo] =
  let data = loadFontDataPriv(cast[ptr UncheckedArray[uint8]](fileData), fileData.len.int32,
      fontSize, nil, glyphCount, `type`)
  result = RArray[GlyphInfo](len: if glyphCount > 0: glyphCount else: 95, data: data)

proc loadFont*(fileName: string): Font =
  ## Load font from file into GPU memory (VRAM)
  result = loadFontPriv(fileName.cstring)
  if not isFontReady(result): raiseRaylibError("Failed to load Font from " & fileName)

proc loadFont*(fileName: string; fontSize: int32; codepoints: openArray[int32]): Font =
  ## Load font from file with extended parameters, use an empty array for codepoints to load the default character set
  result = loadFontPriv(fileName.cstring, fontSize,
      if codepoints.len == 0: nil else: cast[ptr UncheckedArray[int32]](codepoints), codepoints.len.int32)
  if not isFontReady(result): raiseRaylibError("Failed to load Font from " & fileName)

proc loadFont*(fileName: string; fontSize, glyphCount: int32): Font =
  result = loadFontPriv(fileName.cstring, fontSize, nil, glyphCount)
  if not isFontReady(result): raiseRaylibError("Failed to load Font from " & fileName)

proc loadFontFromImage*(image: Image, key: Color, firstChar: int32): Font =
  ## Load font from Image (XNA style)
  result = loadFontFromImagePriv(image, key, firstChar)
  if not isFontReady(result): raiseRaylibError("Failed to load Font from Image")

proc loadFontFromMemory*(fileType: string; fileData: openArray[uint8]; fontSize: int32;
    codepoints: openArray[int32]): Font =
  ## Load font from memory buffer, fileType refers to extension: i.e. '.ttf'
  result = loadFontFromMemoryPriv(fileType.cstring,
      cast[ptr UncheckedArray[uint8]](fileData), fileData.len.int32, fontSize,
      if codepoints.len == 0: nil else: cast[ptr UncheckedArray[int32]](codepoints), codepoints.len.int32)
  if not isFontReady(result): raiseRaylibError("Failed to load Font from buffer")

proc loadFontFromMemory*(fileType: string; fileData: openArray[uint8]; fontSize: int32;
    glyphCount: int32): Font =
  result = loadFontFromMemoryPriv(fileType.cstring, cast[ptr UncheckedArray[uint8]](fileData),
      fileData.len.int32, fontSize, nil, glyphCount)
  if not isFontReady(result): raiseRaylibError("Failed to load Font from buffer")

proc loadFontFromData*(chars: sink RArray[GlyphInfo]; baseSize, padding: int32, packMethod: int32): Font =
  ## Load font using chars info
  result.baseSize = baseSize
  result.glyphCount = chars.len.int32
  result.glyphs = chars.data
  wasMoved(chars)
  let atlas = genImageFontAtlasPriv(result.glyphs, addr result.recs, result.glyphCount, baseSize,
      padding, packMethod)
  result.texture = loadTextureFromImage(atlas)
  if not isFontReady(result): raiseRaylibError("Failed to load Font from Image")

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
  if not isWaveReady(result): raiseRaylibError("Failed to load Wave from " & fileName)

proc loadWaveFromMemory*(fileType: string; fileData: openArray[uint8]): Wave =
  ## Load wave from memory buffer, fileType refers to extension: i.e. '.wav'
  result = loadWaveFromMemoryPriv(fileType.cstring, cast[ptr UncheckedArray[uint8]](fileData),
      fileData.len.int32)
  if not isWaveReady(result): raiseRaylibError("Failed to load Wave from buffer")

proc loadSound*(fileName: string): Sound =
  ## Load sound from file
  result = loadSoundPriv(fileName.cstring)
  if not isSoundReady(result): raiseRaylibError("Failed to load Sound from " & fileName)

proc loadSoundAlias*(source: Sound): SoundAlias =
  ## Create a new sound that shares the same sample data as the source sound, does not own the sound data
  result = SoundAlias(loadSoundAliasPriv(source))
  if not isSoundReady(Sound(result)): raiseRaylibError("Failed to load SoundAlias from source")

proc loadSoundFromWave*(wave: Wave): Sound =
  ## Load sound from wave data
  result = loadSoundFromWavePriv(wave)
  if not isSoundReady(result): raiseRaylibError("Failed to load Sound from Wave")

proc updateSound*[T](sound: var Sound, data: openArray[T]) =
  ## Update sound buffer with new data
  updateSoundPriv(sound, cast[ptr UncheckedArray[T]](data), data.len.int32)

proc loadMusicStream*(fileName: string): Music =
  ## Load music stream from file
  result = loadMusicStreamPriv(fileName.cstring)
  if not isMusicReady(result): raiseRaylibError("Failed to load Music from " & fileName)

proc loadMusicStreamFromMemory*(fileType: string; data: openArray[uint8]): Music =
  ## Load music stream from data
  result = loadMusicStreamFromMemoryPriv(fileType.cstring, cast[ptr UncheckedArray[uint8]](data),
      data.len.int32)
  if not isMusicReady(result): raiseRaylibError("Failed to load Music from buffer")

proc loadAudioStream*(sampleRate: uint32, sampleSize: uint32, channels: uint32): AudioStream =
  ## Load audio stream (to stream raw audio pcm data)
  result = loadAudioStreamPriv(sampleRate, sampleSize, channels)
  if not isAudioStreamReady(result): raiseRaylibError("Failed to load AudioStream")

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
  if not isModelReady(result): raiseRaylibError("Failed to load Model from " & fileName)

proc loadModelFromMesh*(mesh: sink Mesh): Model =
  ## Load model from generated mesh (default material)
  result = loadModelFromMeshPriv(mesh)
  wasMoved(mesh)
  if not isModelReady(result): raiseRaylibError("Failed to load Model from Mesh")

proc fade*(color: Color, alpha: float32): Color =
  ## Get color with alpha applied, alpha goes from 0.0 to 1.0
  let alpha = clamp(alpha, 0, 1)
  Color(r: color.r, g: color.g, b: color.b, a: uint8(255*alpha))

proc colorToInt*(color: Color): int32 =
  ## Get hexadecimal value for a Color
  (color.r.int32 shl 24) or (color.g.int32 shl 16) or (color.b.int32 shl 8) or color.a.int32

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
