# Fast Log Entry (FLE) in Tideline

_Verified 2026-10-04 against the [SimpleFLE documentation](https://docs.wavelog.org/user-guide/logbook/simple-fle/) and
`assets/js/sections/simplefle.js` of `wavelog/wavelog` (branch `dev`). The source was read through a page-fetching tool
that summarises, so regular expressions below are quoted from its output, not from a local copy; the tests in
`packages/tideline_domain/test/fle/` pin the behaviour Tideline implements._

## Which dialect
Fast Log Entry is a text shorthand several programs share (the original by DF3CB, `FLEcli`, SimpleFLE in Wavelog).
Tideline follows **SimpleFLE as Wavelog documents and implements it**, because the user's log goes to Wavelog and that
syntax is documented and open. Nothing from the other dialects is assumed. In particular **there are no textual
`mycall`, `operator` or `mygrid` lines**: SimpleFLE keeps those in form fields (`#stationProfile`, `#operator`,
`#my-grid`, stored in the browser). In Tideline the station comes from the Wavelog station location chosen on the FLE
screen (or the running activation).

## What SimpleFLE does (verified)
- **One QSO per line.** Band, mode, frequency, date and time zone words change what the following QSOs inherit.
  The shorthand example "1734 4W7EST 5 HB9HIL 1800 DJ7NT 13 DF2ET" in the documentation is four lines
  (`1734 4W7EST`, `5 HB9HIL`, …): the time fragment is the **first** word of a line (`itemNumber === 0` in the source).
- **Order of tests per word** (source): `day +…`, ISO date, four-digit time `^[0-2][0-9][0-5][0-9]$`, mode, band
  `^[0-9]{1,4}(?:m|cm|mm)$` or `sat`, frequency `^\d+\.\d+$` (MHz, sets the band), one-digit time fragment `^[1-9]$` and
  two-digit `^[0-5][0-9]$` (first word of the line only; the fragment replaces the last digit, or the last two), a
  reference, the callsign (only if none yet), locator, report (not the first word), exchange, `@name`.
- **Callsign** `([a-zA-Z0-9]{1,3}[0-9][a-zA-Z0-9]{0,3}[a-zA-Z])` or with a prefix or suffix after `/`. It must end in a
  letter, so `JO62` is a locator. A six-character locator before the callsign would be taken for a call.
- **References** (shape, upper case): SOTA `^[A-Z0-9]{1,3}/[A-Z]{2}-\d{3}$`, IOTA `^[AENOS]*[FNSUACA]-\d{3}$`, POTA
  `^(?!.*FF)[A-Z0-9]{1,3}-\d{4,5}(?:,…)*$` (comma list), WWFF `^[A-Z0-9]{1,3}[F]{2}-\d{4}$`.
- **Locator** `(?<=^#?)[A-R]{2}[0-9]{2}([A-X]{2}([0-9]{2})?)?$` (4, 6 or 8 characters, optional `#`).
- **Reports** `^[-+]\d{1,2}$|^\d{1,3}$|^\d{1,3}[-+]\d{1,2}$`: first word is sent, second received. Normalised by mode
  (`getReportByMode`): CW one digit `5d9`, two digits `dd9`; SSB one digit `5d`, two digits as typed, three digits the
  first two; dB modes get a `+` if unsigned. Defaults: SSB 59, CW 599, other data modes 0 dB.
- **Contest exchange** `,` sent and `.` received after the call: numbers are `STX`/`SRX`, other text `STX_STRING`/
  `SRX_STRING`; the sent part persists while a received part is seen; `,-` clears it, `,++` counts up, `,+0` stops.
- **`@Name`** `(?<=^@)[A-Za-z]+`, **`[QSL message]`**, **`<comment>`**, **`<field:value>`** (any ADIF field; `tx_pwr`
  and `my_*` persist, an empty value resets).
- **Dates:** `date YYYY-MM-DD` (the source tests the bare ISO date), `day +` / `day ++` adds days, `TIMEZONE ±H` or
  `TZOFS ±H` converts local to UTC. No rollover for a time that goes backwards.
- The mode list is the instance's. Unknown words are **silently ignored** in the source.

## What Tideline does differently (on purpose)
| | SimpleFLE | Tideline |
|---|---|---|
| Unknown word | ignored | the whole line is reported (`unknownToken`) and left out |
| Line with a problem | partly applied | left out **whole**; its band/mode words are not inherited |
| Second callsign on a line | ignored | `secondCallsign` |
| Report before the callsign | accepted | `reportBeforeCall` |
| Band without frequency | a default frequency of the band | no frequency (ADIF `FREQ` is optional) |
| Default report | by mode | `Mode.defaultReport` (59, 599, −10 for dB modes) |
| `<field:value>` | any field | not core fields, not fields that have their own segment, not `my_*` (the station location or activation sets those), not `STATION_CALLSIGN`/`OPERATOR`; `tx_pwr` persists |
| Time going backwards | silent | a warning (a `day +` is probably missing); future times too |
| `sat` | a band | not supported (error) |
| Hour 24–29 | accepted by the regex | `invalidTime` |
| Four digits that are not a time | ignored | `invalidTime` |
| Exchange | written to every QSO | written only on a line with a received part (`STX` from the persisted sent part) |
| Limits | none | 5,000 lines, 500 characters per line, 256 per field value |

## Grammar in Tideline
```
text      := line (newline line)*
line      := day | date | zone | words
day       := "day" " " "+"+                 (1 to 31 plus signs)
date      := ["date" " "] YYYY-MM-DD        (not before 1930; a real date)
zone      := ("timezone" | "tzofs") " " [+-]H   (−12 … +14, hours)
words     := word*   — band/mode/frequency words, then, for a QSO:
             [time | fragment] call [report [report]] [locator] [reference] [@name]
             [exchange] [<comment>] [<field:value>]* [[QSL message]]
```
Words are case-insensitive. Band, mode and frequency words may stand alone or open a QSO line. A QSO line needs a
callsign; time (full on the first QSO, a fragment after) is inherited; band and mode must have been given.
Times are **UTC**, minus the `timezone` offset, on the date set by `date` and `day`.

## Where it is used
- Pure Dart in `tideline_domain` (`FleParser`, typed `FleProblem` per line, `FleWarning`); no Flutter, no database.
- The screen previews every line (QSO, header or problem) and logs all QSOs in **one local transaction**.
- Not in contest mode (ADR 0028). Exchange words are recorded as typed; no serial is allocated.
