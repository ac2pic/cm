import json
import tables
import ./utils/types
import ./utils/normalize

type Manifest3* = object
  id*: ModID 
  version*: Semver

  title*: LocalizedString
  description*: LocalizedString
  license*: SPDXExpression
  homepage*: LocalizedString
  keywords*: seq[LocalizedString]
  author*: seq[Person]
  icons*: ModIcons
  
  dependencies*: ModDependencies
  
  assets*: seq[FilePath]
  assetsDir*: FilePath

  plugin*: FilePath
  preload*: FilePath
  postload*: FilePath
  prestart*: FilePath
  poststart*: FilePath

type Manifest3Wrapper* = object
  data*: JsonNode
  manifest*: Manifest3

 
proc `%`*(man: Manifest3) : JsonNode = 
  result =  %* {
    "id": man.id,
    "version": man.version,
    "title": man.title,
    "description": man.description,
    "license": man.license,
    "homepage": man.homepage,
    "keywords": man.keywords,
    "author": man.author,
    "icons": man.icons,
    "dependencies": man.dependencies,
    "assets": man.assets,
    "assetsDir": man.assetsDir,
    "plugin": man.plugin,
    "preload": man.preload,
    "postload": man.postload,
    "prestart": man.prestart,
    "poststart": man.poststart
  }


proc norm*(wrapper: var Manifest3Wrapper): void =
  normString(wrapper.data, "id", "my-mod")
  normString(wrapper.data, "version", "0.0.0")
  normLocalizableString(wrapper.data, "title", wrapper.data["id"].str)
  normLocalizableString(wrapper.data, "description")
  normString(wrapper.data, "license")
  normLocalizableString(wrapper.data, "homepage")
  normKeywords(wrapper.data, "keywords")
  normAuthor(wrapper.data, "author")
  normModIcons(wrapper.data, "icons")
  normDependencies(wrapper.data, "dependencies")
  normAssets(wrapper.data, "assets")
  normString(wrapper.data, "assetsDir")

  normString(wrapper.data, "plugin")
  normString(wrapper.data, "preload")
  normString(wrapper.data, "postload")
  normString(wrapper.data, "prestart")
  normString(wrapper.data, "poststart")
  wrapper.manifest = to(wrapper.data, Manifest3)

proc sync*(wrapper: Manifest3Wrapper): void =
  for key, value in %wrapper.manifest:
    wrapper.data[key] = copy(value)
