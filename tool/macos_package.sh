#!/usr/bin/env bash
# Builds the signed Mac App Store package (.pkg) of Tideline with manual
# signing, so it needs no Apple ID login (this is what CI uses): the
# "Apple Distribution" and "Mac Installer Distribution" certificates must be in
# a keychain, and the "Mac App Store Connect" provisioning profile is a file.
#
#   tool/macos_package.sh --profile FILE.provisionprofile [build-number]
#
# The profile can also come from the environment (PROFILE_PATH). The archive is
# made with the project's own ad hoc signature (which keeps the sandbox
# entitlements) and the export signs it, the way tool/ios_archive.sh does for
# iOS. That also leaves the plugins' resource bundles unsigned, so the
# ITMS-90284 problem of tool/macos_archive.sh does not arise. The package lands
# in app/build/macos/export/. Nothing is uploaded here.
# See docs/release.md.
set -euo pipefail
cd "$(dirname "$0")/../app"

profile="${PROFILE_PATH:-}"
number=""
while [ $# -gt 0 ]; do
  case "$1" in
    --profile) profile="$2"; shift 2 ;;
    *) number="$1"; shift ;;
  esac
done
if [ -z "$profile" ] || [ ! -f "$profile" ]; then
  echo "Usage: tool/macos_package.sh --profile FILE.provisionprofile [build-number]" >&2
  exit 1
fi

version="$(sed -n 's/^version:[[:space:]]*\([0-9.]*\)+.*/\1/p' pubspec.yaml)"
number="${number:-$(sed -n 's/^version:.*+\([0-9]*\).*/\1/p' pubspec.yaml)}"
echo "Tideline $version ($number)"

work="build/macos"
mkdir -p "$work"
plist="$work/profile.plist"
security cms -D -i "$profile" > "$plist"
name="$(plutil -extract Name raw "$plist")"
uuid="$(plutil -extract UUID raw "$plist")"
team="$(plutil -extract TeamIdentifier.0 raw "$plist")"
# A Mac profile names the app in com.apple.application-identifier.
appid="$(plutil -extract Entitlements.com\\.apple\\.application-identifier raw "$plist" 2>/dev/null \
  || plutil -extract Entitlements.application-identifier raw "$plist")"
bundle="${appid#"$team".}"
case "$name" in
  "iOS Team"*|"Mac Team"*)
    echo "$name is managed by Xcode. Manual signing needs a profile created in the developer portal" >&2
    echo "(Certificates, Identifiers & Profiles > Profiles > Mac App Store Connect) and downloaded from there." >&2
    exit 1 ;;
esac
if plutil -extract ProvisionedDevices raw "$plist" >/dev/null 2>&1; then
  echo "$name is a development profile (it lists devices): a Mac App Store profile is needed." >&2
  exit 1
fi
if [ "$(plutil -extract ExpirationDate raw "$plist" | cut -c1-10)" \< "$(date -u +%Y-%m-%d)" ]; then
  echo "$name has expired." >&2
  exit 1
fi
echo "Profile: $name ($bundle, team $team)"

# The application certificate: the one of the profile that is in the keychain.
identity=""
i=0
while cert="$(plutil -extract "DeveloperCertificates.$i" raw "$plist" 2>/dev/null)"; do
  sha="$(echo "$cert" | base64 -d | openssl x509 -inform der -noout -fingerprint -sha1 | sed 's/.*=//; s/://g')"
  if security find-identity -v -p codesigning | grep -q "$sha"; then identity="$sha"; break; fi
  i=$((i + 1))
done
if [ -z "$identity" ]; then
  echo "None of the certificates in $name is in the keychain (with its private key)." >&2
  exit 1
fi
echo "Application certificate: $identity"

# The installer certificate signs the .pkg. It is not a code-signing identity,
# so it is not in the "codesigning" list.
# `|| true`: with pipefail a missing match would end the script before the
# message below.
installer="$(security find-identity -p basic | grep -E "Mac Installer Distribution|3rd Party Mac Developer Installer" \
  | grep "($team)" | grep -v CSSMERR | head -1 | awk '{print $2}')" || true
if [ -z "$installer" ]; then
  echo "No usable Mac Installer Distribution certificate of team $team in the keychain (with its private key)." >&2
  echo "Identities found (kind only; CSSMERR_ marks one the system does not accept):" >&2
  security find-identity -p basic | sed -nE 's/^ *[0-9]+\) [0-9A-F]+ "([^":]*)[^"]*"(.*)$/  \1\2/p' >&2 || true
  exit 1
fi
echo "Installer certificate: $installer"

# Xcode finds profiles in either folder, depending on its version.
for dir in "$HOME/Library/MobileDevice/Provisioning Profiles" \
           "$HOME/Library/Developer/Xcode/UserData/Provisioning Profiles"; do
  mkdir -p "$dir"
  cp "$profile" "$dir/$uuid.provisionprofile"
done

cat > "$work/ExportOptions-manual.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>method</key>
	<string>app-store-connect</string>
	<key>destination</key>
	<string>export</string>
	<key>teamID</key>
	<string>$team</string>
	<key>signingStyle</key>
	<string>manual</string>
	<key>signingCertificate</key>
	<string>$identity</string>
	<key>installerSigningCertificate</key>
	<string>$installer</string>
	<key>provisioningProfiles</key>
	<dict>
		<key>$bundle</key>
		<string>$name</string>
	</dict>
	<key>uploadSymbols</key>
	<true/>
	<key>manageAppVersionAndBuildNumber</key>
	<false/>
</dict>
</plist>
PLIST

flutter pub get
# Fixes the version and build number that the Xcode build reads.
flutter build macos --release --build-name "$version" --build-number "$number"

archive="$work/Tideline.xcarchive"
rm -rf "$archive" "$work/export"
xcodebuild -workspace macos/Runner.xcworkspace -scheme Runner -configuration Release \
  -destination 'generic/platform=macOS' archive -archivePath "$archive"
xcodebuild -exportArchive -archivePath "$archive" \
  -exportOptionsPlist "$work/ExportOptions-manual.plist" -exportPath "$work/export"

pkg="$(find "$work/export" -name '*.pkg' | head -1)"
[ -n "$pkg" ] || { echo "No package was exported." >&2; exit 1; }

# Check before anything is uploaded: the package is signed by the installer
# certificate, and the app inside by the distribution certificate of the team,
# sandboxed, with the profile and without any development-signed nested code.
pkgutil --check-signature "$pkg" | grep -q "Installer" || { echo "The package is not signed with an installer certificate." >&2; exit 1; }
check="$work/check"
rm -rf "$check" && pkgutil --expand-full "$pkg" "$check"
app="$(find "$check" -maxdepth 4 -name 'Tideline.app' | head -1)"
[ -n "$app" ] || { echo "No Tideline.app in the package." >&2; exit 1; }
signed="$(codesign -dvv "$app" 2>&1 | sed -n 's/^TeamIdentifier=//p')"
[ "$signed" = "$team" ] || { echo "The app is signed by team '${signed:-none}', expected $team." >&2; exit 1; }
codesign -dvv "$app" 2>&1 | grep -q "Authority=.*Distribution" || { echo "The app is not signed with a distribution certificate." >&2; exit 1; }
codesign -d --entitlements - "$app" 2>&1 | grep -q "com.apple.security.app-sandbox" || { echo "The app is not sandboxed." >&2; exit 1; }
[ -f "$app/Contents/embedded.provisionprofile" ] || { echo "The app has no provisioning profile." >&2; exit 1; }
codesign --verify --deep --strict "$app"
if find "$app" \( -name '*.bundle' -o -name '*.framework' \) -exec sh -c 'codesign -dvv "$1" 2>&1 | grep -q "Authority=Apple Development"' _ {} \; -print | grep -q .; then
  echo "Development-signed code is left in the package (ITMS-90284)." >&2
  exit 1
fi
rm -rf "$check"
echo "Package ready and verified: app/$pkg"
