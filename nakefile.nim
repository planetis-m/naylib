import nake, std/strformat
# Only Linux is supported!

const
  SourceDir = currentSourcePath().parentDir.quoteShell
  ProjectUrl = "https://github.com/planetis-m/naylib"
  RaylibGitUrl = "https://github.com/raysan5/raylib.git"
  RaylibStableCommit = "6e9ec253c89a9f37e7cbe1f1db382121dcbb61c1"
  RaylibDir = SourceDir / "dist" / "raylib"
  CIncludeDir = SourceDir / "cinclude"
  JsonApiDir = SourceDir / "api"
  DocsDir = SourceDir / "docs"

proc fetchLatestRaylib =
  if not dirExists(RaylibDir):
    direSilentShell(&"Cloning {RaylibGitUrl}...",
        "git clone --depth 1", RaylibGitUrl, RaylibDir)
  withDir(RaylibDir):
    direSilentShell("Fetching latest stable commit...",
        "git fetch && git checkout", RaylibStableCommit)

task "build", "Build the raylib C static library":
  fetchLatestRaylib()
  withDir(RaylibDir / "src"):
    direSilentShell("Building raylib static library...",
        "make clean && make CC=clang PLATFORM=PLATFORM_DESKTOP -j4")
    # Install to cinclude directory
    discard existsOrCreateDir(CIncludeDir)
    copyFileToDir("libraylib.a", CIncludeDir)
    copyFileToDir("raylib.h", CIncludeDir)

proc generateWrapper =
  let script = "raylib_gen"
  withDir(SourceDir / "gen"):
    var exe = script.addFileExt(ExeExt)
    if exe.needsRefresh(script):
      direSilentShell("Building raylib2nim tool...",
          "nim c", "--mm:arc --panics:on -d:release -d:emiLenient", script)
    else:
      echo "Skipped building raylib2nim tool."
    normalizeExe(exe)
    direSilentShell("Generating raylib Nim wrapper...", exe)

task "wrap", "Produce the raylib nim wrapper":
  let parser = "raylib_parser"
  let header = RaylibDir / "src" / "raylib.h"
  fetchLatestRaylib()
  withDir(RaylibDir / "parser"):
    var exe = parser.addFileExt(ExeExt)
    if exe.needsRefresh(parser):
      direSilentShell("Building raylib API parser...",
          "cc", parser.addFileExt(".c"), "-o", exe)
    else:
      echo "Skipped building raylib API parser."
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
