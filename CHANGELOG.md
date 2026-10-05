# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- A built-in demo account: **Try the demo (no Wavelog needed)** on the Welcome screen sets up an account served inside
  the app, for testers and App Review. Nothing is sent over the network (ADR 0031).
- Release workflow: a tag creates a GitHub release with a Windows portable zip and MSIX, an experimental Linux tarball,
  the SBOM and checksums (ADR 0030). A tag also uploads the Android bundle to the Google Play internal track, after
  approval of the `production` environment, and the signed iOS and iPadOS build goes to TestFlight the same way
  (`tool/ios_archive.sh`), and so does the signed macOS package (`tool/macos_package.sh`).

### Changed
- Activation counting follows the programmes' rules (ADR 0021 update): SOTA needs 4 QSOs with different stations on one UTC
  day (the same station on another band no longer counts), WWFF counts the same station again on another UTC day and
  adds the days of a session up. Counting across several activations is not tracked.
- iOS and macOS `Info.plist` declare `ITSAppUsesNonExemptEncryption` as `true`, so builds no longer wait for the
  per-build encryption question (ADR 0022).

### Fixed
- `tool/macos_archive.sh`: the Mac App Store upload was rejected with ITMS-90284 because the plugins' resource bundles
  kept the development signature. The script now strips it and re-seals the app (`docs/release.md`).

## [0.4.0] - 2026-10-05

Tester feedback turned into features, plus Fast Log Entry and field modes. Build number 6 (0.3.1 had builds 3 and 4, an earlier 0.4.0 upload was build 5). Database schema 5 (the
update migrates in place, nothing to do). Highlights: several Wavelog accounts, an offline callsign directory with notes,
freeing up space by removing QSOs Wavelog already has, desktop navigation, Fast Log Entry, and a field mode.

### Added
- **Field mode** (ADR 0029). *Settings → Field mode*: one switch sets the sunlight theme, glove mode, a battery saver and
  keeps the screen on while the log, Fast Log Entry or the contest screen is open; switching it off brings your theme and
  button size back. Each part can be set on its own. The battery saver stops the tide animation, ticks the clock once a
  minute and slows the contest rates. New dependency `wakelock_plus`. No location button.
- **Fast Log Entry** (ADR 0028). Type QSOs as shorthand in the dialect of Wavelog's SimpleFLE (time fragments, band, mode,
  frequency, reports, locator, references, @name, date and time zone), see how every line was read, and log them all in
  one transaction. Problem lines are named and left out, duplicates and odd times are flagged, a running activation takes
  the QSOs. Open it with the lightning bolt in the log or Ctrl/⌘+Shift+F. Not for contest sessions.
- **Free up space** (ADR 0027). On an account's page, *Remove synced QSOs from this device* removes the local copies of
  QSOs that Wavelog already has, by age (older than 1, 2 or 5 years, or all). Tideline asks Wavelog first and keeps what
  it cannot find there; QSOs of contests and activations, and QSOs not yet sent or changed since, stay. Nothing is deleted
  on Wavelog. **Export, then remove** saves an ADIF file of exactly those QSOs first. A single synced QSO can be removed
  from its details. Worked-before hints and station names stay; an ADIF import skips QSOs removed this way. Database
  schema 5.
- **Offline callsign directory and notes** (ADR 0026). Under the callsign field: what earlier contacts say about the
  station (name, place, locator) with **Fill in** for empty fields, and your own note, with a note button in the field.
  The directory is built from your log and from Wavelog's history; **Settings → Reference data → Browse callsigns and
  notes** searches it. Notes are local only (Wavelog's API v2 has no notes), are in the encrypted backup and in no
  export. Database schema 4.
- **Desktop navigation** on macOS, Windows and Linux (ADR 0025). A sidebar instead of the bottom bar (also in a narrow
  window), a menu bar (the system menu on macOS, a strip in the window on Windows and Linux) with Go, Operate and Help,
  built from the same commands as the shortcuts, and a **Go back** command on `Esc`, `Alt+←` and `Ctrl/⌘+[`. A right
  click on a log row offers *Open QSO* and *Copy callsign*.
- **Several Wavelog accounts** (ADR 0024). Settings → Wavelog accounts lists them and adds another; each account can be
  renamed, put into use for logging, given a new token or removed. On the log screen an account menu appears from the
  second account on. Switching is refused while a contest session or an activation runs. Sync covers every account, and
  the sync screen shows the waiting QSOs per account. Import and export say which account they act on.

### Fixed
- Removing an account that had contest sessions, activations or a worked-before index failed on the database's foreign
  keys and left the account in place. The removal now deletes all of the account's local data, its settings and its
  token (nothing on the server), and updates the screens.

## [0.3.1] - 2026-10-04

Feedback from the first test round: the keyboard on phones and a less cluttered settings screen. Build number 3 (0.3.0
had builds 1 and 2).

### Added
- **Hide keyboard on phones.** While the on-screen keyboard is up, a **Hide keyboard** bar sits above it and replaces
  the bottom navigation, which the keyboard used to cover. Tapping empty space or dragging the log list or settings
  also closes the keyboard. Tablets and computers are unchanged (ADR 0020).

### Changed
- **Settings are a hub of pages** (ADR 0023): Wavelog account, Appearance and language, Reference data, Security and
  backup, each on its own page, with the keyboard shortcuts one tap away. Nothing about what the settings do changed.
- RST fields in the log form open a signed number keyboard (frequency and the contest exchange already had number
  keyboards).

## [0.3.0] - 2026-10-04

The first test build (TestFlight, internal testers). It holds everything developed so far: the versions 0.1 (offline
logging and sync) and 0.2 (contest mode) were never released on their own.

### Added
- **iOS release preparation** (ADR 0022). A privacy manifest (no tracking, no data collected; the file-timestamp and
  disk-space reasons for the bundled SQLite), the languages the app supports (English, German) declared to the system,
  and the Face ID text in both languages.
  The launch screen shows the Tideline mark instead of the template's empty placeholder image, which Flutter's IPA
  validation rejects. The system's local-network prompt now explains why (Wavelog servers in your own network).
- **macOS release preparation.** The same privacy manifest, the declared languages and local-network text, and the App
  Store category (Utilities). A Mac App Store export options file and a runbook (`docs/release.md`).
- **SOTA, POTA and WWFF activations** (ADR 0021).
  - Reference lists you download yourself from the official source, only when you press Download (HTTPS only, size
    caps, streamed to disk, cancellable). The installed list is replaced in one step only after the whole file was read,
    so a failed or cancelled download changes nothing. Address, version, date and source are shown in settings.
  - Search by reference, name or region, and the nearest references to your grid square, all offline.
  - Activation setup with the grid square taken from the reference, and advice on which Wavelog location carries
    your reference. Wavelog fills the own reference of an upload from the station location and ignores the one sent
    (verified); Tideline keeps it on every QSO and in ADIF exports and never changes your Wavelog locations.
  - A banner on the log screen with the reference, place name and progress toward validity as a bar and a sentence
    (POTA 10 QSOs per UTC day, SOTA 4, WWFF 44; duplicates are not counted).
  - Park-to-park and summit-to-summit: the other station's reference is a field of the entry form and syncs.
  - Commands `activation.start` (⇧⌘A / Ctrl+Shift+A) and `activation.end` (⇧⌘E / Ctrl+Shift+E).
  - Local data: schema version 3 (reference status and position index), activations and rules as data.
  - Station locations now cache their SOTA, POTA, WWFF, IOTA and SIG values.
- **Contest mode** (ADR 0018).
  - Contest rules are data files with a strict, fuzz-tested parser. Bundled: CQ WW (SSB, CW), CQ WPX (SSB, CW), ARRL
    DX (CW, SSB), IARU HF, DARC WAG and two generic contests, checked against the sponsors' rules. Your own
    definitions can be imported in settings.
  - Session setup with your exchange and the Cabrillo categories.
  - A dense, keyboard-first entry screen. Enter logs the QSO or goes to the first missing field; Space and Tab move on.
    Touch targets stay at least 48 dp.
  - Serial numbers are taken in the same transaction as the QSO and never reused, even after a delete.
  - Live hints as icon and text: dupe, worked on other bands, new multiplier, worked before in your log, super check
    partial and one-character-off suggestions.
  - Score (labelled as an estimate), multipliers, per-band table and rates (last 10/60 minutes, last 10/100 QSOs, best
    60 minutes).
  - Editing and deleting QSOs without leaving contest mode; the sent serial stays fixed.
  - Phone, tablet-portrait and tablet-landscape layouts; typed input survives rotation and resizing.
  - New commands with default shortcuts, listed in the shortcuts overlay.
- **Wavelog contest sessions (3.2+).** A session is created on Wavelog once one of its QSOs is uploaded, its QSOs are
  linked as they upload and its end time follows the log. A lost answer is reconciled before any retry, so no session is
  created twice. Older servers and inactive contests keep the session on the device.
- **Cabrillo export.**
  - Export a contest session as a Cabrillo 3.0 log, running or past, from the contest menu, the shortcut
    (⇧⌘X / Ctrl+Shift+X) and the list of past sessions (ADR 0019).
  - Problems are checked and listed first; the user may export anyway.
  - Contests without a Cabrillo name show a warning instead.
- **Contest session status.** The Wavelog state of a session (local, waiting, being checked, on Wavelog) and the reason
  it stays local, as icon and text in the contest screen and the session list.
- **Cabrillo categories.** Added `CATEGORY-TIME` and the `YL` overlay (Cabrillo 3.0 specification).
- **Super check partial.** Download MASTER.SCP from an address you can see and change (HTTPS only, at most 8 MiB, only
  when you ask), or import the file.
- **Worked-before index.** Built from your log and kept current as you log, filled from your Wavelog log on each sync
  (at most 10 pages per run), and rebuildable from settings. The normal log shows new call, band, mode or combination.
- **Frequency entry.** A live reading under the field ("14.205 MHz · 20 m", "472 kHz · 630 m") replaces the fixed MHz
  suffix. Whole numbers are read as kHz when that lands in an amateur band and MHz does not, so `472`, `136` and `1840`
  work while `7`, `50` and `144` stay MHz.
- **Wavelog onboarding.**
  - Server address check, with plain HTTP allowed on the LAN only after an opt-in.
  - Every token permission is explained and checked live.
  - Trust-on-first-use certificate pinning with a fingerprint dialog.
  - Station selection.
- **Offline logging.**
  - Callsign entry with live offline DXCC and worked-before hints.
  - Frequency selects the band; reports default by mode; time is explicit UTC.
  - Enter and Esc on hardware keyboards.
  - Phone, tablet-portrait and tablet-landscape layouts.
- **Transparent sync.**
  - Per-QSO status with plain-language explanations and Wavelog's own message.
  - Sync history.
  - The tide gauge as a headline.
  - A dry-run preview before uploads of more than 50 QSOs.
  - Conflict choices for edits Wavelog cannot apply (ADR 0016).
- **Sync engine.**
  - Single uploads, with a reconcile check before any retry, so nothing is duplicated or lost across timeouts,
    crashes, server errors and restarts.
  - Same-minute twin detection, patch/replace/delete, account blocking, Retry-After.
- **ADIF 3.1.7 import and export.** A strict, fuzz-tested parser, tolerant of real-world files; lossless round trip.
- **Encrypted backups.** Passphrase protected (Argon2id + XChaCha20-Poly1305); tokens are never included; a restore never
  re-uploads synced QSOs.
- **Account settings.** Token expiry, entering a new token, removing an account. Optional app lock.
- **Atkinson Hyperlegible** reading font (optional, bundled).
- **The Tideline app icon**, built for Liquid Glass on iOS/macOS, plus adaptive and themed Android icons, Windows icons
  and launch screens.
- **Offline DXCC** from the bundled AD1C country files.
- **Mock Wavelog server** with fault injection, and an end-to-end test of the real app against it (iPad simulator, macOS,
  CI).
- **Manual v0.2** in English and German, including the contest mode chapter.
- **Workspace and CI.**
  - A Dart workspace with the Flutter app (iOS, iPadOS, Android, macOS, Windows; Linux unofficial) and pure-Dart
    packages for the domain, ADIF, the Wavelog client, data and a mock Wavelog server.
  - CI that runs analysis, tests and a stale-generated-code check, and builds every platform.
  - Release workflows that sign with CI secrets, plus an SBOM.
- **Encrypted local database.**
  - SQLite3MultipleCiphers (ChaCha20-Poly1305), with the key in the OS secure store.
  - Schema v2 covers QSOs (ADIF 3.1.x fields), sync state and journal, contests and serials, activations, reference
    data, worked-before and peer devices, plus contest-session sync state and links (v2).
  - Migration harness, with a tested v1 → v2 migration.
- **"Low Tide" design system.**
  - Light, dark, sunlight and night-red themes, contrast-tested against WCAG 2.2 AA (AAA for sunlight).
  - Glove mode and extra text spacing.
  - The wave-horizon tide gauge, with a text and screen-reader equivalent.
- **Adaptive app shell.** A bottom bar on phones and a navigation rail on tablets and desktop, driven by window size
  classes.
- **Keyboard commands.** A command registry with platform-aware shortcuts, user overrides and conflict detection, a
  shortcut overview (Ctrl/⌘ + / or F1), and a shortcut table in the manual generated from the registry.
- **Languages.** English and German, chosen in the app or following the system. A pseudo-locale and a forced RTL mode
  are available for testing.
- **Wavelog API v2 client.** A capability probe (index.php detection, token scopes, Wavelog 3.2 features), typed errors
  and a mock server for tests.
- **Documentation.** README, manual skeleton (EN/DE), architecture, verified Wavelog API notes, ADRs 0001–0015, STRIDE
  threat model, MASVS mapping, privacy statement and security policy.

### Changed
- **Log screen in landscape (ADR 0020).** On tablets and wide windows in landscape, the entry form is three rows across
  the full width with the log underneath. With the on-screen keyboard open, all fields, Clear and Log stay visible
  without scrolling; the top bar hides while the keyboard is up. QSO details open in a sheet instead of a third column,
  and the separate context column is gone (the DXCC and worked-before hints stay in the entry). The frequency reading
  moves into the third row of the strip.
- **More room above the keyboard.** In landscape the contest banner hides with the app bar while the keyboard is up,
  and the list yields its minimum height, so name, locator, comment, station, hints and both buttons fit on an iPad Pro
  11" without scrolling. With larger text the hints scroll below the fields.
- **Clear and Log stay in reach.** In the landscape strip they are now pinned below the fields, like in the portrait
  grid and the contest strip, so they remain visible when the keyboard leaves very little room.
- **Log screen in portrait.** On tablets in portrait the fields are rows of up to three over the log instead of a
  narrow column beside it, with Clear and Log pinned. With the keyboard up, everything stays visible. The contest
  screen already fit in portrait; tests now cover it.
- **Contest entry in landscape.** The same strip for contest mode: callsign, received exchange, band, mode and
  frequency in one row, hints and sent exchange below, the frequency reading and buttons pinned at the bottom, recent
  QSOs and the score panel underneath. Everything stays above the on-screen keyboard.
- **Phones stay in portrait.** iPhone and Android phones no longer rotate; tablets and desktop windows do.

### Fixed
- **Tablet landscape.** On an iPad Pro or Air 11" in landscape (1210 dp) the log list got ~130 dp and the log screen
  stayed empty. Columns now follow the available width, and the navigation rail shows labels only from 1440 dp. The
  entry form pairs short fields (band and mode, reports, name and locator) and keeps Clear and Log in view. The contest
  setup lists every contest in its own column instead of a 300 dp scroll box. Multiplier hints name the country
  instead of its DXCC number.
- Commands that share a key on different screens (for example Enter in the log and in contest mode) no longer shadow
  each other; the command available on the current screen runs.
- The contest entry's Log button is no longer cut off in tablet-landscape and desktop windows; the action row stays
  pinned below the scrolling fields.
- Frequencies below 1 MHz are read out in kHz (`472 kHz · 630 m`).
