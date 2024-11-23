import std/[algorithm, sets, tables, sequtils, strutils, enumerate]
from std/sugar import `=>`
import schema, ctypes, utils, config

proc isMangled(name: string, config: ConfigData): bool =
  name in config.mangledSymbols

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

proc isNilIfEmptyParameter(x, y: string, config: ConfigData): bool =
  (x, y) in config.isNilIfEmptyParameters

proc getReplacement(x, y: string, config: ConfigData): string =
  result = getOrDefault(config.typeReplacements, (x, y))

proc getReplacement(x: string, config: ConfigData): string =
  result = getOrDefault(config.typeReplacements, (x, ""))

proc filterIgnoredSymbols(ctx: var ApiContext; config: ConfigData) =
  keepIf(ctx.api.defines, x => isNotIgnored(x.name, config))
  keepIf(ctx.api.structs, x => isNotIgnored(x.name, config))
  keepIf(ctx.api.callbacks, x => isNotIgnored(x.name, config))
  keepIf(ctx.api.aliases, x => isNotIgnored(x.name, config))
  keepIf(ctx.api.enums, x => isNotIgnored(x.name, config))
  keepIf(ctx.api.functions, x => isNotIgnored(x.name, config))

proc shouldRemoveNamespacePrefix(name: string, config: ConfigData): bool =
  config.namespacePrefix != "" and name.startsWith(config.namespacePrefix) and
    name notin config.keepNamespacePrefix

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
    typeVar = convertType(typeVar, config.namespacePrefix, pointerType)

proc updateType(typeVar: var string; name: string; pointerType: PointerType; config: ConfigData) =
  updateType(typeVar, name, "", pointerType, config)

proc checkCstringType(fnc: FunctionInfo, kind: string, config: ConfigData): bool =
  kind == "cstring" and fnc.name notin config.wrappedFuncs and hasVarargs notin fnc.flags

proc isOpenArrayParameter(x, y: string, config: ConfigData): bool =
  (x, y) in config.openArrayParameters

proc isVarargsParam(param: ParamInfo): bool =
  param.name == "args" and param.`type` == "..."

proc sortEnumValues(enm: var EnumInfo, config: ConfigData) =
  sort(enm.values, proc (x, y: ValueInfo): int = cmp(x.value, y.value))

proc processEnumName(enm: var EnumInfo, config: ConfigData) =
  if shouldRemoveNamespacePrefix(enm.name, config):
    removePrefix(enm.name, config.namespacePrefix)

proc processEnumValues(enm: var EnumInfo, config: ConfigData) =
  proc removePrefixes(name: string, config: ConfigData): string =
    result = name
    for prefix in config.enumValuePrefixes:
      if result.startsWith(prefix) and not isDigit(result[prefix.len]):
        result.removePrefix(prefix)
        break

  for val in mitems(enm.values):
    val.name = removePrefixes(val.name, config).camelCaseAscii()

proc processEnums(ctx: var ApiContext, config: ConfigData) =
  # Execute the processing stages in order
  for enm in mitems(ctx.api.enums):
    sortEnumValues(enm, config)
    processEnumName(enm, config)
    processEnumValues(enm, config)

proc processAliasFlags(alias: var AliasInfo, config: ConfigData) =
  if shouldMarkAsDistinct(alias.name, config):
    alias.flags.incl isDistinct

proc processAliases(ctx: var ApiContext, config: ConfigData) =
  # Execute the processing stages in order
  for alias in mitems(ctx.api.aliases):
    processAliasFlags(alias, config)

proc processStructFlags(obj: var StructInfo, config: ConfigData) =
  if shouldMarkAsComplete(obj.name, config):
    obj.flags.incl isCompleteStruct
  if shouldMarkAsPrivate(obj.name, config):
    obj.flags.incl isPrivate

proc processStructFields(obj: var StructInfo, config: ConfigData) =
  for fld in mitems(obj.fields):
    if shouldMarkAsPrivate(obj.name, fld.name, config) or isPrivate in obj.flags:
      fld.flags.incl isPrivate
    if isArray(obj.name, fld.name, config):
      fld.flags.incl isPtArray

proc processStructNames(obj: var StructInfo, config: ConfigData) =
  if shouldRemoveNamespacePrefix(obj.name, config):
    obj.importName = obj.name
    removePrefix(obj.name, config.namespacePrefix)
  if isMangled(obj.name, config):
    obj.importName = "rl" & obj.name

template effectiveName(obj: StructInfo): untyped =
  if obj.importName != "": obj.importName
  else: obj.name

proc updateFieldTypes(obj: var StructInfo, config: ConfigData) =
  for fld in mitems(obj.fields):
    let pointerType = if isPtArray in fld.flags: ptArray else: ptPtr
    updateType(fld.`type`, effectiveName(obj), fld.name, pointerType, config)

proc finalizeProcessing(obj: var StructInfo, ctx: var ApiContext, config: ConfigData) =
  for fld in mitems(obj.fields):
    # Handle read-only fields
    if isReadOnlyField(effectiveName(obj), fld.name, config):
      ctx.readOnlyFieldAccessors.add ParamInfo(
        name: fld.name, `type`: obj.name, dirty: fld.`type`
      )
      fld.flags.incl isPrivate
    # Handle array accessors
    if {isPtArray, isPrivate} * fld.flags == {isPtArray}:
      let tmp = capitalizeAscii(fld.name)
      ctx.boundCheckedArrayAccessors.add AliasInfo(
        `type`: obj.name, name: obj.name & tmp
      )
    # Mark array fields as private
    if isPtArray in fld.flags:
      fld.flags.incl isPrivate

proc processStructs(ctx: var ApiContext, config: ConfigData) =
  # Execute the processing stages in order
  for obj in mitems(ctx.api.structs):
    processStructFlags(obj, config)
    processStructFields(obj, config)
    processStructNames(obj, config)
    updateFieldTypes(obj, config)
    finalizeProcessing(obj, ctx, config)

proc processFunctionFlags(fnc: var FunctionInfo, config: ConfigData) =
  if fnc.name in config.wrappedFuncs:
    fnc.flags.incl isWrappedFunc
    fnc.flags.incl isPrivate
  if shouldMarkAsPrivate(fnc.name, config):
    fnc.flags.incl isPrivate
  if fnc.name in config.noSideEffectsFuncs:
    fnc.flags.incl isFunc
  if isWrappedFunc notin fnc.flags:
    if fnc.name in config.discardReturn:
      fnc.flags.incl isDiscardable
      fnc.flags.incl isAutoWrappedFunc
    if fnc.name in config.boolReturn:
      fnc.flags.incl isBoolReturn
      fnc.flags.incl isAutoWrappedFunc

proc processVarargs(fnc: var FunctionInfo, config: ConfigData) =
  if fnc.params.len > 0 and isVarargsParam(fnc.params[^1]):
    fnc.flags.incl hasVarargs
    fnc.params.setLen(fnc.params.high)

proc processParameters(fnc: var FunctionInfo, config: ConfigData) =
  for i, param in enumerate(fnc.params.mitems):
    if isArray(fnc.name, param.name, config):
      param.flags.incl isPtArray
    let pointerType =
      if isPtArray in param.flags: ptArray
      elif isOutParameter(fnc.name, param.name, config): ptOut
      elif isPrivate notin fnc.flags: ptVar
      else: ptPtr
    let paramType = convertType(param.`type`, config.namespacePrefix, pointerType)
    if checkCstringType(fnc, paramType, config):
      param.flags.incl isString
      fnc.flags.incl isAutoWrappedFunc
    if isOpenArrayParameter(fnc.name, param.name, config):
      param.flags.incl isOpenArray
      fnc.params[i+1].flags.incl isArrayLen
      fnc.flags.incl isAutoWrappedFunc
    if {isOpenArray, isString} * param.flags != {} and
        isNilIfEmptyParameter(fnc.name, param.name, config):
      param.flags.incl isNilIfEmpty
    if paramType.startsWith("var "):
      param.flags.incl isVarParam
      param.dirty = paramType

proc processReturnType(fnc: var FunctionInfo, config: ConfigData) =
  if fnc.returnType != "void":
    if isArray(fnc.name, config):
      fnc.flags.incl isPtArray
    let returnType = convertType(fnc.returnType, config.namespacePrefix)
    if checkCstringType(fnc, returnType, config):
      fnc.flags.incl isString
      fnc.flags.incl isAutoWrappedFunc
  if isAutoWrappedFunc in fnc.flags:
    fnc.flags.incl isPrivate

proc updateParameterTypes(fnc: var FunctionInfo, config: ConfigData) =
  for i, param in enumerate(fnc.params.mitems):
    if isOpenArray in param.flags:
      param.dirty = convertType(param.`type`, config.namespacePrefix, ptOpenArray)
      param.flags.incl isOpenArray
      fnc.params[i+1].dirty = param.name # stores array name
    let pointerType =
      if isPtArray in param.flags: ptArray
      elif isOutParameter(fnc.name, param.name, config): ptOut
      elif isPrivate notin fnc.flags: ptVar
      else: ptPtr
    updateType(param.`type`, fnc.name, param.name, pointerType, config)

proc updateReturnType(fnc: var FunctionInfo, config: ConfigData) =
  if fnc.returnType != "void":
    let pointerType =
      if isPtArray in fnc.flags: ptArray
      elif isPrivate notin fnc.flags: ptVar
      else: ptPtr
    updateType(fnc.returnType, fnc.name, pointerType, config)

proc generateNames(fnc: var FunctionInfo, config: ConfigData) =
  proc shouldRemoveSuffix(name: string, config: ConfigData): bool =
    name in config.functionOverloads

  proc generateProcName(name: string, config: ConfigData): string =
    result = name
    if shouldRemoveNamespacePrefix(name, config):
      result.removePrefix(config.namespacePrefix)
    for prefix in config.typePrefixes:
      if result.startsWith(prefix) and not isDigit(result[prefix.len]):
        result.removePrefix(prefix)
        break
    if shouldRemoveSuffix(name, config):
      for suffix in config.funcOverloadSuffixes:
        if result.endsWith(suffix):
          result.removeSuffix(suffix)
          break
    result = uncapitalizeAscii(result)

  fnc.importName = (if isMangled(fnc.name, config): "rl" else: "") & fnc.name
  fnc.name = generateProcName(fnc.name, config)

proc finalizeProcessing(fnc: var FunctionInfo, ctx: var ApiContext, config: ConfigData) =
  if isAutoWrappedFunc in fnc.flags:
    ctx.funcsToWrap.add fnc

proc processFunctions(ctx: var ApiContext, config: ConfigData) =
  # Execute the processing stages in order
  for fnc in mitems(ctx.api.functions):
    processFunctionFlags(fnc, config)
    processVarargs(fnc, config)
    processParameters(fnc, config)
    processReturnType(fnc, config)
    updateParameterTypes(fnc, config)
    updateReturnType(fnc, config)
    generateNames(fnc, config)
    finalizeProcessing(fnc, ctx, config)

proc processApiTypes*(ctx: var ApiContext, config: ConfigData) =
  # Process all type categories
  filterIgnoredSymbols(ctx, config)
  processEnums(ctx, config)
  processAliases(ctx, config)
  processStructs(ctx, config)
  processFunctions(ctx, config)
