# Package

version     = "4.5.1"
author      = "Antonis Geralis"
description = "Raylib Nim wrapper"
license     = "MIT"
srcDir      = "src"

# Deps

requires "nim >= 1.9.1"
#requires "eminim == 2.8.2"

#import std/distros
#foreignDep "wayland-protocols"
#foreignDep "wayland"

from std/os import `/`, quoteShell

const
  PkgDir = thisDir().quoteShell

after install:
  when defined(windows):
    let patchPath = PkgDir / "mangle_names.patch"
    withDir(PkgDir / "src/raylib"):
      exec "git apply " & patchPath
