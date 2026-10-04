# Fast Log Entry

Type many QSOs as shorthand, check how Tideline read each line, and log them all at once. It is the shorthand of Wavelog's
SimpleFLE, so it works for a paper log, an activation you wrote down, or a session at the keyboard. It needs no
connection.

Open it with the **lightning bolt** in the log's top bar, or **Ctrl/⌘ + Shift + F**.

## How to type
One QSO per line. Band, mode, date and time zone words on their own line apply to the lines after them.

```
date 2026-10-02
20m cw
1734 DL1ABC 599 579 JO62 @Anna
5 G4XYZ
40 F5ABC <good signal>
14.205 ssb
1810 W1AW 59 57
```

- **Time:** the first QSO needs a full UTC time (`1734`). After that, type only the digits that changed: `5` after `1734`
  is 17:35, `40` is 17:40.
- **Callsign** next, then optional **reports**, **locator** (`JO62`, `#JO62QM`), a **reference** (`de-0034`, `dm/bw-001`,
  `dlff-0123`, `eu-005`; a park-to-park partner's reference), and **@Name**.
- **Reports:** `59`, `599`, `-12`. One report is the one you sent; what you did not type is the mode's default (59, 599,
  -10 for FT8). A single digit is the second digit (`7 3` is 57 / 53 in SSB).
- **Band, mode, frequency:** `20m`, `cw`, `ft8`, `14.205` (MHz, with a dot). A frequency also sets the band.
- **Dates:** `date 2026-10-02`, `day +` (next day), `day ++` (two days). **Time zone:** `timezone +2` converts the times you
  type from local time to UTC.
- **More:** `<comment>`, `[QSL message]`, `<tx_pwr:50>` (stays for the lines after it), or another ADIF field as
  `<rig:IC-7300>`.
- **Contest exchange:** `,1.12` is sent 1, received 12; `,++` counts up. These are recorded as typed; Fast Log Entry does not
  hand out contest serial numbers and is not for a contest session.

## The preview
Every line is shown with an icon **and** text:
- a QSO: call, name, time in UTC, band, mode and reports;
- a line that sets what follows;
- a **problem**, with the word that was not understood. A line with a problem is left out completely.

Warnings: the QSO is **earlier than the one before** (did you forget `day +`?), **in the future**, or a **duplicate** of a
QSO already in the log or earlier in the text. Duplicates are not logged unless you switch on **Also log duplicates**.

## Logging
Choose the **station location** (if you have several), then **Log N QSOs**. All QSOs are stored in one step: all or none.
While you type, nothing is stored and nothing is sent. They sync like any QSO afterwards.

- With problems in the text, fix them, or switch on **Skip lines with problems**.
- While an **activation** is running, the QSOs go into it, with its references.

## What it does not accept
Lines such as `mycall DL1ABC`, `mygrid JO62` (classic FLE files): choose the station location on the screen instead. A second
callsign on one line, reports before the callsign, `sat`, and fields Tideline sets itself (`my_…`, the station callsign) are
reported as problems.
