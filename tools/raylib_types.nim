
type
  EmbeddedImage* = distinct Image
  EmbeddedWave* = distinct Wave
  EmbeddedFont* = distinct Font

  ShaderLocsPtr* = distinct ptr UncheckedArray[ShaderLocation]

proc `=destroy`*(x: var EmbeddedImage) = discard
proc `=copy`*(dest: var EmbeddedImage; source: EmbeddedImage) =
  copyMem(addr dest, addr source, sizeof(Image))

proc `=destroy`*(x: var EmbeddedWave) = discard
proc `=copy`*(dest: var EmbeddedWave; source: EmbeddedWave) =
  copyMem(addr dest, addr source, sizeof(Wave))

proc `=destroy`*(x: var EmbeddedFont) = discard
proc `=copy`*(dest: var EmbeddedFont; source: EmbeddedFont) =
  copyMem(addr dest, addr source, sizeof(Font))

proc `=destroy`*(x: var MaterialMap) = discard
proc `=copy`*(dest: var MaterialMap; source: MaterialMap) {.error.}
proc `=sink`*(dest: var MaterialMap; source: MaterialMap) {.error.}

# proc `=destroy`*(x: var ShaderLocsPtr) = discard
# proc `=copy`*(dest: var ShaderLocsPtr; source: ShaderLocsPtr) {.error.}
# proc `=sink`*(dest: var ShaderLocsPtr; source: ShaderLocsPtr) {.error.}

proc `=destroy`*(x: var Image) =
  unloadImage(x)
proc `=copy`*(dest: var Image; source: Image) =
  if dest.data != source.data:
    `=destroy`(dest)
    wasMoved(dest)
    dest = imageCopy(source)

proc `=destroy`*(x: var Texture) =
  unloadTexture(x)
proc `=copy`*(dest: var Texture; source: Texture) {.error.}

proc `=destroy`*(x: var RenderTexture) =
  unloadRenderTexture(x)
proc `=copy`*(dest: var RenderTexture; source: RenderTexture) {.error.}

proc `=destroy`*(x: var Font) =
  unloadFont(x)
proc `=copy`*(dest: var Font; source: Font) {.error.}

proc `=destroy`*(x: var Mesh) =
  unloadMesh(x)
proc `=copy`*(dest: var Mesh; source: Mesh) {.error.}

proc `=destroy`*(x: var Shader) =
  unloadShader(x)
proc `=copy`*(dest: var Shader; source: Shader) {.error.}

proc `=destroy`*(x: var Material) =
  unloadMaterial(x)
proc `=copy`*(dest: var Material; source: Material) {.error.}

proc `=destroy`*(x: var Model) =
  unloadModel(x)
proc `=copy`*(dest: var Model; source: Model) {.error.}

proc `=destroy`*(x: var ModelAnimation) =
  unloadModelAnimation(x)
proc `=copy`*(dest: var ModelAnimation; source: ModelAnimation) {.error.}

proc `=destroy`*(x: var Wave) =
  unloadWave(x)
proc `=copy`*(dest: var Wave; source: Wave) =
  if dest.data != source.data:
    `=destroy`(dest)
    wasMoved(dest)
    dest = waveCopy(source)

proc `=destroy`*(x: var AudioStream) =
  unloadAudioStream(x)
proc `=copy`*(dest: var AudioStream; source: AudioStream) {.error.}

proc `=destroy`*(x: var Sound) =
  unloadSound(x)
proc `=copy`*(dest: var Sound; source: Sound) {.error.}

proc `=destroy`*(x: var Music) =
  unloadMusicStream(x)
proc `=copy`*(dest: var Music; source: Music) {.error.}

type
  CSeq*[T] = object
    len: int
    data: ptr UncheckedArray[T]

proc `=destroy`*[T](x: var CSeq[T]) =
  if x.data != nil:
    for i in 0..<x.len: `=destroy`(x.data[i])
    memFree(x.data)
proc `=copy`*[T](dest: var CSeq[T]; source: CSeq[T]) =
  if dest.data != source.data:
    `=destroy`(dest)
    wasMoved(dest)
    dest.len = source.len
    if dest.len > 0:
      dest.data = cast[typeof(dest.data)](memAlloc(dest.len.uint32))
      for i in 0..<dest.len: dest.data[i] = source.data[i]

proc raiseIndexDefect(i, n: int) {.noinline, noreturn.} =
  raise newException(IndexDefect, "index " & $i & " not in 0 .. " & $n)

template checkArrayAccess(a, x, len) =
  when compileOption("boundChecks"):
    {.line.}:
      if x < 0 or x >= len:
        raiseIndexDefect(x, len-1)

proc `[]`*[T](x: CSeq[T], i: int): lent T =
  checkArrayAccess(x.data, i, x.len)
  result = x.data[i]

proc `[]`*[T](x: var CSeq[T], i: int): var T =
  checkArrayAccess(x.data, i, x.len)
  result = x.data[i]

proc `[]=`*[T](x: var CSeq[T], i: int, val: sink T) =
  checkArrayAccess(x.data, i, x.len)
  x.data[i] = val

proc len*[T](x: CSeq[T]): int {.inline.} = x.len

proc `@`*[T](x: CSeq[T]): seq[T] {.inline.} =
  newSeq(result, x.len)
  for i in 0..x.len-1: result[i] = x[i]

template toOpenArray*(x: CSeq, first, last: int): untyped =
  toOpenArray(x.data, first, last)

template toOpenArray*(x: CSeq): untyped =
  toOpenArray(x.data, 0, x.len-1)
