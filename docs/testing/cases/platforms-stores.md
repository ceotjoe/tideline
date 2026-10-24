# Platforms and stores (PS)

Minimums in the project: iOS and iPadOS 16.0, Android 7.0 (API 24), macOS 12.0, Windows 10 or newer (check the MSIX
manifest). Linux is unofficial and never blocks a release. Release steps are in `docs/release.md`.

### PS-01 Fresh install and first run
**P1 · all · Needs: a clean device or user**
Install the store build (or release artefact). Open it.

**Expected:** the Welcome screen appears in the system language, onboarding is reachable, no permission prompt appears
before it is needed, no crash.

Result:

### PS-02 Oldest supported OS and smallest screen
**P1 · iOS 16, Android 7, one small and one large device · Needs: the devices or simulators**
Run LG-01, DS-01 and AL-06 on the oldest supported OS and on the smallest and largest supported screens (iPhone SE class,
small Android, 12.9″ iPad, large Android tablet, foldable if available).

**Expected:** they pass; layouts follow the window size class, not the device type.

Result:

### PS-03 Upgrade from the previous store version
**P1 · all · Needs: the previous build from the same channel**
See DS-14. Include TestFlight → App Store and Play closed test → production.

**Expected:** as DS-14. The database migrates in place; the build number is higher; the app version shown in Settings
matches the store.

Result:

### PS-04 Uninstall and reinstall
**P2 · all**
Uninstall, reinstall.

**Expected:** the app starts clean. It does not restore from a cloud backup (iOS, Android). On desktop the log stays in the
user folder and the README or manual says where.

Result:

### PS-05 Android back, edge to edge, split screen
**P2 · Android phone, tablet, foldable**
Use the back button and gesture on every level, rotate, use split screen and a freeform window, and fold or unfold.

**Expected:** back goes up one level and never discards an entry; typed input survives; status and navigation bars do
not cover content on the current Android version.

Result:

### PS-06 Windows install paths
**P1 · Windows 10 and 11 · Needs: the GitHub release**
Check the checksum against `SHA256SUMS.txt`. Install the MSIX on a clean PC; run the portable zip from a folder and from
a USB drive; start it twice; use 125 %, 150 % and 200 % scaling and two monitors of different scaling.

**Expected:** both install and run; the publisher is shown; a second start does not corrupt data; the layout survives
scaling and moving between monitors; closing the window ends the process.

Result:

### PS-07 macOS build and review
**P1 · macOS · Needs: the TestFlight/App Store Mac build**
Install, open without a Gatekeeper warning, quit with **⌘Q**, use full screen and Stage Manager.

**Expected:** the build passes review; the local-network prompt appears only when a LAN server is used and explains why;
the menu bar entries match the shortcuts overlay.

Result:

### PS-08 iOS and iPadOS App Review
**P1 · iOS, iPadOS · Needs: App Store Connect**
Submit with the demo account described in the review notes.

**Expected:** a reviewer reaches a working app without a Wavelog server; the privacy answers match `PRIVACY.md`; export
compliance is "no" (ADR 0034); the build is accepted.

Result:

### PS-09 Google Play
**P1 · Android · Needs: Play Console**
Closed test for 14 days with at least 12 testers opted in (only if the developer account is personal and created after
2023-11-13), then apply for production. Check Android vitals.

**Expected:** no crash or ANR cluster in vitals; the data safety form matches `PRIVACY.md`; production is approved.

Result:

### PS-10 Store listing and artefacts
**P2 · all**
Compare the store texts, screenshots and feature graphic (`docs/release/store-listing.md`) with the shipped version.

**Expected:** every claim exists in the app; screenshots show the current design in EN and DE; the privacy policy URL
works; the SBOM and checksums are attached to the GitHub release; the README links the right stores.

Result:

### PS-11 Linux arm64 on a Raspberry Pi (no keyring)
**P3 · Raspberry Pi 4 or 5, 64-bit Raspberry Pi OS · Needs: the `linux-arm64` tarball**
Unpack the tarball and start `tideline` with a running keyring (desktop session). Then stop the keyring service (or use
Raspberry Pi OS Lite with a minimal X session) and start it again.

**Expected:** with the keyring, the app starts and logs a QSO. Without it, the "Tideline couldn't start" screen explains
the missing system keyring (EN and DE), the app does not open, `tideline.sqlite` is unchanged and no token is written to
any file. Linux never blocks a release.

Result:
