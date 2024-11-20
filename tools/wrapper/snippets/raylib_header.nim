from std/strutils import addf, toHex
from std/unicode import Rune
from std/syncio import writeFile
import std/[assertions, paths]
import private/rconfig
const raylibDir = currentSourcePath().Path.parentDir / Path"raylib"

{.passC: "-I" & raylibDir.string.}
{.passC: "-I" & string(raylibDir / Path"external/glfw/include").}
{.passC: "-Wall -D_GNU_SOURCE -Wno-missing-braces -Werror=pointer-arith".}
when defined(emscripten):
  {.passC: "-DPLATFORM_WEB".}
  when defined(GraphicsApiOpenGlEs3):
    {.passC: "-DGRAPHICS_API_OPENGL_ES3".}
    {.passL: "-sMIN_WEBGL_VERSION=2 -sMAX_WEBGL_VERSION=2".}
  else: {.passC: "-DGRAPHICS_API_OPENGL_ES2".}
  const NaylibWebHeapSize {.intdefine.} = 134217728  # 128MiB default
  {.passL: "-sUSE_GLFW=3 -sWASM=1 -sTOTAL_MEMORY=" & $NaylibWebHeapSize.}
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
{.compile: raylibDir / Path"rcore.c".}
{.compile: raylibDir / Path"rshapes.c".}
{.compile: raylibDir / Path"rtextures.c".}
{.compile: raylibDir / Path"rtext.c".}
{.compile: raylibDir / Path"utils.c".}
{.compile: raylibDir / Path"rmodels.c".}
{.compile: raylibDir / Path"raudio.c".}
when defined(android):
  {.compile: AndroidNdk.Path / Path"sources/android/native_app_glue/android_native_app_glue.c".}

const
  RaylibVersion* = (5, 5, 0)

  # Taken from raylib/src/config.h
  MaxShaderLocations* = 32 ## Maximum number of shader locations supported
  MaxMaterialMaps* = 12 ## Maximum number of shader maps supported
  MaxMeshVertexBuffers* = 9 ## Maximum vertex buffers (VBO) per mesh
