import common, std/[algorithm, streams, sets, tables]
import std/strutils except spaces
when defined(nimPreviewSlimSystem):
  import std/syncio

const
  extraTypes = [
    """rAudioBuffer {.importc, nodecl, bycopy.} = object""",
    """rAudioProcessor {.importc, nodecl, bycopy.} = object"""
  ]
  raylibHeader = """
from std/strutils import addf, toHex
from std/unicode import Rune
from std/syncio import writeFile
import std/[assertions, paths]
const raylibDir = currentSourcePath().Path.parentDir / Path"raylib"

{.passC: "-I" & raylibDir.string.}
{.passC: "-I" & string(raylibDir / Path"external/glfw/include").}
{.passC: "-I" & string(raylibDir / Path"external/glfw/deps/mingw").}
{.passC: "-Wall -D_GNU_SOURCE -Wno-missing-braces -Werror=pointer-arith".}
when defined(emscripten):
  {.passC: "-DPLATFORM_WEB".}
  when defined(GraphicsApiOpenGlEs3):
    {.passC: "-DGRAPHICS_API_OPENGL_ES3".}
    {.passL: "-sFULL_ES3 -sMAX_WEBGL_VERSION=2".}
  else: {.passC: "-DGRAPHICS_API_OPENGL_ES2".}
  {.passL: "-sUSE_GLFW=3 -sWASM=1 -sTOTAL_MEMORY=67108864".} # 64MiB
  {.passL: "-sEXPORTED_RUNTIME_METHODS=ccall".}
  when compileOption("threads"):
    const NaylibWebPthreadPoolSize {.intdefine.} = 2
    {.passL: "-sPTHREAD_POOL_SIZE=" & $NaylibWebPthreadPoolSize.}
  when defined(NaylibWebAsyncify): {.passL: "-sASYNCIFY".}
  when defined(NaylibWebResources):
    const NaylibWebResourcesPath {.strdefine.} = "resources"
    {.passL: "-sFORCE_FILESYSTEM=1 --preload-file " & NaylibWebResourcesPath.}

  type emCallbackFunc* = proc() {.cdecl.}
  proc emscriptenSetMainLoop*(f: emCallbackFunc, fps, simulateInfiniteLoop: int32) {.
      cdecl, importc: "emscripten_set_main_loop", header: "<emscripten.h>".}

elif defined(android):
  const AndroidNdk {.strdefine.} = "/opt/android-ndk"
  const ProjectLibraryName = "main"
  {.passC: "-I" & string(AndroidNdk.Path / Path"sources/android/native_app_glue").}

  {.passC: "-DPLATFORM_ANDROID".}
  when defined(GraphicsApiOpenGlEs3): {.passC: "-DGRAPHICS_API_OPENGL_ES3".}
  else: {.passC: "-DGRAPHICS_API_OPENGL_ES2".}
  {.passC: "-ffunction-sections -funwind-tables -fstack-protector-strong -fPIE -fPIC".}
  {.passC: "-Wa,--noexecstack -Wformat -no-canonical-prefixes".}

  {.passL: "-Wl,-soname,lib" & ProjectLibraryName & ".so -Wl,--exclude-libs,libatomic.a".}
  {.passL: "-Wl,--build-id -Wl,-z,noexecstack -Wl,-z,relro -Wl,-z,now -Wl,--warn-shared-textrel".}
  {.passL: "-Wl,--fatal-warnings -u ANativeActivity_onCreate -Wl,-no-undefined".}
  {.passL: "-llog -landroid -lEGL -lGLESv2 -lOpenSLES -lc -lm -ldl".}

else:
  {.passC: "-DPLATFORM_DESKTOP_GLFW".}
  when defined(GraphicsApiOpenGl11): {.passC: "-DGRAPHICS_API_OPENGL_11".}
  elif defined(GraphicsApiOpenGl21): {.passC: "-DGRAPHICS_API_OPENGL_21".}
  elif defined(GraphicsApiOpenGl43): {.passC: "-DGRAPHICS_API_OPENGL_43".}
  elif defined(GraphicsApiOpenGlEs2): {.passC: "-DGRAPHICS_API_OPENGL_ES2".}
  elif defined(GraphicsApiOpenGlEs3): {.passC: "-DGRAPHICS_API_OPENGL_ES3".}
  else: {.passC: "-DGRAPHICS_API_OPENGL_33".}

  when defined(windows):
    when defined(tcc): {.passL: "-lopengl32 -lgdi32 -lwinmm -lshell32".}
    else: {.passL: "-static-libgcc -lopengl32 -lgdi32 -lwinmm".}

  elif defined(macosx):
    {.passL: "-framework OpenGL -framework Cocoa -framework IOKit -framework CoreAudio -framework CoreVideo".}

  elif defined(drm):
    {.passC: staticExec("pkg-config libdrm --cflags").}
    {.passC: "-DPLATFORM_DRM -DGRAPHICS_API_OPENGL_ES2 -DEGL_NO_X11".}
    # pkg-config glesv2 egl libdrm gbm --libs
    # nanosleep: -lrt, miniaudio linux 32bit ARM: -ldl -lpthread -lm -latomic
    {.passL: "-lGLESv2 -lEGL -ldrm -lgbm -lrt -ldl -lpthread -lm -latomic".}

  else:
    when defined(linux):
      {.passC: "-fPIC".}
      {.passL: "-lGL -lrt -lm -lpthread -ldl".} # pkg-config gl --libs, nanosleep, miniaudio linux

    elif defined(bsd):
      {.passC: staticExec("pkg-config ossaudio --variable=includedir").}
      {.passL: "-lGL -lrt -lossaudio -lpthread -lm -ldl".} # pkg-config gl ossaudio --libs, nanosleep, miniaudio BSD

    when defined(wayland):
      {.passC: "-D_GLFW_WAYLAND".}
      # pkg-config wayland-client wayland-cursor wayland-egl xkbcommon --libs
      {.passL: "-lwayland-client -lwayland-cursor -lwayland-egl -lxkbcommon".}
      const wlProtocolsDir = raylibDir / Path"external/glfw/deps/wayland"

      proc wlGenerate(protocol: Path, basename: string) =
        discard staticExec("wayland-scanner client-header " & protocol.string & " " &
            string(raylibDir / Path(basename & ".h")))
        discard staticExec("wayland-scanner private-code " & protocol.string & " " &
            string(raylibDir / Path(basename & "-code.h")))

      static:
        wlGenerate(wlProtocolsDir / Path"wayland.xml", "wayland-client-protocol")
        wlGenerate(wlProtocolsDir / Path"xdg-shell.xml", "xdg-shell-client-protocol")
        wlGenerate(wlProtocolsDir / Path"xdg-decoration-unstable-v1.xml",
            "xdg-decoration-unstable-v1-client-protocol")
        wlGenerate(wlProtocolsDir / Path"viewporter.xml", "viewporter-client-protocol")
        wlGenerate(wlProtocolsDir / Path"relative-pointer-unstable-v1.xml",
            "relative-pointer-unstable-v1-client-protocol")
        wlGenerate(wlProtocolsDir / Path"pointer-constraints-unstable-v1.xml",
            "pointer-constraints-unstable-v1-client-protocol")
        wlGenerate(wlProtocolsDir / Path"fractional-scale-v1.xml", "fractional-scale-v1-client-protocol")
        wlGenerate(wlProtocolsDir / Path"xdg-activation-v1.xml", "xdg-activation-v1-client-protocol")
        wlGenerate(wlProtocolsDir / Path"idle-inhibit-unstable-v1.xml",
            "idle-inhibit-unstable-v1-client-protocol")

    else:
      {.passC: "-D_GLFW_X11".}
      # pkg-config x11 xrandr xinerama xi xcursor --libs
      {.passL: "-lX11 -lXrandr -lXinerama -lXi -lXcursor".}

when defined(emscripten): discard
elif defined(android): discard
elif defined(macosx): {.compile(raylibDir / Path"rglfw.c", "-x objective-c").}
else: {.compile: raylibDir / Path"rglfw.c".}
{.compile: raylibDir / Path"rshapes.c".}
{.compile: raylibDir / Path"rtextures.c".}
{.compile: raylibDir / Path"rtext.c".}
{.compile: raylibDir / Path"utils.c".}
{.compile: raylibDir / Path"rmodels.c".}
{.compile: raylibDir / Path"raudio.c".}
{.compile: raylibDir / Path"rcore.c".}
when defined(android):
  {.compile: AndroidNdk.Path / Path"sources/android/native_app_glue/android_native_app_glue.c".}

const
  RaylibVersion* = (5, 5, 0)

  # Taken from raylib/src/config.h
  MaxShaderLocations* = 32 ## Maximum number of shader locations supported
  MaxMaterialMaps* = 12 ## Maximum number of shader maps supported
  MaxMeshVertexBuffers* = 7 ## Maximum vertex buffers (VBO) per mesh
"""
  extraDistinct = """
  ShaderLocation* = distinct int32 ## Shader location

  FlagsEnum = ConfigFlags|Gesture
  Flags*[E: FlagsEnum] = distinct uint32

proc flags*[E: FlagsEnum](e: varargs[E]): Flags[E] {.inline.} =
  var res: uint32 = 0
  for val in items(e):
    res = res or uint32(val)
  Flags[E](res)

template Diffuse*(_: typedesc[MaterialMapIndex]): untyped = Albedo
template Specular*(_: typedesc[MaterialMapIndex]): untyped = Metalness

template MapDiffuse*(_: typedesc[ShaderLocationIndex]): untyped = MapAlbedo
template MapSpecular*(_: typedesc[ShaderLocationIndex]): untyped = MapMetalness
"""
  helpers = """

type va_list {.importc: "va_list", header: "<stdarg.h>".} = object ## Only used by TraceLogCallback
proc vsprintf(s: cstring, format: cstring, args: va_list) {.cdecl, importc: "vsprintf", header: "<stdio.h>".}

type
  ConstCstring {.importc: "const char *".} = cstring

## Callbacks to hook some internal functions
## WARNING: This callbacks are intended for advance users
type
  TraceLogCallbackImpl = proc (logLevel: int32; text: ConstCstring; args: va_list) {.
      cdecl.}
  LoadFileDataCallback* = proc (fileName: ConstCstring; bytesRead: ptr uint32): ptr UncheckedArray[uint8] {.
      cdecl.} ## FileIO: Load binary data
  SaveFileDataCallback* = proc (fileName: ConstCstring; data: pointer; bytesToWrite: uint32): bool {.
      cdecl.} ## FileIO: Save binary data
  LoadFileTextCallback* = proc (fileName: ConstCstring): cstring {.cdecl.} ## FileIO: Load text data
  SaveFileTextCallback* = proc (fileName: ConstCstring; text: cstring): bool {.cdecl.} ## FileIO: Save text data
  AudioCallback* = proc (bufferData: pointer, frames: uint32) {.cdecl.} ## Audio thread callback to request new data

const
  LightGray* = Color(r: 200, g: 200, b: 200, a: 255)
  Gray* = Color(r: 130, g: 130, b: 130, a: 255)
  DarkGray* = Color(r: 80, g: 80, b: 80, a: 255)
  Yellow* = Color(r: 253, g: 249, b: 0, a: 255)
  Gold* = Color(r: 255, g: 203, b: 0, a: 255)
  Orange* = Color(r: 255, g: 161, b: 0, a: 255)
  Pink* = Color(r: 255, g: 109, b: 194, a: 255)
  Red* = Color(r: 230, g: 41, b: 55, a: 255)
  Maroon* = Color(r: 190, g: 33, b: 55, a: 255)
  Green* = Color(r: 0, g: 228, b: 48, a: 255)
  Lime* = Color(r: 0, g: 158, b: 47, a: 255)
  DarkGreen* = Color(r: 0, g: 117, b: 44, a: 255)
  SkyBlue* = Color(r: 102, g: 191, b: 255, a: 255)
  Blue* = Color(r: 0, g: 121, b: 241, a: 255)
  DarkBlue* = Color(r: 0, g: 82, b: 172, a: 255)
  Purple* = Color(r: 200, g: 122, b: 255, a: 255)
  Violet* = Color(r: 135, g: 60, b: 190, a: 255)
  DarkPurple* = Color(r: 112, g: 31, b: 126, a: 255)
  Beige* = Color(r: 211, g: 176, b: 131, a: 255)
  Brown* = Color(r: 127, g: 106, b: 79, a: 255)
  DarkBrown* = Color(r: 76, g: 63, b: 47, a: 255)
  White* = Color(r: 255, g: 255, b: 255, a: 255)
  Black* = Color(r: 0, g: 0, b: 0, a: 255)
  Blank* = Color(r: 0, g: 0, b: 0, a: 0)
  Magenta* = Color(r: 255, g: 0, b: 255, a: 255)
  RayWhite* = Color(r: 245, g: 245, b: 245, a: 255)
"""
  enumInFuncReturn = toTable({
    "GetKeyPressed": "KeyboardKey",
    "GetGamepadButtonPressed": "GamepadButton",
    "GetGestureDetected": "Gesture",
    "GetShaderLocation": "ShaderLocation",
    "GetShaderLocationAttrib": "ShaderLocation",
  })
  enumInFuncParams = toTable({
    ("IsKeyPressed", "key"): "KeyboardKey",
    ("IsKeyPressedRepeat", "key"): "KeyboardKey",
    ("IsKeyDown", "key"): "KeyboardKey",
    ("IsKeyReleased", "key"): "KeyboardKey",
    ("IsKeyUp", "key"): "KeyboardKey",
    ("SetExitKey", "key"): "KeyboardKey",
    ("SetCameraAltControl", "keyAlt"): "KeyboardKey",
    ("SetCameraSmoothZoomControl", "keySmoothZoom"): "KeyboardKey",
    ("SetCameraMoveControls", "keyFront"): "KeyboardKey",
    ("SetCameraMoveControls", "keyBack"): "KeyboardKey",
    ("SetCameraMoveControls", "keyRight"): "KeyboardKey",
    ("SetCameraMoveControls", "keyLeft"): "KeyboardKey",
    ("SetCameraMoveControls", "keyUp"): "KeyboardKey",
    ("SetCameraMoveControls", "keyDown"): "KeyboardKey",
    ("IsGamepadButtonPressed", "button"): "GamepadButton",
    ("IsGamepadButtonDown", "button"): "GamepadButton",
    ("IsGamepadButtonReleased", "button"): "GamepadButton",
    ("IsGamepadButtonUp", "button"): "GamepadButton",
    ("GetGamepadAxisMovement", "axis"): "GamepadAxis",
    ("SetMouseCursor", "cursor"): "MouseCursor",
    ("IsMouseButtonPressed", "button"): "MouseButton",
    ("IsMouseButtonDown", "button"): "MouseButton",
    ("IsMouseButtonReleased", "button"): "MouseButton",
    ("IsMouseButtonUp", "button"): "MouseButton",
    ("SetCameraPanControl", "keyPan"): "MouseButton",
    ("SetGesturesEnabled", "flags"): "Flags[Gesture]",
    ("IsGestureDetected", "gesture"): "Gesture",
    ("SetConfigFlags", "flags"): "Flags[ConfigFlags]",
    ("SetWindowState", "flags"): "Flags[ConfigFlags]",
    ("ClearWindowState", "flags"): "Flags[ConfigFlags]",
    ("IsWindowState", "flag"): "ConfigFlags",
    ("TraceLog", "logLevel"): "TraceLogLevel",
    ("SetTraceLogLevel", "logLevel"): "TraceLogLevel",
    ("UpdateCamera", "mode"): "CameraMode",
    ("BeginBlendMode", "mode"): "BlendMode",
    ("SetMaterialTexture", "mapType"): "MaterialMapIndex",
    ("SetShaderValue", "locIndex"): "ShaderLocation",
    ("SetShaderValueV", "locIndex"): "ShaderLocation",
    ("SetShaderValueMatrix", "locIndex"): "ShaderLocation",
    ("SetShaderValueTexture", "locIndex"): "ShaderLocation",
    ("SetShaderValue", "uniformType"): "ShaderUniformDataType",
    ("SetShaderValueV", "uniformType"): "ShaderUniformDataType",
    ("LoadImageRaw", "format"): "PixelFormat",
    ("ImageFormat", "newFormat"): "PixelFormat",
    ("GetPixelColor", "format"): "PixelFormat",
    ("SetPixelColor", "format"): "PixelFormat",
    ("GetPixelDataSize", "format"): "PixelFormat",
    ("SetTextureFilter", "filter"): "TextureFilter",
    ("SetTextureWrap", "wrap"): "TextureWrap",
    ("LoadTextureCubemap", "layout"): "CubemapLayout",
    ("LoadFontData", "type"): "FontType",
    ("DrawTextCodepoint", "codepoint"): "Rune",
    ("GetGlyphIndex", "codepoint"): "Rune",
    ("GetGlyphInfo", "codepoint"): "Rune",
    ("GetGlyphAtlasRec", "codepoint"): "Rune"
  })
  excludedFuncs = toHashSet([
    "ColorIsEqual",
    # Text strings management functions
    "TextCopy",
    "TextIsEqual",
    "TextLength",
    "TextFormat",
    "TextSubtext",
    "TextReplace",
    "TextInsert",
    "TextJoin",
    "TextSplit",
    "TextAppend",
    "TextFindIndex",
    "TextToUpper",
    "TextToLower",
    "TextToPascal",
    "TextToInteger",
    "TextToFloat",
    "TextToSnake",
    "TextToCamel",
    # Misc
    "GetRandomValue",
    "SetRandomSeed",
    "LoadRandomSequence",
    "UnloadRandomSequence",
    "OpenURL",
    "Fade",
    "ColorToInt",
    "GetColor",
    # Files management functions
    "ExportDataAsCode",
    "LoadFileData",
    "UnloadFileData",
    "SaveFileData",
    "LoadFileText",
    "UnloadFileText",
    "SaveFileText",
    "FileExists",
    "IsFileNameValid",
    "DirectoryExists",
    "IsFileExtension",
    "GetFileExtension",
    "GetFileName",
    "GetFileLength",
    "GetFileNameWithoutExt",
    "GetDirectoryPath",
    "GetPrevDirectoryPath",
    "GetWorkingDirectory",
    "GetApplicationDirectory",
    "GetDirectoryFiles",
    "MakeDirectory",
    "ChangeDirectory",
    "GetFileModTime",
    "IsPathFile",
    "UnloadDirectoryFiles",
    "LoadDirectoryFiles",
    "LoadDirectoryFilesEx",
    # Compression/Encoding functionality
    "CompressData",
    "DecompressData",
    "EncodeDataBase64",
    "DecodeDataBase64",
    # Text codepoints management functions (unicode characters)
    "LoadCodepoints",
    "UnloadCodepoints",
    "GetCodepoint",
    "GetCodepointCount",
    "GetCodepointPrevious",
    "GetCodepointNext",
    "CodepointToUTF8",
    "LoadUTF8",
    "UnloadUTF8",
    # Setters
    "SetMaterialTexture",
    "SetModelMeshMaterial",
    # MemFree
    "UnloadImageColors",
    "UnloadImagePalette",
    "UnloadFontData",
    "UnloadModelAnimations",
    "UnloadWaveSamples",
  ])
  allocFuncs = toHashSet([
    "MemAlloc",
    "MemRealloc",
    "MemFree",
    "UnloadVrStereoConfig",
    "UnloadShader",
    "UnloadImage",
    "UnloadTexture",
    "UnloadRenderTexture",
    "UnloadFont",
    "UnloadModel",
    "UnloadMesh",
    "UnloadMaterial",
    "UnloadModelAnimation",
    "UnloadWave",
    "UnloadSound",
    "UnloadSoundAlias",
    "UnloadMusicStream",
    "UnloadAudioStream",
  ])
  privateFuncs = toHashSet([
    "InitWindow",
    "UpdateTexture",
    "UpdateTextureRec",
    "GetPixelColor",
    "SetPixelColor",
    "LoadShader",
    "LoadShaderFromMemory",
    "SetShaderValue",
    "SetShaderValueV",
    "LoadModelAnimations",
    "LoadWaveSamples",
    "LoadImagePalette",
    "LoadImage",
    "LoadImageRaw",
    "LoadImageSvg",
    "LoadImageFromMemory",
    "ExportImageToMemory",
    "LoadImageColors",
    "SetTraceLogCallback",
    "LoadFontData",
    "LoadMaterials",
    "LoadImageFromTexture",
    "LoadTextureFromImage",
    "LoadTextureCubemap",
    "LoadTexture",
    "LoadRenderTexture",
    "LoadImageAnim",
    "LoadImageAnimFromMemory",
    "LoadFont",
    "LoadFontEx",
    "LoadFontFromImage",
    "LoadFontFromMemory",
    "GenImageFontAtlas",
    "DrawMeshInstanced",
    "DrawTextCodepoints",
    "LoadModel",
    "LoadModelFromMesh",
    "LoadWave",
    "LoadSound",
    "LoadSoundAlias",
    "LoadSoundFromWave",
    "LoadWaveFromMemory",
    "LoadMusicStream",
    "LoadMusicStreamFromMemory",
    "LoadDroppedFiles",
    "UnloadDroppedFiles",
    "UpdateMeshBuffer",
    "UpdateSound",
    "LoadAudioStream",
    "UpdateAudioStream",
  ])
  nosideeffectsFuncs = toHashSet([
    "CheckCollisionCircleLine",
    "UpdateModelAnimationBoneMatrices",
    "GenImageText",
    "GenImageFontAtlas",
    "GetMeshBoundingBox",
    "IsModelAnimationValid",
    "IsSoundReady",
    "IsMaterialReady",
    "IsShaderReady",
    "GetWorldToScreen2D",
    "GetScreenToWorld2D",
    "GetCameraMatrix",
    "GetCameraMatrix2D",
    "GetSplinePointLinear",
    "GetSplinePointBasis",
    "GetSplinePointCatmullRom",
    "GetSplinePointBezierQuad",
    "GetSplinePointBezierCubic",
    "CheckCollisionRecs",
    "CheckCollisionCircles",
    "CheckCollisionCircleRec",
    "CheckCollisionPointRec",
    "CheckCollisionPointCircle",
    "CheckCollisionPointTriangle",
    "CheckCollisionPointPoly",
    "CheckCollisionLines",
    "CheckCollisionPointLine",
    "GetCollisionRec",
    "IsImageReady",
    "GenImageColor",
    "GenImageGradientLinear",
    "GenImageGradientRadial",
    "GenImageGradientSquare",
    "GenImageChecked",
    "GenImageWhiteNoise",
    "GenImagePerlinNoise",
    "GenImageCellular",
    "GenImageText",
    "ImageCopy",
    "ImageFromImage",
    "ImageText",
    "ImageTextEx",
    "ImageFormat",
    "ImageFromChannel",
    "ImageKernelConvolution",
    "ImageToPOT",
    "ImageCrop",
    "ImageAlphaCrop",
    "ImageAlphaClear",
    "ImageAlphaMask",
    "ImageAlphaPremultiply",
    "ImageBlurGaussian",
    "ImageResize",
    "ImageResizeNN",
    "ImageResizeCanvas",
    "ImageMipmaps",
    "ImageDither",
    "ImageFlipVertical",
    "ImageFlipHorizontal",
    "ImageRotate",
    "ImageRotateCW",
    "ImageRotateCCW",
    "ImageColorTint",
    "ImageColorInvert",
    "ImageColorGrayscale",
    "ImageColorContrast",
    "ImageColorBrightness",
    "ImageColorReplace",
    "GetImageAlphaBorder",
    "GetImageColor",
    "ImageClearBackground",
    "ImageDrawPixel",
    "ImageDrawPixelV",
    "ImageDrawLine",
    "ImageDrawLineV",
    "ImageDrawLineEx",
    "ImageDrawTriangle",
    "ImageDrawTriangleEx",
    "ImageDrawTriangleLines",
    "ImageDrawTriangleFan",
    "ImageDrawTriangleStrip",
    "ImageDrawCircle",
    "ImageDrawCircleV",
    "ImageDrawCircleLines",
    "ImageDrawCircleLinesV",
    "ImageDrawRectangle",
    "ImageDrawRectangleV",
    "ImageDrawRectangleRec",
    "ImageDrawRectangleLines",
    "ImageDraw",
    "ImageDrawText",
    "ImageDrawTextEx",
    "IsTextureReady",
    "IsRenderTextureReady",
    "ColorNormalize",
    "ColorFromNormalized",
    "ColorToHSV",
    "ColorFromHSV",
    "ColorTint",
    "ColorLerp",
    "ColorBrightness",
    "ColorContrast",
    "ColorAlpha",
    "ColorAlphaBlend",
    "GetPixelDataSize",
    "IsFontReady",
    "MeasureTextEx",
    "GetGlyphIndex",
    "GetGlyphInfo",
    "GetGlyphAtlasRec",
    "IsModelReady",
    "CheckCollisionSpheres",
    "CheckCollisionBoxes",
    "CheckCollisionBoxSphere",
    "GetRayCollisionSphere",
    "GetRayCollisionBox",
    "GetRayCollisionMesh",
    "GetRayCollisionTriangle",
    "GetRayCollisionQuad",
    "IsAudioDeviceReady",
    "IsWaveReady",
    "WaveCopy",
    "WaveCrop",
    "WaveFormat",
    "IsMusicReady",
    "GetMusicTimeLength",
    "IsAudioStreamReady",
  ])
  needErrorChecking = toHashSet([
    "Window",
    "Shader",
    "Image",
    "Texture2D",
    "RenderTexture2D",
    "Font",
    "Model",
    "Material",
    "Wave",
    "Sound",
    "Music",
    "AudioStream"
  ])

type
  PropertyInfo = object
    struct, field, `type`: string

proc preprocessStructs(structs: var seq[StructInfo];
                       procProperties, procArrays: var seq[PropertyInfo]) =
  proc isPrivateField(obj: StructInfo, fld: FieldInfo): bool =
    (obj.name, fld.name) notin {"Wave": "frameCount", "Sound": "frameCount", "Music": "frameCount"} and
    fld.name.endsWith("Count")

  proc isArrayField(obj: StructInfo, fld: FieldInfo, isPlural: bool): bool =
    isPlural and not endsWith(fld.name.normalize, "data") and
    (obj.name, fld.name) notin {
      "Material": "params",
      "VrDeviceInfo": "lensDistortionValues",
      "FilePathList": "paths",
      "AutomationEvent": "params",
      "AutomationEventList": "events"
    }

  proc shouldUsePluralType(obj: StructInfo, fld: FieldInfo): bool =
    result = isPlural(fld.name)
    if fld.name in ["mipmaps", "channels"]:
      result = false
    elif (obj.name, fld.name) in {"Model": "meshMaterial", "Model": "bindPose", "Mesh": "vboId"}:
      result = true

  proc shouldBePrivate(obj: StructInfo, fld: FieldInfo, isArray, isPrivate: bool): bool =
    isPrivate or isArray or
    obj.name in ["FilePathList", "AutomationEventList"] or
    (obj.name, fld.name) in {
      "MaterialMap": "texture",
      "Material": "shader",
      "AudioStream": "buffer",
      "AudioStream": "processor"
    }

  for obj in mitems(structs):
    if obj.name in ["Color", "Vector2", "Vector3", "Vector4"]:
      obj.flags.incl isCompleteStruct
    if obj.name == "FilePathList":
      obj.flags.incl isPrivate

    for fld in mitems(obj.fields):
      if isPrivateField(obj, fld):
        fld.flags.incl isPrivate
      const replacements = [
        ("Camera3D", "projection", "CameraProjection"),
        ("Image", "format", "PixelFormat"),
        ("Texture", "format", "PixelFormat"),
        ("NPatchInfo", "layout", "NPatchLayout"),
        ("Shader", "locs", "ptr UncheckedArray[ShaderLocation]")
      ]
      var fieldType = getReplacement(obj.name, fld.name, replacements)
      var baseType = ""
      let many = shouldUsePluralType(obj, fld)
      if fieldType == "":
        const replacements = [
          ("ModelAnimation", "framePoses", "ptr UncheckedArray[ptr UncheckedArray[$1]]"),
          ("Mesh", "vboId", "ptr array[MaxMeshVertexBuffers, $1]"),
          ("Material", "maps", "ptr array[MaxMaterialMaps, $1]")
        ]
        let pattern = getReplacement(obj.name, fld.name, replacements)
        (fieldType, baseType) = convertType(fld.`type`, pattern, many, false)
      let isArray = isArrayField(obj, fld, many)
      if isPrivate in fld.flags:
        procProperties.add PropertyInfo(struct: obj.name, field: fld.name, `type`: fieldType)
      if isArray:
        procArrays.add PropertyInfo(struct: obj.name, field: capitalizeAscii(fld.name), `type`: baseType)
      if shouldBePrivate(obj, fld, isArray, isPrivate in fld.flags):
        fld.flags.incl isPrivate
      fld.`type` = fieldType

proc preprocessEnums(enums: var seq[EnumInfo]) =
  proc removeCommonPrefixes(name: string): string =
    result = name
    const prefixes = [
      "FLAG_", "LOG_", "KEY_", "MOUSE_CURSOR_", "MOUSE_BUTTON_",
      "GAMEPAD_BUTTON_", "GAMEPAD_AXIS_", "FONT_", "BLEND_", "GESTURE_",
      "CAMERA_", "MATERIAL_MAP_", "SHADER_LOC_", "SHADER_UNIFORM_",
      "SHADER_ATTRIB_", "PIXELFORMAT_", "TEXTURE_FILTER_", "TEXTURE_WRAP_",
      "NPATCH_", "CUBEMAP_LAYOUT_"
    ]
    for prefix in prefixes:
      result.removePrefix(prefix)

  for enm in mitems(enums):
    sort(enm.values, proc (x, y: ValueInfo): int = cmp(x.value, y.value))
    for val in mitems(enm.values):
      val.name = removeCommonPrefixes(val.name).camelCaseAscii()

proc preprocessAliases(aliases: var seq[AliasInfo]) =
  for alias in mitems(aliases):
    if alias.name == "Quaternion":
      alias.flags.incl isDistinct

proc preprocessFunctions(holder: var seq[FunctionInfo]; wrappedFuncs: var seq[FunctionInfo]) =
  proc shouldRemoveSuffix(fnc: FunctionInfo): bool =
    const exceptions = [
      "DrawRectangleGradientV",
      "SetShaderValueV",
      "ColorToHSV",
      "ColorFromHSV",
      "CheckCollisionCircleRec",
      "CheckCollisionPointRec"
    ]
    fnc.name notin exceptions and
      ((fnc.name.endsWith("V") and fnc.returnType != "Vector2") or
      (fnc.name.endsWith("Rec") and fnc.returnType != "Rectangle") or
      fnc.name.endsWith("Ex") or fnc.name.endsWith("Pro"))

  proc generateProcName(fnc: FunctionInfo): string =
    result = fnc.name
    if shouldRemoveSuffix(fnc):
      result.removeSuffix("V")
      result.removeSuffix("Rec")
      result.removeSuffix("Ex")
      result.removeSuffix("Pro")
    result = uncapitalizeAscii(result)

  proc getMangledFunctionName(name: string): string =
    const mangledFunctions = ["ShowCursor", "CloseWindow", "LoadImage", "DrawText", "DrawTextEx"]
    if name in mangledFunctions:
      result = "rl" & name
    else:
      result = name

  proc shouldUsePluralType(fnc: FunctionInfo, param: ParamInfo): bool =
    result = isPlural(param.name)
    if (fnc.name, param.name) == ("LoadImageAnim", "frames"):
      result = false
    elif (fnc.name, param.name) == ("ImageKernelConvolution", "kernel"):
      result = true

  proc shouldUsePluralReturnType(fnc: FunctionInfo): bool =
    isPlural(fnc.name) or fnc.name == "LoadImagePalette"

  proc findEnumTypeForParam(fnc: FunctionInfo, param: ParamInfo): string =
    enumInFuncParams.getOrDefault((fnc.name, param.name))

  proc findEnumTypeForReturn(fnc: FunctionInfo): string =
    enumInFuncReturn.getOrDefault(fnc.name)

  proc checkCstringType(fnc: FunctionInfo, kind: string): bool =
    kind == "cstring" and fnc.name notin privateFuncs and hasVarargs notin fnc.flags

  proc checkOpenarrayType(fnc: FunctionInfo, kind: string, many: bool, nextName: string): bool =
    kind != "pointer" and many and ((nextName == "count" or nextName.endsWith("Count")) or
        (nextName == "size" or nextName.endsWith("Size"))) and
        fnc.name notin privateFuncs and hasVarargs notin fnc.flags

  for fnc in mitems(holder):
    if fnc.name in excludedFuncs:
      continue
    if fnc.name in privateFuncs: fnc.flags.incl isPrivate
    if fnc.name in allocFuncs: fnc.flags.incl isAllocFunc

    proc isVarargsParam(param: ParamInfo): bool =
      param.name == "args" and param.`type` == "..."

    if fnc.params.len > 0:
      if isVarargsParam(fnc.params[^1]):
        fnc.flags.incl hasVarargs
        fnc.params.setLen(fnc.params.high)

    for i, param in fnc.params.mpairs:
      let many = shouldUsePluralType(fnc, param)
      let (paramType, baseType) = convertType(param.`type`, many)
      if checkCstringType(fnc, paramType):
        fnc.flags.incl autoWrapped
      if i < fnc.params.high and checkOpenarrayType(fnc, paramType, many, fnc.params[i+1].name):
        param.baseType = baseType
        param.flags.incl isOpenArray
        fnc.flags.incl autoWrapped
      if paramType.startsWith("var "):
        param.flags.incl isVarParam
        param.baseType = baseType
    if fnc.returnType != "void":
      let (returnType, baseType) = convertType(fnc.returnType, false)
      if checkCstringType(fnc, returnType):
        fnc.flags.incl autoWrapped
      if baseType in needErrorChecking and fnc.name notin privateFuncs:
        echo "WARNING: Function might require error checking: ", fnc.name

    if autoWrapped in fnc.flags:
      fnc.flags.incl isPrivate

    for i, param in fnc.params.mpairs:
      var paramType = findEnumTypeForParam(fnc, param)
      if paramType == "":
        var baseType = ""
        let many = shouldUsePluralType(fnc, param)
        const
          replacements = [
            ("GenImageFontAtlas", "glyphRecs", "ptr ptr UncheckedArray[$1]"),
            ("CheckCollisionLines", "collisionPoint", "out $1"),
            ("LoadImageAnim", "frames", "out $1"),
            ("SetTraceLogCallback", "callback", "TraceLogCallbackImpl"),
          ]
        let pat = getReplacement(fnc.name, param.name, replacements)
        (paramType, baseType) = convertType(param.`type`, pat, many, isPrivate notin fnc.flags)
      param.`type` = paramType
    if fnc.returnType != "void":
      var returnType = findEnumTypeForReturn(fnc)
      if returnType == "":
        let many = shouldUsePluralReturnType(fnc)
        (returnType, _) = convertType(fnc.returnType, "", many, isPrivate notin fnc.flags)
      fnc.returnType = returnType

    fnc.importName = getMangledFunctionName(fnc.name)
    fnc.name = generateProcName(fnc)
    if autoWrapped in fnc.flags:
      wrappedFuncs.add fnc

proc genBindings(t: TopLevel, procProperties, procArrays: seq[PropertyInfo],
                 wrappedFuncs: seq[FunctionInfo],
                 fname: string; header, middle: string) =
  var buf = newStringOfCap(50)
  var indent = 0
  var otp: FileStream
  try:
    otp = openFileStream(fname, fmWrite)
    lit header

    proc generateEnums(enums: seq[EnumInfo]) =
      lit "\ntype"
      scope:
        for enm in items(enums):
          spaces
          ident enm.name
          lit "* {.size: sizeof(int32).} = enum"
          doc enm
          scope:
            var prev = -1
            for i, val in pairs(enm.values):
              if val.value == prev: continue
              spaces
              ident val.name
              if prev + 1 != val.value:
                lit " = "
                lit $val.value
              doc val
              prev = val.value
            lit "\n"
        lit "\n"

    # Generate enum definitions
    generateEnums(t.enums)
    lit extraDistinct

    proc generateObjects(structs: seq[StructInfo]) =
      for obj in items(structs):
        spaces
        ident obj.name
        if isPrivate notin obj.flags:
          lit "*"
        if obj.name == "Rectangle":
          lit " {.importc: \"rlRectangle\""
        else:
          lit " {.importc"
        lit ", header: \"raylib.h\""
        if isCompleteStruct in obj.flags:
          lit ", completeStruct"
        lit ", bycopy.} = object"
        doc obj
        scope:
          for fld in items(obj.fields):
            # Group Matrix fields by rows
            if obj.name != "Matrix" or fld.name in ["m0", "m1", "m2", "m3"]: # row starts
              spaces
            ident fld.name
            if obj.name == "Matrix" and fld.name notin ["m12", "m13", "m14", "m15"]: # row ends
              lit "*, "
              continue
            if isPrivate in fld.flags:
              lit ": "
            else:
              lit "*: "
            lit fld.`type`
            doc fld
        lit "\n"

    lit "\ntype"
    scope:
      # Generate type definitions
      generateObjects(t.structs)
      # Add a type alias or a missing type
      for alias in items(t.aliases):
        spaces
        ident alias.name
        if isDistinct in alias.flags:
          lit "* {.borrow: `.`.} = distinct "
        else:
          lit "* = "
        ident alias.`type`
        doc alias
      lit "\n"
      for extra in extraTypes.items:
        spaces
        lit extra
      lit "\n"
      for x in procArrays.items:
        spaces
        lit x.struct
        lit x.field
        lit "* = distinct "
        ident x.struct
      lit "\n"
    lit middle

    proc generateProcs(holder: seq[FunctionInfo]) =
      for fnc in items(holder):
        if fnc.name in excludedFuncs:
          continue
        # Generate proc signature
        lit "\nproc "
        ident fnc.name
        if isPrivate in fnc.flags:
          lit "Priv("
        elif isAllocFunc in fnc.flags:
          lit "("
        else:
          lit "*("
        # Generate parameters
        for i, param in fnc.params.pairs:
          if i > 0: lit ", "
          ident param.name
          lit ": "
          lit param.`type`
        lit ")"
        # Generate return type
        if fnc.returnType != "void":
          lit ": "
          lit fnc.returnType
        # Generate import pragma
        lit " {.importc: "
        lit "\""
        ident fnc.importName
        lit "\""
        if hasVarargs in fnc.flags:
          lit ", varargs"
        lit ".}"
        # Generate documentation comment
        if {isAllocFunc, isPrivate} * fnc.flags == {} and fnc.description != "":
          scope:
            spaces
            lit "## "
            lit fnc.description

    # Seperate funcs and procs
    var
      withSideEffect: seq[FunctionInfo] = @[]
      withoutSideEffect: seq[FunctionInfo] = @[]
    for fnc in t.functions:
      if fnc.importName in excludedFuncs: continue
      elif fnc.importName in nosideeffectsFuncs: withoutSideEffect.add fnc
      else: withSideEffect.add fnc

    # Generate procs
    lit "\n{.push callconv: cdecl, header: \"raylib.h\".}"
    lit "\n{.push sideEffect.}"
    generateProcs withSideEffect
    lit "\n{.pop.}\n"

    lit "\n{.push noSideEffect.}"
    generateProcs withoutSideEffect
    lit "\n{.pop.}"
    lit "\n{.pop.}\n"

    lit readFile("raylib_types.nim")
    lit "\n"
    for x in procProperties.items:
      lit "proc "
      ident x.field
      lit "*(x: "
      ident x.struct
      lit "): "
      lit x.`type`
      lit " {.inline.} = x."
      ident x.field
      lit "\n"

    proc generateWrappedProcs(holder: seq[FunctionInfo]) =
      for fnc in items(holder):
        # Generate proc signature
        lit "\nproc "
        ident fnc.name
        lit "*("
        # Generate parameters
        var skipNext = false
        for i, param in fnc.params.pairs:
          if skipNext:
            skipNext = false
          else:
            if i > 0: lit ", "
            ident param.name
            lit ": "
            if param.`type` == "cstring":
              lit "string"
            elif isOpenArray in param.flags:
              lit "openArray["
              lit param.baseType
              lit "]"
              skipNext = true
            elif isVarParam in param.flags:
              lit "var "
              lit param.baseType
            else:
              lit param.`type`
        lit ")"
        # Generate return type
        if fnc.returnType != "void":
          lit ": "
          if fnc.returnType == "cstring":
            lit "string"
          else:
            lit fnc.returnType
        lit " ="
        # Generate documentation comment
        if fnc.description != "":
          scope:
            spaces
            lit "## "
            lit fnc.description
        scope:
          spaces
          # Generate forwarding call
          if fnc.returnType == "cstring":
            lit "$"
          lit fnc.name
          lit "Priv("
          var nextValue = ""
          for i, param in fnc.params.pairs:
            if i > 0: lit ", "
            if isOpenArray in param.flags:
              lit "cast["
              lit param.`type`
              lit "]("
            elif isVarParam in param.flags:
              lit "addr "
            if nextValue != "":
              lit nextValue
              lit ".len."
              lit param.`type`
              nextValue = ""
            else:
              ident param.name
            if param.`type` == "cstring":
              lit ".cstring"
            if isOpenArray in param.flags:
              lit ")"
              nextValue = param.name
          lit ")\n"

    # Generate wrapped functions
    generateWrappedProcs(wrappedFuncs)
    lit readFile("raylib_wrap.nim")
    lit readFile("raylib_fields.nim")
  finally:
    if otp != nil: otp.close()

const
  raylibApi = "../api/raylib.json"
  outputname = "../src/raylib.nim"

type
  ApiContext = object
    api: TopLevel
    procProperties: seq[PropertyInfo] = @[]
    procArrays: seq[PropertyInfo] = @[]
    wrappedFuncs: seq[FunctionInfo] = @[]

proc preprocessApi(ctx: var ApiContext) =
  preprocessStructs(ctx.api.structs, ctx.procProperties, ctx.procArrays)
  preprocessEnums(ctx.api.enums)
  preprocessAliases(ctx.api.aliases)
  preprocessFunctions(ctx.api.functions, ctx.wrappedFuncs)

proc generateOutput(ctx: ApiContext) =
  genBindings(ctx.api, ctx.procProperties, ctx.procArrays, ctx.wrappedFuncs, outputname, raylibHeader, helpers)

proc main =
  var t = ApiContext(api: parseApi(raylibApi))
  preprocessApi(t)
  generateOutput(t)

main()
