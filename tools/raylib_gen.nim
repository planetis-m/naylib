import common, std/[streams, strutils]
when defined(nimPreviewSlimSystem):
  import std/syncio

const
  extraTypes = [
    """rAudioBuffer {.importc, nodecl, bycopy.} = object""",
    """rAudioProcessor {.importc, nodecl, bycopy.} = object"""
  ]
  raylibHeader = """
from std/unicode import Rune
import std/os
const raylibDir = currentSourcePath().parentDir / "raylib/src"

{.passC: "-I" & raylibDir.}
{.passC: "-I" & raylibDir / "external/glfw/include".}
{.passC: "-I" & raylibDir / "external/glfw/deps/mingw".}
{.passC: "-Wall -D_DEFAULT_SOURCE -Wno-missing-braces -Werror=pointer-arith".}
when defined(emscripten):
  {.passC: "-DPLATFORM_WEB -DGRAPHICS_API_OPENGL_ES2".}
  {.passL: "-s USE_GLFW=3 -s WASM=1 -s ASYNCIFY -s TOTAL_MEMORY=67108864".}
  when defined(NaylibWebResources):
    const NaylibWebResourcesPath {.strdefine.} = "resources"
    {.passL: "-s FORCE_FILESYSTEM=1 --preload-file " & NaylibWebResourcesPath.}

  type emCallbackFunc* = proc() {.cdecl.}
  proc emscriptenSetMainLoop*(f: emCallbackFunc, fps: cint, simulateInfiniteLoop: cint) {.
      cdecl, importc: "emscripten_set_main_loop", header: "<emscripten.h>".}

elif defined(android):
  const AndroidApiVersion {.intdefine.} = 29
  const AndroidNdk {.strdefine.} = "/opt/android-ndk"
  const ProjectLibraryName = "main"
  {.passC: "-I" & AndroidNdk / "sources/android/native_app_glue".}

  {.passC: "-D__ANDROID__ -DPLATFORM_ANDROID -DGRAPHICS_API_OPENGL_ES2 -D__ANDROID_API__=" & $AndroidApiVersion & " -DMAL_NO_OSS".}
  {.passC: "-ffunction-sections -funwind-tables -fstack-protector-strong -fPIE -fPIC".}
  {.passC: "-Wa,--noexecstack -Wformat -no-canonical-prefixes".}

  {.passL: "-Wl,-soname,lib" & ProjectLibraryName & ".so -Wl,--exclude-libs,libatomic.a".}
  {.passL: "-Wl,--build-id -Wl,-z,noexecstack -Wl,-z,relro -Wl,-z,now -Wl,--warn-shared-textrel".}
  {.passL: "-Wl,--fatal-warnings -u ANativeActivity_onCreate -Wl,-no-undefined".}
  {.passL: "-llog -landroid -lEGL -lGLESv2 -lOpenSLES -lc -lm -ldl".}

else:
  {.passC: "-DPLATFORM_DESKTOP".}
  when defined(GraphicsApiOpenGl11): {.passC: "-DGRAPHICS_API_OPENGL_11".}
  elif defined(GraphicsApiOpenGl21): {.passC: "-DGRAPHICS_API_OPENGL_21".}
  elif defined(GraphicsApiOpenGl43): {.passC: "-DGRAPHICS_API_OPENGL_43".}
  elif defined(GraphicsApiOpenGlEs2): {.passC: "-DGRAPHICS_API_OPENGL_ES2".}
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
      const wlProtocolsDir = staticExec "pkg-config wayland-protocols --variable=pkgdatadir"
      const wlClientDir = staticExec "pkg-config wayland-client --variable=pkgdatadir"
      proc wlGenerate(protocol, basename: string) =
        discard staticExec("wayland-scanner client-header " & protocol & " " & raylibDir / basename & ".h")
        discard staticExec("wayland-scanner private-code " & protocol & " " & raylibDir / basename & "-code.h")

      static:
        wlGenerate(wlClientDir / "wayland.xml", "wayland-client-protocol")
        wlGenerate(wlProtocolsDir / "stable/xdg-shell/xdg-shell.xml", "wayland-xdg-shell-client-protocol")
        wlGenerate(wlProtocolsDir / "unstable/xdg-decoration/xdg-decoration-unstable-v1.xml",
            "wayland-xdg-decoration-client-protocol")
        wlGenerate(wlProtocolsDir / "stable/viewporter/viewporter.xml", "wayland-viewporter-client-protocol")
        wlGenerate(wlProtocolsDir / "unstable/relative-pointer/relative-pointer-unstable-v1.xml",
            "wayland-relative-pointer-unstable-v1-client-protocol")
        wlGenerate(wlProtocolsDir / "unstable/pointer-constraints/pointer-constraints-unstable-v1.xml",
            "wayland-pointer-constraints-unstable-v1-client-protocol")
        wlGenerate(wlProtocolsDir / "unstable/idle-inhibit/idle-inhibit-unstable-v1.xml",
            "wayland-idle-inhibit-unstable-v1-client-protocol")

    else:
      # pkg-config x11 xrandr xinerama xi xxf86vm xcursor --libs
      {.passL: "-lX11 -lXrandr -lXinerama -lXi -lXxf86vm -lXcursor".}

when defined(emscripten): discard
elif defined(android): discard
elif defined(macosx): {.compile(raylibDir / "rglfw.c", "-x objective-c").}
else: {.compile: raylibDir / "rglfw.c".}
{.compile: raylibDir / "rshapes.c".}
{.compile: raylibDir / "rtextures.c".}
{.compile: raylibDir / "rtext.c".}
{.compile: raylibDir / "utils.c".}
{.compile: raylibDir / "rmodels.c".}
{.compile: raylibDir / "raudio.c".}
{.compile: raylibDir / "rcore.c".}
when defined(android): {.compile: AndroidNdk / "sources/android/native_app_glue/android_native_app_glue.c".}

const
  RaylibVersion* = (4, 5, 0)

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

template Menu*(_: typedesc[KeyboardKey]): untyped = R ## Key: Android menu button
"""
  helpers = """

type va_list* {.importc: "va_list", header: "<stdarg.h>".} = object ## Only used by TraceLogCallback
proc vsprintf*(s: cstring, format: cstring, args: va_list) {.cdecl, importc: "vsprintf", header: "<stdio.h>".}

## Callbacks to hook some internal functions
## WARNING: This callbacks are intended for advance users
type
  TraceLogCallback* = proc (logLevel: TraceLogLevel; text: cstring; args: va_list) {.
      cdecl.} ## Logging: Redirect trace log messages
  LoadFileDataCallback* = proc (fileName: cstring; bytesRead: ptr uint32): ptr UncheckedArray[uint8] {.
      cdecl.} ## FileIO: Load binary data
  SaveFileDataCallback* = proc (fileName: cstring; data: pointer; bytesToWrite: uint32): bool {.
      cdecl.} ## FileIO: Save binary data
  LoadFileTextCallback* = proc (fileName: cstring): cstring {.cdecl.} ## FileIO: Load text data
  SaveFileTextCallback* = proc (fileName: cstring; text: cstring): bool {.cdecl.} ## FileIO: Save text data
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
  enumInFuncReturn = [
    ("GetKeyPressed", 0),
    ("GetGamepadButtonPressed", 14),
    ("GetGestureDetected", 25),
    ("GetShaderLocation", 35),
    ("GetShaderLocationAttrib", 35)
  ]
  enumInFuncParams = [
    # KeyboardKey
    ("IsKeyPressed", "key"),
    ("IsKeyDown", "key"),
    ("IsKeyReleased", "key"),
    ("IsKeyUp", "key"),
    ("SetExitKey", "key"),
    ("SetCameraAltControl", "keyAlt"),
    ("SetCameraSmoothZoomControl", "keySmoothZoom"),
    ("SetCameraMoveControls", "keyFront"),
    ("SetCameraMoveControls", "keyBack"),
    ("SetCameraMoveControls", "keyRight"),
    ("SetCameraMoveControls", "keyLeft"),
    ("SetCameraMoveControls", "keyUp"),
    ("SetCameraMoveControls", "keyDown"),
    # GamepadButton
    ("IsGamepadButtonPressed", "button"),
    ("IsGamepadButtonDown", "button"),
    ("IsGamepadButtonReleased", "button"),
    ("IsGamepadButtonUp", "button"),
    # GamepadAxis
    ("GetGamepadAxisMovement", "axis"),
    # MouseCursor
    ("SetMouseCursor", "cursor"),
    # MouseButton
    ("IsMouseButtonPressed", "button"),
    ("IsMouseButtonDown", "button"),
    ("IsMouseButtonReleased", "button"),
    ("IsMouseButtonUp", "button"),
    ("SetCameraPanControl", "keyPan"),
    # Gesture
    ("SetGesturesEnabled", "flags"),
    ("IsGestureDetected", "gesture"),
    # ConfigFlags
    ("SetConfigFlags", "flags"),
    ("SetWindowState", "flags"),
    ("ClearWindowState", "flags"),
    ("IsWindowState", "flag"),
    # TraceLogLevel
    ("TraceLog", "logLevel"),
    ("SetTraceLogLevel", "logLevel"),
    # CameraMode
    ("SetCameraMode", "mode"),
    # BlendMode
    ("BeginBlendMode", "mode"),
    # MaterialMapIndex
    ("SetMaterialTexture", "mapType"),
    # ShaderLocation
    ("SetShaderValue", "locIndex"),
    ("SetShaderValueV", "locIndex"),
    ("SetShaderValueMatrix", "locIndex"),
    ("SetShaderValueTexture", "locIndex"),
    # ShaderUniformDataType
    ("SetShaderValue", "uniformType"),
    ("SetShaderValueV", "uniformType"),
    # PixelFormat
    ("LoadImageRaw", "format"),
    ("ImageFormat", "newFormat"),
    ("GetPixelColor", "format"),
    ("SetPixelColor", "format"),
    ("GetPixelDataSize", "format"),
    # TextureFilter
    ("SetTextureFilter", "filter"),
    # TextureWrap
    ("SetTextureWrap", "wrap"),
    # CubemapLayout
    ("LoadTextureCubemap", "layout"),
    # FontType
    ("LoadFontData", "type"),
    # Rune
    ("DrawTextCodepoint", "codepoint"),
    ("GetGlyphIndex", "codepoint"),
    ("GetGlyphInfo", "codepoint"),
    ("GetGlyphAtlasRec", "codepoint"),
  ]
  enumInFuncs = [
    "KeyboardKey",
    "KeyboardKey",
    "KeyboardKey",
    "KeyboardKey",
    "KeyboardKey",
    "KeyboardKey",
    "KeyboardKey",
    "KeyboardKey",
    "KeyboardKey",
    "KeyboardKey",
    "KeyboardKey",
    "KeyboardKey",
    "KeyboardKey",
    "GamepadButton",
    "GamepadButton",
    "GamepadButton",
    "GamepadButton",
    "GamepadAxis",
    "MouseCursor",
    "MouseButton",
    "MouseButton",
    "MouseButton",
    "MouseButton",
    "MouseButton",
    "Flags[Gesture]",
    "Gesture",
    "Flags[ConfigFlags]",
    "Flags[ConfigFlags]",
    "Flags[ConfigFlags]",
    "ConfigFlags",
    "TraceLogLevel",
    "TraceLogLevel",
    "CameraMode",
    "BlendMode",
    "MaterialMapIndex",
    "ShaderLocation",
    "ShaderLocation",
    "ShaderLocation",
    "ShaderLocation",
    "ShaderUniformDataType",
    "ShaderUniformDataType",
    "PixelFormat",
    "PixelFormat",
    "PixelFormat",
    "PixelFormat",
    "PixelFormat",
    "TextureFilter",
    "TextureWrap",
    "CubemapLayout",
    "FontType",
    "Rune",
    "Rune",
    "Rune",
    "Rune",
  ]
  excludedFuncs = [
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
    # Misc
    "GetRandomValue",
    "SetRandomSeed",
    "OpenURL",
    # Files management functions
    "LoadFileData",
    "UnloadFileData",
    "SaveFileData",
    "LoadFileText",
    "UnloadFileText",
    "SaveFileText",
    "FileExists",
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
    # IsReady
    "IsShaderReady",
    "IsImageReady",
    "IsFontReady",
    "IsWaveReady",
    "IsSoundReady",
    "IsMusicReady",
    "IsAudioStreamReady",
  ]
  allocFuncs = [
    "MemAlloc",
    "MemRealloc",
    "MemFree"
  ]
  privateFuncs = [
    "GetMonitorName",
    "GetClipboardText",
    "GetGamepadName",
    "UpdateTexture",
    "UpdateTextureRec",
    "GetPixelColor",
    "SetPixelColor",
    "LoadShader",
    "LoadShaderFromMemory",
    "SetShaderValue",
    "SetShaderValueV",
    "LoadModelAnimations",
    "UnloadModelAnimations",
    "LoadWaveSamples",
    "UnloadWaveSamples",
    "LoadImagePalette",
    "UnloadImagePalette",
    "LoadImage",
    "LoadImageRaw",
    "LoadImageFromMemory",
    "LoadImageColors",
    "UnloadImageColors",
    "LoadFontData",
    "UnloadFontData",
    "LoadMaterials",
    "LoadImageFromTexture",
    "LoadTextureFromImage",
    "LoadTextureCubemap",
    "LoadTexture",
    "LoadRenderTexture",
    "DrawLineStrip",
    "DrawTriangleFan",
    "DrawTriangleStrip",
    "CheckCollisionPointPoly",
    "LoadFont",
    "LoadFontEx",
    "LoadFontFromImage",
    "LoadFontFromMemory",
    "GenImageFontAtlas",
    "DrawTriangleStrip3D",
    "DrawMeshInstanced",
    "ExportDataAsCode",
    "DrawTextCodepoints",
    "LoadModel",
    "LoadModelFromMesh",
    "LoadWave",
    "LoadSound",
    "LoadSoundFromWave",
    "LoadWaveFromMemory",
    "LoadMusicStream",
    "LoadMusicStreamFromMemory",
    "UnloadDroppedFiles",
    "LoadDroppedFiles",
  ]

proc genBindings(t: TopLevel, fname: string; header, middle: string) =
  var buf = newStringOfCap(50)
  var indent = 0
  var otp: FileStream
  try:
    otp = openFileStream(fname, fmWrite)
    lit header
    # Generate enum definitions
    lit "\ntype"
    scope:
      for enm in items(t.enums):
        spaces
        ident enm.name
        lit "* {.size: sizeof(int32).} = enum"
        doc enm
        scope:
          var prev = -1
          for i, val in pairs(enm.values):
            if val.value == prev: continue
            spaces
            var valName = val.name
            removePrefix(valName, "FLAG_")
            removePrefix(valName, "LOG_")
            removePrefix(valName, "KEY_")
            removePrefix(valName, "MOUSE_CURSOR_")
            removePrefix(valName, "MOUSE_BUTTON_")
            removePrefix(valName, "GAMEPAD_BUTTON_")
            removePrefix(valName, "GAMEPAD_AXIS_")
            removePrefix(valName, "FONT_")
            removePrefix(valName, "BLEND_")
            removePrefix(valName, "GESTURE_")
            removePrefix(valName, "CAMERA_")
            removePrefix(valName, "MATERIAL_MAP_")
            removePrefix(valName, "SHADER_LOC_")
            removePrefix(valName, "SHADER_UNIFORM_")
            removePrefix(valName, "SHADER_ATTRIB_")
            removePrefix(valName, "PIXELFORMAT_")
            removePrefix(valName, "TEXTURE_FILTER_")
            removePrefix(valName, "TEXTURE_WRAP_")
            removePrefix(valName, "NPATCH_")
            removePrefix(valName, "CUBEMAP_LAYOUT_")
            ident camelCaseAscii(valName)
            if prev + 1 != val.value:
              lit " = "
              lit $val.value
            doc val
            prev = val.value
          lit "\n"
      lit "\n"
    lit extraDistinct
    # Generate type definitions
    var procProperties: seq[(string, string, string)] = @[]
    var procArrays: seq[(string, string, string)] = @[]
    lit "\ntype"
    scope:
      for obj in items(t.structs):
        spaces
        ident obj.name
        if obj.name == "FilePathList":
          lit " {.importc, header: \"raylib.h\", bycopy.} = object"
        else: lit "* {.importc, header: \"raylib.h\", bycopy.} = object"
        doc obj
        scope:
          for fld in items(obj.fields):
            if obj.name != "Matrix" or fld.name notin ["m4", "m8", "m12", "m5", "m9", "m13", "m6", "m10", "m14", "m7", "m11", "m15"]:
              spaces
            var name = fld.name
            ident name
            if obj.name == "Matrix" and fld.name in ["m0", "m4", "m8", "m1", "m5", "m9", "m2", "m6", "m10", "m3", "m7", "m11"]:
              lit "*, "
              continue
            let isPrivate = (obj.name, name) notin
                {"Wave": "frameCount", "Sound": "frameCount", "Music": "frameCount"} and
                name.endsWith("Count") or (obj.name, name) in {"AudioStream": "buffer",
                "AudioStream": "processor"}
            const replacements = [
              ("Camera3D", "projection", "CameraProjection"),
              ("Image", "format", "PixelFormat"),
              ("Texture", "format", "PixelFormat"),
              ("NPatchInfo", "layout", "NPatchLayout")
            ]
            let kind = getReplacement(obj.name, name, replacements)
            if kind != "":
              lit "*: "
              lit kind
            else:
              let many = name notin ["mipmaps", "channels"] and isPlural(name) or
                  (obj.name, name) in {"Model": "meshMaterial", "Model": "bindPose", "Mesh": "vboId"}
              const replacements = [
                ("ModelAnimation", "framePoses", "ptr UncheckedArray[ptr UncheckedArray[$1]]"),
                ("Mesh", "vboId", "ptr array[MaxMeshVertexBuffers, $1]"),
                ("Material", "maps", "ptr array[MaxMaterialMaps, $1]"),
                ("Shader", "locs", "ptr UncheckedArray[ShaderLocation]")
              ]
              let pat = getReplacement(obj.name, name, replacements)
              var baseKind = ""
              let kind = convertType(fld.`type`, pat, many, false, baseKind)
              var isArray = many and not endsWith(name.normalize, "data") and
                  (obj.name, name) notin {"Material": "params", "VrDeviceInfo": "lensDistortionValues", "FilePathList": "paths"}
              if isPrivate or isArray or obj.name == "FilePathList" or (obj.name, name) == ("MaterialMap", "texture"):
                lit ": "
              else:
                lit "*: "
              lit kind
              if isPrivate:
                procProperties.add (obj.name, name, kind)
              if isArray:
                procArrays.add (obj.name, name, baseKind)
            doc fld
        lit "\n"
      # Add a type alias or a missing type
      for alias in items(t.aliases):
        spaces
        ident alias.name
        lit "* = "
        ident alias.`type`
        doc alias
      lit "\n"
      for extra in extraTypes.items:
        spaces
        lit extra
      lit "\n"
      for obj, name, _ in procArrays.items:
        spaces
        lit obj
        lit capitalizeAscii(name)
        lit "* = distinct "
        ident obj
      lit "\n"
    lit middle
    # Generate functions
    lit "\n{.push callconv: cdecl, header: \"raylib.h\".}"
    for fnc in items(t.functions):
      if fnc.name in excludedFuncs: continue
      lit "\nproc "
      var fncName = uncapitalizeAscii(fnc.name) # Follow Nim's naming convention for proc names.
      if fncName notin ["drawRectangleGradientV", "setShaderValueV", "colorToHSV", "colorFromHSV",
          "checkCollisionCircleRec", "checkCollisionPointRec", "genImageGradientV"] and
          (fncName.endsWith("V") and fnc.returnType != "Vector2" or
          fncName.endsWith("Rec") and fnc.returnType != "Rectangle") or
          fncName.endsWith("Ex") or fncName.endsWith("Pro"):
        fncName.removeSuffix("V")
        fncName.removeSuffix("Rec")
        fncName.removeSuffix("Ex")
        fncName.removeSuffix("Pro")
      ident fncName
      let isPrivate = fnc.name in privateFuncs
      let isAlloc = fnc.name in allocFuncs
      if isPrivate:
        lit "Priv("
      elif isAlloc:
        lit "("
      else:
        lit "*("
      var hasVarargs = false
      for i, param in fnc.params.pairs:
        if param.name == "args" and param.`type` == "...": # , ...) {
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
            let many = (fnc.name, param.name) != ("LoadImageAnim", "frames") and isPlural(param.name)
            const
              replacements = [
                ("GenImageFontAtlas", "recs", "ptr ptr UncheckedArray[$1]"),
                ("CheckCollisionLines", "collisionPoint", "out $1"),
                ("LoadImageAnim", "frames", "out $1"),
              ]
            let pat = getReplacement(fnc.name, param.name, replacements)
            var baseKind = ""
            let kind = convertType(param.`type`, pat, many, not isPrivate, baseKind)
            lit kind
      lit ")"
      if fnc.returnType != "void":
        lit ": "
        block outer:
          for (name, idx) in enumInFuncReturn.items:
            if name == fnc.name:
              lit enumInFuncs[idx]
              break outer
          let many = isPlural(fnc.name) or fnc.name == "LoadImagePalette"
          var baseKind = ""
          let kind = convertType(fnc.returnType, "", many, not isPrivate, baseKind)
          lit kind
      lit " {.importc: \""
      ident fnc.name
      lit "\""
      if hasVarargs:
        lit ", varargs"
      lit ".}"
      if not (isAlloc or isPrivate) and fnc.description != "":
        scope:
          spaces
          lit "## "
          lit fnc.description
    lit "\n{.pop.}\n"
    lit readFile("raylib_types.nim")
    lit "\n"
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
    lit readFile("raylib_wrap.nim")
    lit readFile("raylib_fields.nim")
  finally:
    if otp != nil: otp.close()

const
  raylibApi = "../api/raylib_api.json"
  outputname = "../src/raylib.nim"

proc main =
  var t = parseApi(raylibApi)
  genBindings(t, outputname, raylibHeader, helpers)

main()
