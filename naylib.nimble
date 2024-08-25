# Package

version     = "5.1.6"
author      = "Antonis Geralis"
description = "Raylib Nim wrapper"
license     = "MIT"
srcDir      = "src"

# Deps

requires "nim >= 2.0.0"
#requires "eminim == 2.8.2"

# https://github.com/raysan5/raylib/wiki/Working-on-GNU-Linux
import std/distros
if detectOs(Ubuntu):
  foreignDep "libasound2-dev libx11-dev libxrandr-dev libxi-dev libgl1-mesa-dev libglu1-mesa-dev libxcursor-dev libxinerama-dev"
  foreignDep "libxkbcommon-dev libwayland-bin"
elif detectOs(Fedora):
  foreignDep "alsa-lib-devel mesa-libGL-devel libX11-devel libXrandr-devel libXi-devel libXcursor-devel libXinerama-devel libatomic"
  foreignDep "libxkbcommon-devel wayland-devel"
elif detectOs(ArchLinux) or detectOs(Manjaro):
  foreignDep "alsa-lib mesa libx11 libxrandr libxi libxcursor libxinerama"
  foreignDep "libxkbcommon wayland"

# Tasks

import std/[os, strutils, parseutils]

proc editRaylibDirConst(dir: string) =
  withDir(dir):
    var file = readFile("raylib.nim")
    let first = find(file, "raylibDir")
    let skipped = skipUntil(file, '\n', start = first)
    let str = "\"" & (dir / "raylib") & "\""
    file[first..first+skipped-1] = "raylibDir = Path" & str
    writeFile("raylib.nim", file)

task localInstall, "Install on your local workspace":
  echo "To complete the installation, run:\n"
  echoForeignDeps()
  # Works with atlas
  editRaylibDirConst(thisDir() / "src")

after install:
  when defined(atlas):
    localInstallTask()
  else:
    echo "To complete the installation, run:\n"
    echoForeignDeps()
    # Fails with atlas
    editRaylibDirConst(thisDir())

task test, "Runs the test suite":
  localInstallTask()
  exec "nim c -d:release tests/basic_window.nim"
  when defined(linux):
    exec "nim c -d:release -d:wayland tests/basic_window.nim"
  exec "nim c -d:release -d:emscripten tests/basic_window_web.nim"
