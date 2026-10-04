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

1. Choose the version and build number. The version stays `0.3.0` for the first round; the build number grows with
   every upload (`1`, `2`, …). Keep `app/pubspec.yaml`, `app/lib/src/app_version.dart` (`appVersion`) and
   `msix_version` in step.
2. From `app/`: `flutter build ipa --release --build-name 0.3.0 --build-number <N>`. The IPA lands in
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
cd app && flutter build apk --release --build-name 0.3.0 --build-number 1
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
3. Build the bundle: `cd app && flutter build appbundle --release --build-name 0.3.0 --build-number <N>`.
   The `versionCode` is the build number and must grow with every upload. Output:
   `build/app/outputs/bundle/release/app-release.aab`.
4. **Testing → Internal testing** → create a release → upload the AAB, accept Play App Signing → add testers by email
   (up to 100) → copy the opt-in link. Internal testers get the build within minutes and need no review.
5. **Personal developer accounts created after 2023-11-13** must run a **closed test** with at least 12 testers opted in
   for 14 days before they can apply for production (Google's rule; organisation accounts and older accounts are
   exempt). Internal testing does not count. Check your account type in Play Console and start the closed test early.

Not automated yet: the upload. The release workflow builds the AAB; uploading through the Play Developer API needs a
service account (step 5.4).

