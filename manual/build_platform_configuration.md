# Naylib Build & Platform Configuration Guide

## Changing raylib Settings with Nim Defines

To customize raylib behavior in the Naylib wrapper, you can use Nim's `--define` option to enable or disable specific features. These settings are configured in the project's `config.nims` file.

### Example Usage

To enable a feature, such as `NaylibSupportAutomationEvents`, add the following line to your `config.nims`:

```nim
switch("define", "NaylibSupportAutomationEvents")
```

Alternatively, you can pass it directly via the command line when invoking `nim`:

```bash
nim c --define:NaylibSupportAutomationEvents my_program.nim
```

To disable a feature, you can use:

```nim
switch("define", "NaylibSupportAutomationEvents=false")
```

### Available Options

A full list of configurable options can be found in the `rconfig.nim` file. Refer to it for the supported feature flags and their descriptions: [rconfig.nim](../src/rconfig.nim).

## Building for the Web (WebAssembly)

To compile your project for web browsers using WebAssembly:

1. Install the Emscripten SDK. Follow the [official Emscripten installation guide](https://emscripten.org/docs/getting_started/downloads.html).

2. Create a configuration file for your project. You can use [this example](../tests/basic_window_web.nims)
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

### Customizing the Web Build

When building for web, the following defines are available to customize your build:

- `-d:GraphicsApiOpenGlEs3`: Use WebGL 2.0 instead of WebGL 1.0 (default: WebGL 1.0)
- `-d:NaylibWebAsyncify`: Enable Asyncify support for blocking operations
- `-d:NaylibWebResources`: Enable filesystem and resource preloading
  - `-d:NaylibWebResourcesPath="resources"`: Set the path to preload resources from (default: "resources")
- `--threads:on`: Enable multithreading support
  - `-d:NaylibWebPthreadPoolSize=N`: Set the size of the pthread pool (default: 2)
- `-d:NaylibWebHeapSize=N`: Set the WebAssembly heap size in bytes (default: 134217728 / 128MiB)

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

> **Note:** Instead of the standard Android template, you can use this: [naylib-android-withads-template](https://github.com/choltreppe/naylib-android-withads-template) if you need to add reward ads to your game.

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

