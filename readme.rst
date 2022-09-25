=============================================================
          Naylib - Yet another raylib Nim wrapper
=============================================================

This repo contains raylib wrapper generated using raylib_parser.
It focuses on an idiomatic Nim API.

The Docs are `here <https://planetis-m.github.io/naylib/raylib.html>`_

Examples
========

See the accompanying examples `repo <https://github.com/planetis-m/raylib-examples>`_

Installation
============

Install with ``nimble install naylib`` then cd in the installed directory,
i.e: ``cd $(nimble path naylib)`` and run:

.. code-block::

  nimble buildDesktop

Official raylib `cheatsheet <https://www.raylib.com/cheatsheet/cheatsheet.html>`_

Usage Tips
==========

Creating a new project
----------------------

TODO

When compiling a new program don't forget to specify the target platform with ``--define:PlatformDesktop``.
Other available values are ``PlatformRpi`` (deprecated in raylib 4.2), ``PlatformDrm``, ``PlatformAndroid``.

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

  proc initGame(width, height, fps: int32, flags: Flags[ConfigFlags], title: string): Game =
    assert not isWindowReady(), "Window is already opened"
    setConfigFlags(flags)
    initWindow(width, height, title)
    setTargetFPS(fps)

  proc gameShouldClose(x: Game): bool {.inline.} =
    result = windowShouldClose()

  let game = initGame(800, 450, 60, flags(FlagMsaa4xHint, FlagWindowHighdpi), "example")
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

========================== ================================ ==============================
raylib function            Native alternative               notes
========================== ================================ ==============================
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
========================== ================================ ==============================

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
TextSplit          strutils.split
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
================== ============================== ========
