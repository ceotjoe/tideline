# Data safety (DS)

The rule behind all of these: **no QSO is lost, duplicated or silently changed.** Sync is journaled, resumable and
idempotent, and the local database is the source of truth. Wavelog has no client-side QSO id, so idempotency rests on a
reconcile query (call, minute, band, mode, station) before any retry (ADR 0008).

### DS-01 Offline logging, then sync
**P1 · all · Needs: real Wavelog 3.1+**
1. Airplane mode on. Log 5 QSOs with different calls, bands and modes.
2. Look at the log and the sync screen. Network on. Choose **Sync now**.

**Expected:** while offline all 5 show as waiting with icon and text, and logging was never slowed or blocked. After
sync all 5 show as synced, exist once on Wavelog with the right call, time (UTC), band, mode and station, and the tide
gauge text agrees with the list.

Result:

### DS-02 Quit during a sync
**P1 · iOS, iPadOS, Android, one desktop OS · Needs: real Wavelog**
1. Log 20 QSOs offline. Network on, **Sync now**, and kill the app (swipe away, force quit, or end the task) after the
   first few have gone.
2. Reopen the app. Let it sync. Repeat three times with different timing.

**Expected:** after the last run every QSO exists exactly once on Wavelog and is synced locally. Interrupted ones passed
through **Checking** and were reconciled, not sent twice. Nothing is lost locally.

Result:

### DS-03 Network drops mid-sync
**P1 · all · Needs: real Wavelog**
1. Start a sync of 20 QSOs. Switch Wi-Fi off (or move to mobile data and back) after a few uploads.
2. Switch back on.

**Expected:** Tideline reports that Wavelog is not reachable without losing anything, resumes when the connection is
back or on **Sync now**, and no QSO is duplicated.

Result:

### DS-04 Duplicate on the server
**P1 · all · Needs: real Wavelog**
1. Log a QSO and sync it. Log the same call, band, mode and minute again, locally.
2. Sync.

**Expected:** the second QSO is not silently dropped and not uploaded as a second copy. Its state is rejected or flagged
as a duplicate with a plain explanation ("Another QSO with the same callsign … in the same minute"). Correcting the time
by a minute lets it sync.

Result:

### DS-05 Revoked token
**P1 · all · Needs: real Wavelog**
1. With waiting QSOs on the device, revoke the token in Wavelog.
2. **Sync now**.
3. Create a new token, enter it under Settings → Wavelog account → Enter a new token. Sync.

**Expected:** "Token problem" is explained, nothing is lost, the waiting QSOs sync after the new token, and the old token
does not appear on any screen.

Result:

### DS-06 Server too old, token without permissions
**P2 · all · Needs: real Wavelog or mock**
1. Try onboarding against a Wavelog older than 3.1 (or the mock set to an old version).
2. Create a token with only some permissions (no `qso:write`, then no `qso:read`) and use it.

**Expected:** a clear message about the version or the missing permission, in the chosen language, before any QSO is
touched. Features that need `qso:read`, `qso:delete` or the 3.2 contest scopes are disabled with an explanation, not
failing halfway.

Result:

### DS-07 Clock skew
**P2 · iOS, Android, one desktop OS · Needs: real Wavelog**
1. Set the device clock 10 minutes wrong (switch off automatic time). Log a QSO with the time set to "now".
2. Look at the time shown, then sync.

**Expected:** Tideline either warns about the skew or still stores UTC as entered. No QSO is rejected silently or filed
on a wrong day. Restore automatic time afterwards.

Result:

### DS-08 Too many requests
**P2 · all · Needs: real Wavelog or mock that answers 429**
1. Tap **Sync now** three times quickly.
2. Make the server answer "too many requests".

**Expected:** one run, no error from the quick taps. After a 429 Tideline waits and retries by itself while the app is
open (ADR 0033); nothing is lost.

Result:

### DS-09 Change a synced QSO
**P1 · all · Needs: real Wavelog**
1. Sync a QSO. Correct its name or comment locally. Sync.
2. Change its time, mode, band or station locally.

**Expected:** a comment or name change reaches Wavelog. A change of time, mode, band, frequency or station shows
**Needs decision** with the two choices **Replace in Wavelog** and **I'll fix it in Wavelog**, explained. Neither choice
loses the QSO.

Result:

### DS-10 Update from Wavelog and remove from this device
**P1 · iOS or Android and one desktop OS · Needs: real Wavelog**
1. Sync a QSO. In Wavelog change its time. In Tideline choose **Remove from this device**.
2. Follow the action to **Update from Wavelog**, confirm. Then **Remove from this device** again.
3. Try the same on a QSO of a contest session and of an activation, and on a local QSO that is still waiting.

**Expected:** step 1 refuses and offers the update. After step 2 the local QSO shows Wavelog's time, nothing was sent to
Wavelog, and the removal works. In step 3 the update is not offered. If the QSO was deleted in Wavelog, nothing changes.

Result:

### DS-11 Free up space
**P1 · iOS or Android and one desktop OS · Needs: real Wavelog**
1. Settings → account → Remove synced QSOs. Choose an age, read the count, **Check with Wavelog**.
2. **Export, then remove**. Import the ADIF file into another program.
3. Import the same file back into Tideline.

**Expected:** only synced, unchanged QSOs of that age go. Contest, activation, waiting and changed QSOs stay. Nothing is
deleted on Wavelog. The exported file holds exactly the removed QSOs. The re-import skips them.

Result:

### DS-12 Backup and restore across devices
**P1 · each OS family · Needs: nothing**
1. Create a backup on device A (a log with QSOs, two station locations, callsign notes, a contest session).
2. Restore on device B (same OS family), or on A after reinstalling.
3. Sync on B against a Wavelog that already has the synced QSOs.

**Expected:** QSOs, locations and notes are back; QSOs already on Wavelog are not uploaded again; the token is **not** in
the backup and must be entered again; the backup screen says the file is not encrypted. A corrupted file, a file
from 0.5.x and a file that is not a backup are each refused with a clear message, without a crash and without changing
the existing log.

Result:

### DS-13 ADIF round trip
**P1 · all · Needs: nothing**
1. Import an ADIF 3.1.x file with many fields, non-ASCII text, user-defined fields and an `APP_` field.
2. Export the log and open the file in a second logging program and in Wavelog's own import.
3. Import the export into a fresh Tideline.

**Expected:** no QSO is lost or duplicated; field values survive; unknown fields are kept and written back; times stay
UTC; a malformed record is reported by name and does not stop the rest. A very large file (50 000 QSOs) imports without
freezing the screen.

Result:

### DS-14 Upgrade keeps the log
**P1 · all · Needs: a build of the previous release**
1. Install the previous release, log and sync QSOs, change settings, add a second account.
2. Install the new build over it.

**Expected:** the log, settings, accounts and notes are intact (the database migrates in place); the token still works;
no QSO is uploaded again. Coming from 0.5.x, the log is empty with a one-time notice and the old file is kept.

Result:
