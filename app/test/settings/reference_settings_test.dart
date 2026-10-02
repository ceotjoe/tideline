import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tideline/src/services/app_services.dart';
import 'package:tideline/src/services/data_transfer.dart';
import 'package:tideline/src/services/scp_download.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';

import '../support/contest_fakes.dart';
import '../support/pump_app.dart';

final String _scp = [
  '# test list',
  for (var i = 0; i < 20; i++) 'DL${i + 1}ABC',
  'W1AW',
].join('\n');

const String _userContest = '''
{
  "schema": 1, "id": "my-contest", "version": 3, "name": "My Contest",
  "modes": ["CW"], "bands": ["20m"],
  "exchange": {
    "sent": [{"kind": "rst"}],
    "rcvd": [{"kind": "rst"}]
  },
  "dupe": {"per": []},
  "points": [{"points": 1}],
  "score": "points"
}''';

/// A file picker that hands out canned bytes (or fails).
class _FakeTransfer extends DataTransfer {
  new(super._ref, {this.bytes, this.error});

  final Uint8List? bytes;
  final Exception? error;
  int picks = 0;

  @override
  Future<Uint8List?> pickFile(List<String> extensions, {int? maxBytes}) async {
    picks++;
    if (error != null) throw error!;
    return bytes;
  }
}

/// An in-memory [ScpStore].
class _MemoryScpStore extends Fake implements ScpStore {
  ScpPackInfo? stored;
  String? text;

  @override
  Future<ScpPackInfo> replace(
    String text, {
    required String sourceUrl,
    required DateTime fetchedAt,
  }) async {
    this.text = text;
    return stored = ScpPackInfo(
      callCount: ScpDatabase.parse(text).length,
      sha256: 'x',
      sourceUrl: sourceUrl,
      fetchedAt: fetchedAt.millisecondsSinceEpoch,
    );
  }

  @override
  Future<ScpPackInfo?> info() async => stored;

  @override
  Future<ScpDatabase?> load() async =>
      text == null ? null : ScpDatabase.parse(text!);

  @override
  Future<void> clear() async {
    stored = null;
    text = null;
  }
}

/// A definition repository that parses like the real one.
class _Definitions extends Fake implements ContestDefinitionRepository {
  new() {
    _list.addAll(bundledDefinitions().take(2));
  }

  final List<StoredContestDefinition> _list = [];
  final _changes = StreamController<void>.broadcast(sync: true);
  final Set<String> inUse = {};
  final List<String> deleteCalls = [];

  @override
  Stream<List<StoredContestDefinition>> watchAll() async* {
    yield List.of(_list);
    await for (final _ in _changes.stream) {
      yield List.of(_list);
    }
  }

  @override
  Future<ContestImportResult> importUserDefinition(String json) async {
    final ContestDefinition def;
    try {
      def = ContestDefinition.parse(json);
    } on ContestDefinitionException catch (e) {
      return ContestImportRejected(ContestImportError.invalid, exception: e);
    }
    final existing = _list.where((d) => d.definition.id == def.id).firstOrNull;
    if (existing != null && existing.builtin) {
      return const ContestImportRejected(
        ContestImportError.idClashesWithBuiltin,
      );
    }
    _list
      ..remove(existing)
      ..add(StoredContestDefinition(def, builtin: false));
    _changes.add(null);
    return ContestImported(def, replaced: existing != null);
  }

  @override
  Future<ContestDeleteResult> delete(String id) async {
    deleteCalls.add(id);
    final row = _list.where((d) => d.definition.id == id).firstOrNull;
    if (row == null) return ContestDeleteResult.notFound;
    if (row.builtin) return ContestDeleteResult.builtin;
    if (inUse.contains(id)) return ContestDeleteResult.inUse;
    _list.remove(row);
    _changes.add(null);
    return ContestDeleteResult.deleted;
  }
}

class _RebuildableWorkedBefore extends Fake implements WorkedBeforeRepository {
  final List<String> rebuilt = [];
  Completer<void>? gate;
  Error? failWith;

  @override
  Future<void> rebuildAll(String accountId) async {
    await gate?.future;
    if (failWith != null) throw failWith!;
    rebuilt.add(accountId);
  }
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

Future<void> _tapText(WidgetTester tester, String text) async {
  final finder = find.text(text);
  await _show(tester, finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

http.StreamedResponse _response(String body, {int status = 200}) {
  final bytes = utf8.encode(body);
  return http.StreamedResponse(
    Stream.value(bytes),
    status,
    contentLength: bytes.length,
  );
}

void main() {
  group('contest definitions', () {
    late _Definitions definitions;

    Future<List<Override>> setup(
      WidgetTester tester, {
      Uint8List? bytes,
      Exception? error,
    }) async {
      definitions = _Definitions();
      final overrides = <Override>[
        dataTransferProvider.overrideWith(
          (ref) => _FakeTransfer(ref, bytes: bytes, error: error),
        ),
      ];
      await pumpTideline(
        tester,
        size: TestSizes.tabletPortrait,
        definitions: definitions,
        overrides: overrides,
      );
      await _openSettings(tester);
      await _show(tester, find.text('Import definition'));
      return overrides;
    }

    testWidgets('bundled definitions are listed and cannot be deleted', (
      tester,
    ) async {
      await setup(tester);
      for (final d in definitions._list) {
        expect(find.text(d.definition.name), findsOneWidget);
      }
      expect(find.textContaining('Bundled · version'), findsWidgets);
      expect(find.byIcon(Icons.delete_outline), findsNothing);
    });

    testWidgets('a valid file is imported and can be deleted again', (
      tester,
    ) async {
      await setup(tester, bytes: utf8.encode(_userContest));
      await _tapText(tester, 'Import definition');
      expect(find.text('Imported “My Contest”.'), findsOneWidget);
      await _show(tester, find.text('My Contest'));
      expect(find.text('Imported by you · version 3'), findsOneWidget);

      await tester.tap(find.byTooltip('Delete definition My Contest'));
      await tester.pumpAndSettle();
      expect(find.text('Delete “My Contest”?'), findsOneWidget);
      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();
      expect(find.text('Deleted “My Contest”.'), findsOneWidget);
      expect(find.text('My Contest'), findsNothing);
    });

    testWidgets('a definition in use is not deleted and says why', (
      tester,
    ) async {
      await setup(tester, bytes: utf8.encode(_userContest));
      await _tapText(tester, 'Import definition');
      definitions.inUse.add('my-contest');
      await tester.tap(find.byTooltip('Delete definition My Contest'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'A contest session in your log uses this definition, so it cannot '
          'be deleted.',
        ),
        findsOneWidget,
      );
      expect(find.text('My Contest'), findsOneWidget);
    });

    testWidgets('a rejected file shows a localised reason and the path', (
      tester,
    ) async {
      final bad = _userContest.replaceFirst(
        '"score": "points"',
        '"score": "points", "extra": 1',
      );
      await setup(tester, bytes: utf8.encode(bad));
      await _tapText(tester, 'Import definition');
      expect(find.text('Definition not imported'), findsOneWidget);
      expect(
        find.text('The file contains a setting that Tideline does not know.'),
        findsOneWidget,
      );
      expect(find.textContaining(r'Technical detail: $'), findsOneWidget);
      expect(find.textContaining('extra'), findsOneWidget);
      // Nothing was stored.
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.text('My Contest'), findsNothing);
    });

    testWidgets('a file that is not JSON is explained', (tester) async {
      await setup(tester, bytes: utf8.encode('not json'));
      await _tapText(tester, 'Import definition');
      expect(find.text('The file is not valid JSON.'), findsOneWidget);
    });

    testWidgets('a file that is not text is refused', (tester) async {
      await setup(tester, bytes: Uint8List.fromList([0xff, 0xfe, 0xfd]));
      await _tapText(tester, 'Import definition');
      expect(find.text('The file is not valid UTF-8 text.'), findsOneWidget);
    });

    testWidgets('a file over 256 KiB is refused before it is read', (
      tester,
    ) async {
      await setup(tester, error: const ImportTooLargeException());
      await _tapText(tester, 'Import definition');
      expect(find.text('The file is larger than 256 KiB.'), findsOneWidget);
    });

    testWidgets('an id that belongs to a bundled contest is refused', (
      tester,
    ) async {
      final id = definitions0Id();
      final clash = _userContest.replaceFirst('my-contest', id);
      await setup(tester, bytes: utf8.encode(clash));
      await _tapText(tester, 'Import definition');
      expect(
        find.text(
          'This id belongs to a bundled contest. Choose a different id in '
          'the file.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('cancelling the picker changes nothing', (tester) async {
      await setup(tester);
      await _tapText(tester, 'Import definition');
      expect(find.text('Definition not imported'), findsNothing);
      expect(find.textContaining('Imported'), findsNothing);
    });
  });

  group('super check partial', () {
    late _MemoryScpStore store;
    late List<http.BaseRequest> requests;

    Future<void> setup(
      WidgetTester tester, {
      Future<http.StreamedResponse> Function(http.BaseRequest)? handler,
      Uint8List? fileBytes,
      Exception? pickError,
      double textScale = 1,
    }) async {
      store = _MemoryScpStore();
      requests = [];
      await pumpTideline(
        tester,
        size: TestSizes.tabletPortrait,
        textScale: textScale,
        overrides: [
          scpStoreProvider.overrideWithValue(store),
          publicHttpClientFactoryProvider.overrideWithValue(
            () => MockClient.streaming((request, body) {
              requests.add(request);
              return (handler ?? (_) async => _response(_scp))(request);
            }),
          ),
          dataTransferProvider.overrideWith(
            (ref) => _FakeTransfer(ref, bytes: fileBytes, error: pickError),
          ),
        ],
      );
      await _openSettings(tester);
      await _show(tester, find.text('Download address (https)'));
    }

    String urlText(WidgetTester tester) => tester
        .widget<TextField>(
          find.widgetWithText(TextField, 'Download address (https)'),
        )
        .controller!
        .text;

    testWidgets('nothing is installed or fetched by default', (tester) async {
      await setup(tester);
      expect(find.text('No list installed'), findsOneWidget);
      expect(urlText(tester), 'https://www.supercheckpartial.com/MASTER.SCP');
      expect(find.text('Remove'), findsNothing);
      expect(requests, isEmpty);
    });

    testWidgets('Download installs the list and shows what is installed', (
      tester,
    ) async {
      await setup(tester);
      await _tapText(tester, 'Download');
      expect(requests, hasLength(1));
      expect(requests.single.url.hasQuery, isFalse);
      expect(requests.single.headers['user-agent'], startsWith('Tideline/'));
      expect(find.text('List installed: 21 callsigns.'), findsOneWidget);
      expect(store.text, _scp);
      await _show(tester, find.textContaining('21 callsigns · installed'));
      expect(
        find.text('Source: https://www.supercheckpartial.com/MASTER.SCP'),
        findsOneWidget,
      );
      expect(find.text('Remove'), findsOneWidget);
    });

    testWidgets('an http address is rejected with a message, nothing is sent', (
      tester,
    ) async {
      await setup(tester);
      await tester.enterText(
        find.widgetWithText(TextField, 'Download address (https)'),
        'http://www.supercheckpartial.com/MASTER.SCP',
      );
      await _tapText(tester, 'Download');
      expect(find.text('Only https addresses are allowed.'), findsOneWidget);
      expect(requests, isEmpty);
      expect(store.stored, isNull);
    });

    testWidgets('a file over 8 MiB is refused and not stored', (tester) async {
      await setup(
        tester,
        handler: (_) async => http.StreamedResponse(
          const Stream.empty(),
          200,
          contentLength: maxScpBytes + 1,
        ),
      );
      await _tapText(tester, 'Download');
      expect(
        find.text('The file is larger than 8 MiB. It was not stored.'),
        findsOneWidget,
      );
      expect(store.stored, isNull);
    });

    testWidgets('content that is not a MASTER.SCP is refused', (tester) async {
      await setup(tester, handler: (_) async => _response('<html>oops</html>'));
      await _tapText(tester, 'Download');
      expect(
        find.text('This is not a MASTER.SCP file (one callsign per line).'),
        findsOneWidget,
      );
      expect(store.stored, isNull);
    });

    testWidgets('an HTTP error status is shown with its code', (tester) async {
      await setup(tester, handler: (_) async => _response('', status: 503));
      await _tapText(tester, 'Download');
      expect(
        find.text('The server answered with HTTP status 503.'),
        findsOneWidget,
      );
    });

    testWidgets('a network failure is explained', (tester) async {
      await setup(
        tester,
        handler: (_) async => throw http.ClientException('refused'),
      );
      await _tapText(tester, 'Download');
      expect(
        find.text(
          'The server could not be reached. Check your connection and the '
          'address.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('progress is shown while downloading', (tester) async {
      final body = StreamController<List<int>>();
      await setup(
        tester,
        handler: (_) async => http.StreamedResponse(body.stream, 200),
      );
      final finder = find.text('Download');
      await _show(tester, finder);
      await tester.tap(finder);
      await tester.pump();
      body.add(utf8.encode(_scp));
      await tester.pump();
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.textContaining('Downloading the list'), findsWidgets);
      await body.close();
      await tester.pumpAndSettle();
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.text('List installed: 21 callsigns.'), findsOneWidget);
    });

    testWidgets('a file can be imported', (tester) async {
      await setup(tester, fileBytes: utf8.encode(_scp));
      await _tapText(tester, 'Import file');
      expect(store.text, _scp);
      expect(store.stored!.sourceUrl, scpLocalFileSource);
      await _show(tester, find.text('Source: a file you imported'));
    });

    testWidgets('a file over 8 MiB is refused before it is read', (
      tester,
    ) async {
      await setup(tester, pickError: const ImportTooLargeException());
      await _tapText(tester, 'Import file');
      expect(
        find.text('The file is larger than 8 MiB. It was not stored.'),
        findsOneWidget,
      );
    });

    testWidgets('Remove asks first, then removes the list', (tester) async {
      await setup(tester);
      await _tapText(tester, 'Download');
      await _tapText(tester, 'Remove');
      expect(find.text('Remove the list?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(store.stored, isNotNull);

      await _tapText(tester, 'Remove');
      await tester.tap(find.text('Remove').last);
      await tester.pumpAndSettle();
      expect(store.stored, isNull);
      expect(find.text('List removed.'), findsOneWidget);
      expect(find.text('No list installed'), findsOneWidget);
    });

    testWidgets('meets the guidelines at 200 % text', (tester) async {
      final handle = tester.ensureSemantics();
      await setup(tester, textScale: 2);
      expect(tester.takeException(), isNull);
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });
  });

  group('worked-before index', () {
    late _RebuildableWorkedBefore index;

    Future<void> setup(WidgetTester tester) async {
      index = _RebuildableWorkedBefore();
      await pumpTideline(
        tester,
        size: TestSizes.tabletPortrait,
        workedBefore: index,
      );
      await _openSettings(tester);
      await _show(tester, find.text('Rebuild worked-before index'));
    }

    testWidgets('asks first; Cancel changes nothing', (tester) async {
      await setup(tester);
      await tester.tap(find.text('Rebuild worked-before index'));
      await tester.pumpAndSettle();
      expect(find.text('Rebuild the index?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(index.rebuilt, isEmpty);
    });

    testWidgets('shows progress while rebuilding, then confirms', (
      tester,
    ) async {
      await setup(tester);
      index.gate = Completer<void>();
      await tester.tap(find.text('Rebuild worked-before index'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rebuild'));
      await tester.pump();
      await tester.pump();
      expect(find.text('Rebuilding the index…'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      index.gate!.complete();
      await tester.pumpAndSettle();
      expect(index.rebuilt, [testAccount.id]);
      expect(find.text('Rebuilding the index…'), findsNothing);
      expect(
        find.text(
          'Index rebuilt. The next sync adds the contacts from your Wavelog '
          'server.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('a failure is reported and closes the progress', (
      tester,
    ) async {
      await setup(tester);
      index.failWith = StateError('disk');
      await tester.tap(find.text('Rebuild worked-before index'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rebuild'));
      await tester.pumpAndSettle();
      expect(find.text('The index could not be rebuilt.'), findsOneWidget);
      expect(find.text('Rebuilding the index…'), findsNothing);
    });
  });
}

/// The id of the first bundled definition used by the fake repository.
String definitions0Id() => bundledDefinitions().first.definition.id;
