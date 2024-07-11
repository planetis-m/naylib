# Naylib Advanced Usage Guide

## Building for the Web (WebAssembly)

To compile your project for web browsers using WebAssembly:

1. Install the Emscripten SDK (emsdk). Follow the [official Emscripten installation guide](https://emscripten.org/docs/getting_started/downloads.html).

2. Add the `-d:emscripten` flag when compiling.

3. Create a configuration file for your project. You can use [this example](tests/basic_window_web.nims) as a starting point.

## Building for Android

Building for Android is streamlined using the [raylib-game-template](https://github.com/planetis-m/raylib-game-template) repository. Follow these steps:

1. Fork the [raylib-game-template](https://github.com/planetis-m/raylib-game-template) repository.

2. Clone your forked repository and navigate to its directory.

3. Run the following Nimble tasks in order:

   ```bash
   nimble setupBuildEnv    # Set up Android SDK/NDK
   nimble setupAndroid     # Set up raylib project for Android
   nimble buildAndroid     # Compile raylib project for Android
   nimble deploy           # Install and monitor raylib project on default emulator/device
   ```

   These tasks go through the entire process, from setting up the environment to deploying your app on an Android device or emulator.

## Choosing the OpenGL Graphics Backend Version

By default, Naylib uses OpenGL 3.3 on desktop platforms. To choose a different version, use one of the following flags when compiling:

- `-d:GraphicsApiOpenGl43` (OpenGL 4.3)
- `-d:GraphicsApiOpenGl33` (OpenGL 3.3 - default)
- `-d:GraphicsApiOpenGl21` (OpenGL 2.1)
- `-d:GraphicsApiOpenGl11` (OpenGL 1.1)
- `-d:GraphicsApiOpenGlEs2` (OpenGL ES 2.0)
- `-d:GraphicsApiOpenGlEs3` (OpenGL ES 3.0)

Note: For Wayland on Linux, add the `-d:wayland` flag.
