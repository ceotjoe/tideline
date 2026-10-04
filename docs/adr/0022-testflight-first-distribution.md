# 0022. Distribution: TestFlight first, stores later

- Status: proposed
- Date: 2026-10-04

## Context
The maintainer wants to test with VoiceOver and TalkBack and run a real contest and a real activation on devices, and
for that needs a build that can be installed outside Xcode: **TestFlight on iOS and iPadOS** first.

Verified from the repository (2026-10-04):
- Bundle ID `com.ITWebService.tideline` and an Apple development team are set in the iOS project, with automatic signing
  (ADR 0015, `app/ios/Runner.xcodeproj`). `docs/release.md` said the team still had to be configured; that was out of
  date.
- Version `0.0.1+1` in `app/pubspec.yaml`; `appVersion` in `app/lib/src/app_version.dart` is kept equal by a test.
- `.github/workflows/release.yml` builds an unsigned or signed IPA but does not upload and has no provisioning or
  App Store Connect credentials.
- There is no `PrivacyInfo.xcprivacy` and no `ITSAppUsesNonExemptEncryption` key in `Info.plist`.
- The app has no path without a Wavelog server: without an account the router always shows onboarding.

Verified from Apple's public documentation and forums (not from our code):
- Builds for external testers need Beta App Review once per version, with a beta description, a feedback address and,
  if the app requires sign-in, working demo credentials. Internal testers (up to 100 App Store Connect users) need no
  review.
- Missing export-compliance answers block a build. Setting `ITSAppUsesNonExemptEncryption` in `Info.plist` answers the
  question for every upload. Encryption built into the OS (HTTPS) is exempt; our own use (SQLite3MultipleCiphers with
  ChaCha20, Argon2id and XChaCha20-Poly1305 for backups) is the part the maintainer must classify.
- Since 2024-05-01 an upload needs a privacy manifest that declares the "required reason" APIs the app's code uses
  (file timestamps, boot time, disk space, user defaults, active keyboards).

## Decision
1. **First target: iOS and iPadOS through TestFlight, internal testers first.** Android internal testing, macOS (Mac App
   Store or notarised download) and Windows follow after the first TestFlight round.
2. **Version 0.3.0** is the first TestFlight version (Phase 4 is complete). The build number counts up on every upload
   (`+1`, `+2`, …); CI uses the run number once uploads are automated. `app/pubspec.yaml`, `appVersion` and
   `msix_version` stay in step.
3. **Nothing is added to the app for diagnostics.** No telemetry, no crash reporter (CLAUDE.md). Testers can use
   TestFlight's own feedback and crash sharing, which is Apple's and opt-in for the tester.
4. **Privacy manifest and export compliance are part of the build**, not of the store listing:
   `app/ios/Runner/PrivacyInfo.xcprivacy` (no tracking, no collected data, the required-reason APIs found in the
   Xcode privacy report of a real archive) and the `ITSAppUsesNonExemptEncryption` value the maintainer decides.
5. **Uploads start manual** (Xcode or Transporter) and get automated with an App Store Connect API key once the first
   build has passed. The key is a repository secret and never enters the repository.

## Consequences
- A tester needs a Wavelog server and a token to get past onboarding. For internal testers that is the maintainer's own
  server. For Beta App Review and later App Review it must be solved: see the open decision in the Phase 5 plan.
- The release workflow needs an Apple section with provisioning and upload; `docs/release.md` describes it.
- Export classification and the answers in App Store Connect (privacy "nutrition label", encryption, age rating) are the
  maintainer's to give. Tideline's `PRIVACY.md` is the source for them.
