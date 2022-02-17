import nake
# Only Linux is supported!

const
  RaylibStableCommit = "963de06d08f28784e03b6cfa994d545f9e0ef8b5"
  SourceDir = currentSourcePath().parentDir
  CIncludeDir = SourceDir / "cinclude"
  JsonApiDir = SourceDir / "api"
  RaylibDir = SourceDir / "dist" / "raylib"

proc fetchLatestRaylib =
  if not dirExists(RaylibDir):
    direShell("git clone --depth 1 https://github.com/raysan5/raylib.git", RaylibDir)
  withDir(RaylibDir):
    direShell("git fetch")
    direShell("git checkout", RaylibStableCommit)

task "build", "Builds the raylib C static library":
  fetchLatestRaylib()
  withDir(RaylibDir / "src"):
    direShell("make clean")
    direShell("make PLATFORM=PLATFORM_DESKTOP -j4")
    # Install to cinclude directory
    discard existsOrCreateDir(CIncludeDir)
    copyFileToDir("libraylib.a", CIncludeDir)
    copyFileToDir("raylib.h", CIncludeDir)

proc generateWrapper =
  let script = "raylib_gen"
  withDir(SourceDir / "gen"):
    direShell("nim", "c", "--mm:arc --panics:on -d:release -d:emiLenient", script)
    var exe = script.addFileExt(ExeExt)
    normalizeExe(exe)
    direShell(exe)

task "wrap", "Produces the raylib nim wrapper":
  let parser = "raylib_parser"
  let header = RaylibDir / "src" / "raylib.h"
  fetchLatestRaylib()
  withDir(RaylibDir / "parser"):
    var exe = parser.addFileExt(ExeExt)
    normalizeExe(exe)
    direShell("cc", parser.addFileExt(".c"), "-o", exe)
    direShell(exe, "-f JSON", "-d RLAPI", "-i", header, "-o", JsonApiDir / "raylib_api.json")
  generateWrapper()
