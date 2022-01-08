
proc raiseRangeDefect {.noinline, noreturn.} =
  raise newException(RangeDefect, "array access out of bounds")

template checkArrayAccess(a, x, len) =
  when compileOption("boundChecks"):
    {.line.}:
      if a == nil or x.uint32 >= len.uint32:
        raiseRangeDefect()

proc `<`*(a, b: MaterialMapIndex): bool {.borrow.}
proc `<=`*(a, b: MaterialMapIndex): bool {.borrow.}
proc `==`*(a, b: MaterialMapIndex): bool {.borrow.}

proc `<`*(a, b: ShaderLocationIndex): bool {.borrow.}
proc `<=`*(a, b: ShaderLocationIndex): bool {.borrow.}
proc `==`*(a, b: ShaderLocationIndex): bool {.borrow.}

proc recs*(x: Font): lent FontRecs {.inline.} =
  result = FontRecs(x)

proc recs*(x: var Font): var FontRecs {.inline.} =
  result = FontRecs(x)

proc `[]`*(x: FontRecs, i: int32): Rectangle =
  checkArrayAccess(Font(x).recs, i, Font(x).glyphCount)
  result = Font(x).recs[i]

proc `[]`*(x: var FontRecs, i: int32): var Rectangle =
  checkArrayAccess(Font(x).recs, i, Font(x).glyphCount)
  result = Font(x).recs[i]

proc `[]=`*(x: var FontRecs, i: int32, val: Rectangle) =
  checkArrayAccess(Font(x).recs, i, Font(x).glyphCount)
  Font(x).recs[i] = val

proc glyphs*(x: Font): lent FontGlyphs {.inline.} =
  result = FontGlyphs(x)

proc glyphs*(x: var Font): var FontGlyphs {.inline.} =
  result = FontGlyphs(x)

proc `[]`*(x: FontGlyphs, i: int32): GlyphInfo =
  checkArrayAccess(Font(x).glyphs, i, Font(x).glyphCount)
  result = Font(x).glyphs[i]

proc `[]`*(x: var FontGlyphs, i: int32): var GlyphInfo =
  checkArrayAccess(Font(x).glyphs, i, Font(x).glyphCount)
  result = Font(x).glyphs[i]

proc `[]=`*(x: var FontGlyphs, i: int32, val: GlyphInfo) =
  checkArrayAccess(Font(x).glyphs, i, Font(x).glyphCount)
  Font(x).glyphs[i] = val

proc vertices*(x: Mesh): lent MeshVertices {.inline.} =
  result = MeshVertices(x)

proc vertices*(x: var Mesh): var MeshVertices {.inline.} =
  result = MeshVertices(x)

proc `[]`*(x: MeshVertices, i: int32): Vector3 =
  checkArrayAccess(Mesh(x).vertices, i, Mesh(x).vertexCount)
  result = cast[Vector3](Mesh(x).vertices[i*sizeof(Vector3)])

proc `[]`*(x: var MeshVertices, i: int32): var Vector3 =
  checkArrayAccess(Mesh(x).vertices, i, Mesh(x).vertexCount)
  result = cast[var Vector3](Mesh(x).vertices[i*sizeof(Vector3)])

proc `[]=`*(x: var MeshVertices, i: int32, val: Vector3) =
  checkArrayAccess(Mesh(x).vertices, i, Mesh(x).vertexCount)
  copyMem(Mesh(x).vertices[i*sizeof(Vector3)].addr, val.unsafeAddr, sizeof(Vector3))

proc texcoords*(x: Mesh): lent MeshTexcoords {.inline.} =
  result = MeshTexcoords(x)

proc texcoords*(x: var Mesh): var MeshTexcoords {.inline.} =
  result = MeshTexcoords(x)

proc `[]`*(x: MeshTexcoords, i: int32): Vector2 =
  checkArrayAccess(Mesh(x).texcoords, i, Mesh(x).vertexCount)
  result = cast[Vector2](Mesh(x).texcoords[i*sizeof(Vector2)])

proc `[]`*(x: var MeshTexcoords, i: int32): var Vector2 =
  checkArrayAccess(Mesh(x).texcoords, i, Mesh(x).vertexCount)
  result = cast[var Vector2](Mesh(x).texcoords[i*sizeof(Vector2)])

proc `[]=`*(x: var MeshTexcoords, i: int32, val: Vector2) =
  checkArrayAccess(Mesh(x).texcoords, i, Mesh(x).vertexCount)
  copyMem(Mesh(x).texcoords[i*sizeof(Vector2)].addr, val.unsafeAddr, sizeof(Vector2))

proc texcoords2*(x: Mesh): lent MeshTexcoords2 {.inline.} =
  result = MeshTexcoords2(x)

proc texcoords2*(x: var Mesh): var MeshTexcoords2 {.inline.} =
  result = MeshTexcoords2(x)

proc `[]`*(x: MeshTexcoords2, i: int32): Vector2 =
  checkArrayAccess(Mesh(x).texcoords2, i, Mesh(x).vertexCount)
  result = cast[Vector2](Mesh(x).texcoords2[i*sizeof(Vector2)])

proc `[]`*(x: var MeshTexcoords2, i: int32): var Vector2 =
  checkArrayAccess(Mesh(x).texcoords2, i, Mesh(x).vertexCount)
  result = cast[var Vector2](Mesh(x).texcoords2[i*sizeof(Vector2)])

proc `[]=`*(x: var MeshTexcoords2, i: int32, val: Vector2) =
  checkArrayAccess(Mesh(x).texcoords2, i, Mesh(x).vertexCount)
  copyMem(Mesh(x).texcoords2[i*sizeof(Vector2)].addr, val.unsafeAddr, sizeof(Vector2))

proc normals*(x: Mesh): lent MeshNormals {.inline.} =
  result = MeshNormals(x)

proc normals*(x: var Mesh): var MeshNormals {.inline.} =
  result = MeshNormals(x)

proc `[]`*(x: MeshNormals, i: int32): Vector3 =
  checkArrayAccess(Mesh(x).normals, i, Mesh(x).vertexCount)
  result = cast[Vector3](Mesh(x).normals[i*sizeof(Vector3)])

proc `[]`*(x: var MeshNormals, i: int32): var Vector3 =
  checkArrayAccess(Mesh(x).normals, i, Mesh(x).vertexCount)
  result = cast[var Vector3](Mesh(x).normals[i*sizeof(Vector3)])

proc `[]=`*(x: var MeshNormals, i: int32, val: Vector3) =
  checkArrayAccess(Mesh(x).normals, i, Mesh(x).vertexCount)
  copyMem(Mesh(x).normals[i*sizeof(Vector3)].addr, val.unsafeAddr, sizeof(Vector3))

proc tangents*(x: Mesh): lent MeshTangents {.inline.} =
  result = MeshTangents(x)

proc tangents*(x: var Mesh): var MeshTangents {.inline.} =
  result = MeshTangents(x)

proc `[]`*(x: MeshTangents, i: int32): Vector4 =
  checkArrayAccess(Mesh(x).tangents, i, Mesh(x).vertexCount)
  result = cast[Vector4](Mesh(x).tangents[i*sizeof(Vector4)])

proc `[]`*(x: var MeshTangents, i: int32): var Vector4 =
  checkArrayAccess(Mesh(x).tangents, i, Mesh(x).vertexCount)
  result = cast[var Vector4](Mesh(x).tangents[i*sizeof(Vector4)])

proc `[]=`*(x: var MeshTangents, i: int32, val: Vector4) =
  checkArrayAccess(Mesh(x).tangents, i, Mesh(x).vertexCount)
  copyMem(Mesh(x).tangents[i*sizeof(Vector4)].addr, val.unsafeAddr, sizeof(Vector4))

proc colors*(x: Mesh): lent MeshColors {.inline.} =
  result = MeshColors(x)

proc colors*(x: var Mesh): var MeshColors {.inline.} =
  result = MeshColors(x)

proc `[]`*(x: MeshColors, i: int32): Color =
  checkArrayAccess(Mesh(x).colors, i, Mesh(x).vertexCount)
  result = cast[Color](Mesh(x).colors[i*sizeof(Color)])

proc `[]`*(x: var MeshColors, i: int32): var Color =
  checkArrayAccess(Mesh(x).colors, i, Mesh(x).vertexCount)
  result = cast[var Color](Mesh(x).colors[i*sizeof(Color)])

proc `[]=`*(x: var MeshColors, i: int32, val: Color) =
  checkArrayAccess(Mesh(x).colors, i, Mesh(x).vertexCount)
  copyMem(Mesh(x).colors[i*sizeof(Color)].addr, val.unsafeAddr, sizeof(Color))

proc indices*(x: Mesh): lent MeshIndices {.inline.} =
  result = MeshIndices(x)

proc indices*(x: var Mesh): var MeshIndices {.inline.} =
  result = MeshIndices(x)

proc `[]`*(x: MeshIndices, i: int32): array[3, uint16] =
  checkArrayAccess(Mesh(x).indices, i, Mesh(x).triangleCount)
  result = cast[typeof(result)](Mesh(x).indices[i*sizeof(result)])

proc `[]`*(x: var MeshIndices, i: int32): var array[3, uint16] =
  checkArrayAccess(Mesh(x).indices, i, Mesh(x).triangleCount)
  result = cast[var typeof(result)](Mesh(x).indices[i*sizeof(result)])

proc `[]=`*(x: var MeshIndices, i: int32, val: array[3, uint16]) =
  checkArrayAccess(Mesh(x).indices, i, Mesh(x).triangleCount)
  copyMem(Mesh(x).indices[i*sizeof(val)].addr, val.unsafeAddr, sizeof(val))

proc animVertices*(x: Mesh): lent MeshAnimVertices {.inline.} =
  result = MeshAnimVertices(x)

proc animVertices*(x: var Mesh): var MeshAnimVertices {.inline.} =
  result = MeshAnimVertices(x)

proc `[]`*(x: MeshAnimVertices, i: int32): Vector3 =
  checkArrayAccess(Mesh(x).animVertices, i, Mesh(x).vertexCount)
  result = cast[var Vector3](Mesh(x).animVertices[i*sizeof(Vector3)])

proc `[]`*(x: var MeshAnimVertices, i: int32): var Vector3 =
  checkArrayAccess(Mesh(x).animVertices, i, Mesh(x).vertexCount)
  result = cast[var Vector3](Mesh(x).animVertices[i*sizeof(Vector3)])

proc `[]=`*(x: var MeshAnimVertices, i: int32, val: Vector3) =
  checkArrayAccess(Mesh(x).animVertices, i, Mesh(x).vertexCount)
  copyMem(Mesh(x).animVertices[i*sizeof(Vector3)].addr, val.unsafeAddr, sizeof(Vector3))

proc animNormals*(x: Mesh): lent MeshAnimNormals {.inline.} =
  result = MeshAnimNormals(x)

proc animNormals*(x: var Mesh): var MeshAnimNormals {.inline.} =
  result = MeshAnimNormals(x)

proc `[]`*(x: MeshAnimNormals, i: int32): Vector3 =
  checkArrayAccess(Mesh(x).animNormals, i, Mesh(x).vertexCount)
  result = cast[Vector3](Mesh(x).animNormals[i*sizeof(Vector3)])

proc `[]`*(x: var MeshAnimNormals, i: int32): var Vector3 =
  checkArrayAccess(Mesh(x).animNormals, i, Mesh(x).vertexCount)
  result = cast[var Vector3](Mesh(x).animNormals[i*sizeof(Vector3)])

proc `[]=`*(x: var MeshAnimNormals, i: int32, val: Vector3) =
  checkArrayAccess(Mesh(x).animNormals, i, Mesh(x).vertexCount)
  copyMem(Mesh(x).animNormals[i*sizeof(Vector3)].addr, val.unsafeAddr, sizeof(Vector3))

proc boneIds*(x: Mesh): lent MeshBoneIds {.inline.} =
  result = MeshBoneIds(x)

proc boneIds*(x: var Mesh): var MeshBoneIds {.inline.} =
  result = MeshBoneIds(x)

proc `[]`*(x: MeshBoneIds, i: int32): array[4, uint8] =
  checkArrayAccess(Mesh(x).boneIds, i, Mesh(x).vertexCount)
  result = cast[typeof(result)](Mesh(x).boneIds[i*sizeof(result)])

proc `[]`*(x: var MeshBoneIds, i: int32): var array[4, uint8] =
  checkArrayAccess(Mesh(x).boneIds, i, Mesh(x).vertexCount)
  result = cast[var typeof(result)](Mesh(x).boneIds[i*sizeof(result)])

proc `[]=`*(x: var MeshBoneIds, i: int32, val: array[4, uint8]) =
  checkArrayAccess(Mesh(x).boneIds, i, Mesh(x).vertexCount)
  copyMem(Mesh(x).boneIds[i*sizeof(val)].addr, val.unsafeAddr, sizeof(val))

proc boneWeights*(x: Mesh): lent MeshBoneWeights {.inline.} =
  result = MeshBoneWeights(x)

proc boneWeights*(x: var Mesh): var MeshBoneWeights {.inline.} =
  result = MeshBoneWeights(x)

proc `[]`*(x: MeshBoneWeights, i: int32): Vector4 =
  checkArrayAccess(Mesh(x).boneWeights, i, Mesh(x).vertexCount)
  result = cast[Vector4](Mesh(x).boneWeights[i*sizeof(Vector4)])

proc `[]`*(x: var MeshBoneWeights, i: int32): var Vector4 =
  checkArrayAccess(Mesh(x).boneWeights, i, Mesh(x).vertexCount)
  result = cast[var Vector4](Mesh(x).boneWeights[i*sizeof(Vector4)])

proc `[]=`*(x: var MeshBoneWeights, i: int32, val: Vector4) =
  checkArrayAccess(Mesh(x).boneWeights, i, Mesh(x).vertexCount)
  copyMem(Mesh(x).boneWeights[i*sizeof(Vector4)].addr, val.unsafeAddr, sizeof(Vector4))

proc vboId*(x: Mesh): lent MeshVboId {.inline.} =
  result = MeshVboId(x)

proc vboId*(x: var Mesh): var MeshVboId {.inline.} =
  result = MeshVboId(x)

proc `[]`*(x: MeshVboId, i: int32): uint32 =
  checkArrayAccess(Mesh(x).vboId, i, MaxMeshVertexBuffers)
  result = Mesh(x).vboId[i]

proc `[]`*(x: var MeshVboId, i: int32): var uint32 =
  checkArrayAccess(Mesh(x).vboId, i, MaxMeshVertexBuffers)
  result = Mesh(x).vboId[i]

proc `[]=`*(x: var MeshVboId, i: int32, val: uint32) =
  checkArrayAccess(Mesh(x).vboId, i, MaxMeshVertexBuffers)
  Mesh(x).vboId[i] = val

proc locs*(x: Shader): lent ShaderLocs {.inline.} =
  result = ShaderLocs(x)

proc locs*(x: var Shader): var ShaderLocs {.inline.} =
  result = ShaderLocs(x)

proc `[]`*(x: ShaderLocs, i: ShaderLocationIndex): int32 =
  checkArrayAccess(Shader(x).locs, i, MaxShaderLocations)
  result = Shader(x).locs[i]

proc `[]`*(x: var ShaderLocs, i: ShaderLocationIndex): var int32 =
  checkArrayAccess(Shader(x).locs, i, MaxShaderLocations)
  result = Shader(x).locs[i]

proc `[]=`*(x: var ShaderLocs, i: ShaderLocationIndex, val: int32) =
  checkArrayAccess(Shader(x).locs, i, MaxShaderLocations)
  Shader(x).locs[i] = val

proc maps*(x: Material): lent MaterialMaps {.inline.} =
  result = MaterialMaps(x)

proc maps*(x: var Material): var MaterialMaps {.inline.} =
  result = MaterialMaps(x)

proc `[]`*(x: MaterialMaps, i: MaterialMapIndex): MaterialMap =
  checkArrayAccess(Material(x).maps, i, MaxMaterialMaps)
  result = Material(x).maps[i]

proc `[]`*(x: var MaterialMaps, i: MaterialMapIndex): var MaterialMap =
  checkArrayAccess(Material(x).maps, i, MaxMaterialMaps)
  result = Material(x).maps[i]

proc `[]=`*(x: var MaterialMaps, i: MaterialMapIndex, val: MaterialMap) =
  checkArrayAccess(Material(x).maps, i, MaxMaterialMaps)
  Material(x).maps[i] = val

proc meshes*(x: Model): lent ModelMeshes {.inline.} =
  result = ModelMeshes(x)

proc meshes*(x: var Model): var ModelMeshes {.inline.} =
  result = ModelMeshes(x)

proc `[]`*(x: ModelMeshes, i: int32): Mesh =
  checkArrayAccess(Model(x).meshes, i, Model(x).meshCount)
  result = Model(x).meshes[i]

proc `[]`*(x: var ModelMeshes, i: int32): var Mesh =
  checkArrayAccess(Model(x).meshes, i, Model(x).meshCount)
  result = Model(x).meshes[i]

proc `[]=`*(x: var ModelMeshes, i: int32, val: Mesh) =
  checkArrayAccess(Model(x).meshes, i, Model(x).meshCount)
  Model(x).meshes[i] = val

proc materials*(x: Model): lent ModelMaterials {.inline.} =
  result = ModelMaterials(x)

proc materials*(x: var Model): var ModelMaterials {.inline.} =
  result = ModelMaterials(x)

proc `[]`*(x: ModelMaterials, i: int32): Material =
  checkArrayAccess(Model(x).materials, i, Model(x).materialCount)
  result = Model(x).materials[i]

proc `[]`*(x: var ModelMaterials, i: int32): var Material =
  checkArrayAccess(Model(x).materials, i, Model(x).materialCount)
  result = Model(x).materials[i]

proc `[]=`*(x: var ModelMaterials, i: int32, val: Material) =
  checkArrayAccess(Model(x).materials, i, Model(x).materialCount)
  Model(x).materials[i] = val

proc meshMaterial*(x: Model): lent ModelMeshMaterial {.inline.} =
  result = ModelMeshMaterial(x)

proc meshMaterial*(x: var Model): var ModelMeshMaterial {.inline.} =
  result = ModelMeshMaterial(x)

proc `[]`*(x: ModelMeshMaterial, i: int32): int32 =
  checkArrayAccess(Model(x).meshMaterial, i, Model(x).meshCount)
  result = Model(x).meshMaterial[i]

proc `[]`*(x: var ModelMeshMaterial, i: int32): var int32 =
  checkArrayAccess(Model(x).meshMaterial, i, Model(x).meshCount)
  result = Model(x).meshMaterial[i]

proc `[]=`*(x: var ModelMeshMaterial, i: int32, val: int32) =
  checkArrayAccess(Model(x).meshMaterial, i, Model(x).meshCount)
  Model(x).meshMaterial[i] = val

proc bones*(x: Model): lent ModelBones {.inline.} =
  result = ModelBones(x)

proc bones*(x: var Model): var ModelBones {.inline.} =
  result = ModelBones(x)

proc `[]`*(x: ModelBones, i: int32): BoneInfo =
  checkArrayAccess(Model(x).bones, i, Model(x).boneCount)
  result = Model(x).bones[i]

proc `[]`*(x: var ModelBones, i: int32): var BoneInfo =
  checkArrayAccess(Model(x).bones, i, Model(x).boneCount)
  result = Model(x).bones[i]

proc `[]=`*(x: var ModelBones, i: int32, val: BoneInfo) =
  checkArrayAccess(Model(x).bones, i, Model(x).boneCount)
  Model(x).bones[i] = val

proc bindPose*(x: Model): lent ModelBindPose {.inline.} =
  result = ModelBindPose(x)

proc bindPose*(x: var Model): var ModelBindPose {.inline.} =
  result = ModelBindPose(x)

proc `[]`*(x: ModelBindPose, i: int32): Transform =
  checkArrayAccess(Model(x).bindPose, i, Model(x).boneCount)
  result = Model(x).bindPose[i]

proc `[]`*(x: var ModelBindPose, i: int32): var Transform =
  checkArrayAccess(Model(x).bindPose, i, Model(x).boneCount)
  result = Model(x).bindPose[i]

proc `[]=`*(x: var ModelBindPose, i: int32, val: Transform) =
  checkArrayAccess(Model(x).bindPose, i, Model(x).boneCount)
  Model(x).bindPose[i] = val

proc bones*(x: ModelAnimation): lent ModelAnimationBones {.inline.} =
  result = ModelAnimationBones(x)

proc bones*(x: var ModelAnimation): var ModelAnimationBones {.inline.} =
  result = ModelAnimationBones(x)

proc `[]`*(x: ModelAnimationBones, i: int32): BoneInfo =
  checkArrayAccess(ModelAnimation(x).bones, i, ModelAnimation(x).boneCount)
  result = ModelAnimation(x).bones[i]

proc `[]`*(x: var ModelAnimationBones, i: int32): var BoneInfo =
  checkArrayAccess(ModelAnimation(x).bones, i, ModelAnimation(x).boneCount)
  result = ModelAnimation(x).bones[i]

proc `[]=`*(x: var ModelAnimationBones, i: int32, val: BoneInfo) =
  checkArrayAccess(ModelAnimation(x).bones, i, ModelAnimation(x).boneCount)
  ModelAnimation(x).bones[i] = val

proc framePoses*(x: ModelAnimation): lent ModelAnimationFramePoses {.inline.} =
  result = ModelAnimationFramePoses(x)

proc framePoses*(x: var ModelAnimation): var ModelAnimationFramePoses {.inline.} =
  result = ModelAnimationFramePoses(x)

proc `[]`*(x: ModelAnimationFramePoses; i, y: int32): lent Transform =
  checkArrayAccess(ModelAnimation(x).framePoses, i, ModelAnimation(x).frameCount)
  checkArrayAccess(ModelAnimation(x).framePoses[i], y, ModelAnimation(x).boneCount)
  result = ModelAnimation(x).framePoses[i][y]

proc `[]`*(x: var ModelAnimationFramePoses; i, y: int32): var Transform =
  checkArrayAccess(ModelAnimation(x).framePoses, i, ModelAnimation(x).frameCount)
  checkArrayAccess(ModelAnimation(x).framePoses[i], y, ModelAnimation(x).boneCount)
  result = ModelAnimation(x).framePoses[i][y]

proc `[]=`*(x: var ModelAnimationFramePoses; i, y: int32, val: Transform) =
  checkArrayAccess(ModelAnimation(x).framePoses, i, ModelAnimation(x).frameCount)
  checkArrayAccess(ModelAnimation(x).framePoses[i], y, ModelAnimation(x).boneCount)
  ModelAnimation(x).framePoses[i][y] = val
