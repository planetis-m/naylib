
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

type
  Pixels* = concept
    proc kind(x: Self): PixelFormat
    proc value(x: Self): pointer

proc kind*(x: seq[Color]): PixelFormat = PixelformatUncompressedR8g8b8a8
proc kind*(x: CSeq[Color]): PixelFormat = PixelformatUncompressedR8g8b8a8
proc value*(x: seq[Color]): pointer = x[0].addr
proc value*(x: CSeq[Color]): pointer = x.data

proc updateTexture*(texture: Texture2D, pixels: Pixels) =
  ## Update GPU texture with new data
  updateTexturePriv(texture, pixels.value)

proc updateTextureRec*(texture: Texture2D, rec: Rectangle, pixels: Pixels) =
  ## Update GPU texture rectangle with new data
  updateTextureRecPriv(texture, rec, pixels.value)

proc drawTexturePoly*(texture: Texture2D; center: Vector2; points: openarray[Vector2];
    texcoords: openarray[Vector2]; tint: Color) =
  ## Draw a textured polygon
  drawTexturePolyPriv(texture, center, cast[ptr UncheckedArray[Vector2]](points),
      cast[ptr UncheckedArray[Vector2]](texcoords), points.len.int32, tint)

proc getPixelColor*(pixels: Pixels): Color =
  ## Get Color from a source pixel pointer of certain format
  getPixelColorPriv(pixels.value, pixels.kind)

proc setPixelColor*(pixels: Pixels, color: Color) =
  ## Set color formatted into destination pixel pointer
  setPixelColorPriv(pixels.value, color, pixels.kind)

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
  result = CSeq[GlyphInfo](len: glyphCount, data: data)

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
