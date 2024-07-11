# Naylib

<img src="assets/naylib.png" alt="Naylib logo" width="15%" />

Welcome to this repository! Here you'll find a Nim wrapper for raylib, a library for
creating 2D and 3D games. The Nim API is designed to be user-friendly and easy to use.

## Documentation

To learn more about how to use this wrapper, you can check out the documentation:

- [raylib](https://planetis-m.github.io/naylib/raylib.html) - User-friendly library for videogame programming
- [raymath](https://planetis-m.github.io/naylib/raymath.html) - Mathematical functions for vectors, matrices, and quaternions
- [rlgl](https://planetis-m.github.io/naylib/rlgl.html) - Abstraction layer for OpenGL with immediate-mode API
- [reasings](https://planetis-m.github.io/naylib/reasings.html) - Smooth animation transitions
- [rmem](https://planetis-m.github.io/naylib/rmem.html) - Memory pool and objects pool

If you're familiar with the C version of raylib, you may find the
[cheatsheet](https://www.raylib.com/cheatsheet/cheatsheet.html) useful.

## Installation

To install this wrapper, run `nimble install naylib`.

## Examples

We've also provided some example code to help you get started. You can find it in the
accompanying [example repository](https://github.com/planetis-m/raylib-examples). To
compile and run an example, run the command `nim c -r -d:release example.nim` in your
terminal.

## Compilation Targets and Host OS Support

| Target           | Windows           | Linux             | macOS             |
|------------------|--------------------|--------------------|-------------------|
| Native           | Supported, Tested | Supported, Tested | Supported, Tested |
| WebAssembly      | Supported, Tested | Supported, Tested | Supported, Tested |
| DRM              | Untested          | Supported         | Untested          |
| Android          | Supported, Tested | Supported, Tested | Possibly Works    |
| Windows (Cross)  | N/A               | Known Issues      | Untested          |

### Notes:

- CI is now in place, testing Windows, Linux, and macOS for native and WebAssembly (Emscripten) builds.
- A separate CI tests Windows and Linux hosts crosscompiling for Android.

### CI Status Badges:

[![Native & WebAssembly CI](https://img.shields.io/github/actions/workflow/status/planetis-m/naylib/ci.yml?branch=main&label=Native%20%26%20WebAssembly%20CI)](https://github.com/planetis-m/naylib/actions/workflows/ci.yml)

[![Android CI](https://img.shields.io/github/actions/workflow/status/planetis-m/raylib-game-template/ci.yml?branch=master&label=Android%20CI)](https://github.com/planetis-m/raylib-game-template/actions/workflows/ci.yml)
