import json

proc normString*(node: JsonNode, key: string, default: string = ""): void =
  if not node.hasKey(key):
    node[key] = %*default
  if node[key].kind != JString:
    node[key] = %*default
    
proc normString*(node: JsonNode, key: int, default: string = ""): void =
  if node.kind != JArray or len(node.elems) <= key:
    return

  if node.elems[key].kind != JString:
    node.elems[key] = %*default

proc normBoolean*(node: JsonNode, key: string, default: bool = false): void =
  if not node.hasKey(key) or node[key].kind != JBool:
    node[key] = %*default

# LocalizedString = object
# if string then convert it to {en_US: string}
proc normLocalizableString*(node: JsonNode, key: string, default: string = ""): void =
  if not node.hasKey(key):
    node[key] = %*{"en_US": default}

  if node[key].kind == JString:
    node[key] = %*{"en_US": node[key].str}

  elif node[key].kind != JObject:
    node[key] = %*{"en_US": default}

proc normLocalizableString*(node: JsonNode, key: int, default: string = ""): void =
  if node.kind != JArray or len(node.elems) <= key:
    return
  if node.elems[key].kind != JString:
    node.elems[key] = %*{"en_US": default}
  else:
    node.elems[key] = %*{"en_US": node.elems[key].str}

# Person = object
#  if string then convert it to {name: {en_US: string}}
proc normPerson*(node: JsonNode, key: int): void =
  if node.kind != JArray or len(node.elems) <= key:
    return
  
  if node[key].kind == JString:
    let personName = node[key].str
    node.elems[key] = %*{"name": ""}
    normLocalizableString(node[key], "name", personName)
  elif node[key].kind != JObject:
    node.elems[key] = %*{"name": ""}
    normLocalizableString(node[key], "name")

  normLocalizableString(node[key], "email")
  normLocalizableString(node[key], "url")
  normLocalizableString(node[key], "comment")

proc normAuthor*(node: JsonNode, key: string): void =
  if not node.hasKey(key):
    node[key] = %*[]
  if node[key].kind != JArray:
    node[key] = %*[]

  var index: int = len(node[key].elems)
  while index > 0:
    index.dec
    normPerson(node[key], index)
    if node[key][index].getStr("") == "":
      node[key].elems.delete(index)


proc normModIcons*(node: JsonNode, key: string): void = 
  if not node.hasKey(key):
    node[key] = %*{}
  if node[key].kind != JObject:
    node[key] = %*{}

  for size, filePath in node[key]:
    normString(node[key], size, "")
    if node[key][size].getStr("") == "":
      node[key].delete(size)

proc normLegacyDependencies*(node: JsonNode, key: string): void =
  if not node.hasKey(key):
    node[key] = %*{}
  if node[key].kind != JObject:
    node[key] = %*{}

  for name, filePath in node[key]:
    normString(node[key], name, "")
    if node[key][name].getStr("") == "":
      node[key].delete(name)

# ModDependency = object
#  if string then convert to {version: string, optional: false}
proc normDependency*(node: JsonNode, key: string): void =
  if not node.hasKey(key):
    node[key] = %*{}
  
  if node[key].kind == JString:
    node[key] = %* {"version": node[key].str, "optional": false}
  elif node[key].kind != JObject:
    node[key] = %*{}
  normString(node[key], "version", "")
  normBoolean(node[key], "optional", false)

# ModDependencies = <string, ModDependency>
proc normDependencies*(node: JsonNode, key: string): void =
  if node[key].kind != JObject:
    node[key] = %* {}
  for name, value in node[key]:
    normDependency(node[key], name)

proc normAssets*(node: JsonNode, key: string): void =
  if not node.hasKey(key):
    node[key] = %*[]
  if node[key].kind != JArray:
    node[key] = %*[]

  var index: int = len(node[key].elems)
  while index > 0:
    index.dec
    normString(node[key], index, "")
    if node[key][index].getStr("") == "":
      node[key].elems.delete(index)

# keywords LocalizedString[]
proc normKeywords*(node: JsonNode, key: string): void =
  if not node.hasKey(key) or node[key].kind != JArray:
    node[key] = %*[]

  var index: int = len(node[key].elems)
  while index > 0:
    index.dec
    normLocalizableString(node[key], index, "")
