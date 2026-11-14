# 0036. Import the design library from material_ui and cupertino_ui (Flutter 3.50)

- Status: accepted
- Date: 2026-11-14

## Context
- Flutter 3.50.0 (Dart 3.14) deprecates `package:flutter/material.dart` and the `GlobalMaterialLocalizations` /
  `GlobalCupertinoLocalizations` delegates of `flutter_localizations` in favour of the `material_ui` and `cupertino_ui`
  packages. With `dart analyze --fatal-infos` this broke the build with 96 infos.
- Both packages were already in the lockfile as transitive dependencies.

## Decision
- **`app` depends directly on `material_ui` and `cupertino_ui`** and imports `package:material_ui/material_ui.dart`
  instead of `package:flutter/material.dart`.
- Where `flutter_localizations` is imported next to them, it hides its deprecated `GlobalMaterialLocalizations` and
  `GlobalCupertinoLocalizations`, so the names are unambiguous.
- CI and release builds are pinned to Flutter 3.50.0.

## Consequences
- Two more direct dependencies, both from the Flutter team and no new transitive code. Network access, the privacy
  policy and the threat model do not change.
- The new `unnecessary_unawaited` lint removed two `unawaited(...)` wrappers around `showModalBottomSheet` and
  `showDialog`.
