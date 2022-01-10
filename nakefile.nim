import nake
# Only Linux is supported!

const
  RaylibStableCommit = "0851960397f02a477d80eda2239f90fae14dec64"
  SourceDir = currentSourcePath().parentDir
  RaylibDir = SourceDir / "dist" / "raylib"

task "static", "Builds raylib C static library":
  if not dirExists(RaylibDir):
    direShell("git clone --depth 1 https://github.com/raysan5/raylib.git", RaylibDir)
  withDir(RaylibDir):
    direShell("git fetch")
    direShell("git checkout", RaylibStableCommit)
    withDir("src"):
      direShell("make clean")
      direShell("make PLATFORM=PLATFORM_DESKTOP -j4")
      copyFileToDir("libraylib.a", SourceDir)

task "parse", "Produces JSON API files":
  let parser = "raylib_parser"
  let header = RaylibDir / "src" / "raylib.h"
  assert dirExists(RaylibDir), "Run task 'static' first"
  withDir(RaylibDir / "parser"):
    direShell("cc", parser.addFileExt(".c"), "-o", parser)
    direShell(findExe(parser), "-f JSON", "-d RLAPI", "-i", header, "-o", SourceDir / "api")
