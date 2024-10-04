# Naylib

<img src="assets/naylib.png" alt="Naylib logo" width="15%" />

Welcome to this repository! Here you'll find a Nim wrapper for raylib, a library for
creating 2D and 3D games. The Nim API is designed to be user-friendly and easy to use.

## Features

- **Easy-to-use API**: Simplified Nim interface for raylib functions
- **Cross-platform support**: Develop for multiple platforms including Windows, Linux, macOS, Web and Android
- **Comprehensive documentation**: Detailed guides and API references
- **Active community**: Get support and share your creations

## Documentation

To learn more about how to use this wrapper, you can check out the documentation:

- [raylib](https://planetis-m.github.io/naylib/raylib.html) - Core library for videogame programming
- [raymath](https://planetis-m.github.io/naylib/raymath.html) - Mathematical functions for game development
- [rlgl](https://planetis-m.github.io/naylib/rlgl.html) - Abstraction layer for OpenGL with immediate-mode API
- [reasings](https://planetis-m.github.io/naylib/reasings.html) - Smooth animation transitions
- [rmem](https://planetis-m.github.io/naylib/rmem.html) - Memory pool and objects pool allocators

If you're familiar with the C version of raylib, you may find the
[cheatsheet](https://www.raylib.com/cheatsheet/cheatsheet.html) useful.

## Installation

Install naylib easily with `nimble install naylib`.

For Linux users only: Ensure you have the [required](https://github.com/raysan5/raylib/wiki/Working-on-GNU-Linux)
dependencies installed using your distribution's native package manager.

## Examples

We've also provided some example code to help you get started. You can find it in the
accompanying [example repository](https://github.com/planetis-m/raylib-examples).
To compile and run an example: `nim c -r -d:release example.nim`

## Changes from Raylib to Naylib

Naylib introduces several improvements and changes compared to the original Raylib.
For a comprehensive overview of these changes, including memory management, naming
conventions, and API improvements, please refer to our
[Changes Overview](changes_overview.md) document.

## Advanced Usage

For detailed instructions on advanced topics, please refer to our
[Advanced Usage Guide](advanced_usage.md).

Here are quick links to some important sections:

- [Important Usage Tips](advanced_usage.md#important-usage-tips) - Learn how to properly call `closeWindow` and other crucial tips
- [Building for the Web (WebAssembly)](advanced_usage.md#building-for-the-web-webassembly) - Instructions for compiling your project for web browsers
- [Building for Android](advanced_usage.md#building-for-android) - Step-by-step guide for Android development
- [Raylib Functions to Nim Alternatives](alternatives_table.rst) - Find Nim equivalents for raylib functions

## Platform Support

| Target           | Windows           | Linux             | macOS             |
|------------------|-------------------|-------------------|-------------------|
| Native           | Supported, Tested | Supported, Tested | Supported, Tested |
| WebAssembly      | Supported, Tested | Supported, Tested | Supported, Tested |
| DRM              | Untested          | Supported         | Untested          |
| Android          | Supported, Tested | Supported, Tested | Possibly Works    |
| Windows (Cross)  | N/A               | Known Issues      | Untested          |

### Development Status

- Our CI pipeline ensures quality across Windows, Linux, and macOS for both native and WebAssembly builds.
- We also maintain a separate CI for Android cross-compilation from Windows and Linux hosts.

### CI Status

[![Native & WebAssembly CI](https://img.shields.io/github/actions/workflow/status/planetis-m/naylib/ci.yml?branch=main&label=Native%20%26%20WebAssembly%20CI)](https://github.com/planetis-m/naylib/actions/workflows/ci.yml)

[![Android CI](https://img.shields.io/github/actions/workflow/status/planetis-m/naylib-game-template/ci.yml?branch=master&label=Android%20CI)](https://github.com/planetis-m/naylib-game-template/actions/workflows/ci.yml)

[![Examples CI](https://img.shields.io/github/actions/workflow/status/planetis-m/raylib-examples/ci.yml?branch=master&label=Nim%20CI)](https://github.com/planetis-m/raylib-examples/actions/workflows/ci.yml)

## Alternative Game Development Libraries

While we believe that Naylib provides a great option for game development with Nim, we understand
that it may not be the perfect fit for everyone. Here are some noteworthy alternatives:

- [NimForUE](https://github.com/jmgomez/NimForUE): Plugin for Unreal Engine 5
- [sokol-nim](https://github.com/floooh/sokol-nim): Auto-generated bindings for sokol headers
- [gdextcore](https://github.com/godot-nim/gdextcore): Godot 4.x bindings
- [godot-nim](https://github.com/pragmagic/godot-nim): Godot 3 bindings
- [nico](https://github.com/ftsf/nico): Pico-8 inspired game framework
- [p5nim](https://github.com/pietroppeter/p5nim): Processing library

For a comprehensive list of game development resources in Nim,
visit [awesome-nim](https://github.com/ringabout/awesome-nim#game-development).

## Contributing

We welcome contributions! Whether it's bug reports, feature requests, or code contributions,
please feel free to engage with our project.

## License

Naylib is open-source software licensed under the [MIT](LICENSE) License.

Please note that the raylib [source](src/raylib) code included in this distribution is licensed under
the [zlib](LICENSE-RAYLIB) license.

## Contact

For support and discussions, join us on Discord:
- Nim server (#gamedev): [discord.gg/ByYHrPUY](https://discord.gg/ByYHrPUY)
- Raylib server (#raylib-nim): [discord.gg/raylib](https://discord.gg/raylib)
