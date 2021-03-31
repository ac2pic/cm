import json
import ./package/manifest2

var jsonData = parseJson("{}")
var man = Manifest2Wrapper(data: jsonData)
man.norm
echo man.manifest
echo man.toManifest3 
