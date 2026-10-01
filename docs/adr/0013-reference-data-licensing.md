# 0013. Reference data: bundle only what we may redistribute

- Status: accepted
- Date: 2026-10-01

## Context
Licence terms verified 2026-10:

| Source | Terms | Status |
|---|---|---|
| AD1C country files (`cty.dat`, country-files.com) | MIT-style; redistribution allowed if the notice is kept | verified |
| Club Log `cty.xml` | Per-developer permission / API key; not for bundling | verified via Club Log documentation references |
| WWFF directory | "No part … may be reproduced … without prior permission" | verified |
| SOTA summits list, POTA parks list, MASTER.SCP | No terms found | unknown |

## Decision
- **Bundle:** AD1C `cty.dat` only, with its copyright notice. It is the offline DXCC baseline from the MVP.
- **Everything else:** downloaded **by the user, on request**, directly from the official source URL to the device. The
  app shows the source before downloading. Tideline never mirrors or re-hosts these files.
- Packs record source, version, hash, fetch date and licence note, and the UI shows their age.
- The maintainer may ask WWFF, SOTA and POTA for permission. If it is granted, a new ADR may allow bundling.

## Consequences
- No licence risk for the project.
- First-time setup needs a connection to download SOTA, POTA, WWFF and SCP packs. The manual says so.
