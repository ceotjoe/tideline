# Callsign directory and notes

Tideline remembers what your QSOs say about the stations you worked, and lets you keep your own notes. Both work offline.

## What earlier contacts say
When you type a callsign you have worked before, a line appears under the field, for example
**Known from earlier contacts: Anna · Berlin · JO62**. It uses the newest contact that has each value. A portable call
(`DL1ABC/P`, `EA8/DL1ABC`) finds the same station.

- **Fill in** copies the name and locator into the fields that are still **empty**. What you typed is never replaced.
- Nothing is written into a QSO unless you log it.

The directory is built from your own log and from your Wavelog (it learns your Wavelog's history while it syncs, a part
at a time). It is part of the worked-before index: **Settings → Reference data → Worked-before index → Rebuild** rebuilds
it too.

## Notes
- The **note button** at the right of the callsign field opens the note for this station. It is filled when a note
  exists, and the start of the note shows under the field. Tap that text to edit it.
- A note is for the station, whatever the suffix: one note for `DL1ABC`, `DL1ABC/P` and `EA8/DL1ABC`. It can be up to
  2,000 characters.
- **Notes stay on your device.** Wavelog's interface has callsign notes of its own, but its API gives no access to them,
  so Tideline's notes are never sent to Wavelog and never appear in an ADIF export. They are in your
  [encrypted backup](backups.md); restoring never overwrites a note you already have.
- Saving an empty note deletes it.

## Browse
**Callsigns** in the main navigation (second place, `⌘2` / `Ctrl+2`) lists the stations, newest contact first, with name, place,
locator, DXCC and zones and the date you last worked them. Search by the start of a call, or by a name or place. Tap a
station to read or edit its note; a filled note icon marks stations that have one.

## Privacy
Names and places of other people are personal data. They stay in the encrypted database on your device and are not sent
anywhere. See the [privacy statement](../../../PRIVACY.md).
