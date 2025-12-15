# ****************************************************************************************
#
#   Naylib configuration flags
#
#   This file defines all the configuration flags for the different Naylib modules
#   Converted from raylib's config.h
#
#   LICENSE: zlib/libpng
#
# ****************************************************************************************

{.passC: "-DEXTERNAL_CONFIG_FLAGS".}

# Module selection - Some modules could be avoided
# Mandatory modules: rcore, rlgl, utils
const NaylibSupportModuleRshapes {.booldefine.} = true
when NaylibSupportModuleRshapes:
  {.passC: "-DSUPPORT_MODULE_RSHAPES=1".}

const NaylibSupportModuleRtextures {.booldefine.} = true
when NaylibSupportModuleRtextures:
  {.passC: "-DSUPPORT_MODULE_RTEXTURES=1".}

const NaylibSupportModuleRtext {.booldefine.} = true
when NaylibSupportModuleRtext:
  {.passC: "-DSUPPORT_MODULE_RTEXT=1".}  # WARNING: It requires SUPPORT_MODULE_RTEXTURES to load sprite font textures

const NaylibSupportModuleRmodels {.booldefine.} = true
when NaylibSupportModuleRmodels:
  {.passC: "-DSUPPORT_MODULE_RMODELS=1".}

const NaylibSupportModuleRaudio {.booldefine.} = true
when NaylibSupportModuleRaudio:
  {.passC: "-DSUPPORT_MODULE_RAUDIO=1".}

# ----------------------------------------------------------------------------------------
# Module: rcore - Configuration Flags
# ----------------------------------------------------------------------------------------

# Camera module is included (rcamera.h) and multiple predefined cameras are available
const NaylibSupportCameraSystem {.booldefine.} = true
when NaylibSupportCameraSystem:
  {.passC: "-DSUPPORT_CAMERA_SYSTEM=1".}

# Gestures module is included (rgestures.h) to support gestures detection
const NaylibSupportGesturesSystem {.booldefine.} = true
when NaylibSupportGesturesSystem:
  {.passC: "-DSUPPORT_GESTURES_SYSTEM=1".}

# Include pseudo-random numbers generator (rprand.h)
const NaylibSupportRprandGenerator {.booldefine.} = false
when NaylibSupportRprandGenerator:
  {.passC: "-DSUPPORT_RPRAND_GENERATOR=1".}

# Mouse gestures are directly mapped like touches
const NaylibSupportMouseGestures {.booldefine.} = true
when NaylibSupportMouseGestures:
  {.passC: "-DSUPPORT_MOUSE_GESTURES=1".}

# Reconfigure standard input for SSH connection
const NaylibSupportSshKeyboardRpi {.booldefine.} = true
when NaylibSupportSshKeyboardRpi:
  {.passC: "-DSUPPORT_SSH_KEYBOARD_RPI=1".}

# High resolution timer support
const NaylibSupportWinmmHighresTimer {.booldefine.} = true
when NaylibSupportWinmmHighresTimer:
  {.passC: "-DSUPPORT_WINMM_HIGHRES_TIMER=1".}

# Busy wait loop timing support
const NaylibSupportBusyWaitLoop {.booldefine.} = false
when NaylibSupportBusyWaitLoop:
  {.passC: "-DSUPPORT_BUSY_WAIT_LOOP=1".}

# Partial busy wait loop support
const NaylibSupportPartialBusyWaitLoop {.booldefine.} = true
when NaylibSupportPartialBusyWaitLoop:
  {.passC: "-DSUPPORT_PARTIALBUSY_WAIT_LOOP=1".}

# Screen capture support
const NaylibSupportScreenCapture {.booldefine.} = true
when NaylibSupportScreenCapture:
  {.passC: "-DSUPPORT_SCREEN_CAPTURE=1".}

# Compression API support
const NaylibSupportCompressionApi {.booldefine.} = true
when NaylibSupportCompressionApi:
  {.passC: "-DSUPPORT_COMPRESSION_API=1".}

# Automation events support
const NaylibSupportAutomationEvents {.booldefine.} = true
when NaylibSupportAutomationEvents:
  {.passC: "-DSUPPORT_AUTOMATION_EVENTS=1".}

# Custom frame control support
const NaylibSupportCustomFrameControl {.booldefine.} = false
when NaylibSupportCustomFrameControl:
  {.passC: "-DSUPPORT_CUSTOM_FRAME_CONTROL=1".}

# Clipboard image support
const NaylibSupportClipboardImage {.booldefine.} = false
when NaylibSupportClipboardImage:
  {.passC: "-DSUPPORT_CLIPBOARD_IMAGE=1".}

# ----------------------------------------------------------------------------------------
# Module: rlgl - Configuration Flags
# ----------------------------------------------------------------------------------------

# Enable OpenGL Debug Context (only available on OpenGL 4.3)
const NaylibRlEnableOpenglDebugContext {.booldefine.} = false
when NaylibRlEnableOpenglDebugContext:
  {.passC: "-DRLGL_ENABLE_OPENGL_DEBUG_CONTEXT=1".}

# Show OpenGL extensions and capabilities detailed logs on init
const NaylibRlShowGlDetailsInfo {.booldefine.} = false
when NaylibRlShowGlDetailsInfo:
  {.passC: "-DRLGL_SHOW_GL_DETAILS_INFO=1".}

# GPU skinning support
const NaylibRlSupportMeshGpuSkinning {.booldefine.} = true
when NaylibRlSupportMeshGpuSkinning:
  {.passC: "-DRL_SUPPORT_MESH_GPU_SKINNING=1".}

# ----------------------------------------------------------------------------------------
# Module: rshapes - Configuration Flags
# ----------------------------------------------------------------------------------------

# Use QUADS instead of TRIANGLES for drawing when possible
const NaylibSupportQuadsDrawMode {.booldefine.} = true
when NaylibSupportQuadsDrawMode:
  {.passC: "-DSUPPORT_QUADS_DRAW_MODE=1".}

# ----------------------------------------------------------------------------------------
# Module: rtextures - Configuration Flags
# ----------------------------------------------------------------------------------------

# Image format support
const NaylibSupportFileFormatPng {.booldefine.} = true
when NaylibSupportFileFormatPng:
  {.passC: "-DSUPPORT_FILEFORMAT_PNG=1".}

const NaylibSupportFileFormatBmp {.booldefine.} = false
when NaylibSupportFileFormatBmp:
  {.passC: "-DSUPPORT_FILEFORMAT_BMP=1".}

const NaylibSupportFileFormatTga {.booldefine.} = false
when NaylibSupportFileFormatTga:
  {.passC: "-DSUPPORT_FILEFORMAT_TGA=1".}

const NaylibSupportFileFormatJpg {.booldefine.} = false
when NaylibSupportFileFormatJpg:
  {.passC: "-DSUPPORT_FILEFORMAT_JPG=1".}

const NaylibSupportFileFormatGif {.booldefine.} = true
when NaylibSupportFileFormatGif:
  {.passC: "-DSUPPORT_FILEFORMAT_GIF=1".}

const NaylibSupportFileFormatQoi {.booldefine.} = true
when NaylibSupportFileFormatQoi:
  {.passC: "-DSUPPORT_FILEFORMAT_QOI=1".}

const NaylibSupportFileFormatPsd {.booldefine.} = false
when NaylibSupportFileFormatPsd:
  {.passC: "-DSUPPORT_FILEFORMAT_PSD=1".}

const NaylibSupportFileFormatDds {.booldefine.} = true
when NaylibSupportFileFormatDds:
  {.passC: "-DSUPPORT_FILEFORMAT_DDS=1".}

const NaylibSupportFileFormatHdr {.booldefine.} = false
when NaylibSupportFileFormatHdr:
  {.passC: "-DSUPPORT_FILEFORMAT_HDR=1".}

const NaylibSupportFileFormatPic {.booldefine.} = false
when NaylibSupportFileFormatPic:
  {.passC: "-DSUPPORT_FILEFORMAT_PIC=1".}

const NaylibSupportFileFormatKtx {.booldefine.} = false
when NaylibSupportFileFormatKtx:
  {.passC: "-DSUPPORT_FILEFORMAT_KTX=1".}

const NaylibSupportFileFormatAstc {.booldefine.} = false
when NaylibSupportFileFormatAstc:
  {.passC: "-DSUPPORT_FILEFORMAT_ASTC=1".}

const NaylibSupportFileFormatPkm {.booldefine.} = false
when NaylibSupportFileFormatPkm:
  {.passC: "-DSUPPORT_FILEFORMAT_PKM=1".}

const NaylibSupportFileFormatPvr {.booldefine.} = false
when NaylibSupportFileFormatPvr:
  {.passC: "-DSUPPORT_FILEFORMAT_PVR=1".}

# Image manipulation support
const NaylibSupportImageExport {.booldefine.} = true
when NaylibSupportImageExport:
  {.passC: "-DSUPPORT_IMAGE_EXPORT=1".}

const NaylibSupportImageGeneration {.booldefine.} = true
when NaylibSupportImageGeneration:
  {.passC: "-DSUPPORT_IMAGE_GENERATION=1".}

const NaylibSupportImageManipulation {.booldefine.} = true
when NaylibSupportImageManipulation:
  {.passC: "-DSUPPORT_IMAGE_MANIPULATION=1".}

# ----------------------------------------------------------------------------------------
# Module: rtext - Configuration Flags
# ----------------------------------------------------------------------------------------

const NaylibSupportDefaultFont {.booldefine.} = true
when NaylibSupportDefaultFont:
  {.passC: "-DSUPPORT_DEFAULT_FONT=1".}

const NaylibSupportFileFormatTtf {.booldefine.} = true
when NaylibSupportFileFormatTtf:
  {.passC: "-DSUPPORT_FILEFORMAT_TTF=1".}

const NaylibSupportFileFormatFnt {.booldefine.} = true
when NaylibSupportFileFormatFnt:
  {.passC: "-DSUPPORT_FILEFORMAT_FNT=1".}

const NaylibSupportFileFormatBdf {.booldefine.} = false
when NaylibSupportFileFormatBdf:
  {.passC: "-DSUPPORT_FILEFORMAT_BDF=1".}

const NaylibSupportTextManipulation {.booldefine.} = true
when NaylibSupportTextManipulation:
  {.passC: "-DSUPPORT_TEXT_MANIPULATION=1".}

const NaylibSupportFontAtlasWhiteRec {.booldefine.} = true
when NaylibSupportFontAtlasWhiteRec:
  {.passC: "-DSUPPORT_FONT_ATLAS_WHITE_REC=1".}

const NaylibSupportAtlasSizeConservative {.booldefine.} = false
when NaylibSupportAtlasSizeConservative:
  {.passC: "-DSUPPORT_FONT_ATLAS_SIZE_CONSERVATIVE=1".}

# ----------------------------------------------------------------------------------------
# Module: rmodels - Configuration Flags
# ----------------------------------------------------------------------------------------

const NaylibSupportFileFormatObj {.booldefine.} = true
when NaylibSupportFileFormatObj:
  {.passC: "-DSUPPORT_FILEFORMAT_OBJ=1".}

const NaylibSupportFileFormatMtl {.booldefine.} = true
when NaylibSupportFileFormatMtl:
  {.passC: "-DSUPPORT_FILEFORMAT_MTL=1".}

const NaylibSupportFileFormatIqm {.booldefine.} = true
when NaylibSupportFileFormatIqm:
  {.passC: "-DSUPPORT_FILEFORMAT_IQM=1".}

const NaylibSupportFileFormatGltf {.booldefine.} = true
when NaylibSupportFileFormatGltf:
  {.passC: "-DSUPPORT_FILEFORMAT_GLTF=1".}

const NaylibSupportFileFormatVox {.booldefine.} = true
when NaylibSupportFileFormatVox:
  {.passC: "-DSUPPORT_FILEFORMAT_VOX=1".}

const NaylibSupportFileFormatM3d {.booldefine.} = true
when NaylibSupportFileFormatM3d:
  {.passC: "-DSUPPORT_FILEFORMAT_M3D=1".}

const NaylibSupportMeshGeneration {.booldefine.} = true
when NaylibSupportMeshGeneration:
  {.passC: "-DSUPPORT_MESH_GENERATION=1".}

# ----------------------------------------------------------------------------------------
# Module: raudio - Configuration Flags
# ----------------------------------------------------------------------------------------

const NaylibSupportFileFormatWav {.booldefine.} = true
when NaylibSupportFileFormatWav:
  {.passC: "-DSUPPORT_FILEFORMAT_WAV=1".}

const NaylibSupportFileFormatOgg {.booldefine.} = true
when NaylibSupportFileFormatOgg:
  {.passC: "-DSUPPORT_FILEFORMAT_OGG=1".}

const NaylibSupportFileFormatMp3 {.booldefine.} = true
when NaylibSupportFileFormatMp3:
  {.passC: "-DSUPPORT_FILEFORMAT_MP3=1".}

const NaylibSupportFileFormatQoa {.booldefine.} = true
when NaylibSupportFileFormatQoa:
  {.passC: "-DSUPPORT_FILEFORMAT_QOA=1".}

const NaylibSupportFileFormatFlac {.booldefine.} = false
when NaylibSupportFileFormatFlac:
  {.passC: "-DSUPPORT_FILEFORMAT_FLAC=1".}

const NaylibSupportFileFormatXm {.booldefine.} = true
when NaylibSupportFileFormatXm:
  {.passC: "-DSUPPORT_FILEFORMAT_XM=1".}

const NaylibSupportFileFormatMod {.booldefine.} = true
when NaylibSupportFileFormatMod:
  {.passC: "-DSUPPORT_FILEFORMAT_MOD=1".}

# ----------------------------------------------------------------------------------------
# Module: utils - Configuration Flags
# ----------------------------------------------------------------------------------------

const NaylibSupportStandardFileio {.booldefine.} = true
when NaylibSupportStandardFileio:
  {.passC: "-DSUPPORT_STANDARD_FILEIO=1".}

const NaylibSupportTracelog {.booldefine.} = true
when NaylibSupportTracelog:
  {.passC: "-DSUPPORT_TRACELOG=1".}

const NaylibSupportTracelogDebug {.booldefine.} = false
when NaylibSupportTracelogDebug:
  {.passC: "-DSUPPORT_TRACELOG_DEBUG=1".}

