# Security and privacy (SP)

The rules are in `CLAUDE.md`, `PRIVACY.md` and `docs/security/threat-model.md`. Never put a real token in a report; use a
throwaway token and revoke it afterwards.

### SP-01 The token stays in the secure store
**P1 · all · Needs: a throwaway token**
Enter the token. Then look in: the app's screens, settings, the ADIF and Cabrillo exports, a backup file (open it in a
text editor), a screenshot, the device log (`adb logcat`, Console, Event Viewer), and a shared crash or bug report.

**Expected:** the token appears nowhere except the field you typed it into (and masked there). The backup does not
contain it and says so.

Result:

### SP-02 No network without an action
**P1 · all · Needs: a network monitor (Little Snitch, Proxyman, Charles, a router log, or `adb` packet capture)**
Install, set up with the demo account, then with a real Wavelog. Use the app for 30 minutes including idle time.

**Expected:** the only hosts contacted are your Wavelog server(s) and, only when you start a download, the documented
reference-list sources. No analytics, crash reporting, font, ad or update-check host. The demo account makes no request.

Result:

### SP-03 TLS
**P1 · all · Needs: a self-signed HTTPS server and a plain-HTTP LAN server**
1. Connect to the self-signed server: compare the shown fingerprint, trust it. Replace the server's certificate and sync.
2. Try a plain `http://` public address, and then a private-LAN address.

**Expected:** the fingerprint dialog warns clearly; trusting works; a changed certificate is refused with an explanation
and nothing is uploaded. There is no "disable TLS validation" option. Plain HTTP to a public address is refused; to a
private-LAN address it needs a warned opt-in.

Result:

### SP-04 Hostile ADIF
**P1 · all · Needs: crafted files (the repository's fuzz corpus under `packages/tideline_adif`)**
Import: a truncated file, a field with a wrong length, a huge field length, nested `<` and `>`, invalid UTF-8, a file of
200 MB, and an ADIF with an unknown field.

**Expected:** no crash or hang; the import reports the bad record or refuses the file with a message; valid records
around a bad one survive; unknown fields are kept in `adif_extra`.

Result:

### SP-05 Hostile server responses
**P2 · all · Needs: the mock server modified, or a proxy**
Return garbage JSON, a very large body, a wrong content type, a redirect to another host, and an error with HTML.

**Expected:** a plain error message, no crash, no redirect to another host followed with the token, nothing logged with
personal data.

Result:

### SP-06 Backup and files
**P1 · all · Needs: nothing**
1. Open a backup file in a hex viewer. Try restoring a file with a flipped byte, and a gigantic file.
2. On iOS check that Tideline's data is not in iCloud (Settings → your name → iCloud → Manage Storage); on Android check
   that it is not in Google's backup; on a desktop check where the data lives.

**Expected:** the backup is plain and says so; tampering is detected (hash) and refused with a message; the size limit is
enforced; the database is excluded from cloud backups.

Result:

### SP-07 App lock
**P2 · iOS, Android · Needs: Face ID, a fingerprint or a PIN**
Turn on the lock, leave the app, return. Fail the biometric, then use the passcode. Reboot.

**Expected:** the app asks every time; the fallback works; a cancelled prompt leaves the log hidden; the lock is
independent of encryption (there is none).

Result:

### SP-08 Logs and crash output
**P1 · all · Needs: a debug build and a release build**
Provoke errors (revoked token, bad server answer, bad file). Read the logs.

**Expected:** callsigns, names, locators and tokens are redacted or absent in logs; no QSO list in a stack trace.

Result:

### SP-09 Permissions and policy files
**P1 · all · Needs: the store builds**
Check the OS permission list for the app, `PrivacyInfo.xcprivacy`, the Android manifest, the MSIX capabilities, and
`ITSAppUsesNonExemptEncryption`.

**Expected:** only network (and biometric for the lock; local network only for a LAN server) is requested; no location,
camera, contacts, notification or storage permission; `ITSAppUsesNonExemptEncryption` is `false`; `PRIVACY.md`
matches what the store forms say.

Result:
