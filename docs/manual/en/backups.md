# Backups and export

Your log is never locked in.

## ADIF export

**Settings → Security and backup → Export log as ADIF** saves your whole log as an ADIF file. Every logging
program can read it.

ADIF files are **not encrypted**, so keep them somewhere safe.

## ADIF import

**Import ADIF file** adds QSOs from a file, for example a paper log typed in elsewhere or another logger's export.
- QSOs already in your log are skipped.
- Records without a valid callsign, time, band or mode are counted and reported.
- The imported QSOs belong to your default station location and sync like any other QSO.
- **Large imports:** before more than 50 new QSOs are uploaded, Tideline shows a preview and waits for you. See
  [Sync and conflicts](sync-and-conflicts.md).

## Encrypted backup

**Create encrypted backup** saves everything except your token, protected by a passphrase of at least 8 characters.
- **Keep the passphrase safe.** Without it, the backup cannot be opened, not even by us.
- **Restoring:** **Restore a backup** brings everything back on the same or a new device.
- **No duplicates:** QSOs that were already in Wavelog stay linked to their Wavelog entries and are not uploaded again.
- **Your token is not in the backup.** After restoring on a new device, enter a new token under **Settings → Wavelog account → Enter a
  new token**.

### Why Android doesn't back Tideline up to the cloud

Tideline's data is encrypted with a key that never leaves the device. A cloud copy could not be opened, so Tideline
switches the system backup off and offers its own encrypted backup instead.
