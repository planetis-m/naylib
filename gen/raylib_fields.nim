
proc raiseRangeDefect {.noinline, noreturn.} =
  raise newException(RangeDefect, "array access out of bounds")

template checkArrayAccess(a, x, len) =
  when compileOption("boundChecks"):
    {.line.}:
      if a == nil or x.uint32 >= len.uint32:
        raiseRangeDefect()

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

template locs*(x: Shader): ShaderLocs = ShaderLocs(x)

proc `[]`*(x: ShaderLocs, i: ShaderLocationIndex): int32 =
  checkArrayAccess(Shader(x).locs, i, MaxShaderLocations)
  result = Shader(x).locs[i.int]

proc `[]`*(x: var ShaderLocs, i: ShaderLocationIndex): var int32 =
  checkArrayAccess(Shader(x).locs, i, MaxShaderLocations)
  result = Shader(x).locs[i.int]

proc `[]=`*(x: var ShaderLocs, i: ShaderLocationIndex, val: int32) =
  checkArrayAccess(Shader(x).locs, i, MaxShaderLocations)
  Shader(x).locs[i.int] = val

template maps*(x: Material): MaterialMaps = MaterialMaps(x)

proc `[]`*(x: MaterialMaps, i: MaterialMapIndex): lent MaterialMap =
  checkArrayAccess(Material(x).maps, i, MaxMaterialMaps)
  result = Material(x).maps[i.int]

proc `[]`*(x: var MaterialMaps, i: MaterialMapIndex): var MaterialMap =
  checkArrayAccess(Material(x).maps, i, MaxMaterialMaps)
  result = Material(x).maps[i.int]

proc `[]=`*(x: var MaterialMaps, i: MaterialMapIndex, val: MaterialMap) =
  checkArrayAccess(Material(x).maps, i, MaxMaterialMaps)
  Material(x).maps[i.int] = val

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
