# Package

version     = "5.1.3"
author      = "Antonis Geralis"
description = "Raylib Nim wrapper"
license     = "MIT"
srcDir      = "src"

# Deps

requires "nim >= 2.0.0"
#requires "eminim == 2.8.2"

#import std/distros
#foreignDep "wayland-protocols"
#foreignDep "wayland"

from std/os import `/`, quoteShell
from std/strutils import find
from std/parseutils import skipUntil

proc editRaylibDirConst(dir: string) =
  withDir(dir):
    var file = readFile("raylib.nim")
    let first = find(file, "raylibDir")
    let skipped = skipUntil(file, '\n', start = first)
    let str = "\"" & (dir / "raylib") & "\""
    file[first..first+skipped-1] = "raylibDir = Path" & str
    writeFile("raylib.nim", file)

after install:
  # Fails with atlas
  editRaylibDirConst(thisDir().quoteShell)

task localInstall, "Install on your local workspace":
  # Works with atlas
  editRaylibDirConst(thisDir().quoteShell / "src")

task test, "Runs the test suite":
  localInstallTask()
  exec "nim c -d:release tests/basic_window.nim"
  exec "nim c -d:release -d:emscripten tests/basic_window_web.nim"
