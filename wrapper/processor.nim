import std/[algorithm, sets, tables, sequtils, strutils, enumerate]
from std/sugar import `=>`
import schema, ctypes, utils, config

proc isNotIgnored(x: string, config: ConfigData): bool =
  (x, "") notin config.ignoredSymbols

proc isArray(x, y: string, config: ConfigData): bool =
  (x, y) in config.arrayTypes

proc isArray(x: string, config: ConfigData): bool =
  (x, "") in config.arrayTypes

proc isPrivateSymbol(x, y: string, config: ConfigData): bool =
  (x, y) in config.privateSymbols

proc isPrivateSymbol(x: string, config: ConfigData): bool =
  (x, "") in config.privateSymbols

proc isReadOnlyField(x, y: string, config: ConfigData): bool =
  (x, y) in config.readOnlyFields

proc isOutParameter(x, y: string, config: ConfigData): bool =
  (x, y) in config.outParameters

proc getReplacement(x, y: string, config: ConfigData): string =
  result = getOrDefault(config.typeReplacements, (x, y))

proc getReplacement(x: string, config: ConfigData): string =
  result = getOrDefault(config.typeReplacements, (x, ""))

proc filterIgnoredSymbols*(ctx: var ApiContext; config: ConfigData) =
  keepIf(ctx.api.defines, x => isNotIgnored(x.name, config))
  keepIf(ctx.api.structs, x => isNotIgnored(x.name, config))
  keepIf(ctx.api.callbacks, x => isNotIgnored(x.name, config))
  keepIf(ctx.api.aliases, x => isNotIgnored(x.name, config))
  keepIf(ctx.api.enums, x => isNotIgnored(x.name, config))
  keepIf(ctx.api.functions, x => isNotIgnored(x.name, config))

proc shouldRemoveNamespacePrefix(name: string, config: ConfigData): bool =
  config.namespacePrefix != "" and name.startsWith(config.namespacePrefix) and
    name notin config.keepNamespacePrefix

proc shouldMarkAsMangled(name: string, config: ConfigData): bool =
  name in config.mangledSymbols

proc shouldMarkAsDistinct(name: string, config: ConfigData): bool =
  name in config.distinctAliases

proc shouldMarkAsComplete(name: string, config: ConfigData): bool =
  name notin config.incompleteStructs

proc shouldMarkAsPrivate(name: string, config: ConfigData): bool =
  isPrivateSymbol(name, config)

proc shouldMarkAsPrivate(module, name: string, config: ConfigData): bool =
  isPrivateSymbol(module, name, config)

proc updateType(typeVar: var string; module, name: string;
                pointerType: PointerType; config: ConfigData) =
  let replacement = getReplacement(module, name, config)
  if replacement != "":
    typeVar = replacement
  else:
    typeVar = convertType(typeVar, pointerType)

proc updateType(typeVar: var string; name: string; pointerType: PointerType; config: ConfigData) =
  updateType(typeVar, name, "", pointerType, config)

proc processEnums*(ctx: var ApiContext; config: ConfigData) =
  proc removePrefixes(name: string, config: ConfigData): string =
    result = name
    for prefix in config.enumValuePrefixes:
      if result.startsWith(prefix) and
          not isDigit(result[prefix.len]):
        result.removePrefix(prefix)
        break

  for enm in mitems(ctx.api.enums):
    sort(enm.values, proc (x, y: ValueInfo): int = cmp(x.value, y.value))
    if shouldRemoveNamespacePrefix(enm.name, config):
      removePrefix(enm.name, config.namespacePrefix)
    for val in mitems(enm.values):
      val.name = removePrefixes(val.name, config).camelCaseAscii()

proc processAliases*(ctx: var ApiContext; config: ConfigData) =
  for alias in mitems(ctx.api.aliases):
    if shouldMarkAsDistinct(alias.name, config):
      alias.flags.incl isDistinct

proc preprocessStructs(ctx: var ApiContext, config: ConfigData) =
  for obj in mitems(ctx.api.structs):
    if shouldMarkAsMangled(obj.name, config):
      obj.flags.incl isMangled
    if shouldMarkAsComplete(obj.name, config):
      obj.flags.incl isCompleteStruct
    if shouldMarkAsPrivate(obj.name, config):
      obj.flags.incl isPrivate

    for fld in mitems(obj.fields):
      if shouldMarkAsPrivate(obj.name, fld.name, config) or isPrivate in obj.flags:
        fld.flags.incl isPrivate
      if isArray(obj.name, fld.name, config):
        fld.flags.incl isPtArray

proc processStructs*(ctx: var ApiContext; config: ConfigData) =
  preprocessStructs(ctx, config)
  for obj in mitems(ctx.api.structs):
    if isMangled in obj.flags:
      obj.importName = "rl" & obj.name
    if shouldRemoveNamespacePrefix(obj.name, config):
      obj.importName = obj.name
      removePrefix(obj.name, config.namespacePrefix)

    template objName: untyped =
      if obj.importName != "": obj.importName else: obj.name

    for fld in mitems(obj.fields):
      updateType(fld.`type`, objName, fld.name,
                 if isPtArray in fld.flags: ptArray else: ptPtr, config)
      if isReadOnlyField(objName, fld.name, config):
        ctx.readOnlyFieldAccessors.add ParamInfo(
          name: fld.name, `type`: obj.name, dirty: fld.`type`)
        fld.flags.incl isPrivate
      if {isPtArray, isPrivate} * fld.flags == {isPtArray}:
        let tmp = capitalizeAscii(fld.name)
        ctx.boundCheckedArrayAccessors.add AliasInfo(
          `type`: obj.name, name: obj.name & tmp)
      if isPtArray in fld.flags:
        fld.flags.incl isPrivate

proc checkCstringType(fnc: FunctionInfo, kind: string, config: ConfigData): bool =
  kind == "cstring" and fnc.name notin config.wrappedFuncs and hasVarargs notin fnc.flags

proc isOpenArrayParameter(x, y: string, config: ConfigData): bool =
  (x, y) in config.openArrayParameters

proc isVarargsParam(param: ParamInfo): bool =
  param.name == "args" and param.`type` == "..."

proc preprocessFunctions(ctx: var ApiContext, config: ConfigData) =
  for fnc in mitems(ctx.api.functions):
    if shouldMarkAsMangled(fnc.name, config):
      fnc.flags.incl isMangled
    if fnc.name in config.wrappedFuncs:
      fnc.flags.incl isWrappedFunc
      fnc.flags.incl isPrivate
    if shouldMarkAsPrivate(fnc.name, config):
      fnc.flags.incl isPrivate
    if fnc.name in config.noSideEffectsFuncs:
      fnc.flags.incl isFunc

    if fnc.params.len > 0 and isVarargsParam(fnc.params[^1]):
      fnc.flags.incl hasVarargs
      fnc.params.setLen(fnc.params.high)

    for i, param in enumerate(fnc.params.mitems):
      if isArray(fnc.name, param.name, config):
        param.flags.incl isPtArray
      let pointerType =
        if isPtArray in param.flags: ptArray
        elif isOutParameter(fnc.name, param.name, config): ptOut
        elif isPrivate notin fnc.flags: ptVar
        else: ptPtr
      let paramType = convertType(param.`type`, pointerType)
      if checkCstringType(fnc, paramType, config):
        param.flags.incl isString
        fnc.flags.incl isAutoWrappedFunc
      if isOpenArrayParameter(fnc.name, param.name, config):
        param.flags.incl isOpenArray
        fnc.params[i+1].flags.incl isArrayLen
        fnc.flags.incl isAutoWrappedFunc
      if paramType.startsWith("var "):
        param.flags.incl isVarParam
        param.dirty = paramType
    if fnc.returnType != "void":
      if isArray(fnc.name, config):
        fnc.flags.incl isPtArray
      let returnType = convertType(fnc.returnType)
      if checkCstringType(fnc, returnType, config):
        fnc.flags.incl isString
        fnc.flags.incl isAutoWrappedFunc
    if isAutoWrappedFunc in fnc.flags:
      fnc.flags.incl isPrivate

proc processFunctions*(ctx: var ApiContext; config: ConfigData) =
  proc shouldRemoveSuffix(name: string, config: ConfigData): bool =
    name in config.functionOverloads

  proc generateProcName(name: string, config: ConfigData): string =
    result = name
    if shouldRemoveNamespacePrefix(name, config):
      result.removePrefix(config.namespacePrefix)
    if shouldRemoveSuffix(name, config):
      for suffix in config.funcOverloadSuffixes:
        if result.endsWith(suffix):
          result.removeSuffix(suffix)
          break
    result = uncapitalizeAscii(result)

  preprocessFunctions(ctx, config)
  for fnc in mitems(ctx.api.functions):
    for i, param in enumerate(fnc.params.mitems):
      if isOpenArray in param.flags:
        param.dirty = convertType(param.`type`, ptOpenArray)
        param.flags.incl isOpenArray
        fnc.params[i+1].dirty = param.name # stores array name
      let pointerType =
        if isPtArray in param.flags: ptArray
        elif isOutParameter(fnc.name, param.name, config): ptOut
        elif isPrivate notin fnc.flags: ptVar
        else: ptPtr
      updateType(param.`type`, fnc.name, param.name, pointerType, config)
    if fnc.returnType != "void":
      let pointerType =
        if isPtArray in fnc.flags: ptArray
        elif isPrivate notin fnc.flags: ptVar
        else: ptPtr
      updateType(fnc.returnType, fnc.name, pointerType, config)

    fnc.importName = (if isMangled in fnc.flags: "rl" else: "") & fnc.name
    fnc.name = generateProcName(fnc.name, config)
    if isAutoWrappedFunc in fnc.flags:
      ctx.funcsToWrap.add fnc
