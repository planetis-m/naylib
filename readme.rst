==============================================================
Naylib - Your Nimble Companion for Game Development Adventures
==============================================================

Welcome to this repository! Here you'll find a Nim wrapper for raylib, a library for
creating 2D and 3D games. The Nim API is designed to be user-friendly and easy to use.

> **WARNING**: Currently Naylib only works with Nim version 2.0.0 which is expected to be released soon.
> Use a `nightlies build <https://github.com/nim-lang/nightlies/releases>`_ in the meantime.

Documentation
=============

To learn more about how to use this wrapper, you can check out the documentation:

- `raylib <https://planetis-m.github.io/naylib/raylib.html>`_ - documentation for the raylib module
- `raymath <https://planetis-m.github.io/naylib/raymath.html>`_ - documentation for the raymath module
- `rlgl <https://planetis-m.github.io/naylib/rlgl.html>`_ - documentation for the rlgl module
- `reasings <https://planetis-m.github.io/naylib/reasings.html>`_ - documentation for the reasings module

If you're familiar with the C version of raylib, you may find the
`cheatsheet <https://www.raylib.com/cheatsheet/cheatsheet.html>`_ useful.

Installation
============

To install this wrapper, simply run ``nimble install naylib``.

Examples
========

We've also provided some example code to help you get started. You can find it in the
accompanying `example repository <https://github.com/planetis-m/raylib-examples>`_. To
compile and run an example, run the command ``nim c -r -d:release example.nim`` in your
terminal.

Usage Tips
==========

Creating a new project
----------------------

To choose a version of the OpenGL graphics backend on desktop, select one of the following options:

- ``-d:GraphicsApiOpenGl43`` (OpenGL 4.3)
- ``-d:GraphicsApiOpenGl33`` (OpenGL 3.3 - default)
- ``-d:GraphicsApiOpenGl21`` (OpenGL 2.1)
- ``-d:GraphicsApiOpenGl11`` (OpenGL 1.1)
- ``-d:GraphicsApiOpenGlEs2`` (OpenGL ES 2.0)

If you're compiling on Linux for Wayland, add the ``-d:wayland`` flag.

To compile your code to run on the web using WebAssembly, you will need to define
emscripten. Additionally, you will need to create a configuration file. You can find an
example configuration file at
https://github.com/planetis-m/raylib-examples/blob/main/core/basic_window_web.nims.

Note: By default, Naylib will use OpenGL 3.3 on desktop platforms.

Building for Android
--------------------

Building your raylib project for Android is a bit different than building for desktop.
Here are the steps you need to follow:

**1. Install OpenJDK, Android SDK and Android NDK by following the instructions on the official raylib wiki:**

You can find instructions on how to install OpenJDK, Android SDK, and Android NDK on the official raylib wiki. Here are the links to the instructions for different platforms:

- `Working for Android <https://github.com/raysan5/raylib/wiki/Working-for-Android>`_
- `Working for Android (on Linux) <https://github.com/raysan5/raylib/wiki/Working-for-Android-(on-Linux)>`_
- `Working for Android (on macOS) <https://github.com/raysan5/raylib/wiki/Working-for-Android-(on-macOS)>`_

Note that you can use the latest versions of the software. Alternatively, on Arch Linux,
you can install the following AUR packages instead:
``android-sdk android-sdk-build-tools android-sdk-platform-tools android-ndk android-platform(-29)``.

**2. Fork the** `planetis-m/raylib-game-template <https://github.com/planetis-m/raylib-game-template>`_ **repository.**

The `build_android.nims <https://github.com/planetis-m/raylib-game-template/blob/master/build_android.nims#L22-L55>`_
file allows you to specify the locations of the OpenJDK, Android SDK, NDK on your computer
by setting variables in the file. It also contains several configuration options that can
be customized to suit your needs, such as the application name and icon or the architecture of
the device you are targeting.

**3. Run the following commands to setup and then build the project for Android:**

Use the following command to set up and build the project for Android:

.. code-block:: bash

  nimble setupAndroid
  nimble buildAndroid

If everything goes smoothly, you will see a file named raylib_game.apk in the same directory.

**4. Install and run the APK on your Android device.**

Enable USB Debugging on your Android device, plug it into your computer, and install the
package with the following command:

.. code-block:: bash

  adb -d install raylib_game.apk

Now you should be able to run your raylib game on your Android device!

How to properly call closeWindow
--------------------------------

While types in Naylib are wrapped with Nim's destructors, ``closeWindow`` needs to be
called at the very end of the program. However, this can cause conflicts with variables
that are destroyed after the last statement in your program.

To avoid these conflicts, you can use one of the following methods:

- Use the ``defer`` statement (which is not available at the top level) or the ``try-finally`` block.

.. code-block:: nim

  initWindow(800, 450, "example")
  defer: closeWindow()
  let texture = loadTexture("resources/example.png")

- Wrap everything inside a game object.

.. code-block:: nim

  type
    Game = object

  proc `=destroy`(x: var Game) =
    assert isWindowReady(), "Window is already closed"
    closeWindow()

  proc `=sink`(x: var Game; y: Game) {.error.}
  proc `=copy`(x: var Game; y: Game) {.error.}
  proc `=wasMoved`(x: var Game) {.error.}

  proc initGame(width, height, fps: int32, flags: Flags[ConfigFlags], title: string): Game =
    assert not isWindowReady(), "Window is already opened"
    setConfigFlags(flags)
    initWindow(width, height, title)
    setTargetFPS(fps)

  proc gameShouldClose(x: Game): bool {.inline.} =
    result = windowShouldClose()

  let game = initGame(800, 450, 60, flags(Msaa4xHint, WindowHighdpi), "example")
  let texture = loadTexture("resources/example.png")

- Open a new scope

.. code-block:: nim

  initWindow(800, 450, "example")
  block:
    let texture = loadTexture("resources/example.png")
  closeWindow()


Raylib functions to Nim
-----------------------

While most of raylib functions are wrapped in Naylib, some functions are not wrapped
because they closely reflect the C API and are considered less idiomatic or harder to use.
Here is a `table <alternatives_table.rst>`_ that provides their equivalent Nim functions.

Overview of Changes and Features
================================

Destructor-based Memory Management of Raylib Types
--------------------------------------------------

Types in Naylib like ``Image``, ``Wave`` use destructors and as a nice bonus they do not
require manual ``Unload`` calls anymore.

Change in Naming Convention
---------------------------

In raylib, various functions have similar names that differ in suffixes based on the type
of arguments they receive, such as ``DrawRectangle`` vs ``DrawRectangleV`` vs
``DrawRectangleRec`` vs ``DrawRectanglePro``. However, in Naylib, this naming
convention has changed. Functions that return ``Vector2`` or ``Rectangle`` still follow
the previous naming convention, but function overloading is now used for cases that
previously employed different suffixes. This allows for a more uniform and intuitive
naming convention.

Encapsulation and Safe API for Pointers to Arrays of Structures
---------------------------------------------------------------

Data types that hold pointers to arrays of structures, such as ``Model``, are encapsulated
and offer index operators to provide a safe and idiomatic API. As an example, the code
snippet ``model.materials[0].maps[MaterialMapIndex.Diffuse].texture = texture`` includes a
runtime bounds check on the index to ensure safe access to the data.

Mapping of C Enums to Nim
-------------------------

The C enums have been mapped to Nim, and their values have been shortened by removing
their prefix. For instance, ``LOG_TRACE`` is represented as ``Trace``.

Type Checking for Enums
-----------------------

Each function argument or struct field that is intended to employ a particular C enum type
undergoes type checking. Consequently, erroneous code such as
``isKeyPressed(MouseButton.Left)`` fails to compile.

Abstraction of Raw Pointers and CString Parameters
--------------------------------------------------

To improve the safety and usability of the public API, Naylib has abstracted the use of
raw pointers through the use of ``openArray[T]``, with the exception of ``cstring``
parameters, which are automatically converted from ``string``. If you encounter a warning
related to ``CStringConv``, you can silence it by using the ``--warning:CStringConv:off``
flag.

Compliment Begin-End Pairs with Extra Sugar
-------------------------------------------

For begin-end pairs, such as ``beginDrawing``, ``endDrawing`` extra syntactic sugar was
added in the form of templates like ``drawing``, ``mode3D`` that accept a block of code,
and provide extra safety in case of errors since the programs is not left in an invalid
state, because the "end" part is always executed.

Addition of RArray Type
-----------------------

The ``RArray[T]`` type has been added to encapsulate memory managed by raylib. It provides
index operators, len, and ``@`` (which converts to ``seq``) and ``toOpenArray``. You can use
this type to work with raylib functions that manage memory without needing to make copies.

Working with Bitflags in Nim
----------------------------

Raylib uses bitflags for ``ConfigFlags`` and ``Gesture``. To work with these flags in
Nim, you can use the ``flags`` procedure which returns ``Flags[T]``.

Change in Dropped Files Functions
---------------------------------

In raylib 4.2, the functions ``LoadDroppedFiles`` and ``UnloadDroppedFiles`` were
introduced but were later removed. Instead, the older function ``getDroppedFiles`` was
reintroduced as it is more efficient and easier to wrap, requiring fewer copies.

Using Embedded Images and Waves in Naylib
-----------------------------------------

Use the ``toEmbedded`` procs to get an ``EmbeddedImage`` or ``EmbeddedWave``, which are
not memory managed and can be embedded directly into source code. To use this feature,
first export the image or wave as code using the ``exportImageAsCode`` or
``exportWaveAsCode`` procs, and then translate the output to Nim using a tool such as
``c2nim`` or by manual conversion. An example of how to use this feature can be found in
the file ``others/embedded_files_loading.nim`` which is available at
https://github.com/planetis-m/raylib-examples/blob/master/embedded_files_loading.nim.

Integration of External Data Types with ShaderV and Pixel
---------------------------------------------------------

The concepts of ``ShaderV`` and ``Pixel`` permit the integration of external data types
into procs that employ them, such as ``setShaderValue`` and ``updateTexture``.

Math Libraries and Integer Vector Type in Naylib
------------------------------------------------

In addition to porting the ``raymath`` and ``reasings`` libraries to Nim, Naylib also
provides math operators like ``+``, ``*``, ``-=`` for convenience. Furthermore, Naylib
introduces an integer vector type called ``IndexN`` to facilitate operations with indices.

Alternatives
============

While we believe that Naylib provides a great option for game development with Nim, we
understand that it may not be the perfect fit for everyone. Here are some alternative
libraries that you may want to check out:

- `NimForUE <https://github.com/jmgomez/NimForUE>`_ - a Nim plugin for the Unreal Engine 5.
- `godot-nim <https://github.com/pragmagic/godot-nim>`_ - Nim bindings for the Godot game engine.
- `nico <https://github.com/ftsf/nico>`_ - a Nim-based game framework inspired by Pico-8.
- `p5nim <https://github.com/pietroppeter/p5nim>`_ - a processing library for Nim.

For more game development options in Nim, you can check out
`awesome-nim <https://github.com/ringabout/awesome-nim#game-development>`_.
