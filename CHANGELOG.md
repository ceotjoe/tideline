# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
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
- **Manual v0.1** in English and German.
- **Workspace and CI.**
  - A Dart workspace with the Flutter app (iOS, iPadOS, Android, macOS, Windows; Linux unofficial) and pure-Dart
    packages for the domain, ADIF, the Wavelog client, data and a mock Wavelog server.
  - CI that runs analysis, tests and a stale-generated-code check, and builds every platform.
  - Release workflows that sign with CI secrets, plus an SBOM.
- **Encrypted local database.**
  - SQLite3MultipleCiphers (ChaCha20-Poly1305), with the key in the OS secure store.
  - Schema v1 covers QSOs (ADIF 3.1.x fields), sync state and journal, contests and serials, activations, reference
    data, worked-before and peer devices.
  - Migration harness.
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
