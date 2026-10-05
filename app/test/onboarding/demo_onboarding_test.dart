import 'package:flutter_test/flutter_test.dart';
import 'package:tideline/src/services/app_services.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:wavelog_mock/wavelog_mock.dart' show demoUrl;

import '../support/pump_app.dart';

void main() {
  testWidgets('the demo button reaches the station step without a server', (
    tester,
  ) async {
    await pumpTideline(tester, accounts: const []);
    expect(find.text('Try the demo (no Wavelog needed)'), findsOneWidget);

    await tester.tap(find.text('Try the demo (no Wavelog needed)'));
    await tester.pumpAndSettle();

    expect(find.text('Demo station'), findsOneWidget);
    expect(find.text('N0CALL · JO40'), findsOneWidget);
  });

  testWidgets('the demo button meets the tap target and label guidelines', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpTideline(tester, accounts: const []);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    handle.dispose();
  });

  testWidgets('the demo account is marked in the account list', (tester) async {
    const demo = Account(
      id: 'acc-demo',
      label: 'Demo',
      baseUrl: demoUrl,
      usesIndexPhp: true,
      allowHttpLan: false,
      scopes: {'qso:read', 'qso:write', 'station:read'},
      hasContestSessions: false,
    );
    expect(isDemoAccount(demo), isTrue);

    await pumpTideline(tester, accounts: const [demo]);
    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Wavelog accounts'));
    await tester.pumpAndSettle();
    expect(find.textContaining('nothing leaves this device'), findsOneWidget);
  });

  test('a normal account is not the demo account', () {
    const real = Account(
      id: 'acc-1',
      label: 'Home',
      baseUrl: 'https://log.example.org',
      usesIndexPhp: true,
      allowHttpLan: false,
      scopes: {},
      hasContestSessions: false,
    );
    expect(isDemoAccount(real), isFalse);
  });
}
