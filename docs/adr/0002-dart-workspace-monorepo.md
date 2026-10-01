# 0002. Dart pub workspace monorepo

- Status: accepted
- Date: 2026-10-01

## Context
- Sync logic, the ADIF parser and the Wavelog client must be testable, and the parser fuzzable, without Flutter.
- Dart supports native pub workspaces since 3.6; this project uses Dart 3.13. Melos is an extra tool to install and keep updated.

## Decision
- A single repository with a root `pubspec.yaml` that declares `workspace:` members:
  - `app/` (Flutter);
  - pure-Dart packages in `packages/`: `tideline_domain`, `tideline_adif`, `wavelog_client`, `tideline_data` and
    `wavelog_mock`.
- No melos. `tool/test_all.sh` runs the tests.

## Consequences
- **Pros:**
  - One lockfile, so dependency versions are consistent everywhere.
  - Package boundaries enforce the layering, because domain packages cannot import Flutter.
- **Cons:**
  - `tideline_data` uses drift, which needs the native sqlite3 library at test time. The sqlite3 package's build hooks
    provide it.
