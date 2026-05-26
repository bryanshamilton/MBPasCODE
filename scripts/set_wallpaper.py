#!/usr/bin/env python3
"""Set desktop wallpaper with fit-to-screen and black background on macOS 15+."""
import os
import sys
import plistlib

STORE_PATH = os.path.expanduser(
    "~/Library/Application Support/com.apple.wallpaper/Store/Index.plist"
)


def make_config():
    """Create a wallpaper configuration blob: fit-to-screen, black background."""
    color_space = plistlib.dumps("kCGColorSpaceGenericRGB", fmt=plistlib.FMT_BINARY)
    return plistlib.dumps({
        "placement": 1,  # 0=fill, 1=fit, 2=stretch, 3=center
        "backgroundColor": {
            "colorSpace": color_space,
            "components": [0.0, 0.0, 0.0, 1.0],  # RGBA black
        },
    }, fmt=plistlib.FMT_BINARY)


def set_wallpaper(image_path):
    image_url = f"file://{image_path}"
    config = make_config()

    with open(STORE_PATH, "rb") as f:
        store = plistlib.load(f)

    choice = {
        "Configuration": config,
        "Files": [{"relative": image_url}],
        "Provider": "com.apple.wallpaper.choice.image",
    }

    content = {
        "Choices": [choice],
        "Shuffle": "$null",
    }

    # Apply to all spaces and displays
    for section in ["AllSpacesAndDisplays", "SystemDefault"]:
        if section not in store:
            store[section] = {}
        if "Desktop" not in store[section]:
            store[section]["Desktop"] = {}
        if "Content" not in store[section]["Desktop"]:
            store[section]["Desktop"]["Content"] = {}
        store[section]["Desktop"]["Content"]["Choices"] = [choice]

    with open(STORE_PATH, "wb") as f:
        plistlib.dump(store, f, fmt=plistlib.FMT_BINARY)

    print(f"  ✅ Wallpaper set: {os.path.basename(image_path)} (fit, black bg)")
    print("     Note: Log out/in or restart for changes to take effect.")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <image_path>")
        sys.exit(1)

    path = os.path.abspath(sys.argv[1])
    if not os.path.exists(path):
        print(f"Error: {path} not found")
        sys.exit(1)

    set_wallpaper(path)
