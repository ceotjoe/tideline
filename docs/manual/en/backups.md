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

## Backup

**Create backup** saves everything except your token in one `.tlbackup` file.
- **The backup is not encrypted.** It holds your QSOs, station locations and callsign notes in readable form, so keep it
  somewhere safe, like an ADIF export.
- **Restoring:** **Restore a backup** brings everything back on the same or a new device.
- **No duplicates:** QSOs that were already in Wavelog stay linked to their Wavelog entries and are not uploaded again.
- **Your token is not in the backup.** After restoring on a new device, enter a new token under **Settings → Wavelog account → Enter a
  new token**.
- **Backups from version 0.5 can't be restored.** Version 0.5 encrypted its backups with a passphrase; this version
  has no encryption code any more. Tideline says so when you pick such a file.

### How your log is protected on the device

Tideline doesn't encrypt your log itself. It relies on what your device does: the lock screen and the operating system's
own storage protection. Use a device passcode, and switch on the app lock under **Security and backup** if others use your
device.

Tideline asks iPhone, iPad and Android not to put its data into iCloud, iTunes or Google backups. Your own backup file,
which you save yourself, is the way to move the log to another device.
