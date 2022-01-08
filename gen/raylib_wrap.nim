
proc raiseRangeDefect {.noinline, noreturn.} =
  raise newException(RangeDefect, "array access out of bounds")

template checkArrayAccess(a, len) =
  when compileOption("boundChecks"):
    {.line.}:
      if a == nil or i.uint32 >= len.uint32:
        raiseRangeDefect()

proc `<`*(a, b: MaterialMapIndex): bool {.borrow.}
proc `<=`*(a, b: MaterialMapIndex): bool {.borrow.}
proc `==`*(a, b: MaterialMapIndex): bool {.borrow.}

proc `<`*(a, b: ShaderLocationIndex): bool {.borrow.}
proc `<=`*(a, b: ShaderLocationIndex): bool {.borrow.}
proc `==`*(a, b: ShaderLocationIndex): bool {.borrow.}

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

proc loadModelAnimations*(fileName: string): seq[ModelAnimation] =
  ## Load model animations from file
  var len = 0'u32
  let data = loadModelAnimationsPriv(fileName.cstring, len.addr)
  if len <= 0:
    raise newException(IOError, "No model animations loaded from " & filename)
  result = newSeq[ModelAnimation](len.int)
  copyMem(result[0].addr, data, len.int * sizeof(ModelAnimation))
  #for i in 0..<len.int:
    #result[i] = data[i]
  memFree(data)

proc loadWaveSamples*(wave: Wave): seq[float32] =
  ## Load samples data from wave as a floats array
  let data = loadWaveSamplesPriv(wave)
  let len = int(wave.frameCount * wave.channels)
  result = newSeq[float32](len)
  copyMem(result[0].addr, data, len * sizeof(float32))
  memFree(data)

proc loadImageColors*(image: Image): seq[Color] =
  ## Load color data from image as a Color array (RGBA - 32bit)
  let data = loadImageColorsPriv(image)
  let len = int(image.width * image.height)
  result = newSeq[Color](len)
  copyMem(result[0].addr, data, len * sizeof(Color))
  memFree(data)

proc loadImagePalette*(image: Image, maxPaletteSize: int32): seq[Color] =
  ## Load colors palette from image as a Color array (RGBA - 32bit)
  var len = 0'i32
  let data = loadImagePalettePriv(image, maxPaletteSize, len.addr)
  result = newSeq[Color](len.int)
  copyMem(result[0].addr, data, len.int * sizeof(Color))
  memFree(data)

proc loadFontData*(fileData: openarray[uint8], fontSize: int32, fontChars: openarray[int32], `type`: FontType): seq[GlyphInfo] =
  ## Load font data for further use
  let data = loadFontDataPriv(cast[ptr UncheckedArray[uint8]](fileData), fileData.len.int32,
      fontSize, cast[ptr UncheckedArray[int32]](fontChars), fontChars.len.int32, `type`)
  result = newSeq[GlyphInfo](fontChars.len)
  copyMem(result[0].addr, data, fontChars.len * sizeof(GlyphInfo))
  memFree(data)

proc loadMaterials*(fileName: string): seq[Material] =
  ## Load materials from model file
  var len = 0'i32
  let data = loadMaterialsPriv(fileName.cstring, len.addr)
  if len <= 0:
    raise newException(IOError, "No materials loaded from " & filename)
  result = newSeq[Material](len.int)
  copyMem(result[0].addr, data, len.int * sizeof(Material))
  #for i in 0..<len.int:
    #result[i] = data[i]
  memFree(data)

proc drawLineStrip*(points: openarray[Vector2], color: Color) {.inline.} =
  ## Draw lines sequence
  drawLineStripPriv(cast[ptr UncheckedArray[Vector2]](points), points.len.int32, color)

proc drawTriangleFan*(points: openarray[Vector2], color: Color) =
  ## Draw a triangle fan defined by points (first vertex is the center)
  drawTriangleFanPriv(cast[ptr UncheckedArray[Vector2]](points), points.len.int32, color)

proc drawTriangleStrip*(points: openarray[Vector2], color: Color) =
  ## Draw a triangle strip defined by points
  drawTriangleStripPriv(cast[ptr UncheckedArray[Vector2]](points), points.len.int32, color)

proc loadImageFromMemory*(fileType: string, fileData: openarray[uint8]): Image =
  ## Load image from memory buffer, fileType refers to extension: i.e. '.png'
  result = loadImageFromMemoryPriv(fileType.cstring, cast[ptr UncheckedArray[uint8]](fileData), fileData.len.int32)

proc drawTexturePoly*(texture: Texture2D, center: Vector2, points: openarray[Vector2], texcoords: openarray[Vector2], tint: Color) =
  ## Draw a textured polygon
  drawTexturePolyPriv(texture, center, cast[ptr UncheckedArray[Vector2]](points), cast[ptr UncheckedArray[Vector2]](texcoords), points.len.int32, tint)

proc loadFontEx*(fileName: string, fontSize: int32, fontChars: openarray[int32]): Font =
  ## Load font from file with extended parameters, use an empty array for fontChars to load the default character set
  result = loadFontExPriv(fileName.cstring, fontSize,
      if fontChars.len == 0: nil else: cast[ptr UncheckedArray[int32]](fontChars), fontChars.len.int32)

proc loadFontFromMemory*(fileType: string, fileData: openarray[uint8], fontSize: int32, fontChars: openarray[int32]): Font =
  ## Load font from memory buffer, fileType refers to extension: i.e. '.ttf'
  result = loadFontFromMemoryPriv(fileType.cstring,
      cast[ptr UncheckedArray[uint8]](fileData), fileData.len.int32, fontSize,
      cast[ptr UncheckedArray[int32]](fontChars), fontChars.len.int32)

proc genImageFontAtlas*(chars: openarray[GlyphInfo], recs: var seq[Rectangle], fontSize: int32, padding: int32, packMethod: int32): Image =
  ## Generate image font atlas using chars info
  var data: ptr UncheckedArray[Rectangle] = nil
  result = genImageFontAtlasPriv(cast[ptr UncheckedArray[GlyphInfo]](chars), data.addr, chars.len.int32, fontSize, padding, packMethod)
  recs = newSeq[Rectangle](chars.len)
  copyMem(recs[0].addr, data, chars.len * sizeof(Rectangle))
  #for i in 0..<len.int:
    #result[i] = data[i]
  memFree(data)

proc drawTriangleStrip3D*(points: openarray[Vector3], color: Color) =
  ## Draw a triangle strip defined by points
  drawTriangleStrip3DPriv(cast[ptr UncheckedArray[Vector3]](points), points.len.int32, color)

proc drawMeshInstanced*(mesh: Mesh, material: Material, transforms: openarray[Matrix]) =
  ## Draw multiple mesh instances with material and different transforms
  drawMeshInstancedPriv(mesh, material, cast[ptr UncheckedArray[Matrix]](transforms), transforms.len.int32)

proc loadWaveFromMemory*(fileType: string, fileData: openarray[uint8]): Wave =
  ## Load wave from memory buffer, fileType refers to extension: i.e. '.wav'
  loadWaveFromMemoryPriv(fileType.cstring, cast[ptr UncheckedArray[uint8]](fileData), fileData.len.int32)

proc loadMusicStreamFromMemory*(fileType: string, data: openarray[uint8]): Music =
  ## Load music stream from data
  loadMusicStreamFromMemoryPriv(fileType.cstring, cast[ptr UncheckedArray[uint8]](data), data.len.int32)

proc recs*(x: Font): lent FontRecs {.inline.} =
  result = FontRecs(x)

proc recs*(x: var Font): var FontRecs {.inline.} =
  result = FontRecs(x)

proc `[]`*(x: FontRecs, i: int32): Rectangle =
  checkArrayAccess(Font(x).recs, Font(x).glyphCount)
  result = Font(x).recs[i]

proc `[]`*(x: var FontRecs, i: int32): var Rectangle =
  checkArrayAccess(Font(x).recs, Font(x).glyphCount)
  result = Font(x).recs[i]

proc `[]=`*(x: var FontRecs, i: int32, val: Rectangle) =
  checkArrayAccess(Font(x).recs, Font(x).glyphCount)
  Font(x).recs[i] = val

proc glyphs*(x: Font): lent FontGlyphs {.inline.} =
  result = FontGlyphs(x)

proc glyphs*(x: var Font): var FontGlyphs {.inline.} =
  result = FontGlyphs(x)

proc `[]`*(x: FontGlyphs, i: int32): GlyphInfo =
  checkArrayAccess(Font(x).glyphs, Font(x).glyphCount)
  result = Font(x).glyphs[i]

proc `[]`*(x: var FontGlyphs, i: int32): var GlyphInfo =
  checkArrayAccess(Font(x).glyphs, Font(x).glyphCount)
  result = Font(x).glyphs[i]

proc `[]=`*(x: var FontGlyphs, i: int32, val: GlyphInfo) =
  checkArrayAccess(Font(x).glyphs, Font(x).glyphCount)
  Font(x).glyphs[i] = val

proc vertices*(x: Mesh): lent MeshVertices {.inline.} =
  result = MeshVertices(x)

proc vertices*(x: var Mesh): var MeshVertices {.inline.} =
  result = MeshVertices(x)

proc `[]`*(x: MeshVertices, i: int32): Vector3 =
  checkArrayAccess(Mesh(x).vertices, Mesh(x).vertexCount)
  result = cast[Vector3](Mesh(x).vertices[i*sizeof(Vector3)])

proc `[]`*(x: var MeshVertices, i: int32): var Vector3 =
  checkArrayAccess(Mesh(x).vertices, Mesh(x).vertexCount)
  result = cast[var Vector3](Mesh(x).vertices[i*sizeof(Vector3)])

proc `[]=`*(x: var MeshVertices, i: int32, val: Vector3) =
  checkArrayAccess(Mesh(x).vertices, Mesh(x).vertexCount)
  copyMem(Mesh(x).vertices[i*sizeof(Vector3)].addr, val.unsafeAddr, sizeof(Vector3))

proc texcoords*(x: Mesh): lent MeshTexcoords {.inline.} =
  result = MeshTexcoords(x)

proc texcoords*(x: var Mesh): var MeshTexcoords {.inline.} =
  result = MeshTexcoords(x)

proc `[]`*(x: MeshTexcoords, i: int32): Vector2 =
  checkArrayAccess(Mesh(x).texcoords, Mesh(x).vertexCount)
  result = cast[Vector2](Mesh(x).texcoords[i*sizeof(Vector2)])

proc `[]`*(x: var MeshTexcoords, i: int32): var Vector2 =
  checkArrayAccess(Mesh(x).texcoords, Mesh(x).vertexCount)
  result = cast[var Vector2](Mesh(x).texcoords[i*sizeof(Vector2)])

proc `[]=`*(x: var MeshTexcoords, i: int32, val: Vector2) =
  checkArrayAccess(Mesh(x).texcoords, Mesh(x).vertexCount)
  copyMem(Mesh(x).texcoords[i*sizeof(Vector2)].addr, val.unsafeAddr, sizeof(Vector2))

proc texcoords2*(x: Mesh): lent MeshTexcoords2 {.inline.} =
  result = MeshTexcoords2(x)

proc texcoords2*(x: var Mesh): var MeshTexcoords2 {.inline.} =
  result = MeshTexcoords2(x)

proc `[]`*(x: MeshTexcoords2, i: int32): Vector2 =
  checkArrayAccess(Mesh(x).texcoords2, Mesh(x).vertexCount)
  result = cast[Vector2](Mesh(x).texcoords2[i*sizeof(Vector2)])

proc `[]`*(x: var MeshTexcoords2, i: int32): var Vector2 =
  checkArrayAccess(Mesh(x).texcoords2, Mesh(x).vertexCount)
  result = cast[var Vector2](Mesh(x).texcoords2[i*sizeof(Vector2)])

proc `[]=`*(x: var MeshTexcoords2, i: int32, val: Vector2) =
  checkArrayAccess(Mesh(x).texcoords2, Mesh(x).vertexCount)
  copyMem(Mesh(x).texcoords2[i*sizeof(Vector2)].addr, val.unsafeAddr, sizeof(Vector2))

proc normals*(x: Mesh): lent MeshNormals {.inline.} =
  result = MeshNormals(x)

proc normals*(x: var Mesh): var MeshNormals {.inline.} =
  result = MeshNormals(x)

proc `[]`*(x: MeshNormals, i: int32): Vector3 =
  checkArrayAccess(Mesh(x).normals, Mesh(x).vertexCount)
  result = cast[Vector3](Mesh(x).normals[i*sizeof(Vector3)])

proc `[]`*(x: var MeshNormals, i: int32): var Vector3 =
  checkArrayAccess(Mesh(x).normals, Mesh(x).vertexCount)
  result = cast[var Vector3](Mesh(x).normals[i*sizeof(Vector3)])

proc `[]=`*(x: var MeshNormals, i: int32, val: Vector3) =
  checkArrayAccess(Mesh(x).normals, Mesh(x).vertexCount)
  copyMem(Mesh(x).normals[i*sizeof(Vector3)].addr, val.unsafeAddr, sizeof(Vector3))

proc tangents*(x: Mesh): lent MeshTangents {.inline.} =
  result = MeshTangents(x)

proc tangents*(x: var Mesh): var MeshTangents {.inline.} =
  result = MeshTangents(x)

proc `[]`*(x: MeshTangents, i: int32): Vector4 =
  checkArrayAccess(Mesh(x).tangents, Mesh(x).vertexCount)
  result = cast[Vector4](Mesh(x).tangents[i*sizeof(Vector4)])

proc `[]`*(x: var MeshTangents, i: int32): var Vector4 =
  checkArrayAccess(Mesh(x).tangents, Mesh(x).vertexCount)
  result = cast[var Vector4](Mesh(x).tangents[i*sizeof(Vector4)])

proc `[]=`*(x: var MeshTangents, i: int32, val: Vector4) =
  checkArrayAccess(Mesh(x).tangents, Mesh(x).vertexCount)
  copyMem(Mesh(x).tangents[i*sizeof(Vector4)].addr, val.unsafeAddr, sizeof(Vector4))

proc colors*(x: Mesh): lent MeshColors {.inline.} =
  result = MeshColors(x)

proc colors*(x: var Mesh): var MeshColors {.inline.} =
  result = MeshColors(x)

proc `[]`*(x: MeshColors, i: int32): Color =
  checkArrayAccess(Mesh(x).colors, Mesh(x).vertexCount)
  result = cast[Color](Mesh(x).colors[i*sizeof(Color)])

proc `[]`*(x: var MeshColors, i: int32): var Color =
  checkArrayAccess(Mesh(x).colors, Mesh(x).vertexCount)
  result = cast[var Color](Mesh(x).colors[i*sizeof(Color)])

proc `[]=`*(x: var MeshColors, i: int32, val: Color) =
  checkArrayAccess(Mesh(x).colors, Mesh(x).vertexCount)
  copyMem(Mesh(x).colors[i*sizeof(Color)].addr, val.unsafeAddr, sizeof(Color))

proc indices*(x: Mesh): lent MeshIndices {.inline.} =
  result = MeshIndices(x)

proc indices*(x: var Mesh): var MeshIndices {.inline.} =
  result = MeshIndices(x)

proc `[]`*(x: MeshIndices, i: int32): array[3, uint16] =
  checkArrayAccess(Mesh(x).indices, Mesh(x).triangleCount)
  result = cast[typeof(result)](Mesh(x).indices[i*sizeof(result)])

proc `[]`*(x: var MeshIndices, i: int32): var array[3, uint16] =
  checkArrayAccess(Mesh(x).indices, Mesh(x).triangleCount)
  result = cast[var typeof(result)](Mesh(x).indices[i*sizeof(result)])

proc `[]=`*(x: var MeshIndices, i: int32, val: array[3, uint16]) =
  checkArrayAccess(Mesh(x).indices, Mesh(x).triangleCount)
  copyMem(Mesh(x).indices[i*sizeof(val)].addr, val.unsafeAddr, sizeof(val))

proc animVertices*(x: Mesh): lent MeshAnimVertices {.inline.} =
  result = MeshAnimVertices(x)

proc animVertices*(x: var Mesh): var MeshAnimVertices {.inline.} =
  result = MeshAnimVertices(x)

proc `[]`*(x: MeshAnimVertices, i: int32): Vector3 =
  checkArrayAccess(Mesh(x).animVertices, Mesh(x).vertexCount)
  result = cast[var Vector3](Mesh(x).animVertices[i*sizeof(Vector3)])

proc `[]`*(x: var MeshAnimVertices, i: int32): var Vector3 =
  checkArrayAccess(Mesh(x).animVertices, Mesh(x).vertexCount)
  result = cast[var Vector3](Mesh(x).animVertices[i*sizeof(Vector3)])

proc `[]=`*(x: var MeshAnimVertices, i: int32, val: Vector3) =
  checkArrayAccess(Mesh(x).animVertices, Mesh(x).vertexCount)
  copyMem(Mesh(x).animVertices[i*sizeof(Vector3)].addr, val.unsafeAddr, sizeof(Vector3))

proc animNormals*(x: Mesh): lent MeshAnimNormals {.inline.} =
  result = MeshAnimNormals(x)

proc animNormals*(x: var Mesh): var MeshAnimNormals {.inline.} =
  result = MeshAnimNormals(x)

proc `[]`*(x: MeshAnimNormals, i: int32): Vector3 =
  checkArrayAccess(Mesh(x).animNormals, Mesh(x).vertexCount)
  result = cast[Vector3](Mesh(x).animNormals[i*sizeof(Vector3)])

proc `[]`*(x: var MeshAnimNormals, i: int32): var Vector3 =
  checkArrayAccess(Mesh(x).animNormals, Mesh(x).vertexCount)
  result = cast[var Vector3](Mesh(x).animNormals[i*sizeof(Vector3)])

proc `[]=`*(x: var MeshAnimNormals, i: int32, val: Vector3) =
  checkArrayAccess(Mesh(x).animNormals, Mesh(x).vertexCount)
  copyMem(Mesh(x).animNormals[i*sizeof(Vector3)].addr, val.unsafeAddr, sizeof(Vector3))

proc boneIds*(x: Mesh): lent MeshBoneIds {.inline.} =
  result = MeshBoneIds(x)

proc boneIds*(x: var Mesh): var MeshBoneIds {.inline.} =
  result = MeshBoneIds(x)

proc `[]`*(x: MeshBoneIds, i: int32): array[4, uint8] =
  checkArrayAccess(Mesh(x).boneIds, Mesh(x).vertexCount)
  result = cast[typeof(result)](Mesh(x).boneIds[i*sizeof(result)])

proc `[]`*(x: var MeshBoneIds, i: int32): var array[4, uint8] =
  checkArrayAccess(Mesh(x).boneIds, Mesh(x).vertexCount)
  result = cast[var typeof(result)](Mesh(x).boneIds[i*sizeof(result)])

proc `[]=`*(x: var MeshBoneIds, i: int32, val: array[4, uint8]) =
  checkArrayAccess(Mesh(x).boneIds, Mesh(x).vertexCount)
  copyMem(Mesh(x).boneIds[i*sizeof(val)].addr, val.unsafeAddr, sizeof(val))

proc boneWeights*(x: Mesh): lent MeshBoneWeights {.inline.} =
  result = MeshBoneWeights(x)

proc boneWeights*(x: var Mesh): var MeshBoneWeights {.inline.} =
  result = MeshBoneWeights(x)

proc `[]`*(x: MeshBoneWeights, i: int32): Vector4 =
  checkArrayAccess(Mesh(x).boneWeights, Mesh(x).vertexCount)
  result = cast[Vector4](Mesh(x).boneWeights[i*sizeof(Vector4)])

proc `[]`*(x: var MeshBoneWeights, i: int32): var Vector4 =
  checkArrayAccess(Mesh(x).boneWeights, Mesh(x).vertexCount)
  result = cast[var Vector4](Mesh(x).boneWeights[i*sizeof(Vector4)])

proc `[]=`*(x: var MeshBoneWeights, i: int32, val: Vector4) =
  checkArrayAccess(Mesh(x).boneWeights, Mesh(x).vertexCount)
  copyMem(Mesh(x).boneWeights[i*sizeof(Vector4)].addr, val.unsafeAddr, sizeof(Vector4))

proc vboId*(x: Mesh): lent MeshVboId {.inline.} =
  result = MeshVboId(x)

proc vboId*(x: var Mesh): var MeshVboId {.inline.} =
  result = MeshVboId(x)

proc `[]`*(x: MeshVboId, i: int32): uint32 =
  checkArrayAccess(Mesh(x).vboId, MaxMeshVertexBuffers)
  result = Mesh(x).vboId[i]

proc `[]`*(x: var MeshVboId, i: int32): var uint32 =
  checkArrayAccess(Mesh(x).vboId, MaxMeshVertexBuffers)
  result = Mesh(x).vboId[i]

proc `[]=`*(x: var MeshVboId, i: int32, val: uint32) =
  checkArrayAccess(Mesh(x).vboId, MaxMeshVertexBuffers)
  Mesh(x).vboId[i] = val

proc locs*(x: Shader): lent ShaderLocs {.inline.} =
  result = ShaderLocs(x)

proc locs*(x: var Shader): var ShaderLocs {.inline.} =
  result = ShaderLocs(x)

proc `[]`*(x: ShaderLocs, i: ShaderLocationIndex): int32 =
  checkArrayAccess(Shader(x).locs, MaxShaderLocations)
  result = Shader(x).locs[i]

proc `[]`*(x: var ShaderLocs, i: ShaderLocationIndex): var int32 =
  checkArrayAccess(Shader(x).locs, MaxShaderLocations)
  result = Shader(x).locs[i]

proc `[]=`*(x: var ShaderLocs, i: ShaderLocationIndex, val: int32) =
  checkArrayAccess(Shader(x).locs, MaxShaderLocations)
  Shader(x).locs[i] = val

proc maps*(x: Material): lent MaterialMaps {.inline.} =
  result = MaterialMaps(x)

proc maps*(x: var Material): var MaterialMaps {.inline.} =
  result = MaterialMaps(x)

proc `[]`*(x: MaterialMaps, i: MaterialMapIndex): MaterialMap =
  checkArrayAccess(Material(x).maps, MaxMaterialMaps)
  result = Material(x).maps[i]

proc `[]`*(x: var MaterialMaps, i: MaterialMapIndex): var MaterialMap =
  checkArrayAccess(Material(x).maps, MaxMaterialMaps)
  result = Material(x).maps[i]

proc `[]=`*(x: var MaterialMaps, i: MaterialMapIndex, val: MaterialMap) =
  checkArrayAccess(Material(x).maps, MaxMaterialMaps)
  Material(x).maps[i] = val

proc meshes*(x: Model): lent ModelMeshes {.inline.} =
  result = ModelMeshes(x)

proc meshes*(x: var Model): var ModelMeshes {.inline.} =
  result = ModelMeshes(x)

proc `[]`*(x: ModelMeshes, i: int32): Mesh =
  checkArrayAccess(Model(x).meshes, Model(x).meshCount)
  result = Model(x).meshes[i]

proc `[]`*(x: var ModelMeshes, i: int32): var Mesh =
  checkArrayAccess(Model(x).meshes, Model(x).meshCount)
  result = Model(x).meshes[i]

proc `[]=`*(x: var ModelMeshes, i: int32, val: Mesh) =
  checkArrayAccess(Model(x).meshes, Model(x).meshCount)
  Model(x).meshes[i] = val

proc materials*(x: Model): lent ModelMaterials {.inline.} =
  result = ModelMaterials(x)

proc materials*(x: var Model): var ModelMaterials {.inline.} =
  result = ModelMaterials(x)

proc `[]`*(x: ModelMaterials, i: int32): Material =
  checkArrayAccess(Model(x).materials, Model(x).materialCount)
  result = Model(x).materials[i]

proc `[]`*(x: var ModelMaterials, i: int32): var Material =
  checkArrayAccess(Model(x).materials, Model(x).materialCount)
  result = Model(x).materials[i]

proc `[]=`*(x: var ModelMaterials, i: int32, val: Material) =
  checkArrayAccess(Model(x).materials, Model(x).materialCount)
  Model(x).materials[i] = val

proc meshMaterial*(x: Model): lent ModelMeshMaterial {.inline.} =
  result = ModelMeshMaterial(x)

proc meshMaterial*(x: var Model): var ModelMeshMaterial {.inline.} =
  result = ModelMeshMaterial(x)

proc `[]`*(x: ModelMeshMaterial, i: int32): int32 =
  checkArrayAccess(Model(x).meshMaterial, Model(x).meshCount)
  result = Model(x).meshMaterial[i]

proc `[]`*(x: var ModelMeshMaterial, i: int32): var int32 =
  checkArrayAccess(Model(x).meshMaterial, Model(x).meshCount)
  result = Model(x).meshMaterial[i]

proc `[]=`*(x: var ModelMeshMaterial, i: int32, val: int32) =
  checkArrayAccess(Model(x).meshMaterial, Model(x).meshCount)
  Model(x).meshMaterial[i] = val

proc bones*(x: Model): lent ModelBones {.inline.} =
  result = ModelBones(x)

proc bones*(x: var Model): var ModelBones {.inline.} =
  result = ModelBones(x)

proc `[]`*(x: ModelBones, i: int32): BoneInfo =
  checkArrayAccess(Model(x).bones, Model(x).boneCount)
  result = Model(x).bones[i]

proc `[]`*(x: var ModelBones, i: int32): var BoneInfo =
  checkArrayAccess(Model(x).bones, Model(x).boneCount)
  result = Model(x).bones[i]

proc `[]=`*(x: var ModelBones, i: int32, val: BoneInfo) =
  checkArrayAccess(Model(x).bones, Model(x).boneCount)
  Model(x).bones[i] = val

proc bindPose*(x: Model): lent ModelBindPose {.inline.} =
  result = ModelBindPose(x)

proc bindPose*(x: var Model): var ModelBindPose {.inline.} =
  result = ModelBindPose(x)

proc `[]`*(x: ModelBindPose, i: int32): Transform =
  checkArrayAccess(Model(x).bindPose, Model(x).boneCount)
  result = Model(x).bindPose[i]

proc `[]`*(x: var ModelBindPose, i: int32): var Transform =
  checkArrayAccess(Model(x).bindPose, Model(x).boneCount)
  result = Model(x).bindPose[i]

proc `[]=`*(x: var ModelBindPose, i: int32, val: Transform) =
  checkArrayAccess(Model(x).bindPose, Model(x).boneCount)
  Model(x).bindPose[i] = val

proc bones*(x: ModelAnimation): lent ModelAnimationBones {.inline.} =
  result = ModelAnimationBones(x)

proc bones*(x: var ModelAnimation): var ModelAnimationBones {.inline.} =
  result = ModelAnimationBones(x)

proc `[]`*(x: ModelAnimationBones, i: int32): BoneInfo =
  checkArrayAccess(ModelAnimation(x).bones, ModelAnimation(x).boneCount)
  result = ModelAnimation(x).bones[i]

proc `[]`*(x: var ModelAnimationBones, i: int32): var BoneInfo =
  checkArrayAccess(ModelAnimation(x).bones, ModelAnimation(x).boneCount)
  result = ModelAnimation(x).bones[i]

proc `[]=`*(x: var ModelAnimationBones, i: int32, val: BoneInfo) =
  checkArrayAccess(ModelAnimation(x).bones, ModelAnimation(x).boneCount)
  ModelAnimation(x).bones[i] = val

proc framePoses*(x: ModelAnimation): lent ModelAnimationFramePoses {.inline.} =
  result = ModelAnimationFramePoses(x)

proc framePoses*(x: var ModelAnimation): var ModelAnimationFramePoses {.inline.} =
  result = ModelAnimationFramePoses(x)

type
  FramePose* = object
    len: int32
    data: ptr UncheckedArray[Transform]

proc len*(x: FramePose): int32 {.inline.} = x.len

proc `=destroy`*(x: var FramePose) =
  if x.data != nil: memFree(x.data)
proc `=copy`*(dest: var FramePose; source: FramePose) =
  if dest.data != source.data:
    `=destroy`(dest)
    wasMoved(dest)
    dest.len = source.len
    if dest.len > 0:
      dest.data = cast[typeof(dest.data)](memAlloc(dest.len))
      copyMem(dest.data, source.data, dest.len * sizeof(Transform))

proc `[]`*(x: ModelAnimationFramePoses, i: int32): FramePose =
  checkArrayAccess(ModelAnimation(x).framePoses, ModelAnimation(x).frameCount)
  result = FramePose(len: ModelAnimation(x).boneCount, data: ModelAnimation(x).framePoses[i])

proc `[]`*(x: var ModelAnimationFramePoses, i: int32): FramePose =
  checkArrayAccess(ModelAnimation(x).framePoses, ModelAnimation(x).frameCount)
  result = FramePose(len: ModelAnimation(x).boneCount, data: ModelAnimation(x).framePoses[i])

proc `[]=`*(x: var ModelAnimationFramePoses, i: int32, val: sink FramePose) =
  checkArrayAccess(ModelAnimation(x).framePoses, ModelAnimation(x).frameCount)
  ModelAnimation(x).framePoses[i] = val.data

proc `[]`*(x: FramePose, i: int32): lent Transform =
  checkArrayAccess(x.data, x.len)
  result = x.data[i]

proc `[]`*(x: var FramePose, i: int32): var Transform =
  checkArrayAccess(x.data, x.len)
  result = x.data[i]

proc `[]=`*(x: var FramePose, i: int32, val: Transform) =
  checkArrayAccess(x.data, x.len)
  x.data[i] = val
