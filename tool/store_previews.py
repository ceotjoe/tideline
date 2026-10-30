#!/usr/bin/env python3
"""Records the Mac App Store app previews (nothing is committed).

It runs app/integration_test/store_previews_test.dart once per scene. The test
prints PREVIEW_START and PREVIEW_END around the part to film; this script
records the Tideline window with `screencapture -v` between the two, then
encodes the clip to what App Store Connect takes for a Mac preview: 1920x1080,
H.264, 30 fps, 15 to 30 seconds, with a silent stereo AAC track.

Like tool/store_screenshots.py it moves the maintainer's tideline.sqlite aside
and puts it back (see docs/release.md). Needs Screen Recording permission for
the terminal and ffmpeg.

Output: docs/release/previews/mac/<scene>-<locale>.mp4 (git-ignored).

  tool/store_previews.py log contest activation
"""

from __future__ import annotations

import argparse
import signal
import subprocess
import sys
import time

import store_screenshots as ss

ROOT = ss.ROOT
APP = ss.APP
OUT = ROOT / "docs" / "release" / "previews" / "mac"
TEST = "integration_test/store_previews_test.dart"
SCENES = ["log", "contest", "activation"]
TARGET = (1920, 1080)


def record_scene(scene: str, locale: str, raw) -> None:
    cmd = [
        "nice", "-n", "15", "flutter", "test", TEST, "-d", "macos",
        f"--dart-define=PREVIEW={scene}", f"--dart-define=STORE_LOCALE={locale}",
    ]
    print("+", " ".join(cmd), flush=True)
    log_path = ROOT / "build" / f"store_previews_{scene}.log"
    log_path.parent.mkdir(exist_ok=True)
    log = log_path.open("w")
    proc = subprocess.Popen(cmd, cwd=APP, stdout=subprocess.PIPE,
                            stderr=subprocess.STDOUT, text=True)
    rec = None
    tail: list[str] = []
    try:
        for line in proc.stdout:
            log.write(line)
            log.flush()
            tail = (tail + [line.rstrip()])[-40:]
            if "PREVIEW_START" in line:
                wid = ss.mac_window_id()
                rec = subprocess.Popen(
                    ["screencapture", "-v", "-x", "-o", "-l", wid, str(raw)])
                time.sleep(0.5)
            elif "PREVIEW_END" in line and rec:
                rec.send_signal(signal.SIGINT)
                rec.wait(timeout=30)
                rec = None
    finally:
        if rec:
            rec.send_signal(signal.SIGINT)
            rec.wait(timeout=30)
    code = proc.wait()
    if code != 0 or not raw.exists():
        print("\n".join(tail), file=sys.stderr)
        raise SystemExit(f"{scene}: flutter test failed (exit {code}); see {log_path}")


def encode(raw, out) -> float:
    """Fits the window recording into 1920x1080 on a flat background."""
    w, h = TARGET
    vf = (f"fps=30,scale={w}:{h}:force_original_aspect_ratio=decrease:flags=lanczos,"
          f"pad={w}:{h}:(ow-iw)/2:(oh-ih)/2:color=0xF3EFE6,format=yuv420p")
    ss.sh(["ffmpeg", "-y", "-loglevel", "error", "-i", str(raw),
           "-f", "lavfi", "-i", "anullsrc=channel_layout=stereo:sample_rate=48000",
           "-vf", vf, "-c:v", "libx264", "-profile:v", "high", "-crf", "16",
           "-preset", "slow", "-r", "30", "-c:a", "aac", "-b:a", "256k",
           "-shortest", "-movflags", "+faststart", str(out)])
    probe = ss.sh(["ffprobe", "-v", "error", "-show_entries", "format=duration",
                   "-of", "csv=p=0", str(out)])
    return float(probe.strip())


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("scenes", nargs="*", default=SCENES)
    ap.add_argument("--locale", default="en")
    args = ap.parse_args()
    for s in args.scenes:
        if s not in SCENES:
            raise SystemExit(f"unknown scene {s}; choose from {SCENES}")

    db = ss.MAC_SUPPORT / "tideline.sqlite"
    aside = db.with_name("tideline.sqlite.store-screenshots-aside")
    before = None
    if db.exists():
        if aside.exists():
            raise SystemExit(f"{aside} exists: a former run was interrupted. "
                             "Restore it by hand first.")
        before = ss.sha(db)
        print(f"moving the real database aside ({before[:12]})", flush=True)
        db.rename(aside)
        for ext in ("-wal", "-shm"):
            side = db.with_name(db.name + ext)
            if side.exists():
                side.rename(aside.with_name(aside.name + ext))
    OUT.mkdir(parents=True, exist_ok=True)
    try:
        for scene in args.scenes:
            # A clean demo account for every scene.
            for ext in ("", "-wal", "-shm"):
                db.with_name(db.name + ext).unlink(missing_ok=True)
            raw = ROOT / "build" / f"preview_{scene}_raw.mov"
            raw.unlink(missing_ok=True)
            record_scene(scene, args.locale, raw)
            out = OUT / f"{scene}-{args.locale}.mp4"
            secs = encode(raw, out)
            ok = "ok" if 15 <= secs <= 30 else "OUTSIDE 15-30 s"
            print(f"{scene}: {out} {secs:.1f} s ({ok})", flush=True)
    finally:
        if before is not None:
            for ext in ("", "-wal", "-shm"):
                db.with_name(db.name + ext).unlink(missing_ok=True)
            for ext in ("", "-wal", "-shm"):
                src = aside.with_name(aside.name + ext)
                if src.exists():
                    src.rename(db.with_name(db.name + ext))
            after = ss.sha(db)
            print("database restored:", "checksum matches" if after == before
                  else f"CHECKSUM DIFFERS ({before[:12]} vs {after[:12]})", flush=True)


if __name__ == "__main__":
    main()
