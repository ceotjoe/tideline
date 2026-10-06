# Privacy Statement

_Last updated: 2026-10-05. Applies to Tideline on all platforms._

Tideline is an open-source logging app for licensed amateur radio operators.

## Summary

Tideline collects **no data about you**. There is no telemetry, no analytics, no advertising, no crash
reporting service and no third-party tracker. The developers never receive your data.

## Data stored on your device

| Data | Purpose | Protection |
|---|---|---|
| Your QSO log (callsigns, times, frequencies, locations, notes) | The app's core function | Local database on your device (plain SQLite, protected by the operating system; see below) |
| Wavelog server address and API token(s) | Syncing to your own Wavelog | Token kept only in the OS secure store (Keychain, Android Keystore, Windows protected storage) |
| Pinned server certificate fingerprints | Trusting your self-hosted server | Local database |
| Downloaded reference data (DXCC, SOTA, POTA, WWFF, call history, MASTER.SCP) | Offline lookups | Local database (during installation a list is briefly held in a temporary table; it contains only public reference data) |
| Worked-before index (calls, bands and modes from your log and your Wavelog server) | "Worked before" hints | Local database; rebuildable from settings |
| Callsign directory (name, place, locator and zones of the stations you worked, from your QSO history) | Showing what you know about a station while you log, offline | Local database; rebuildable from settings; never sent anywhere |
| Callsign notes (text you write about a station) | Your own memory aid | Local database; included in backups; never sent to Wavelog or exported to ADIF |
| Records of QSOs removed from this device to free space (local id, Wavelog id, time and a hash of the QSO's duplicate key; no callsign) | Not uploading or importing them again | Local database; not part of backups or exports |
| Activations (programme, reference, your grid square, start and end) | Activation logging and progress | Local database |
| Contest definitions you import | Contest rules and scoring | Local database |
| Settings | Your preferences | Local database |

**Tideline does not encrypt your data itself.** The local database and the backups you export are plain files. On the
device they are protected by the operating system (the lock screen and its storage protection), and Tideline asks iOS,
iPadOS and Android not to include them in iCloud, iTunes or Google backups. Backups and exports (ADIF, Cabrillo) are
written only where you save them and are **not encrypted**, so keep them somewhere safe. Only the API token is kept in
the OS secure store (Keychain, Android Keystore, Windows protected storage).

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
   - **SOTA, POTA and WWFF reference lists:** when you press "Download" (or "Update") on a list in Settings →
     Reference lists, Tideline fetches the address shown there. The defaults are the official files:
     `https://pota.app/all_parks_ext.csv`, `https://www.sotadata.org.uk/summitslist.csv` (which forwards to
     `https://storage.sota.org.uk/summitslist.csv`) and `https://wwff.co/wwff-data/wwff_directory.csv`. Only HTTPS is
     allowed. Each list is 10 to 25 MB. The requests contain no information about you or your log, only a generic
     `Tideline/<version>` user agent, and Tideline never contacts these addresses on its own. The operators of these
     sites see your IP address like for any web request.
3. **Other Tideline devices on your local network**, only when you pair them (a later feature).
   - Traffic stays in the local network. (Not built yet. Tideline ships no encryption of its own, ADR 0034, so this
     needs a design before it can be offered.)

The built-in **demo account** (Welcome screen) makes no network connection at all: its "server" runs inside the app.

Nothing else. The app makes no "phone-home", update check or font download calls.

## Permissions

- **Location:** not used. Tideline never asks for your position; you type your grid locator.
- **Camera:** not used. A later pairing feature may ask for it to scan a QR code, and this statement will change first.
- **Local network:** used only to reach a Wavelog server on your LAN, or for device pairing.
- **Biometrics:** optional. Used only for the app lock, evaluated by the OS. Tideline never sees biometric data.

## Children

Tideline is a tool for licensed radio amateurs and does not knowingly collect data from anyone.

## Your control

- All data stays on your device or on your own Wavelog server.
- Deleting the app deletes its local data. Remove an account in the app to delete its token from the secure store.

## Contact

Questions: open an issue at <https://github.com/ceotjoe/tideline> or contact the maintainer (DO1HOZ).
