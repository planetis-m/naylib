==============================================================
Naylib - Your Nimble Companion for Game Development Adventures
==============================================================

Welcome to this repository! Here you'll find a Nim wrapper for raylib, a library for
creating 2D and 3D games. The Nim API is designed to be user-friendly and easy to use.

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

To use the OpenGL graphics backend on desktop, select one of the options below:

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

Note: By default, naylib will use OpenGL 3.3 on desktop platforms.

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
you can install the following AUR packages instead: ``android-sdk android-sdk-build-tools
android-sdk-platform-tools android-ndk android-platform``.

**2. Fork the** `planetis-m/raylib-game-template <https://github.com/planetis-m/raylib-game-template>`_ **repository.**

The `build_android.nims <https://github.com/planetis-m/raylib-game-template/blob/master/build_android.nims#L16-L49>`_
file allows you to specify the locations of the OpenJDK, Android SDK, NDK on your computer
by setting variables in the file. It also contains several configuration options that can
be customized to suit your needs, such as the architecture of the device you are targeting
or making multiplatform APKs.

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

How to call closeWindow
-----------------------

Types are wrapped with Nim's destructors but ``closeWindow`` must be called at the very end.
This might create a conflict with variables that are destroyed after the last statement in your program.
It can easily be avoided with one of the following ways:

- Using defer (not available at the top level) or try/finally

.. code-block:: nim

  initWindow(800, 450, "example")
  defer: closeWindow()
  let texture = loadTexture("resources/example.png")

- Wrap everything in a game object

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

- Using a block or a proc call

.. code-block:: nim

  initWindow(800, 450, "example")
  block:
    let texture = loadTexture("resources/example.png")
  closeWindow()

Raylib functions to Nim
-----------------------

Some raylib functions are not wrapped as the API is deemed too C-like and better alternatives exist in the Nim stdlib.
Bellow is a table that will help you convert those functions to native Nim functions.

Files management functions
~~~~~~~~~~~~~~~~~~~~~~~~~~

========================== ================================ =================
raylib function            Native alternative               notes
========================== ================================ =================
LoadFileData               readFile                         Cast to seq[byte]
UnloadFileData             None                             Not needed
SaveFileData               writeFile
LoadFileText               readFile
UnloadFileText             None                             Not needed
SaveFileText               writeFile
FileExists                 os.fileExists
DirectoryExists            os.dirExists
IsFileExtension            strutils.endsWith
GetFileExtension           os.splitFile, os.searchExtPos
GetFileName                os.extractFilename
GetFileLength              os.getFileSize
GetFileNameWithoutExt      os.splitFile
GetDirectoryPath           os.splitFile
GetPrevDirectoryPath       os.parentDir, os.parentDirs
GetWorkingDirectory        os.getCurrentDir
GetApplicationDirectory    os.getAppDir
GetDirectoryFiles          os.walkDir, os.walkFiles
ChangeDirectory            os.setCurrentDir
GetFileModTime             os.getLastModificationTime
IsPathFile                 os.getFileInfo
========================== ================================ =================

Text strings management functions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

================== ========================================== ================
raylib function    Native alternative                         notes
================== ========================================== ================
TextCopy           assignment
TextIsEqual        `==`
TextLength         len
TextFormat         strutils.format, strformat.`&`
TextSubtext        substr
TextReplace        strutils.replace, strutils.multiReplace
TextInsert         insert
TextJoin           strutils.join
TextSplit          strutils.split, unicode.split
TextAppend         add
TextFindIndex      strutils.find
TextToUpper        strutils.toUpperAscii, unicode.toUpper
TextToLower        strutils.toLowerAscii, unicode.toLower
TextToPascal       None                                       Write a function
TextToInteger      strutils.parseInt
================== ========================================== ================

Text codepoints management functions (unicode characters)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

======================= ===================== ==============================
raylib function         Native alternative    notes
======================= ===================== ==============================
LoadCodepoints          toRunes
UnloadCodepoints        None                  Not needed
GetCodepoint            runeAt, size          Returns 0xFFFD on error
GetCodepointCount       runeLen
GetCodepointPrevious    None                  toRunes and iterate in reverse
GetCodepointNext        None                  Use runes iterator
CodepointToUTF8         toUTF8
LoadUTF8                toUTF8
UnloadUTF8              None                  Not needed
======================= ===================== ==============================

See also proc ``graphemeLen``, ``runeSubStr`` and everything else provided by std/unicode.

Compression/Encoding functionality
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

================== ===================== ================
raylib function    Native alternative    notes
================== ===================== ================
CompressData       zippy.compress        External package
DecompressData     zippy.decompress
EncodeDataBase64   base64.encode
DecodeDataBase64   base64.decode
================== ===================== ================

Misc
~~~~

================== ============================== ========
raylib function    Native alternative             notes
================== ============================== ========
GetRandomValue     random.rand
SetRandomSeed      random.randomize
OpenURL            browsers.openDefaultBrowser
PI (C macros)      math.PI
DEG2RAD            math.degToRad
RAD2DEG            math.radToDeg
================== ============================== ========

Other changes and improvements
------------------------------

- Raw pointers were abstracted from the public API, except ``cstring`` parameters which are
  implicitly converted from ``string``. Use ``--warning:CStringConv:off`` to silence
  the warning.

- ``LoadDroppedFiles``, ``UnloadDroppedFiles`` added in raylib 4.2 were removed and
  replaced by the older ``getDroppedFiles`` which is more efficient and simpler to wrap,
  as it doesn't require as many copies.

- ``ConfigFlags`` and ``Gesture`` are used in raylib as bitflags. There is a convenient
  ``flags`` proc that returns ``Flags[T]``.

- ``CSeq`` type is added which encapsulates memory managed by raylib for zero copies.
  Provided are index operators, len, and ``@`` (seq) and ``toOpenArray`` converters.

- ``toEmbedded`` procs that return ``EmbeddedImage``, ``EmbeddedWave``, that are not
  destroyed, for embedding files directly to source code. Use ``exportImageAsCode``
  and ``exportWaveAsCode`` first and translate the output to Nim with a tool such as c2nim
  or manually. See `others/embedded_files_loading` example.

- ``ShaderV`` and ``Pixel`` concepts allow plugging-in foreign data types to procs that
  use them (``setShaderValue``, ``updateTexture``, etc).

- Data types that hold pointers to arrays of structs, most notably ``Mesh``, are properly
  encapsulated and offer index operators for a safe and idiomatic API.

- Every function argument or struct field, that is supposed to use a specific C enum type,
  is properly typechecked. So wrong code like ``isKeyPressed(Left)`` doesn't compile.

- Mapped C to Nim enums and shortened values by removing the prefix.

- Raymath was ported to Nim and a integer vector type called ``IndexN`` was added.
  Reasings was also ported to Nim.

- The names of functions that are overloaded no longer end with ``Ex``, ``Pro``, ``Rec``, ``V``.
  Functions that return ``Vector2`` or ``Rectangle`` are an exception.

Alternatives
============

While we believe that naylib provides a great option for game development with Nim, we
understand that it may not be the perfect fit for everyone. Here are some alternative
libraries that you may want to check out:

- `NimForUE <https://github.com/jmgomez/NimForUE>`_ - a Nim plugin for the Unreal Engine 5.
- `godot-nim <https://github.com/pragmagic/godot-nim>`_ - Nim bindings for the Godot game engine.
- `nico <https://github.com/ftsf/nico>`_ - a Nim-based game framework inspired by Pico-8.
- `p5nim <https://github.com/pietroppeter/p5nim>`_ - a processing library for Nim.

For more game development options in Nim, you can check out
`awesome-nim <https://github.com/ringabout/awesome-nim#game-development>`_.
