# GEMINI.MD: AI Collaboration Guide

This document provides essential context for AI models interacting with this project. Adhering to these guidelines will ensure consistency and maintain code quality.

## 1. Project Overview & Purpose

* **Primary Goal:** This project, "Naylib," is a Nim wrapper for the Raylib library, which is designed for creating 2D and 3D games. The wrapper aims to provide a more user-friendly and idiomatic Nim interface to the underlying C library.
* **Business Domain:** Game Development.

## 2. Core Technologies & Stack

* **Languages:** Nim (>= 2.0.0), C (for the underlying Raylib library).
* **Frameworks:** The project is a library and it's compiled with the Nim compiler. It can target multiple platforms, including Windows, Linux, macOS, and WebAssembly (via Emscripten).
* **Key Libraries/Dependencies:** The core dependency is Raylib. The project also has several foreign dependencies for different Linux distributions to support graphics and audio.
* **Package Manager(s):** Nimble is used for package management.

## 3. Architectural Patterns

* **Overall Architecture:** This project is a wrapper library. It exposes the functionality of the underlying C library (Raylib) through a Nim interface. It uses a combination of direct C imports (`importc`) and higher-level Nim modules that provide a more idiomatic API.
* **Directory Structure Philosophy:**
    * `/src`: Contains the main source code for the Nim wrapper.
    * `/raylib`: Contains the source code for the Raylib C library as a submodule.
    * `/tests`: Contains tests for the wrapper.
    * `/manual`: Contains documentation about the wrapper, including an overview of changes from Raylib, an advanced usage guide, and a configuration guide for the wrapper generator.
    * `/tools`: Contains tools for generating the wrapper from the Raylib API definitions.

## 4. Coding Conventions & Style Guide

* **Formatting:** The Nim code follows standard Nim formatting conventions. The underlying C code (Raylib) follows a specific style (Pascal-case/camel-case) which is different from standard C conventions.
* **Naming Conventions:**
    * Naylib uses function overloading to simplify the API compared to Raylib's suffix-based naming (e.g., `DrawRectangle`, `DrawRectangleV`).
    * C enums are mapped to Nim enums with the prefix removed (e.g., `LOG_TRACE` becomes `Trace`).
* **API Design:**
    * The wrapper aims to provide a safe and idiomatic Nim API.
    * Raw pointers and C strings are abstracted using `openArray[T]` and `string`.
    * Begin-end pairs from Raylib (e.g., `beginDrawing`/`endDrawing`) are wrapped in templates (`drawing`, `mode3D`) for safer usage.
* **Error Handling:** The wrapper uses Nim's exception handling. For example, asset loading functions check if the asset was loaded successfully and raise a `RaylibError` if not.

## 5. Key Files & Modules

* **Main Modules:** As a library, provides several modules that can be imported:
    * `raylib`: Core library for videogame programming.
    * `raymath`: Mathematical functions for game development.
    * `rlgl`: Abstraction layer for OpenGL with an immediate-mode API.
    * `reasings`: Functions for smooth animation transitions.
    * `rmem`: Memory pool and object pool allocators.
    * `rcamera`: A basic camera system.
* **Configuration:**
    * `naylib.nimble`: The package definition file for Nimble.
    * `config.nims`: Used to configure build options, such as enabling or disabling specific Raylib features.
    * The wrapper generator has its own configuration files in the `tools/wrapper` directory.
* **CI/CD Pipeline:** `.github/workflows/ci.yml` defines the CI pipeline, which runs tests on Linux, Windows, and macOS for native and WebAssembly builds.

## 6. Development & Testing Workflow

* **Local Development Environment:** To set up the project locally, you need to have Nim and the required system dependencies for Raylib installed. The `nimble install` command can be used to install the package.
* **Testing:** Tests are run using the `nimble test` command. This compiles and runs the tests defined in the `tests` directory.
* **CI/CD Process:** The CI pipeline is triggered on push and pull requests to the `main` branch. It runs the test suite on multiple platforms to ensure that changes don't break the build.

## 7. Specific Instructions for AI Collaboration

* **Contribution Guidelines:** The `raylib/CONTRIBUTING.md` file provides guidelines for contributing to the underlying Raylib library. While there isn't a specific `CONTRIBUTING.md` for Naylib itself, the principles of writing simple, easy-to-use code and providing good documentation are applicable.
* **Infrastructure (IaC):** Not applicable.
* **Security:** Be mindful of security, especially when dealing with file I/O and memory management. While the wrapper aims to be safe, it's still possible to introduce vulnerabilities.
* **Dependencies:** When adding new dependencies, update the `naylib.nimble` file.
* **Commit Messages:** While there is no explicit convention mentioned, it's good practice to write clear and descriptive commit messages.
* **Wrapper Generation:** The wrapper is generated using the tools in the `/tools` directory. Any changes to the Raylib API should be reflected in the generated wrapper by running the generator. The configuration for the generator is in `tools/wrapper/config.ini`.
