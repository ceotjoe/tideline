# Bundled contest definitions

One JSON file per contest, file name = `id` + `.json`. They are loaded into `contest_definitions` (`builtin = true`)
and validated by the strict parser `ContestDefinition.parse` (see
[docs/architecture/contest-definitions.md](../../../docs/architecture/contest-definitions.md) and
[ADR 0018](../../../docs/adr/0018-contest-definitions-as-data.md)). `app/test/contest/bundled_definitions_test.dart`
parses every file, checks names and ids, and scores hand-checked logs.

The live score is a claimed-score estimate. The sponsor's log check is authoritative.

## Files, rule year and known approximations

Rules followed: the published rules as of the 2025/2026 contest seasons, from the author's knowledge, not re-verified
against the sponsors' sites at the time of writing. Check each sponsor's current rules before a contest and bump
`version` when they change.

| File | Contest | Notes |
|---|---|---|
| `cq-ww-ssb`, `cq-ww-cw` | CQ World Wide DX | RST + CQ zone. 0 points same country (multipliers still count), 1 same continent, 2 NA to NA other country, 3 other continents. Multipliers: zone and country per band. Exact. |
| `cq-wpx-ssb`, `cq-wpx-cw` | CQ WPX | RST + serial. Other continent 3 (6 on 160/80/40 m), same continent other country 1 (2 on low bands), NA to NA other country 2 (4 on low bands), same country 1 on any band. Prefix multiplier once per contest. Same-country QSOs have scored 1 point in the WPX rules for years; I believe this is unchanged for 2023 and later but did not re-verify it. |
| `arrl-dx-cw`, `arrl-dx-ssb` | ARRL International DX | W/VE (DXCC 291, 1) send RST + state/province and receive RST + power. Everyone else sends RST + power and receives RST + state. 3 points per QSO. Alaska and Hawaii are DX. |
| `iaru-hf` | IARU HF World Championship | RST + ITU zone, CW and phone, ITU zone multiplier per band and mode category. See approximations. |
| `darc-wag` | Worked All Germany | DL stations send RST + DOK, others RST + serial. See approximations. |
| `generic-serial` | Generic | RST + serial, 14 bands from 160 m to 70 cm, CW/PHONE/DIGI, dupe per band and mode category, score = QSO count. No ADIF contest id, no Cabrillo. |
| `generic-exchange` | Generic | Same with RST + free text exchange. |

### Approximations (parser limits)

- **ARRL DX, W/VE to W/VE and DX to DX:** these contacts do not count in the real contest. The definition cannot exclude
  a QSO, so they score 0 points. Multipliers are guarded by predicates so they do not count either. "Not W/VE" cannot be
  written, so the DX side is expressed as "continent is not NA" plus an explicit list of North American DXCC entities
  other than 291 and 1. A new NA entity would need adding to that list (`dxcc-na`, `state-na` in the files).
  A DX station whose DXCC is unknown scores 3 points against a W/VE station.
- **IARU HF, "same ITU zone":** there is no zone predicate, so "same DXCC entity" stands in for "same ITU zone" (1
  point). Same-country QSOs across ITU zones (USA, Canada, Russia, Brazil, Australia, China) are under-scored (1
  instead of 3), and different-country QSOs inside one zone are over-scored (3 instead of 1). HQ stations send a society
  abbreviation instead of a zone and cannot be entered (the `ituZone` element rejects it), and the HQ multiplier is
  missing. Use the generic exchange or an imported definition for HQ stations.
- **WAG:** points are 3 for DL to DX and DX to DL, 1 for DL to DL, 0 for DX to DX (the brief this file was written
  from; the official DARC rules should be compared before the next WAG, since I am not certain whether DL to European
  DX is scored differently). DL stations receive a serial from foreign stations and a DOK from DL stations, but an
  exchange cannot vary with the other station, so a DL station gets both elements as optional. DL stations count DXCC
  entities per band; DARC's WAE entities (which differ from DXCC) are not distinguished. Non-DL stations count DOKs per
  band.
- **Dupes:** "per band and mode" is `band` + `modeCategory` where a contest counts CW and phone separately.

## Writing your own

A definition is a JSON file validated by the same strict parser; anything it does not understand is rejected. Start from
one of these files and read
[docs/architecture/contest-definitions.md](../../../docs/architecture/contest-definitions.md) for every key, exchange
element, predicate and multiplier source. Note that the file name only needs to equal the `id` for bundled files.
