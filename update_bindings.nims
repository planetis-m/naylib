import std/os

const
  originUrl = "https://github.com/planetis-m/naylib"
  pkgDir = thisDir().quoteShell
  rayDir = pkgDir / "src/raylib"
  apiDir = pkgDir / "api"
  docsDir = pkgDir / "docs"

template `/.`(x: string): string =
  (when defined(posix): "./" & x else: x)

proc genWrapper(lib: string) =
  let src = lib & "_gen.nim"
  withDir(pkgDir / "tools"):
    let exe = toExe(lib & "_gen")
    # Build the ray2nim tool
    exec("nim c --mm:arc --panics:on -d:release -d:emiLenient " & src)
    # Generate {lib} Nim wrapper
    exec(/.exe)

proc genApiJson(lib, prefix: string) =
  let src = "raylib_parser.c"
  withDir(rayDir / "parser"):
    let exe = toExe("raylib_parser")
    # Building raylib API parser
    exec("cc " & src & " -o " & exe)
    mkDir(apiDir)
    let header = rayDir / "src" / (lib & ".h")
    let apiJson = apiDir / (lib & "_api.json")
    # Generate {lib} API JSON file
    exec(/.exe & " -f JSON " & (if prefix != "": "-d " & prefix else: "") &
        " -i " & header & " -o " & apiJson)

proc wrapRaylib(lib, prefix: string) =
  genApiJson(lib, prefix)
  genWrapper(lib)

task wrap, "Produce all raylib nim wrappers":
  wrapRaylib("raylib", "RLAPI")
  # wrapRaylib("raymath", "RMAPI")
  genWrapper("rlgl")
  # wrapRaylib("rlgl", "")

task docs, "Generate documentation":
  # https://nim-lang.github.io/Nim/docgen.html
  withDir(pkgDir):
    for tmp in items(["raymath", "raylib", "rlgl", "reasings"]):
      let doc = docsDir / tmp.addFileExt(".html")
      let src = "src" / tmp
      # Generate the docs for {src}
      exec("nim doc --verbosity:0 --git.url:" & originUrl &
          " --git.devel:main --git.commit:main --out:" & doc & " " & src)
