#!/usr/bin/env python3
"""Builds every platform's app icon from the layers in layers/ (run
generate_icon.py first). Needs rsvg-convert and ImageMagick (magick).

Outputs:
  ios/Runner/AppIcon.icon, macos/Runner/AppIcon.icon   Liquid Glass (Icon Composer format)
  android mipmaps: adaptive foreground/monochrome + legacy PNGs
  windows/runner/resources/app_icon.ico, assets/icon/msix_logo.png
  ios/Runner/Assets.xcassets/LaunchImage.imageset  the launch screen's centred mark (120 pt)

Run from the repository root: python3 docs/design/icon/build_platform_icons.py
"""
import json
import os
import re
import shutil
import subprocess
import tempfile

ROOT = os.getcwd()
ICON = os.path.join(ROOT, "docs/design/icon")
LAYERS = os.path.join(ICON, "layers")
APP = os.path.join(ROOT, "app")
BACKGROUND = (0x1F, 0x6F, 0x68)  # seafoam700


def svg_body(name):
    s = open(os.path.join(LAYERS, name)).read()
    return re.search(r"<svg[^>]*>(.*)</svg>", s, re.S).group(1)


def write_svg(path, body, size=1024):
    with open(path, "w") as f:
        f.write(f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {size} {size}">{body}</svg>\n')


def render(svg, png, px):
    subprocess.run(["rsvg-convert", "-w", str(px), "-h", str(px), "-o", png, svg], check=True)


def icon_bundle(dest):
    """Icon Composer `.icon` bundle: groups are listed front to back."""
    if os.path.exists(dest):
        shutil.rmtree(dest)
    os.makedirs(os.path.join(dest, "Assets"))
    for name in ("1-tide.svg", "2-signal.svg"):
        shutil.copy(os.path.join(LAYERS, name), os.path.join(dest, "Assets", name))
    r, g, b = (c / 255 for c in BACKGROUND)
    spec = {
        "fill": {"automatic-gradient": f"extended-srgb:{r:.5f},{g:.5f},{b:.5f},1.00000"},
        "groups": [
            {
                "layers": [{"image-name": "2-signal.svg", "name": "Signal"}],
                "name": "Signal",
                "shadow": {"kind": "neutral", "opacity": 0.5},
                "translucency": {"enabled": True, "value": 0.4},
            },
            {
                "layers": [{"image-name": "1-tide.svg", "name": "Tide"}],
                "name": "Tide",
                "shadow": {"kind": "neutral", "opacity": 0.5},
                "translucency": {"enabled": True, "value": 0.4},
            },
        ],
        "supported-platforms": {"circles": ["watchOS"], "squares": "shared"},
    }
    with open(os.path.join(dest, "icon.json"), "w") as f:
        json.dump(spec, f, indent=2)
        f.write("\n")


def android(tmp):
    res = os.path.join(APP, "android/app/src/main/res")
    fg = svg_body("1-tide.svg") + svg_body("2-signal.svg")
    # Adaptive icons: 108 dp canvas, content must fit the central 66 dp.
    scaled = f'<g transform="translate(512 512) scale(0.66) translate(-512 -512)">{fg}</g>'
    write_svg(os.path.join(tmp, "fg.svg"), scaled)
    mono = re.sub(r'(stroke|fill)="#[0-9A-Fa-f]{6}"', r'\1="#FFFFFF"', scaled)
    write_svg(os.path.join(tmp, "mono.svg"), mono)
    flat = svg_body("flattened-default.svg")
    write_svg(
        os.path.join(tmp, "legacy.svg"),
        f'<clipPath id="r"><rect width="1024" height="1024" rx="230"/></clipPath><g clip-path="url(#r)">{flat}</g>',
    )
    for density, scale in {"mdpi": 1, "hdpi": 1.5, "xhdpi": 2, "xxhdpi": 3, "xxxhdpi": 4}.items():
        d = os.path.join(res, f"mipmap-{density}")
        os.makedirs(d, exist_ok=True)
        render(os.path.join(tmp, "fg.svg"), os.path.join(d, "ic_launcher_foreground.png"), int(108 * scale))
        render(os.path.join(tmp, "mono.svg"), os.path.join(d, "ic_launcher_monochrome.png"), int(108 * scale))
        render(os.path.join(tmp, "legacy.svg"), os.path.join(d, "ic_launcher.png"), int(48 * scale))
    anydpi = os.path.join(res, "mipmap-anydpi-v26")
    os.makedirs(anydpi, exist_ok=True)
    with open(os.path.join(anydpi, "ic_launcher.xml"), "w") as f:
        f.write(
            '<?xml version="1.0" encoding="utf-8"?>\n'
            '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
            '    <background android:drawable="@color/ic_launcher_background"/>\n'
            '    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>\n'
            '    <monochrome android:drawable="@mipmap/ic_launcher_monochrome"/>\n'
            "</adaptive-icon>\n"
        )
    values = os.path.join(res, "values")
    os.makedirs(values, exist_ok=True)
    with open(os.path.join(values, "ic_launcher_background.xml"), "w") as f:
        f.write(
            '<?xml version="1.0" encoding="utf-8"?>\n<resources>\n'
            f'    <color name="ic_launcher_background">#{BACKGROUND[0]:02X}{BACKGROUND[1]:02X}{BACKGROUND[2]:02X}</color>\n'
            "</resources>\n"
        )
    return os.path.join(tmp, "legacy.svg")


def windows(tmp, legacy_svg):
    pngs = []
    for px in (16, 24, 32, 48, 64, 256):
        p = os.path.join(tmp, f"w{px}.png")
        render(legacy_svg, p, px)
        pngs.append(p)
    subprocess.run(["magick", *pngs, os.path.join(APP, "windows/runner/resources/app_icon.ico")], check=True)
    os.makedirs(os.path.join(APP, "assets/icon"), exist_ok=True)
    render(legacy_svg, os.path.join(APP, "assets/icon/msix_logo.png"), 512)


def ios_launch_image(tmp):
    """The mark shown centred on the launch screen: the icon with rounded
    corners, 120 pt. Flutter's IPA validation rejects the 1x1 placeholder of
    the project template as a "default launch image"."""
    body = svg_body("flattened-default.svg")
    svg = os.path.join(tmp, "launch.svg")
    with open(svg, "w") as f:
        f.write(
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024">'
            '<clipPath id="r"><rect width="1024" height="1024" rx="230"/></clipPath>'
            f'<g clip-path="url(#r)">{body}</g></svg>\n'
        )
    dest = os.path.join(APP, "ios/Runner/Assets.xcassets/LaunchImage.imageset")
    for name, px in (("LaunchImage.png", 120), ("LaunchImage@2x.png", 240), ("LaunchImage@3x.png", 360)):
        render(svg, os.path.join(dest, name), px)


def main():
    icon_bundle(os.path.join(APP, "ios/Runner/AppIcon.icon"))
    icon_bundle(os.path.join(APP, "macos/Runner/AppIcon.icon"))
    with tempfile.TemporaryDirectory() as tmp:
        legacy = android(tmp)
        windows(tmp, legacy)
        ios_launch_image(tmp)
    print("platform icons written")


if __name__ == "__main__":
    main()
