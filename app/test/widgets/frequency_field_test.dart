import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tideline/l10n/generated/app_localizations.dart';
import 'package:tideline/src/design/theme.dart';
import 'package:tideline/src/design/tokens/color_tokens.dart';
import 'package:tideline/src/widgets/frequency_field.dart';

Widget host(
  TextEditingController c, {
  Locale locale = const Locale('en'),
  String? errorText,
  TidelineThemeVariant variant = TidelineThemeVariant.light,
}) => MaterialApp(
  locale: locale,
  theme: buildTidelineTheme(variant: variant),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  home: Scaffold(
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: FrequencyField(
        controller: c,
        onChanged: (_) {},
        errorText: errorText,
      ),
    ),
  ),
);

void main() {
  late TextEditingController controller;
  setUp(() => controller = TextEditingController());
  tearDown(() => controller.dispose());

  testWidgets('empty field shows the input hint', (tester) async {
    await tester.pumpWidget(host(controller));
    expect(find.text('Type MHz (14.205) or kHz (14205).'), findsOneWidget);
  });

  testWidgets('472 is read as 472 kHz on 630 m', (tester) async {
    await tester.pumpWidget(host(controller));
    await tester.enterText(find.byType(TextField), '472');
    await tester.pump();
    expect(find.text('472 kHz · 630 m'), findsOneWidget);
    expect(find.byIcon(Icons.waves), findsOneWidget);
  });

  testWidgets('below 1 MHz is shown in kHz, from 1 MHz up in MHz', (
    tester,
  ) async {
    await tester.pumpWidget(host(controller));
    final expected = {
      '136': '136 kHz · 2190 m',
      '475': '475 kHz · 630 m',
      '1840': '1.84 MHz · 160 m',
    };
    for (final MapEntry(key: input, value: text) in expected.entries) {
      await tester.enterText(find.byType(TextField), input);
      await tester.pump();
      expect(find.text(text), findsOneWidget, reason: input);
    }
  });

  testWidgets('kHz readout is spoken in kilohertz, in German too', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(host(controller, locale: const Locale('de')));
    await tester.enterText(find.byType(TextField), '472');
    await tester.pump();
    expect(find.text('472 kHz · 630 m'), findsOneWidget);
    expect(find.bySemanticsLabel('472 Kilohertz, 630 m'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('kHz and decimal MHz input resolve to the same reading', (
    tester,
  ) async {
    await tester.pumpWidget(host(controller));
    for (final text in ['14205', '14.205', '14,205']) {
      await tester.enterText(find.byType(TextField), text);
      await tester.pump();
      expect(find.text('14.205 MHz · 20 m'), findsOneWidget, reason: text);
    }
  });

  testWidgets('garbage shows the hint with an icon', (tester) async {
    await tester.pumpWidget(host(controller));
    await tester.enterText(find.byType(TextField), 'abc');
    await tester.pump();
    expect(find.textContaining('Not a frequency'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });

  testWidgets('outside every band shows MHz plus a note and icon', (
    tester,
  ) async {
    await tester.pumpWidget(host(controller));
    await tester.enterText(find.byType(TextField), '27.555');
    await tester.pump();
    expect(find.text('27.555 MHz · outside amateur bands'), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
  });

  testWidgets('a form error replaces the unreadable hint', (tester) async {
    await tester.pumpWidget(host(controller, errorText: 'Form error'));
    await tester.enterText(find.byType(TextField), 'abc');
    await tester.pump();
    expect(find.text('Form error'), findsOneWidget);
    expect(find.textContaining('Not a frequency'), findsNothing);
  });

  testWidgets('reading is a live region with a spoken label', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(host(controller));
    await tester.enterText(find.byType(TextField), '14205');
    await tester.pump();
    final node = tester.getSemantics(
      find.bySemanticsLabel('14.205 megahertz, 20 m'),
    );
    expect(node.flagsCollection.isLiveRegion, isTrue);
    handle.dispose();
  });

  testWidgets('German strings', (tester) async {
    await tester.pumpWidget(host(controller, locale: const Locale('de')));
    await tester.enterText(find.byType(TextField), '27.555');
    await tester.pump();
    expect(
      find.text('27.555 MHz · außerhalb der Amateurfunkbänder'),
      findsOneWidget,
    );
  });

  testWidgets('survives 200% text scale without overflow', (tester) async {
    tester.view.physicalSize = const Size(320, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          textScaler: TextScaler.linear(2),
          size: Size(320, 600),
        ),
        child: host(controller),
      ),
    );
    await tester.enterText(find.byType(TextField), '27.555');
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  for (final variant in TidelineThemeVariant.values) {
    testWidgets('meets guidelines in ${variant.name}', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(host(controller, variant: variant));
      for (final text in ['', '472', 'abc', '27.555']) {
        await tester.enterText(find.byType(TextField), text);
        await tester.pump();
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      }
      handle.dispose();
    });
  }
}
