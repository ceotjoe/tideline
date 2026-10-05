#!/usr/bin/env bash
# Builds the Mac App Store archive of Tideline and optionally uploads it.
#
#   tool/macos_archive.sh [build-number] [--upload]
#
# Needs app/macos/Runner/Configs/Signing.local.xcconfig (git-ignored; copy the
# .example file). The team and signing identity are passed with
# `xcodebuild -xcconfig`, so nothing about them enters the tracked project.
# --upload exports with ExportOptions.plist (destination "upload") and
# -allowProvisioningUpdates: Xcode may create certificates and the provisioning
# profile in your Apple Developer account. Without it only the archive is made.
# See docs/release.md.
set -euo pipefail
cd "$(dirname "$0")/../app"

SIGNING=macos/Runner/Configs/Signing.local.xcconfig
if [ ! -f "$SIGNING" ]; then
  echo "Missing app/$SIGNING: copy $SIGNING.example and fill in your team." >&2
  exit 1
fi

version="$(sed -n 's/^version:[[:space:]]*\([0-9.]*\)+.*/\1/p' pubspec.yaml)"
number=""
upload=false
for arg in "$@"; do
  case "$arg" in
    --upload) upload=true ;;
    *) number="$arg" ;;
  esac
done
number="${number:-$(sed -n 's/^version:.*+\([0-9]*\).*/\1/p' pubspec.yaml)}"
echo "Tideline $version ($number)"

flutter pub get
# Fixes the version and build number that the Xcode build reads.
flutter build macos --release --build-name "$version" --build-number "$number"

archive="build/macos/Tideline.xcarchive"
rm -rf "$archive"
xcodebuild -workspace macos/Runner.xcworkspace -scheme Runner -configuration Release \
  -destination 'generic/platform=macOS' -xcconfig "$SIGNING" \
  archive -archivePath "$archive"

team="$(codesign -dv "$archive/Products/Applications/Tideline.app" 2>&1 | sed -n 's/^TeamIdentifier=//p')"
echo "Archive signed by team: ${team:-none}"
if [ -z "$team" ] || [ "$team" = "not set" ]; then
  echo "The archive has no team: check $SIGNING." >&2
  exit 1
fi

# Swift Package Manager plugins ship resource bundles in Contents/Resources
# (no executable). The archive signs them with the development certificate and
# the export re-signs the app and frameworks with the distribution one but
# leaves these alone, so App Store Connect rejects the upload with ITMS-90284.
# Without a signature they are sealed as plain resources by the app's own
# signature, which the export does create (verified 2026-10-05).
app="$archive/Products/Applications/Tideline.app"
for bundle in "$app"/Contents/Resources/*.bundle; do
  [ -e "$bundle" ] || continue
  # Fails if the bundle holds code: that would need a real signature instead.
  if find "$bundle" -type f -perm +111 | grep -q .; then
    echo "$bundle contains an executable: it must be signed, not stripped." >&2
    exit 1
  fi
  codesign --remove-signature "$bundle"
done
# Re-seal the app: the bundles are part of its signature.
codesign --force --preserve-metadata=identifier,entitlements,flags,runtime \
  --sign "$(codesign -dvv "$app" 2>&1 | sed -n 's/^Authority=\(Apple Development.*\)/\1/p' | head -1)" "$app"
codesign --verify --deep --strict "$app"
echo "Resource bundles stripped; app re-sealed and verified."

if $upload; then
  xcodebuild -exportArchive -archivePath "$archive" \
    -exportOptionsPlist macos/ExportOptions.plist \
    -exportPath build/macos/export -allowProvisioningUpdates
else
  echo "Archive ready: app/$archive (add --upload to export and upload)."
fi
echo "If git shows changes in app/macos/Runner.xcodeproj, Xcode only upgraded the file: git checkout app/macos/Runner.xcodeproj"
