import std / [os, strformat, strutils, osproc]

const
  RayLatestCommit = "4eb3d8857f1a8377f2cfa6e804183512cde5973e"

  Usage = """
Usage: nayget command
Commands:
  build    -- build the raylib C static library
  wrap     -- produce the raylib nim wrapper
  docs     -- generate documentation
"""

proc writeHelp() =
  stdout.write(Usage)
  stdout.flushFile()
  quit(0)

const
  srcDir = currentSourcePath().parentDir.quoteShell
  rayDir = srcDir / "dist/raylib"
  inclDir = srcDir / "cinclude"
  apiDir = srcDir / "api"
  docsDir = srcDir / "docs"

proc exec(cmd: string) =
  if execShellCmd(cmd) != 0: quit("FAILURE: " & cmd)

template withDir(dir, body) =
  let old = getCurrentDir()
  try:
    setCurrentDir(dir)
    body
  finally:
    setCurrentDir(old)

proc fetchLatestRaylib =
  if not dirExists(rayDir):
    echo "Cloning raysan/raylib..."
    exec("git clone --depth 50 https://github.com/raysan5/raylib.git " & rayDir)
  withDir(rayDir):
    echo "Fetching latest commit..."
    exec("git fetch && git checkout " & RayLatestCommit)

proc buildLatestRaylib =
  fetchLatestRaylib()
  withDir(rayDir / "src"):
    echo "Building raylib static library..."
    exec("make clean && make PLATFORM=PLATFORM_DESKTOP -j4")
    echo "Copying to C include directory"
    discard existsOrCreateDir(inclDir)
    copyFileToDir("libraylib.a", inclDir)
    copyFileToDir("raylib.h", inclDir)

proc generateWrapper =
  let script = "raylib_gen.nim"
  withDir(srcDir / "gen"):
    var exe = script.changeFileExt(ExeExt)
    echo "Building raylib2nim tool..."
    exec("nim c --mm:arc --panics:on -d:release -d:emiLenient " & script)
    normalizeExe(exe)
    echo "Generating raylib Nim wrapper..."
    exec(exe)

proc wrapLatestRaylib =
  let parser = "raylib_parser.c"
  let header = rayDir / "src/raylib.h"
  fetchLatestRaylib()
  withDir(rayDir / "parser"):
    var exe = parser.changeFileExt(ExeExt)
    echo "Building raylib API parser..."
    exec(&"cc {parser} -o {exe}")
    normalizeExe(exe)
    echo "Generating API JSON file..."
    exec(&"exe -f JSON -d RLAPI -i {header} -o {apiDir / \"raylib_api.json\"}")
  generateWrapper()

proc buildDocs =
  # https://nim-lang.github.io/Nim/docgen.html
  withDir(srcDir):
    for src in items(["raymath", "raylib"]):
      let doc = docsDir / src.addFileExt(".html")
      echo &"Generating the docs for {src}..."
      const url = "https://github.com/planetis-m/naylib"
      exec(&"nim doc --verbosity:0 --git.url:{url} --git.devel:main --git.commit:main --out:{doc} {src}")

proc main =
  if os.paramCount() != 1: writeHelp()
  let cmd = paramStr(1)
  case cmd
  of "build": buildLatestRaylib()
  of "wrap": wrapLatestRaylib()
  of "docs": buildDocs()
  else: writeHelp()

main()
