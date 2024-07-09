when defined(emscripten):
  --define:GraphicsApiOpenGlEs2
  # --define:NaylibWebResources
  --os:linux
  --cpu:wasm32
  --cc:clang
  --clang.exe:emcc
  --clang.linkerexe:emcc
  --clang.cpp.exe:emcc
  --clang.cpp.linkerexe:emcc
  # --mm:orc
  --threads:on
  --panics:on
  --define:noSignalHandler
  --passL:"-o tests/build/index.html"
  # Use raylib/src/shell.html or raylib/src/minshell.html
  --passL:"--shell-file tests/minshell.html"
