# 0016. Product decisions for the MVP

- Status: accepted
- Date: 2026-10-02

## Context
Phase 0 left a set of open questions. The maintainer answered them before Phase 2.

## Decision

| Topic | Decision |
|---|---|
| Minimum Wavelog | **3.1.0** for logging and sync. Contest-session sync only when the probe detects **3.2.0+** (ADR 0007). |
| Optional token scopes | Onboarding offers three opt-ins, each with a plain-language explanation: **`qso:delete`**, **`contest:read` + `contest:write`** and **`lookup:read`**. Required scopes stay `qso:read`, `qso:write`, `station:read`. |
| Editing read-only fields after sync | Changing time, mode, frequency or station of a synced QSO moves it to `conflict`. **The user decides:** "Replace on server" (delete + re-create; only offered when `qso:delete` is granted; the server id changes) or "I'll fix it in Wavelog" (the QSO is marked as resolved locally and left untouched on the server). |
| Reference data | As ADR 0013: bundle only AD1C `cty.dat`; everything else is a user-initiated download from the official source. |
| Reading font | Bundle **Atkinson Hyperlegible** (SIL OFL 1.1) as an optional font. It is never downloaded at runtime. |
| Windows distribution | **Signed MSIX via GitHub releases first**; the Microsoft Store may follow later. |
| Repository | Public at github.com/ceotjoe/tideline. |

## Consequences
- The conflict screen needs two clearly explained actions, and "Replace on server" has to be hidden when the token
  lacks `qso:delete`.
- The font and its licence file ship in `app/assets/fonts/`; `PRIVACY.md` stays accurate (no font downloads).
