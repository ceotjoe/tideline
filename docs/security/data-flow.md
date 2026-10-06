# Data flow

```mermaid
flowchart LR
  subgraph device["User device"]
    UI[Tideline UI] <--> DB[(Local DB<br/>plain SQLite, OS protection)]
    KS[[OS secure store<br/>API tokens]]
    KS --> SYNC[Sync engine]
    DB <--> SYNC
    FILES[/ADIF · Cabrillo · plain backups/] <--> UI
    GPS[Location, on demand] --> UI
  end
  SYNC -- HTTPS, Bearer token, optional TOFU pin --> WL[(User's Wavelog server)]
  UI -- user-initiated HTTPS download --> REF[(Reference sources:<br/>SOTA · POTA · WWFF · SCP)]
  SYNC <-. later: LAN, paired, design open .-> PEER[Other Tideline device]
```

| # | Flow | Data | Protection |
|---|---|---|---|
| F1 | UI ↔ DB | QSOs, settings, packs | Plain file, protected by the OS (device lock, storage protection) and excluded from cloud backups (ADR 0034). |
| F2 | Sync ↔ Wavelog | QSOs, station list, the user's log (worked-before) | TLS (platform roots or a pinned leaf), a scoped bearer token, strict JSON parsing |
| F3 | UI → reference sources | Download only. Nothing about the user is sent beyond the HTTP request itself. | TLS, size limits, a hash recorded, strict parsing |
| F4 | Files ↔ UI | ADIF/Cabrillo exports and imports; backups | Imports are parsed strictly (and fuzzed). Backups are plain, hash-checked gzip files (not encrypted, ADR 0034); restore caps the decompressed size. |
| F5 | Location → UI | Coordinates, converted to a Maidenhead grid on the device | Never stored raw. Never sent anywhere except as a grid in a QSO. |
| F6 | Device ↔ peer (later) | QSOs | Not built. Needs a design that adds no encryption of our own (ADR 0034) |

Trust boundaries: between the device and every external system (F2, F3, F6), and between the app and imported files (F4).
