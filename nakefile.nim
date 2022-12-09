import nake, std/strformat

const
  pkgDir = currentSourcePath().parentDir.quoteShell
  rayDir = pkgDir / "/src/raylib"
  apiDir = pkgDir / "/api"
  docsDir = pkgDir / "/docs"

proc genWrapper(lib: string) =
  let src = lib & "_gen.nim"
  withDir(pkgDir / "/tools"):
    var exe = src.changeFileExt(ExeExt)
    direSilentShell "Building the ray2nim tool...",
        "nim c --mm:arc --panics:on -d:release -d:emiLenient " & src
    normalizeExe(exe)
    direSilentShell &"Generating {lib} Nim wrapper...", exe

proc genApiJson(lib, prefix: string) =
  let src = "raylib_parser.c"
  withDir(rayDir / "/parser"):
    var exe = src.changeFileExt(ExeExt)
    direSilentShell "Building raylib API parser...", &"cc {src} -o {exe}"
    discard existsOrCreateDir(apiDir)
    normalizeExe(exe)
    let header = rayDir / &"/src/{lib}.h"
    let apiJson = apiDir / &"/{lib}_api.json"
    direSilentShell &"Generating {lib} API JSON file...",
        exe & " -f JSON " & (if prefix != "": "-d " & prefix else: "") &
        &" -i {header} -o {apiJson}"

proc wrapRaylib(lib, prefix: string) =
  genApiJson(lib, prefix)
  genWrapper(lib)

task "wrap", "Produce all raylib nim wrappers":
  wrapRaylib("raylib", "RLAPI")
  # wrapRaylib("raymath", "RMAPI")
  genWrapper("rlgl")
  # wrapRaylib("rlgl", "")

task "docs", "Generate documentation":
  # https://nim-lang.github.io/Nim/docgen.html
  withDir(pkgDir):
    for tmp in items(["raymath", "raylib", "rlgl", "reasings"]):
      let doc = docsDir / tmp.addFileExt(".html")
      let src = "src/" / tmp
      direSilentShell(&"Generating the docs for {src}...",
          &"nim doc --verbosity:0 --git.url:https://github.com/planetis-m/naylib --git.devel:main --git.commit:main --out:{doc} {src}")
