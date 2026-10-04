# 0028. Fast Log Entry (FLE) in the normal log

- Status: accepted
- Date: 2026-10-04

## Context
- v0.4 proposal B: typing many QSOs as shorthand ("1734 4W7EST", "5 HB9HIL", …), useful for logging a paper log or an
  activation after the fact.
- Several programs share FLE in different dialects. The user's log is Wavelog, whose SimpleFLE is documented and open.
- Verified 2026-10-04 and recorded in [fle.md](../architecture/fle.md): the grammar, the order in which words are tested,
  and where SimpleFLE ignores what Tideline will not.
- The maintainer did not answer whether FLE should also work in contest mode (decision 3 of the v0.4 proposal); the
  recommendation in the proposal was the normal log first.

## Decision
- **Dialect:** SimpleFLE as Wavelog implements it, nothing from other dialects. No textual station lines (SimpleFLE has
  none): the **station location** is chosen on the FLE screen.
- **Strict parsing.** Untrusted text: a line that is not understood is reported with a typed problem and the word it is
  about, and **left out whole**; it does not change band, mode, date or time for the lines after it. Limits: 5,000 lines,
  500 characters a line, 256 per value. The parser is total (never throws), and is fuzzed.
- **Preview, then one confirmation.** The screen shows every line: QSO (time, call, band, mode, reports, extras), header
  (what it sets), or problem (icon, text and the word). *Log N QSOs* writes them in **one local transaction**; nothing
  is sent while typing, and sync runs afterwards as for any QSO. By default the button needs a text without problems;
  *Skip lines with problems* logs the rest. Times are UTC; a time zone line is shown as such.
- **Same rules as the normal log:** QSOs that duplicate one already in the log (same call, minute, band, mode, station) or
  one earlier in the text are marked and not logged unless the user asks, and the worked-before index and callsign
  directory learn from them like from any QSO.
- **Activations:** with a running activation each QSO is logged into it (own references and `MY_*` fields from the
  activation, as for a QSO typed on the log screen), in the same transaction. The program reference in a line is the
  other station's (park-to-park, summit-to-summit).
- **Not in contest mode.** Serial numbers are allocated atomically per session and never reused
  ([ADR 0018](0018-contest-definitions-as-data.md)); an exchange typed in FLE would bypass that. Exchange words are
  accepted for QSOs outside a contest session and recorded as typed (`STX`, `SRX`, `STX_STRING`, `SRX_STRING`), with no
  `CONTEST_ID` and no serial allocation. FLE for a contest session can be added later with allocation.
- **Command.** `log.fle` in the command registry (⌘/Ctrl+Shift+F), reachable from the log screen's app bar and the Go
  menu on desktop.

## Consequences
- Typing the shorthand needs no network and blocks nothing.
- A QSO logged by FLE has source `fle` (already in the schema) and carries no frequency unless the text gave one.
- Pasting a classic FLE file with `mycall`/`mygrid` lines gives per-line problems, not a guess; the manual says what to
  do (choose the station location).
