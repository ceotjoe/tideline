import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tideline/src/widgets/phone_orientation_lock.dart';

void main() {
  /// The orientation lists requested from the platform while the widget runs.
  Future<List<List<Object?>>> requested(
    WidgetTester tester,
    Size display,
    TargetPlatform platform, [
    Future<void> Function()? afterPump,
  ]) async {
    final calls = <List<Object?>>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'SystemChrome.setPreferredOrientations') {
          calls.add((call.arguments as List).cast<Object?>());
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    debugDefaultTargetPlatformOverride = platform;
    tester.view.display
      ..devicePixelRatio = 1
      ..size = display;
    addTearDown(tester.view.display.reset);
    try {
      await tester.pumpWidget(
        const PhoneOrientationLock(child: SizedBox.shrink()),
      );
      await afterPump?.call();
    } finally {
      // Must be unset before the test ends (a teardown is too late).
      debugDefaultTargetPlatformOverride = null;
    }
    return calls;
  }

  testWidgets('a phone is locked to portrait', (tester) async {
    final calls = await requested(
      tester,
      const Size(390, 844),
      TargetPlatform.iOS,
    );
    expect(calls, [
      ['DeviceOrientation.portraitUp'],
    ]);
  });

  testWidgets('a tablet rotates freely, whatever its window size', (
    tester,
  ) async {
    // The display is a tablet; the app window may be a narrow Split View.
    final calls = await requested(
      tester,
      const Size(834, 1194),
      TargetPlatform.android,
      () async {
        tester.view.physicalSize = const Size(390, 844);
        await tester.pump();
      },
    );
    expect(calls, [<Object?>[]]);
  });

  testWidgets('desktop is left alone', (tester) async {
    final calls = await requested(
      tester,
      const Size(400, 700),
      TargetPlatform.macOS,
    );
    expect(calls, isEmpty);
  });
}
