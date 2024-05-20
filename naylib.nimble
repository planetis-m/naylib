# Package

version     = "5.1.0"
author      = "Antonis Geralis"
description = "Raylib Nim wrapper"
license     = "MIT"
srcDir      = "src"

# Deps

requires "nim >= 1.9.5"
#requires "eminim == 2.8.2"

#import std/distros
#foreignDep "wayland-protocols"
#foreignDep "wayland"

from std/os import `/`, quoteShell
from std/strutils import find
from std/parseutils import skipUntil

const PkgDir = thisDir().quoteShell

before install:
  # https://stackoverflow.com/a/27415757
  exec "git submodule deinit -f ."
  exec "git submodule update --init"
  withDir(PkgDir / "src/raylib"):
    # exec "git rev-parse HEAD"
    let patchPath = PkgDir / "mangle_names.patch"
    exec "git apply " & patchPath

after install:
  withDir(PkgDir / "src"):
    var src = readFile("raylib.nim")
    let first = find(src, "raylibDir")
    let skipped = skipUntil(src, '\n', start = first)
    let dir = when defined(windows): "(r\"" & (PkgDir / "src/raylib/src") & "\")"
              else: "\"" & (PkgDir / "src/raylib/src") & "\""
    src[first..first+skipped-1] = "raylibDir = Path" & dir
    writeFile("raylib.nim", src)
