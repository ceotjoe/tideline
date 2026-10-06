import 'package:flutter_test/flutter_test.dart';
import 'package:tideline/src/services/app_services.dart';

import 'support/pump_app.dart';

void main() {
  testWidgets('no notice on a normal start', (tester) async {
    await pumpTideline(tester);
    expect(
      find.text('Your earlier log could not be carried over'),
      findsNothing,
    );
  });

  testWidgets('a set-aside 0.5.x log is explained once', (tester) async {
    await pumpTideline(
      tester,
      overrides: [legacyDatabaseNoticeProvider.overrideWithValue(true)],
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Your earlier log could not be carried over'),
      findsOneWidget,
    );
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(
      find.text('Your earlier log could not be carried over'),
      findsNothing,
    );
  });
}
