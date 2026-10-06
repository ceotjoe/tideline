# Releasing Tideline

Releases follow [Semantic Versioning](https://semver.org). Pushing a tag `vX.Y.Z` runs
`.github/workflows/release.yml`, which builds release artifacts for every platform plus an SBOM (SPDX) and, once all builds
have passed, creates the GitHub release ([ADR 0030](adr/0030-release-automation.md)): Windows portable zip and MSIX, the
experimental Linux tarball, the SBOM and `SHA256SUMS.txt`, with the version's `CHANGELOG.md` section as notes (`0.x` is
marked as a pre-release). The tag must be `v` plus the `app/pubspec.yaml` version or the run fails. *Run workflow* on any
branch is a dry run: it builds but publishes nothing.

## Required repository secrets

Where a secret lives matters, because an *environment* secret is visible only to jobs that declare that environment:

- **Repository secrets** (signing material, needed by every build, no approval): the `ANDROID_*`, `APPLE_CERT_*`, `MACOS_*` and
  `WINDOWS_*` secrets and the iOS provisioning profile. Add them under **Settings → Secrets and variables → Actions →
  Repository secrets**.
- **`production` environment secrets** (credentials that publish to a store): `PLAY_SERVICE_ACCOUNT_JSON` and the
  `ASC_*` secrets. Only the upload jobs declare `environment: production`, so a release waits for one approval from the
  required reviewer before anything reaches a store (**Settings → Environments → production**).

Without the signing secrets a tag run **fails** for Android, iOS and macOS (a release must not be debug-signed or unsigned); the
other builds only warn and build unsigned. A manual run (*Run workflow*) is a dry run and never uploads, and builds unsigned where the secrets are missing.

| Secret | Used for |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | Upload keystore (`.jks`), base64-encoded |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore password |
| `ANDROID_KEY_ALIAS` | Key alias |
| `ANDROID_KEY_PASSWORD` | Key password |
| `APPLE_CERT_P12_BASE64` | Apple distribution certificate (`.p12`), base64-encoded |
| `APPLE_CERT_PASSWORD` | Its password |
| `IOS_PROVISIONING_PROFILE_BASE64` | App Store provisioning profile for `com.ITWebService.tideline`, base64-encoded (how to create it: below) |
| `MACOS_CERT_P12_BASE64` | `.p12` with the *Apple Distribution* identity (signs the app), base64-encoded |
| `MACOS_CERT_PASSWORD` | Its password |
| `MACOS_INSTALLER_P12_BASE64` | `.p12` with the *Mac Installer Distribution* identity (signs the package), base64-encoded |
| `MACOS_INSTALLER_PASSWORD` | Its password |
| `MACOS_PROVISIONING_PROFILE_BASE64` | Mac App Store Connect provisioning profile for `com.ITWebService.tideline`, base64-encoded |
| `WINDOWS_CERT_PFX_BASE64` | Code-signing certificate for the MSIX (`.pfx`), base64-encoded |
| `WINDOWS_CERT_PASSWORD` | Its password |
| `WINDOWS_PUBLISHER` | Publisher subject of that certificate, e.g. `CN=…` (must match exactly) |

Encode a file with: `base64 -i file.jks | pbcopy` (macOS).

### How to create each secret

Never paste a secret into a chat or commit it. Keep the originals in a password manager. After adding a base64 secret, check
that it decodes: `pbpaste | base64 --decode | file -`.

**Android** (4 secrets). One upload keystore: reuse `~/tideline-upload.jks` from the Android section below if it exists,
because Play registers the upload key. Otherwise create it with the `keytool` command there and back it up.
`ANDROID_KEYSTORE_BASE64` is the base64 of the `.jks`, `ANDROID_KEYSTORE_PASSWORD` and `ANDROID_KEY_PASSWORD` are its
passwords and `ANDROID_KEY_ALIAS` is `upload`.

**Apple certificate** (2 secrets).
1. In Keychain Access → My Certificates, find **Apple Distribution** (or *iPhone Distribution*) with a private key under it.
   If there is none, create one in the developer portal (*Certificates, Identifiers & Profiles → Certificates → +*) with a
   CSR from Keychain Access (*Certificate Assistant → Request a Certificate from a CA*) and install the download.
2. Right-click it → *Export…* → `.p12` with a strong password.
3. `APPLE_CERT_P12_BASE64` is the base64 of the `.p12`, `APPLE_CERT_PASSWORD` is the export password. Delete the file
   afterwards or keep it only in the password manager.

**macOS** (5 secrets). Needs an *Apple Distribution* certificate and a *Mac Installer Distribution* certificate with their
private keys, plus a Mac App Store profile. Xcode's cloud-managed signing does not leave them in your keychain, and the iOS
certificate (*iPhone Distribution*) cannot sign Mac apps.
1. Keychain Access → *Certificate Assistant → Request a Certificate from a CA* (save to disk). In the developer portal →
   *Certificates → +*, create **Apple Distribution** and **Mac Installer Distribution** from that request, download both,
   double-click to install them. Each must show a private key under it in *My Certificates*. (An account may hold only a few
   Apple Distribution certificates; revoke one you don't use if the portal refuses.)
2. Export **each identity on its own** (a single combined file is easy to get wrong: a file with only one of them looks fine
   until the runner imports it). In *My Certificates*, select *Apple Distribution: …* (with its key) → right-click →
   *Export…* → `.p12` with a password, then the same for *3rd Party Mac Developer Installer: …* (shown for the *Mac
   Installer Distribution* certificate). `MACOS_CERT_P12_BASE64` / `MACOS_CERT_PASSWORD` are the first file and its password,
   `MACOS_INSTALLER_P12_BASE64` / `MACOS_INSTALLER_PASSWORD` the second. Upload without the clipboard, with the full path:
   `base64 -i "$HOME/…/installer.p12" | gh secret set MACOS_INSTALLER_P12_BASE64 -R ceotjoe/tideline`.
   Check a file before uploading: `openssl pkcs12 -legacy -in FILE -nokeys | grep subject` must show the expected
   certificate.
3. *Profiles → + → **Mac App Store Connect*** → App ID `com.ITWebService.tideline` → the Apple Distribution certificate →
   a name such as `Tideline Mac App Store` → download the `.provisionprofile`.
   `MACOS_PROVISIONING_PROFILE_BASE64` is its base64.

**Windows signing** (3 secrets). Needs a certificate Windows trusts: a commercial code-signing certificate (OV or EV) or
Azure Trusted Signing (a different workflow step). A self-signed certificate is trusted only on machines that import it.
With a `.pfx`: `WINDOWS_CERT_PFX_BASE64` is its base64, `WINDOWS_CERT_PASSWORD` its password, and `WINDOWS_PUBLISHER` the exact
subject, which must equal `msix_config.publisher`: `openssl pkcs12 -in cert.pfx -nokeys | openssl x509 -noout -subject`.
Leave all three unset until then: the workflow builds unsigned and says so.

**Secrets for the store uploads** (`PLAY_SERVICE_ACCOUNT_JSON` and `ASC_*` are read by the upload job; see
[ADR 0030](adr/0030-release-automation.md)):

| Secret | How to get it |
|---|---|
| `PLAY_SERVICE_ACCOUNT_JSON` | Google Cloud: enable the *Google Play Android Developer API*, create a service account and a JSON key. Play Console → *Users and permissions* → invite its email, **for Tideline only** with *View app information and download bulk reports (read-only)* and *Release apps to testing tracks*. No production, store-presence or financial permissions. Use a service account of its own for Tideline. Permissions can take hours to apply. The first AAB must be uploaded by hand, and while the app has no published release the API accepts only draft releases. |
| `ASC_KEY_P8_BASE64`, `ASC_KEY_ID`, `ASC_ISSUER_ID` | App Store Connect → *Users and Access → Integrations → App Store Connect API* → generate a key with the **App Manager** role. The `.p8` can be downloaded once. Key ID and issuer ID are shown on that page. |

Also create a **`production` environment** (*Settings → Environments*) with yourself as required reviewer, and scope the
store secrets to it.

## Not automated yet

- **macOS (Mac App Store):** automated since ADR 0030 phase 4, see "macOS: Mac App Store and TestFlight" below. After
  the first release is through, the macOS app can switch to the data-protection keychain (ADR 0006).
- **iOS and iPadOS:** automated since phase 3, see the next section. **Google Play:** automated since phase 2, see
  the Android section below.
- **Microsoft Store:** only if Store distribution is chosen. `msix_config.store` is `false` for now, meaning direct MSIX.

## Checklist

1. `CHANGELOG.md`: move *Unreleased* items into a new version section.
2. Bump `version:` in `app/pubspec.yaml` (and `msix_version`).
3. Tag `vX.Y.Z` and push. The workflow creates the GitHub release; check its files and notes afterwards. A bad release is
   removed with `gh release delete vX.Y.Z --cleanup-tag --yes`, then fixed and tagged again.

## iOS and iPadOS: automatic TestFlight upload

On a tag push, the `ios` job builds a signed IPA with `tool/ios_archive.sh` and the `testflight` job uploads it to App
Store Connect with `xcrun altool` and the API key, after you approve the `production` environment. Nothing is uploaded by
a manual run (*Run workflow*), but it does build the signed IPA, so it is the way to test the signing setup.

### The provisioning profile (once, and again when it expires or the certificate changes)
CI signs **manually**, without an Apple ID, so the profile must be one you create in the developer portal. The profiles
Xcode manages for you ("iOS Team Store Provisioning Profile: …") are refused.
1. *Certificates, Identifiers & Profiles → Profiles → +* → **App Store Connect** (distribution) → the App ID
   `com.ITWebService.tideline` → the **Distribution certificate you exported as `.p12`** → a name such as
   `Tideline App Store` → Generate → Download.
2. `base64 -i Tideline_App_Store.mobileprovision | pbcopy` → repository secret `IOS_PROVISIONING_PROFILE_BASE64`.
3. A profile lasts a year and becomes invalid if its certificate is revoked or regenerated: make a new one and replace the
   secret.

### Testing the signing locally
With the certificate in your keychain (with its private key) and the downloaded profile:
`tool/ios_archive.sh --profile ~/Downloads/Tideline_App_Store.mobileprovision [build-number]` archives without signing and
exports with the profile, then checks the IPA (team, distribution certificate, embedded profile). It never uploads.
The IPA is `app/build/ios/export/Tideline.ipa`. It copies the profile into Xcode's profile folders, like Xcode does.
*Checked 2026-10-05:* the script refuses an Xcode-managed profile with an explanation, and a manual workflow run built
and verified the signed IPA with the portal profile `Tideline App Store` (team Q486NF4XF6, version 0.4.0, build 5).
The first upload attempt (tag `v0.4.0`) stopped in the job's own IPA check, which failed on macOS because `wc -l` pads its
number (fixed afterwards), so `altool` has not been exercised yet.

### App Review notes
No sign-in credentials are needed. Paste into the review notes (App Store Connect, Play Console *App access*):

> Tideline is a client for the user's own Wavelog server. To review it without one, tap **Try the demo (no Wavelog
> needed)** on the first screen, then **Finish**. This creates a demo account with a made-up station that runs entirely
> on the device (no network). Log a QSO on the Log tab and open **Sync** to see it upload to the demo server.
> The demo account can be removed under Settings → Wavelog accounts.

### Export compliance
`ITSAppUsesNonExemptEncryption` is `true` in `app/ios/Runner/Info.plist` and `app/macos/Runner/Info.plist` (maintainer's
decision 2026-10-05, ADR 0022 update): the app's own encryption (SQLite3MultipleCiphers, backups) goes beyond what the OS
provides, so it is not exempt. Builds no longer wait with *Missing Compliance*, but App Store Connect may still ask the
follow-up questions (mass-market self-classification, France); the maintainer answers them. This is the maintainer's
classification, not a legal opinion of the project.

### Version and build number
`tool/ios_archive.sh` takes both from `app/pubspec.yaml` (`+N`). App Store Connect refuses a build number it has seen for
that version, so bump `+N` for every release (the same number is the Play `versionCode`).

## First TestFlight build (by hand, as a fallback)

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
   address and a way for the reviewer to get past onboarding: the built-in demo (ADR 0031), see *App Review notes* below.
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
cd app && flutter build apk --release --build-name 0.4.0 --build-number 6
adb install -r build/app/outputs/flutter-apk/app-release.apk
```
Without `key.properties` the build is signed with the debug key and Play will refuse it, but it installs for testing.

### 3. Google Play
1. Play Console → **Create app**: name, default language, App (not game), free, accept the declarations.
2. **App content** (required before any track works): privacy policy URL (a public page; `PRIVACY.md` on GitHub works),
   app access (the app needs a Wavelog server: tell the reviewer to use the built-in demo, as for Apple), ads (none), content rating
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

### 4. Automatic upload (internal track)
On a tag push the `play` job of `release.yml` uploads the AAB to the **internal** track after you approve the `production`
environment. It first checks that the bundle is not debug-signed. Everything beyond internal testing (closed test,
production) is promoted by hand in Play Console.

Once, by hand, before the first automatic upload: create the app, fill in *App content*, upload the first AAB yourself
(the API cannot create the app or its first release), and invite the service account (see the secrets section: permissions
for Tideline only, never production). Permissions can take hours to apply.

While the app has no published release the API accepts only **draft** releases, which is the default here: open the draft
in Play Console and roll it out. After the first release, set the repository variable `PLAY_RELEASE_STATUS` to `completed`
(**Settings → Secrets and variables → Actions → Variables**) so uploads roll out to internal testers by themselves.
The `versionCode` is the build number from `app/pubspec.yaml` (`+N`), so bump it for every release: Play refuses a
`versionCode` it already has, and a re-run of the same tag fails.
*Checked 2026-10-05:* the tag `v0.4.0` uploaded build 6 to the internal track as a draft.

## macOS: Mac App Store and TestFlight

### Automatic upload
On a tag push the `macos` job builds a signed `.pkg` with `tool/macos_package.sh` and the `testflight` job uploads it to App
Store Connect together with the iOS IPA (`xcrun altool --type macos`), after you approve the `production` environment. A
manual run builds the signed package too but uploads nothing. The script archives with the project's ad hoc signature,
which keeps the sandbox entitlements, and lets the export sign with the profile, the Apple Distribution certificate and
the installer certificate; the plugins' resource bundles then stay unsigned, so ITMS-90284 does not arise. It checks the
package before it can be uploaded: installer signature, team and distribution certificate of the app, sandbox, embedded
profile, no development-signed code.

Test it locally with the certificates in your keychain and the downloaded profile:
`tool/macos_package.sh --profile ~/Downloads/Tideline_Mac_App_Store.provisionprofile [build-number]`. The package is
`app/build/macos/export/Tideline.pkg`.
*Checked 2026-10-05:* an ad hoc archive keeps the three sandbox entitlements and has unsigned resource bundles, and its
export (with Xcode's automatic signing) gives a valid app with those entitlements, the application identifier, the profile
and no development-signed bundles. The script refuses Xcode-managed profiles. A manual workflow run on 2026-10-05 then built
and verified the signed package with the portal profile `Tideline app Mac`: installer certificate, Apple Distribution
for team Q486NF4XF6, sandbox entitlements, embedded profile, no development-signed code, version 0.4.0 build 6.
**Not yet run:** the `altool` upload of the package (it runs with the next release tag).

The manual way below (`tool/macos_archive.sh`) stays as the local alternative that uses Xcode's own signing.

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
4. **ITMS-90284** ("The executable `….bundle` must be signed with the certificate that is contained in the provisioning
   profile", one per plugin: `connectivity_plus`, `file_picker_darwin`, `flutter_secure_storage_darwin`,
   `local_auth_darwin`): the archive signs the plugins' resource bundles in `Contents/Resources` with the development
   certificate, and the export re-signs only the app and the frameworks. The script therefore removes the signature of
   those bundles (they contain no code, and the app's own signature seals them as resources), re-seals the app and checks
   it with `codesign --verify --deep --strict`. It refuses to strip a bundle that contains an executable. Verified on
   2026-10-05 by exporting with `destination: export` and checking every nested object in the `.pkg`. The Organizer
   route is fixed too, because the archive itself is changed. After a Flutter or plugin update, repeat the check.
5. If git shows changes in `app/macos/Runner.xcodeproj` afterwards, newer Xcode only upgraded the file:
   `git checkout app/macos/Runner.xcodeproj`.
6. In TestFlight, install the build from the Mac **TestFlight** app. External macOS testers need Beta App Review like on iOS.

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


## Store screenshots
`tool/store_screenshots.py` makes the screenshots on demand; the folder `docs/release/screenshots/` is git-ignored.
It runs `app/integration_test/store_screenshots_test.dart` on a device. The test uses the in-app demo account (ADR 0031) and
invented QSOs, so nothing private is in the pictures, and stops at the four main screens (Log, Callsigns, Sync, Settings).
The script takes the picture with the platform's own tool, so pixels, fonts and status bar are the real ones.

```bash
tool/store_screenshots.py ios --locales en de          # iPhone 6.9" and iPad 13" simulators, created and deleted by the script
tool/store_screenshots.py android --locales en de      # one running emulator or device; phone 1080x1920, tablet 1600x2560
tool/store_screenshots.py mac --locales en de          # see the warning below
```

- Output: `docs/release/screenshots/<iphone-6.9|ipad-13|android-phone|android-tablet-10|mac>/<locale>/NN-name.png`. The script
  warns when a picture has not the size the store asks for.
- It runs at low priority (`nice`), but builds the app for each run: expect 15 minutes or more for everything.
  `--ios-only iphone-6.9` limits it to one simulator.
- Android needs exactly one device listed by `adb devices` (for example `emulator -avd Pixel_10a`). The display size is
  changed with `wm size` for the run and reset afterwards; the app is uninstalled first so every run starts clean.
- **macOS:** the test runs the real app, which uses your real database. The script moves `tideline.sqlite` aside, restores it
  and compares checksums (see the macOS note in this file), but the macOS mode has not been run yet. Run it only when you
  have a backup. The window is captured as it is; the Mac App Store wants 1280×800, 1440×900, 2560×1600 or 2880×1800.
- Not generated: contest, activation and Fast Log Entry screens (you asked for the four main screens only).
