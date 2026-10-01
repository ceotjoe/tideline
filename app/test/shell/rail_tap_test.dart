import 'package:flutter_test/flutter_test.dart';

import '../support/pump_app.dart';

void main() {
  testWidgets('tapping a rail destination switches section', (tester) async {
    await pumpTideline(tester, size: TestSizes.tabletPortrait);
    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();
    expect(find.text('Appearance'), findsOneWidget);
    // Each radio group has a visible title, not only a semantics label.
    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('Touch targets'), findsOneWidget);
  });
}
