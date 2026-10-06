#!/usr/bin/env python3
"""Generates the store screenshots on demand (nothing is committed).

It runs app/integration_test/store_screenshots_test.dart on a device, which walks
the demo account through the four main screens and prints `STORE_SHOT <name>` at each.
This script then takes the picture with the platform's own tool, so the pixels,
fonts and status bar are the real ones:

  ios      simctl on two throw-away simulators it creates and deletes
           (iPhone 6.9" and iPad 13"), status bar set to 9:41
  android  adb on a running emulator or device (phone 1080x1920, tablet
           1600x2560 through `wm size`, restored afterwards), demo-mode status bar
  mac      screencapture of the app window; moves the maintainer's
           tideline.sqlite aside and puts it back (see docs/release.md)

Output: docs/release/screenshots/<platform>/<locale>/<name>.png (git-ignored).

  tool/store_screenshots.py ios android --locales en de
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
APP = ROOT / "app"
OUT = ROOT / "docs" / "release" / "screenshots"
TEST = "integration_test/store_screenshots_test.dart"
BUNDLE_ID = "com.ITWebService.tideline"

# Device types the store asks for. Names are simctl device type identifiers,
# matched by prefix against `simctl list devicetypes`.
IOS_DEVICES = {
    "iphone-6.9": ["iPhone 18 Pro Max", "iPhone 17 Pro Max", "iPhone 16 Pro Max"],
    "ipad-13": ["iPad Pro 13-inch (M5)", "iPad Pro 13-inch (M4)"],
}
# Pixel sizes the store requires, checked after capture.
EXPECTED = {
    "iphone-6.9": {(1320, 2868), (1290, 2796), (1260, 2736)},
    "ipad-13": {(2064, 2752), (2048, 2732)},
    "android-phone": {(1080, 1920)},
    "android-tablet-10": {(1600, 2560)},
}


def run(cmd, **kw):
    return subprocess.run(cmd, check=True, text=True, capture_output=True, **kw)


def sh(cmd, check=True):
    r = subprocess.run(cmd, text=True, capture_output=True)
    if check and r.returncode != 0:
        raise SystemExit(f"{' '.join(cmd)}\nexit {r.returncode}\n{r.stderr or r.stdout}")
    return r.stdout


def png_size(path: Path) -> tuple[int, int]:
    out = sh(["sips", "-g", "pixelWidth", "-g", "pixelHeight", str(path)])
    w = int(re.search(r"pixelWidth: (\d+)", out).group(1))
    h = int(re.search(r"pixelHeight: (\d+)", out).group(1))
    return w, h


def run_flutter(device: str, locale: str, capture, extra_defines=()):
    """Runs the test, calling capture(name) at each STORE_SHOT line."""
    # Low priority, so the machine stays usable during the build and the run.
    cmd = [
        "nice", "-n", "15", "flutter", "test", TEST, "-d", device,
        f"--dart-define=STORE_LOCALE={locale}",
        *[f"--dart-define={d}" for d in extra_defines],
    ]
    print("+", " ".join(cmd), flush=True)
    proc = subprocess.Popen(
        cmd, cwd=APP, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True
    )
    shots = 0
    tail: list[str] = []
    log_path = ROOT / "build" / "store_screenshots.log"
    log_path.parent.mkdir(exist_ok=True)
    log = log_path.open("w")
    for line in proc.stdout:
        log.write(line)
        log.flush()
        tail = (tail + [line.rstrip()])[-40:]
        m = re.search(r"STORE_SHOT (\S+)", line)
        if m:
            capture(m.group(1))
            shots += 1
    code = proc.wait()
    if code != 0:
        print("\n".join(tail), file=sys.stderr)
        raise SystemExit(f"flutter test failed (exit {code}); full output: {log_path}")
    if shots == 0:
        raise SystemExit("the test ran but took no screenshots")
    return shots


# --- iOS -------------------------------------------------------------------


def ios_runtime() -> str:
    data = json.loads(sh(["xcrun", "simctl", "list", "runtimes", "-j"]))
    ok = [r for r in data["runtimes"] if r.get("isAvailable") and "iOS" in r["name"]]
    if not ok:
        raise SystemExit("no iOS simulator runtime installed")
    return sorted(ok, key=lambda r: r["version"])[-1]["identifier"]


def ios_device_type(prefixes: list[str]) -> str:
    data = json.loads(sh(["xcrun", "simctl", "list", "devicetypes", "-j"]))
    types = data["devicetypes"]
    for want in prefixes:
        for t in types:
            if t["name"] == want or t["name"].startswith(want + " ("):
                return t["identifier"]
    raise SystemExit(f"none of {prefixes} is a known simulator device type")


def do_ios(locales, only=None):
    runtime = ios_runtime()
    for key, names in IOS_DEVICES.items():
        if only and key not in only:
            continue
        dtype = ios_device_type(names)
        name = f"Tideline store {key}"
        udid = sh(["xcrun", "simctl", "create", name, dtype, runtime]).strip()
        print(f"created simulator {name} {udid}", flush=True)
        try:
            sh(["xcrun", "simctl", "boot", udid])
            sh(["xcrun", "simctl", "bootstatus", udid, "-b"])
            sh([
                "xcrun", "simctl", "status_bar", udid, "override",
                "--time", "9:41", "--batteryState", "charged", "--batteryLevel", "100",
                "--cellularMode", "active", "--cellularBars", "4", "--wifiBars", "3",
                "--operatorName", "",
            ])
            sh(["xcrun", "simctl", "ui", udid, "appearance", "light"])
            for locale in locales:
                # A clean app every time: the demo account is added once per run.
                sh(["xcrun", "simctl", "uninstall", udid, BUNDLE_ID], check=False)
                out_dir = OUT / key / locale
                shutil.rmtree(out_dir, ignore_errors=True)
                out_dir.mkdir(parents=True)

                def capture(shot, out_dir=out_dir, udid=udid):
                    # simctl is not allowed to write to external volumes, so it
                    # writes to a temporary folder and the file is moved.
                    with tempfile.TemporaryDirectory() as tmp:
                        tmp_file = Path(tmp) / f"{shot}.png"
                        sh(["xcrun", "simctl", "io", udid, "screenshot",
                            "--type=png", str(tmp_file)])
                        shutil.move(str(tmp_file), out_dir / f"{shot}.png")

                n = run_flutter(udid, locale, capture)
                check_sizes(key, out_dir)
                print(f"{key} {locale}: {n} screenshots in {out_dir}", flush=True)
        finally:
            sh(["xcrun", "simctl", "shutdown", udid], check=False)
            sh(["xcrun", "simctl", "delete", udid], check=False)


# --- Android ---------------------------------------------------------------


def adb(serial: str, *args: str, check=True) -> str:
    return sh(["adb", "-s", serial, *args], check=check)


def android_serial(requested: str | None) -> str:
    out = sh(["adb", "devices"]).splitlines()[1:]
    serials = [l.split()[0] for l in out if l.strip().endswith("device")]
    if requested:
        if requested not in serials:
            raise SystemExit(f"adb does not list {requested}: {serials}")
        return requested
    if len(serials) != 1:
        raise SystemExit(
            "need exactly one running emulator or device (or --android-serial); "
            f"adb lists {serials}. Start one, e.g. `emulator -avd Pixel_10a`."
        )
    return serials[0]


def android_demo_bar(serial: str, on: bool):
    adb(serial, "shell", "settings", "put", "global", "sysui_demo_allowed", "1")
    cmd = lambda *a: adb(
        serial, "shell", "am", "broadcast", "-a", "com.android.systemui.demo", *a
    )
    if on:
        cmd("-e", "command", "enter")
        cmd("-e", "command", "clock", "-e", "hhmm", "0941")
        cmd("-e", "command", "battery", "-e", "level", "100", "-e", "plugged", "false")
        cmd("-e", "command", "network", "-e", "wifi", "show", "-e", "level", "4")
        cmd("-e", "command", "network", "-e", "sims", "1")
        cmd("-e", "command", "network", "-e", "mobile", "show", "-e", "datatype", "none",
            "-e", "level", "4")
        cmd("-e", "command", "status", "-e", "bluetooth", "hide", "-e", "volume", "hide",
            "-e", "location", "hide", "-e", "alarm", "hide")
        cmd("-e", "command", "notifications", "-e", "visible", "false")
    else:
        cmd("-e", "command", "exit")


def do_android(locales, serial_arg):
    serial = android_serial(serial_arg)
    sizes = {
        "android-phone": ("1080x1920", "420"),
        "android-tablet-10": ("1600x2560", "320"),
    }
    try:
        android_demo_bar(serial, True)
        for key, (size, density) in sizes.items():
            adb(serial, "shell", "wm", "size", size)
            adb(serial, "shell", "wm", "density", density)
            time.sleep(2)
            for locale in locales:
                adb(serial, "uninstall", BUNDLE_ID, check=False)
                out_dir = OUT / key / locale
                shutil.rmtree(out_dir, ignore_errors=True)
                out_dir.mkdir(parents=True)

                def capture(shot, out_dir=out_dir):
                    data = subprocess.run(
                        ["adb", "-s", serial, "exec-out", "screencap", "-p"],
                        check=True, capture_output=True,
                    ).stdout
                    (out_dir / f"{shot}.png").write_bytes(data)

                n = run_flutter(serial, locale, capture)
                check_sizes(key, out_dir)
                print(f"{key} {locale}: {n} screenshots in {out_dir}", flush=True)
    finally:
        adb(serial, "shell", "wm", "size", "reset", check=False)
        adb(serial, "shell", "wm", "density", "reset", check=False)
        android_demo_bar(serial, False)


# --- macOS -----------------------------------------------------------------

MAC_SUPPORT = (
    Path.home() / "Library/Containers" / BUNDLE_ID
    / "Data/Library/Application Support" / BUNDLE_ID
)


def sha(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def mac_window_id() -> str:
    """The id of the Tideline window, from the window server (no Accessibility)."""
    script = (
        'import CoreGraphics\n'
        'let l = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) '
        'as! [[String: Any]]\n'
        'for w in l { if (w[kCGWindowOwnerName as String] as? String) == "tideline" '
        '|| (w[kCGWindowOwnerName as String] as? String) == "Tideline" '
        '{ print(w[kCGWindowNumber as String] as! Int); break } }\n'
    )
    out = subprocess.run(["swift", "-"], input=script, text=True, capture_output=True).stdout
    wid = out.strip().splitlines()[-1] if out.strip() else ""
    if not wid.isdigit():
        raise SystemExit("could not find the Tideline window")
    return wid


def do_mac(locales):
    db = MAC_SUPPORT / "tideline.sqlite"
    aside = db.with_name("tideline.sqlite.store-screenshots-aside")
    before = None
    if db.exists():
        if aside.exists():
            raise SystemExit(f"{aside} exists: a former run was interrupted. "
                             "Restore it by hand first.")
        before = sha(db)
        print(f"moving the real database aside ({before[:12]})", flush=True)
        db.rename(aside)
        for ext in ("-wal", "-shm"):
            side = db.with_name(db.name + ext)
            if side.exists():
                side.rename(aside.with_name(aside.name + ext))
    try:
        for locale in locales:
            out_dir = OUT / "mac" / locale
            shutil.rmtree(out_dir, ignore_errors=True)
            out_dir.mkdir(parents=True)

            def capture(shot, out_dir=out_dir):
                wid = mac_window_id()
                sh(["screencapture", "-x", "-o", "-l", wid, str(out_dir / f"{shot}.png")])

            n = run_flutter("macos", locale, capture)
            print(f"mac {locale}: {n} screenshots in {out_dir}", flush=True)
    finally:
        if before is not None:
            for ext in ("", "-wal", "-shm"):
                cur = db.with_name(db.name + ext)
                if cur.exists():
                    cur.unlink()
            for ext in ("", "-wal", "-shm"):
                src = aside.with_name(aside.name + ext)
                if src.exists():
                    src.rename(db.with_name(db.name + ext))
            after = sha(db)
            print("database restored:", "checksum matches" if after == before
                  else f"CHECKSUM DIFFERS ({before[:12]} vs {after[:12]}), "
                       "the app may have migrated it; check by hand", flush=True)


# --- common ----------------------------------------------------------------


def check_sizes(key: str, out_dir: Path):
    want = EXPECTED.get(key)
    if not want:
        return
    for p in sorted(out_dir.glob("*.png")):
        size = png_size(p)
        if size not in want:
            print(f"WARNING {p.name}: {size[0]}x{size[1]} is not one of "
                  f"{sorted(want)} for {key}", file=sys.stderr)


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("platforms", nargs="+", choices=["ios", "android", "mac"])
    ap.add_argument("--locales", nargs="+", default=["en", "de"])
    ap.add_argument("--android-serial")
    ap.add_argument("--ios-only", nargs="+", choices=list(IOS_DEVICES),
                    help="only these simulators, to save time while iterating")
    args = ap.parse_args()
    os.chdir(ROOT)
    for platform in args.platforms:
        {"ios": lambda: do_ios(args.locales, args.ios_only),
         "android": lambda: do_android(args.locales, args.android_serial),
         "mac": lambda: do_mac(args.locales)}[platform]()


if __name__ == "__main__":
    main()
