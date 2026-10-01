# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
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
