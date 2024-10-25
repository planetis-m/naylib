import std/[pegs, strutils, dirs, paths, cmdline]
when defined(nimPreviewSlimSystem):
  from std/syncio import readFile, writeFile

const nonWordChar = {'\1'..'\xff'} - IdentChars

func matchIdentifier(identifier: string): Peg =
  let wordBoundary = charSet(nonWordChar) / startAnchor() / endAnchor()
  result = sequence(capture(wordBoundary), term(identifier), capture(wordBoundary))

let replacements = [
  # Match identifier when surrounded by non-word chars, but only capture the identifier
  (matchIdentifier("Rectangle"), "$1rlRectangle$2"),
  (matchIdentifier("CloseWindow"), "$1rlCloseWindow$2"),
  (matchIdentifier("ShowCursor"), "$1rlShowCursor$2"),
  (matchIdentifier("LoadImage"), "$1rlLoadImage$2"),
  (matchIdentifier("DrawText"), "$1rlDrawText$2"),
  (matchIdentifier("DrawTextEx"), "$1rlDrawTextEx$2")
]

proc processFile(path: Path, replacements: openArray[(Peg, string)]) =
  let pathStr = string(path)
  if not (pathStr.endsWith(".c") or pathStr.endsWith(".h")):
    return

  echo "Processing: ", pathStr
  var content = readFile(pathStr)
  var newContent = content.parallelReplace(replacements)

  # Write back only if changes were made
  if newContent != content:
    writeFile(pathStr, newContent)
    echo "  Modified: ", pathStr

proc main() =
  if paramCount() < 1:
    echo "Usage: mangle_names <directory>"
    quit(1)

  let sourceDir = Path(paramStr(1))
  if dirExists(sourceDir):
    echo "Starting replacement process..."
    for path in walkDirRec(sourceDir):
      processFile(path, replacements)
    echo "Replacement process completed."
  else:
    echo "Error: Directory '", string(sourceDir), "' not found!"

when isMainModule:
  main()
