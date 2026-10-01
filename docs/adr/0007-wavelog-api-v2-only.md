# 0007. Use Wavelog API v2 only

- Status: accepted
- Date: 2026-10-01

## Context
- API v2 (Wavelog 3.1.0+) has scoped, expiring bearer tokens, consistent JSON errors, rate-limit signalling, QSO CRUD,
  stations and (from 3.2.0) contest sessions.
- The legacy API puts keys in request bodies and URLs, and has no scopes.
- What only the legacy API has: a version endpoint for non-admins, and radio `cat_url`. See
  [wavelog-api.md](../architecture/wavelog-api.md).

## Decision
- Tideline uses API v2 exclusively.
- The server version is not read. Capabilities are probed instead: `status`, `token`, and `catalog` (for 3.2+).
- Servers older than 3.1.0 are unsupported, and onboarding says so clearly.

## Consequences
- Least-privilege tokens, and no API keys in URLs.
- Users on Wavelog older than 3.1.0 must upgrade.
