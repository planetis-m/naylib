# Package

version     = "1.7.6"
author      = "Antonis Geralis"
description = "Raylib Nim wrapper"
license     = "MIT"
srcDir      = "src"

# Deps

requires "nim >= 1.6.0"
#requires "eminim == 2.8.2"

#import std/distros
#foreignDep "wayland-protocols"

const
  RayLatestCommit = "e6306e5e76f83c9cf0b2bfbb85ceffa4ed2926ee"

let
  rayDir = "dist/raylib"
  inclDir = "include"

proc fetchLatestRaylib =
  if not dirExists(rayDir):
    # Cloning raysan/raylib...
    exec "git clone --depth 1 https://github.com/raysan5/raylib.git " & rayDir
  withDir(rayDir):
    # Fetching latest commit...
    exec "git fetch --depth 1 origin " & RayLatestCommit & "; git checkout " & RayLatestCommit

# proc fetchStableRaylib =
#   if not dirExists(rayDir):
#     # Cloning raysan/raylib at tag...
#     exec "git clone -b '4.2.0' --depth 1 https://github.com/raysan5/raylib.git " & rayDir

proc buildRaylib(platform: string, wayland = false) =
  fetchLatestRaylib()
  withDir(rayDir & "/src"):
    const exe = when defined(windows): "mingw32-make" else: "make"
    # Building raylib static library...
    exec exe & " clean && " & exe & " -j4 PLATFORM=" & platform &
        (if wayland: " USE_WAYLAND_DISPLAY=TRUE" else: "")
  # Copying to C include directory...
  if not dirExists(inclDir):
    mkDir inclDir
  cpFile(rayDir & "/src/libraylib.a", inclDir & "/libraylib.a")
  cpFile(rayDir & "/src/raylib.h", inclDir & "/raylib.h")

task buildDesktop, "Build the raylib library for the Desktop platform":
  buildRaylib("PLATFORM_DESKTOP")

task buildRPi, "Build the raylib library for the RPi platform":
  buildRaylib("PLATFORM_RPI")

task buildDRM, "Build the raylib library for the DRM platform":
  buildRaylib("PLATFORM_DRM")

task buildAndroid, "Build the raylib library for the Android platform":
  buildRaylib("PLATFORM_ANDROID")
