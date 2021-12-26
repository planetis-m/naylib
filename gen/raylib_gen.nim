import common, std/[algorithm, streams]
import strutils except indent

const
  indWidth = 2
  extraTypes = [
    "Quaternion* = Vector4 ## Quaternion, 4 components (Vector4 alias)",
    "Texture2D* = Texture ## Texture2D, same as Texture",
    "TextureCubemap* = Texture ## TextureCubemap, same as Texture",
    "RenderTexture2D* = RenderTexture ## RenderTexture2D, same as RenderTexture",
    "Camera* = Camera3D ## Camera type fallback, defaults to Camera3D",
    "RAudioBuffer* {.importc: \"rAudioBuffer\", bycopy.} = object"
  ]
  header = """

const lext = when defined(windows): ".dll" elif defined(macosx): ".dylib" else: ".so"
{.pragma: rlapi, cdecl, dynlib: "libraylib" & lext.}

const
  RaylibVersion* = "4.0"

  MaxShaderLocations* = 32 ## Maximum number of shader locations supported
  MaxMaterialMaps* = 12 ## Maximum number of shader maps supported
  MaxMeshVertexBuffers* = 7 ## Maximum vertex buffers (VBO) per mesh
"""
  flagsHelper = """

  Enums = ConfigFlags|Gesture
  Flag*[E: Enums] = distinct uint32

proc flag*[E: Enums](e: varargs[E]): Flag[E] {.inline.} =
  var res = 0'u32
  for val in items(e):
    res = res or uint32(val)
  Flag[E](res)
"""
  duplicateVal = """

const
  Menu* = KeyboardKey.R ## Key: Android menu button
"""
  colors = """

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
  enumPrefixes = [
    ("ConfigFlags", "FLAG_"),
    ("TraceLogLevel", "LOG_"),
    ("KeyboardKey", "KEY_"),
    ("MouseButton", "MOUSE_BUTTON_"),
    ("MouseCursor", "MOUSE_CURSOR_"),
    ("GamepadButton", "GAMEPAD_BUTTON_"),
    ("GamepadAxis", "GAMEPAD_AXIS_"),
    ("MaterialMapIndex", "MATERIAL_MAP_"),
    ("ShaderLocationIndex", "SHADER_LOC_"),
    ("ShaderUniformDataType", "SHADER_UNIFORM_"),
    ("ShaderAttributeDataType", "SHADER_ATTRIB_"),
    ("PixelFormat", "PIXELFORMAT_"),
    ("TextureFilter", "TEXTURE_FILTER_"),
    ("TextureWrap", "TEXTURE_WRAP_"),
    ("CubemapLayout", "CUBEMAP_LAYOUT_"),
    ("FontType", "FONT_"),
    ("BlendMode", "BLEND_"),
    ("Gesture", "GESTURE_"),
    ("CameraMode", "CAMERA_"),
    ("CameraProjection", "CAMERA_"),
    ("NPatchLayout", "NPATCH_")
  ]
  enumInFuncParams = [
    # KeyboardKey
    ("IsKeyPressed", "KeyboardKey", @["key"]),
    ("IsKeyDown", "KeyboardKey", @["key"]),
    ("IsKeyReleased", "KeyboardKey", @["key"]),
    ("IsKeyUp", "KeyboardKey", @["key"]),
    ("SetExitKey", "KeyboardKey", @["key"]),
    ("GetKeyPressed", "KeyboardKey", @["returnType"]),
    ("SetCameraPanControl", "KeyboardKey", @["keyPan"]),
    ("SetCameraAltControl", "KeyboardKey", @["keyAlt"]),
    ("SetCameraSmoothZoomControl", "KeyboardKey", @["keySmoothZoom"]),
    ("SetCameraMoveControls", "KeyboardKey", @["keyFront", "keyBack", "keyRight", "keyLeft", "keyUp", "keyDown"]),
    # GamepadButton
    ("IsGamepadButtonPressed", "GamepadButton", @["button"]),
    ("IsGamepadButtonDown", "GamepadButton", @["button"]),
    ("IsGamepadButtonReleased", "GamepadButton", @["button"]),
    ("IsGamepadButtonUp", "GamepadButton", @["button"]),
    ("GetGamepadButtonPressed", "GamepadButton", @["returnType"]),
    # GamepadAxis
    ("GetGamepadAxisMovement", "GamepadAxis", @["axis"]),
    # MouseCursor
    ("SetMouseCursor", "MouseCursor", @["cursor"]),
    # MouseButton
    ("IsMouseButtonPressed", "MouseButton", @["button"]),
    ("IsMouseButtonDown", "MouseButton", @["button"]),
    ("IsMouseButtonReleased", "MouseButton", @["button"]),
    ("IsMouseButtonUp", "MouseButton", @["button"]),
    # Gesture
    ("SetGesturesEnabled", "Flag[Gesture]", @["flags"]),
    ("IsGestureDetected", "Gesture", @["gesture"]),
    ("GetGestureDetected", "Gesture", @["returnType"]),
    # ConfigFlags
    ("SetConfigFlags", "Flag[ConfigFlags]", @["flags"]),
    ("IsWindowState", "ConfigFlags", @["flag"]),
    ("SetWindowState", "Flag[ConfigFlags]", @["flags"]),
    ("ClearWindowState", "Flag[ConfigFlags]", @["flags"]),
    # TraceLogLevel
    ("TraceLog", "TraceLogLevel", @["logLevel"]),
    ("SetTraceLogLevel", "TraceLogLevel", @["logLevel"]),
    # CameraMode
    ("SetCameraMode", "CameraMode", @["mode"]),
    # BlendMode
    ("BeginBlendMode", "BlendMode", @["mode"]),
    # MaterialMapIndex
    ("SetMaterialTexture", "MaterialMapIndex", @["mapType"]),
    # ShaderUniformDataType
    ("SetShaderValue", "ShaderUniformDataType", @["uniformType"]),
    ("SetShaderValueV", "ShaderUniformDataType", @["uniformType"]),
    # PixelFormat
    ("LoadImageRaw", "PixelFormat", @["format"]),
    ("ImageFormat", "PixelFormat", @["newFormat"]),
    ("GetPixelColor", "PixelFormat", @["format"]),
    ("SetPixelColor", "PixelFormat", @["format"]),
    ("GetPixelDataSize", "PixelFormat", @["format"]),
    # TextureFilter
    ("SetTextureFilter", "TextureFilter", @["filter"]),
    # TextureWrap
    ("SetTextureWrap", "TextureWrap", @["wrap"]),
    # CubemapLayout
    ("LoadTextureCubemap", "CubemapLayout", @["layout"]),
    # FontType
    ("LoadFontData", "FontType", @["type"]),
  ]
  excluded = [
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
    "MemAlloc",
    "MemRealloc",
    "MemFree",
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
    "DecodeDataBase64"
  ]
  raylibDestructors = """

proc `=destroy`*(x: var Image) =
  if x.data != nil: unloadImage(x)
proc `=copy`*(dest: var Image; source: Image) =
  if dest.data != source.data:
    `=destroy`(dest)
    wasMoved(dest)
    dest = imageCopy(source)

proc `=destroy`*(x: var Texture) =
  if x.id > 0: unloadTexture(x)
proc `=copy`*(dest: var Texture; source: Texture) {.error.}

proc `=destroy`*(x: var RenderTexture) =
  if x.id > 0: unloadRenderTexture(x)
proc `=copy`*(dest: var RenderTexture; source: RenderTexture) {.error.}

proc `=destroy`*(x: var Font) =
  if x.texture.id > 0: unloadFont(x)
proc `=copy`*(dest: var Font; source: Font) {.error.}

proc `=destroy`*(x: var Mesh) =
  if x.vboId != nil: unloadMesh(x)
proc `=copy`*(dest: var Mesh; source: Mesh) {.error.}

proc `=destroy`*(x: var Shader) =
  if x.id > 0: unloadShader(x)
proc `=copy`*(dest: var Shader; source: Shader) {.error.}

proc `=destroy`*(x: var Material) =
  if x.maps != nil: unloadMaterial(x)
proc `=copy`*(dest: var Material; source: Material) {.error.}

proc `=destroy`*(x: var Model) =
  if x.meshes != nil: unloadModel(x)
proc `=copy`*(dest: var Model; source: Model) {.error.}

proc `=destroy`*(x: var ModelAnimation) =
  if x.framePoses != nil: unloadModelAnimation(x)
proc `=copy`*(dest: var ModelAnimation; source: ModelAnimation) {.error.}

proc `=destroy`*(x: var Wave) =
  if x.data != nil: unloadWave(x)
proc `=copy`*(dest: var Wave; source: Wave) =
  if dest.data != source.data:
    `=destroy`(dest)
    wasMoved(dest)
    dest = waveCopy(source)

proc `=destroy`*(x: var AudioStream) =
  if x.buffer != nil: unloadAudioStream(x)
proc `=copy`*(dest: var AudioStream; source: AudioStream) {.error.}

proc `=destroy`*(x: var Sound) =
  if x.stream.buffer != nil: unloadSound(x)
proc `=copy`*(dest: var Sound; source: Sound) {.error.}

proc `=destroy`*(x: var Music) =
  if x.stream.buffer != nil: unloadMusicStream(x)
proc `=copy`*(dest: var Music; source: Music) {.error.}
"""
  callbacks = """

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
"""

const
  raylibApi = "../api/raylib_api.json"
  outputname = "../raylib.nim"

proc main =
  template str(x: string) =
    buf.setLen 0
    let isKeyw = isKeyword(x)
    if isKeyw:
      buf.add '`'
    buf.add x
    if isKeyw:
      buf.add '`'
    otp.write buf
  template lit(x: string) = otp.write x
  template ind =
    buf.setLen 0
    addIndent(buf, indent)
    otp.write buf
  template doc(x: untyped) =
    if x.description != "":
      lit " ## "
      lit x.description
  template scp(body: untyped) =
    inc indent, indWidth
    body
    dec indent, indWidth

  var top = parseApi(raylibApi)

  var buf = newStringOfCap(50)
  var indent = 0
  var otp: FileStream
  try:
    otp = openFileStream(outputname, fmWrite)
    lit header
    # Generate type definitions
    lit "\ntype"
    scp:
      for obj in items(top.structs):
        ind
        str obj.name
        lit "* {.bycopy.} = object"
        doc obj
        scp:
          for fld in items(obj.fields):
            ind
            var (name, sub) = transFieldName(fld.name)
            str name
            lit "*: "
            if obj.name == "Camera3D" and name == "projection":
              lit "CameraProjection"
            elif obj.name == "Image" and name == "format":
              lit "PixelFormat"
            elif obj.name == "Texture" and name == "format":
              lit "PixelFormat"
            elif obj.name == "NPatchInfo" and name == "layout":
              lit "NPatchLayout"
            else:
              let many = hasMany(fld.name) or
                  (obj.name == "Model" and (fld.name == "meshMaterial" or fld.name == "bindPose"))
              if obj.name == "ModelAnimation" and fld.name == "framePoses":
                sub = "ptr UncheckedArray[ptr UncheckedArray[$1]]"
              elif obj.name == "Mesh" and fld.name == "vboId":
                sub = "ptr array[MaxMeshVertexBuffers, $1]"
              elif obj.name == "Material" and fld.name == "maps":
                sub = "ptr array[MaxMaterialMaps, $1]"
              elif obj.name == "Shader" and fld.name == "locs":
                sub = "ptr array[MaxShaderLocations, $1]"
              let kind = convertType(fld.`type`, sub, many)
              lit kind
            doc fld
        case obj.name
        of "Vector4":
          ind
          lit extraTypes[0]
        of "AudioStream":
          ind
          lit extraTypes[5]
        of "Texture":
          ind
          lit extraTypes[1]
          ind
          lit extraTypes[2]
        of "RenderTexture":
          ind
          lit extraTypes[3]
        of "Camera3D":
          ind
          lit extraTypes[4]
        lit "\n"
      for enm in mitems(top.enums):
        ind
        str enm.name
        lit "* {.size: sizeof(cint).} = enum"
        doc enm
        scp:
          proc cmpValueInfo(x, y: ValueInfo): int = cmp(x.value, y.value)
          sort(enm.values, cmpValueInfo)
          let allSeq = allSequential(enm.values)
          for (i, val) in mpairs(enm.values):
            if i-1>=0 and enm.values[i-1].value == val.value: # duplicate!
              continue
            ind
            for (name, prefix) in enumPrefixes.items:
              if enm.name == name:
                removePrefix(val.name, prefix)
                break
            str camelCaseAscii(val.name)
            if not allSeq or (i == 0 and val.value != 0):
              lit " = "
              lit $val.value
            doc val
          lit "\n"
    lit callbacks
    lit flagsHelper
    lit duplicateVal
    lit colors
    for fnc in items(top.functions):
      if fnc.name in excluded: continue
      lit "\nproc "
      str uncapitalizeAscii(fnc.name)
      lit "*("
      var hasVarargs = false
      for i, (name, kind) in fnc.params.pairs:
        if name == "" and kind == "":
          hasVarargs = true
        else:
          if i > 0: lit ", "
          str name
          lit ": "
          block outer:
            for (fname, kind, params) in enumInFuncParams.items:
              if fname == fnc.name and name in params:
                lit kind
                break outer
            let many = (fnc.name != "LoadImageAnim" or name != "frames") and hasMany(name)
            var pat = ""
            if fnc.name == "GenImageFontAtlas" and name == "recs":
              pat = "ptr ptr UncheckedArray[$1]"
            let kind = convertType(kind, pat, many)
            lit kind
      lit ")"
      if fnc.returnType != "void":
        lit ": "
        block outer:
          for (fname, kind, params) in enumInFuncParams.items:
            if fname == fnc.name and "returnType" in params:
              lit kind
              break outer
          let many = hasMany(fnc.name) or fnc.name == "LoadImagePalette"
          let kind = convertType(fnc.returnType, "", many)
          str kind
      lit " {.importc: \""
      str fnc.name
      lit "\""
      if hasVarargs:
        lit ", varargs"
      lit ", rlapi.}"
      scp:
        if fnc.description != "":
          ind
          lit "## "
          lit fnc.description
    lit "\n"
    lit raylibDestructors
  finally:
    if otp != nil: otp.close()

main()
