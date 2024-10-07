import std/[algorithm, sets, tables, sequtils, strutils]
when defined(nimPreviewSlimSystem):
  from std/syncio import readFile
import common, newdsl

const
  raylibHeader = readFile("raylib_header.nim")
  destructorHooks = readFile("raylib_types.nim")
  manualWrappers = readFile("raylib_wrap.nim")
  arrayAccessors = readFile("raylib_fields.nim")
  opaqueStructs = """
  rAudioBuffer {.importc, nodecl, bycopy.} = object
  rAudioProcessor {.importc, nodecl, bycopy.} = object
"""
  bitsetsHelperAndDuplicateValues = """
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
  callbacksAndColors = """

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
  privateFuncs = toHashSet([
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
  wrappedFuncs = toHashSet([
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
  noSideeffectsFuncs = toHashSet([
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
  mangledFuncs = toHashSet([
    "ShowCursor",
    "CloseWindow",
    "LoadImage",
    "DrawText",
    "DrawTextEx"
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

proc preprocessStructs(ctx: var ApiContext) =
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
    obj.name == "AutomationEventList" or
    (obj.name, fld.name) in {
      "MaterialMap": "texture",
      "Material": "shader",
      "AudioStream": "buffer",
      "AudioStream": "processor"
    }

  for obj in mitems(ctx.api.structs):
    if obj.name == "Rectangle":
      obj.flags.incl isMangled
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
        ctx.readOnlyFieldAccessors.add (struct: obj.name, field: fld.name, `type`: fieldType)
      if isArray:
        let tmp = capitalizeAscii(fld.name)
        ctx.boundCheckedArrayAccessors.add (struct: obj.name & tmp, field: obj.name, `type`: "")
      if shouldBePrivate(obj, fld, isArray, isPrivate in fld.flags + obj.flags):
        fld.flags.incl isPrivate
      fld.`type` = fieldType

proc preprocessEnums(ctx: var ApiContext) =
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
      if name.startsWith(prefix):
        result.removePrefix(prefix)
        break

  for enm in mitems(ctx.api.enums):
    sort(enm.values, proc (x, y: ValueInfo): int = cmp(x.value, y.value))
    for val in mitems(enm.values):
      val.name = removeCommonPrefixes(val.name).camelCaseAscii()

proc preprocessAliases(ctx: var ApiContext) =
  for alias in mitems(ctx.api.aliases):
    if alias.name == "Quaternion":
      alias.flags.incl isDistinct

proc preprocessFunctions(ctx: var ApiContext) =
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
    kind == "cstring" and fnc.name notin wrappedFuncs and hasVarargs notin fnc.flags

  proc checkOpenarrayType(fnc: FunctionInfo, kind: string, many: bool, nextName: string): bool =
    kind != "pointer" and many and ((nextName == "count" or nextName.endsWith("Count")) or
        (nextName == "size" or nextName.endsWith("Size"))) and
        fnc.name notin wrappedFuncs and hasVarargs notin fnc.flags

  keepIf(ctx.api.functions, proc (x: FunctionInfo): bool = x.name notin excludedFuncs)
  for fnc in mitems(ctx.api.functions):
    if fnc.name in mangledFuncs:
      fnc.flags.incl isMangled
    if fnc.name in wrappedFuncs:
      fnc.flags.incl isWrappedFunc
      fnc.flags.incl isPrivate
    if fnc.name in privateFuncs:
      fnc.flags.incl isPrivate
    if fnc.name in noSideeffectsFuncs:
      fnc.flags.incl isFunc

    proc isVarargsParam(param: ParamInfo): bool =
      param.name == "args" and param.`type` == "..."

    if fnc.params.len > 0:
      if isVarargsParam(fnc.params[^1]):
        fnc.flags.incl hasVarargs
        fnc.params.setLen(fnc.params.high)

    var autoWrap = false
    for i, param in fnc.params.mpairs:
      let many = shouldUsePluralType(fnc, param)
      let (paramType, baseType) = convertType(param.`type`, many)
      if checkCstringType(fnc, paramType):
        param.flags.incl isString
        autoWrap = true
      if i < fnc.params.high and checkOpenarrayType(fnc, paramType, many, fnc.params[i+1].name):
        param.baseType = baseType
        param.flags.incl isOpenArray
        autoWrap = true
      if paramType.startsWith("var "):
        param.flags.incl isVarParam
        param.baseType = baseType
    if fnc.returnType != "void":
      let (returnType, baseType) = convertType(fnc.returnType, false)
      if checkCstringType(fnc, returnType):
        fnc.flags.incl isString
        autoWrap = true
      if baseType in needErrorChecking and fnc.name notin privateFuncs:
        echo "WARNING: Function might require error checking: ", fnc.name

    if autoWrap:
      fnc.flags.incl isWrappedFunc
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

    fnc.importName = (if isMangled in fnc.flags: "rl" else: "") & fnc.name
    fnc.name = generateProcName(fnc)
    if autoWrap:
      ctx.funcsToWrap.add fnc

const
  raylibApi = "../api/raylib.json"
  outputname = "../src/raylib.nim"

proc preprocessApi(ctx: var ApiContext) =
  preprocessStructs(ctx)
  preprocessEnums(ctx)
  preprocessAliases(ctx)
  preprocessFunctions(ctx)

proc generateOutput(ctx: ApiContext) =
  var b = openBuilder(outputname)
  genBindings(b, ctx,
              moduleHeader = raylibHeader, afterEnums = bitsetsHelperAndDuplicateValues,
              afterObjects = opaqueStructs & callbacksAndColors, afterFuncs = destructorHooks & arrayAccessors,
              moduleEnd = manualWrappers)
  b.close()

proc main =
  var ctx = ApiContext(api: parseApi(raylibApi))
  preprocessApi(ctx)
  generateOutput(ctx)

main()
