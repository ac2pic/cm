import unittest
import json
import tables
import ../../src/package/manifest2

suite "LegacyManifest default values":
    setup:
        let wrapper = newManifest2Wrapper("{}")
        let manifest = wrapper.manifest

    test "name is my-mod":
        assert manifest.name == "my-mod"

    test "version is 0.0.0":
        assert manifest.version == "0.0.0"
    
    test "ccmodHumanName is my-mod":
        assert manifest.ccmodHumanName == "my-mod"

    test "description is empty":
        assert manifest.description == ""

    test "license is empty":
        assert manifest.license == ""

    test "icons is empty":
        assert len(manifest.icons) == 0

    test "ccmodDependencies is empty":
        assert len(manifest.ccmodDependencies) == 0

    test "assets is empty":
        assert len(manifest.assets) == 0
    
    test "plugin is empty":
        assert manifest.plugin == ""

    test "preload is empty":
        assert manifest.preload == ""

    test "postload is empty":
        assert manifest.postload == ""

    test "prestart is empty":
        assert manifest.prestart == ""

    test "main is empty":
        assert manifest.main == ""
