import nake, std/strformat
# Only Linux is supported!

const
  ProjectUrl = "https://github.com/planetis-m/raylib-fever".quoteShell
  RaylibStableCommit = "d4382f4a52e7631bf02ff8073ed24b282596ce0a"
  SourceDir = currentSourcePath().parentDir.quoteShell
  CIncludeDir = SourceDir / "cinclude"
  JsonApiDir = SourceDir / "api"
  RaylibDir = SourceDir / "dist" / "raylib"
  DocsDir = SourceDir / "docs"

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
    direShell("nim c", "--mm:arc --panics:on -d:release -d:emiLenient", script)
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

task "docs", "Generate documentation":
  # https://nim-lang.github.io/Nim/docgen.html
  let src = ["raylib.nim", "raymath.nim"]
  for f in src.items:
    echo &"Generating the docs for {f}..."
    let doc = DocsDir / f.changeFileExt(".html")
    if doc.needsRefresh(f):
      direShell("nim doc",
          &"--verbosity:0 --git.url:{ProjectUrl} --git.devel:main --git.commit:main --out:{DocsDir} {f}")
    else:
      echo &"Skipped generating {doc}."
