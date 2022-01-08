
proc `=destroy`*(x: var Image) =
  if x.data != nil: unloadImage(x)
proc `=copy`*(dest: var Image; source: Image) =
  if dest.data != source.data:
    `=destroy`(dest)
    wasMoved(dest)
    dest = imageCopy(source)

proc `=destroy`*(x: var Texture) =
  if x.id > 0: unloadTexture(x)
proc `=copy`*(dest: var Texture; source: Texture) {.error.}

proc `=destroy`*(x: var RenderTexture) =
  if x.id > 0: unloadRenderTexture(x)
proc `=copy`*(dest: var RenderTexture; source: RenderTexture) {.error.}

proc `=destroy`*(x: var Font) =
  if x.texture.id > 0: unloadFont(x)
proc `=copy`*(dest: var Font; source: Font) {.error.}

proc `=destroy`*(x: var Mesh) =
  if x.vboId != nil: unloadMesh(x)
proc `=copy`*(dest: var Mesh; source: Mesh) {.error.}

proc `=destroy`*(x: var Shader) =
  if x.id > 0: unloadShader(x)
proc `=copy`*(dest: var Shader; source: Shader) {.error.}

proc `=destroy`*(x: var Material) =
  if x.maps != nil: unloadMaterial(x)
proc `=copy`*(dest: var Material; source: Material) {.error.}

proc `=destroy`*(x: var Model) =
  if x.meshes != nil: unloadModel(x)
proc `=copy`*(dest: var Model; source: Model) {.error.}

proc `=destroy`*(x: var ModelAnimation) =
  if x.framePoses != nil: unloadModelAnimation(x)
proc `=copy`*(dest: var ModelAnimation; source: ModelAnimation) {.error.}

proc `=destroy`*(x: var Wave) =
  if x.data != nil: unloadWave(x)
proc `=copy`*(dest: var Wave; source: Wave) =
  if dest.data != source.data:
    `=destroy`(dest)
    wasMoved(dest)
    dest = waveCopy(source)

proc `=destroy`*(x: var AudioStream) =
  if x.buffer != nil: unloadAudioStream(x)
proc `=copy`*(dest: var AudioStream; source: AudioStream) {.error.}

proc `=destroy`*(x: var Sound) =
  if x.stream.buffer != nil: unloadSound(x)
proc `=copy`*(dest: var Sound; source: Sound) {.error.}

proc `=destroy`*(x: var Music) =
  if x.stream.buffer != nil: unloadMusicStream(x)
proc `=copy`*(dest: var Music; source: Music) {.error.}
