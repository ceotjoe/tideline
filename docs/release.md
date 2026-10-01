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
  - Provisioning profiles and `ExportOptions.plist` for `flutter build ipa` and for the Mac App Store build.
  - Upload to App Store Connect.
  - Prerequisite: an Apple Developer Team ID, which must be configured first.
  - After that, the macOS app can switch to the data-protection keychain (ADR 0006).
- **Google Play upload:** planned via the Play Developer API once a service account exists. Until then, upload the AAB
  artifact manually.
- **Microsoft Store:** only if Store distribution is chosen. `msix_config.store` is `false` for now, meaning direct MSIX.

## Checklist

1. `CHANGELOG.md`: move *Unreleased* items into a new version section.
2. Bump `version:` in `app/pubspec.yaml` (and `msix_version`).
3. Tag `vX.Y.Z` and push.
4. Attach artifacts and the SBOM to the GitHub release.
