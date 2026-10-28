"""Validate public Firebase client configuration and prepare the CI-only build.

Never put an Apple password or a Firebase Admin private key in this configuration.
"""
import json
import os
from pathlib import Path
import plistlib
import re
from urllib.parse import urlparse


def configuration(env):
    names = ["API_BASE_URL", "FIREBASE_PROJECT_ID", "FIREBASE_IOS_API_KEY",
             "FIREBASE_IOS_APP_ID", "FIREBASE_MESSAGING_SENDER_ID",
             "GOOGLE_IOS_CLIENT_ID", "GOOGLE_WEB_CLIENT_ID"]
    missing = [name for name in names if not env.get(name, "").strip()]
    if missing:
        raise ValueError("Missing GitHub Actions variables: " + ", ".join(missing))
    config = {name: env[name].strip() for name in names}
    url = urlparse(config["API_BASE_URL"])
    if url.scheme != "https" or not url.hostname or url.username or url.password:
        raise ValueError("API_BASE_URL must be a public HTTPS URL without credentials")
    if not re.fullmatch(r"1:\d+:ios:[a-zA-Z0-9]+", config["FIREBASE_IOS_APP_ID"]):
        raise ValueError("FIREBASE_IOS_APP_ID must be GOOGLE_APP_ID of the iOS app")
    if config["FIREBASE_IOS_APP_ID"].split(":")[1] != config["FIREBASE_MESSAGING_SENDER_ID"]:
        raise ValueError("Firebase app ID and sender ID must belong to the same project")
    for name in ["GOOGLE_IOS_CLIENT_ID", "GOOGLE_WEB_CLIENT_ID"]:
        if not re.fullmatch(r"[a-zA-Z0-9-]+\.apps\.googleusercontent\.com", config[name]):
            raise ValueError(name + " is not a valid OAuth client ID")
    config["FIREBASE_API_KEY"] = config.pop("FIREBASE_IOS_API_KEY")
    config["IOS_SIDELOAD_BUILD"] = "true"
    return config


def prepare(root, env):
    config = configuration(env)
    client = config["GOOGLE_IOS_CLIENT_ID"].removesuffix(".apps.googleusercontent.com")
    (root / "firebase-config.ios.json").write_text(json.dumps(config), encoding="utf-8")
    (root / "ios/Flutter/Firebase.local.xcconfig").write_text(
        f"GOOGLE_REVERSED_CLIENT_ID = com.googleusercontent.apps.{client}\n", encoding="utf-8")
    # Only the ephemeral CI checkout is changed. The regular iOS build retains NFC.
    with (root / "ios/Runner/Runner.entitlements").open("wb") as output:
        plistlib.dump({}, output)
    print("Prepared Firebase iOS client configuration and sideload entitlements.")


if __name__ == "__main__":
    if os.environ.get("GITHUB_ACTIONS") != "true":
        raise SystemExit("Run this script only in a disposable GitHub Actions checkout.")
    try:
        prepare(Path(__file__).resolve().parents[1] / "client", os.environ)
    except ValueError as error:
        raise SystemExit(str(error)) from None
