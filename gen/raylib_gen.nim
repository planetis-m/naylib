import common, std/[algorithm, streams, strutils, sugar]

const
  extraTypes = {
    "Vector4": "Quaternion* = Vector4 ## Quaternion, 4 components (Vector4 alias)",
    "Texture": "Texture2D* = Texture ## Texture2D, same as Texture",
    "Texture": "TextureCubemap* = Texture ## TextureCubemap, same as Texture",
    "RenderTexture": "RenderTexture2D* = RenderTexture ## RenderTexture2D, same as RenderTexture",
    "Camera3D": "Camera* = Camera3D ## Camera type fallback, defaults to Camera3D",
    "AudioStream": "RAudioBuffer* {.importc: \"rAudioBuffer\", bycopy.} = object"
  }
  raylibHeader = """
const lext = when defined(windows): ".dll" elif defined(macosx): ".dylib" else: ".so"
{.pragma: rlapi, cdecl, dynlib: "libraylib" & lext.}

const
  RaylibVersion* = "4.0"

  MaxShaderLocations* = 32 ## Maximum number of shader locations supported
  MaxMaterialMaps* = 12 ## Maximum number of shader maps supported
  MaxMeshVertexBuffers* = 7 ## Maximum vertex buffers (VBO) per mesh
"""
  helpers = """

type va_list* {.importc: "va_list", header: "<stdarg.h>".} = object ## Only used by TraceLogCallback
proc vprintf*(format: cstring, args: va_list) {.cdecl, importc: "vprintf", header: "<stdio.h>".}

## Callbacks to hook some internal functions
## WARNING: This callbacks are intended for advance users
type
  TraceLogCallback* = proc (logLevel: cint; text: cstring; args: va_list) {.cdecl.} ## Logging: Redirect trace log messages
  LoadFileDataCallback* = proc (fileName: cstring; bytesRead: ptr uint32): ptr UncheckedArray[uint8] {.
      cdecl.} ## FileIO: Load binary data
  SaveFileDataCallback* = proc (fileName: cstring; data: pointer; bytesToWrite: uint32): bool {.
      cdecl.} ## FileIO: Save binary data
  LoadFileTextCallback* = proc (fileName: cstring): cstring {.cdecl.} ## FileIO: Load text data
  SaveFileTextCallback* = proc (fileName: cstring; text: cstring): bool {.cdecl.} ## FileIO: Save text data

  Enums = ConfigFlags|Gesture
  Flag*[E: Enums] = distinct uint32

proc flag*[E: Enums](e: varargs[E]): Flag[E] {.inline.} =
  var res = 0'u32
  for val in items(e):
    res = res or uint32(val)
  Flag[E](res)

const
  Menu* = KeyboardKey.R ## Key: Android menu button

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
    ("GetGestureDetected", 25)
  ]
  enumInFuncParams = [
    # KeyboardKey
    ("IsKeyPressed", "key"),
    ("IsKeyDown", "key"),
    ("IsKeyReleased", "key"),
    ("IsKeyUp", "key"),
    ("SetExitKey", "key"),
    ("SetCameraPanControl", "keyPan"),
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
    ("LoadFontData", "type")
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
    "Flag[Gesture]",
    "Gesture",
    "Flag[ConfigFlags]",
    "Flag[ConfigFlags]",
    "Flag[ConfigFlags]",
    "ConfigFlags",
    "TraceLogLevel",
    "TraceLogLevel",
    "CameraMode",
    "BlendMode",
    "MaterialMapIndex",
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
    "FontType"
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
    "GetFileNameWithoutExt",
    "GetDirectoryPath",
    "GetPrevDirectoryPath",
    "GetWorkingDirectory",
    "GetDirectoryFiles",
    "ClearDirectoryFiles",
    "ChangeDirectory",
    "GetFileModTime",
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
    "GetDroppedFiles",
    "GetGamepadName",
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
    "LoadImageFromMemory",
    "DrawTexturePoly",
    "LoadFontEx",
    "LoadFontFromMemory",
    "GenImageFontAtlas",
    "DrawTriangleStrip3D",
    "DrawMeshInstanced",
    "LoadWaveFromMemory",
    "LoadMusicStreamFromMemory"
  ]

proc removeEnumPrefix(enm, val: string): string =
  # Remove prefixes from enum fields.
  const
    enumPrefixes = {
      "ConfigFlags": "FLAG_",
      "TraceLogLevel": "LOG_",
      "KeyboardKey": "KEY_",
      "MouseButton": "MOUSE_BUTTON_",
      "MouseCursor": "MOUSE_CURSOR_",
      "GamepadButton": "GAMEPAD_BUTTON_",
      "GamepadAxis": "GAMEPAD_AXIS_",
      "MaterialMapIndex": "MATERIAL_MAP_",
      "ShaderLocationIndex": "SHADER_LOC_",
      "ShaderUniformDataType": "SHADER_UNIFORM_",
      "ShaderAttributeDataType": "SHADER_ATTRIB_",
      "PixelFormat": "PIXELFORMAT_",
      "TextureFilter": "TEXTURE_FILTER_",
      "TextureWrap": "TEXTURE_WRAP_",
      "CubemapLayout": "CUBEMAP_LAYOUT_",
      "FontType": "FONT_",
      "BlendMode": "BLEND_",
      "Gesture": "GESTURE_",
      "CameraMode": "CAMERA_",
      "CameraProjection": "CAMERA_",
      "NPatchLayout": "NPATCH_"
    }
  result = val
  for x, prefix in enumPrefixes.items:
    if enm == x:
      removePrefix(result, prefix)
      return

proc replaceCintField(obj, fld: string): string =
  # Replace `int32` with the respective enum type.
  const enumReplacements = [
    ("Camera3D", "projection", "CameraProjection"),
    ("Image", "format", "PixelFormat"),
    ("Texture", "format", "PixelFormat"),
    ("NPatchInfo", "layout", "NPatchLayout")
  ]
  result = ""
  for x, y, kind in enumReplacements.items:
    if obj == x and fld == y:
      return kind

proc getSpecialPattern(x, y: string, replacements: openarray[(string, string, string)]): string =
  # Manual replacements for some fields
  result = ""
  for a, b, pattern in replacements.items:
    if x == a and y == b:
      return pattern

proc genBindings(t: Topmost, fname: string; header, middle, footer: string) =
  var buf = newStringOfCap(50)
  var indent = 0
  var otp: FileStream
  try:
    otp = openFileStream(fname, fmWrite)
    lit header
    # Generate type definitions
    lit "\ntype"
    scope:
      for obj in items(t.structs):
        spaces
        ident obj.name
        lit "* {.bycopy.} = object"
        doc obj
        scope:
          for fld in items(obj.fields):
            spaces
            var (name, pat) = transFieldName(fld.name)
            ident name
            lit "*: "
            let kind = replaceCintField(obj.name, name)
            if kind != "":
              lit kind
            else:
              let many = isPlural(name) or (obj.name, name) in {"Model": "meshMaterial", "Model": "bindPose"}
              const replacements = [
                ("ModelAnimation", "framePoses", "ptr UncheckedArray[ptr UncheckedArray[$1]]"),
                ("Mesh", "vboId", "ptr array[MaxMeshVertexBuffers, $1]"),
                ("Material", "maps", "ptr array[MaxMaterialMaps, $1]"),
                ("Shader", "locs", "ptr array[MaxShaderLocations, $1]")
              ]
              let tmp = getSpecialPattern(obj.name, name, replacements)
              if tmp != "": pat = tmp
              let kind = convertType(fld.`type`, pat, many, false)
              lit kind
            doc fld
        # Add a type alias or a missing type after the respective type.
        for name, extra in extraTypes.items:
          if obj.name == name:
            spaces
            lit extra
        lit "\n"
      # Generate enums definitions
      for enm in items(t.enums):
        spaces
        ident enm.name
        lit "* {.size: sizeof(cint).} = enum"
        doc enm
        scope:
          let allSeq = allSequential(enm.values)
          for i, val in pairs(enm.values):
            if i-1>=0 and enm.values[i-1].value == val.value: # omit duplicate!
              continue
            spaces
            # Follow Nim's naming convention for enum fields.
            let name = removeEnumPrefix(enm.name, val.name)
            ident camelCaseAscii(name)
            # Set the int value if the enum has holes and it doesn't start at 0.
            if not allSeq or (i == 0 and val.value != 0):
              lit " = "
              lit $val.value
            doc val
          lit "\n"
    lit middle
    # Generate functions
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
      for i, (param, kind) in fnc.params.pairs:
        if param == "" and kind == "": # , ...) {
          hasVarargs = true
        else:
          if i > 0: lit ", "
          ident param
          lit ": "
          block outer:
            for j, (name, param1) in enumInFuncParams.pairs:
              if name == fnc.name and param1 == param:
                lit enumInFuncs[j]
                break outer
            let many = (fnc.name, param) != ("LoadImageAnim", "frames") and isPlural(param)
            const
              replacements = [
                ("GenImageFontAtlas", "recs", "ptr ptr UncheckedArray[$1]")
              ]
            let pat = getSpecialPattern(fnc.name, param, replacements)
            let kind = convertType(kind, pat, many, not isPrivate)
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
          let kind = convertType(fnc.returnType, "", many, not isPrivate)
          lit kind
      lit " {.importc: \""
      ident fnc.name
      lit "\""
      if hasVarargs:
        lit ", varargs"
      lit ", rlapi.}"
      if not (isAlloc or isPrivate) and fnc.description != "":
        scope:
          spaces
          lit "## "
          lit fnc.description
    lit "\n"
    lit footer
  finally:
    if otp != nil: otp.close()

const
  raylibApi = "../api/raylib_api.json"
  outputname = "../raylib.nim"

proc main =
  var t = parseApi(raylibApi)
  # Some enums are unsorted!
  for enm in mitems(t.enums): sort(enm.values, (x, y) => cmp(x.value, y.value))
  genBindings(t, outputname, raylibHeader, helpers, readFile("raylib_wrap.nim"))

main()
