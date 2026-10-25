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
            self.assertEqual(config["FIREBASE_API_KEY"], "public-client-key")
            self.assertNotIn("FIREBASE_IOS_API_KEY", config)

    def test_missing_variable_does_not_write_files(self):
        del self.env["GOOGLE_IOS_CLIENT_ID"]
        with tempfile.TemporaryDirectory() as directory:
            with self.assertRaisesRegex(ValueError, "GOOGLE_IOS_CLIENT_ID"):
                module.prepare(Path(directory), self.env)
            self.assertEqual(list(Path(directory).iterdir()), [])

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
