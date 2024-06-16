import std/os

const
  ProjectUrl = "https://github.com/planetis-m/naylib"
  PkgDir = thisDir().quoteShell
  RaylibDir = PkgDir / "raylib"
  RaylibGit = "https://github.com/raysan5/raylib.git"
  RayLatestCommit = "dcf2f6a8e97911c90efce5722bd7f0c7cdc8601e"
  ApiDir = PkgDir / "api"
  DocsDir = PkgDir / "docs"

template `/.`(x: string): string =
  (when defined(posix): "./" & x else: x)

proc fetchLatestRaylib =
  if not dirExists(RaylibDir):
    exec "git clone --depth 1 " & RaylibGit & " " & RaylibDir
  withDir(RaylibDir):
    exec "git switch -"
    exec "git fetch --depth 100 origin " & RayLatestCommit
    exec "git checkout " & RayLatestCommit

proc genWrapper(lib: string) =
  let src = lib & "_gen.nim"
  withDir(PkgDir / "tools"):
    let exe = toExe(lib & "_gen")
    # Build the ray2nim tool
    exec("nim c --mm:arc --panics:on -d:release -d:emiLenient " & src)
    # Generate {lib} Nim wrapper
    exec(/.exe)

proc genApiJson(lib, prefix: string) =
  let src = "raylib_parser.c"
  withDir(RaylibDir / "parser"):
    let exe = toExe("raylib_parser")
    # Building raylib API parser
    exec("cc " & src & " -o " & exe)
    mkDir(ApiDir)
    let header = RaylibDir / "src" / (lib & ".h")
    let apiJson = ApiDir / (lib & ".json")
    # Generate {lib} API JSON file
    exec(/.exe & " -f JSON " & (if prefix != "": "-d " & prefix else: "") &
        " -i " & header & " -o " & apiJson)

proc wrapRaylib(lib, prefix: string) =
  genApiJson(lib, prefix)
  genWrapper(lib)

task wrap, "Produce all raylib nim wrappers":
  wrapRaylib("raylib", "RLAPI")
  # genWrapper("raylib")
  # wrapRaylib("raymath", "RMAPI")
  genWrapper("rlgl")
  # wrapRaylib("rlgl", "")

task patch, "Patch raylib":
  withDir(PkgDir / "src/raylib"):
    # exec "git rev-parse HEAD"
    let patchPath = PkgDir / "mangle_names.patch"
    exec "git apply --reject " & patchPath

task update, "Update the raylib git directory":
  fetchLatestRaylib()
  cpDir(RaylibDir / "src", PkgDir / "src/raylib")
  # patchTask()

task docs, "Generate documentation":
  # https://nim-lang.github.io/Nim/docgen.html
  withDir(PkgDir):
    for tmp in items(["raymath", "raylib", "rlgl", "reasings"]):
      let doc = DocsDir / (tmp & ".html")
      let src = "src" / tmp
      # Generate the docs for {src}
      exec("nim doc --verbosity:0 --git.url:" & ProjectUrl &
          " --git.devel:main --git.commit:main --out:" & doc & " " & src)
