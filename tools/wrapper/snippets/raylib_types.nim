
type
  WeakImage* = distinct Image
  WeakWave* = distinct Wave
  WeakFont* = distinct Font

  MaterialMapsPtr* = distinct typeof(Material.maps)
  ShaderLocsPtr* = distinct typeof(Shader.locs)
  SoundAlias* = distinct Sound
  ModelFromMesh* = distinct Model

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
proc `=wasMoved`*(x: var MaterialMap) {.error.}
proc `=dup`*(source: MaterialMap): MaterialMap {.error.}
proc `=copy`*(dest: var MaterialMap; source: MaterialMap) {.error.}
proc `=sink`*(dest: var MaterialMap; source: MaterialMap) {.error.}

proc `=destroy`*(x: ModelFromMesh) {.nodestroy.} =
  let m = addr(Model(x))
  m.meshCount = 0
  unloadModel(m[])
proc `=dup`*(source: ModelFromMesh): ModelFromMesh {.error.}
proc `=copy`*(dest: var ModelFromMesh; source: ModelFromMesh) {.error.}

# proc `=destroy`*(x: ShaderLocsPtr) = discard
# proc `=wasMoved`*(x: var ShaderLocsPtr) {.error.}
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

proc `=destroy`*(x: SoundAlias) =
  unloadSoundAlias(Sound(x))

proc `=destroy`*(x: Music) =
  unloadMusicStream(x)
proc `=dup`*(source: Music): Music {.error.}
proc `=copy`*(dest: var Music; source: Music) {.error.}

proc `=destroy`*(x: AutomationEventList) =
  unloadAutomationEventList(x)
proc `=dup`*(source: AutomationEventList): AutomationEventList {.error.}
proc `=copy`*(dest: var AutomationEventList; source: AutomationEventList) {.error.}

type
  RArray*[T] = object
    len: int
    data: ptr UncheckedArray[T]

proc `=destroy`*[T](x: RArray[T]) =
  if x.data != nil:
    for i in 0..<x.len: `=destroy`(x.data[i])
    memFree(x.data)
proc `=wasMoved`*[T](x: var RArray[T]) =
  x.data = nil
proc `=dup`*[T](source: RArray[T]): RArray[T] {.nodestroy.} =
  result = RArray[T](len: source.len)
  if source.data != nil:
    result.data = cast[typeof(result.data)](memAlloc(result.len.uint32))
    for i in 0..<result.len: result.data[i] = `=dup`(source.data[i])
proc `=copy`*[T](dest: var RArray[T]; source: RArray[T]) =
  if dest.data != source.data:
    `=destroy`(dest)
    `=wasMoved`(dest)
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
  rangeCheck(first <= last)
  checkArrayAccess(last, x.len)
  toOpenArray(x.data, first, last)

template toOpenArray*(x: RArray): untyped =
  toOpenArray(x.data, 0, x.len-1)

proc capacity*(x: AutomationEventList): int {.inline.} = int(x.capacity)
proc len*(x: AutomationEventList): int {.inline.} = int(x.count)

proc `[]`*(x: AutomationEventList, i: int): lent AutomationEvent =
  checkArrayAccess(x.events, i, x.len)
  result = x.events[i]

proc `[]`*(x: var AutomationEventList, i: int): var AutomationEvent =
  checkArrayAccess(x.events, i, x.len)
  result = x.events[i]

proc `[]=`*(x: var AutomationEventList, i: int, val: sink AutomationEvent) =
  checkArrayAccess(x.events, i, x.len)
  x.events[i] = val

static:
  assert sizeof(Color) == 4*sizeof(uint8)
  assert sizeof(Vector2) == 2*sizeof(float32)
  assert sizeof(Vector3) == 3*sizeof(float32)
  assert sizeof(Vector4) == 4*sizeof(float32)

template recs*(x: Font): FontRecs = FontRecs(x)

proc `[]`*(x: FontRecs, i: int): Rectangle =
  checkArrayAccess(Font(x).recs, i, Font(x).glyphCount)
  result = Font(x).recs[i]

proc `[]`*(x: var FontRecs, i: int): var Rectangle =
  checkArrayAccess(Font(x).recs, i, Font(x).glyphCount)
  result = Font(x).recs[i]

proc `[]=`*(x: var FontRecs, i: int, val: Rectangle) =
  checkArrayAccess(Font(x).recs, i, Font(x).glyphCount)
  Font(x).recs[i] = val

template glyphs*(x: Font): FontGlyphs = FontGlyphs(x)

proc `[]`*(x: FontGlyphs, i: int): lent GlyphInfo =
  checkArrayAccess(Font(x).glyphs, i, Font(x).glyphCount)
  result = Font(x).glyphs[i]

proc `[]`*(x: var FontGlyphs, i: int): var GlyphInfo =
  checkArrayAccess(Font(x).glyphs, i, Font(x).glyphCount)
  result = Font(x).glyphs[i]

proc `[]=`*(x: var FontGlyphs, i: int, val: GlyphInfo) =
  checkArrayAccess(Font(x).glyphs, i, Font(x).glyphCount)
  Font(x).glyphs[i] = val

template vertices*(x: Mesh): MeshVertices = MeshVertices(x)

proc `[]`*(x: MeshVertices, i: int): Vector3 =
  checkArrayAccess(Mesh(x).vertices, i, Mesh(x).vertexCount)
  result = cast[ptr UncheckedArray[Vector3]](Mesh(x).vertices)[i]

proc `[]`*(x: var MeshVertices, i: int): var Vector3 =
  checkArrayAccess(Mesh(x).vertices, i, Mesh(x).vertexCount)
  result = cast[ptr UncheckedArray[Vector3]](Mesh(x).vertices)[i]

proc `[]=`*(x: var MeshVertices, i: int, val: Vector3) =
  checkArrayAccess(Mesh(x).vertices, i, Mesh(x).vertexCount)
  cast[ptr UncheckedArray[Vector3]](Mesh(x).vertices)[i] = val

template texcoords*(x: Mesh): MeshTexcoords = MeshTexcoords(x)

proc `[]`*(x: MeshTexcoords, i: int): Vector2 =
  checkArrayAccess(Mesh(x).texcoords, i, Mesh(x).vertexCount)
  result = cast[ptr UncheckedArray[Vector2]](Mesh(x).texcoords)[i]

proc `[]`*(x: var MeshTexcoords, i: int): var Vector2 =
  checkArrayAccess(Mesh(x).texcoords, i, Mesh(x).vertexCount)
  result = cast[ptr UncheckedArray[Vector2]](Mesh(x).texcoords)[i]

proc `[]=`*(x: var MeshTexcoords, i: int, val: Vector2) =
  checkArrayAccess(Mesh(x).texcoords, i, Mesh(x).vertexCount)
  cast[ptr UncheckedArray[Vector2]](Mesh(x).texcoords)[i] = val

template texcoords2*(x: Mesh): MeshTexcoords2 = MeshTexcoords2(x)

proc `[]`*(x: MeshTexcoords2, i: int): Vector2 =
  checkArrayAccess(Mesh(x).texcoords2, i, Mesh(x).vertexCount)
  result = cast[ptr UncheckedArray[Vector2]](Mesh(x).texcoords2)[i]

proc `[]`*(x: var MeshTexcoords2, i: int): var Vector2 =
  checkArrayAccess(Mesh(x).texcoords2, i, Mesh(x).vertexCount)
  result = cast[ptr UncheckedArray[Vector2]](Mesh(x).texcoords2)[i]

proc `[]=`*(x: var MeshTexcoords2, i: int, val: Vector2) =
  checkArrayAccess(Mesh(x).texcoords2, i, Mesh(x).vertexCount)
  cast[ptr UncheckedArray[Vector2]](Mesh(x).texcoords2)[i] = val

template normals*(x: Mesh): MeshNormals = MeshNormals(x)

proc `[]`*(x: MeshNormals, i: int): Vector3 =
  checkArrayAccess(Mesh(x).normals, i, Mesh(x).vertexCount)
  result = cast[ptr UncheckedArray[Vector3]](Mesh(x).normals)[i]

proc `[]`*(x: var MeshNormals, i: int): var Vector3 =
  checkArrayAccess(Mesh(x).normals, i, Mesh(x).vertexCount)
  result = cast[ptr UncheckedArray[Vector3]](Mesh(x).normals)[i]

proc `[]=`*(x: var MeshNormals, i: int, val: Vector3) =
  checkArrayAccess(Mesh(x).normals, i, Mesh(x).vertexCount)
  cast[ptr UncheckedArray[Vector3]](Mesh(x).normals)[i] = val

template tangents*(x: Mesh): MeshTangents = MeshTangents(x)

proc `[]`*(x: MeshTangents, i: int): Vector4 =
  checkArrayAccess(Mesh(x).tangents, i, Mesh(x).vertexCount)
  result = cast[ptr UncheckedArray[Vector4]](Mesh(x).tangents)[i]

proc `[]`*(x: var MeshTangents, i: int): var Vector4 =
  checkArrayAccess(Mesh(x).tangents, i, Mesh(x).vertexCount)
  result = cast[ptr UncheckedArray[Vector4]](Mesh(x).tangents)[i]

proc `[]=`*(x: var MeshTangents, i: int, val: Vector4) =
  checkArrayAccess(Mesh(x).tangents, i, Mesh(x).vertexCount)
  cast[ptr UncheckedArray[Vector4]](Mesh(x).tangents)[i] = val

template colors*(x: Mesh): MeshColors = MeshColors(x)

proc `[]`*(x: MeshColors, i: int): Color =
  checkArrayAccess(Mesh(x).colors, i, Mesh(x).vertexCount)
  result = cast[ptr UncheckedArray[Color]](Mesh(x).colors)[i]

proc `[]`*(x: var MeshColors, i: int): var Color =
  checkArrayAccess(Mesh(x).colors, i, Mesh(x).vertexCount)
  result = cast[ptr UncheckedArray[Color]](Mesh(x).colors)[i]

proc `[]=`*(x: var MeshColors, i: int, val: Color) =
  checkArrayAccess(Mesh(x).colors, i, Mesh(x).vertexCount)
  cast[ptr UncheckedArray[Color]](Mesh(x).colors)[i] = val

template indices*(x: Mesh): MeshIndices = MeshIndices(x)

proc `[]`*(x: MeshIndices, i: int): array[3, uint16] =
  checkArrayAccess(Mesh(x).indices, i, Mesh(x).triangleCount)
  result = cast[ptr UncheckedArray[typeof(result)]](Mesh(x).indices)[i]

proc `[]`*(x: var MeshIndices, i: int): var array[3, uint16] =
  checkArrayAccess(Mesh(x).indices, i, Mesh(x).triangleCount)
  result = cast[ptr UncheckedArray[typeof(result)]](Mesh(x).indices)[i]

proc `[]=`*(x: var MeshIndices, i: int, val: array[3, uint16]) =
  checkArrayAccess(Mesh(x).indices, i, Mesh(x).triangleCount)
  cast[ptr UncheckedArray[typeof(val)]](Mesh(x).indices)[i] = val

template animVertices*(x: Mesh): MeshAnimVertices = MeshAnimVertices(x)

proc `[]`*(x: MeshAnimVertices, i: int): Vector3 =
  checkArrayAccess(Mesh(x).animVertices, i, Mesh(x).vertexCount)
  result = cast[ptr UncheckedArray[Vector3]](Mesh(x).animVertices)[i]

proc `[]`*(x: var MeshAnimVertices, i: int): var Vector3 =
  checkArrayAccess(Mesh(x).animVertices, i, Mesh(x).vertexCount)
  result = cast[ptr UncheckedArray[Vector3]](Mesh(x).animVertices)[i]

proc `[]=`*(x: var MeshAnimVertices, i: int, val: Vector3) =
  checkArrayAccess(Mesh(x).animVertices, i, Mesh(x).vertexCount)
  cast[ptr UncheckedArray[Vector3]](Mesh(x).animVertices)[i] = val

template animNormals*(x: Mesh): MeshAnimNormals = MeshAnimNormals(x)

proc `[]`*(x: MeshAnimNormals, i: int): Vector3 =
  checkArrayAccess(Mesh(x).animNormals, i, Mesh(x).vertexCount)
  result = cast[ptr UncheckedArray[Vector3]](Mesh(x).animNormals)[i]

proc `[]`*(x: var MeshAnimNormals, i: int): var Vector3 =
  checkArrayAccess(Mesh(x).animNormals, i, Mesh(x).vertexCount)
  result = cast[ptr UncheckedArray[Vector3]](Mesh(x).animNormals)[i]

proc `[]=`*(x: var MeshAnimNormals, i: int, val: Vector3) =
  checkArrayAccess(Mesh(x).animNormals, i, Mesh(x).vertexCount)
  cast[ptr UncheckedArray[Vector3]](Mesh(x).animNormals)[i] = val

template boneIds*(x: Mesh): MeshBoneIds = MeshBoneIds(x)

proc `[]`*(x: MeshBoneIds, i: int): array[4, uint8] =
  checkArrayAccess(Mesh(x).boneIds, i, Mesh(x).vertexCount)
  result = cast[ptr UncheckedArray[typeof(result)]](Mesh(x).boneIds)[i]

proc `[]`*(x: var MeshBoneIds, i: int): var array[4, uint8] =
  checkArrayAccess(Mesh(x).boneIds, i, Mesh(x).vertexCount)
  result = cast[ptr UncheckedArray[typeof(result)]](Mesh(x).boneIds)[i]

proc `[]=`*(x: var MeshBoneIds, i: int, val: array[4, uint8]) =
  checkArrayAccess(Mesh(x).boneIds, i, Mesh(x).vertexCount)
  cast[ptr UncheckedArray[typeof(val)]](Mesh(x).boneIds)[i] = val

template boneWeights*(x: Mesh): MeshBoneWeights = MeshBoneWeights(x)

proc `[]`*(x: MeshBoneWeights, i: int): Vector4 =
  checkArrayAccess(Mesh(x).boneWeights, i, Mesh(x).vertexCount)
  result = cast[ptr UncheckedArray[Vector4]](Mesh(x).boneWeights)[i]

proc `[]`*(x: var MeshBoneWeights, i: int): var Vector4 =
  checkArrayAccess(Mesh(x).boneWeights, i, Mesh(x).vertexCount)
  result = cast[ptr UncheckedArray[Vector4]](Mesh(x).boneWeights)[i]

proc `[]=`*(x: var MeshBoneWeights, i: int, val: Vector4) =
  checkArrayAccess(Mesh(x).boneWeights, i, Mesh(x).vertexCount)
  cast[ptr UncheckedArray[Vector4]](Mesh(x).boneWeights)[i] = val

template boneMatrices*(x: Mesh): MeshBoneMatrices = MeshBoneMatrices(x)

proc `[]`*(x: MeshBoneMatrices, i: int): lent Matrix =
  checkArrayAccess(Mesh(x).boneMatrices, i, Mesh(x).boneCount)
  result = Mesh(x).boneMatrices[i]

proc `[]`*(x: var MeshBoneMatrices, i: int): var Matrix =
  checkArrayAccess(Mesh(x).boneMatrices, i, Mesh(x).boneCount)
  result = Mesh(x).boneMatrices[i]

proc `[]=`*(x: var MeshBoneMatrices, i: int, val: Matrix) =
  checkArrayAccess(Mesh(x).boneMatrices, i, Mesh(x).boneCount)
  Mesh(x).boneMatrices[i] = val

template vboId*(x: Mesh): MeshVboId = MeshVboId(x)

proc `[]`*(x: MeshVboId, i: int): uint32 =
  checkArrayAccess(Mesh(x).vboId, i, MaxMeshVertexBuffers)
  result = Mesh(x).vboId[i]

proc `[]`*(x: var MeshVboId, i: int): var uint32 =
  checkArrayAccess(Mesh(x).vboId, i, MaxMeshVertexBuffers)
  result = Mesh(x).vboId[i]

proc `[]=`*(x: var MeshVboId, i: int, val: uint32) =
  checkArrayAccess(Mesh(x).vboId, i, MaxMeshVertexBuffers)
  Mesh(x).vboId[i] = val

proc `locs=`*(x: var Shader; locs: ShaderLocsPtr) {.inline.} =
  x.locs = (typeof(x.locs))(locs)

template locs*(x: Shader): ShaderLocs = ShaderLocs(x)

proc `[]`*(x: ShaderLocs, i: ShaderLocationIndex): ShaderLocation =
  checkArrayAccess(Shader(x).locs, i.int, MaxShaderLocations)
  result = Shader(x).locs[i.int]

proc `[]`*(x: var ShaderLocs, i: ShaderLocationIndex): var ShaderLocation =
  checkArrayAccess(Shader(x).locs, i.int, MaxShaderLocations)
  result = Shader(x).locs[i.int]

proc `[]=`*(x: var ShaderLocs, i: ShaderLocationIndex, val: ShaderLocation) =
  checkArrayAccess(Shader(x).locs, i.int, MaxShaderLocations)
  Shader(x).locs[i.int] = val

proc `maps=`*(x: var Material; maps: MaterialMapsPtr) {.inline.} =
  x.maps = (typeof(x.maps))(maps)

template maps*(x: Material): MaterialMaps = MaterialMaps(x)

proc `[]`*(x: MaterialMaps, i: MaterialMapIndex): lent MaterialMap =
  checkArrayAccess(Material(x).maps, i.int, MaxMaterialMaps)
  result = Material(x).maps[i.int]

proc `[]`*(x: var MaterialMaps, i: MaterialMapIndex): var MaterialMap =
  checkArrayAccess(Material(x).maps, i.int, MaxMaterialMaps)
  result = Material(x).maps[i.int]

proc `[]=`*(x: var MaterialMaps, i: MaterialMapIndex, val: MaterialMap) =
  checkArrayAccess(Material(x).maps, i.int, MaxMaterialMaps)
  Material(x).maps[i.int] = val

proc `texture=`*(x: var MaterialMap, val: Texture) {.nodestroy, inline.} =
  ## Set texture for a material map type (Diffuse, Specular...)
  ## NOTE: Previous texture should be manually unloaded
  x.texture = val

template `texture=`*(x: var MaterialMap, val: Texture{call}) =
  {.error: "Cannot pass a rvalue, as `x` does not take ownership of the texture.".}

proc `shader=`*(x: var Material, val: Shader) {.nodestroy, inline.} =
  x.shader = val

template `shader=`*(x: var Material, val: Shader{call}) =
  {.error: "Cannot pass a rvalue, as `x` does not take ownership of the shader.".}

proc texture*(x: MaterialMap): lent Texture {.inline.} =
  result = x.texture

proc shader*(x: Material): lent Shader {.inline.} =
  result = x.shader

proc texture*(x: var MaterialMap): var Texture {.inline.} =
  result = x.texture

proc shader*(x: var Material): var Shader {.inline.} =
  result = x.shader

template meshes*(x: Model): ModelMeshes = ModelMeshes(x)

proc `[]`*(x: ModelMeshes, i: int): lent Mesh =
  checkArrayAccess(Model(x).meshes, i, Model(x).meshCount)
  result = Model(x).meshes[i]

proc `[]`*(x: var ModelMeshes, i: int): var Mesh =
  checkArrayAccess(Model(x).meshes, i, Model(x).meshCount)
  result = Model(x).meshes[i]

proc `[]=`*(x: var ModelMeshes, i: int, val: Mesh) =
  checkArrayAccess(Model(x).meshes, i, Model(x).meshCount)
  Model(x).meshes[i] = val

template materials*(x: Model): ModelMaterials = ModelMaterials(x)

proc `[]`*(x: ModelMaterials, i: int): lent Material =
  checkArrayAccess(Model(x).materials, i, Model(x).materialCount)
  result = Model(x).materials[i]

proc `[]`*(x: var ModelMaterials, i: int): var Material =
  checkArrayAccess(Model(x).materials, i, Model(x).materialCount)
  result = Model(x).materials[i]

proc `[]=`*(x: var ModelMaterials, i: int, val: Material) =
  checkArrayAccess(Model(x).materials, i, Model(x).materialCount)
  Model(x).materials[i] = val

template meshMaterial*(x: Model): ModelMeshMaterial = ModelMeshMaterial(x)

proc `[]`*(x: ModelMeshMaterial, i: int): int32 =
  checkArrayAccess(Model(x).meshMaterial, i, Model(x).meshCount)
  result = Model(x).meshMaterial[i]

proc `[]`*(x: var ModelMeshMaterial, i: int): var int32 =
  checkArrayAccess(Model(x).meshMaterial, i, Model(x).meshCount)
  result = Model(x).meshMaterial[i]

proc `[]=`*(x: var ModelMeshMaterial, i: int, val: int32) =
  ## Set the material for a mesh
  checkArrayAccess(Model(x).meshMaterial, i, Model(x).meshCount)
  Model(x).meshMaterial[i] = val

template bones*(x: Model): ModelBones = ModelBones(x)

proc `[]`*(x: ModelBones, i: int): lent BoneInfo =
  checkArrayAccess(Model(x).bones, i, Model(x).boneCount)
  result = Model(x).bones[i]

proc `[]`*(x: var ModelBones, i: int): var BoneInfo =
  checkArrayAccess(Model(x).bones, i, Model(x).boneCount)
  result = Model(x).bones[i]

proc `[]=`*(x: var ModelBones, i: int, val: BoneInfo) =
  checkArrayAccess(Model(x).bones, i, Model(x).boneCount)
  Model(x).bones[i] = val

template bindPose*(x: Model): ModelBindPose = ModelBindPose(x)

proc `[]`*(x: ModelBindPose, i: int): lent Transform =
  checkArrayAccess(Model(x).bindPose, i, Model(x).boneCount)
  result = Model(x).bindPose[i]

proc `[]`*(x: var ModelBindPose, i: int): var Transform =
  checkArrayAccess(Model(x).bindPose, i, Model(x).boneCount)
  result = Model(x).bindPose[i]

proc `[]=`*(x: var ModelBindPose, i: int, val: Transform) =
  checkArrayAccess(Model(x).bindPose, i, Model(x).boneCount)
  Model(x).bindPose[i] = val

template bones*(x: ModelAnimation): ModelAnimationBones = ModelAnimationBones(x)

proc `[]`*(x: ModelAnimationBones, i: int): lent BoneInfo =
  checkArrayAccess(ModelAnimation(x).bones, i, ModelAnimation(x).boneCount)
  result = ModelAnimation(x).bones[i]

proc `[]`*(x: var ModelAnimationBones, i: int): var BoneInfo =
  checkArrayAccess(ModelAnimation(x).bones, i, ModelAnimation(x).boneCount)
  result = ModelAnimation(x).bones[i]

proc `[]=`*(x: var ModelAnimationBones, i: int, val: BoneInfo) =
  checkArrayAccess(ModelAnimation(x).bones, i, ModelAnimation(x).boneCount)
  ModelAnimation(x).bones[i] = val

template framePoses*(x: ModelAnimation): ModelAnimationFramePoses = ModelAnimationFramePoses(x)

proc `[]`*(x: ModelAnimationFramePoses; i, j: int): lent Transform =
  checkArrayAccess(ModelAnimation(x).framePoses, i, ModelAnimation(x).frameCount)
  checkArrayAccess(ModelAnimation(x).framePoses[i], j, ModelAnimation(x).boneCount)
  result = ModelAnimation(x).framePoses[i][j]

proc `[]`*(x: var ModelAnimationFramePoses; i, j: int): var Transform =
  checkArrayAccess(ModelAnimation(x).framePoses, i, ModelAnimation(x).frameCount)
  checkArrayAccess(ModelAnimation(x).framePoses[i], j, ModelAnimation(x).boneCount)
  result = ModelAnimation(x).framePoses[i][j]

proc `[]=`*(x: var ModelAnimationFramePoses; i, j: int, val: Transform) =
  checkArrayAccess(ModelAnimation(x).framePoses, i, ModelAnimation(x).frameCount)
  checkArrayAccess(ModelAnimation(x).framePoses[i], j, ModelAnimation(x).boneCount)
  ModelAnimation(x).framePoses[i][j] = val
