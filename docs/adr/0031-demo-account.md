# 0031. Built-in demo account for testing and App Review

- Status: accepted
- Date: 2026-10-05

## Context
Onboarding needs a Wavelog server and a token. Testers and App Review (Apple guideline 2.1, Google "app access") cannot
get past it without one (ADR 0022, consequences). ADR 0022 left open how reviewers get in; the first idea was a hosted
demo Wavelog server.

## Decision
1. **The demo is an account whose server runs inside the app.** The Welcome step offers **Try the demo (no Wavelog
   needed)**. It runs the normal onboarding (probe, station list, `finish()`), so the demo account is an ordinary account
   and the sync engine, repositories and UI are unchanged.
2. **One seam.** `pinnedHttpClient()` returns an `InProcessClient` for the reserved host `demo.tideline.invalid`; the
   client answers from `MockWavelog` (package `wavelog_mock`) without a socket and fails for every other host. `.invalid`
   never resolves (RFC 6761), so even a bug in the seam cannot reach a real server.
3. **Fixtures.** One in-memory server per process with the public token `wl2_demo_token` (all scopes) and one invented
   station (`N0CALL`, `JO40`). What is uploaded stays until the app is closed; the local log is kept like any account's.
4. **Marked as demo.** The account list shows "Demo account: no server, nothing leaves this device" instead of the
   address (text, not colour). The demo account is removed like any account.
5. **In every build.** No flag: the reviewed binary is the shipped one, and users can try the app without a server.
6. **`wavelog_mock` becomes a normal dependency of `app`** (it pulls `shelf` into the binary). A separate
   `wavelog_demo` package would be cleaner and can be split out later.

## Consequences
- No hosted demo server to run or keep alive; App Review works offline. This replaces the hosted-server option
  (maintainer's earlier choice) for review; it can still be added.
- The demo does not prove the app works against a real server; that stays covered by the mock-based tests and the
  maintainer's own server.
- No new network access, permission or scope. The threat model and `PRIVACY.md` say so.
- The mock's fault injection that drops connections is not available in-process.
