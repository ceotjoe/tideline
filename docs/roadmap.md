# Roadmap

The milestones from the Phase 0 plan. Each phase ends with a summary and the maintainer's approval.

| Phase | Milestone | Status |
|---|---|---|
| 0 | Research and plan | done |
| 1 | M1 Foundation | done |
| 2 | M2 MVP (v0.1) | done |
| 3 | M3 Contest mode (v0.2) | done, approved 2026-10-03 |
| 4 | M4 Activations and reference packs (v0.3) | done, approved 2026-10-04 |
| 5 | M5 First TestFlight build, then FLE, field modes, multi-account UI, store releases (v0.4 → v1.0) | release plan written, awaiting approval |
| — | Device-to-device sync, WSJT-X listener, desktop extras, iPad drag and drop, Android background sync | later |

## Phase 3 scope

**Contest mode:**
- Contest definitions as data files, with a bundled set.
- Fast entry, keyboard and touch.
- Serial numbers that never repeat.
- Dupe rules.
- Super check partial and call history from a user-downloaded MASTER.SCP.
- Live rates and multipliers.
- Editing without leaving contest mode.
- Cabrillo export.
- Wavelog 3.2 contest-session sync.

**Worked-before index** pulled from the user's Wavelog log.

**Frequency entry improvement (requested 2026-10-02):**
- Replace the fixed "MHz" suffix with a live interpretation under the field, for example "14.205 MHz · 20 m".
- Read whole numbers as kHz whenever that hits an amateur band and MHz doesn't. Then `472` (630 m), `136` (2200 m) and
  `1840` work, while `7`, `50` and `144` stay MHz.
- Logic: `Frequency.parseUserInput` in `packages/tideline_domain/lib/src/values/frequency.dart`. UI: the frequency field
  in `app/lib/src/features/log/qso_entry_form.dart`. Contest entry should use the same field.

## Phase 3 plan

Design: [ADR 0018](adr/0018-contest-definitions-as-data.md) and [contest-definitions.md](architecture/contest-definitions.md).

| Step | Work | Package(s) |
|---|---|---|
| 3.1 | Frequency entry: kHz/MHz heuristic, live interpretation, reusable field | domain, app |
| 3.2 | Contest domain: definition parser, predicates, dupe check, points/multipliers, WPX prefix, rates | domain |
| 3.3 | Cabrillo 3.0 writer | adif |
| 3.4 | MASTER.SCP parser, super check partial and N+1 matching | domain |
| 3.5 | Wavelog client: contest catalog, `/contest` CRUD, ADIF pull; mock server support | wavelog_client, wavelog_mock |
| 3.6 | Bundled contest definitions | app assets |
| 3.7 | Data: definition loader, contest sessions, atomic serial allocation, SCP store, worked-before index | data |
| 3.8 | Sync: contest-session create/link with reconcile; worked-before pull | data |
| 3.9 | Contest mode UI: session setup, dense fast entry, dupe/SCP/worked-before hints, rates and multipliers, inline edit, Cabrillo export, commands | app |
| 3.10 | Goldens, accessibility checks, manual (EN/DE), CHANGELOG, threat model, PRIVACY.md | all |

## Phase 4 scope

**Reference packs** (user-initiated downloads, see [ADR 0013](adr/0013-reference-data-licensing.md) and
[ADR 0021](adr/0021-reference-packs-and-activations.md)):
- SOTA summits, POTA parks and WWFF references, each downloaded on request from the official file.
- Pack metadata (source, hash, fetch date, licence note) and age shown in settings; delete and update per pack.
- Offline search by reference, name, region and distance from the grid square.

**Activations:**
- An activation session ties a program and reference to a station profile, a grid square and a start time.
- QSOs logged in a session carry `MY_SOTA_REF` / `MY_POTA_REF` / `MY_WWFF_REF` (and `MY_SIG` for others).
- Progress toward validity, with a text equivalent: POTA 10 QSOs per UTC day, SOTA 4, WWFF 44.
- Park-to-park and summit-to-summit: the other station's reference is entered per QSO.
- Activation list, resume and end; ADIF export of one activation.
- Portable layout: large controls, reduced chrome, battery-friendly (no polling).

**Not in Phase 4:** spotting, FLE, multi-account UI (Phase 5).

## Phase 4 plan

| Step | Work | Package(s) |
|---|---|---|
| 4.1 | Verify formats and rules; ADR 0021; record in `wavelog-api.md`-style notes | docs |
| 4.2 | Domain: `ProgramReference`, per-program CSV parsers (strict, streaming), validity rules, distance search | domain |
| 4.3 | Data: `program_references` and `reference_packs` store, atomic pack replace, search queries, migration | data |
| 4.4 | Download service generalised from `scp_download.dart` (https only, redirects, per-pack size cap, streaming parse) | app |
| 4.5 | Activation domain and repository: session lifecycle, `activations` table, progress per UTC day | domain, data |
| 4.6 | Sync: `MY_*_REF` and `SIG` fields in the Wavelog payload; verify field names against the API docs | data, wavelog_client, wavelog_mock |
| 4.7 | UI: pack settings, reference picker, activation setup, entry with progress and P2P/S2S | app |
| 4.8 | Goldens, accessibility, manual EN/DE (`activations.md`), CHANGELOG, threat model T10, PRIVACY.md | all |

## Phase 5 scope

**First: a build the maintainer can test on devices.** Phase 5 starts with TestFlight (iOS and iPadOS), because the
hand tests that remain (VoiceOver, TalkBack, a real contest run, a real activation) need an installable build. The
reasoning and the verified facts are in [ADR 0022](adr/0022-testflight-first-distribution.md). The feature work (FLE,
field modes, multi-account UI) and the v1.0 store releases follow after the first test round, each with its own scope
proposal.

## Phase 5 plan

| Step | Work | Needs from the maintainer |
|---|---|---|
| 5.1 | **Release readiness (iOS).** Done 2026-10-04: `PrivacyInfo.xcprivacy` (no tracking, no collection, file timestamps and disk space for the bundled SQLite), version 0.3.0+1 with tests that keep it in step, CHANGELOG section 0.3.0, `CFBundleLocalizations` and a German Face ID text, an unsigned release build checked. Not done: the signed archive and the install on a real iPhone and iPad (needs the app record and signing in the maintainer's account, see `docs/release.md`). Export compliance stays a per-build answer in App Store Connect (ADR 0022). | App record in App Store Connect; signed archive on a device |
| 5.2 | **Getting past onboarding.** Decided: option A, a demo Wavelog server with a limited token in the review notes. No app change. | The demo server and token |
| 5.3 | **Runbook and test checklist.** Done 2026-10-04: [testflight.md](testing/testflight.md) (checklist, beta description and What to Test in EN and DE). Open: the app record and the beta texts in App Store Connect. Original scope: `docs/release.md` first-build section (done), `docs/testing/testflight.md` with what to test (VoiceOver, TalkBack later, contest, activation, offline, sync problems) and how to report. App Store Connect text for the beta description (EN, DE). | App record in App Store Connect |
| 5.3b | **Android for TalkBack.** Runbook written 2026-10-04 (`docs/release.md`), AAB build checked, Play account exists. Open: the upload key, the Play app record and content forms, the first internal release. Original scope: A signed release APK for `adb install` (upload key, `key.properties`), then a Play Console account, the internal track and, if the account needs it, the closed test of 12 testers for 14 days. | Play Console account, upload key |
| 5.3c | **macOS preparation.** Done 2026-10-04 except signing and upload: privacy manifest, category, languages, local-network text, export options, runbook and the keychain check list in `docs/release.md`. | Signed archive and a first run |
| 5.4 | **Automate the upload.** CI job on a manual trigger: build number from the run number, signing, upload with an App Store Connect API key (secrets documented in `docs/release.md`). | API key as repository secrets |
| 5.5 | **First test round.** Triage findings, fix, upload the next build. | Test results |
| 5.6+ | FLE, field modes (glove, battery saver), multi-account UI → v0.4; store listing and release for v1.0. Scope proposals after 5.5. | |

### What the check of 2026-10-04 found
- `flutter build ios --release --no-codesign` works (29.8 MB, minimum iOS 16.0).
- The plugins `file_picker`, `flutter_secure_storage`, `connectivity_plus`, `local_auth` and Flutter itself ship privacy
  manifests. `sqlite3mc.framework` does not. It imports `stat`, `fstat`, `lstat`, `utimes` and `futimes` (the "file
  timestamp" category) and `statfs` and `fstatfs` (the "disk space" category). The app's own manifest has to declare
  them with a reason Apple accepts. For file timestamps `C617.1` (files inside the app's container) fits; for disk space
  I have not found a reason that clearly fits SQLite's use, so 5.1 verifies it with Xcode's privacy report and Apple's
  list instead of guessing.
- Encryption: HTTPS is exempt as OS-provided. The app's own encryption (SQLite3MultipleCiphers with ChaCha20, backups with
  Argon2id and XChaCha20-Poly1305) is for the maintainer to classify. I am not giving a legal answer.
- Without an account the app always shows onboarding. Internal testers use the maintainer's server; Beta App Review for
  external testers needs a way in.

### Decision for 5.2: how do testers and reviewers get past onboarding?
- **A. A demo Wavelog server (recommended first).** The maintainer runs or picks a Wavelog instance and a limited token
  for reviewers, entered in the review notes. No app change. Works for TestFlight and later for App Review.
- **B. "Try without a server".** Log locally with no account; QSOs are kept until an account is added. It suits an
  "offline logger" and removes the review problem for good. It is a feature: QSOs belong to an account today, so it
  needs a local account, a data-model decision and an ADR.
