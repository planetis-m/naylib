# Package

version     = "1.6.0"
author      = "Antonis Geralis"
description = "Raylib Nim wrapper"
license     = "MIT"
srcDir      = "src"
#skipDirs    = @["api", "tools"]

# Deps

requires "nim >= 1.6.0"
#requires "eminim >= 2.8.2"

foreignDep "wayland-protocols"
