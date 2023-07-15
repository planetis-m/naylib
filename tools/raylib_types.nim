
type
  WeakImage* = distinct Image
  WeakWave* = distinct Wave
  WeakFont* = distinct Font

  ShaderLocsPtr* = distinct typeof(Shader.locs)

proc `=destroy`*(x: WeakImage) = discard
proc `=dup`*(source: WeakImage): WeakImage {.nodestroy.} = source
proc `=copy`*(dest: var WeakImage; source: WeakImage) {.nodestroy.} =
  dest = source

proc `=destroy`*(x: WeakWave) = discard
proc `=dup`*(source: WeakWave): WeakWave {.nodestroy.} = source
proc `=copy`*(dest: var WeakWave; source: WeakWave) {.nodestroy.} =
  dest = source

proc `=destroy`*(x: WeakFont) = discard
proc `=dup`*(source: WeakFont): WeakFont {.nodestroy.} = source
proc `=copy`*(dest: var WeakFont; source: WeakFont) {.nodestroy.} =
  dest = source

proc `=destroy`*(x: MaterialMap) = discard
proc `=dup`*(source: MaterialMap): MaterialMap {.error.}
proc `=copy`*(dest: var MaterialMap; source: MaterialMap) {.error.}
proc `=sink`*(dest: var MaterialMap; source: MaterialMap) {.error.}

# proc `=destroy`*(x: ShaderLocsPtr) = discard
# proc `=dup`*(source: ShaderLocsPtr): ShaderLocsPtr {.error.}
# proc `=copy`*(dest: var ShaderLocsPtr; source: ShaderLocsPtr) {.error.}
# proc `=sink`*(dest: var ShaderLocsPtr; source: ShaderLocsPtr) {.error.}

proc `=destroy`*(x: Image) =
  unloadImage(x)
proc `=dup`*(source: Image): Image {.nodestroy.} =
  result = imageCopy(source)
proc `=copy`*(dest: var Image; source: Image) =
  if dest.data != source.data:
    dest = imageCopy(source) # generates =sink

proc `=destroy`*(x: Texture) =
  unloadTexture(x)
proc `=dup`*(source: Texture): Texture {.error.}
proc `=copy`*(dest: var Texture; source: Texture) {.error.}

proc `=destroy`*(x: RenderTexture) =
  unloadRenderTexture(x)
proc `=dup`*(source: RenderTexture): RenderTexture {.error.}
proc `=copy`*(dest: var RenderTexture; source: RenderTexture) {.error.}

proc `=destroy`*(x: Font) =
  unloadFont(x)
proc `=dup`*(source: Font): Font {.error.}
proc `=copy`*(dest: var Font; source: Font) {.error.}

proc `=destroy`*(x: Mesh) =
  unloadMesh(x)
proc `=dup`*(source: Mesh): Mesh {.error.}
proc `=copy`*(dest: var Mesh; source: Mesh) {.error.}

proc `=destroy`*(x: Shader) =
  unloadShader(x)
proc `=dup`*(source: Shader): Shader {.error.}
proc `=copy`*(dest: var Shader; source: Shader) {.error.}

proc `=destroy`*(x: Material) =
  unloadMaterial(x)
# proc `=dup`*(source: Material): Material {.error.}
proc `=copy`*(dest: var Material; source: Material) {.error.}

proc `=destroy`*(x: Model) =
  unloadModel(x)
proc `=dup`*(source: Model): Model {.error.}
proc `=copy`*(dest: var Model; source: Model) {.error.}

proc `=destroy`*(x: ModelAnimation) =
  unloadModelAnimation(x)
# proc `=dup`*(source: ModelAnimation): ModelAnimation {.error.}
proc `=copy`*(dest: var ModelAnimation; source: ModelAnimation) {.error.}

proc `=destroy`*(x: Wave) =
  unloadWave(x)
proc `=dup`*(source: Wave): Wave {.nodestroy.} =
  result = waveCopy(source)
proc `=copy`*(dest: var Wave; source: Wave) =
  if dest.data != source.data:
    dest = waveCopy(source)

proc `=destroy`*(x: AudioStream) =
  unloadAudioStream(x)
proc `=dup`*(source: AudioStream): AudioStream {.error.}
proc `=copy`*(dest: var AudioStream; source: AudioStream) {.error.}

proc `=destroy`*(x: Sound) =
  unloadSound(x)
proc `=dup`*(source: Sound): Sound {.error.}
proc `=copy`*(dest: var Sound; source: Sound) {.error.}

proc `=destroy`*(x: Music) =
  unloadMusicStream(x)
proc `=dup`*(source: Music): Music {.error.}
proc `=copy`*(dest: var Music; source: Music) {.error.}

type
  RArray*[T] = object
    len: int
    data: ptr UncheckedArray[T]

proc `=destroy`*[T](x: RArray[T]) =
  if x.data != nil:
    for i in 0..<x.len: `=destroy`(x.data[i])
    memFree(x.data)
proc `=dup`*[T](source: RArray[T]): RArray[T] {.nodestroy.} =
  result.len = source.len
  if source.data != nil:
    result.data = cast[typeof(result.data)](memAlloc(result.len.uint32))
    for i in 0..<result.len: result.data[i] = `=dup`(source.data[i])
proc `=copy`*[T](dest: var RArray[T]; source: RArray[T]) =
  if dest.data != source.data:
    `=destroy`(dest)
    wasMoved(dest)
    dest.len = source.len
    if source.data != nil:
      dest.data = cast[typeof(dest.data)](memAlloc(dest.len.uint32))
      for i in 0..<dest.len: dest.data[i] = source.data[i]

proc raiseIndexDefect(i, n: int) {.noinline, noreturn.} =
  raise newException(IndexDefect, "index " & $i & " not in 0 .. " & $n)

template checkArrayAccess(a, x, len) =
  when compileOption("boundChecks"):
    {.line.}:
      if x < 0 or x >= len:
        raiseIndexDefect(x, len-1)

proc `[]`*[T](x: RArray[T], i: int): lent T =
  checkArrayAccess(x.data, i, x.len)
  result = x.data[i]

proc `[]`*[T](x: var RArray[T], i: int): var T =
  checkArrayAccess(x.data, i, x.len)
  result = x.data[i]

proc `[]=`*[T](x: var RArray[T], i: int, val: sink T) =
  checkArrayAccess(x.data, i, x.len)
  x.data[i] = val

proc len*[T](x: RArray[T]): int {.inline.} = x.len

proc `@`*[T](x: RArray[T]): seq[T] {.inline.} =
  newSeq(result, x.len)
  for i in 0..x.len-1: result[i] = x[i]

template toOpenArray*(x: RArray, first, last: int): untyped =
  toOpenArray(x.data, first, last)

template toOpenArray*(x: RArray): untyped =
  toOpenArray(x.data, 0, x.len-1)
