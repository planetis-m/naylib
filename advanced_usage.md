# Naylib Advanced Usage Guide

## Building for the Web (WebAssembly)

To compile your project for web browsers using WebAssembly:

1. Install the Emscripten SDK. Follow the [official Emscripten installation guide](https://emscripten.org/docs/getting_started/downloads.html).

2. Add the `-d:emscripten` flag when compiling.

3. Create a configuration file for your project. You can use [this example](tests/basic_window_web.nims) as a starting point.

## Building for Android

Building for Android is streamlined using the [raylib-game-template](https://github.com/planetis-m/raylib-game-template) repository. Follow these steps:

1. Fork the [raylib-game-template](https://github.com/planetis-m/raylib-game-template) repository.

2. Clone your forked repository and navigate to its directory.

3. Make sure to install Java JDK and wget then, run the following Nimble tasks in order:

   ```bash
   nimble setupBuildEnv    # Set up Android SDK/NDK
   nimble setupAndroid     # Set up raylib project for Android
   nimble buildAndroid     # Compile raylib project for Android
   nimble deploy           # Install and monitor raylib project on default emulator/device
   ```

   These tasks go through the entire process, from setting up the environment to deploying your app on an Android device or emulator.

### Customizing the Android Build

The [build_android.nims](https://github.com/planetis-m/raylib-game-template/blob/master/build_android.nims#L31-L65) file in the raylib-game-template repository offers extensive customization options for your Android build:

- Define target Android architectures (armeabi-v7a, arm64-v8a, x86, x86-64)
- Set GLES and Android API versions
- Specify locations of OpenJDK, Android SDK, and NDK on your system
- Configure application properties such as name and icon
- Adjust other build settings to match your project requirements

Review and modify this file to tailor the Android build process to your specific needs.

## Choosing the OpenGL Graphics Backend Version

By default, Naylib uses OpenGL 3.3 on desktop platforms. To choose a different version, use one of the following flags when compiling:

- `-d:GraphicsApiOpenGl43` (OpenGL 4.3)
- `-d:GraphicsApiOpenGl33` (OpenGL 3.3 - default)
- `-d:GraphicsApiOpenGl21` (OpenGL 2.1)
- `-d:GraphicsApiOpenGl11` (OpenGL 1.1)
- `-d:GraphicsApiOpenGlEs2` (OpenGL ES 2.0)
- `-d:GraphicsApiOpenGlEs3` (OpenGL ES 3.0)

Note: For Wayland on Linux, add the `-d:wayland` flag.

## Important Usage Tips

### Properly Calling closeWindow

Since Naylib wraps most types with Nim's destructors, `closeWindow` needs special attention. It should be called at the very end of your program to avoid conflicts with variables destroyed after the last statement. Here are three recommended methods:

1. Using `defer` or `try-finally`:

```nim
initWindow(800, 450, "example")
defer: closeWindow()
let texture = loadTexture("resources/example.png")
# Your game logic here
```

2. Wrapping everything inside a game object:

```nim
type
  Game = object

proc `=destroy`(x: Game) =
  assert isWindowReady(), "Window is already closed"
  closeWindow()

# Prevent copying, moving, etc.
proc `=sink`(x: var Game; y: Game) {.error.}
proc `=dup`(y: Game): Game {.error.}
proc `=copy`(x: var Game; y: Game) {.error.}
proc `=wasMoved`(x: var Game) {.error.}

proc initGame(width, height, fps: int32, flags: Flags[ConfigFlags], title: string): Game =
  assert not isWindowReady(), "Window is already opened"
  setConfigFlags(flags)
  initWindow(width, height, title)
  setTargetFPS(fps)

let game = initGame(800, 450, 60, flags(Msaa4xHint, WindowHighdpi), "example")
let texture = loadTexture("resources/example.png")
# Your game logic here
```

3. Opening a new scope:

```nim
initWindow(800, 450, "example")
block:
  let texture = loadTexture("resources/example.png")
  # Your game logic here
closeWindow()
```

### Raylib Functions to Nim Alternatives

Some raylib functions are not directly wrapped in Naylib because they closely reflect the C API. For these cases, we provide Nim alternatives. Refer to our [Alternatives Table](alternatives_table.rst) for a comprehensive list of equivalent Nim functions.

### Additional Tips

- **Custom Pixel Formats**: To make your external type compatible with the `Pixel` concept, define a `kind` template that returns the corresponding pixel format.

```nim
from raylib import PixelFormat

type RGBAPixel* = distinct byte

template kind*(x: typedesc[RGBAPixel]): PixelFormat = UncompressedR8g8b8a8
```

- **Swapping Raymath**: Raylib is designed to be independent of `raymath`. You can use alternative vector math libraries like `vmath`, `geometrymath`, or `glm`. Remember to implement converters for `Vector2`, `Vector3`, `Vector4`, and `Matrix` if you switch libraries.

```nim
converter toVector2*(v: geometrymath.Vector2[float32]): raylib.Vector2 {.inline.} =
  raylib.Vector2(x: v.x, y: v.y)

converter fromVector2*(v: raylib.Vector2): geometrymath.Vector2[float32] {.inline.} =
  geometrymath.Vector2[float32](x: v.x, y: v.y)
```
