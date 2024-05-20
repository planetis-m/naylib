# Package

version     = "5.1.2"
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

proc replaceRaylibDirConstant(dir: string) =
  withDir(dir):
    var file = readFile("raylib.nim")
    let first = find(file, "raylibDir")
    let skipped = skipUntil(file, '\n', start = first)
    let str = when defined(windows): "(r\"" & (dir / "raylib") & "\")"
              else: "\"" & (dir / "raylib") & "\""
    file[first..first+skipped-1] = "raylibDir = Path" & str
    writeFile("raylib.nim", file)

before install:
  # Works with atlas
  replaceRaylibDirConstant(thisDir().quoteShell / "src")

after install:
  # Fails with atlas
  replaceRaylibDirConstant(thisDir().quoteShell)
