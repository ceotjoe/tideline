# Contest mode

Contest mode is a fast, dense logging screen for contests. It works fully offline. Serial numbers, dupe checks, the
score and the rates are all computed on your device. Contest QSOs are ordinary QSOs in your log and sync to Wavelog like
any other.

## Starting a session

1. Open **Contest mode** from the button at the top of the log screen, or press **⇧⌘C** (**Ctrl+Shift+C**).
2. Choose the **Contest**. Use **Search contests** to filter the list. Each contest is marked **Built in** or
   **Imported by you**.
3. Choose the **Station**. It is required, so the QSOs can sync.
4. Check **My exchange**. Tideline fills in what it can from the station, for example your CQ zone or DOK. Fields that
   your exchange does not need are not shown.
5. Optionally set the **Cabrillo categories** (operator, assistance, band, mode, power, station type, transmitters,
   overlay, time). They are only used for the Cabrillo export. Power, station type and overlay start as **Not set** on
   purpose, so you make those claims yourself.
6. Choose **Start session**.

While a session runs, the log screen shows a banner, "Contest session active", with **Return to contest**. You can
reopen an ended session from **Past sessions**.

## Logging

The entry follows the contest's exchange: the callsign, then the received exchange (for example RST and CQ zone, or RST
and serial number). What you send is shown above it, including the **next serial number**.

- **Enter** logs the QSO, but only when it is complete. If the callsign is empty, Enter goes to the callsign. If part of
  the exchange is missing, Enter goes to the first missing field.
- **Space** or **Tab** moves to the next field.
- **Esc** wipes the entry.
- After logging, the callsign and received fields are cleared, and band, mode and frequency stay set. The screen reader
  announces "Logged", the call letter by letter and the serial number.
- **Page Up** and **Page Down** change the band. **⌘M** (**Ctrl+M**) changes the mode. The frequency field works as in
  the normal log: `14025`, `14.025` and `1840` are all understood.

On a touch screen, use the **Log QSO** button. All buttons are at least 48 dp; glove mode makes them larger.

**Tablet in landscape:** callsign, received exchange, band, mode and frequency are one row across the whole width. The
hints and the sent exchange are below it, then the frequency reading and the buttons. Your recent QSOs and the score
panel are underneath. With the on-screen keyboard open, all of this stays visible without scrolling and the top bar
hides until you close the keyboard.

### Serial numbers

Your serial number is taken at the moment the QSO is saved, in the same step that stores the QSO. The number shown
before that is only a preview. Serial numbers are never reused: if you delete a QSO, its number stays taken, and the next
QSO gets the next number. Editing a QSO never changes the serial number you sent.

## Hints while you type

Under the callsign, Tideline shows what it knows, always as an icon with text:

| Hint | Meaning |
|---|---|
| Dupe | You already worked this station on this band (and mode, if the contest counts modes separately). A dupe is still logged if you press Enter. It is marked and scores 0 points. |
| Already worked on … | Worked in this contest, but on another band or mode, so it is not a dupe here. |
| New multiplier | This QSO would add a multiplier, for example a new zone, country, prefix or DOK. |
| Outside this contest's bands or modes | The QSO scores 0 points. |
| In your log | Worked before in your whole log: new band, new mode, new combination, or already worked. |
| Super check | Calls from the MASTER.SCP list that contain what you typed. Tap one to use it. |
| Did you mean | Calls in the list that differ by one character, shown when what you typed is not in the list. |

### The super check partial list (MASTER.SCP)

Tideline does not include the list, because it is not ours to distribute. Install it in **Settings → Reference data →
Super check partial**:

- **Download** fetches the list from the address shown. The default is `https://www.supercheckpartial.com/MASTER.SCP`,
  and you can change it. Only `https` addresses are allowed, and the file may be at most 8 MiB. Tideline contacts this
  address only when you press Download, and sends nothing about you.
- **Import file** installs a MASTER.SCP file you already have.
- **Remove** deletes the list.

## Score and rates

The **Score and rates** panel shows QSOs, points, multipliers, dupes, the score per band and these rates:

- the last 10 and the last 60 minutes, projected to QSOs per hour;
- the last 10 and the last 100 QSOs, as QSOs per hour;
- your best 60 minutes so far.

The **claimed score is an estimate**. It follows the contest's rules as Tideline knows them, but only the contest
sponsor's log check is authoritative. Show or hide the panel with **⌘R** (**Ctrl+R**). On a phone the panel starts
collapsed and shows a one-line summary.

## Editing without leaving contest mode

Select a QSO in **Recent QSOs**, or press **⌘E** (**Ctrl+E**) for the last one. You can change the callsign, band, mode
and received exchange in place. The sent exchange, including the serial number, cannot be changed. Delete asks first.
The score is recomputed after every change.

## Ending a session

Press **⇧⌘E** (**Ctrl+Shift+E**) or choose the **End contest session** button (the stop icon) at the top of the contest
screen. Tideline asks first. Your QSOs stay in your log. You
can reopen the session later.

## Wavelog status of a session

Your QSOs always upload with the contest's ADIF name (`CONTEST_ID`) and their exchange fields. On **Wavelog 3.2 or
newer**, and with a token that has `contest:write`, Tideline also creates the session on Wavelog and links its QSOs to
it. The contest screen and the list of past sessions show where a session stands, always as an icon with text:

| State | Meaning |
|---|---|
| Only on this device | The session is not mirrored on Wavelog. The reason is shown after the colon, for example an old server (before 3.2), a contest that is not activated on the server, or a token without `contest:write`. |
| Waiting for upload to Wavelog | The session will be created on Wavelog once one of its QSOs has been uploaded. |
| Being checked on Wavelog | A create request got lost. Tideline checks whether Wavelog already has the session before it tries again. |
| On Wavelog | The session exists on Wavelog and its QSOs are linked to it. |

Your log is complete either way. The session on Wavelog is an optional extra. If you delete the session in Wavelog,
Tideline does not create it again.

## Exporting a Cabrillo log

Choose **Export Cabrillo log** from the menu (the three dots) in the contest screen, press **⇧⌘X** (**Ctrl+Shift+X**),
or use the button on a card in the list of past sessions. Tideline then:

1. Builds the log from the session: your callsign and locator from the station, the categories from the session setup,
   the claimed score from the contest engine, and one `QSO:` line per contact.
2. Checks it and lists any problems (for example an empty exchange value, which is written as `-`). You can cancel,
   or export anyway.
3. Asks where to save it. The suggested name is `CALL-CONTEST-YEAR.log`, for example `DO1HOZ-DARC-WAG-2026.log`.

Notes:

- A contest whose definition has no Cabrillo name cannot be exported. Tideline shows a warning for it. Use the ADIF
  export in Settings instead, or add a `cabrillo` name to the definition.
- When the exchange differs by station (WAG: serial number from abroad, DOK from Germany), both share one column in the
  log.
- A contact logged without a frequency gets the lower edge of its band (`14000` for 20 m), as contest loggers commonly
  write it.
- Dupes are included, as contest sponsors expect. Their log check removes them.
- The claimed score is an estimate. Check it against the contest rules before you send the log.
- Free text is written as plain ASCII: `ä` becomes `ae`, and so on.

## Contest definitions

Every contest is a small data file that describes its exchange, dupe rule, points and multipliers. Tideline includes:

- CQ World Wide DX (SSB, CW);
- CQ WPX (SSB, CW);
- ARRL International DX (CW, SSB);
- IARU HF World Championship;
- DARC Worked All Germany (WAG);
- two generic contests, one with a serial number and one with a free exchange, for anything else.

The bundled rules were checked against the sponsors' rules on 2026-10-02. Rules change, so check them before a
contest. Known simplifications are listed in `app/assets/contests/README.md`, for example that WAE-only countries are not
separate multipliers.

In **Settings → Reference data → Contest definitions** you can **Import definition** from a JSON file of up to 256 KiB, and delete
definitions you imported. A definition that a session uses cannot be deleted. Tideline checks an imported file strictly
and says what is wrong if it rejects it. The file format is described in
[contest-definitions.md](../../architecture/contest-definitions.md).
