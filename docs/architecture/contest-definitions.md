# Contest definitions

Contests are **data, not code** ([ADR 0018](../adr/0018-contest-definitions-as-data.md)). A definition is a JSON file.
The bundled set lives in `app/assets/contests/` (next to `assets/reference/cty.csv`) and is loaded into `contest_definitions` (with
`builtin = true`). Users can import their own files, which are validated with the same strict parser. Definitions are
untrusted input: unknown keys are rejected, sizes are bounded, and every field is validated.

The domain type is `ContestDefinition` (`packages/tideline_domain/lib/src/contest/`). The parser rejects a file it
does not fully understand rather than guessing.

## Example

```json
{
  "schema": 1,
  "id": "cq-ww-ssb",
  "version": 1,
  "name": "CQ World Wide DX Contest (SSB)",
  "cabrillo": "CQ-WW-SSB",
  "adif": "CQ-WW-SSB",
  "modes": ["PHONE"],
  "bands": ["160m", "80m", "40m", "20m", "15m", "10m"],
  "exchange": {
    "sent": [
      { "kind": "rst" },
      { "kind": "cqZone", "default": "{MY_CQ_ZONE}" }
    ],
    "rcvd": [
      { "kind": "rst" },
      { "kind": "cqZone" }
    ]
  },
  "dupe": { "per": ["band", "modeCategory"] },
  "points": [
    { "when": { "sameDxcc": true }, "points": 0 },
    { "when": { "sameContinent": false }, "points": 3 },
    { "when": { "myContinent": "NA", "theirContinent": "NA" }, "points": 2 },
    { "points": 1 }
  ],
  "multipliers": [
    { "id": "zone", "source": "rcvd:cqZone", "per": "band" },
    { "id": "country", "source": "dxcc", "per": "band" }
  ],
  "score": "pointsTimesMultipliers"
}
```

## Fields

Required keys: `schema`, `id`, `version`, `name`, `modes`, `bands`, `exchange`, `dupe`, `score`. The `points` field is required unless `score` is `qsos`. The `multipliers` field is optional (default empty). Both `modes` and `bands` must not be empty.

| Key | Type | Meaning |
|---|---|---|
| `schema` | int | Schema version. Only `1` is valid now. |
| `id` | string | Stable slug `[a-z0-9-]{1,64}`. Primary key in `contest_definitions`. |
| `version` | int ≥ 1 | Bumped when the rules change. A session keeps the version it started with. |
| `name` | string ≤ 120 | Display name. Not localised: contest names are proper names. |
| `cabrillo` | string? | Cabrillo `CONTEST:` value. Missing means Cabrillo export is not offered. |
| `adif` | string? | ADIF `CONTEST_ID` and Wavelog contest ADIF name. |
| `modes` | list | Mode categories allowed: `CW`, `PHONE`, `DIGI`. `PHONE` = SSB/AM/FM; `DIGI` = RTTY, FT8, PSK, … |
| `bands` | list | ADIF band names allowed. |
| `exchange.sent` / `exchange.rcvd` | list | Ordered exchange elements (see below). The order is the entry order and the Cabrillo column order. |
| `exchange.variants` | list? | Optional `[{ "when": {…}, "sent": […], "rcvd": […] }]`. The first variant whose `when` matches *my* station replaces `sent`/`rcvd` (for example, DL stations send a DOK in WAG). Only `my*` predicates are allowed here. |
| `dupe.per` | list | Keys making a contact unique besides the call: any of `band`, `mode`, `modeCategory`. `[]` = once per contest. |
| `points` | list | Ordered rules, **first match wins**. The last rule must have no `when`. |
| `multipliers` | list | Each `{id, source, per, when?}`. `per` is `band`, `bandMode` or `contest`. |
| `score` | string | `pointsTimesMultipliers`, `points` (no multipliers) or `qsos` (one per valid QSO). |

### Exchange element kinds

Each element maps to one ADIF field, which is how it is stored on the QSO (ADIF names, ADR 0016).

| `kind` | Sent field | Received field | Validation |
|---|---|---|---|
| `rst` | `RST_SENT` | `RST_RCVD` | `[1-5][1-9][1-9]?` (default `59`/`599` by mode) |
| `serial` | `STX` | `SRX` | integer 1–99999. Sent serials always come from `serial_allocations`. |
| `cqZone` | `STX_STRING` | `CQZ` | 1–40 |
| `ituZone` | `STX_STRING` | `ITUZ` | 1–90 |
| `grid` | `MY_GRIDSQUARE` | `GRIDSQUARE` | 4- or 6-character Maidenhead |
| `state` | `STX_STRING` | `STATE` | 1–3 letters |
| `section` | `STX_STRING` | `ARRL_SECT` | 1–4 letters |
| `dok` | `STX_STRING` | `DARC_DOK` | `[A-Z0-9]{1,6}` (letters and digits) |
| `power` | `TX_PWR` | `RX_PWR` | number or `KW`, `K`, `QRP`; Cabrillo writes it as given |
| `name` | `STX_STRING` | `NAME` | letters, ≤ 20 |
| `text` | `STX_STRING` | `SRX_STRING` | `[A-Z0-9/]{1,12}` |

An element may set `"label"` (an l10n key suffix matching `[a-z][a-zA-Z0-9]{0,31}`, e.g. `"label": "age"`), `"default"` (sent side only; never on `serial`; may use the
placeholders `{MY_CQ_ZONE}`, `{MY_ITU_ZONE}`, `{MY_GRID4}`, `{MY_STATE}`, `{MY_DOK}`, which come from the station
profile and session settings; a default without placeholders must itself be valid for its kind) and `"optional": true`.

**Exception:** when one exchange has two elements that store into `STX_STRING` (or `SRX_STRING`), they are joined with
a single space and split again on Cabrillo export. Each exchange may contain at most one `serial` per side. Two elements writing the same ADIF field on one side are rejected, except STX_STRING/SRX_STRING, which are joined.

A variant must set `sent` or `rcvd` or both.

**Normalization:** values are upper-cased and numbers lose leading zeros (`05` → `5`). Grids are normalised and must have 4 or 6 characters. The `name` kind accepts Unicode letters. The `power` kind accepts 1–99999, `KW`, `K` or `QRP`.

**Complete exchange copy:** if no element of a side uses `STX_STRING`/`SRX_STRING`, that field receives all given values of the side in order, space-separated (including report and serial). If any element uses it, no copy is made.

**Reading back from ADIF:** a shared string field (STX_STRING/SRX_STRING) is split on whitespace and assigned in order. A single element takes the whole string. Missing tokens become empty.

### Predicates (`when`)

An empty `when {}` is rejected. All listed keys must hold (AND). Unknown keys are a parse error. Predicate values may be a single value or a list.

| Key | Value | Holds when |
|---|---|---|
| `sameDxcc` | bool | My and their DXCC entity are (not) equal. |
| `sameContinent` | bool | My and their continent are (not) equal. |
| `myContinent` / `theirContinent` | `AF` `AN` `AS` `EU` `NA` `OC` `SA` or list | Continent is one of these. |
| `myDxcc` / `theirDxcc` | int (1–999) or list | DXCC entity number is one of these. |
| `modeCategory` | `CW` `PHONE` `DIGI` or list | The QSO's mode category. |
| `band` | band or list | The QSO's band. |

Their DXCC entity and continent come from the offline DXCC resolver (`Dxcc`), with the received exchange taking
precedence when it carries a zone or DXCC. If a predicate needs data that is unknown, the rule does not match.

### Dupe checks

Calls are compared as typed (upper-cased), so DL1ABC and DL1ABC/P are different calls. The `mode` key in `dupe.per` refers to the ADIF main mode, where USB and LSB are both treated as SSB.

### Multiplier sources

The multiplier source must be `dxcc`, `wpxPrefix`, `grid4`, `continent` or `rcvd:<kind>`. The kinds `rcvd:rst` and `rcvd:serial` are rejected. Both `rcvd:<kind>` and `grid4` must refer to an element present in some received exchange (base or a variant). Multiplier ids match `[a-z0-9_-]{1,32}` and are unique. The `per` field means `band`, `bandMode` (band + mode category), or `contest`.

| `source` | Value counted |
|---|---|
| `dxcc` | DXCC entity number |
| `wpxPrefix` | CQ WPX prefix (portable suffixes /P, /M, /MM, /AM, /QRP, /A, /LH are ignored; LX/DL1ABC → LX0; K1ABC/2 → K2; calls with more than two parts after stripping suffixes have no prefix) |
| `rcvd:<kind>` | The received value of that exchange element, upper-cased (`rcvd:cqZone`, `rcvd:state`, `rcvd:dok`, …) |
| `grid4` | First four characters of the received grid |
| `continent` | Their continent |

A multiplier counts once per `per` scope. With `when`, it only counts for QSOs matching the predicate (for example,
ARRL DX: DX stations count `rcvd:state` only from W/VE).

## Validation rules

The parser enforces strict limits:
- Input size: ≤ 256 KiB (both characters and UTF-8 bytes).
- Lists: each ≤ 64 elements.
- Points per rule: 0–1000.
- Version: 1–1,000,000.
- Name: 1–120 characters without control characters (Unicode letters allowed).
- `cabrillo` and `adif` fields: match `[A-Za-z0-9._+-]{1,40}`.

For `pointsTimesMultipliers`, at least one multiplier is required. For `points` and `qsos` scoring modes, no multipliers must be present.

## Scoring is an estimate

The live score is a **claimed-score estimate** for motivation and strategy. The contest sponsor's log checking is
authoritative. The UI says so, and the manual repeats it.

## Scoring details

Dupes score 0 points and credit no multipliers. Multiplier credit is independent of points: a 0-point same-country QSO still counts its zone and country. QSOs outside the contest's bands or mode categories are "out of contest": they score 0 points and do not take part in dupe checks. Contest-wide multipliers are attributed to the band of their first QSO in the per-band breakdown.

## Rates

`ContestRates` computes, from the session's QSO times (UTC):
- QSOs in the last 10 and 60 minutes, projected to QSOs/hour;
- the time span of the last 10 and 100 QSOs, as QSOs/hour;
- the best 60-minute window so far.

The rate over the last n QSOs uses the n−1 intervals between the n-th last and the newest QSO. It is unknown with fewer than n QSOs or a zero time span. Counting windows are (now − w, now]. QSO times after `now` are ignored.

All functions are pure and take a `UtcDateTime now`, so they are tested without a clock.

## Wavelog session settings

When a session is created on Wavelog 3.2+, `settings.exchangefields` is derived from the received exchange: `serial` if
it contains a `serial`, `gridsquare` if it contains a `grid`, and `exchange` if it contains anything else. All other
session settings use Wavelog's defaults.
