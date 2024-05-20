# Package

version     = "5.1.1"
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

after install:
  # Fails with atlas
  var file = readFile("raylib.nim")
  let first = find(file, "raylibDir")
  let skipped = skipUntil(file, '\n', start = first)
  let dir = thisDir().quoteShell / "raylib"
  let str = when defined(windows): "(r\"" & dir & "\")"
            else: "\"" & dir & "\""
  file[first..first+skipped-1] = "raylibDir = Path" & str
  writeFile("raylib.nim", file)
