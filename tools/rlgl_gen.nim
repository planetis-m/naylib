import common, std/[streams, strutils]
when defined(nimPreviewSlimSystem):
  import std/syncio

const
  rlglHeader = """
from raylib import PixelFormat, TextureFilter, BlendMode, ShaderLocationIndex,
  ShaderUniformDataType, ShaderAttributeDataType, MaxShaderLocations, ShaderLocation,
  Matrix, Vector2, Vector3, Color, ShaderLocsPtr
export PixelFormat, TextureFilter, BlendMode, ShaderLocationIndex, ShaderUniformDataType,
  ShaderAttributeDataType, MaxShaderLocations, ShaderLocation, Matrix, Vector2, Vector3,
  Color, ShaderLocsPtr

# Security check in case no GraphicsApiOpenGl* defined
const
  UseEmbeddedGraphicsApi = defined(GraphicsApiOpenGlEs2) or defined(GraphicsApiOpenGlEs3)

const
  RlglVersion* = (5, 1, 0)

  DefaultBatchBuffers* = 1 ## Default number of batch buffers (multi-buffering)
  DefaultBatchDrawCalls* = 256 ## Default number of batch draw calls (by state changes: mode, texture)
  DefaultBatchMaxTextureUnits* = 4 ## Maximum number of textures units that can be activated on batch drawing
  MaxMatrixStackSize* = 32 ## Maximum size of Matrix stack
  # MaxShaderLocations* = 32 ## Maximum number of shader locations supported
  CullDistanceNear* = 0.01 ## Default near cull distance
  CullDistanceFar* = 1000.0 ## Default far cull distance

when not UseEmbeddedGraphicsApi:
  const DefaultBatchBufferElements* = 8192 ## This is the maximum amount of elements (quads) per batch
                                           ## NOTE: Be careful with text, every letter maps to a quad
else:
  const DefaultBatchBufferElements* = 2048 ## We reduce memory sizes for embedded systems (RPI and HTML5)
                                           ## NOTE: On HTML5 (emscripten) this is allocated on heap,
                                           ## by default it's only 16MB!...just take care...
"""
  types = """

type
  rlglLoadProc* = proc (name: cstring): pointer ## OpenGL extension functions loader signature (same as GLADloadproc)

  TextureParameter* {.size: sizeof(int32).} = enum ## Texture parameters (equivalent to OpenGL defines)
    FilterNearest = 0x2600 ## GL_NEAREST
    FilterLinear = 0x2601 ## GL_LINEAR
    FilterMipNearest = 0x2700 ## GL_NEAREST_MIPMAP_NEAREST
    FilterLinearMipNearest = 0x2701 ## GL_LINEAR_MIPMAP_NEAREST
    FilterNearestMipLinear = 0x2702 ## GL_NEAREST_MIPMAP_LINEAR
    FilterMipLinear = 0x2703 ## GL_LINEAR_MIPMAP_LINEAR
    MagFilter = 0x2800 ## GL_TEXTURE_MAG_FILTER
    MinFilter = 0x2801 ## GL_TEXTURE_MIN_FILTER
    WrapS = 0x2802 ## GL_TEXTURE_WRAP_S
    WrapT = 0x2803 ## GL_TEXTURE_WRAP_T
    WrapRepeat = 0x2901 ## GL_REPEAT
    FilterAnisotropic = 0x3000 ## Anisotropic filter (custom identifier)
    MipmapBiasRatio = 0x4000 ## Texture mipmap bias, percentage ratio (custom identifier)
    WrapClamp = 0x812F ## GL_CLAMP_TO_EDGE
    WrapMirrorRepeat = 0x8370 ## GL_MIRRORED_REPEAT
    WrapMirrorClamp = 0x8742 ## GL_MIRROR_CLAMP_EXT

  MatrixMode* {.size: sizeof(int32).} = enum ## Matrix modes (equivalent to OpenGL)
    Modelview = 0x1700 ## GL_MODELVIEW
    Projection = 0x1701 ## GL_PROJECTION
    Texture = 0x1702 ## GL_TEXTURE

  DrawMode* {.size: sizeof(int32).} = enum ## Primitive assembly draw modes
    Lines = 0x0001 ## GL_LINES
    Triangles = 0x0004 ## GL_TRIANGLES
    Quads = 0x0007 ## GL_QUADS

  GlType* {.size: sizeof(int32).} = enum ## GL equivalent data types
    UnsignedByte = 0x1401 ## GL_UNSIGNED_BYTE
    Float = 0x1406 ## GL_FLOAT

  BufferUsageHint* {.size: sizeof(int32).} = enum ## GL buffer usage hint
    StreamDraw = 0x88E0 ## GL_STREAM_DRAW
    StreamRead = 0x88E1 ## GL_STREAM_READ
    StreamCopy = 0x88E2 ## GL_STREAM_COPY
    StaticDraw = 0x88E4 ## GL_STATIC_DRAW
    StaticRead = 0x88E5 ## GL_STATIC_READ
    StaticCopy = 0x88E6 ## GL_STATIC_COPY
    DynamicDraw = 0x88E8 ## GL_DYNAMIC_DRAW
    DynamicRead = 0x88E9 ## GL_DYNAMIC_READ
    DynamicCopy = 0x88EA ## GL_DYNAMIC_COPY

  ShaderType* {.size: sizeof(int32).} = enum ## GL Shader type
    FragmentShader = 0x8B30 ## GL_FRAGMENT_SHADER
    VertexShader = 0x8B31 ## GL_VERTEX_SHADER
    ComputeShader = 0x91B9 ## GL_COMPUTE_SHADER

  BlendFactor* {.size: sizeof(int32).} = enum ## GL blending factors
    Zero ## GL_ZERO
    One ## GL_ONE
    SrcColor = 0x0300 ## GL_SRC_COLOR
    OneMinusSrcColor = 0x0301 ## GL_ONE_MINUS_SRC_COLOR
    SrcAlpha = 0x0302 ## GL_SRC_ALPHA
    OneMinusSrcAlpha = 0x0303 ## GL_One_MINUS_SRC_ALPHA
    DstAlpha = 0x0304 ## GL_DST_ALPHA
    OneMinusDstAlpha = 0x0305 ## GL_ONE_MINUS_DST_ALPHA
    DstColor = 0x0306 ## GL_DST_COLOR
    OneMinusDstColor = 0x0307 ## GL_ONE_MINUS_DST_COLOR
    SrcAlphaSaturate = 0x0308 ## GL_SRC_ALPHA_SATURATE
    ConstantColor = 0x8001 ## GL_CONSTANT_COLOR
    OneMinusConstantColor = 0x8002 ## GL_ONE_MINUS_CONSTANT_COLOR
    ConstantAlpha = 0x8003 ## GL_CONSTANT_ALPHA
    OneMinusConstantAlpha = 0x8004 ## GL_ONE_MINUS_CONSTANT_ALPHA

  BlendFuncOrEq* {.size: sizeof(int32).} = enum ## GL blending functions/equations
    BlendColor = 0x8005 ## GL_BLEND_COLOR
    FuncAdd = 0x8006 ## GL_FUNC_ADD
    Min = 0x8007 ## GL_MIN
    Max = 0x8008 ## GL_MAX
    BlendEquation = 0x8009 ## GL_BLEND_EQUATION
    FuncSubtract = 0x800A ## GL_FUNC_SUBTRACT
    FuncReverseSubtract = 0x800B ## GL_FUNC_REVERSE_SUBTRACT
    BlendDstRgb = 0x80C8 ## GL_BLEND_DST_RGB
    BlendSrcRgb = 0x80C9 ## GL_BLEND_SRC_RGB
    BlendDstAlpha = 0x80CA ## GL_BLEND_DST_ALPHA
    BlendSrcAlpha = 0x80CB ## GL_BLEND_SRC_ALPHA
    BlendEquationAlpha = 0x883D ## GL_BLEND_EQUATION_ALPHA

  DefaultShaderVariableName* = enum ## Default shader vertex attribute names to set location points
    AttribPosition = "vertexPosition" ## Binded by default to shader location: 0
    AttribTexcoord = "vertexTexCoord" ## Binded by default to shader location: 1
    AttribNormal = "vertexNormal" ## Binded by default to shader location: 2
    AttribColor = "vertexColor" ## Binded by default to shader location: 3
    AttribTangent = "vertexTangent" ## Binded by default to shader location: 4
    AttribTexcoord2 = "vertexTexCoord2" ## Binded by default to shader location: 5
    UniformMvp = "mvp" ## model-view-projection matrix
    UniformView = "matView" ## view matrix
    UniformProjection = "matProjection" ## projection matrix
    UniformModel = "matModel" ## model matrix
    UniformNormal = "matNormal" ## normal matrix (transpose(inverse(matModelView))
    UniformColor = "colDiffuse" ## color diffuse (base tint color, multiplied by texture color)
    Sampler2dTexture0 = "texture0" ## texture0 (texture slot active 0)
    Sampler2dTexture1 = "texture1" ## texture1 (texture slot active 1)
    Sampler2dTexture2 = "texture2" ## texture2 (texture slot active 2)
"""
  helpers = """

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
  excludedFuncs = [
    "rlGetPixelFormatName",
  ]
  excludedTypes = [
    "Matrix",
    "rlglData"
  ]
  enumInFuncReturn = [
    ("rlGetLocationUniform", 19),
    ("rlGetLocationAttrib", 19),
    ("rlGetVersion", 32),
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
    "BlendFuncOrEq",
    "BlendFuncOrEq",
    "BlendFuncOrEq",
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
    lit "template BlendEquationRgb*(_: typedesc[BlendFuncOrEq]): untyped = BlendEquation"
    var procProperties: seq[(string, string, string)] = @[]
    var procArrays: seq[(string, string, string)] = @[]
    lit "\n\ntype"
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
              lit "when not UseEmbeddedGraphicsApi:"
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
              lit "else:"
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
      if fnc.name in excludedFuncs: continue
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
  rlglApi = "../api/rlgl.json"
  outputname = "../src/rlgl.nim"

proc main =
  var t = parseApi(rlglApi)
  genBindings(t, outputname, rlglHeader, helpers)

main()
