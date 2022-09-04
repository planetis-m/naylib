import common, std/[streams, strutils]

const
  extraTypes = [
    """rAudioBuffer {.importc: "rAudioBuffer", header: "raylib.h", bycopy.} = object""",
    """rAudioProcessor {.importc: "rAudioProcessor", header: "raylib.h", bycopy.} = object"""
  ]
  raylibHeader = """
from unicode import Rune
import os
const inclDir = currentSourcePath().parentDir /../ "include"
{.passC: "-I" & inclDir.}
{.passL: inclDir / "libraylib.a".}
when defined(PlatformDesktop):
  when defined(linux):
    {.passC: "-D_DEFAULT_SOURCE".}
    when not defined(Wayland): {.passL: "-lX11".}
    {.passL: "-lGL -lm -lpthread -ldl -lrt".}
  elif defined(windows):
    {.passL: "-static-libgcc -lopengl32 -lgdi32 -lwinmm".}
    when defined(release): {.passL: "-Wl,--subsystem,windows".}
  elif defined(macosx):
    {.passL: "-framework OpenGL -framework Cocoa -framework IOKit -framework CoreAudio -framework CoreVideo".}
  elif defined(bsd):
    {.passL: "-lGL -lpthread -lX11 -lXrandr -lXinerama -lXi -lXxf86vm -lXcursor".}
elif defined(PlatformRpi):
  {.passL: "-lbrcmGLESv2 -lbrcmEGL -lpthread -lrt -lm -lbcm_host -ldl -latomic".}
elif defined(PlatformDrm):
  {.passC: "-DEGL_NO_X11".}
  {.passL: "-lGLESv2 -lEGL -ldrm -lgbm -lpthread -lrt -lm -ldl -latomic".}
elif defined(PlatformAndroid):
  {.passL: "-llog -landroid -lEGL -lGLESv2 -lOpenSLES -lc -lm".}

const
  RaylibVersion* = "4.2"
"""
  extraDistinct = """

  MaterialMapDiffuse* = MaterialMapAlbedo
  MaterialMapSpecular* = MaterialMapMetalness

  ShaderLocMapDiffuse* = ShaderLocMapAlbedo
  ShaderLocMapSpecular* = ShaderLocMapMetalness
  # Taken from raylib/src/config.h
  MaxShaderLocations* = 32 ## Maximum number of shader locations supported
  MaxMaterialMaps* = 12 ## Maximum number of shader maps supported
  MaxMeshVertexBuffers* = 7 ## Maximum vertex buffers (VBO) per mesh

proc `==`*(a, b: ConfigFlags): bool {.borrow.}

proc `<`*(a, b: TraceLogLevel): bool {.borrow.}
proc `<=`*(a, b: TraceLogLevel): bool {.borrow.}
proc `==`*(a, b: TraceLogLevel): bool {.borrow.}

proc `==`*(a, b: KeyboardKey): bool {.borrow.}
proc `==`*(a, b: MouseButton): bool {.borrow.}
proc `==`*(a, b: MouseCursor): bool {.borrow.}
proc `==`*(a, b: GamepadButton): bool {.borrow.}
proc `==`*(a, b: GamepadAxis): bool {.borrow.}

proc `<`*(a, b: MaterialMapIndex): bool {.borrow.}
proc `<=`*(a, b: MaterialMapIndex): bool {.borrow.}
proc `==`*(a, b: MaterialMapIndex): bool {.borrow.}

proc `<`*(a, b: ShaderLocationIndex): bool {.borrow.}
proc `<=`*(a, b: ShaderLocationIndex): bool {.borrow.}
proc `==`*(a, b: ShaderLocationIndex): bool {.borrow.}

proc `==`*(a, b: ShaderLocation): bool {.borrow.}
proc `==`*(a, b: ShaderUniformDataType): bool {.borrow.}
proc `==`*(a, b: ShaderAttributeDataType): bool {.borrow.}
proc `==`*(a, b: PixelFormat): bool {.borrow.}
proc `==`*(a, b: TextureFilter): bool {.borrow.}
proc `==`*(a, b: TextureWrap): bool {.borrow.}
proc `==`*(a, b: CubemapLayout): bool {.borrow.}
proc `==`*(a, b: FontType): bool {.borrow.}
proc `==`*(a, b: BlendMode): bool {.borrow.}
proc `==`*(a, b: Gesture): bool {.borrow.}
proc `==`*(a, b: CameraMode): bool {.borrow.}
proc `==`*(a, b: CameraProjection): bool {.borrow.}
proc `==`*(a, b: NPatchLayout): bool {.borrow.}

type
  FlagsEnum = ConfigFlags|Gesture
  Flags*[E: FlagsEnum] = distinct uint32

proc flags*[E: FlagsEnum](e: varargs[E]): Flags[E] {.inline.} =
  var res = 0'u32
  for val in items(e):
    res = res or uint32(val)
  Flags[E](res)
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
    ("GetGlyphAtlasRec", "codepoint")
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
    "Rune"
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
    "ClearDirectoryFiles",
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
    "GetCodepointCount",
    "GetCodepoint",
    "CodepointToUTF8",
    "TextCodepointsToUTF8",
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
    "LoadImageColors",
    "UnloadImageColors",
    "LoadFontData",
    "UnloadFontData",
    "LoadMaterials",
    "DrawLineStrip",
    "DrawTriangleFan",
    "DrawTriangleStrip",
    "CheckCollisionPointPoly",
    "LoadImageFromMemory",
    "DrawTexturePoly",
    "LoadFontEx",
    "LoadFontFromMemory",
    "GenImageFontAtlas",
    "DrawTriangleStrip3D",
    "DrawMeshInstanced",
    "LoadWaveFromMemory",
    "LoadMusicStreamFromMemory",
    "DrawTextCodepoints",
    "UnloadDroppedFiles",
    "LoadDroppedFiles"
  ]

proc getReplacement(x, y: string, replacements: openarray[(string, string, string)]): string =
  # Manual replacements for some fields
  result = ""
  for a, b, pattern in replacements.items:
    if x == a and y == b:
      return pattern

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
        lit "* = distinct int32"
        doc enm
      spaces
      # Extra distinct type used in GetShaderLocation, SetShaderValue
      lit "ShaderLocation* = distinct int32 ## Shader location"
    lit "\n\nconst"
    scope:
      for enm in items(t.enums):
        for i, val in pairs(enm.values):
          spaces
          ident camelCaseAscii(val.name)
          lit "* = "
          ident enm.name
          lit "("
          lit $val.value
          lit ")"
          doc val
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
          lit " {.header: \"raylib.h\", bycopy.} = object"
        else: lit "* {.header: \"raylib.h\", bycopy.} = object"
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
                ("Shader", "locs", "ptr array[MaxShaderLocations, ShaderLocation]")
              ]
              let pat = getReplacement(obj.name, name, replacements)
              var baseKind = ""
              let kind = convertType(fld.`type`, pat, many, false, baseKind)
              var isArray = many and not endsWith(name.normalize, "data") and
                  (obj.name, name) notin {"Material": "params", "VrDeviceInfo": "lensDistortionValues", "FilePathList": "paths"}
              if isPrivate or isArray or obj.name == "FilePathList":
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
      ident uncapitalizeAscii(fnc.name) # Follow Nim's naming convention for proc names.
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
                ("LoadModelFromMesh", "mesh", "sink Mesh"),
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
