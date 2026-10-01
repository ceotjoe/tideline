import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tideline/src/app.dart';
import 'package:tideline/src/providers.dart';
import 'package:tideline/src/settings/app_settings.dart';

/// Records settings saves without a database.
class FakeSettingsController implements SettingsController {
  final List<AppSettings> saved = [];

  @override
  Future<void> save(AppSettings settings) async => saved.add(settings);
}

/// Window sizes used across tests and goldens.
abstract final class TestSizes {
  static const phone = Size(390, 844);
  static const tabletPortrait = Size(820, 1180);
  static const tabletLandscape = Size(1180, 820);
  static const desktop = Size(1440, 900);
}

/// Pumps the full app with providers that need no database.
Future<FakeSettingsController> pumpTideline(
  WidgetTester tester, {
  Size size = TestSizes.phone,
  AppSettings settings = const AppSettings(),
  int pending = 0,
  double textScale = 1,
  bool disableAnimations = true,
}) async {
  tester.view
    ..physicalSize = size * tester.view.devicePixelRatio
    ..platformDispatcher.textScaleFactorTestValue = textScale
    ..platformDispatcher.accessibilityFeaturesTestValue =
        FakeAccessibilityFeatures(disableAnimations: disableAnimations);
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearAllTestValues);

  final controller = FakeSettingsController();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appSettingsProvider.overrideWith((ref) => Stream.value(settings)),
        pendingSyncCountProvider.overrideWith((ref) => Stream.value(pending)),
        bindingOverridesProvider.overrideWith((ref) => Stream.value(const [])),
        settingsControllerProvider.overrideWithValue(controller),
        // Nothing may touch the real database in widget tests.
        databaseProvider.overrideWith(
          (ref) => throw StateError('no database in widget tests'),
        ),
        shortcutBindingStoreProvider.overrideWith(
          (ref) => throw StateError('no database in widget tests'),
        ),
        settingsStoreProvider.overrideWith(
          (ref) => throw StateError('no database in widget tests'),
        ),
      ],
      child: const TidelineApp(),
    ),
  );
  await tester.pumpAndSettle();
  return controller;
}
