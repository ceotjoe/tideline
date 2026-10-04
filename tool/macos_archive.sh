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

if $upload; then
  xcodebuild -exportArchive -archivePath "$archive" \
    -exportOptionsPlist macos/ExportOptions.plist \
    -exportPath build/macos/export -allowProvisioningUpdates
else
  echo "Archive ready: app/$archive (add --upload to export and upload)."
fi
echo "If git shows changes in app/macos/Runner.xcodeproj, Xcode only upgraded the file: git checkout app/macos/Runner.xcodeproj"
