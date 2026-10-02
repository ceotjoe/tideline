# Tideline

**Tideline — the offline logger for Wavelog.**

Tideline is an open-source, cross-platform logging app for amateur radio operators. It logs QSOs
offline-first, on a summit, in a park, at a field day or in a contest, and synchronises them with your
own [Wavelog](https://www.wavelog.org) instance whenever a connection is available.

> **Status: MVP (v0.1) in development, not yet released.** Logging, sync, offline DXCC, ADIF and encrypted backups work
> and are tested end to end against a mock Wavelog. Store builds are not available yet; follow the
> [CHANGELOG](CHANGELOG.md).

Platforms: **iOS · iPadOS · Android · macOS · Windows** (one Flutter codebase).

## Why Tideline?

Tideline is built around four ideas:

1. **Offline is normal, not an error.** Everything except the sync itself works with no connection,
   including DXCC lookups, reference lookups and "worked before" hints.
2. **Sync you can trust.**
   - Every QSO shows its sync state: local, queued, uploading, synced, conflict or rejected.
   - When the server objects, the app says why in plain language.
   - Nothing is silently lost or duplicated.
3. **Built for the field.** Usable with gloves, in bright sunlight, at night (red mode), one-handed and with a
   screen reader.
4. **Secure and private by design.** No telemetry. Encrypted at rest. Least-privilege API tokens.

## Planned features

| Feature | Milestone |
|---|---|
| ✅ Offline QSO logging, transparent sync queue with journal, tide-gauge sync indicator | MVP (v0.1) |
| ✅ Offline DXCC / prefix lookup, ADIF import/export, encrypted backup, app lock | MVP (v0.1) |
| ✅ English and German UI, accessibility baseline (WCAG 2.2 AA) | MVP (v0.1) |
| Contest mode: keyboard-first entry, serials, dupe checks, super check partial, rates, multipliers, Cabrillo | v0.2 |
| "Worked before" index from your own Wavelog log | v0.2 |
| SOTA / POTA / WWFF activation sessions with offline reference packs and progress toward validity | v0.3 |
| Fast Log Entry (FLE), glove mode, battery saver, multiple Wavelog accounts | v0.4 → v1.0 |
| Device-to-device sync over local Wi-Fi (no internet), WSJT-X listener on desktop | later |

## Requirements

- **Wavelog 3.1.0 or newer** with API v2. Contest-session sync needs **3.2.0+**.
- A Wavelog API v2 token with these scopes:
  - Required: `qso:read`, `qso:write`, `station:read`.
  - Optional: `contest:read`, `contest:write` (contest sessions), `qso:delete` (propagate deletes) and
    `lookup:read` (online lookups).
  - The app explains each scope when you set it up.
- Minimum OS versions:
  - iOS / iPadOS 16
  - Android 7.0
  - macOS 12
  - Windows 10 (1903)

## Install

Not yet released. Store links will appear here (App Store, Mac App Store, Google Play, Microsoft Store / MSIX).

## Quick start (developers)

```bash
flutter pub get
dart analyze --fatal-infos
tool/test_all.sh
cd app && flutter run
```

To try sync without a real Wavelog, run the mock server and connect to `http://127.0.0.1:8765` with the token
`wl2_demo_token` (switch on "Allow an unencrypted connection"):

```bash
cd packages/wavelog_mock && dart run bin/serve.dart
```

The end-to-end test uses the same mock: `cd app && flutter test integration_test -d macos`.

See [CONTRIBUTING.md](CONTRIBUTING.md).

## How Tideline compares

Several good tools already exist, and Tideline aims to complement them rather than clone them. The descriptions
below are based on each project's public description as of October 2026; corrections are welcome.

| | Tideline | Wavelog Mobile | DA6IT Wavelog Offline Logger | CloudLogOffline | HAMRS |
|---|---|---|---|---|---|
| Platforms | iOS, iPadOS, Android, macOS, Windows | Android | Desktop | Mobile (Qt) | — |
| Licence | MIT | Open source (Flutter) | — | Open source (Qt) | Proprietary |
| Wavelog sync | API v2 | Yes | Yes | Cloudlog-compatible API | No |
| Offline logging | Offline-first | Offline queue | Offline-first | Yes | Yes |
| Visible sync conflicts | Per-QSO state + journal | — | Yes | — | n/a |
| WSJT-X integration | Later (desktop) | — | Yes (merge) | — | — |
| Contest mode | Yes (v0.2) | Yes | — | — | — |
| POTA / SOTA | Yes (v0.3, offline packs) | Yes | — | — | Yes (portable focus) |
| Device-to-device sync without internet | Later | — | — | — | — |

"—" means we haven't verified it, not that the feature is missing. Please open an issue if something is wrong.

## Documentation

- [User manual](docs/manual/en/index.md) · [Handbuch (Deutsch)](docs/manual/de/index.md)
- [Architecture](docs/architecture/overview.md) and [decision records](docs/adr/)
- [Wavelog API notes](docs/architecture/wavelog-api.md)
- [Security](docs/security/threat-model.md) · [Privacy](PRIVACY.md) · [Security policy](SECURITY.md)
- [Design system](docs/design/design-system.md) · [Accessibility](docs/design/accessibility.md)
- [Translating](docs/translating.md) · [Releasing](docs/release.md) · [Roadmap](docs/roadmap.md)

## Licence

[MIT](LICENSE) © 2026 Jörg Holzapfel (DO1HOZ) and contributors.

DXCC prefix data: AD1C's country files (country-files.com), used under their licence terms (bundled from v0.1).
