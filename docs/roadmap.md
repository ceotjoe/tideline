# Roadmap

The milestones from the Phase 0 plan. Each phase ends with a summary and the maintainer's approval.

| Phase | Milestone | Status |
|---|---|---|
| 0 | Research and plan | done |
| 1 | M1 Foundation | done |
| 2 | M2 MVP (v0.1) | done |
| 3 | M3 Contest mode (v0.2) | done, approved 2026-10-03 |
| 4 | M4 Activations and reference packs (v0.3) | plan written, awaiting approval of the plan |
| 5 | M5 FLE, field modes, multi-account UI, store releases (v0.4 → v1.0) | planned |
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
