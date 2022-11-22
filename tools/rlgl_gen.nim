import common, std/[streams, strutils]
when defined(nimPreviewSlimSystem):
  import std/syncio

const
  rlglHeader = """
from raylib import PixelFormat, TextureFilter, BlendMode, ShaderLocationIndex,
  ShaderUniformDataType, ShaderAttributeDataType, MaxShaderLocations, Matrix
export PixelFormat, TextureFilter, BlendMode, ShaderLocationIndex, ShaderUniformDataType,
  ShaderAttributeDataType, MaxShaderLocations

const
  RlglVersion* = (4, 2, 0)
"""
  types = """

type
  TextureParameter* = distinct int32
  MatrixMode* = distinct int32
  DrawMode* = distinct int32
  GlType* = distinct int32
  BufferUsageHint* = distinct int32
  ShaderType* = distinct int32

  GlVersion* = distinct int32
  FramebufferAttachType* = distinct int32
  FramebufferAttachTextureType* = distinct int32
  CullMode* = distinct int32
"""
  constants = """

  DefaultBatchBufferElements = 8192 ## This is the maximum amount of elements (quads) per batch
                                    ## NOTE: Be careful with text, every letter maps to a quad
  DefaultBatchBuffers = 1 ## Default number of batch buffers (multi-buffering)
  DefaultBatchDrawCalls = 256 ## Default number of batch draw calls (by state changes: mode, texture)
  DefaultBatchMaxTextureUnits = 4 ## Maximum number of textures units that can be activated on batch drawing
  MaxMatrixStackSize = 32 ## Maximum size of Matrix stack
  # MaxShaderLocations = 32 ## Maximum number of shader locations supported
  CullDistanceNear = 0.01 ## Default near cull distance
  CullDistanceFar = 1000.0 ## Default far cull distance

  # Texture parameters (equivalent to OpenGL defines)
  TextureWrapS = TextureParameter(0x2802) ## GL_TEXTURE_WRAP_S
  TextureWrapT = TextureParameter(0x2803) ## GL_TEXTURE_WRAP_T
  TextureMagFilter = TextureParameter(0x2800) ## GL_TEXTURE_MAG_FILTER
  TextureMinFilter = TextureParameter(0x2801) ## GL_TEXTURE_MIN_FILTER

  TextureFilterNEAREST = TextureParameter(0x2600) ## GL_NEAREST
  TextureFilterLINEAR = TextureParameter(0x2601) ## GL_LINEAR
  TextureFilterMIP_NEAREST = TextureParameter(0x2700) ## GL_NEAREST_MIPMAP_NEAREST
  TextureFilterNEAREST_MIP_LINEAR = TextureParameter(0x2702) ## GL_NEAREST_MIPMAP_LINEAR
  TextureFilterLINEAR_MIP_NEAREST = TextureParameter(0x2701) ## GL_LINEAR_MIPMAP_NEAREST
  TextureFilterMIP_LINEAR = TextureParameter(0x2703) ## GL_LINEAR_MIPMAP_LINEAR
  TextureFilterANISOTROPIC = TextureParameter(0x3000) ## Anisotropic filter (custom identifier)
  TextureMipmapBIAS_RATIO = TextureParameter(0x4000) ## Texture mipmap bias, percentage ratio (custom identifier)

  TextureWrapRepeat = TextureParameter(0x2901) ## GL_REPEAT
  TextureWrapClamp = TextureParameter(0x812F) ## GL_CLAMP_TO_EDGE
  TextureWrapMirrorRepeat = TextureParameter(0x8370) ## GL_MIRRORED_REPEAT
  TextureWrapMirrorClamp = TextureParameter(0x8742) ## GL_MIRROR_CLAMP_EXT

  # Matrix modes (equivalent to OpenGL)
  MatrixModelview = MatrixMode(0x1700) ## GL_MODELVIEW
  MatrixProjection = MatrixMode(0x1701) ## GL_PROJECTION
  MatrixTexture = MatrixMode(0x1702) ## GL_TEXTURE

  # Primitive assembly draw modes
  DrawLines = DrawMode(0x0001) ## GL_LINES
  DrawTriangles = DrawMode(0x0004) ## GL_TRIANGLES
  DrawQuads = DrawMode(0x0007) ## GL_QUADS

  # GL equivalent data types
  GlUnsignedByte = GlType(0x1401) ## GL_UNSIGNED_BYTE
  GlFloat = GlType(0x1406) ## GL_FLOAT

  # Buffer usage hint
  UsageStreamDraw = BufferUsageHint(0x88E0) ## GL_STREAM_DRAW
  UsageStreamRead = BufferUsageHint(0x88E1) ## GL_STREAM_READ
  UsageStreamCopy = BufferUsageHint(0x88E2) ## GL_STREAM_COPY
  UsageStaticDraw = BufferUsageHint(0x88E4) ## GL_STATIC_DRAW
  UsageStaticRead = BufferUsageHint(0x88E5) ## GL_STATIC_READ
  UsageStaticCopy = BufferUsageHint(0x88E6) ## GL_STATIC_COPY
  UsageDynamicDraw = BufferUsageHint(0x88E8) ## GL_DYNAMIC_DRAW
  UsageDynamicRead = BufferUsageHint(0x88E9) ## GL_DYNAMIC_READ
  UsageDynamicCopy = BufferUsageHint(0x88EA) ## GL_DYNAMIC_COPY

  # GL Shader type
  FragmentShader = ShaderType(0x8B30) ## GL_FRAGMENT_SHADER
  VertexShader = ShaderType(0x8B31) ## GL_VERTEX_SHADER
  ComputeShader = ShaderType(0x91B9) ## GL_COMPUTE_SHADER
"""
  helpers = """
template drawMode*(mode: DrawMode; body: untyped) =
  ## Drawing mode (how to organize vertex)
  rlBegin(mode)
  try:
    body
  finally: rlEnd()

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
      if a == nil or (x < 0 or x >= len):
        raiseIndexDefect(x, len-1)

proc `[]`*(x: VertexBufferVertices, i: int): Vector3 =
  checkArrayAccess(VertexBuffer(x).vertices, i, VertexBuffer(x).elementCount)
  result = cast[ptr UncheckedArray[Vector3]](VertexBuffer(x).vertices)[i]

proc `[]`*(x: var VertexBufferVertices, i: int): var Vector3 =
  checkArrayAccess(VertexBuffer(x).vertices, i, VertexBuffer(x).elementCount)
  result = cast[ptr UncheckedArray[Vector3]](VertexBuffer(x).vertices)[i]

proc `[]=`*(x: var VertexBufferVertices, i: int, val: Vector3) =
  checkArrayAccess(VertexBuffer(x).vertices, i, VertexBuffer(x).elementCount)
  cast[ptr UncheckedArray[Vector3]](VertexBuffer(x).vertices)[i] = val

proc `[]`*(x: VertexBufferTexcoords, i: int): Vector2 =
  checkArrayAccess(VertexBuffer(x).texcoords, i, VertexBuffer(x).elementCount)
  result = cast[ptr UncheckedArray[Vector2]](VertexBuffer(x).texcoords)[i]

proc `[]`*(x: var VertexBufferTexcoords, i: int): var Vector2 =
  checkArrayAccess(VertexBuffer(x).texcoords, i, VertexBuffer(x).elementCount)
  result = cast[ptr UncheckedArray[Vector2]](VertexBuffer(x).texcoords)[i]

proc `[]=`*(x: var VertexBufferTexcoords, i: int, val: Vector2) =
  checkArrayAccess(VertexBuffer(x).texcoords, i, VertexBuffer(x).elementCount)
  cast[ptr UncheckedArray[Vector2]](VertexBuffer(x).texcoords)[i] = val

proc `[]`*(x: VertexBufferColors, i: int): Color =
  checkArrayAccess(VertexBuffer(x).colors, i, VertexBuffer(x).elementCount)
  result = cast[ptr UncheckedArray[Color]](VertexBuffer(x).colors)[i]

proc `[]`*(x: var VertexBufferColors, i: int): var Color =
  checkArrayAccess(VertexBuffer(x).colors, i, VertexBuffer(x).elementCount)
  result = cast[ptr UncheckedArray[Color]](VertexBuffer(x).colors)[i]

proc `[]=`*(x: var VertexBufferColors, i: int, val: Color) =
  checkArrayAccess(VertexBuffer(x).colors, i, VertexBuffer(x).elementCount)
  cast[ptr UncheckedArray[Color]](VertexBuffer(x).colors)[i] = val

proc `[]`*(x: VertexBufferIndices, i: int): array[6, uint32] =
  checkArrayAccess(VertexBuffer(x).indices, i, VertexBuffer(x).elementCount)
  result = cast[ptr UncheckedArray[typeof(result)]](VertexBuffer(x).indices)[i]

proc `[]`*(x: var VertexBufferIndices, i: int): var array[6, uint32] =
  checkArrayAccess(VertexBuffer(x).indices, i, VertexBuffer(x).elementCount)
  result = cast[ptr UncheckedArray[typeof(result)]](VertexBuffer(x).indices)[i]

proc `[]=`*(x: var VertexBufferIndices, i: int, val: array[6, uint32]) =
  checkArrayAccess(VertexBuffer(x).indices, i, VertexBuffer(x).elementCount)
  cast[ptr UncheckedArray[typeof(val)]](VertexBuffer(x).indices)[i] = val

proc `[]`*(x: RenderBatchVertexBuffer, i: int): VertexBuffer =
  checkArrayAccess(RenderBatch(x).vertexBuffer, i, RenderBatch(x).bufferCount)
  result = RenderBatch(x).vertexBuffer[i]

proc `[]`*(x: var RenderBatchVertexBuffer, i: int): var VertexBuffer =
  checkArrayAccess(RenderBatch(x).vertexBuffer, i, RenderBatch(x).bufferCount)
  result = RenderBatch(x).vertexBuffer[i]

proc `[]`*(x: RenderBatchDraws, i: int): Rectangle =
  checkArrayAccess(RenderBatch(x).draws, i, DefaultBatchDrawCalls)
  result = RenderBatch(x).draws[i]

proc `[]`*(x: var RenderBatchDraws, i: int): var Rectangle =
  checkArrayAccess(RenderBatch(x).draws, i, DefaultBatchDrawCalls)
  result = RenderBatch(x).draws[i]
"""
  destructors = """

proc `=destroy`*(x: var RenderBatch) =
  if x.vertexBuffer != nil: unloadRenderBatch(x)
proc `=copy`*(dest: var RenderBatch; source: RenderBatch) {.error.}

proc `=sink`*(dest: var vertexBuffer; source: VertexBuffer) {.error.}
proc `=copy`*(dest: var VertexBuffer; source: VertexBuffer) {.error.}
"""
  excludedEnums = [
    "rlTraceLogLevel",
    "rlPixelFormat",
    "rlTextureFilter",
    "rlBlendMode",
    "rlShaderLocationIndex",
    "rlShaderUniformDataType",
    "rlShaderAttributeDataType"
  ]
  excludedTypes = [
    "Matrix"
  ]

proc genBindings(t: TopLevel, fname: string, header, footer: string) =
  var buf = newStringOfCap(50)
  var indent = 0
  var otp: FileStream
  try:
    otp = openFileStream(fname, fmWrite)
    lit header
    lit types
    # Generate type definitions
    lit "\nconst"
    scope:
      for enm in items(t.enums):
        if enm.name notin ["rlGlVersion", "rlFramebufferAttachType",
            "rlFramebufferAttachTextureType", "rlCullMode"]:
          continue
        for i, val in pairs(enm.values):
          spaces
          var name = val.name
          removePrefix(name, "RL_")
          ident camelCaseAscii(name)
          lit "* = "
          name = enm.name
          removePrefix(name, "rl")
          ident name
          lit "("
          lit $val.value
          lit ")"
          doc val
    lit "\n"
    lit constants
    var procArrays: seq[(string, string, string)] = @[]
    lit "\ntype"
    scope:
      for obj in items(t.structs):
        if obj.name in excludedTypes: continue
        spaces
        var objName = obj.name
        if objName != "rlglData":
          removePrefix(objName, "rl")
        ident capitalizeAscii(objName)
        lit "* {.bycopy.} = object"
        doc obj
        scope:
          for fld in items(obj.fields):
            spaces
            var name = fld.name
            ident name
            # let kind = getReplacement(obj.name, name, replacement)
            # if kind != "":
            #   lit kind
            #   continue
            var baseKind = ""
            let many = isPlural(name) or (objName, name) == ("RenderBatch", "vertexBuffer")
            let kind = convertType(fld.`type`, "", many, false, baseKind)
            if many:
              lit ": "
            else:
              lit "*: "
            lit kind
            doc fld
            if many:
              procArrays.add (objName, name, baseKind)
        lit "\n"
      for obj, name, _ in procArrays.items:
        spaces
        lit obj
        lit capitalizeAscii(name)
        lit "* = distinct "
        ident obj
      lit "\n"
    lit destructors
    # Generate functions
    lit "\n{.push callconv: cdecl, header: \"rlgl.h\".}"
    for fnc in items(t.functions):
      lit "\nproc "
      var name = fnc.name
      if name notin ["rlBegin", "rlEnd", "rlglInit", "rlglClose"]:
        removePrefix(name, "rl")
      ident uncapitalizeAscii(name)
      lit "*("
      var hasVarargs = false
      for i, param in fnc.params.pairs:
        if param.name == "args" and param.`type` == "...":
          hasVarargs = true
        else:
          if i > 0: lit ", "
          ident param.name
          lit ": "
          var baseKind = ""
          let kind = convertType(param.`type`, "", false, true, baseKind)
          lit kind
      lit ")"
      if fnc.returnType != "void":
        lit ": "
        var baseKind = ""
        let kind = convertType(fnc.returnType, "", false, true, baseKind)
        lit kind
      lit " {.importc: \""
      ident fnc.name
      lit "\""
      if hasVarargs:
        lit ", varargs"
      lit ".}"
      if fnc.description != "":
        scope:
          spaces
          lit "## "
          lit fnc.description
    lit "\n{.pop.}\n"
    # lit "\n"
    lit footer
  finally:
    if otp != nil: otp.close()

const
  rlglApi = "../api/rlgl_api.json"
  outputname = "../src/rlgl.nim"

proc main =
  var t = parseApi(rlglApi)
  genBindings(t, outputname, rlglHeader, helpers)

main()
