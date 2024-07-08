when defined(emscripten):
  --define:GraphicsApiOpenGlEs2
  --define:NaylibWebResources
  --os:linux
  --cpu:wasm32
  --cc:clang
  when defined(windows):
    --clang.exe:emcc.bat
    --clang.linkerexe:emcc.bat
    --clang.cpp.exe:emcc.bat
    --clang.cpp.linkerexe:emcc.bat
  else:
    --clang.exe:emcc
    --clang.linkerexe:emcc
    --clang.cpp.exe:emcc
    --clang.cpp.linkerexe:emcc
  # --mm:orc
  --threads:on
  --panics:on
  --define:noSignalHandler
  --passL:"-o public/index.html"
  # Use raylib/src/shell.html or raylib/src/minshell.html
  --passL:"--shell-file tests/minshell.html"
