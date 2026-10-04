# 0023. Settings as a hub of pages

- Status: accepted
- Date: 2026-10-04

## Context
- Settings were one scrolling list of ten sections (account, appearance, language, data, contest definitions, reference
  lists, super check partial, worked-before index, security, keyboard). A tester found it too cluttered, and v0.4 adds
  more (multiple accounts, field modes, callsign directory).
- Layouts follow the window size class, not the platform ([ADR 0010](0010-adaptive-size-classes.md)).

## Decision
- The Settings tab shows a hub: one list entry per group, each with an icon, a title and a one-line hint.
- Each group is its own page and its own `go_router` route under `/settings` (`account`, `appearance`,
  `reference-data`, `security`, `developer`), so deep links and the back stack work and the navigation stays visible.
  Tapping the Settings tab again returns to the hub.
- Groups: **Wavelog account**; **Appearance and language**; **Reference data** (reference lists, super check partial,
  contest definitions, worked-before index); **Security and backup** (app lock, ADIF import and export, encrypted
  backup). "Keyboard shortcuts" opens the overlay from the hub. A developer page exists in debug builds only.
- The sections themselves are unchanged widgets; only their container moved.
- No search for now: five entries do not need it. New settings go on the page they belong to; a group with nothing to
  hold is not created (the roadmap's "Logging" group waits for a setting that needs it).

## Consequences
- The hub is short at any text size; pages scroll on their own.
- Links from other screens must name the page (the activation screen opens **Reference data**).
- On a wide window the hub is still a list, not a master-detail pane. Step 6.4 (desktop navigation) may revisit that.
- The manual's paths changed (`Settings → Reference data → Super check partial`); `docs/manual/*/settings.md` lists them.
