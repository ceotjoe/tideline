# Bundled contest definitions

One JSON file per contest, file name = `id` + `.json`. They are loaded into `contest_definitions` (`builtin = true`)
and validated by the strict parser `ContestDefinition.parse` (see
[docs/architecture/contest-definitions.md](../../../docs/architecture/contest-definitions.md) and
[ADR 0018](../../../docs/adr/0018-contest-definitions-as-data.md)). `app/test/contest/bundled_definitions_test.dart`
parses every file, checks names and ids, and scores hand-checked logs.

The live score is a claimed-score estimate. The sponsor's log check is authoritative.

## Files, sources and verification

Each file was checked against the sponsor's current published rules on **2026-10-02**. Check the rules again before a
contest and bump `version` when they change.

| File | Contest | Source (checked 2026-10-02) | Rules |
|---|---|---|---|
| `cq-ww-ssb`, `cq-ww-cw` | CQ World Wide DX | <http://www.cqww.com/rules/> | 2026 |
| `cq-wpx-ssb`, `cq-wpx-cw` | CQ WPX | <http://cqwpx.com/rules/> | 2026 |
| `arrl-dx-cw`, `arrl-dx-ssb` | ARRL International DX | <https://contests.arrl.org/ContestRules/DX-Rules.pdf> | Version 2.0, 04 Jan 2024 |
| `iaru-hf` | IARU HF World Championship | <https://contests.arrl.org/ContestRules/IARU-HF-Rules.pdf> | Version 1.21 |
| `darc-wag` | Worked All Germany | <https://www.darc.de/der-club/referate/conteste/wag-contest/en/rules/> and <https://www.darc.de/der-club/referate/conteste/wag-contest/regeln/> | 2026 page (multiplier change "new from 2024") |
| `generic-serial` | Generic | none | RST + serial, 14 bands from 160 m to 70 cm, CW/PHONE/DIGI, dupe per band and mode category, score = QSO count. No ADIF contest id, no Cabrillo. |
| `generic-exchange` | Generic | none | Same with RST + free text exchange. |

How the sources were read: the ARRL PDFs were converted to text and read in full. The CQ and DARC pages were read
through a page summariser, which quotes the relevant rule text but is not the page itself; the values below (points,
exchange, multiplier scope) were cross-checked between two separate fetches of each page.

### What each file encodes

- **CQ WW (SSB and CW):** bands 160-10 m; RS(T) + CQ zone. Points: 0 same country (the QSO still counts for zone and
  country), 1 same continent other country, 2 North America to North America other country, 3 other continents.
  Multipliers: CQ zone and country, each per band. Dupe: once per band. SSB and CW are separate contests.
- **CQ WPX (SSB and CW):** bands 160-10 m; RS(T) + serial. Points: other continent 3 (6 on 160/80/40 m), same continent
  other country 1 (2 on low bands), North America to North America other country 2 (4 on low bands), same country 1 on
  any band. Multiplier: each prefix once per contest. Dupe: once per band.
- **ARRL DX (CW and Phone):** bands 160-10 m. W/VE (DXCC 291 and 1) send RST + state/province and receive RST + power;
  everyone else sends RST + power and receives RST + state/province. Only W/VE to DX counts, 3 points per QSO. **Alaska
  (6) and Hawaii (110) take part as DX stations** (rules 2.3 and 5.2.3.1), so they send power, and a W/VE station counts
  them as DXCC entities. W/VE multiplier: DXCC entities other than USA and Canada, per band. DX multiplier: state, DC,
  province or territory, per band. This is written with `myDxcc` / `theirDxccNot: [291, 1]`.
- **IARU HF:** bands 160-10 m, CW and phone in one contest. RS(T) + ITU zone. Points: 1 for the same ITU zone
  (`sameItuZone`, which includes the same zone on another continent), 3 same continent other zone, 5 other continent and
  zone. Multiplier: ITU zone **per band, not per mode** (rule 5.2.1). Dupe: once per band and mode.
- **WAG:** bands 80-10 m, CW and SSB in one contest. Non-DL stations send RST + serial, DL stations RST + DOK. Points:
  DL to DL 1, DL to Europe 3, DL to DX 5, non-DL to DL 3. DL multiplier: DXCC/WAE entity per band and mode; non-DL
  multiplier: DARC district (the first letter of the DOK) per band and mode; `NM` is no multiplier. A DL station
  receives a serial from non-DL stations and a DOK from DL stations (`when` on the received elements).

### Discrepancies fixed in this check

| File | Was | Now | Rule |
|---|---|---|---|
| `arrl-dx-*` | list of 48 North American DXCC entities, two "overseas" and two "NA" multiplier pairs | `theirDxccNot` / `myDxccNot: [291, 1]`, one DXCC and one state multiplier; Hawaii (110) now counts as a DX multiplier like Alaska | ARRL DX 2.3, 5.2.2, 5.2.3.1 |
| `iaru-hf` | "same DXCC entity" stood in for "same ITU zone" | `sameItuZone` | IARU 5.1.1, 5.1.3 |
| `iaru-hf` | zone multiplier per band and mode | per band | IARU 5.2.1 |
| `darc-wag` | DL to Europe and DL to DX both 3 points | 3 and 5 | WAG points |
| `darc-wag` | multiplier per band, the whole DOK as non-DL multiplier | per band and mode; DARC district (first DOK letter), `NM` excluded | WAG multipliers |
| `darc-wag` | DL stations had serial and DOK both optional | serial required for non-DL, DOK for DL, per `when` | WAG exchange |

CQ WW and CQ WPX needed no change.

### What could not be verified or is approximated

- **CQ WW countries:** the rules use the DXCC list *plus the WAE list and IG9/IH9* for the country multiplier (and for
  "same country"). The definitions use DXCC entities only, so WAE-only countries (for example Sicily or the Balearics)
  are not separate multipliers and QSOs with them are scored as the DXCC entity. Maritime mobile stations count only for
  the zone multiplier; this is not modelled.
- **CQ WPX prefixes:** the rules say that /A, /E, /J, /P, maritime mobile and other licence-class identifiers do not
  count as prefixes. `WpxPrefix` ignores /P, /M, /MM, /AM, /QRP, /A, /LH, /E, /J, /AE and /AG and uses the home prefix.
- **ARRL DX:** W/VE to W/VE and DX to DX contacts are not valid in the real contest. The definition cannot exclude a
  QSO, so they score 0 points and credit no multiplier. A station whose DXCC is unknown scores 0 points and credits no
  multiplier (a negated list needs a known value). Labrador is not distinguished from the rest of Newfoundland
  (`rcvd:state` counts the exchange value, so a logged `LB` counts correctly).
- **IARU HF:** IARU member society HQ stations (and AC, R1, R2, R3) send an abbreviation instead of a zone. The
  `ituZone` element rejects it, so these stations cannot be logged with the full exchange and their 1 point, and the HQ
  and official multipliers, are missing. Use the generic exchange or an imported definition for HQ stations.
  `sameItuZone` needs my ITU zone in the station profile, otherwise the zone rule is skipped and the continent rules
  apply.
- **WAG:** the DL multiplier uses DXCC entities. DARC uses the DXCC/WAE list plus IG9/IH9; WAE-only entities are not
  distinguished. Whether Germany itself counts as a multiplier for DL stations is not stated in the rules text I read;
  the definition does not count it. "Europe" for the 3-point rule is the continent EU of the DXCC resolver. DOKs that do
  not start with a letter (special DOKs) give no district multiplier. Foreign stations that did not receive a number
  send "000", which the `serial` element rejects (range 1 to 99999); log those QSOs with serial 1 or leave the field
  optional in an imported definition. The contest-free JOTA segments are not modelled. Non-DL to non-DL contacts are not
  valid and the definition requires a DOK for them.
- **Dupes:** "per band and mode" is `band` + `modeCategory` where a contest counts CW and phone separately. The DARC and
  IARU rules say "per band and mode"; this treats USB and LSB as the same mode, which they are.

## Writing your own

A definition is a JSON file validated by the same strict parser; anything it does not understand is rejected. Start from
one of these files and read
[docs/architecture/contest-definitions.md](../../../docs/architecture/contest-definitions.md) for every key, exchange
element, predicate and multiplier source. Note that the file name only needs to equal the `id` for bundled files.
