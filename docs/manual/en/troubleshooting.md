# Troubleshooting

| What you see | What to do |
|---|---|
| "Your Wavelog isn't reachable right now" | Nothing is lost. Tideline syncs when the app is opened again, when the connection returns, or when you choose **Sync now**. |
| QSOs show **Checking** | A previous attempt was interrupted. Tideline asks your Wavelog whether the QSO arrived before sending it again, so nothing is duplicated. |
| **Token problem** | The token expired or was revoked. Create a new one in Wavelog and enter it under **Settings → Enter a new token**. Waiting QSOs then sync. |
| **Rejected** | Open the QSO: it explains the problem and shows Wavelog's own message. Correct the QSO and it is sent again. |
| **Needs decision** after changing time, mode, frequency or station | Wavelog can't change these fields on an uploaded QSO. Choose **Replace in Wavelog** (needs the qso:delete permission) or **I'll fix it in Wavelog**. |
| "Another QSO with the same callsign … in the same minute" | Wavelog stores only one QSO per callsign, band, mode and minute. Correct the time if it was a separate contact, or delete one of them. |
| "Unknown certificate" during setup | Normal for self-hosted servers. Compare the fingerprint with your server's, then trust it. |
| "Your log can't be unlocked" when starting | The key in your device's secure storage is missing, which can happen after restoring the device. Nothing is deleted. Restore a Tideline backup, or reinstall to start over. |
| iPhone/iPad doesn't sync in the background | Correct: iOS does not allow reliable background syncing. Open Tideline when you're back online. |
