# Test cases before v1.0

These are the hand-test cases that must pass before the store release (v1.0). The platform checklists
([testflight.md](../testflight.md), [android.md](../android.md), [desktop.md](../desktop.md)) are walk-throughs of the
whole app. The cases here are narrower: one risk, exact steps, one expected result, so a pass or a fail is not a matter
of opinion. Automated tests (`tool/test_all.sh`) run in CI and are not repeated here; these cases cover what they cannot.

**Valid for:** Tideline 0.7.x. Re-check the wording of a case when a feature it touches changes (see "Keeping this
current").

## Files

| File | Area | Case ids |
|---|---|---|
| [data-safety.md](data-safety.md) | Sync, interruptions, duplicates, backup, ADIF, freeing space | DS-01 to DS-14 |
| [logging.md](logging.md) | Entry, UTC time, frequency, callsign directory, Fast Log Entry, accounts | LG-01 to LG-10 |
| [contest.md](contest.md) | Contest sessions, serials, dupes, scoring, Cabrillo | CT-01 to CT-08 |
| [activations.md](activations.md) | Reference lists, SOTA, POTA and WWFF activations | AC-01 to AC-07 |
| [accessibility-language.md](accessibility-language.md) | Screen readers, keyboard, text size, themes, EN and DE | AL-01 to AL-10 |
| [security-privacy.md](security-privacy.md) | Token, TLS, network, untrusted input, logs | SP-01 to SP-09 |
| [platforms-stores.md](platforms-stores.md) | Install, upgrade, store review, release artefacts | PS-01 to PS-10 |

## Priority
- **P1**: must pass on every platform it applies to. A failure blocks v1.0.
- **P2**: must pass on at least one platform per OS family (Apple, Android, Windows). A failure on another platform
  is a major issue, not necessarily a blocker.
- **P3**: should pass. A failure is written down under known limitations if it is not fixed.

## Reading a case
Each case has:
- **Priority and platforms**: `iOS`, `iPadOS`, `Android`, `macOS`, `Windows`, or `all`.
- **Needs**: a real Wavelog (version), the mock server (`dart run bin/serve.dart` in `packages/wavelog_mock`, token
  `wl2_demo_token`), the demo account, or nothing.
- **Steps** and **Expected**. Anything not in Expected is not required, but note surprises.
- **Result**: fill in one line per platform tested, as `platform · build · date · pass/fail · issue link`.

The demo account and the mock server cannot test certificates, token problems, Wavelog 3.2 contest sessions or the
reconcile after an interrupted upload; those cases say **real Wavelog**.

## Setting up
- Use a test station location or a test logbook on your Wavelog. Deleting QSOs on Wavelog needs `qso:delete`.
- Keep a second Wavelog (or a second station location) for the multi-account cases.
- Have ready: a Wavelog 3.1.x and a 3.2.x server, one self-signed HTTPS server, a hardware keyboard for the iPad and the
  Android tablet, and a screen reader per platform.
- Never put a token or a private server address in a report.

## Recording results
Copy the **Result** lines into the release issue for v1.0 (one issue, one table) or into a file under
`docs/testing/results/` named `<version>-<platform>.md`. A case counts as passed only when its Expected block was
checked in full on that platform and build. The exit criteria in [../README.md](../README.md) are satisfied by these
cases as follows:

| Exit criterion | Cases |
|---|---|
| Data safety | DS-01 to DS-14 |
| Real-world use | CT-01 to CT-08, AC-01 to AC-07 |
| Accessibility | AL-01 to AL-10 |
| Platforms and stores | PS-01 to PS-10 |
| Language | AL-08 to AL-10 |
| Security and privacy | SP-01 to SP-09 |

## Keeping this current
- Every release that changes a feature updates the cases that touch it, in the same change as the CHANGELOG entry.
- A bug found after release gets a case here if it could come back unnoticed (use the next free id in its area).
- The build line of the checklists and the "Valid for" line above move with the version bump.
