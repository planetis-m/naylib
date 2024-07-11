# Naylib

<img src="assets/naylib.png" alt="Naylib logo" width="15%" />

Welcome to this repository! Here you'll find a Nim wrapper for raylib, a library for
creating 2D and 3D games. The Nim API is designed to be user-friendly and easy to use.

## Features

- **Easy-to-use API**: Simplified Nim interface for raylib functions
- **Cross-platform support**: Develop for multiple platforms including Windows, Linux, macOS, Web, and Android
- **Comprehensive documentation**: Detailed guides and API references
- **Active community**: Get support and share your creations

## Documentation

To learn more about how to use this wrapper, you can check out the documentation:

- [raylib](https://planetis-m.github.io/naylib/raylib.html) - Core library for videogame programming
- [raymath](https://planetis-m.github.io/naylib/raymath.html) - Mathematical functions for game development
- [rlgl](https://planetis-m.github.io/naylib/rlgl.html) - Abstraction layer for OpenGL with immediate-mode API
- [reasings](https://planetis-m.github.io/naylib/reasings.html) - Smooth animation transitions
- [rmem](https://planetis-m.github.io/naylib/rmem.html) - Memory pool and objects pool

If you're familiar with the C version of raylib, you may find the
[cheatsheet](https://www.raylib.com/cheatsheet/cheatsheet.html) useful.

## Installation

Install naylib easily with `nimble install naylib`.

## Examples

We've also provided some example code to help you get started. You can find it in the
accompanying [example repository](https://github.com/planetis-m/raylib-examples).

To compile and run an example: `nim c -r -d:release example.nim`

## Advanced Usage

For detailed instructions on advanced usage, including:
- Building for different platforms (Web, Android)
- Choosing OpenGL backend versions
- Platform-specific considerations

Please refer to our [Advanced Usage Guide](advanced_usage.md).

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

[![Android CI](https://img.shields.io/github/actions/workflow/status/planetis-m/raylib-game-template/ci.yml?branch=master&label=Android%20CI)](https://github.com/planetis-m/raylib-game-template/actions/workflows/ci.yml)

## Contributing

We welcome contributions! Whether it's bug reports, feature requests, or code contributions,
please feel free to engage with our project.

## License

Naylib is open-source software. [LICENSE-MIT](LICENSE)

## Contact

For support and discussions, join the [Nim Discord server](https://discord.gg/ByYHrPUY)
and visit the #gamedev channel.
