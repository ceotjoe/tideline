# Privacy Statement

_Last updated: 2026-10-02. Applies to Tideline on all platforms._

Tideline is an open-source logging app for licensed amateur radio operators.

## Summary

Tideline collects **no data about you**. There is no telemetry, no analytics, no advertising, no crash
reporting service and no third-party tracker. The developers never receive your data.

## Data stored on your device

| Data | Purpose | Protection |
|---|---|---|
| Your QSO log (callsigns, times, frequencies, locations, notes) | The app's core function | Encrypted database (SQLite3MultipleCiphers); key held in the OS secure store |
| Wavelog server address and API token(s) | Syncing to your own Wavelog | Token kept only in the OS secure store (Keychain, Android Keystore, Windows protected storage) |
| Pinned server certificate fingerprints | Trusting your self-hosted server | Encrypted database |
| Downloaded reference data (DXCC, SOTA, POTA, WWFF, call history, MASTER.SCP) | Offline lookups | Encrypted database |
| Worked-before index (calls, bands and modes from your log and your Wavelog server) | "Worked before" hints | Encrypted database; rebuildable from settings |
| Contest definitions you import | Contest rules and scoring | Encrypted database |
| Device location (only while you ask for it) | Computing your Maidenhead grid locator | Used on device, stored only as the grid in your QSO / activation |
| Settings | Your preferences | Encrypted database |

Backups you export are encrypted with a passphrase you choose. Exports (ADIF, Cabrillo) are written only
where you save them.

## Network connections

Tideline connects only to:

1. **The Wavelog server(s) you configure.** It uploads your QSOs, creates and updates contest sessions
   (Wavelog 3.2+, if your token allows it), and downloads your station profiles and log (for "worked before"
   hints), using the API token you provide.
2. **Reference-data sources, and only when you start a download.**
   - The source URLs are shown before downloading and listed in the user manual.
   - These sites receive the usual technical data of a web request, such as your IP address.
   - Their own privacy policies apply.
   - **MASTER.SCP (super check partial):** when you press "Download" in Settings → Super check partial, Tideline
     fetches the address shown there (default `https://www.supercheckpartial.com/MASTER.SCP`, which you can
     change). Only HTTPS is allowed. The request contains no information about you or your log; it sends only a
     generic `Tideline/<version>` user agent. Tideline never contacts this address on its own.
3. **Other Tideline devices on your local network**, only when you pair them (a later feature).
   - Traffic stays in the local network and is end-to-end encrypted.

Nothing else. The app makes no "phone-home", update check or font download calls.

## Permissions

- **Location:** optional. Used only to compute your grid locator when you ask for it.
- **Camera:** optional. Used only to scan a pairing QR code (later feature).
- **Local network:** used only to reach a Wavelog server on your LAN, or for device pairing.
- **Biometrics:** optional. Used only for the app lock, evaluated by the OS. Tideline never sees biometric data.

## Children

Tideline is a tool for licensed radio amateurs and does not knowingly collect data from anyone.

## Your control

- All data stays on your device or on your own Wavelog server.
- Deleting the app deletes its local data. Remove an account in the app to delete its token from the secure store.

## Contact

Questions: open an issue at <https://github.com/ceotjoe/tideline> or contact the maintainer (DO1HOZ).
