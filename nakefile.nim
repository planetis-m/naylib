import nake, std/strformat

const
  RayLatestCommit = "f6558fe6e0932863b83d2a6a49b8fc81b7354242"

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
    copyFileToDir("rlgl.h", inclDir)

task "build", "Build the raylib library for the default platform":
  buildRaylib("PLATFORM_DESKTOP")

task "buildDesktop", "Build the raylib library for the Desktop platform":
  buildRaylib("PLATFORM_DESKTOP")

task "buildRPi", "Build the raylib library for the RPi platform":
  buildRaylib("PLATFORM_RPI")

task "buildDRM", "Build the raylib library for the DRM platform":
  buildRaylib("PLATFORM_DRM")

task "buildAndroid", "Build the raylib library for the Android platform":
  buildRaylib("PLATFORM_ANDROID")

# The rest are meant for developers only!

proc genWrapper(lib: string) =
  let src = lib & "_gen.nim"
  withDir(pkgDir / "/tools"):
    var exe = src.changeFileExt(ExeExt)
    direSilentShell "Building the ray2nim tool...",
        "nim c --mm:arc --panics:on -d:release -d:emiLenient " & src
    normalizeExe(exe)
    direSilentShell &"Generating {lib} Nim wrapper...", exe

proc genApiJson(lib, prefix: string) =
  let src = "raylib_parser.c"
  fetchLatestRaylib()
  withDir(rayDir / "/parser"):
    var exe = src.changeFileExt(ExeExt)
    direSilentShell "Building raylib API parser...", &"cc {src} -o {exe}"
    discard existsOrCreateDir(apiDir)
    normalizeExe(exe)
    let header = rayDir / &"/src/{lib}.h"
    let apiJson = apiDir / &"/{lib}_api.json"
    direSilentShell &"Generating {lib} API JSON file...",
        exe & " -f JSON " & (if prefix != "": "-d " & prefix else: "") &
        &" -i {header} -o {apiJson}"

proc wrapRaylib(lib, prefix: string) =
  genApiJson(lib, prefix)
  genWrapper(lib)

task "wrap", "Produce all raylib nim wrappers":
  wrapRaylib("raylib", "RLAPI")
  # wrapRaylib("raymath", "RMAPI")
  wrapRaylib("rlgl", "")

task "wrapRaylib", "Produce the raylib nim wrapper":
  wrapRaylib("raylib", "RLAPI")

task "wrapRaymath", "Produce the raymath nim wrapper":
  wrapRaylib("raymath", "RMAPI")

task "wrapRlgl", "Produce the rlgl nim wrapper":
  # wrapRaylib("rlgl", "RLAPI")
  genWrapper("rlgl")

task "docs", "Generate documentation":
  # https://nim-lang.github.io/Nim/docgen.html
  withDir(pkgDir):
    for tmp in items(["raymath", "raylib"]):
      let doc = docsDir / tmp.addFileExt(".html")
      let src = "src/" / tmp
      direSilentShell(&"Generating the docs for {src}...",
          &"nim doc --verbosity:0 --git.url:https://github.com/planetis-m/naylib --git.devel:main --git.commit:main --out:{doc} {src}")
