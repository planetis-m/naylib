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

Using nimble:

.. code-block::

  nimble install naylib
  cd $(nimble path naylib)
  nake buildDesktop

or without, git clone this repo and then:

.. code-block::

  nake buildDesktop

Official raylib `cheatsheet <https://www.raylib.com/cheatsheet/cheatsheet.html>`_

Usage Tips
==========

Creating a new project
----------------------

TODO

When compiling a new program don't forget to specify the target platform with ``--define:PlatformDesktop``.
Other available values are ``PlatformRpi``, ``PlatformDrm``, ``PlatformAndroid``.

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

- Using a block

.. code-block:: nim

  initWindow(800, 450, "example")
  block:
    let texture = loadTexture("resources/example.png")
  closeWindow()
