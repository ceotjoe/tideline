#!/usr/bin/env bash
# Builds the signed App Store IPA of Tideline (iOS and iPadOS) with manual
# signing, so it needs no Apple ID login: the distribution certificate must be
# in a keychain and the App Store provisioning profile is a file.
#
#   tool/ios_archive.sh --profile FILE.mobileprovision [build-number]
#
# The profile can also come from the environment (PROFILE_PATH). The script
# archives without signing and lets the export sign with the profile and the
# certificate the profile names: passing a profile to `xcodebuild archive`
# would apply it to every Swift package target and fail. The IPA lands in
# app/build/ios/export/. Uploading is a separate step (the release workflow's
# upload job, or Transporter); nothing is uploaded here.
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
  echo "Usage: tool/ios_archive.sh --profile FILE.mobileprovision [build-number]" >&2
  exit 1
fi

version="$(sed -n 's/^version:[[:space:]]*\([0-9.]*\)+.*/\1/p' pubspec.yaml)"
number="${number:-$(sed -n 's/^version:.*+\([0-9]*\).*/\1/p' pubspec.yaml)}"
echo "Tideline $version ($number)"

work="build/ios"
mkdir -p "$work"
plist="$work/profile.plist"
security cms -D -i "$profile" > "$plist"
name="$(plutil -extract Name raw "$plist")"
uuid="$(plutil -extract UUID raw "$plist")"
team="$(plutil -extract TeamIdentifier.0 raw "$plist")"
appid="$(plutil -extract Entitlements.application-identifier raw "$plist")"
bundle="${appid#"$team".}"
if plutil -extract ProvisionedDevices raw "$plist" >/dev/null 2>&1; then
  echo "$name is a development or ad hoc profile (it lists devices): an App Store profile is needed." >&2
  exit 1
fi
case "$name" in
  "iOS Team"*|"Mac Team"*)
    echo "$name is managed by Xcode. Manual signing needs a profile created in the developer portal" >&2
    echo "(Certificates, Identifiers & Profiles > Profiles > App Store Connect) and downloaded from there." >&2
    exit 1 ;;
esac
if [ "$(plutil -extract ExpirationDate raw "$plist" | cut -c1-10)" \< "$(date -u +%Y-%m-%d)" ]; then
  echo "$name has expired." >&2
  exit 1
fi
echo "Profile: $name ($bundle, team $team)"

# The certificate to sign with: the one of the profile that is in the keychain.
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
echo "Signing certificate: $identity"

# Xcode finds profiles in either folder, depending on its version.
for dir in "$HOME/Library/MobileDevice/Provisioning Profiles" \
           "$HOME/Library/Developer/Xcode/UserData/Provisioning Profiles"; do
  mkdir -p "$dir"
  cp "$profile" "$dir/$uuid.mobileprovision"
done

cat > "$work/ExportOptions.plist" <<PLIST
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
flutter build ios --release --no-codesign --build-name "$version" --build-number "$number"

archive="$work/Tideline.xcarchive"
rm -rf "$archive" "$work/export"
xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner -configuration Release \
  -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO \
  archive -archivePath "$archive"
xcodebuild -exportArchive -archivePath "$archive" \
  -exportOptionsPlist "$work/ExportOptions.plist" -exportPath "$work/export"

ipa="$(find "$work/export" -name '*.ipa' | head -1)"
[ -n "$ipa" ] || { echo "No IPA was exported." >&2; exit 1; }

# The IPA must be signed with the distribution certificate, for the right team,
# and carry the profile: check before anything is uploaded.
check="$work/check"
rm -rf "$check" && mkdir -p "$check" && unzip -q "$ipa" -d "$check"
app="$(find "$check/Payload" -maxdepth 1 -name '*.app' | head -1)"
signed="$(codesign -dvv "$app" 2>&1 | sed -n 's/^TeamIdentifier=//p')"
if [ "$signed" != "$team" ]; then
  echo "The IPA is signed by team '${signed:-none}', expected $team." >&2
  exit 1
fi
codesign -dvv "$app" 2>&1 | grep -q "Authority=.*Distribution" || { echo "Not signed with a distribution certificate." >&2; exit 1; }
[ -f "$app/embedded.mobileprovision" ] || { echo "The IPA has no provisioning profile." >&2; exit 1; }
codesign --verify --deep --strict "$app"
rm -rf "$check"
echo "IPA ready and verified: app/$ipa"
