import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tideline/src/services/scp_download.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';

import '../support/pump_app.dart';

const _pota = '''
"reference","name","active","entityId","locationDesc","latitude","longitude","grid"
"US-0001","Acadia National Park","1","291","US-ME","44.31","-68.2034","FN54vh"
"US-0002","Alagnak Wild River","1","6","US-AK","59.0908","-156.463","BO19sc"
''';

/// An in-memory [ReferencePackStore] that really consumes the stream.
class _MemoryPackStore extends Fake implements ReferencePackStore {
  final Map<ReferenceProgram, ReferencePackInfo> infos = {};
  final _changes = StreamController<void>.broadcast(sync: true);
  final List<ReferenceProgram> cleared = [];

  @override
  Future<ReferencePackInfo> install(
    ReferenceProgram program,
    Stream<ProgramReference> references, {
    required String sourceUrl,
    required String sha256,
    required DateTime fetchedAt,
    DateTime? sourceDate,
    String? licenceNote,
  }) async {
    final list = await references.toList();
    final info = ReferencePackInfo(
      program: program,
      count: list.length,
      sha256: sha256,
      sourceUrl: sourceUrl,
      fetchedAt: fetchedAt.millisecondsSinceEpoch,
      version: '2026-10-03',
    );
    infos[program] = info;
    _changes.add(null);
    return info;
  }

  @override
  Stream<ReferencePackInfo?> watchInfo(ReferenceProgram program) async* {
    yield infos[program];
    await for (final _ in _changes.stream) {
      yield infos[program];
    }
  }

  @override
  Future<void> clear(ReferenceProgram program) async {
    cleared.add(program);
    infos.remove(program);
    _changes.add(null);
  }
}

http.StreamedResponse _ok(String body, {int status = 200}) {
  final bytes = utf8.encode(body);
  return http.StreamedResponse(
    Stream.value(bytes),
    status,
    contentLength: bytes.length,
  );
}

Future<void> _openSettings(WidgetTester tester) async {
  await tester.tap(find.text('Settings').last);
  await tester.pumpAndSettle();
}

Future<void> _show(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: find
        .byWidgetPredicate(
          (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
        )
        .last,
  );
  await tester.pumpAndSettle();
}

/// Real file I/O never completes under the test's fake clock, so the
/// download steps run in real time until [done] holds.
Future<void> _until(WidgetTester tester, bool Function() done) async {
  for (var i = 0; i < 200 && !done(); i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 25)),
    );
    await tester.pump();
  }
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  late _MemoryPackStore store;
  late List<http.BaseRequest> requests;

  Future<void> setup(
    WidgetTester tester,
    Future<http.StreamedResponse> Function(http.BaseRequest) handler, {
    Size size = TestSizes.tabletPortrait,
    double textScale = 1,
  }) async {
    store = _MemoryPackStore();
    requests = [];
    final overrides = <Override>[
      publicHttpClientFactoryProvider.overrideWithValue(
        () => MockClient.streaming((request, body) {
          requests.add(request);
          return handler(request);
        }),
      ),
    ];
    await pumpTideline(
      tester,
      size: size,
      textScale: textScale,
      referencePacks: store,
      overrides: overrides,
    );
    await _openSettings(tester);
    await _show(tester, find.text('Parks on the Air (POTA)'));
  }

  Finder inCard(String program, Finder finder) => find.descendant(
    of: find.ancestor(of: find.text(program), matching: find.byType(Card)),
    matching: finder,
  );

  testWidgets('three lists, none installed, with the official addresses', (
    tester,
  ) async {
    await setup(tester, (_) async => _ok(_pota));
    expect(find.text('Summits on the Air (SOTA)'), findsOneWidget);
    expect(find.text('Parks on the Air (POTA)'), findsOneWidget);
    expect(find.text('World Wide Flora & Fauna (WWFF)'), findsOneWidget);
    expect(find.text('No list installed'), findsWidgets);
    for (final name in [
      'Summits on the Air (SOTA)',
      'Parks on the Air (POTA)',
      'World Wide Flora & Fauna (WWFF)',
    ]) {
      expect(inCard(name, find.text('Download')), findsOneWidget, reason: name);
    }
    expect(find.text('https://pota.app/all_parks_ext.csv'), findsOneWidget);
    // Nothing contacts a server until Download is pressed.
    expect(requests, isEmpty);
  });

  testWidgets('Download installs the list and shows what is stored', (
    tester,
  ) async {
    await setup(tester, (_) async => _ok(_pota));
    final button = find.descendant(
      of: find.ancestor(
        of: find.text('Parks on the Air (POTA)'),
        matching: find.byType(Card),
      ),
      matching: find.text('Download'),
    );
    await tester.tap(button);
    await _until(
      tester,
      () => find.textContaining('list installed:').evaluate().isNotEmpty,
    );

    expect(
      requests.single.url.toString(),
      'https://pota.app/all_parks_ext.csv',
    );
    expect(find.text('POTA list installed: 2 references.'), findsOneWidget);
    expect(
      find.textContaining('2 references · list dated 2026-10-03 · downloaded'),
      findsOneWidget,
    );
    expect(
      find.text('Source: https://pota.app/all_parks_ext.csv'),
      findsOneWidget,
    );
    // The button turns into Update and a Remove button appears.
    expect(find.text('Update'), findsOneWidget);
    expect(find.text('Remove'), findsOneWidget);
    expect(store.infos.keys, [ReferenceProgram.pota]);
  });

  testWidgets('an edited address is used', (tester) async {
    await setup(tester, (_) async => _ok(_pota));
    final field = find.descendant(
      of: find.ancestor(
        of: find.text('Parks on the Air (POTA)'),
        matching: find.byType(Card),
      ),
      matching: find.byType(TextField),
    );
    await tester.enterText(field, 'https://mirror.example.org/parks.csv');
    await tester.tap(inCard('Parks on the Air (POTA)', find.text('Download')));
    await _until(
      tester,
      () => find.textContaining('list installed:').evaluate().isNotEmpty,
    );
    expect(requests.single.url.host, 'mirror.example.org');
    expect(
      find.text('Source: https://mirror.example.org/parks.csv'),
      findsOneWidget,
    );
  });

  testWidgets('errors are explained and keep the old list', (tester) async {
    await setup(tester, (_) async => _ok('<html>Blocked</html>'));
    await tester.tap(inCard('Parks on the Air (POTA)', find.text('Download')));
    await _until(
      tester,
      () => find.textContaining('not a POTA list').evaluate().isNotEmpty,
    );
    expect(
      find.text('This is not a POTA list. Check the address.'),
      findsOneWidget,
    );
    expect(store.infos, isEmpty);

    final field = inCard('Parks on the Air (POTA)', find.byType(TextField));
    await tester.enterText(field, 'http://pota.app/all_parks_ext.csv');
    await tester.tap(inCard('Parks on the Air (POTA)', find.text('Download')));
    await tester.pumpAndSettle();
    expect(find.text('Only https addresses are allowed.'), findsOneWidget);
  });

  testWidgets('a server error shows its status', (tester) async {
    await setup(tester, (_) async => _ok('', status: 503));
    await tester.tap(inCard('Parks on the Air (POTA)', find.text('Download')));
    await _until(
      tester,
      () => find.textContaining('HTTP status').evaluate().isNotEmpty,
    );
    expect(
      find.text('The server answered with HTTP status 503.'),
      findsOneWidget,
    );
  });

  testWidgets('Cancel stops a running download and says so', (tester) async {
    final body = StreamController<List<int>>();
    await setup(
      tester,
      (_) async => http.StreamedResponse(body.stream, 200, contentLength: 1000),
    );
    await tester.tap(inCard('Parks on the Air (POTA)', find.text('Download')));
    await _until(tester, () => find.text('Cancel').evaluate().isNotEmpty);
    body.add(List.filled(100, 65));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.textContaining('Downloading…'), findsWidgets);

    await tester.tap(find.text('Cancel'));
    body.add(List.filled(100, 65));
    await _until(
      tester,
      () => find.textContaining('Download cancelled').evaluate().isNotEmpty,
    );
    expect(
      find.text('Download cancelled. The installed list was not changed.'),
      findsOneWidget,
    );
    expect(find.text('Cancel'), findsNothing);
    expect(store.infos, isEmpty);
    unawaited(body.close());
  });

  testWidgets('Remove asks first, then clears the list', (tester) async {
    await setup(tester, (_) async => _ok(_pota));
    await tester.tap(inCard('Parks on the Air (POTA)', find.text('Download')));
    await _until(
      tester,
      () => find.textContaining('list installed:').evaluate().isNotEmpty,
    );

    await tester.tap(inCard('Parks on the Air (POTA)', find.text('Remove')));
    await tester.pumpAndSettle();
    expect(find.text('Remove the POTA list?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(store.cleared, isEmpty);

    await tester.tap(inCard('Parks on the Air (POTA)', find.text('Remove')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Remove'),
      ),
    );
    await tester.pumpAndSettle();
    expect(store.cleared, [ReferenceProgram.pota]);
    expect(find.text('POTA list removed.'), findsOneWidget);
  });

  testWidgets('the section reads well at 200 % text on a phone', (
    tester,
  ) async {
    await setup(
      tester,
      (_) async => _ok(_pota),
      size: TestSizes.phone,
      textScale: 2,
    );
    expect(tester.takeException(), isNull);
    final handle = tester.ensureSemantics();
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    handle.dispose();
  });
}
