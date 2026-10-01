#!/usr/bin/env python3
"""Generates the Tideline app icon layers (concept A, refined) and a preview.

Design: a half sun (the transmitter) rising out of the tide line, radio arcs
radiating sideways to the left and right, and two bold waves below.
Sideways arcs and an empty top centre keep it from reading as the Wi-Fi
symbol. Layers are flat vector shapes for Liquid Glass: Icon Composer adds
light, depth and specular highlights. See docs/design/design-system.md.

Run: python3 docs/design/icon/generate_icon.py
"""
import math
import os

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "layers")

CX, HORIZON = 512, 580  # sun centre sits on the horizon

def arc(cx, cy, r, a0, a1):
    p = lambda a: (cx + r * math.cos(math.radians(a)), cy + r * math.sin(math.radians(a)))
    (x0, y0), (x1, y1) = p(a0), p(a1)
    return f"M{x0:.1f} {y0:.1f} A{r} {r} 0 0 1 {x1:.1f} {y1:.1f}"

def wave(x0, x1, y, amp, wavelength, phase=0.0, clip=None):
    """A sine stroke from x0 to x1; `clip` draws only part of it, keeping
    the phase of the full wave so that waves stay parallel."""
    start, end = clip or (x0, x1)
    pts, x = [], start
    while x <= end + 0.1:
        pts.append(f"{x:.1f} {y + amp * math.sin(2 * math.pi * (x - x0) / wavelength + phase):.1f}")
        x += 4
    return "M" + " L".join(pts)

S = 'fill="none" stroke-linecap="round" stroke-linejoin="round"'

def half_sun(r):
    return f"M{CX - r} {HORIZON} A{r} {r} 0 0 1 {CX + r} {HORIZON} Z"

LAYERS = {
    # Back layer: the tide.
    "1-tide": [
        f'<path d="{wave(150, 874, HORIZON + 112, 30, 362)}" {S} stroke-width="74"/>',
        # Parallel to the first wave (same wavelength and phase) so the two
        # never touch, even at 29 px.
        f'<path d="{wave(150, 874, HORIZON + 244, 30, 362, clip=(250, 774))}" {S} stroke-width="74"/>',
    ],
    # Front layer: the transmitter sun and its signal.
    "2-signal": [
        f'<path d="{half_sun(132)}"/>',
        # Right side, radiating outward and up; top centre stays empty.
        f'<path d="{arc(CX, HORIZON, 232, -62, -14)}" {S} stroke-width="66"/>',
        f'<path d="{arc(CX, HORIZON, 342, -56, -18)}" {S} stroke-width="66"/>',
        # Left side, mirrored.
        f'<path d="{arc(CX, HORIZON, 232, -166, -118)}" {S} stroke-width="66"/>',
        f'<path d="{arc(CX, HORIZON, 342, -162, -124)}" {S} stroke-width="66"/>',
    ],
}

# Default appearance colours ("Low Tide" palette).
BACKGROUND = "#1F6F68"                      # seafoam700
FOREGROUND = {"1-tide": "#9FD3C7", "2-signal": "#FFFCF6"}  # seafoam300, sand50

APPEARANCES = {
    "light":  ("#1F6F68", {"1-tide": ("#9FD3C7", 1), "2-signal": ("#FFFCF6", 1)}),
    "dark":   ("#0F1E22", {"1-tide": ("#7FD1C3", 1), "2-signal": ("#FFFCF6", 1)}),
    "clear":  ("rgba(255,255,255,0.16)", {"1-tide": ("#FFFFFF", 0.62), "2-signal": ("#FFFFFF", 0.95)}),
    "tinted": ("#1C1C1E", {"1-tide": ("#F2B8FF", 0.55), "2-signal": ("#F2B8FF", 1)}),
}

def colourise(shapes, colour):
    out = []
    for s in shapes:
        attr = f'stroke="{colour}"' if 'stroke-width' in s else f'fill="{colour}"'
        out.append(s.replace("<path ", f"<path {attr} ", 1))
    return "".join(out)

def svg(body):
    return f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024">{body}</svg>\n'

def write_layers():
    os.makedirs(OUT, exist_ok=True)
    with open(os.path.join(OUT, "0-background.svg"), "w") as f:
        f.write(svg(f'<rect width="1024" height="1024" fill="{BACKGROUND}"/>'))
    for name, shapes in LAYERS.items():
        with open(os.path.join(OUT, f"{name}.svg"), "w") as f:
            f.write(svg(colourise(shapes, FOREGROUND[name])))
    # Flattened default appearance, used for Android/Windows/Linux sources.
    flat = f'<rect width="1024" height="1024" fill="{BACKGROUND}"/>' + "".join(
        colourise(s, FOREGROUND[n]) for n, s in LAYERS.items())
    with open(os.path.join(OUT, "flattened-default.svg"), "w") as f:
        f.write(svg(flat))

def tile(mode, size):
    bg, layer_style = APPEARANCES[mode]
    body = "".join(
        f'<g opacity="{layer_style[n][1]}">{colourise(s, layer_style[n][0])}</g>'
        for n, s in LAYERS.items())
    return (f'<div class="tile {mode}" style="width:{size}px;height:{size}px;background:{bg}">'
            f'<svg viewBox="0 0 1024 1024">{body}</svg></div>')

def write_preview():
    cells = "".join(f"<figure>{tile(m, 200)}<figcaption>{m}</figcaption></figure>" for m in APPEARANCES)
    small = "".join(tile("light", s) for s in (120, 60, 40, 29))
    html = f"""<!doctype html><html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1"><title>Tideline icon</title>
<style>
:root{{--bg:#F6F1E7;--fg:#12343B;--muted:#3E5C61}}
@media (prefers-color-scheme:dark){{:root{{--bg:#0F1E22;--fg:#E8F1EF;--muted:#A9C2C0}}}}
body{{margin:0;padding:24px 16px;background:var(--bg);color:var(--fg);font:16px/1.5 -apple-system,system-ui,sans-serif}}
main{{max-width:1000px;margin:auto}} h1{{font-size:26px;margin:0 0 4px}} h2{{font-size:18px;margin:28px 0 8px}}
p{{color:var(--muted);margin:0 0 12px}}
.row{{display:flex;gap:20px;flex-wrap:wrap;align-items:flex-end}}
figure{{margin:0;text-align:center;padding:14px;border-radius:24px;background:linear-gradient(135deg,#ff9a76,#6a82fb 55%,#2bc0a6)}}
figcaption{{font-size:13px;color:#fff;margin-top:6px}}
.tile{{position:relative;border-radius:22.5%;overflow:hidden;box-shadow:0 6px 18px rgba(0,0,0,.25)}}
.tile svg{{width:100%;height:100%;display:block}}
.tile::after{{content:"";position:absolute;inset:0;border-radius:inherit;
 background:linear-gradient(160deg,rgba(255,255,255,.35),rgba(255,255,255,0) 40%);box-shadow:inset 0 0 0 1.5px rgba(255,255,255,.35)}}
.tile.clear{{backdrop-filter:blur(14px) saturate(1.4);-webkit-backdrop-filter:blur(14px) saturate(1.4)}}
.compare{{display:flex;gap:28px;align-items:center;flex-wrap:wrap}} .compare div{{text-align:center;font-size:13px;color:var(--muted)}}
</style></head><body><main>
<h1>Tideline app icon — concept A, refined</h1>
<p>A half sun (the transmitter) rising from the tide line, radio signal radiating sideways, two bold waves below.
Background + 2 flat layers for Liquid Glass.</p>
<h2>Appearances</h2><div class="row">{cells}</div>
<h2>Small sizes and dock</h2><div class="row">{small}
<figure style="padding:10px">{tile("dark", 60)}</figure><figure style="padding:10px">{tile("clear", 60)}</figure></div>
<h2>Before → after</h2><div class="compare">
<div><div style="width:140px;height:140px">{{original}}</div>Original A (Wi-Fi-like)</div>
<div>{tile("light", 140)}<br>Refined A</div></div>
<p style="margin-top:28px;font-size:14px">The glass is approximated with CSS; Icon Composer renders the real material.</p>
</main></body></html>"""
    with open(os.path.join(HERE, "concepts", "a-signal-sun", "preview-light.svg")) as f:
        original = f.read().replace("<svg ", '<svg width="140" height="140" ', 1)
    html = html.replace("{original}", original)
    with open(os.path.join(HERE, "preview.html"), "w") as f:
        f.write(html)

if __name__ == "__main__":
    write_layers()
    write_preview()
    print("layers written to", OUT)
