#!/usr/bin/env python3
"""Generates the Google Play feature graphic (1024x500, opaque PNG), EN and DE.

Reuses the app icon's vector shapes (generate_icon.py) on the "Low Tide"
seafoam700 background, with the name and tagline in sand50.

Run: python3 docs/design/icon/generate_feature_graphic.py   (needs rsvg-convert and ImageMagick)
"""
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from generate_icon import LAYERS, colourise, wave  # noqa: E402

OUT = os.path.normpath(os.path.join(HERE, "..", "..", "release", "feature-graphic"))
W, H = 1024, 500
BG, TIDE, SAND, SEAFOAM = "#1F6F68", "#9FD3C7", "#FFFCF6", "#CFEAE3"
FONT = "SF Pro Display, Helvetica Neue, Helvetica, Arial, sans-serif"

TAGLINES = {
    "en": ("Log first.", "Sync later."),
    "de": ("Erst loggen.", "Später syncen."),
}
SUB = {
    "en": "The offline logger for Wavelog",
    "de": "Der Offline-Logger für Wavelog",
}

def svg(lang):
    s = 0.54
    mark = (colourise(LAYERS["1-tide"], TIDE) + colourise(LAYERS["2-signal"], SAND))
    # Soft background wave band across the bottom, parallel to the icon waves.
    band = wave(-40, W + 40, 452, 16, 400, phase=0.6)
    l1, l2 = TAGLINES[lang]
    return f"""<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}">
<rect width="{W}" height="{H}" fill="{BG}"/>
<path d="{band} L{W + 40} {H} L-40 {H} Z" fill="#185C56"/>
<g transform="translate({270 - 512 * s:.1f} {232 - 548 * s:.1f}) scale({s})">{mark}</g>
<g font-family="{FONT}" fill="{SAND}">
<text x="548" y="206" font-size="84" font-weight="700" letter-spacing="-1">Tideline</text>
<text x="550" y="250" font-size="27" fill="{SEAFOAM}">{SUB[lang]}</text>
<text x="550" y="332" font-size="46" font-weight="600">{l1}</text>
<text x="550" y="390" font-size="46" font-weight="600" fill="{TIDE}">{l2}</text>
</g>
</svg>
"""

def main():
    os.makedirs(OUT, exist_ok=True)
    for lang in TAGLINES:
        path = os.path.join(OUT, f"feature-graphic-{lang}")
        with open(path + ".svg", "w", encoding="utf-8") as f:
            f.write(svg(lang))
        subprocess.run(["rsvg-convert", "-w", str(W), "-h", str(H), "-o", path + ".png", path + ".svg"], check=True)
        # Play rejects transparency: flatten onto the background colour.
        subprocess.run(["magick", path + ".png", "-background", BG, "-alpha", "remove", "-alpha", "off", path + ".png"], check=True)

if __name__ == "__main__":
    main()
