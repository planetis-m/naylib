# Package

version     = "1.3.3"
author      = "Antonis Geralis"
description = "Raylib Nim wrapper"
license     = "MIT"
bin         = @["nayget"]
installExt  = @["nim","json"]

# Deps

requires "nim >= 1.6.0"
#requires "eminim >= 2.8.2"

#foreignDep "wayland-protocols"
