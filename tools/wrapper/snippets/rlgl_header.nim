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
  CullDistanceNear* = 0.05 ## Default near cull distance
  CullDistanceFar* = 4000.0 ## Default far cull distance

when not UseEmbeddedGraphicsApi:
  const DefaultBatchBufferElements* = 8192 ## This is the maximum amount of elements (quads) per batch
                                           ## NOTE: Be careful with text, every letter maps to a quad
else:
  const DefaultBatchBufferElements* = 2048 ## We reduce memory sizes for embedded systems (RPI and HTML5)
                                           ## NOTE: On HTML5 (emscripten) this is allocated on heap,
                                           ## by default it's only 16MB!...just take care...

type
  rlglLoadProc* = proc (name: cstring): pointer ## OpenGL extension functions loader signature (same as GLADloadproc)
