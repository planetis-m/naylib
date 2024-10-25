import std/[pegs, strutils, dirs, paths, cmdline]
when defined(nimPreviewSlimSystem):
  from std/syncio import readFile, writeFile

const NonWordChars = {'\1'..'\xff'} - IdentChars

func identifier(name: string): Peg =
  let wordBoundary = charSet(NonWordChars) / startAnchor() / endAnchor()
  result = sequence(capture(wordBoundary), term(name), capture(wordBoundary))

let replacements = [
  # Match identifier when surrounded by non-word chars, but only capture the identifier
  (identifier("Rectangle"), "$1rlRectangle$2"),
  (identifier("CloseWindow"), "$1rlCloseWindow$2"),
  (identifier("ShowCursor"), "$1rlShowCursor$2"),
  (identifier("LoadImage"), "$1rlLoadImage$2"),
  (identifier("DrawText"), "$1rlDrawText$2"),
  (identifier("DrawTextEx"), "$1rlDrawTextEx$2")
]

proc processFile(path: Path, replacements: openArray[(Peg, string)]) =
  let pathStr = string(path)

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
      if path.string.endsWith(".c") or path.string.endsWith(".h"):
        processFile(path, replacements)
    echo "Replacement process completed."
  else:
    echo "Error: Directory '", string(sourceDir), "' not found!"

when isMainModule:
  main()
