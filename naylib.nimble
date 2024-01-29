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

const
  PkgDir = thisDir().quoteShell

before install:
  let patchPath = PkgDir / "mangle_names.patch"
  withDir(PkgDir / "src/raylib"):
    exec "git apply " & patchPath
