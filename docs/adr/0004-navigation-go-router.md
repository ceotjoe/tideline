# 0004. Navigation: go_router

- Status: accepted
- Date: 2026-10-01

## Context
- We need deep links (opening ADIF files, pairing links), adaptive shells (navigation rail vs bottom bar), and nested
  panes on tablets.
- Verified 2026-10: go_router 18.0.2 is maintained by the Flutter team and declared *feature-complete*: bug fixes and
  stability only.

## Decision
- Use go_router with `StatefulShellRoute` for the top-level sections.
- Multi-pane tablet layouts are handled **inside** screens, keyed on size class, not as separate routes. Resizing therefore
  never changes the route or loses state.

## Consequences
- A feature-complete package suits a long-lived app.
- If go_router ever stops being maintained, routes are declared in one file, which limits the migration cost.
