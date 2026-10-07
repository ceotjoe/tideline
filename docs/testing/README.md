# Test plan for testers

This is the entry point for anyone who tests Tideline by hand. Automated tests (`tool/test_all.sh`, goldens, the
accessibility and l10n tests, the end-to-end test) run in CI and do not replace this. The hand tests cover what they
cannot: real devices, real screen readers, a real Wavelog and real use in the field.

**Build under test:** Tideline 0.6.0 (build 8).

## Pick your checklist

| You have | Use | Distribution |
|---|---|---|
| iPhone or iPad | [testflight.md](testflight.md) | TestFlight |
| Mac | [testflight.md](testflight.md) (sections 1, 2, 4, 5, 5b, 5c) and [desktop.md](desktop.md) | TestFlight for Mac, or the build from source |
| Android phone or tablet | [android.md](android.md) | Google Play internal or closed test |
| Windows PC | [desktop.md](desktop.md) | GitHub release: portable zip or MSIX |
| No Wavelog at all | Any checklist, using **Try the demo (no Wavelog needed)** on the Welcome screen | |

Everything that needs a real server (token problems, a self-signed certificate, contest sessions on Wavelog 3.2, the
reconcile after an interrupted upload) needs a real Wavelog 3.1 or newer. The demo account runs inside the app and
cannot test those.

## Rules for every tester
- Use a **test station location** or a test logbook so test QSOs stay out of your real log.
- Tideline has no telemetry. Nobody knows what you tested unless you report it.
- Never put a token or a private server address into a report; blur them in screenshots.
- Tick what works, write down what does not. You do not have to do it in one sitting.

## How to report
Same for every platform. TestFlight testers can use **Send Beta Feedback**. Everyone else opens an issue at
<https://github.com/ceotjoe/tideline/issues>. Include:
1. What you did, step by step, and what you expected.
2. What happened, with a screenshot if you can.
3. Build number, device or computer, OS version, language, text size, screen reader on or off.
4. Whether the network was on, and whether a real Wavelog was involved.

Mark the severity: **blocker** (data lost, duplicated or silently changed; token leaked; crash; cannot log), **major**
(a feature does not work or cannot be used with a screen reader or keyboard), **minor** (wrong text, layout glitch,
unclear message).

## Language pass (EN and DE)
Do this once per release, on one platform, in German. The language is set in-app (Settings → Appearance and language)
and is independent of the system language, so switch it there and also test the system default.

- [ ] Switch to **Deutsch** in the app while the system is English, and the other way round. Every screen on the way
  through onboarding, log, sync, contest, activation, callsigns and settings is in the chosen language. Nothing is
  half English.
- [ ] Look for cut-off words: German is longer. Check buttons, banners, dialogs and the tide gauge text at the largest
  text size.
- [ ] Error and sync explanations (token problem, duplicate, needs decision, rate limit) are understandable German, not
  a literal translation.
- [ ] Date and time are shown the way a German reader expects, but QSO times are UTC and say so.
- [ ] The first-run notice for testers who come from 0.5 (see testflight.md, section 5c) exists in German.
- [ ] With a screen reader on and German selected, callsigns are still read letter by letter.
- [ ] Optional: the pseudo-locale (right to left) in a debug build. Nothing overlaps and the order of fields is mirrored.
- [ ] Note wording that sounds wrong. Use the translation notes in [../translating.md](../translating.md).

## Exit criteria for v1.0
The store release (v1.0) goes ahead when all of these hold. The maintainer ticks them; testers feed them.

**Data safety**
- [ ] Across all platforms tested, no report of a lost, duplicated or silently changed QSO that was not fixed.
- [ ] Interrupting a sync (quit, airplane mode, killed app) on iOS, Android and one desktop OS never loses or duplicates a
  QSO, against a real Wavelog.
- [ ] A backup made on one device restores on another (iOS to iOS, Android to Android, desktop to desktop), and an
  ADIF export opens in a second logging program.

**Real-world use**
- [ ] One real or simulated contest run of 30 minutes or more with a Cabrillo file checked against the contest rules.
- [ ] One real activation (POTA, SOTA or WWFF) outdoors, including Field mode and the sunlight theme.
- [ ] One real Wavelog 3.1 and one 3.2 (contest sessions) tested.

**Accessibility**
- [ ] VoiceOver pass on iPhone and iPad (testflight.md, section 3) with no blocker or major open.
- [ ] TalkBack pass on Android (android.md, section 3) with no blocker or major open.
- [ ] Keyboard-only pass on Mac and on Windows (desktop.md).
- [ ] 200 % text on phone, tablet and a small desktop window without broken layouts.

**Platforms and stores**
- [ ] Android: the Play closed test has run for 14 days with at least 12 testers opted in (needed only if the developer
  account is a personal one created after 2023-11-13, see `docs/release.md`), and the production track is applied for.
- [ ] iOS and iPadOS: a build passes App Review using the demo account.
- [ ] macOS: a build passes review.
- [ ] Windows: the MSIX installs from the GitHub release on a clean PC, and Windows does not block the portable zip
  beyond the usual notice for a signed file.

**Language**
- [ ] The language pass above is done in German and English with no open major.

**Open issues**
- [ ] No open issue labelled blocker. Every major is fixed or written down under known limitations.
