import 'package:flutter_test/flutter_test.dart';
import 'package:tideline/src/features/startup_error_app.dart';

void main() {
  testWidgets('a generic startup error asks for a restart', (tester) async {
    await tester.pumpWidget(const StartupErrorApp());
    await tester.pumpAndSettle();
    expect(find.text("Tideline couldn't start"), findsOneWidget);
    expect(find.textContaining('report it on GitHub'), findsOneWidget);
  });

  testWidgets('a missing system keyring is explained', (tester) async {
    await tester.pumpWidget(
      const StartupErrorApp(secretStoreUnavailable: true),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('system keyring'), findsOneWidget);
    expect(find.textContaining('GNOME Keyring'), findsOneWidget);
    expect(find.textContaining('report it on GitHub'), findsNothing);
  });
}
