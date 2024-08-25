# Naylib Advanced Usage Guide

## Building for the Web (WebAssembly)

To compile your project for web browsers using WebAssembly:

1. Install the Emscripten SDK. Follow the [official Emscripten installation guide](https://emscripten.org/docs/getting_started/downloads.html).

2. Create a configuration file for your project. You can use [this example](tests/basic_window_web.nims)
   as a starting point.

3. Add the `-d:emscripten` flag when compiling, e.g., `nim c -d:emscripten your_project.nim`.

   This will generate the necessary files for web deployment in the `public` directory.

4. To run a local web server, you can use nimhttpd (`nimble install nimhttpd`). Navigate to the
   directory containing your compiled files and run `nimhttpd`.

   For multithreading support (`--threads:on`), you need to pass the following extra arguments to nimhttpd:

   ```bash
   nimhttpd -H:"Cross-Origin-Opener-Policy: same-origin" -H:"Cross-Origin-Embedder-Policy: require-corp"
   ```

5. Open your web browser and navigate to the address printed by nimhttpd (usually `localhost:1337`).

   You should now be able to see your game running in the browser window!

## Building for Android

Building for Android is streamlined using the [naylib-game-template](https://github.com/planetis-m/naylib-game-template) repository. Follow these steps:

1. Fork the [naylib-game-template](https://github.com/planetis-m/naylib-game-template) repository.

2. Clone your forked repository and navigate to its directory.

3. Make sure to install Java JDK and wget then, run the following Nimble tasks in order:

   ```bash
   nimble setupBuildEnv    # Set up Android SDK and NDK for development
   nimble setupAndroid     # Prepare raylib project for Android development
   nimble buildAndroid     # Compile and package raylib project for Android
   ```

4. Install and run the APK on your Android device.

   Enable USB Debugging on your Android device, plug it into your computer, select File Transfer,
   accept the RSA key and install the package with the following command:

   ```bash
   nimble deploy           # Install and monitor raylib project on Android device/emulator
   ```

   Now you should be able to run your raylib game on your Android device!

### Customizing the Android Build

The [build_android.nims](https://github.com/planetis-m/naylib-game-template/blob/master/build_android.nims#L31-L65) file in the naylib-game-template repository offers extensive customization options for your Android build:

- Define target Android architectures (armeabi-v7a, arm64-v8a, x86, x86-64)
- Set GLES and Android API versions
- Specify locations of OpenJDK, Android SDK, and NDK on your system
- Configure application properties such as name and icon
- Adjust other build settings to match your project requirements

Review and modify this file to tailor the build process to your specific needs.

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
# Game logic goes here
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
# Game logic goes here
```

3. Opening a new scope:

```nim
initWindow(800, 450, "example")
block:
  let texture = loadTexture("resources/example.png")
  # Game logic goes here
closeWindow()
```

4. Using templates:

```nim
const
  screenWidth = 800
  screenHeight = 450
  windowName = "example"
  targetFramerate = 60
  flags = flags(Msaa4xHint)

template game(gameCode: untyped) =
  proc main =
    setConfigFlags(flags)
    initWindow(screenWidth, screenHeight, windowName)
    try:
      gameCode
    finally:
      closeWindow()
  main()

template gameLoop(loopCode: untyped) =
  setTargetFPS(targetFramerate)
  while not windowShouldClose():
    loopCode

game:
  # Setup code goes here.
  let texture = loadTexture("resources/example.png")
  gameLoop:
    drawing:
      clearBackground(RayWhite)
```

### Handling types without =copy hooks

Some types in naylib, like `Texture`, don't have `=copy` hooks. This prevents direct copying:

```nim
let texture = loadTexture("resources/example.png")
let copy = texture  # Error: '=copy' is not available for type <Texture>
```

To work around this, use references:

```nim
var texture: ref Texture
new(texture)
texture[] = loadTexture("resources/example.png")
let copy = texture  # This works, copying the reference
```

Remember that `texture` and `copy` will point to the same object.

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
