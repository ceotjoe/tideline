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
5. **Later phases** (separate commits, each approved first): Google Play upload through the Play Developer API (internal
   track, promotion by hand), iOS to TestFlight with an App Store Connect API key and a manual provisioning profile,
   macOS to App Store Connect. Store uploads stay on internal tracks and TestFlight; promotion is manual.

## Consequences
- A release is now public the moment the tag is pushed (a pre-release for `0.x`). A bad build is fixed by deleting the
  release and the tag and pushing a new one.
- The `publish` job can write to the repository: it runs no project code, only `gh`, `awk`, `sha256sum` and the pinned
  `actions/checkout` and `actions/download-artifact`. Build jobs keep read-only tokens.
- No auto-update: users download new versions by hand.
- Follow-ups: signing certificates for Windows, possible AppImage or Flatpak for Linux, and the store phases above.
