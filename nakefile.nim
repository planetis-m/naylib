import nake, std/strformat

const
  RayLatestCommit = "8f88c61bdfe1e6e009dd6f182bc7a2f5c8b38f15"

const
  pkgDir = currentSourcePath().parentDir.quoteShell
  rayDir = pkgDir / "/dist/raylib"
  inclDir = pkgDir / "/src/include"
  apiDir = pkgDir / "/api"
  docsDir = pkgDir / "/docs"

proc fetchLatestRaylib =
  if not dirExists(rayDir):
    direSilentShell "Cloning raysan/raylib...",
        "git clone --depth 1 https://github.com/raysan5/raylib.git " & rayDir
  withDir(rayDir):
    direSilentShell "Fetching latest commit...",
        &"git fetch --depth 1 origin {RayLatestCommit}; git checkout {RayLatestCommit}"

# proc fetchStableRaylib =
#   if not dirExists(rayDir):
#     direSilentShell "Cloning raysan/raylib at tag...",
#         "git clone -b '4.2.0' --depth 1 https://github.com/raysan5/raylib.git " & rayDir

proc buildRaylib(platform: string, wayland = false) =
  fetchLatestRaylib()
  withDir(rayDir / "/src"):
    const exe = when defined(windows): "mingw32-make" else: "make"
    direSilentShell "Building raylib static library...",
        &"{exe} clean && {exe} -j4 PLATFORM={platform}" &
        (if wayland: " USE_WAYLAND_DISPLAY=TRUE" else: "")
    echo "Copying to C include directory..."
    discard existsOrCreateDir(inclDir)
    copyFileToDir("libraylib.a", inclDir)
    copyFileToDir("raylib.h", inclDir)

task "buildDesktop", "Build the raylib library for the Desktop platform":
  buildRaylib("PLATFORM_DESKTOP")

task "buildRPi", "Build the raylib library for the RPi platform":
  buildRaylib("PLATFORM_RPI")

task "buildDRM", "Build the raylib library for the DRM platform":
  buildRaylib("PLATFORM_DRM")

task "buildAndroid", "Build the raylib library for the Android platform":
  buildRaylib("PLATFORM_ANDROID")

# The rest are meant for developers only!

proc generateWrapper =
  let src = "raylib_gen.nim"
  withDir(pkgDir / "/tools"):
    var exe = src.changeFileExt(ExeExt)
    direSilentShell "Building raylib2nim tool...",
        "nim c --mm:arc --panics:on -d:release -d:emiLenient " & src
    normalizeExe(exe)
    direSilentShell "Generating raylib Nim wrapper...", exe

task "wrap", "Produce the raylib nim wrapper":
  let src = "raylib_parser.c"
  let header = rayDir / "/src/raylib.h"
  fetchLatestRaylib()
  withDir(rayDir / "/parser"):
    var exe = src.changeFileExt(ExeExt)
    direSilentShell "Building raylib API parser...", &"cc {src} -o {exe}"
    discard existsOrCreateDir(apiDir)
    normalizeExe(exe)
    direSilentShell "Generating API JSON file...",
        &"{exe} -f JSON -d RLAPI -i {header} -o {apiDir / \"/raylib_api.json\"}"
  generateWrapper()

task "docs", "Generate documentation":
  # https://nim-lang.github.io/Nim/docgen.html
  withDir(pkgDir):
    for tmp in items(["raymath", "raylib"]):
      let doc = docsDir / tmp.addFileExt(".html")
      let src = "src/" / tmp
      direSilentShell(&"Generating the docs for {src}...",
          &"nim doc --verbosity:0 --git.url:https://github.com/planetis-m/naylib --git.devel:main --git.commit:main --out:{doc} {src}")
