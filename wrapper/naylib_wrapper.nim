import std/parseopt
import builder, config, processor, schema

proc parseCommandLine(outputpath, configpath: var string): bool =
  for kind, key, val in getopt():
    case kind
    of cmdArgument:
      discard
    of cmdLongOption, cmdShortOption:
      case key
      of "output", "o":
        outputpath = val
      of "config", "c":
        configpath = val
    of cmdEnd:
      discard
  result = outputpath.len > 0 and configpath.len > 0

proc processApi(ctx: var ApiContext, config: ConfigData) =
  filterIgnoredSymbols(ctx, config)
  processStructs(ctx, config)
  processEnums(ctx, config)
  processAliases(ctx, config)
  processFunctions(ctx, config)

proc generateWrapper(ctx: ApiContext; outputpath: string; config: ConfigData) =
  var b = openBuilder(outputpath, header = config.cHeader)
  genBindings(b, ctx, config.moduleHeader, config.afterEnums, config.afterObjects,
              config.afterFuncs, config.moduleEnd)
  b.close()

proc main =
  var
    outputpath, configpath = ""
  if not parseCommandLine(outputpath, configpath):
    quit "Usage: naylib-parser --config:<config_file> --output:<output_file>"

  let config = parseConfig(configpath)
  var ctx = ApiContext(api: parseApi(config.apiDefinition))
  processApi(ctx, config)
  generateWrapper(ctx, outputpath, config)

main()
