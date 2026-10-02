# 0019. Cabrillo export of contest sessions

- Status: accepted
- Date: 2026-10-02

## Context
- ADR 0018 decided that Cabrillo 3.0 is written locally by `tideline_adif` in the order of the definition's exchange.
- Some contests have per-station alternatives in one position of the received exchange. WAG: a serial number from
  stations outside Germany, a DOK from German ones. The definition models these as consecutive elements with a `when`.
- A Cabrillo checker reads columns by position, so every `QSO:` line needs the same number of tokens.
- Sessions can be exported while running or long after they ended, and the file is the only thing the contest
  organiser sees.

## Decision
- **Alternatives share a column.** Consecutive received elements that have a `when` form one logical column. The line
  holds whichever of them has a value (the others are empty by construction), and an empty column if none has. Every
  other element is a column of its own. Tokens come from `ExchangeMapping.cabrilloTokens`.
- **The session is the unit.** The export uses the stored session (categories, exchange, station), not the screen state,
  so it works for past sessions too. The claimed score comes from the same `ContestEngine` the screen uses.
- **Check first, then ask.** `CabrilloWriter.validate` runs before the file dialog. Problems are listed, localised,
  grouped by kind with the number of QSOs affected. The user may export anyway, because a log with a known flaw is still
  better than none shortly before the deadline.
- **No Cabrillo name, no export.** The entry is visible but explains why nothing is written, and the contest screen and
  session list show a warning. Guessing a `CONTEST:` value would produce logs that robots reject silently.
- **Saved through the ADIF export's mechanism** (`DataTransfer.saveFile`, a file picker save dialog). No new plugin, no
  network.
- **`CREATED-BY` uses a constant** (`appVersion`, kept in step with `pubspec.yaml` by a test) rather than a package-info
  plugin. The ADIF export uses the same constant.

## Consequences
- Alternatives must be adjacent in the definition. A definition that scatters them gets one column per element, which
  the checker will reject; the validator's `exchangeCountMismatch` is the only hint. The definition schema could grow an
  explicit group later.
- Dupes and out-of-contest QSOs are written like any other line; the organiser's checker decides what counts.
- `CATEGORY-BAND: Light` is the one mixed-case value in the specification. The writer upper-cases header values, so it
  is written as `LIGHT`.
