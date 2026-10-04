# 0024. Multiple Wavelog accounts: one active account for logging

- Status: accepted
- Date: 2026-10-04

## Context
- The data model already keys every QSO, contest session, activation, station list, sync journal and worked-before
  entry by `account_id`, and the app already had an active account (`account.active`). Only the UI to add, switch,
  rename and remove accounts was missing (v0.4 proposal A; maintainer decision: a switcher, not a choice per QSO).
- Removing an account failed with a foreign-key error when it had contest sessions, activations or a worked-before
  index, because the purge only knew about QSOs and stations.

## Decision
- **One active account for logging.** The log screen, the entry form, contests and activations use it. There is no
  per-QSO account choice.
- **Where.** Settings → *Wavelog accounts* lists the accounts (state in text: "In use for logging", the number of QSOs
  waiting) and *Add account*; each account has its own page (rename, use for logging, enter a new token, remove). On
  the log screen an account menu appears from the second account on.
- **Adding** reuses the onboarding flow at `/add-account`: it starts at the server step, can be cancelled, and does not
  make the new account active (an activation or contest could be running). It lands on the new account's page.
  Names are made unique ("Club", "Club 2"): two accounts on one server are legitimate.
- **Switching is refused while a contest session or an activation runs** (both belong to the account), with the reason
  in text. They are ended first.
- **Sync covers all accounts**, the active one first, so QSOs of an account you switched away from still reach their
  server (recovery after a restart runs once per account). A large first upload still waits for review, per account:
  the other accounts sync, the review dialog names the waiting one. The sync screen shows the waiting QSOs per account.
- **Removing** offers *Export log, then remove* (ADIF of that account; if saving fails or is cancelled the account
  stays) or plain *Remove*, after a warning that counts the QSOs that never reached Wavelog. Keeping the QSOs of a
  removed account on the device is not offered: every row belongs to an account. The purge deletes in dependency order
  (links and serials, QSOs, sessions, activations, index, stations, account), clears the account's settings and
  token, and tells the database streams. Nothing is ever deleted on the server.
- **Import and export** act on the active account and say which.

## Consequences
- With one account nothing new shows on the log screen.
- The tide gauge keeps its sum; the per-account numbers are text on the sync and accounts pages.
- Per-account worked-before indexes are built for the active account when it becomes active (as before).
- Moving a QSO between accounts, and a per-account default for the account menu, are not part of this step.
