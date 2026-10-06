# 0026. Offline callsign directory and local callsign notes

- Status: accepted
- Date: 2026-10-04

## Context
- Maintainer request (v0.4, step 6.5): an offline callsign directory built from the QSO history of Wavelog, with callsign
  notes. Decisions of 2026-10-04: notes may be local only if Wavelog has no notes API; the directory is per account with
  a merged lookup on the entry form.
- **Verified 2026-10-04** ([wavelog-api.md](../architecture/wavelog-api.md)): Wavelog has callsign notes in its web UI,
  but **API v2 has no notes resource** (the resource list and the `api_v2` library directory), the notes controller uses
  the web session, and callsign notes are not exported to ADIF. So nothing can be read from or written to Wavelog.
- The data for the directory is already pulled: `GET /qso?format=adif` returns the full field set and feeds the
  worked-before index (ADR 0017's neighbours, T20).

## Decision
- **Directory** (`callsign_directory`, schema v4): derived data, one row per account and **home call** (`EA8/DL1ABC/P`
  and `DL1ABC` share a row): name, QTH, locator, country, state, DXCC, CQ and ITU zone, and the time of the newest QSO.
  - **Where it comes from:** every QSO saved locally (inside the transaction that stores it, like the worked-before
    index), the local log when the index is built or rebuilt, and the server ADIF pull. The worked-before index owns
    this: *Rebuild* there rebuilds both, and removing an account purges its rows.
  - **Newest value wins, per value.** An older QSO still fills a gap a newer one leaves. Deleting a QSO keeps what was
    learned, as the worked-before index does.
  - **Untrusted input.** Text is cleaned (control characters out, whitespace collapsed, 80 characters), locators and
    numbers are validated, a server pull adds no new station once an account holds 500,000.
  - **Lookup merges all accounts** (newest value per field); counts and rebuilds stay per account.
- **Notes** (`callsign_notes`): the user's own text, **local only**, one per home call across accounts, up to 2,000
  characters. A row has a UUID, hybrid-clock stamp, origin device and tombstone (the text is dropped on delete), so
  device-to-device sync can carry them later. They are in the **encrypted backup** (`callsignNotes`; a restore never
  overwrites an existing note) and in no ADIF or Cabrillo export. Nothing is sent to Wavelog.
- **Entry form.** Under the callsign: what earlier contacts say ("Anna · Berlin · JO62") with *Fill in*, which copies the
  name and locator into **empty** fields only, and the start of the note. A note button sits in the callsign field
  (filled when a note exists). Values are suggestions, never written into a QSO by themselves.
- **Directory page** (the *Callsigns* tab of the main navigation, [ADR 0032](0032-callsigns-in-main-navigation.md); first Settings → Reference data → *Browse callsigns and notes*): search by call prefix, name or place,
  newest contact first; tapping a station opens its note.

## Consequences
- Names and places of third parties are personal data. They stay in the encrypted database, are never sent anywhere and
  are never exported; `PRIVACY.md` and threat T25 say so.
- The directory fills as the log grows and as sync pulls history (up to 10 pages per run, as for the worked-before
  index), so a new install learns its past gradually.
- If Wavelog adds a notes endpoint, notes could become per account and sync; the rows already have what that needs.
- Not in this step: editing directory values, a QRZ/HamQTH lookup (Wavelog's `lookup:read` returns DXCC data, not
  names), and showing the directory in contest mode (it has its own hints).
