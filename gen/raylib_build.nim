import std/[os, osproc]

const
  RaylibStableCommit = "0851960397f02a477d80eda2239f90fae14dec64"

template withDir(dir, body) =
  let old = getCurrentDir()
  try:
    setCurrentDir(dir)
    body
  finally:
    setCurrentDir(old)

template exec(cmd: string) =
  if execShellCmd(cmd) != 0: quit("FAILURE", QuitFailure)

proc main =
  if not dirExists("../dist/raylib"):
    exec("git clone --depth 1 https://github.com/raysan5/raylib.git ../dist/raylib")
  withDir("../dist/raylib"):
    exec("git fetch")
    #exec("git checkout " & RaylibStableCommit)
    withDir("src"):
      exec("make PLATFORM=PLATFORM_DESKTOP -j4")
      exec("sudo make install")
    # TODO: produce api JSON files

main()
