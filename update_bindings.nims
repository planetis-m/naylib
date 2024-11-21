import std/[os, strutils]

const
  ProjectUrl = "https://github.com/planetis-m/naylib"
  PkgDir = thisDir()
  RaylibDir = PkgDir / "raylib"
  RaylibGit = "https://github.com/raysan5/raylib.git"
  RayLatestCommit = "0d39e7137b28980f05843bd505ef3e74d8772d03"
  DocsDir = PkgDir / "docs"
  ToolsDir = PkgDir / "tools"
  ApiDir = ToolsDir / "wrapper/api"

template `/.`(x: string): string =
  when defined(posix): "./" & x else: x

proc fetchLatestRaylib() =
  var firstTime = false
  if not dirExists(RaylibDir):
    firstTime = true
    exec "git clone --depth 1 " & RaylibGit & " " & quoteShell(RaylibDir)
  withDir(RaylibDir):
    if not firstTime:
      exec "git switch -"
    exec "git fetch --depth 100 origin " & RayLatestCommit
    exec "git checkout " & RayLatestCommit

proc buildParser() =
  withDir(ToolsDir / "parser"):
    let src = "raylib_parser.c"
    let exe = toExe("raylib_parser")
    # if not fileExists(exe) or fileNewer(src, exe):
    exec "cc " & src & " -o " & exe

proc buildMangler() =
  withDir(ToolsDir / "mangler"):
    let src = "naylib_mangler.nim"
    let exe = toExe("naylib_mangler")
    # if not fileExists(exe) or fileNewer(src, exe):
    exec "nim c --mm:arc --panics:on -d:release " & src

proc buildWrapper() =
  withDir(ToolsDir / "wrapper"):
    let src = "naylib_wrapper.nim"
    let exe = toExe("naylib_wrapper")
    # if not fileExists(exe) or fileNewer(src, exe):
    exec "nim c --mm:arc --panics:on -d:release -d:emiLenient " & src

proc genApiJson(lib, prefix, after: string) =
  withDir(ToolsDir / "parser"):
    mkDir(ApiDir)
    let header = RaylibDir / "src" / (lib & ".h")
    let apiJson = ApiDir / (lib & ".json")
    let prefixArg = if prefix != "": "-d " & prefix else: ""
    exec /.toExe("raylib_parser") & " -f JSON " & prefixArg & " -i " & header.quoteShell &
        " -t " & after.quoteShell & " -o " & apiJson.quoteShell

proc genWrapper(lib: string) =
  withDir(ToolsDir / "wrapper"):
    let outp = PkgDir / "src" / (lib & ".nim")
    let conf = "config" / (lib & ".cfg")
    exec /.toExe("naylib_wrapper") & " -c:" & conf & " -o:" & outp

proc wrapRaylib(lib, prefix, after: string) =
  genApiJson(lib, prefix, after)
  genWrapper(lib)

task buildTools, "Build raylib_parser and naylib_wrapper":
  buildParser()
  buildWrapper()
  buildMangler()

task genApi, "Generate API JSON files":
  buildParser()
  genApiJson("raylib", "RLAPI", "")
  # genApiJson("rcamera", "RLAPI", "#endif // RCAMERA_H")
  # genApiJson("raymath", "RMAPI", "")
  genApiJson("rlgl", "", "#endif // RLGL_H")

task genWrappers, "Generate Nim wrappers":
  genWrapper("raylib")
  # genWrapper("rcamera")
  # genWrapper("raymath")
  genWrapper("rlgl")

task update, "Update the raylib git directory":
  fetchLatestRaylib()
  rmDir(PkgDir / "src/raylib")
  cpDir(RaylibDir / "src", PkgDir / "src/raylib")
  cpFile(RaylibDir / "parser/raylib_parser.c", ToolsDir / "parser/raylib_parser.c")

task mangle, "Mangle identifiers in raylib source":
  buildMangler()
  withDir(ToolsDir / "mangler"):
    exec /.toExe("naylib_mangler") & " " & (PkgDir / "src/raylib")

task wrap, "Produce all raylib Nim wrappers":
  buildToolsTask()
  wrapRaylib("raylib", "RLAPI", "")
  # wrapRaylib("rcamera", "RLAPI", "#endif // RCAMERA_H")
  # wrapRaylib("raymath", "RMAPI", "")
  wrapRaylib("rlgl", "", "#endif // RLGL_H")

task docs, "Generate documentation":
  withDir(PkgDir):
    for tmp in ["raymath", "raylib", "rlgl", "reasings", "rmem", "rcamera"]:
      let doc = DocsDir / (tmp & ".html")
      let src = "src" / tmp
      let showNonExports = if tmp != "rmem": " --shownonexports" else: ""
      exec "nim doc --verbosity:0 --git.url:" & ProjectUrl & showNonExports &
           " --git.devel:main --git.commit:main --out:" & doc.quoteShell & " " & src
