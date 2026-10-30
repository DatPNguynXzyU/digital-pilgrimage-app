import importlib.util
from pathlib import Path
import plistlib
import tempfile
import unittest

spec = importlib.util.spec_from_file_location(
    "prepare_ios", Path(__file__).with_name("prepare-ios-sideload.py"))
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class ConfigurationTest(unittest.TestCase):
    def setUp(self):
        self.env = dict(API_BASE_URL="https://example.com/api",
                        FIREBASE_PROJECT_ID="example-project",
                        FIREBASE_IOS_API_KEY="public-client-key",
                        FIREBASE_IOS_APP_ID="1:123:ios:abc123",
                        FIREBASE_MESSAGING_SENDER_ID="123",
                        GOOGLE_IOS_CLIENT_ID="123-ios.apps.googleusercontent.com",
                        GOOGLE_WEB_CLIENT_ID="123-web.apps.googleusercontent.com")

    def test_generates_matching_config_and_sideload_entitlements(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "ios/Flutter").mkdir(parents=True)
            (root / "ios/Runner").mkdir(parents=True)
            module.prepare(root, self.env)
            self.assertEqual(plistlib.loads((root / "ios/Runner/Runner.entitlements").read_bytes()), {})
            self.assertEqual((root / "ios/Flutter/Firebase.local.xcconfig").read_text(),
                             "GOOGLE_REVERSED_CLIENT_ID = com.googleusercontent.apps.123-ios\n")
            config = module.configuration(self.env)
            self.assertEqual(config["IOS_SIDELOAD_BUILD"], "true")
            self.assertEqual(config["IOS_NFC_ENABLED"], "false")
            self.assertEqual(config["FIREBASE_API_KEY"], "public-client-key")
            self.assertNotIn("FIREBASE_IOS_API_KEY", config)

    def test_missing_variable_does_not_write_files(self):
        del self.env["GOOGLE_IOS_CLIENT_ID"]
        with tempfile.TemporaryDirectory() as directory:
            with self.assertRaisesRegex(ValueError, "GOOGLE_IOS_CLIENT_ID"):
                module.prepare(Path(directory), self.env)
            self.assertEqual(list(Path(directory).iterdir()), [])

    def test_nfc_test_build_retains_tag_entitlement_and_other_entries(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "ios/Flutter").mkdir(parents=True)
            (root / "ios/Runner").mkdir(parents=True)
            path = root / "ios/Runner/Runner.entitlements"
            path.write_bytes(plistlib.dumps({"example-preserved": True}))
            module.prepare(root, {**self.env, "ENABLE_IOS_NFC": "true"})
            self.assertEqual(plistlib.loads(path.read_bytes()), {
                "example-preserved": True,
                "com.apple.developer.nfc.readersession.formats": ["TAG"],
            })
            config = module.configuration({**self.env, "ENABLE_IOS_NFC": "true"})
            self.assertEqual(config["IOS_NFC_ENABLED"], "true")
            module.prepare(root, self.env)
            self.assertEqual(plistlib.loads(path.read_bytes()), {"example-preserved": True})

    def test_invalid_nfc_switch_does_not_write_configuration(self):
        with tempfile.TemporaryDirectory() as directory:
            with self.assertRaisesRegex(ValueError, "ENABLE_IOS_NFC"):
                module.prepare(Path(directory), {**self.env, "ENABLE_IOS_NFC": "maybe"})
            self.assertEqual(list(Path(directory).iterdir()), [])

    def test_xcode_runner_signing_references_tag_entitlements(self):
        root = Path(__file__).resolve().parents[1] / "client/ios"
        project = (root / "Runner.xcodeproj/project.pbxproj").read_text(encoding="utf-8")
        self.assertEqual(project.count("CODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements;"), 3)
        entitlements = plistlib.loads((root / "Runner/Runner.entitlements").read_bytes())
        self.assertEqual(entitlements["com.apple.developer.nfc.readersession.formats"], ["TAG"])
        info = plistlib.loads((root / "Runner/Info.plist").read_bytes())
        self.assertTrue(info["NFCReaderUsageDescription"])

    def test_rejects_wrong_platform_mismatched_project_and_injected_scheme(self):
        for key, value in [("FIREBASE_IOS_APP_ID", "1:123:android:abc"),
                           ("FIREBASE_MESSAGING_SENDER_ID", "456"),
                           ("GOOGLE_IOS_CLIENT_ID", "x\nCODE_SIGN_ENTITLEMENTS = bad"),
                           ("API_BASE_URL", "http://example.com/api"),
                           ("API_BASE_URL", "https://user:password@example.com/api")]:
            with self.subTest(key=key, value=value):
                with self.assertRaises(ValueError):
                    module.configuration({**self.env, key: value})


if __name__ == "__main__":
    unittest.main()
