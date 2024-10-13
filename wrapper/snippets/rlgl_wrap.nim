
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
