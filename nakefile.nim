import nake, std/strformat
# Only Linux is supported!

const
  ProjectUrl = "https://github.com/planetis-m/raylib-fever"
  GitUrl = "https://github.com/raysan5/raylib.git"
  RaylibStableCommit = "d4382f4a52e7631bf02ff8073ed24b282596ce0a"
  SourceDir = currentSourcePath().parentDir.quoteShell
  CIncludeDir = SourceDir / "cinclude"
  JsonApiDir = SourceDir / "api"
  RaylibDir = SourceDir / "dist" / "raylib"
  DocsDir = SourceDir / "docs"

proc fetchLatestRaylib =
  if not dirExists(RaylibDir):
    echo "Cloning ", GitUrl, "..."
    direShell("git clone --depth 1", GitUrl, RaylibDir)
  withDir(RaylibDir):
    echo "Fetching latest stable commit..."
    direShell("git fetch")
    direShell("git checkout", RaylibStableCommit)

task "build", "Build the raylib C static library":
  fetchLatestRaylib()
  withDir(RaylibDir / "src"):
    echo "Building raylib static library..."
    direShell("make clean")
    direShell("make PLATFORM=PLATFORM_DESKTOP -j4")
    # Install to cinclude directory
    discard existsOrCreateDir(CIncludeDir)
    copyFileToDir("libraylib.a", CIncludeDir)
    copyFileToDir("raylib.h", CIncludeDir)
  echo "DONE!"

proc generateWrapper =
  let script = "raylib_gen"
  withDir(SourceDir / "gen"):
    var exe = script.addFileExt(ExeExt)
    if exe.needsRefresh(script):
      echo "Building ", script, "..."
      direShell("nim c", "--mm:arc --panics:on -d:release -d:emiLenient", script)
    else:
      echo "Skipped building ", script
    echo "Generating raylib Nim wrapper..."
    normalizeExe(exe)
    direShell(exe)

task "wrap", "Produce the raylib nim wrapper":
  let parser = "raylib_parser"
  let header = RaylibDir / "src" / "raylib.h"
  fetchLatestRaylib()
  withDir(RaylibDir / "parser"):
    var exe = parser.addFileExt(ExeExt)
    if exe.needsRefresh(parser):
      echo "Building ", parser, "..."
      direShell("cc", parser.addFileExt(".c"), "-o", exe)
    else:
      echo "Skipped building ", parser
    echo "Generating API JSON file..."
    normalizeExe(exe)
    direShell(exe, "-f JSON", "-d RLAPI", "-i", header, "-o", JsonApiDir / "raylib_api.json")
  generateWrapper()
  echo "DONE!"

task "docs", "Generate documentation":
  # https://nim-lang.github.io/Nim/docgen.html
  let src = ["raymath.nim", "raylib.nim"]
  for f in src.items:
    echo "Generating the docs for ", f, "..."
    let doc = DocsDir / f.changeFileExt(".html")
    if doc.needsRefresh(SourceDir / f):
      direShell("nim doc",
          &"--verbosity:0 --git.url:{ProjectUrl} --git.devel:main --git.commit:main --out:{DocsDir} {f}")
    else:
      echo "Skipped generating ", doc
  echo "DONE!"
