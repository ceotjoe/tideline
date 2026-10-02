# Sync and conflicts

Every QSO shows where it is in the sync process:

| Status | Meaning |
|---|---|
| Local | Saved on this device only; something is missing (for example a station location). |
| Queued | Waiting for the next sync. |
| Uploading | Being sent right now. |
| Verifying | The last attempt didn't finish cleanly. Tideline checks the server before trying again, so the QSO is never duplicated. |
| Synced | Safely in your Wavelog. |
| Conflict | You changed something Wavelog can't update through its API (time, mode, frequency or station). You decide what happens. |
| Rejected | Wavelog refused the QSO. The reason is shown in plain language. Fix the QSO and it is queued again. |
| Blocked | Your token expired or was revoked. Enter a new token. |

The **tide gauge** shows how many QSOs are still waiting to sync. When the tide is out, everything is synced.

**Sync history** lists every step, with the server's original answer for each QSO.

Sync runs when you open the app, when your connection comes back, and when you tap **Sync now**. iPhone and iPad do not
allow reliable background syncing, so open Tideline when you're back online.

## Before a large upload

When more than 50 new QSOs are waiting, for example after an ADIF import, Tideline doesn't upload them automatically.
The Sync screen shows **Preview upload** with three things:
- how many QSOs will be uploaded;
- how many look like duplicates of QSOs you already have;
- what Wavelog's own test run says.

Choose **Upload** to send them.

## When a QSO needs your decision

Wavelog's API can't change the **time, mode, frequency or station** of an uploaded QSO. If you change one of these,
the QSO shows **Needs decision**, and you choose:
- **Replace in Wavelog:** the old entry is deleted and the corrected QSO is uploaded. This needs the `qso:delete`
  permission.
- **I'll fix it in Wavelog:** Tideline leaves the Wavelog entry alone. Make the same correction there.
