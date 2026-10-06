#!/usr/bin/env bash
# Guards ADR 0034: Tideline ships no encryption of its own, so the Apple export
# compliance answer is "no non-exempt encryption". Fails if encryption comes back.
set -euo pipefail
cd "$(dirname "$0")/.."

fail=0
bad() { echo "ADR 0034: $1" >&2; fail=1; }

# Packages that bring their own cryptography. (`crypto` is hashing only and fine.)
if grep -n -E '^  (cryptography|cryptography_flutter|pointycastle|encrypt|steel_crypto|sqlcipher_flutter_libs|sqlite3_flutter_libs):' pubspec.lock; then
  bad "an encryption package is in pubspec.lock"
fi
if grep -rn -E '^\s+(cryptography|cryptography_flutter|pointycastle|encrypt|steel_crypto|sqlcipher_flutter_libs):' pubspec.yaml app/pubspec.yaml packages/*/pubspec.yaml; then
  bad "an encryption package is declared in a pubspec"
fi

# The native SQLite build must be the plain one.
if ! grep -q -E '^\s+source: sqlite3\s*$' pubspec.yaml; then
  bad "pubspec.yaml hooks must use 'source: sqlite3'"
fi
if grep -n -i -E 'sqlite3mc|sqlcipher|multipleciphers' pubspec.yaml; then
  bad "pubspec.yaml mentions an encrypting SQLite build"
fi

# Dart code must not import encryption libraries or use cipher pragmas.
if grep -rn -E "package:(cryptography|pointycastle|encrypt)/|PRAGMA (cipher|key|hexkey|rekey)" app/lib packages/*/lib; then
  bad "encryption code found in lib/"
fi

# Apple export compliance answer.
for plist in app/ios/Runner/Info.plist app/macos/Runner/Info.plist; do
  if ! awk '/ITSAppUsesNonExemptEncryption/{getline; print}' "$plist" | grep -q '<false/>'; then
    bad "$plist: ITSAppUsesNonExemptEncryption must be <false/>"
  fi
done

[ "$fail" -eq 0 ] && echo "No app-level encryption found."
exit "$fail"
