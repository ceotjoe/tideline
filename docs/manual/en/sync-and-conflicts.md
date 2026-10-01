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
