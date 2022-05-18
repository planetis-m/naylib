import std / [os, strformat, osproc, parseopt, strutils]

const
  RayLatestCommit = "4eb3d8857f1a8377f2cfa6e804183512cde5973e"

  Usage = """
Usage: nayget command --option
Commands:
  build        -- build the raylib C static library
  wrap         -- produce the raylib nim wrapper
  docs         -- generate documentation
Options:
  --platform:x -- one of Desktop, RPi, DRM, Android
  --wayland    -- use Wayland display
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
  let (outp, status) = execCmdEx(cmd)
  when not defined(release): echo outp
  if status != 0: quit("FAILURE: " & cmd)

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
    exec("git fetch")
    exec("git checkout " & RayLatestCommit)

proc buildLatestRaylib(platform: string, wayland: bool) =
  fetchLatestRaylib()
  withDir(rayDir / "src"):
    echo "Building raylib static library..."
    let exe = when defined(windows): "mingw32-make" else: "make"
    exec(exe & " clean")
    exec(exe & &" PLATFORM={platform} USE_WAYLAND_DISPLAY={toUpperAscii($wayland)} -j4")
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
    exec(&"{exe} -f JSON -d RLAPI -i {header} -o {apiDir / \"raylib_api.json\"}")
  generateWrapper()

proc buildDocs =
  # https://nim-lang.github.io/Nim/docgen.html
  withDir(srcDir):
    for src in items(["raymath", "raylib"]):
      let doc = docsDir / src.addFileExt(".html")
      echo &"Generating the docs for {src}..."
      exec("nim doc --verbosity:0 --git.url:https://github.com/planetis-m/naylib" &
        &"--git.devel:main --git.commit:main --out:{doc} {src}")

proc main =
  var platform = "desktop"
  var cmd = ""
  var wayland = false
  for kind, key, val in getopt():
    case kind
    of cmdArgument:
      cmd = key
    of cmdLongOption, cmdShortOption:
      case normalize(key)
      of "help", "h": writeHelp()
      of "platform", "p": platform = normalize(val)
      of "wayland": wayland = true
      else: writeHelp()
    of cmdEnd: assert false # cannot happen
  case platform
  of "desktop": platform = "PLATFORM_DESKTOP"
  of "rpi": platform = "PLATFORM_RPI"
  of "drm": platform = "PLATFORM_DRM"
  of "android": platform = "PLATFORM_ANDROID"
  else: writeHelp()
  case cmd
  of "build": buildLatestRaylib(platform, wayland)
  of "wrap": wrapLatestRaylib()
  of "docs": buildDocs()
  else: writeHelp()

main()
