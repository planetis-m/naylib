import common, std/[streams, strutils]
when defined(nimPreviewSlimSystem):
  import std/syncio

const
  rlglHeader = """
from raylib import PixelFormat, TextureFilter, BlendMode, ShaderLocationIndex,
  ShaderUniformDataType, ShaderAttributeDataType, MaxShaderLocations, ShaderLocation,
  Matrix, Vector2, Vector3, Color, ShaderVariable, ShaderLocsPtr
export PixelFormat, TextureFilter, BlendMode, ShaderLocationIndex, ShaderUniformDataType,
  ShaderAttributeDataType, MaxShaderLocations, ShaderLocation, Matrix, Vector2, Vector3,
  Color, ShaderVariable, ShaderLocsPtr

# Security check in case no GraphicsApiOpenGl* defined
when not defined(GraphicsApiOpenGl11) and not defined(GraphicsApiOpenGlEs2):
  const UseDefaultGraphicsApi = true

const
  RlglVersion* = (4, 2, 0)

  DefaultBatchBuffers* = 1 ## Default number of batch buffers (multi-buffering)
  DefaultBatchDrawCalls* = 256 ## Default number of batch draw calls (by state changes: mode, texture)
  DefaultBatchMaxTextureUnits* = 4 ## Maximum number of textures units that can be activated on batch drawing
  MaxMatrixStackSize* = 32 ## Maximum size of Matrix stack
  # MaxShaderLocations* = 32 ## Maximum number of shader locations supported
  CullDistanceNear* = 0.01 ## Default near cull distance
  CullDistanceFar* = 1000.0 ## Default far cull distance

  # Default shader vertex attribute names to set location points
  AttribPosition* = ShaderVariable("vertexPosition") ## Binded by default to shader location: 0
  AttribTexcoord* = ShaderVariable("vertexTexCoord") ## Binded by default to shader location: 1
  AttribNormal* = ShaderVariable("vertexNormal") ## Binded by default to shader location: 2
  AttribColor* = ShaderVariable("vertexColor") ## Binded by default to shader location: 3
  AttribTangent* = ShaderVariable("vertexTangent") ## Binded by default to shader location: 4
  AttribTexcoord2* = ShaderVariable("vertexTexCoord2") ## Binded by default to shader location: 5

  UniformMvp* = ShaderVariable("mvp") ## model-view-projection matrix
  UniformView* = ShaderVariable("matView") ## view matrix
  UniformProjection* = ShaderVariable("matProjection") ## projection matrix
  UniformModel* = ShaderVariable("matModel") ## model matrix
  UniformNormal* = ShaderVariable("matNormal") ## normal matrix (transpose(inverse(matModelView))
  UniformColor* = ShaderVariable("colDiffuse") ## color diffuse (base tint color, multiplied by texture color)
  Sampler2dTexture0* = ShaderVariable("texture0") ## texture0 (texture slot active 0)
  Sampler2dTexture1* = ShaderVariable("texture1") ## texture1 (texture slot active 1)
  Sampler2dTexture2* = ShaderVariable("texture2") ## texture2 (texture slot active 2)

when defined(GraphicsApiOpenGl11) or UseDefaultGraphicsApi:
  const DefaultBatchBufferElements* = 8192 ## This is the maximum amount of elements (quads) per batch
                                           ## NOTE: Be careful with text, every letter maps to a quad
elif defined(GraphicsApiOpenGlEs2):
  const DefaultBatchBufferElements* = 2048 ## We reduce memory sizes for embedded systems (RPI and HTML5)
                                           ## NOTE: On HTML5 (emscripten) this is allocated on heap,
                                           ## by default it's only 16MB!...just take care...
"""
  types = """

type
  TextureParameter* = distinct int32
  MatrixMode* = distinct int32
  DrawMode* = distinct int32
  GlType* = distinct int32
  BufferUsageHint* = distinct int32
  ShaderType* = distinct int32
  BlendFactor* = distinct int32
  BlendEquation* = distinct int32

proc `==`*(a, b: TextureParameter): bool {.borrow.}
proc `==`*(a, b: MatrixMode): bool {.borrow.}
proc `==`*(a, b: DrawMode): bool {.borrow.}
proc `==`*(a, b: GlType): bool {.borrow.}
proc `==`*(a, b: BufferUsageHint): bool {.borrow.}
proc `==`*(a, b: ShaderType): bool {.borrow.}
proc `==`*(a, b: BlendFactor): bool {.borrow.}
proc `==`*(a, b: BlendEquation): bool {.borrow.}

type
  rlglLoadProc* = proc (name: cstring): pointer ## OpenGL extension functions loader signature (same as GLADloadproc)
"""
  constants = """

const
  # Texture parameters (equivalent to OpenGL defines)
  TextureWrapS* = TextureParameter(0x2802) ## GL_TEXTURE_WRAP_S
  TextureWrapT* = TextureParameter(0x2803) ## GL_TEXTURE_WRAP_T
  TextureMagFilter* = TextureParameter(0x2800) ## GL_TEXTURE_MAG_FILTER
  TextureMinFilter* = TextureParameter(0x2801) ## GL_TEXTURE_MIN_FILTER

  TextureFilterNearest* = TextureParameter(0x2600) ## GL_NEAREST
  TextureFilterLinear* = TextureParameter(0x2601) ## GL_LINEAR
  TextureFilterMipNearest* = TextureParameter(0x2700) ## GL_NEAREST_MIPMAP_NEAREST
  TextureFilterNearestMipLinear* = TextureParameter(0x2702) ## GL_NEAREST_MIPMAP_LINEAR
  TextureFilterLinearMipNearest* = TextureParameter(0x2701) ## GL_LINEAR_MIPMAP_NEAREST
  TextureFilterMipLinear* = TextureParameter(0x2703) ## GL_LINEAR_MIPMAP_LINEAR
  TextureFilterAnisotropic* = TextureParameter(0x3000) ## Anisotropic filter (custom identifier)
  TextureMipmapBiasRatio* = TextureParameter(0x4000) ## Texture mipmap bias, percentage ratio (custom identifier)

  TextureWrapRepeat* = TextureParameter(0x2901) ## GL_REPEAT
  TextureWrapClamp* = TextureParameter(0x812F) ## GL_CLAMP_TO_EDGE
  TextureWrapMirrorRepeat* = TextureParameter(0x8370) ## GL_MIRRORED_REPEAT
  TextureWrapMirrorClamp* = TextureParameter(0x8742) ## GL_MIRROR_CLAMP_EXT

  # Matrix modes (equivalent to OpenGL)
  MatrixModelview* = MatrixMode(0x1700) ## GL_MODELVIEW
  MatrixProjection* = MatrixMode(0x1701) ## GL_PROJECTION
  MatrixTexture* = MatrixMode(0x1702) ## GL_TEXTURE

  # Primitive assembly draw modes
  DrawLines* = DrawMode(0x0001) ## GL_LINES
  DrawTriangles* = DrawMode(0x0004) ## GL_TRIANGLES
  DrawQuads* = DrawMode(0x0007) ## GL_QUADS

  # GL equivalent data types
  GlUnsignedByte* = GlType(0x1401) ## GL_UNSIGNED_BYTE
  GlFloat* = GlType(0x1406) ## GL_FLOAT

  # GL buffer usage hint
  HintStreamDraw* = BufferUsageHint(0x88E0) ## GL_STREAM_DRAW
  HintStreamRead* = BufferUsageHint(0x88E1) ## GL_STREAM_READ
  HintStreamCopy* = BufferUsageHint(0x88E2) ## GL_STREAM_COPY
  HintStaticDraw* = BufferUsageHint(0x88E4) ## GL_STATIC_DRAW
  HintStaticRead* = BufferUsageHint(0x88E5) ## GL_STATIC_READ
  HintStaticCopy* = BufferUsageHint(0x88E6) ## GL_STATIC_COPY
  HintDynamicDraw* = BufferUsageHint(0x88E8) ## GL_DYNAMIC_DRAW
  HintDynamicRead* = BufferUsageHint(0x88E9) ## GL_DYNAMIC_READ
  HintDynamicCopy* = BufferUsageHint(0x88EA) ## GL_DYNAMIC_COPY

  # GL Shader type
  FragmentShader* = ShaderType(0x8B30) ## GL_FRAGMENT_SHADER
  VertexShader* = ShaderType(0x8B31) ## GL_VERTEX_SHADER
  ComputeShader* = ShaderType(0x91B9) ## GL_COMPUTE_SHADER

  # GL blending factors
  FactorZero* = BlendFactor(0) ## GL_ZERO
  FactorOne* = BlendFactor(1) ## GL_ONE
  FactorSrcColor* = BlendFactor(0x0300) ## GL_SRC_COLOR
  FactorOneMinusSrcColor* = BlendFactor(0x0301) ## GL_ONE_MINUS_SRC_COLOR
  FactorSrcAlpha* = BlendFactor(0x0302) ## GL_SRC_ALPHA
  FactorOneMinusSrcAlpha* = BlendFactor(0x0303) ## GL_One_MINUS_SRC_ALPHA
  FactorDstAlpha* = BlendFactor(0x0304) ## GL_DST_ALPHA
  FactorOneMinusDstAlpha* = BlendFactor(0x0305) ## GL_ONE_MINUS_DST_ALPHA
  FactorDstColor* = BlendFactor(0x0306) ## GL_DST_COLOR
  FactorOneMinusDstColor* = BlendFactor(0x0307) ## GL_ONE_MINUS_DST_COLOR
  FactorSrcAlphaSaturate* = BlendFactor(0x0308) ## GL_SRC_ALPHA_SATURATE
  FactorConstantColor* = BlendFactor(0x8001) ## GL_CONSTANT_COLOR
  FactorOneMinusConstantColor* = BlendFactor(0x8002) ## GL_ONE_MINUS_CONSTANT_COLOR
  FactorConstantAlpha* = BlendFactor(0x8003) ## GL_CONSTANT_ALPHA
  FactorOneMinusConstantAlpha* = BlendFactor(0x8004) ## GL_ONE_MINUS_CONSTANT_ALPHA

  # GL blending functions/equations
  BlendFuncAdd* = BlendEquation(0x8006) ## GL_FUNC_ADD
  BlendFuncSubtract* = BlendEquation(0x800A) ## GL_FUNC_SUBTRACT
  BlendFuncReverseSubtract* = BlendEquation(0x800B) ## GL_FUNC_REVERSE_SUBTRACT
  # BlendEquation* = BlendEquation(0x8009) ## GL_BLEND_EQUATION
  BlendEquationRgb* = BlendEquation(0x8009) ## GL_BLEND_EQUATION_RGB (Same as BLEND_EQUATION)
  BlendEquationAlpha* = BlendEquation(0x883D) ## GL_BLEND_EQUATION_ALPHA
  BlendDstRgb* = BlendEquation(0x80C8) ## GL_BLEND_DST_RGB
  BlendSrcRgb* = BlendEquation(0x80C9) ## GL_BLEND_SRC_RGB
  BlendDstAlpha* = BlendEquation(0x80CA) ## GL_BLEND_DST_ALPHA
  BlendSrcAlpha* = BlendEquation(0x80CB) ## GL_BLEND_SRC_ALPHA
  BlendColor* = BlendEquation(0x8005) ## GL_BLEND_COLOR

"""
  helpers = """

proc `=destroy`*(x: var RenderBatch) =
  unloadRenderBatch(x)
proc `=copy`*(dest: var RenderBatch; source: RenderBatch) {.error.}

proc `=sink`*(dest: var VertexBuffer; source: VertexBuffer) {.error.}
proc `=copy`*(dest: var VertexBuffer; source: VertexBuffer) {.error.}

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

when defined(GraphicsApiOpenGl11) or UseDefaultGraphicsApi:
  type IndicesArr* = array[6, uint32]
elif defined(GraphicsApiOpenGlEs2):
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
  enumInFuncReturn = [
    ("rlGetLocationUniform", 21),
    ("rlGetLocationAttrib", 21),
    ("rlGetVersion", 34),
  ]
  enumInFuncParams = [
    # TextureParameter
    ("rlTextureParameters", "param"),
    ("rlMatrixMode", "mode"),
    ("rlBegin", "mode"),
    ("rlSetVertexAttribute", "type"),
    ("rlCompileShader", "type"),
    ("rlLoadShaderBuffer", "usageHint"),
    ("rlFramebufferAttach", "attachType"),
    ("rlFramebufferAttach", "texType"),
    ("rlSetCullFace", "mode"),
    ("rlSetBlendMode", "mode"),
    ("rlGetLocationUniform", "uniformName"),
    ("rlGetLocationAttrib", "attribName"),
    ("rlSetUniform", "uniformType"),
    ("rlSetVertexAttributeDefault", "attribType"),
    ("rlGetPixelFormatName", "format"),
    ("rlLoadTextureCubemap", "format"),
    ("rlGetGlTextureFormats", "format"),
    ("rlUpdateTexture", "format"),
    ("rlGenTextureMipmaps", "format"),
    ("rlReadTexturePixels", "format"),
    ("rlBindImageTexture", "format"),
    ("rlSetVertexAttributeDefault", "locIndex"),
    ("rlSetUniform", "locIndex"),
    ("rlSetUniformMatrix", "locIndex"),
    ("rlSetUniformSampler", "locIndex"),
    ("rlSetBlendFactors", "glSrcFactor"),
    ("rlSetBlendFactors", "glDstFactor"),
    ("rlSetBlendFactorsSeparate", "glSrcRGB"),
    ("rlSetBlendFactorsSeparate", "glDstRGB"),
    ("rlSetBlendFactorsSeparate", "glSrcAlpha"),
    ("rlSetBlendFactorsSeparate", "glDstAlpha"),
    ("rlSetBlendFactors", "glEquation"),
    ("rlSetBlendFactorsSeparate", "glEqRGB"),
    ("rlSetBlendFactorsSeparate", "glEqAlpha"),
  ]
  enumInFuncs = [
    "TextureParameter",
    "MatrixMode",
    "DrawMode",
    "GlType",
    "ShaderType",
    "BufferUsageHint",
    "FramebufferAttachType",
    "FramebufferAttachTextureType",
    "CullMode",
    "BlendMode",
    "ShaderVariable",
    "ShaderVariable",
    "ShaderUniformDataType",
    "ShaderAttributeDataType",
    "PixelFormat",
    "PixelFormat",
    "PixelFormat",
    "PixelFormat",
    "PixelFormat",
    "PixelFormat",
    "PixelFormat",
    "ShaderLocation",
    "ShaderLocation",
    "ShaderLocation",
    "ShaderLocation",
    "BlendFactor",
    "BlendFactor",
    "BlendFactor",
    "BlendFactor",
    "BlendFactor",
    "BlendFactor",
    "BlendEquation",
    "BlendEquation",
    "BlendEquation",
    "GlVersion",
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
    lit "\ntype"
    scope:
      for enm in items(t.enums):
        if enm.name in ["rlTraceLogLevel", "rlPixelFormat", "rlTextureFilter", "rlBlendMode",
            "rlShaderLocationIndex", "rlShaderUniformDataType", "rlShaderAttributeDataType"]: continue
        var enmName = enm.name
        spaces
        removePrefix(enmName, "rl")
        ident enmName
        lit "* {.size: sizeof(int32).} = enum"
        doc enm
        scope:
          var prev = -1
          for i, val in pairs(enm.values):
            if val.value == prev: continue
            spaces
            if prev == -1 and enm.name == "GamepadButton":
              lit "None = -1 ## No button pressed"
              spaces
            var valName = val.name
            removePrefix(valName, "RL_")
            removePrefix(valName, "ATTACHMENT_")
            removePrefix(valName, "CULL_")
            ident camelCaseAscii(valName)
            if prev + 1 != val.value:
              lit " = "
              lit $val.value
            doc val
            prev = val.value
          lit "\n"
      lit "\n"
    lit constants
    var procProperties: seq[(string, string, string)] = @[]
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
        lit "* {.importc: \""
        lit obj.name
        lit "\", nodecl, bycopy.} = object" # .header breaks raylib include order
        doc obj
        scope:
          for fld in items(obj.fields):
            spaces
            var name = fld.name
            if (objName, name) == ("VertexBuffer", "indices"):
              lit "when defined(GraphicsApiOpenGl11) or UseDefaultGraphicsApi:"
              scope:
                spaces
                ident name
            else: ident name
            # let kind = getReplacement(obj.name, name, replacement)
            # if kind != "":
            #   lit kind
            #   continue
            var baseKind = ""
            let isPrivate = (objName, name) in {"VertexBuffer": "elementCount", "RenderBatch": "bufferCount"}
            let many = isPlural(name) or (objName, name) == ("RenderBatch", "vertexBuffer")
            let kind = convertType(fld.`type`, "", many, false, baseKind)
            if many or isPrivate:
              lit ": "
            else:
              lit "*: "
            lit kind
            doc fld
            if (objName, name) == ("VertexBuffer", "indices"):
              spaces
              lit "elif defined(GraphicsApiOpenGlEs2):"
              scope:
                spaces
                lit "indices: ptr UncheckedArray[uint16]"
            if isPrivate:
              procProperties.add (objName, name, kind)
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
          block outer:
            for j, (name, param1) in enumInFuncParams.pairs:
              if name == fnc.name and param1 == param.name:
                lit enumInFuncs[j]
                break outer
            var baseKind = ""
            const
              replacements = [
                ("rlLoadExtensions", "loader", "rlglLoadProc"),
                ("rlGenTextureMipmaps", "mipmaps", "out $1"),
                ("rlGetGlTextureFormats", "glInternalFormat", "out $1"),
                ("rlGetGlTextureFormats", "glFormat", "out $1"),
                ("rlGetGlTextureFormats", "glType", "out $1"),
                ("rlSetShader", "locs", "ShaderLocsPtr"),
                ("rlMultMatrixf", "matf", "array[16, $1]"),
              ]
            let pat = getReplacement(fnc.name, param.name, replacements)
            let kind = convertType(param.`type`, pat, false, true, baseKind)
            lit kind
      lit ")"
      if fnc.returnType != "void":
        lit ": "
        block outer:
          for (name, idx) in enumInFuncReturn.items:
            if name == fnc.name:
              lit enumInFuncs[idx]
              break outer
          var baseKind = ""
          const
            replacements = [
              ("rlGetShaderLocsDefault", "", "ShaderLocsPtr"),
              # ("rlReadScreenPixels", "", ""),
            ]
          let pat = getReplacement(fnc.name, "", replacements)
          let kind = convertType(fnc.returnType, pat, false, true, baseKind)
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
    lit "\n{.pop.}\n\n"
    for obj, field, kind in procProperties.items:
      lit "proc "
      ident field
      lit "*(x: "
      ident obj
      lit "): "
      lit kind
      lit " {.inline.} = x."
      ident field
      lit "\n"
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
