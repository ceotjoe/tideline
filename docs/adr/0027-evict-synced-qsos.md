# 0027. Removing synced QSOs from the device (eviction)

- Status: accepted
- Date: 2026-10-04

## Context
- Maintainer request (v0.4, step 6.6): remove the local copies of QSOs that are already on Wavelog, to free space. Decision
  of 2026-10-04: **only local copies; nothing is ever deleted on Wavelog**.
- A normal delete is a tombstone, and a tombstone of a synced QSO is queued as a delete on the server
  ([ADR 0016](0016-phase-2-product-decisions.md)), and CLAUDE.md requires tombstones for device-to-device sync. So this
  cannot be a delete.
- Wavelog has no way to read a QSO back into the log: the app only pulls ADIF into the worked-before index and the
  callsign directory. A removed QSO therefore cannot be restored from Wavelog, only from an ADIF file.
- `GET /qso` takes a date range without a callsign and returns ids (docs/architecture/wavelog-api.md), so a read-only
  check against the server is possible.

## Decision
- **Eviction is a purge of this device, with a record.** The QSO row and its sync row are removed in one transaction. A
  row in `evicted_qsos` (schema v5) keeps the local id, the account, the Wavelog id, the time, and a SHA-256 of the
  duplicate key (call, minute, band, mode, station). It holds no callsign. Nothing is sent to the server, nothing is
  queued, and a journal entry says how many were removed. (Like removing an account, it is not a sync-visible delete, so
  it is not tombstoned.)
- **Eligible:** synced (the state machine leaves `synced` on every local edit, so synced means unchanged since the last
  upload), a Wavelog id known, not deleted, **and** in no contest session and no activation (contest mode, Cabrillo and
  the activation export need them). Everything else stays, and the screen says why (not on Wavelog yet, changed since,
  contest, activation).
- **Wavelog must confirm.** Before anything is removed, one read-only listing of the QSOs in the date range (±1 day) is
  compared by Wavelog id **and** the duplicate key (call, minute, band, mode, station), the same test the reconcile step
  uses. QSOs that are not found or differ stay. If the check cannot be made (offline, token revoked, server error, a list
  too large to read completely) **nothing is removed**. The client refuses a partial list: it throws instead of cutting
  at the page limit.
- **Re-checked at the moment of removal**, in the transaction: a QSO edited between the check and the removal stays.
- **What the history learned stays.** The worked-before index and the callsign directory are updated from each QSO
  first, and its worked-before rows are marked as coming from the server so a later local rebuild cannot drop them.
- **The user chooses:** by age (older than 1, 2 or 5 years, or all synced QSOs) on the account's *Free up space* page, or
  one QSO from its details. The last step offers **Export, then remove** (an ADIF file of exactly those QSOs; if saving
  fails or is cancelled nothing is removed) or **Remove**.
- **A removed QSO is not brought back by an import.** Importing an ADIF file skips QSOs whose fingerprint is in
  `evicted_qsos` (they are on Wavelog; uploading them again would only be rejected as duplicates). Sync never recreates
  them: it only works on rows that exist.

## Consequences
- Space is freed, but the log list and the ADIF export of the account no longer contain these QSOs; the manual says so and
  suggests exporting first.
- A QSO removed by mistake can only come back through an ADIF file (the export offered first, or one from Wavelog).
- The fingerprint is a hash of a low-entropy tuple, so someone who has the database could test a guess; the database is
  encrypted and the record is not part of backups or exports. Threat T26.
- Device-to-device sync (later) can use the records to avoid sending a removed QSO back to this device.
