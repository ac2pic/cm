import json
import tables
import ./utils/types
import ./utils/normalize
from ./manifest3 import Manifest3, Manifest3Wrapper, norm, sync

type LegacyModDependencies = OrderedTable[ModID, SemVerConstraint]

type Manifest2* = object
  name*: ModId
  version: SemVer
  ccmodHumanName: string
  description: string
  license: SPDXExpression
  homepage: string
  icons: ModIcons
  ccmodDependencies: LegacyModDependencies
  assets: seq[FilePath]
  plugin: FilePath
  preload: FilePath
  postload: FilePath
  prestart: FilePath
  main: FilePath

proc `%`*(man: Manifest2) : JsonNode = 
  result = %* {
    "name": man.name,
    "version": man.version,
    "ccmodHumanName": man.ccmodHumanName,
    "description": man.description,
    "license": man.license,
    "homepage": man.homepage,
    "icons": man.icons,
    "ccmodDependencies": man.ccmodDependencies,
    "assets": man.assets,
    "plugin": man.plugin,
    "preload": man.preload,
    "postload": man.postload,
    "prestart": man.prestart,
    "main": man.main
  }

type Manifest2Wrapper* = object
  data*: JsonNode
  manifest*: Manifest2

proc toManifest3*(oldMan: Manifest2Wrapper): Manifest3 =
  var newJson: JsonNode = parseJson("{}")
  var oldJson: JsonNode = %oldMan.manifest

  const keyMappings: seq[tuple[oldKey: string, newKey: string]] = @[
    (oldKey: "name", newKey: "id"),
    (oldKey: "version", newKey: "version"),
    (oldKey: "license", newKey: "license"),

    (oldKey: "ccmodHumanName", newKey: "title"),
    (oldKey: "description", newKey: "description"),
    (oldKey: "homepage", newKey: "homepage"),
    (oldKey: "icons", newKey: "icons"),

    (oldKey: "ccmodDependencies", newKey: "dependencies"),

    (oldKey: "assets", newKey: "assets"),

    (oldKey: "plugin", newKey: "plugin"),
    (oldKey: "preload", newKey: "preload"),
    (oldKey: "postload", newKey: "postload"),
    (oldKey: "prestart", newKey: "prestart"),
    (oldKey: "main", newKey: "poststart")
  ]
  for (oldKey, newKey) in keyMappings:
    newJson[newKey] = oldJson[oldKey]
  var wrapper3: Manifest3Wrapper = Manifest3Wrapper(data: newJson)
  wrapper3.norm
  wrapper3.manifest


proc norm*(wrapper: var Manifest2Wrapper): void =
  normString(wrapper.data, "name", "my-mod")
  normString(wrapper.data, "version", "0.0.0")
  normString(wrapper.data, "ccmodHumanName", wrapper.data["name"].str)
  normString(wrapper.data, "description")
  normString(wrapper.data, "license")
  normString(wrapper.data, "homepage")
  normModIcons(wrapper.data, "icons")
  if not wrapper.data.hasKey("ccmodDependencies"):
    if wrapper.data.hasKey("dependencies"):
      wrapper.data["ccmodDependencies"] = copy(wrapper.data["dependencies"])
    else:
      wrapper.data["ccmodDependencies"] = newJObject()
  normLegacyDependencies(wrapper.data, "ccmodDependencies")
  normAssets(wrapper.data, "assets")
  normString(wrapper.data, "plugin", "")
  normString(wrapper.data, "preload", "")
  normString(wrapper.data, "postload", "")
  normString(wrapper.data, "prestart", "")
  normString(wrapper.data, "main", "")
  wrapper.manifest = to(wrapper.data, Manifest2)

proc sync*(wrapper: Manifest2Wrapper): void =
  for key, value in %wrapper.manifest:
    wrapper.data[key] = copy(value)


