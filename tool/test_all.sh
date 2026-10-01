#!/usr/bin/env bash
# Runs the tests of every workspace member that has any.
# Pure-Dart packages use `dart test`; Flutter packages use `flutter test`.
set -euo pipefail
cd "$(dirname "$0")/.."

status=0
for dir in packages/* app; do
  [ -d "$dir/test" ] || continue
  if ! find "$dir/test" -name '*_test.dart' -print -quit | grep -q .; then
    continue
  fi
  echo "::group::$dir"
  if grep -q 'sdk: flutter' "$dir/pubspec.yaml"; then
    (cd "$dir" && flutter test) || status=1
  else
    (cd "$dir" && dart test) || status=1
  fi
  echo "::endgroup::"
done
exit $status
