# 0030. Release automation: GitHub releases for Windows and Linux, stores for Apple and Android

- Status: accepted
- Date: 2026-10-05

## Context
Releases were built by `.github/workflows/release.yml` on a `v*` tag, but its outputs were workflow artifacts that expire,
and every store upload was manual (ADR 0022, point 6). The maintainer wants (1) uploads to the Apple and Google stores
to happen automatically and (2) Windows and Linux builds to be downloadable directly from GitHub releases.

Verified from the repository (2026-10-05): the workflow had `contents: read` only and no release step; Linux was built in
`build.yml` as debug, `continue-on-error`; ADR 0015 declared Linux "no releases"; the MSIX needs a certificate that
Windows trusts, which the project does not have yet.

## Decision
1. **Phase 1 (this ADR, implemented): a GitHub release from the tag.** A final `publish` job, the only one with
   `contents: write`, runs on tag pushes after every build job succeeded and runs `gh release create` with:
   - `Tideline-<version>-windows-x64-portable.zip`, which includes the Visual C++ runtime DLLs next to the executable
   - `Tideline-<version>-windows-x64.msix`
   - `Tideline-<version>-linux-x64.tar.gz`
   - the SPDX SBOM and `SHA256SUMS.txt`
   Notes are the `CHANGELOG.md` section of the version plus `.github/release-notes-footer.md`. Versions `0.x` are marked
   as pre-releases.
2. **Tag and `app/pubspec.yaml` must agree.** A `meta` job reads the version and fails the run on a mismatch.
   `workflow_dispatch` builds everything and publishes nothing.
3. **Linux is published, as experimental.** This supersedes the "Linux: no releases, no support promise" part of
   ADR 0015: the tarball is offered, labelled experimental, x86-64 only, without an AppImage or distribution packages.
   The support promise stays as it was.
4. **Windows gets a portable zip next to the MSIX.** Without a certificate Windows trusts, the MSIX cannot be installed;
   the zip needs no installer and no certificate. Both are unsigned until a certificate exists, and SmartScreen may warn.
5. **Phase 2 (implemented): Google Play.** A `play` job (tag pushes only, `environment: production`, needs the Android
   build) checks that the AAB is not debug-signed and uploads it to the **internal** track with
   `r0adkll/upload-google-play` (pinned to a commit) and the service account JSON. The release status is `draft` until the
   repository variable `PLAY_RELEASE_STATUS` says otherwise, because the API accepts only drafts for an app without a
   published release. The Android job now fails a tag run without the keystore. The `versionCode` stays the build number
   in `app/pubspec.yaml`, shared with the Apple builds (ADR 0022 had suggested the run number; a manual run and the
   Apple uploads would make those numbers diverge).
6. **Secrets by risk.** Signing material (keystore, certificates) is a repository secret, so builds need no approval.
   Credentials that publish (`PLAY_SERVICE_ACCOUNT_JSON`, `ASC_*`) are `production` environment secrets, declared only by
   the upload jobs, with the maintainer as required reviewer: one approval gates the irreversible step.
7. **Phase 3 (implemented): iOS and iPadOS to TestFlight.** `tool/ios_archive.sh` archives without signing and exports with
   a **manual** App Store profile (a repository secret) and the distribution certificate the profile names, then verifies
   the IPA. Passing the profile to `xcodebuild archive` would apply it to every Swift package target, so the export does
   the signing. The `ios` job signs; the `testflight` job (tag pushes, `environment: production`) uploads with `altool` and
   the App Store Connect API key. The old `apple` job is split into `ios` and an unsigned `macos` build. A tag run without
   the certificate or profile fails. Export compliance is still answered by hand in App Store Connect (ADR 0022).
8. **Phase 4 (implemented, not yet run in CI): macOS to App Store Connect.** `tool/macos_package.sh` archives with the
   project's ad hoc signature (verified 2026-10-05 to keep the sandbox entitlements and to leave the plugin resource
   bundles unsigned) and exports with manual signing: an Apple Distribution and a Mac Installer Distribution certificate
   (one `.p12`, repository secrets) and a Mac App Store profile. The `testflight` job uploads the IPA and the package with
   one approval and tries both. `tool/macos_archive.sh` stays as the local route; its signature-stripping fix (commit
   46e4f68) is not needed on the new path. A tag run without the Mac secrets fails.
9. **Later:** the Windows certificate, and a decision on AppImage or Flatpak for Linux. Store uploads stay on internal tracks and TestFlight; promotion is manual.

## Consequences
- A release is now public the moment the tag is pushed (a pre-release for `0.x`). A bad build is fixed by deleting the
  release and the tag and pushing a new one.
- The `publish` job can write to the repository: it runs no project code, only `gh`, `awk`, `sha256sum` and the pinned
  `actions/checkout` and `actions/download-artifact`. Build jobs keep read-only tokens.
- No auto-update: users download new versions by hand.
- Follow-ups: signing certificates for Windows, possible AppImage or Flatpak for Linux, and the store phases above.
