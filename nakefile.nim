import nake
# Only Linux is supported!

const
  RaylibStableCommit = "4f2bfc54760cbcbf142417b0bb24ddebf9ee4221"
  SourceDir = currentSourcePath().parentDir
  CIncludeDir = SourceDir / "cinclude"
  RaylibDir = SourceDir / "dist" / "raylib"

proc fetchLatestRaylib =
  if not dirExists(RaylibDir):
    direShell("git clone --depth 1 https://github.com/raysan5/raylib.git", RaylibDir)
  withDir(RaylibDir):
    direShell("git fetch")
    direShell("git checkout", RaylibStableCommit)

task "static", "Builds raylib C static library":
  fetchLatestRaylib()
  withDir(RaylibDir / "src"):
    direShell("make clean")
    direShell("make PLATFORM=PLATFORM_DESKTOP -j4")
    # Install to cinclude directory
    discard existsOrCreateDir(CIncludeDir)
    copyFileToDir("libraylib.a", CIncludeDir)
    copyFileToDir("raylib.h", CIncludeDir)

task "parse", "Produces JSON API files":
  let parser = "raylib_parser"
  let header = RaylibDir / "src" / "raylib.h"
  fetchLatestRaylib()
  withDir(RaylibDir / "parser"):
    let exe = parser.addFileExt(ExeExt)
    direShell("cc", parser & ".c", "-o", exe)
    direShell($CurDir / exe, "-f JSON", "-d RLAPI", "-i", header, "-o", SourceDir / "api")
