# 0033. Request economy towards Wavelog

- Status: accepted
- Date: 2026-10-06

## Context
- A review of the sync code (not a traffic measurement) found that every run, even an idle one, made three GETs:
  `/token`, `/station` and the worked-before pull. A run started on every QSO save, app resume and connectivity change, with
  no minimum gap.
- Connectivity events come in bursts (a Wi-Fi/cellular handover fires several), so one handover could start several runs.
- After a 429 the run stopped and each affected QSO got `nextAttemptAt`, but nothing started the next run. A backlog
  stalled until the user logged, resumed or tapped *Sync now*.
- Wavelog's limits are per token and resource (documented example: 60/60 s default, `qso` 120/60 s).

## Decision
- **Cached refresh.** `SyncEngine` skips `/token` and `/station` when the last successful refresh for that account and token
  is younger than `refreshInterval` (1 hour). It refreshes at once on a manual *Sync now*, when the token changed, after a
  401 (account blocked) or a 403, and when the clock moved backwards. The cache is in memory only and holds a hash of the
  token, never the token.
- **Debounced automatic triggers.** App resume and connectivity regained go through `SyncScheduler.requestAutomatic`, which
  waits 5 s of quiet and then starts one run. Saving a QSO and *Sync now* still run immediately: logging must feel instant.
- **Rate-limit retry, foreground only.** A run that ends `rateLimited` reports the server's `Retry-After`;
  `SyncController` schedules one run at `Retry-After` + 1 s. The retry is dropped when the app leaves the foreground, and
  any other run cancels it. This promises nothing in the background: on iOS the resume trigger picks up on return.

## Consequences
- **Pros:**
  - An idle run costs one request instead of three.
  - A connection handover costs one run instead of several.
  - A backlog that hits a limit finishes without the user having to nudge it.
- **Cons:**
  - A changed scope or station list can take up to an hour to show up, unless the user syncs manually or the server refuses a
    request.
  - An automatic run after resume starts 5 s later.
  - If a server keeps answering 429, Tideline retries once per `Retry-After` (1 s to 1 h) while the app is open.
- POSTs are still not paced; the limit is reacted to, not predicted, because it is server configuration we cannot read.
