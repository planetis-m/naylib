import nake, std/strformat
# Only Linux is supported!

const
  ProjectUrl = "https://github.com/planetis-m/raylib-fever"
  RaylibGitUrl = "https://github.com/raysan5/raylib.git"
  RaylibStableCommit = "d4382f4a52e7631bf02ff8073ed24b282596ce0a"
  SourceDir = currentSourcePath().parentDir.quoteShell
  CIncludeDir = SourceDir / "cinclude"
  JsonApiDir = SourceDir / "api"
  RaylibDir = SourceDir / "dist" / "raylib"
  DocsDir = SourceDir / "docs"

proc fetchLatestRaylib =
  if not dirExists(RaylibDir):
    direSilentShell(&"Cloning {RaylibGitUrl}...",
        "git clone --depth 1", RaylibGitUrl, RaylibDir)
  withDir(RaylibDir):
    direSilentShell("Fetching latest stable commit...", "git fetch")
    direShell("git checkout", RaylibStableCommit)

task "build", "Build the raylib C static library":
  fetchLatestRaylib()
  withDir(RaylibDir / "src"):
    direShell("make clean")
    direSilentShell("Building raylib static library...",
        "make CC=clang PLATFORM=PLATFORM_DESKTOP -j4")
    # Install to cinclude directory
    discard existsOrCreateDir(CIncludeDir)
    copyFileToDir("libraylib.a", CIncludeDir)
    copyFileToDir("raylib.h", CIncludeDir)

proc generateWrapper =
  let script = "raylib_gen"
  withDir(SourceDir / "gen"):
    var exe = script.addFileExt(ExeExt)
    if exe.needsRefresh(script):
      direSilentShell(&"Building {script}...",
          "nim c", "--mm:arc --panics:on -d:release -d:emiLenient", script)
    else:
      echo "Skipped building ", script
    normalizeExe(exe)
    direShell("Generating raylib Nim wrapper...", exe)

task "wrap", "Produce the raylib nim wrapper":
  let parser = "raylib_parser"
  let header = RaylibDir / "src" / "raylib.h"
  fetchLatestRaylib()
  withDir(RaylibDir / "parser"):
    var exe = parser.addFileExt(ExeExt)
    if exe.needsRefresh(parser):
      direSilentShell(&"Building {parser}...",
          "cc", parser.addFileExt(".c"), "-o", exe)
    else:
      echo "Skipped building ", parser
    normalizeExe(exe)
    direSilentShell("Generating API JSON file...",
        exe, "-f JSON", "-d RLAPI", "-i", header, "-o", JsonApiDir / "raylib_api.json")
  generateWrapper()

task "docs", "Generate documentation":
  # https://nim-lang.github.io/Nim/docgen.html
  withDir(SourceDir):
    for src in items(["raymath.nim", "raylib.nim"]):
      let doc = DocsDir / src.changeFileExt(".html")
      if doc.needsRefresh(src):
        direSilentShell(&"Generating the docs for {src}...", "nim doc",
            &"--verbosity:0 --git.url:{ProjectUrl} --git.devel:main --git.commit:main --out:{DocsDir}", src)
      else:
        echo "Skipped generating ", doc
