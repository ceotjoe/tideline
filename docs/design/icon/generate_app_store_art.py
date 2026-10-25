#!/usr/bin/env python3
"""Generates the App Store product page header and search results artwork, EN and DE.

Header: 3840x1646 (21:9). Search results: 3840x2560 (3:2). Both are opaque PNGs
without alpha, as App Store Connect requires. They reuse the icon's vector shapes
(generate_icon.py) and the palette of the Google Play feature graphic. The search
image embeds the real "Log" screenshot from docs/release/screenshots/iphone-6.9.

Run: python3 docs/design/icon/generate_app_store_art.py   (needs rsvg-convert and ImageMagick)
"""
import os
import shutil
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from generate_icon import LAYERS, colourise, wave  # noqa: E402

RELEASE = os.path.normpath(os.path.join(HERE, "..", "..", "release"))
OUT = os.path.join(RELEASE, "app-store-art")
SHOTS = os.path.join(RELEASE, "screenshots", "iphone-6.9")
BG, BAND, TIDE, SAND, SEAFOAM = "#1F6F68", "#185C56", "#9FD3C7", "#FFFCF6", "#CFEAE3"
FONT = "SF Pro Display, Helvetica Neue, Helvetica, Arial, sans-serif"

TAGLINES = {
    "en": ("Log first.", "Sync later."),
    "de": ("Erst loggen.", "Später syncen."),
}
SUB = {
    "en": "The offline logger for Wavelog",
    "de": "Der Offline-Logger für Wavelog",
}
SEARCH_HEAD = {
    "en": ("Log QSOs", "offline."),
    "de": ("QSOs offline", "loggen."),
}
SEARCH_SUB = {
    "en": "Sync to your Wavelog later.",
    "de": "Später mit Deinem Wavelog synchronisieren.",
}

def mark():
    return colourise(LAYERS["1-tide"], TIDE) + colourise(LAYERS["2-signal"], SAND)

def header_svg(lang):
    w, h, k = 3840, 1646, 2.8
    # The feature graphic's lockup (mark left, text right), scaled and centred,
    # so key content stays in the middle where crops cannot clip it.
    dx, dy = 1920 - 470 * k, 823 - 235 * k
    s = 0.54
    l1, l2 = TAGLINES[lang]
    band = wave(-100, w + 100, 1560, 40, 1100, phase=0.6)
    return f"""<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}">
<rect width="{w}" height="{h}" fill="{BG}"/>
<path d="{band} L{w + 100} {h} L-100 {h} Z" fill="{BAND}"/>
<g transform="translate({dx:.1f} {dy:.1f}) scale({k})">
<g transform="translate({270 - 512 * s:.1f} {232 - 548 * s:.1f}) scale({s})">{mark()}</g>
<g font-family="{FONT}" fill="{SAND}">
<text x="548" y="206" font-size="84" font-weight="700" letter-spacing="-1">Tideline</text>
<text x="550" y="250" font-size="27" fill="{SEAFOAM}">{SUB[lang]}</text>
<text x="550" y="332" font-size="46" font-weight="600">{l1}</text>
<text x="550" y="390" font-size="46" font-weight="600" fill="{TIDE}">{l2}</text>
</g>
</g>
</svg>
"""

def search_svg(lang, shot):
    w, h = 3840, 2560
    pw = 1000
    ph = round(pw * 2868 / 1320)
    px, py, r = 2330, (h - ph) // 2, 96
    s = 0.62
    h1, h2 = SEARCH_HEAD[lang]
    band = wave(-100, w + 100, 2460, 50, 1300, phase=0.6)
    return f"""<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="{w}" height="{h}" viewBox="0 0 {w} {h}">
<defs><clipPath id="screen"><rect x="{px}" y="{py}" width="{pw}" height="{ph}" rx="{r}"/></clipPath></defs>
<rect width="{w}" height="{h}" fill="{BG}"/>
<path d="{band} L{w + 100} {h} L-100 {h} Z" fill="{BAND}"/>
<g transform="translate({560 - 512 * s:.1f} {540 - 548 * s:.1f}) scale({s})">{mark()}</g>
<g font-family="{FONT}" fill="{SAND}">
<text x="390" y="1130" font-size="250" font-weight="700" letter-spacing="-4">{h1}</text>
<text x="390" y="1390" font-size="250" font-weight="700" letter-spacing="-4" fill="{TIDE}">{h2}</text>
<text x="396" y="1600" font-size="92" fill="{SEAFOAM}">{SEARCH_SUB[lang]}</text>
</g>
<rect x="{px - 18}" y="{py - 18}" width="{pw + 36}" height="{ph + 36}" rx="{r + 18}" fill="{SAND}"/>
<image x="{px}" y="{py}" width="{pw}" height="{ph}" clip-path="url(#screen)" xlink:href="{shot}"/>
</svg>
"""

def render(name, svg, w, h, render_svg=None):
    """Writes `svg` as the source and renders `render_svg` (default: the same) to PNG."""
    path = os.path.join(OUT, name)
    with open(path + ".svg", "w", encoding="utf-8") as f:
        f.write(svg)
    with tempfile.TemporaryDirectory() as tmp:
        # rsvg-convert only loads images from the SVG's own directory or below.
        src = os.path.join(tmp, "art.svg")
        with open(src, "w", encoding="utf-8") as f:
            f.write(render_svg or svg)
        shutil.copy(os.path.join(SHOTS, name.split("-")[1], "01-log.png"), os.path.join(tmp, "shot.png"))
        subprocess.run(["rsvg-convert", "-w", str(w), "-h", str(h), "-o", path + ".png", src], check=True)
    # App Store Connect rejects alpha: flatten onto the background colour.
    subprocess.run(["magick", path + ".png", "-background", BG, "-alpha", "remove", "-alpha", "off", path + ".png"], check=True)

def main():
    os.makedirs(OUT, exist_ok=True)
    for lang in TAGLINES:
        render(f"header-{lang}", header_svg(lang), 3840, 1646)
        shot = os.path.relpath(os.path.join(SHOTS, lang, "01-log.png"), OUT)
        render(f"search-{lang}", search_svg(lang, shot), 3840, 2560, search_svg(lang, "shot.png"))

if __name__ == "__main__":
    main()
