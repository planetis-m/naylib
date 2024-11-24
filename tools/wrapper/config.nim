import std/[strutils, streams, parsecfg, tables, sets, os]
when defined(nimPreviewSlimSystem):
  from std/syncio import readFile

type
  SymbolPair* = tuple[module, symbol: string]
  ConfigData* = object
    # Processor config
    apiDefinition*: string
    outParameters*: HashSet[SymbolPair]
    isNilIfEmptyParameters*: HashSet[SymbolPair]
    typeReplacements*: Table[SymbolPair, string]
    readOnlyFields*: HashSet[SymbolPair]
    arrayTypes*: HashSet[SymbolPair]
    privateSymbols*: HashSet[SymbolPair]
    ignoredSymbols*: HashSet[SymbolPair]
    openArrayParameters*: HashSet[SymbolPair]
    hiddenRefParameters*: HashSet[SymbolPair]
    discardReturn*: HashSet[string]
    boolReturn*: HashSet[string]
    wrappedFuncs*: HashSet[string]
    functionOverloads*: HashSet[string]
    noSideEffectsFuncs*: HashSet[string]
    mangledSymbols*: HashSet[string]
    incompleteStructs*: HashSet[string]
    distinctAliases*: HashSet[string]
    keepNamespacePrefix*: HashSet[string]
    enumValuePrefixes*: seq[string]
    typePrefixes*: seq[string]
    namespacePrefix*: string
    funcOverloadSuffixes*: seq[string]
    # Builder options
    cHeader*: string
    moduleHeader*: string
    afterEnums*: string
    afterObjects*: string
    afterFuncs*: string
    moduleEnd*: string

proc parseSymbolPair(s: string): SymbolPair =
  let i = s.find('/')
  if i >= 0:
    result.module = s[0..i-1]
    result.symbol = s[i+1..s.high]
  else:
    result.module = s
    result.symbol = ""

proc processKeyWithoutValue(config: var ConfigData; section: string, key: string) =
  let sp = parseSymbolPair(key)
  case section
  of "OutParameters":
    config.outParameters.incl(sp)
  of "NilIfEmptyParameters":
    config.isNilIfEmptyParameters.incl(sp)
  of "ReadOnlyFields":
    config.readOnlyFields.incl(sp)
  of "ArrayTypes":
    config.arrayTypes.incl(sp)
  of "PrivateSymbols":
    config.privateSymbols.incl(sp)
  of "IgnoredSymbols":
    config.ignoredSymbols.incl(sp)
  of "OpenArrayParameters":
    config.openArrayParameters.incl(sp)
  of "HiddenRefParameters":
    config.hiddenRefParameters.incl(sp)
  of "DiscardReturn":
    config.discardReturn.incl(key)
  of "BoolReturn":
    config.boolReturn.incl(key)
  of "WrappedFuncs":
    config.wrappedFuncs.incl(key)
  of "FunctionOverloads":
    config.functionOverloads.incl(key)
  of "NoSideEffectsFuncs":
    config.noSideEffectsFuncs.incl(key)
  of "MangledSymbols":
    config.mangledSymbols.incl(key)
  of "IncompleteStructs":
    config.incompleteStructs.incl(key)
  of "DistinctAliases":
    config.distinctAliases.incl(key)
  of "KeepNamespacePrefix":
    config.keepNamespacePrefix.incl(key)
  of "EnumValuePrefixes":
    config.enumValuePrefixes.add(key)
  of "TypePrefixes":
    config.typePrefixes.add(key)
  of "FuncOverloadSuffixes":
    config.funcOverloadSuffixes.add(key)
  else:
    echo "Warning: Unknown option in section '", section, "': ", key

proc readFileOrUseString(value: string): string =
  if value.endsWith(".nim") and isValidFilename(value):
    result = readFile(value)
  else:
    result = value

proc processKeyValuePair(config: var ConfigData; section: string, key: string, value: string) =
  let sp = parseSymbolPair(key)
  case section
  of "TypeReplacements":
    config.typeReplacements[sp] = value
  of "General":
    case key.normalize
    of "apidefinition":
      config.apiDefinition = value
    of "cheader":
      config.cHeader = value
    of "namespaceprefix":
      config.namespacePrefix = value
    else:
      echo "Warning: Unknown key in General section: ", key
  of "Snippets":
    case key.normalize
    of "moduleheader":
      config.moduleHeader = readFileOrUseString(value)
    of "afterenums":
      config.afterEnums = readFileOrUseString(value)
    of "afterobjects":
      config.afterObjects = readFileOrUseString(value)
    of "afterfuncs":
      config.afterFuncs = readFileOrUseString(value)
    of "moduleend":
      config.moduleEnd = readFileOrUseString(value)
    else:
      echo "Warning: Unknown key in Snippets section: ", key
  else:
    echo "Warning: Unknown key-value pair in section '", section, "': ", key, ":", value

proc parseConfig*(filename: string): ConfigData =
  let f = newFileStream(filename, fmRead)
  if f == nil:
    raise newException(IOError, "Cannot open " & filename)

  var p: CfgParser
  open(p, f, filename)

  result = ConfigData()
  var currentSection = ""
  while true:
    let e = next(p)
    case e.kind
    of cfgEof: break
    of cfgSectionStart:
      currentSection = e.section
    of cfgKeyValuePair:
      if e.value != "":
        processKeyValuePair(result, currentSection, e.key, e.value)
      else:
        processKeyWithoutValue(result, currentSection, e.key)
    of cfgOption: discard
    of cfgError:
      echo "Error in configuration file: ", e.msg
  close(p)
