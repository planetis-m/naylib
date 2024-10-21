# ****************************************************************************************
#
#   raylib [core] example - Basic window
#
#   Welcome to raylib!
#
#   To test examples, just press F6 and execute raylib_compile_execute script
#   Note that compiled executable is placed in the same folder as .c file
#
#   You can find all basic examples on C:\raylib\raylib\examples folder or
#   raylib official webpage: www.raylib.com
#
#   Enjoy using raylib. :)
#
#   Example originally created with raylib 1.0, last time updated with raylib 1.0
#
#   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
#   BSD-like license that allows static linking with closed source software
#
#   Copyright (c) 2013-2023 Ramon Santamaria (@raysan5)
#   Converted to Nim by Antonis Geralis (@planetis-m) in 2022
#
# ****************************************************************************************

import raylib, rlgl, raymath, rmem, reasings, std/[os, times, monotimes, syncio, streams, strutils, parseutils, osproc, locks, terminal]

# ----------------------------------------------------------------------------------------
# Global Variables Definition
# ----------------------------------------------------------------------------------------

const
  screenWidth = 800
  screenHeight = 450

# ----------------------------------------------------------------------------------------
# Module functions Definition
# ----------------------------------------------------------------------------------------

proc testShowCursor() =
  showCursor()

proc testDrawRectangle() =
  let rec = Rectangle(x: 100, y: 100, width: 200, height: 150)
  let color = Red
  drawRectangle(rec, color)

proc testLoadImage() =
  try:
    let image = loadImage("test_image.png")
  except RaylibError:
    echo "Error loading image"

proc testDrawText() =
  drawText("Hello, World!", 100, 100, 20, Black)

proc testDrawTextWithFont() =
  let font = getFontDefault()
  let position = Vector2(x: 200, y: 200)
  drawText(font, "Hello with custom font", position, 24, 2, DarkGray)

# Additional module tests
proc testOs() =
  echo "Current directory: ", getCurrentDir()
  echo "Temp directory: ", getTempDir()

proc testTimes() =
  echo "Current time: ", now()
  echo "Current UTC time: ", utc(now())

proc testMonotimes() =
  let start = getMonoTime()
  sleep(100)
  let duration = getMonoTime() - start
  echo "Slept for ", duration

proc testSyncio() =
  let file = open("test.txt", fmWrite)
  file.write("Hello, SyncIO!")
  file.close()

proc testStreams() =
  let strm = newFileStream("test_stream.txt", fmWrite)
  if not isNil(strm):
    strm.writeLine("Hello, Streams!")
    strm.close()

proc testStrutils() =
  let str = "  Hello, World!  "
  echo "Stripped: ", strip(str)
  echo "To lower: ", toLowerAscii(str)

proc testParseutils() =
  var value: int
  discard parseInt("42", value)
  echo "Parsed integer: ", value

proc testOsproc() =
  let (output, exitCode) = execCmdEx("echo Hello from subprocess")
  echo "Subprocess output: ", output
  echo "Exit code: ", exitCode

proc testLocks() =
  var lock: Lock
  initLock(lock)

  withLock(lock):
    echo "This is executed in a locked state"

  deinitLock(lock)

proc testTerminal() =
  styledEcho(fgRed, "This is red text")
  styledEcho(fgGreen, bgBlue, "Green text on blue background")

  echo "Cursor position: ", cursorPos()
  setCursorPos(0, 5)
  echo "Moved cursor to row 5, column 0"

# ----------------------------------------------------------------------------------------
# Program main entry point
# ----------------------------------------------------------------------------------------

proc main =
  # Initialization
  # --------------------------------------------------------------------------------------
  initWindow(screenWidth, screenHeight, "raylib [core] example - basic window")
  setTargetFPS(60) # Set our game to run at 60 frames-per-second
  # --------------------------------------------------------------------------------------

  # Run tests
  testShowCursor()
  testDrawRectangle()
  testLoadImage()
  testDrawText()
  testDrawTextWithFont()

  # Run additional module tests
  testOs()
  testTimes()
  testMonotimes()
  testSyncio()
  testStreams()
  testStrutils()
  testParseutils()
  testOsproc()
  testLocks()
  testTerminal()

  # Main game loop
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    # ------------------------------------------------------------------------------------
    # TODO: Update your variables here
    # ------------------------------------------------------------------------------------
    # Draw
    # ------------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(RayWhite)
    drawText("Congrats! You created your first window!", 190, 200, 20, LightGray)
    endDrawing()
    # ------------------------------------------------------------------------------------
  # De-Initialization
  # --------------------------------------------------------------------------------------
  closeWindow() # Close window and OpenGL context
  # --------------------------------------------------------------------------------------

main()
