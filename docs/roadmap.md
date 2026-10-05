# Roadmap

The milestones from the Phase 0 plan. Each phase ends with a summary and the maintainer's approval.

| Phase | Milestone | Status |
|---|---|---|
| 0 | Research and plan | done |
| 1 | M1 Foundation | done |
| 2 | M2 MVP (v0.1) | done |
| 3 | M3 Contest mode (v0.2) | done, approved 2026-10-03 |
| 4 | M4 Activations and reference packs (v0.3) | done, approved 2026-10-04 |
| 5 | M5 First TestFlight build and release automation (FLE, field modes and multi-account UI moved to Phase 6) | done, approved 2026-10-05 |
| 6 | M6 Tester feedback and v0.4 (6.1–6.8) | done, shipped as 0.4.0 |
| — | Store listing and release for v1.0 | open |
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
| 5.5 | **First test round.** Build 2 (with the local-network text) reported fine by the maintainer on 2026-10-04; no findings to fix so far. Original scope: Triage findings, fix, upload the next build. | Test results |
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

## Phase 5 scope proposal: v0.4 features (awaiting the maintainer's decisions)

Written 2026-10-04 after build 2 was reported fine. Nothing here is built yet. Recommended order: multi-account UI,
then FLE, then field modes.

### A. Multi-account UI (smallest; the data model already has accounts)
Today one account is active and `accountId` is on every QSO, contest session and activation, so the model needs no change.
- Add an account (the onboarding flow, reused), switch the active account from the log screen's app bar, rename, remove
  (token deleted from the secure store, local QSOs kept or exported first, with a clear choice).
- Per account: stations, sync state and journal, worked-before index, default station. The tide gauge shows the sum with
  a per-account breakdown in text.
- One account is active for logging at a time; there is no per-QSO account choice (decision below).

### B. FLE: typing QSOs as shorthand
Fast Log Entry is a text shorthand that several programs share, in slightly different dialects: the original by DF3CB,
`FLEcli`, and **SimpleFLE in Wavelog**. Wavelog's documentation lists, for QSO lines, in this order: time (full `HHMM`
first, then deltas), callsign, optional reports, locator, SOTA/POTA/IOTA/WWFF reference (recognised by shape, POTA with
several references separated by commas), `@` operator, contest exchange (`,` sent and `.` received), `[]` QSL message and
`<>` comment; header lines set band and mode, date (`date`, `day +`) and a time-zone offset.
- **Proposal:** follow Wavelog's SimpleFLE (users sync there and it is documented), and read the classic core
  (`date`, `mycall`, band and mode lines, time fragments) too. Step 1 of the work verifies the grammar against the Wavelog
  source (`wavelog/wavelog`, SimpleFLE) and records it in `docs/architecture/fle.md`; nothing is assumed beyond the
  documentation until then.
- A pure Dart parser in `tideline_domain` with typed errors per line and a fuzz test. QSOs are previewed (a table with
  per-line problems as icon and text) before they are logged, and one confirmation logs them all in one local
  transaction. Times are UTC (a time-zone offset is shown explicitly).
- Works with activations (references and `MY_*` come from the running activation) and respects the dupe and band rules
  that the normal log has. Accessible as text input with an error list readable by VoiceOver.
- An ADR for the dialect and for how FLE meets contest mode (decision below).

### C. Field modes
There are already themes for sunlight and night, glove mode (larger targets), the reduced-motion setting and no
background work. Open question: what exactly should a "field mode" be? Candidates:
1. **One switch** that turns on glove mode, the sunlight theme and the battery saver at once.
2. **Battery saver:** stop the one-second clock timer on the entry form and the tide animation, no periodic work, longer
   sync backoff. Measurable on a device.
3. **Keep the screen on while logging** (needs a small plugin; an ADR and a threat-model line for the dependency).
4. **A location button** that fills the grid square from GPS (a location permission, `PRIVACY.md` and the store forms
   change; it is only used when pressed).

### D. Other open items from earlier phases
- A rules editor for activation counting (and checking the SOTA and WWFF windows against the programmes' rules).
- Two-fer activations (one activation at two references).
- An end-to-end test with the mock server for activations.
- Automating the uploads (step 5.4) once the API key and the Play service account exist.

### Decisions needed
1. Order and scope: A, B, C as above, or a different order?
2. Multi-account: a switcher with one active account (recommended), or choosing the account per QSO?
3. FLE: follow Wavelog's SimpleFLE (recommended)? Should FLE also work in contest mode, or only in the normal log?
4. Field modes: which of the four candidates do you want, and are GPS and a keep-awake plugin acceptable?
5. Which of D do you want before v0.4?


## Phase 6 plan: tester feedback and v0.4 (decided 2026-10-04, awaiting approval to start 6.1)

Written 2026-10-04 from six enhancement requests. It folds them into the v0.4 proposal above (A multi-account UI,
B FLE, C field modes). Nothing here is built yet.

### Requests

| # | Request | Where it lands |
|---|---|---|
| 1 | Numeric keyboard for numeric fields | 6.1 |
| 2 | Keyboard should be hideable (it covers the bottom navigation on the phone log screen) | 6.1 |
| 3 | Settings need more structure | 6.2 |
| 4 | Delete local QSOs that are already synced to Wavelog | 6.6 |
| 5 | Offline callsign directory from the Wavelog QSO history, with callsign notes | 6.5 |
| 6 | Mac and Windows: OS-agnostic navigation | 6.4 (scope to confirm) |

### Steps

| Step | Work | Release |
|---|---|---|
| 6.1 | **Input ergonomics.** Audit every field for its keyboard type (number or decimal for RST, power and serials; no autocorrect on callsigns). The keyboard covers the bottom bar on the phone log screen because `Scaffold` leaves `bottomNavigationBar` at the window bottom, and an iOS number pad has no Done key. Add a "Hide keyboard" action above the keyboard (48 dp, semantics label), dismiss on tap outside and on scroll drag. Do not lift the bar above the keyboard: ADR 0020 gives the form all the height. Tests: `viewInsets` on a phone, Hide works, the bar is tappable afterwards; same for the contest and activation screens. Amend ADR 0020. | v0.3.1 |
| 6.2 | **Settings structure.** A hub with grouped pages, each its own `go_router` route: Accounts and sync, Logging, Reference data (packs, SCP, contest definitions, worked-before), Appearance and accessibility, Security and backup, About. Search if still cluttered. Goldens, manual, ADR. Done before the other steps, which all add settings. | v0.3.1 |
| 6.3 | **Multi-account UI** (A above). | v0.4 |
| 6.4 | **Desktop navigation.** Decided: macOS and Windows use the navigation desktop software usually has, not the mobile look. A menu bar (native on macOS, in the window on Windows) with the commands from the registry, a sidebar or rail instead of a bottom bar, back by Esc or a back button, full Tab and focus navigation, Ctrl/Cmd via the registry, hover and right-click context menus. Layouts stay driven by size class and input mode, not by platform (ADR 0010). | v0.4 |
| 6.5 | **Callsign directory and notes.** First verify in the Wavelog docs and source whether API v2 has callsign notes; record it in `wavelog-api.md`. A `callsign_directory` table, derived and rebuildable like `worked_before`: name, QTH, grid, country, zones, IOTA from the latest QSO per call, from local QSOs and the server ADIF pull, with a size cap. Notes are a separate user-owned table (UUID, HLC, origin device, tombstone), in the encrypted backup; local-only if there is no API. The entry form shows a hit and the note beside the worked-before status and only suggests values. Third-party names are personal data: `PRIVACY.md`, threat model, ADR. | v0.4 |
| 6.6 | **Evict synced local QSOs.** An eviction, never a delete: a tombstone would sync as a delete. A distinct state and an ADR (CLAUDE.md requires tombstones for device sync). Eligible: synced, reconcile-confirmed on the dupe tuple, unchanged since. Pick by age or selection, preview, offer an ADIF export first. Directory and worked-before are filled first, so nothing is lost. Evicted QSOs must not re-import (test). Exclude QSOs that contest sessions or activations still reference. | v0.4 |
| 6.7 | **FLE** (B above). | v0.4 |
| 6.8 | **Field modes** (C above), including the keyboard behaviour of 6.1. | v0.4 |

_6.2 done 2026-10-04: [ADR 0023](adr/0023-settings-hub.md). The hub has four groups plus the shortcuts entry; the "Logging" group was not created because nothing belongs in it yet._

_6.1 done 2026-10-04 (`7f25482`)._

_6.8 done 2026-10-05: [ADR 0029](adr/0029-field-mode.md). One derived switch plus separate options, battery saver (no animation, minute clock, slower contest rates; the app has no sync backoff to change), keep screen on (`wakelock_plus`), no GPS button. Battery effect not measured._

_6.7 done 2026-10-04: [ADR 0028](adr/0028-fast-log-entry.md), grammar in [fle.md](architecture/fle.md). FLE is for the normal log and activations, not contest sessions (the maintainer did not answer; the recommendation was followed)._

_6.6 done 2026-10-04: [ADR 0027](adr/0027-evict-synced-qsos.md). Removal is a purge with a record, confirmed by a read-only listing of Wavelog; nothing is deleted there._

_6.5 done 2026-10-04: [ADR 0026](adr/0026-callsign-directory-and-notes.md); Wavelog API v2 has no callsign notes (verified), so notes are local only._

_6.4 done 2026-10-04: [ADR 0025](adr/0025-desktop-navigation.md). Not done: a minimum window size (native code per OS) and a two-pane settings view on wide windows._

_6.3 done 2026-10-04: [ADR 0024](adr/0024-multiple-accounts.md). Also fixed: removing an account with contest or activation data failed on the foreign keys (found while building 6.3)._

Every step follows the Definition of Done. Order: 6.1 and 6.2 as v0.3.1, then 6.3 to 6.8. 6.6 comes after 6.5.

### Decisions (maintainer, 2026-10-04)
1. Request 6: desktop-style navigation as in 6.4, not mobile-style.
2. 6.1 and 6.2 ship as v0.3.1.
3. Request 4: eviction only. Nothing is ever deleted on Wavelog; only local, already synced QSOs can be removed.
4. Request 5: local-only notes are acceptable if Wavelog has no notes API.
5. Request 5: a directory per account, with a merged lookup on the entry form.

## Phase 7 scope proposal: v1.0 (written 2026-10-05, awaiting the maintainer's decisions)

Nothing here is built yet. 1.0 means: installable from the stores on every official platform, the hand tests done, no
known data-loss or security findings, and the documentation current.

### A. Maintainer-side (I cannot do these; I can prepare texts and checklists)
- Hand tests from a TestFlight and Play internal build: VoiceOver, TalkBack, a real contest run, a real activation
  ([testflight.md](testing/testflight.md)).
- Play: first AAB by hand, app record and content forms, closed test (12 testers, 14 days) if the account needs it.
- Mac App Store: first run of the signed app, keychain check in the sandbox (data-protection keychain as fallback).
- Export classification follow-up questions in App Store Connect (key set to `true` on 2026-10-05).
- Store listings: privacy label ("Data Not Collected"), screenshots, descriptions EN/DE, age rating, support URL.
- Decide Microsoft Store versus direct MSIX; check the MSIX publisher against the certificate subject.
- App Review access: the in-app demo account of [ADR 0031](adr/0031-demo-account.md) replaces the hosted demo server.

### B. Work for me (proposed, each its own step and commit)
| Step | Work |
|---|---|
| 7.1 | **Release audit.** Check the Definition of Done for every 0.4.0 feature: manual EN/DE, threat model, `PRIVACY.md`, goldens for phone, tablet portrait and landscape, accessibility matchers. Fix gaps. |
| 7.2 | **Store texts.** Listing, What's New, privacy answers and screenshots plan in EN and DE under `docs/release/`, taken from `PRIVACY.md` so they stay true. |
| 7.3 | **Activation end-to-end test** against the mock (open item from Phase 4). |
| 7.4 | **Activation rules.** Verify the SOTA and WWFF counting windows against the programmes' rules and fix the default; decide whether the rules editor and two-fer wait for 1.1. |
| 7.5 | **Hardening pass.** ADIF fuzz run, token/log redaction check, dependency review against the lockfile, threat model refresh. |
| 7.6 | **Release candidate.** Version 1.0.0, CHANGELOG, tag, upload through the release workflow, one more test round. |

### C. Recommended for 1.1 or later
Rules editor, two-fer, a minimum desktop window size, two-pane settings, battery measurements, and everything under
"later" in the table above.

### Decisions needed
1. Is the scope in B right, or should the rules editor and two-fer be in 1.0?
2. Microsoft Store for 1.0, or direct MSIX only?
3. Is Linux unofficial at 1.0 (as in CLAUDE.md)?
