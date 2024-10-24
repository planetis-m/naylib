import std/[os, strutils]

const
  ProjectUrl = "https://github.com/planetis-m/naylib"
  PkgDir = thisDir()
  RaylibDir = PkgDir / "raylib"
  RaylibGit = "https://github.com/raysan5/raylib.git"
  RayLatestCommit = "15f6c47f0715afd1fce52d760053026c2b92214c"
  ApiDir = PkgDir / "wrapper/api"
  DocsDir = PkgDir / "docs"
  ParserDir = RaylibDir / "parser"
  WrapperDir = PkgDir / "wrapper"

template `/.`(x: string): string =
  when defined(posix): "./" & x else: x

proc fetchLatestRaylib() =
  if not dirExists(RaylibDir):
    exec "git clone --depth 1 " & RaylibGit & " " & quoteShell(RaylibDir)
  withDir(RaylibDir):
    exec "git switch -"
    exec "git fetch --depth 100 origin " & RayLatestCommit
    exec "git checkout " & RayLatestCommit

proc buildParser() =
  withDir(ParserDir):
    let src = "raylib_parser.c"
    let exe = toExe("raylib_parser")
    # if not fileExists(exe) or fileNewer(src, exe):
    exec "cc " & src & " -o " & exe

proc buildWrapper() =
  withDir(WrapperDir):
    let src = "naylib_wrapper.nim"
    let exe = toExe("naylib_wrapper")
    # if not fileExists(exe) or fileNewer(src, exe):
    exec "nim c --mm:arc --panics:on -d:release -d:emiLenient " & src

proc genApiJson(lib, prefix, after: string) =
  withDir(ParserDir):
    mkDir(ApiDir)
    let header = RaylibDir / "src" / (lib & ".h")
    let apiJson = ApiDir / (lib & ".json")
    let prefixArg = if prefix != "": "-d " & prefix else: ""
    exec /.toExe("raylib_parser") & " -f JSON " & prefixArg & " -i " & header.quoteShell &
        " -t " & after.quoteShell & " -o " & apiJson.quoteShell

proc genWrapper(lib: string) =
  withDir(WrapperDir):
    let outp = PkgDir / "src" / (lib & ".nim")
    let conf = "config" / (lib & ".cfg")
    exec /.toExe("naylib_wrapper") & " -c:" & conf & " -o:" & outp

proc wrapRaylib(lib, prefix, after: string) =
  genApiJson(lib, prefix, after)
  genWrapper(lib)

task buildTools, "Build raylib_parser and naylib_wrapper":
  buildParser()
  buildWrapper()

task genApi, "Generate API JSON files":
  buildParser()
  genApiJson("raylib", "RLAPI", "")
  # genApiJson("raymath", "RMAPI", "")
  genApiJson("rlgl", "", "#endif // RLGL_H")

task genWrappers, "Generate Nim wrappers":
  genWrapper("raylib")
  # genWrapper("raymath")
  genWrapper("rlgl")

task update, "Update the raylib git directory":
  fetchLatestRaylib()
  rmDir(PkgDir / "src/raylib")
  cpDir(RaylibDir / "src", PkgDir / "src/raylib")
  cpFile(PkgDir / "src/naylib.h", PkgDir / "src/raylib/naylib.h")
  cpFile(PkgDir / "src/naylib.c", PkgDir / "src/raylib/naylib.c")

task wrap, "Produce all raylib Nim wrappers":
  buildToolsTask()
  wrapRaylib("raylib", "RLAPI", "")
  # wrapRaylib("raymath", "RMAPI", "")
  wrapRaylib("rlgl", "", "#endif // RLGL_H")

task docs, "Generate documentation":
  withDir(PkgDir):
    for tmp in ["raymath", "raylib", "rlgl", "reasings", "rmem"]:
      let doc = DocsDir / (tmp & ".html")
      let src = "src" / tmp
      let showNonExports = if tmp != "rmem": " --shownonexports" else: ""
      exec "nim doc --verbosity:0 --git.url:" & ProjectUrl & showNonExports &
           " --git.devel:main --git.commit:main --out:" & doc.quoteShell & " " & src
