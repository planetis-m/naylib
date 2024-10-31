import std/[pegs, strutils, dirs, paths, cmdline]
when defined(nimPreviewSlimSystem):
  from std/syncio import readFile, writeFile

const NonWordChars = {'\1'..'\xff'} - IdentChars

func ident(name: string): Peg =
  # Match identifier when surrounded by non-word chars.
  let wordBoundary = charSet(NonWordChars) / startAnchor() / endAnchor()
  sequence(capture(wordBoundary), term(name), capture(wordBoundary))

let replacements = [
  (ident"Rectangle", "$1rlRectangle$2"),
  (ident"CloseWindow", "$1rlCloseWindow$2"),
  (ident"ShowCursor", "$1rlShowCursor$2"),
  (ident"LoadImage", "$1rlLoadImage$2"),
  (ident"DrawText", "$1rlDrawText$2"),
  (ident"DrawTextEx", "$1rlDrawTextEx$2")
]

proc processFile(path: Path, replacements: openArray[(Peg, string)]) =
  echo "Processing: ", path
  let content = readFile($path)
  let newContent = content.parallelReplace(replacements)

  # Write back only if changes were made
  if newContent != content:
    writeFile($path, newContent)
    echo "  Modified: ", path

proc main() =
  if paramCount() < 1:
    echo "Usage: mangle_names <directory>"
    quit(1)

  let sourceDir = Path(paramStr(1))
  if dirExists(sourceDir):
    echo "Starting replacement process..."
    for path in walkDirRec(sourceDir):
      if endsWith($path, ".c") or endsWith($path, ".h"):
        processFile(path, replacements)
    echo "Replacement process completed."
  else:
    echo "Error: Directory '", sourceDir, "' not found!"

when isMainModule:
  main()
