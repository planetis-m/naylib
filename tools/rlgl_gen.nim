import common, std/[streams, strutils]
when defined(nimPreviewSlimSystem):
  import std/syncio

const
  rlglHeader = """
from raylib import PixelFormat, TextureFilter, BlendMode, ShaderLocationIndex,
  ShaderUniformDataType, ShaderAttributeDataType, MaxShaderLocations, Matrix
export PixelFormat, TextureFilter, BlendMode, ShaderLocationIndex, ShaderUniformDataType,
  ShaderAttributeDataType

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
  MaxShaderLocations = 32 ## Maximum number of shader locations supported
  CullDistanceNear = 0.01 ## Default near cull distance
  CullDistanceFar = 1000.0 ## Default far cull distance

  # Texture parameters (equivalent to OpenGL defines)
  TextureWrapS = 0x2802.TextureParameter ## GL_TEXTURE_WRAP_S
  TextureWrapT = 0x2803.TextureParameter ## GL_TEXTURE_WRAP_T
  TextureMagFilter = 0x2800.TextureParameter ## GL_TEXTURE_MAG_FILTER
  TextureMinFilter = 0x2801.TextureParameter ## GL_TEXTURE_MIN_FILTER

  TextureFilterNEAREST = 0x2600.TextureParameter ## GL_NEAREST
  TextureFilterLINEAR = 0x2601.TextureParameter ## GL_LINEAR
  TextureFilterMIP_NEAREST = 0x2700.TextureParameter ## GL_NEAREST_MIPMAP_NEAREST
  TextureFilterNEAREST_MIP_LINEAR = 0x2702.TextureParameter ## GL_NEAREST_MIPMAP_LINEAR
  TextureFilterLINEAR_MIP_NEAREST = 0x2701.TextureParameter ## GL_LINEAR_MIPMAP_NEAREST
  TextureFilterMIP_LINEAR = 0x2703.TextureParameter ## GL_LINEAR_MIPMAP_LINEAR
  TextureFilterANISOTROPIC = 0x3000.TextureParameter ## Anisotropic filter (custom identifier)
  TextureMipmapBIAS_RATIO = 0x4000.TextureParameter ## Texture mipmap bias, percentage ratio (custom identifier)

  TextureWrapRepeat = 0x2901.TextureParameter ## GL_REPEAT
  TextureWrapClamp = 0x812F.TextureParameter ## GL_CLAMP_TO_EDGE
  TextureWrapMirrorRepeat = 0x8370.TextureParameter ## GL_MIRRORED_REPEAT
  TextureWrapMirrorClamp = 0x8742.TextureParameter ## GL_MIRROR_CLAMP_EXT

  # Matrix modes (equivalent to OpenGL)
  MatrixModelview = 0x1700.MatrixMode ## GL_MODELVIEW
  MatrixProjection = 0x1701.MatrixMode ## GL_PROJECTION
  MatrixTexture = 0x1702.MatrixMode ## GL_TEXTURE

  # Primitive assembly draw modes
  DrawLines = 0x0001.DrawMode ## GL_LINES
  DrawTriangles = 0x0004.DrawMode ## GL_TRIANGLES
  DrawQuads = 0x0007.DrawMode ## GL_QUADS

  # GL equivalent data types
  GlUnsignedByte = 0x1401.GlType ## GL_UNSIGNED_BYTE
  GlFloat = 0x1406.GlType ## GL_FLOAT

  # Buffer usage hint
  UsageStreamDraw = 0x88E0.BufferUsageHint ## GL_STREAM_DRAW
  UsageStreamRead = 0x88E1.BufferUsageHint ## GL_STREAM_READ
  UsageStreamCopy = 0x88E2.BufferUsageHint ## GL_STREAM_COPY
  UsageStaticDraw = 0x88E4.BufferUsageHint ## GL_STATIC_DRAW
  UsageStaticRead = 0x88E5.BufferUsageHint ## GL_STATIC_READ
  UsageStaticCopy = 0x88E6.BufferUsageHint ## GL_STATIC_COPY
  UsageDynamicDraw = 0x88E8.BufferUsageHint ## GL_DYNAMIC_DRAW
  UsageDynamicRead = 0x88E9.BufferUsageHint ## GL_DYNAMIC_READ
  UsageDynamicCopy = 0x88EA.BufferUsageHint ## GL_DYNAMIC_COPY

  # GL Shader type
  FragmentShader = 0x8B30.ShaderType ## GL_FRAGMENT_SHADER
  VertexShader = 0x8B31.ShaderType ## GL_VERTEX_SHADER
  ComputeShader = 0x91B9.ShaderType ## GL_COMPUTE_SHADER
"""
  helpers = """
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
    lit "\ntype"
    scope:
      for obj in items(t.structs):
        if obj.name in excludedTypes: continue
        spaces
        var name = obj.name
        if name != "rlglData":
          removePrefix(name, "rl")
        ident capitalizeAscii(name)
        lit "* {.bycopy.} = object"
        doc obj
        scope:
          for fld in items(obj.fields):
            spaces
            var name = fld.name
            ident name
            lit "*: "
            # let kind = getReplacement(obj.name, name, replacement)
            # if kind != "":
            #   lit kind
            #   continue
            var baseKind = ""
            let kind = convertType(fld.`type`, "", false, false, baseKind)
            lit kind
            doc fld
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
