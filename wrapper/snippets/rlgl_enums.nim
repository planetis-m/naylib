
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

  FramebufferTarget* {.size: sizeof(int32).} = enum
    ReadFramebuffer = 0x8CA8 ## GL_READ_FRAMEBUFFER
    DrawFramebuffer = 0x8CA9 ## GL_DRAW_FRAMEBUFFER

  DefaultShaderLocationIndex* {.size: sizeof(int32).} = enum ## Default shader vertex attribute locations
    AttribPosition = 0
    AttribTexcoord
    AttribNormal
    AttribColor
    AttribTangent
    AttribTexcoord2
    AttribLocationBoneIds
    AttribLocationBoneWeights
    AttribLocationIndices

  DefaultShaderVariableName* = enum ## Default shader vertex attribute names to set location points
    AttribPosition = "vertexPosition" ## Bound by default to shader location: 0
    AttribTexcoord = "vertexTexCoord" ## Bound by default to shader location: 1
    AttribNormal = "vertexNormal" ## Bound by default to shader location: 2
    AttribColor = "vertexColor" ## Bound by default to shader location: 3
    AttribTangent = "vertexTangent" ## Bound by default to shader location: 4
    AttribTexcoord2 = "vertexTexCoord2" ## Bound by default to shader location: 5
    AttribLocationBoneIds = "vertexBoneIds" ## Bound by default to shader location: 6
    AttribLocationBoneWeights = "vertexBoneWeights" ## Bound by default to shader location: 7
    UniformMvp = "mvp" ## model-view-projection matrix
    UniformView = "matView" ## view matrix
    UniformProjection = "matProjection" ## projection matrix
    UniformModel = "matModel" ## model matrix
    UniformNormal = "matNormal" ## normal matrix (transpose(inverse(matModelView))
    UniformColor = "colDiffuse" ## color diffuse (base tint color, multiplied by texture color)
    UniformBoneMatrices = "boneMatrices" ## bone matrices
    Sampler2dTexture0 = "texture0" ## texture0 (texture slot active 0)
    Sampler2dTexture1 = "texture1" ## texture1 (texture slot active 1)
    Sampler2dTexture2 = "texture2" ## texture2 (texture slot active 2)

template BlendEquationRgb*(_: typedesc[BlendFuncOrEq]): untyped = BlendEquation

template VertexBufferIndicesType(): untyped =
  when not UseEmbeddedGraphicsApi:
    ptr UncheckedArray[uint32]
  else:
    ptr UncheckedArray[uint16]
