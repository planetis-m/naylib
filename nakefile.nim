import nake
# Only Linux is supported!

const
  RaylibStableCommit = "0851960397f02a477d80eda2239f90fae14dec64"
  SourceDir = currentSourcePath().parentDir
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
    copyFileToDir("libraylib.a", SourceDir)

task "parse", "Produces JSON API files":
  let parser = "raylib_parser"
  let header = RaylibDir / "src" / "raylib.h"
  fetchLatestRaylib()
  withDir(RaylibDir / "parser"):
    let exe = parser & ExeExt
    direShell("cc", parser & ".c", "-o", exe)
    direShell("./" & exe, "-f JSON", "-d RLAPI", "-i", header, "-o", SourceDir / "api")
