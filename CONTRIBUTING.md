# Contributing to Tideline

Thanks for helping. Tideline is built by and for radio amateurs. Contributions of all kinds are welcome:
code, translations, documentation, testing in the field, contest definitions and bug reports.

## Ground rules

- Read [CLAUDE.md](CLAUDE.md). It holds the project's standing architecture, offline-first, security,
  i18n and accessibility rules, and the Definition of Done. They apply to human contributors too.
- Be kind. See the [Code of Conduct](CODE_OF_CONDUCT.md).
- Security issues go through [SECURITY.md](SECURITY.md), never through public issues.

## Getting started

Requirements:
- Flutter **3.47.2** (stable), which includes Dart 3.13.
- Xcode (for iOS/macOS) and/or Android Studio, or Visual Studio (for Windows).

Then:

```bash
flutter pub get             # resolves the whole workspace
dart analyze --fatal-infos  # must report no issues
tool/test_all.sh            # runs every package's tests
cd app && flutter run
```

## Workflow

1. Open an issue first for anything bigger than a small fix, so we can agree on the approach.
2. Branch from `main`. Use [Conventional Commits](https://www.conventionalcommits.org/)
   (`feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `ci:`, `chore:`).
3. Keep pull requests small and focused.
4. A PR is ready when it meets the Definition of Done:
   - tests pass, the analyzer is clean and code is formatted;
   - no hard-coded user-facing strings (EN + DE ARB entries added);
   - accessibility checks pass, with goldens for phone / tablet portrait / tablet landscape where screens change;
   - manual, README and `CHANGELOG.md` (under *Unreleased*) updated;
   - an ADR in `docs/adr/` if you made a design decision.

## Where things live

| Path | What |
|---|---|
| `app/` | Flutter UI and platform adapters |
| `packages/tideline_domain` | Pure-Dart domain model and sync state machine |
| `packages/tideline_adif` | ADIF / Cabrillo |
| `packages/wavelog_client` | Wavelog API v2 client |
| `packages/tideline_data` | Database, repositories and sync engine |
| `packages/wavelog_mock` | Mock Wavelog server for tests |
| `docs/` | Manual, architecture, ADRs, security and design system |

## Translations

See [docs/translating.md](docs/translating.md). No Dart knowledge is needed.

## Licence

By contributing you agree that your contributions are licensed under the [MIT License](LICENSE).
