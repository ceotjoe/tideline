# Releasing Tideline

Releases follow [Semantic Versioning](https://semver.org). Pushing a tag `vX.Y.Z` runs
`.github/workflows/release.yml`, which builds release artifacts for every platform plus an SBOM (SPDX).

## Required repository secrets

Add these under **Settings → Secrets and variables → Actions**. Without them the workflow still runs, but builds unsigned
artifacts and prints a warning.

| Secret | Used for |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | Upload keystore (`.jks`), base64-encoded |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore password |
| `ANDROID_KEY_ALIAS` | Key alias |
| `ANDROID_KEY_PASSWORD` | Key password |
| `APPLE_CERT_P12_BASE64` | Apple distribution certificate (`.p12`), base64-encoded |
| `APPLE_CERT_PASSWORD` | Its password |
| `WINDOWS_CERT_PFX_BASE64` | Code-signing certificate for the MSIX (`.pfx`), base64-encoded |
| `WINDOWS_CERT_PASSWORD` | Its password |
| `WINDOWS_PUBLISHER` | Publisher subject of that certificate, e.g. `CN=…` (must match exactly) |

Encode a file with: `base64 -i file.jks | pbcopy` (macOS).

## Not automated yet

- **Apple:**
  - The iOS project already has a development team and automatic signing (checked 2026-10-04), so a local
    `flutter build ipa` signs with the maintainer's certificates. CI has no provisioning profile and no App Store Connect
    credentials yet.
  - Upload to App Store Connect (manual until step 5.4 of the Phase 5 plan, see
    [ADR 0022](adr/0022-testflight-first-distribution.md)).
  - The Mac App Store build needs its own certificates, provisioning profile and `ExportOptions.plist`.
  - After that, the macOS app can switch to the data-protection keychain (ADR 0006).
- **Google Play upload:** planned via the Play Developer API once a service account exists. Until then, upload the AAB
  artifact manually.
- **Microsoft Store:** only if Store distribution is chosen. `msix_config.store` is `false` for now, meaning direct MSIX.

## Checklist

1. `CHANGELOG.md`: move *Unreleased* items into a new version section.
2. Bump `version:` in `app/pubspec.yaml` (and `msix_version`).
3. Tag `vX.Y.Z` and push.
4. Attach artifacts and the SBOM to the GitHub release.

## First TestFlight build (iOS and iPadOS, manual)

Prerequisites, all in the maintainer's Apple account: an app record for `com.ITWebService.tideline` in App Store
Connect, and the privacy manifest and export-compliance answer from step 5.1 of the roadmap in the build.

1. Choose the version and build number. The version is `0.4.0` for this round (`0.3.0` had builds 1 and 2, `0.3.1` builds 3 and 4). The build
   number keeps growing across versions (`5` for 0.4.0, then `6`, …), which also keeps the Play `versionCode` and the
   Mac builds in order. Keep `app/pubspec.yaml`, `app/lib/src/app_version.dart` (`appVersion`) and `msix_version` in
   step.
2. From `app/`: `flutter build ipa --release --build-name 0.4.0 --build-number <N>`. The IPA lands in
   `app/build/ios/ipa/`.
3. Upload it with the Transporter app (drag the IPA in, **Deliver**).
4. In App Store Connect → TestFlight: wait for processing, answer any compliance question, add an **internal** testing
   group and install through the TestFlight app. External testers need Beta App Review: a beta description, a feedback
   address and a way for the reviewer to get past onboarding (a Wavelog address and token).
5. Test with the checklist in the roadmap (VoiceOver, a contest run, an activation) and note findings as issues.

Checked on 2026-10-04: `flutter build ios --release --no-codesign` succeeds (29.8 MB, minimum iOS 16.0) and contains
`sqlite3mc.framework`, which has no privacy manifest of its own.

## Privacy manifest (iOS)

`app/ios/Runner/PrivacyInfo.xcprivacy` declares no tracking, no tracking domains and no collected data, plus the
"required reason" APIs that code in the app uses without a manifest of its own. Plugins and Flutter bring their own
manifests; `sqlite3mc.framework` does not. Checked with `nm -u` on the release build of 2026-10-04: it imports `stat`,
`fstat`, `lstat`, `utimes` and `futimes` (file timestamps) and `statfs` and `fstatfs` (disk space).

- File timestamps: `C617.1`, files inside the app's own container (the database and its journal).
- Disk space: `E174.1` is the closest approved reason. SQLite does not check free space for its own sake: it calls
  `statfs` to recognise the file system when it chooses a locking method. If Apple's validation or a review objects,
  change the reason here and in the manifest; nothing else depends on it.

After every dependency update, repeat the check: build for release, then `nm -u` on each framework in
`Runner.app/Frameworks` and compare with the manifest. In Xcode, *Product → Archive → Generate Privacy Report* gives
the combined report.

## Android: first test build and Google Play

Package name `com.ITWebService.tideline` (kept on purpose, ADR 0015; it is permanent once uploaded). Signing is read from
`app/android/key.properties`, which is git-ignored together with every `*.jks` and `*.keystore`.

### 1. Create the upload key (once, on your computer)
Keep the keystore and its passwords out of the repository and out of chat. Back them up: with Play App Signing a lost
upload key can be reset through Play support, but it costs days.

```bash
keytool -genkeypair -v -keystore ~/tideline-upload.jks -storetype JKS -keyalg RSA -keysize 2048 \
  -validity 10000 -alias upload
```

Then create `app/android/key.properties` (never commit it):

```properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=/Users/<you>/tideline-upload.jks
```

Checked on 2026-10-04: `flutter build appbundle --release` succeeds (69.4 MB, debug-signed without `key.properties`).

### 2. A signed build for your own device (TalkBack tests, no Play needed)
```bash
cd app && flutter build apk --release --build-name 0.4.0 --build-number 5
adb install -r build/app/outputs/flutter-apk/app-release.apk
```
Without `key.properties` the build is signed with the debug key and Play will refuse it, but it installs for testing.

### 3. Google Play
1. Play Console → **Create app**: name, default language, App (not game), free, accept the declarations.
2. **App content** (required before any track works): privacy policy URL (a public page; `PRIVACY.md` on GitHub works),
   app access (the app needs a Wavelog server: give the demo address and token, as for Apple), ads (none), content rating
   questionnaire, target audience (not for children), and the **Data safety** form. From `PRIVACY.md`: no data collected
   or shared, no tracking. The merged manifest of the release build (checked 2026-10-04) has `INTERNET`, `ACCESS_NETWORK_STATE`
   (connectivity check), `USE_BIOMETRIC` and `USE_FINGERPRINT` (app lock), minSdk 24 and targetSdk 36.
3. Build the bundle: `cd app && flutter build appbundle --release --build-name 0.4.0 --build-number <N>`.
   The `versionCode` is the build number and must grow with every upload. Output:
   `build/app/outputs/bundle/release/app-release.aab`.
4. **Testing → Internal testing** → create a release → upload the AAB, accept Play App Signing → add testers by email
   (up to 100) → copy the opt-in link. Internal testers get the build within minutes and need no review.
5. **Personal developer accounts created after 2023-11-13** must run a **closed test** with at least 12 testers opted in
   for 14 days before they can apply for production (Google's rule; organisation accounts and older accounts are
   exempt). Internal testing does not count. Check your account type in Play Console and start the closed test early.

Not automated yet: the upload. The release workflow builds the AAB; uploading through the Play Developer API needs a
service account (step 5.4).

## macOS: Mac App Store and TestFlight

Prepared on 2026-10-04: privacy manifest, languages, category `public.app-category.utilities` (change it in
`app/macos/Runner/Info.plist` if you prefer another), the local-network text (macOS asks for it too) and
`app/macos/ExportOptions.plist`. `flutter build macos --release` works (60.2 MB, universal, sandbox with
network client and user-selected files; `sqlite3mc` imports the same APIs as on iOS, so the manifest is the same).
**Not done:** a signed archive, an upload, and a run of the signed app. The project has **no development team** on
purpose: CI builds the Mac app without certificates, and a team with automatic signing would make those builds fail. The
team comes from a git-ignored file instead (see below).

### In the Apple Developer account (once)
1. Register the App ID for iOS **and macOS** (no capabilities; see the Android and iOS notes above), or add macOS to the
   existing one.
2. Certificates: **Apple Distribution** and **Mac Installer Distribution** (Xcode creates them with *Manage
   Certificates*). The Mac App Store needs a provisioning profile for the app ("Mac App Store Connect" type); automatic
   signing in Xcode creates it.
3. In App Store Connect, add the macOS platform to the app record.

### Build and upload
Use the script. It reads your team from a git-ignored file and passes it to `xcodebuild`, because the project file sets
the ad hoc signing identity `-` that an `#include`d xcconfig cannot override (an archive made in Xcode with only the team
set comes out ad hoc and the Organizer says "No Team Found in Archive"; verified 2026-10-04).

1. Once: `cp app/macos/Runner/Configs/Signing.local.xcconfig.example app/macos/Runner/Configs/Signing.local.xcconfig`
   (git-ignored; set your team ID inside). Do not choose the team in Xcode's *Signing & Capabilities* tab: that writes
   `DEVELOPMENT_TEAM` into `project.pbxproj`, and a team with automatic signing makes CI's certificate-less
   `flutter build macos` fail. A test (`app/test/contest/cabrillo_categories_test.dart`) fails if it ever reaches the file.
2. `tool/macos_archive.sh <build-number>` builds with Flutter (version and build number), archives with the team and
   checks that the archive really is signed by it. The archive is `app/build/macos/Tideline.xcarchive`. Checked on
   2026-10-04: it archives and is signed by team `Q486NF4XF6`.
3. Upload either with the script, `tool/macos_archive.sh <build-number> --upload` (exports with
   `app/macos/ExportOptions.plist`; **Xcode may create certificates and the provisioning profile in your Apple Developer
   account**, which is why this is an explicit flag; not run yet), or in Xcode: double-click the `.xcarchive`, then
   *Distribute App → App Store Connect → Upload*.
4. If git shows changes in `app/macos/Runner.xcodeproj` afterwards, newer Xcode only upgraded the file:
   `git checkout app/macos/Runner.xcodeproj`.
5. In TestFlight, install the build from the Mac **TestFlight** app. External macOS testers need Beta App Review like on iOS.

### What to check on the first signed run
- **The keychain.** macOS uses the legacy file-based keychain (`usesDataProtectionKeychain: false`, ADR 0006) because the
  data-protection keychain needs a provisioning profile with a keychain access group. Test: set up an account, quit,
  start again. The token and the database must still unlock, with no keychain password prompt. A build signed
  differently from an earlier one (development vs distribution) cannot read items of the other: expect to enter the
  token again on a Mac where you ran a development build before, and, if the database key is lost, "Your log can't be
  unlocked" (see the troubleshooting chapter). Use a clean Mac user or move `tideline.sqlite` aside first.
  If the legacy keychain does not work in the sandbox of the store build, switch to the data-protection keychain (a
  `keychain-access-groups` entitlement and the profile) and record it in ADR 0006.
- ADIF import and export and backups still work through the system pickers (sandbox).
- Connecting to a server in your own network (the local-network prompt) and to HTTPS servers.

### Not needed for the Mac App Store
Notarization and the hardened runtime are for direct downloads outside the store. If you later distribute a `.dmg`,
that is a separate runbook.

