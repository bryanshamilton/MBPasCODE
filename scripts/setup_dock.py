#!/usr/bin/env python3
"""Configure the macOS Dock: apps, size, behavior."""
import subprocess
import os
import plistlib
import sys

DOCK_APPS = [
    "/System/Applications/Safari.app",
    "/System/Applications/Messages.app",
    "/System/Applications/Photos.app",
    "/System/Applications/Notes.app",
    "/System/Applications/Music.app",
    "/System/Applications/iPhone Mirroring.app",
    "/Applications/Ghostty.app",
    "/Applications/Obsidian.app",
    "/Applications/Claude.app",
    "/Applications/ChatGPT.app",
    "/Applications/Google Chrome.app",
    "/Applications/Microsoft Outlook.app",
    "/Applications/Microsoft Teams.app",
    "/Applications/Pocket Casts.app",
]

DOCK_SETTINGS = {
    "autohide": True,
    "tilesize": 38,
    "magnification": True,
    "largesize": 52,
    "minimize-to-application": True,
    "show-recents": False,
}


def make_dock_entry(app_path):
    """Create a persistent-apps entry for the Dock plist."""
    app_name = os.path.splitext(os.path.basename(app_path))[0]
    return {
        "GUID": subprocess.check_output(["uuidgen"]).decode().strip(),
        "tile-data": {
            "file-data": {
                "_CFURLString": app_path,
                "_CFURLStringType": 0,
            },
            "file-label": app_name,
            "file-type": 41,
        },
        "tile-type": "file-tile",
    }


def defaults_write(key, value):
    """Write a value to com.apple.dock."""
    if isinstance(value, bool):
        subprocess.run(
            ["defaults", "write", "com.apple.dock", key, "-bool", str(value).lower()],
            check=True,
        )
    elif isinstance(value, int):
        subprocess.run(
            ["defaults", "write", "com.apple.dock", key, "-int", str(value)],
            check=True,
        )


def setup_dock():
    print("🚢 Configuring Dock...")

    # Apply appearance settings
    for key, value in DOCK_SETTINGS.items():
        defaults_write(key, value)
    print("  ✅ Dock appearance set (autohide, size=38, magnification=52)")

    # Build the apps list
    dock_plist = os.path.expanduser("~/Library/Preferences/com.apple.dock.plist")
    with open(dock_plist, "rb") as f:
        dock = plistlib.load(f)

    entries = []
    skipped = []
    for app in DOCK_APPS:
        if os.path.exists(app):
            entries.append(make_dock_entry(app))
        else:
            skipped.append(os.path.basename(app))

    dock["persistent-apps"] = entries
    dock["persistent-others"] = []

    with open(dock_plist, "wb") as f:
        plistlib.dump(dock, f, fmt=plistlib.FMT_BINARY)

    if skipped:
        print(f"  ⚠️  Skipped (not installed): {', '.join(skipped)}")

    # Restart Dock
    subprocess.run(["defaults", "read", "com.apple.dock"], capture_output=True)
    os.system("kill $(pgrep -x Dock)")
    print("  ✅ Dock restarted with configured apps")


if __name__ == "__main__":
    setup_dock()
