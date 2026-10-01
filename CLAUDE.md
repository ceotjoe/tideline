# CLAUDE.md — standing rules for Tideline

Tideline is "the offline logger for Wavelog": an MIT-licensed Flutter app for amateur radio operators.
Maintainer: DO1HOZ / Jörg. Targets: iOS, iPadOS, Android, macOS, Windows (Linux is scaffolded but unofficial).

These rules apply to every session. If something here conflicts with what you find in docs, source or on a platform,
**tell the maintainer instead of guessing**.

## Workflow
- Work in phases. Stop after each phase, summarise what was done and verified and what comes next, and wait for approval.
- Small, reviewable commits using Conventional Commits. Semantic Versioning for releases.
- Do not invent Wavelog endpoints, fields or scopes. Verify them in https://docs.wavelog.org/developer/api-v2/ or the
  source on github.com/wavelog/wavelog, and record the result in `docs/architecture/wavelog-api.md`.
- Every significant decision gets an ADR in `docs/adr/NNNN-title.md`.

## Repository layout (Dart pub workspace)
- `app/`: the Flutter app (presentation + platform adapters only).
- `packages/tideline_domain`: pure Dart. Entities, value objects, the sync state machine, rule engines and ports.
- `packages/tideline_adif`: pure Dart. Strict ADIF 3.1.x parser/writer and the Cabrillo writer.
- `packages/wavelog_client`: pure Dart. Wavelog API v2 client.
- `packages/tideline_data`: drift database, migrations, repositories and the sync engine.
- `packages/wavelog_mock`: mock Wavelog v2 server and fixtures. CI never talks to a real Wavelog.

## Architecture rules
- Layers: presentation → domain ← data. The domain imports neither Flutter nor drift nor http.
- Sync logic must be unit-testable without Flutter.
- State: Riverpod 3 (no experimental offline-persistence or mutation APIs). Navigation: go_router.
- Constructors use the Dart 3.13 `new` syntax (`const new({super.key})`), enforced by the linter.
- Use ADIF 3.1.x field names for the internal data model so import/export is lossless. Unknown ADIF fields go to `adif_extra`.
- Data model rules from day one, needed for device-to-device sync:
  - Every row has a UUID primary key.
  - Every row has an HLC timestamp, an origin device id and a tombstone (soft delete).
  - Contest serials are allocated from `serial_allocations` and never reused.
- Every user-facing command goes through the command registry, so its shortcuts and overlay entry come from there.

## Offline-first rules (non-negotiable)
- The local database is the single source of truth for the UI. The UI reads DB streams.
- Every write is a local transaction first. Network calls never block logging.
- Sync is a separate process: resumable, idempotent and journaled.
  - Triggers are app foreground, connectivity regained (followed by a reachability probe) and manual "Sync now".
- Never promise background sync where the OS doesn't guarantee it (iOS).
- QSO times are always UTC. ADIF data stays in ADIF formats. Locale formatting is presentation-only, and code must make
  the difference explicit (`UtcDateTime` vs display formatting).
- Handle partial uploads, timeouts, server duplicates, rejects, revoked tokens, too-old servers and clock skew.
- Wavelog has no client-side QSO id. Idempotency works through:
  - single POSTs;
  - a reconcile query on the server dupe tuple (call + minute + band + mode + station) before any retry.
  See ADR 0008.

## Security rules
- API tokens only in the platform secure store. Never in prefs, logs, backups or crash output.
- Local DB encrypted at rest (SQLite3MultipleCiphers); the key lives in the secure store.
- TLS:
  - HTTPS by default.
  - Self-signed certificates only via explicit trust-on-first-use pinning, shown with a clear warning.
  - Never offer "disable TLS validation".
  - Plain HTTP only for private-LAN hosts, behind a warned opt-in.
- Treat all external input as untrusted: ADIF, API responses, QR payloads, peer data, reference packs.
  - Parse strictly.
  - Fuzz the ADIF parser.
- No telemetry, analytics, ads or trackers. Network access only to:
  - the user's Wavelog servers;
  - user-initiated reference-pack downloads, documented in `PRIVACY.md`.
- Redact tokens and personal data in logs.
- Update `docs/security/threat-model.md` whenever the attack surface changes.
- Keep dependencies minimal and pinned via the lockfile.

## i18n rules
- No hard-coded user-facing strings. Everything goes in ARB files (`app/lib/l10n/arb/`), and a test enforces this.
- Ship EN + DE. Keep RTL working; it is tested with the pseudo-locale.
- The language can be chosen in-app, independent of the system language.

## Accessibility rules (WCAG 2.2 AA minimum)
- Theme contrast is verified by tests, never by eye.
- Touch targets are at least 48×48 dp; glove mode makes them larger.
- Never use colour alone; status always pairs an icon with text. The tide gauge always has a numeric/text equivalent.
- Meaningful semantics labels throughout. Callsigns are read letter by letter.
- 200% text scaling without broken layouts. Respect reduce-motion; all animations are optional.
- Full keyboard navigation with visible focus.
- Widget tests include `meetsGuideline` checks.

## Design rules
- Direction: **"Low Tide"**: soft seafoam/sand, generous whitespace, rounded shapes, and a wave-horizon tide gauge.
  Contest mode uses a dense variant of the same tokens.
- All colours, type, spacing, radii and motion come from the tokens in `app/lib/src/design/`. No ad-hoc colours.
- Themes: light, dark, sunlight (maximum contrast), night red, all derived from the same tokens.
- Layouts are driven by window size classes, never by device type. Phone, tablet portrait and tablet landscape are
  each first-class, and rotating or resizing never loses entered data.

## Definition of Done (every feature)
1. Code + tests pass (`tool/test_all.sh`), `dart analyze --fatal-infos` is clean, and `dart format` is clean.
2. No hard-coded strings (the l10n test passes); EN + DE strings exist.
3. Accessibility checks pass (guideline matchers, contrast test).
4. Phone, tablet-portrait and tablet-landscape layouts are covered by goldens for key screens.
5. Updated as needed: manual (`docs/manual/en` + `de`), README and `CHANGELOG.md`.
6. An ADR is written if a decision was made. The threat model is updated if the attack surface changed.

## Useful commands
- `flutter pub get`: resolve the whole workspace.
- `dart analyze --fatal-infos`: analyse everything.
- `tool/test_all.sh`: run all tests.
- `dart run build_runner build -d` (inside `packages/tideline_data` or `app`): run code generation.
- `flutter gen-l10n` (inside `app`): regenerate localizations.
