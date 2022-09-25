# Package

version     = "1.7.2"
author      = "Antonis Geralis"
description = "Raylib Nim wrapper"
license     = "MIT"
srcDir      = "src"
#skipDirs    = @["api", "tools"]

# Deps

requires "nim >= 1.6.0"
#requires "eminim >= 2.8.2"
#import std/distros
#foreignDep "wayland-protocols"

const
  RayLatestCommit = "7ab056b6efb0764967c80439c15eed828b6ae1c4"

let
  pkgDir = thisDir()
  rayDir = pkgDir & "/dist/raylib"
  inclDir = pkgDir & "/include"
  apiDir = pkgDir & "/api"
  docsDir = pkgDir & "/docs"

proc fetchLatestRaylib =
  if not dirExists(rayDir):
    # Cloning raysan/raylib...
    exec "git clone --depth 10 https://github.com/raysan5/raylib.git " & rayDir
  withDir(rayDir):
    # Fetching latest commit...
    exec "git fetch; git checkout " & RayLatestCommit

proc buildLatestRaylib(platform: string, wayland = false) =
  fetchLatestRaylib()
  withDir(rayDir & "/src"):
    const exe = when defined(windows): "mingw32-make" else: "make"
    # Building raylib static library...
    exec exe & " clean && " & exe & " PLATFORM=" & platform &
        (if wayland: "USE_WAYLAND_DISPLAY=TRUE" else: "") & " -j4"
    # Copying to C include directory...
    if not dirExists inclDir:
      mkDir inclDir
    cpFile("libraylib.a", inclDir & "/libraylib.a")
    cpFile("raylib.h", inclDir & "/raylib.h")

task buildDesktop, "Build the raylib library for the Desktop platform":
  buildLatestRaylib("PLATFORM_DESKTOP")

task buildRPi, "Build the raylib library for the RPi platform":
  buildLatestRaylib("PLATFORM_RPI")

task buildDRM, "Build the raylib library for the DRM platform":
  buildLatestRaylib("PLATFORM_DRM")

task buildAndroid, "Build the raylib library for the Android platform":
  buildLatestRaylib("PLATFORM_ANDROID")

# The rest are meant for developers only!
template `/.`(x: string): string =
  (when defined(posix): "./" & x else: x)

proc generateWrapper =
  let src = "raylib_gen.nim"
  withDir(pkgDir & "/tools"):
    let exe = "raylib_gen".toExe
    # Building raylib2nim tool...
    exec "nim c --mm:arc --panics:on -d:release -d:emiLenient " & src
    # Generating raylib Nim wrapper...
    exec /.exe

task wrap, "Produce the raylib nim wrapper":
  let src = "raylib_parser.c"
  let header = rayDir & "/src/raylib.h"
  fetchLatestRaylib()
  withDir(rayDir & "/parser"):
    let exe = "raylib_parser".toExe
    # Building raylib API parser...
    exec "cc " & src & " -o " & exe
    # Generating API JSON file...
    exec /.exe & " -f JSON -d RLAPI -i " & header & " -o " & apiDir & "/raylib_api.json"
  generateWrapper()

task docs, "Generate documentation":
  # https://nim-lang.github.io/Nim/docgen.html
  for src in items(["raymath", "raylib"]):
    let doc = docsDir & "/" & src & ".html"
    # Generating the docs for...
    exec "nim doc --verbosity:0 --git.url:https://github.com/planetis-m/naylib --git.devel:main --git.commit:main --out:" &
        doc & " " & pkgDir & "/src/" & src
