# Data flow

```mermaid
flowchart LR
  subgraph device["User device"]
    UI[Tideline UI] <--> DB[(Encrypted DB<br/>SQLite3MultipleCiphers)]
    KS[[OS secure store<br/>DB key · API tokens]] --> DB
    KS --> SYNC[Sync engine]
    DB <--> SYNC
    FILES[/ADIF · Cabrillo · encrypted backups/] <--> UI
    GPS[Location, on demand] --> UI
  end
  SYNC -- HTTPS, Bearer token, optional TOFU pin --> WL[(User's Wavelog server)]
  UI -- user-initiated HTTPS download --> REF[(Reference sources:<br/>SOTA · POTA · WWFF · SCP)]
  SYNC <-. later: LAN, E2E-encrypted, paired .-> PEER[Other Tideline device]
```

| # | Flow | Data | Protection |
|---|---|---|---|
| F1 | UI ↔ DB | QSOs, settings, packs | Encrypted at rest. The key is in the secure store. |
| F2 | Sync ↔ Wavelog | QSOs, station list, the user's log (worked-before) | TLS (platform roots or a pinned leaf), a scoped bearer token, strict JSON parsing |
| F3 | UI → reference sources | Download only. Nothing about the user is sent beyond the HTTP request itself. | TLS, size limits, a hash recorded, strict parsing |
| F4 | Files ↔ UI | ADIF/Cabrillo exports and imports; backups | Imports are parsed strictly (and fuzzed). Backups are encrypted with a user passphrase (Argon2id → AEAD). |
| F5 | Location → UI | Coordinates, converted to a Maidenhead grid on the device | Never stored raw. Never sent anywhere except as a grid in a QSO. |
| F6 | Device ↔ peer (later) | QSOs | Pairing by QR code; mutually authenticated, end-to-end encrypted |

Trust boundaries: between the device and every external system (F2, F3, F6), and between the app and imported files (F4).
