import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tideline/src/services/pack_download.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';

const String _potaCsv = '''
"reference","name","active","entityId","locationDesc","latitude","longitude","grid"
"US-0001","Acadia National Park","1","291","US-ME","44.31","-68.2034","FN54vh"
"US-0002","Alagnak Wild River","1","6","US-AK","59.0908","-156.463","BO19sc"
''';

final Uri _url = Uri.parse('https://pota.app/all_parks_ext.csv');

class _FakeServer {
  new(this.handler);

  final Future<http.StreamedResponse> Function(http.BaseRequest request)
  handler;
  final List<http.BaseRequest> requests = [];
  final List<Directory> dirs = [];
  int clientsClosed = 0;

  http.Client make() => _ClosingClient(
    MockClient.streaming((request, body) {
      requests.add(request);
      return handler(request);
    }),
    () => clientsClosed++,
  );

  PackDownloader downloader({
    Duration idle = const Duration(seconds: 5),
    Duration connect = const Duration(seconds: 5),
  }) => PackDownloader(
    clientFactory: make,
    tempDirectory: () async {
      final dir = await Directory.systemTemp.createTemp('tideline_test_');
      dirs.add(dir);
      addTearDown(() async {
        if (dir.existsSync()) await dir.delete(recursive: true);
      });
      return dir;
    },
    idleTimeout: idle,
    connectTimeout: connect,
  );

  bool get leftFiles => dirs.any((d) => d.existsSync());
}

class _ClosingClient extends http.BaseClient {
  new(this._inner, this._onClose);

  final http.Client _inner;
  final void Function() _onClose;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      _inner.send(request);

  @override
  void close() {
    _onClose();
    _inner.close();
  }
}

http.StreamedResponse _ok(
  List<int> bytes, {
  int status = 200,
  Map<String, String> headers = const {},
  bool withLength = true,
}) => http.StreamedResponse(
  Stream.value(bytes),
  status,
  contentLength: withLength ? bytes.length : null,
  headers: headers,
);

Future<PackFailure> _failure(Future<Object?> call) async {
  try {
    await call;
  } on PackException catch (e) {
    return e.failure;
  }
  fail('expected a PackException');
}

const int _max = 1024 * 1024;

void main() {
  group('address check', () {
    test('the official addresses are accepted', () {
      for (final s in referencePackSources.values) {
        expect(parsePackUrl(s.defaultUrl), isNotNull, reason: s.defaultUrl);
        expect(s.licenceNote, isNotEmpty);
      }
      expect(
        referencePackSources.keys.toSet(),
        ReferenceProgram.values.toSet(),
      );
    });

    test('http, credentials, query and fragment are rejected', () {
      for (final (bad, failure) in [
        ('http://pota.app/all_parks_ext.csv', PackFailure.insecureUrl),
        ('ftp://pota.app/x.csv', PackFailure.insecureUrl),
        ('https://user:pw@pota.app/x.csv', PackFailure.invalidUrl),
        ('https://pota.app/x.csv?id=1', PackFailure.invalidUrl),
        ('https://pota.app/x.csv#a', PackFailure.invalidUrl),
        ('pota.app/x.csv', PackFailure.invalidUrl),
        ('', PackFailure.invalidUrl),
      ]) {
        expect(
          () => parsePackUrl(bad),
          throwsA(isA<PackException>().having((e) => e.failure, bad, failure)),
        );
      }
    });
  });

  group('download', () {
    test('streams to a file, hashes it and sends a neutral request', () async {
      final bytes = utf8.encode(_potaCsv);
      final server = _FakeServer((_) async => _ok(bytes));
      final progress = <(int, int?)>[];
      final pack = await server.downloader().download(
        _url,
        maxBytes: _max,
        onProgress: (r, t) => progress.add((r, t)),
      );
      expect(pack.bytes, bytes.length);
      expect(pack.sha256, sha256.convert(bytes).toString());
      expect(pack.file.readAsBytesSync(), bytes);
      expect(progress.last, (bytes.length, bytes.length));

      final request = server.requests.single;
      expect(request.method, 'GET');
      expect(request.url, _url);
      expect(request.headers.keys.toSet(), {'user-agent', 'accept'});
      expect(request.headers['user-agent'], startsWith('Tideline/'));
      expect(server.clientsClosed, 1);

      await pack.delete();
      expect(server.leftFiles, isFalse);
    });

    test('a large body arrives in chunks and is hashed correctly', () async {
      final chunk = List<int>.generate(64 * 1024, (i) => i % 251);
      const count = 80; // 5 MiB
      final all = <int>[for (var i = 0; i < count; i++) ...chunk];
      final server = _FakeServer(
        (_) async => http.StreamedResponse(
          Stream.fromIterable([for (var i = 0; i < count; i++) chunk]),
          200,
          contentLength: all.length,
        ),
      );
      final pack = await server.downloader().download(_url, maxBytes: 8 * _max);
      expect(pack.bytes, all.length);
      expect(pack.sha256, sha256.convert(all).toString());
      await pack.delete();
    });

    test('an http address never reaches the network', () async {
      final server = _FakeServer((_) async => _ok(const []));
      expect(
        await _failure(
          server.downloader().download(
            Uri.parse('http://pota.app/x.csv'),
            maxBytes: _max,
          ),
        ),
        PackFailure.insecureUrl,
      );
      expect(server.requests, isEmpty);
    });

    test('a file over the limit is refused by its announced size', () async {
      final server = _FakeServer((_) async => _ok(List.filled(2000, 65)));
      expect(
        await _failure(server.downloader().download(_url, maxBytes: 1000)),
        PackFailure.tooLarge,
      );
      expect(server.leftFiles, isFalse);
    });

    test('a stream over the limit is aborted when it crosses it', () async {
      final server = _FakeServer(
        (_) async => http.StreamedResponse(
          Stream.fromIterable([
            for (var i = 0; i < 50; i++) List.filled(100, 65),
          ]),
          200,
        ),
      );
      expect(
        await _failure(server.downloader().download(_url, maxBytes: 1000)),
        PackFailure.tooLarge,
      );
      expect(server.leftFiles, isFalse);
      expect(server.clientsClosed, 1);
    });

    test('an HTTP error status is reported with its code', () async {
      final server = _FakeServer((_) async => _ok(const [], status: 404));
      try {
        await server.downloader().download(_url, maxBytes: _max);
        fail('expected an exception');
      } on PackException catch (e) {
        expect(e.failure, PackFailure.httpStatus);
        expect(e.statusCode, 404);
      }
      expect(server.leftFiles, isFalse);
    });

    test('redirects to https are followed, to http are refused', () async {
      final bytes = utf8.encode(_potaCsv);
      final ok = _FakeServer((request) async {
        if (request.url.host == 'pota.app') {
          return _ok(
            const [],
            status: 302,
            headers: {'location': 'https://storage.example.org/p.csv'},
          );
        }
        return _ok(bytes);
      });
      final pack = await ok.downloader().download(_url, maxBytes: _max);
      expect(ok.requests.map((r) => r.url.host), [
        'pota.app',
        'storage.example.org',
      ]);
      await pack.delete();

      final downgrade = _FakeServer(
        (_) async => _ok(
          const [],
          status: 301,
          headers: {'location': 'http://evil.example.org/p.csv'},
        ),
      );
      expect(
        await _failure(downgrade.downloader().download(_url, maxBytes: _max)),
        PackFailure.insecureUrl,
      );
      expect(downgrade.requests, hasLength(1));

      final creds = _FakeServer(
        (_) async => _ok(
          const [],
          status: 302,
          headers: {'location': 'https://u:p@evil.example.org/p.csv'},
        ),
      );
      expect(
        await _failure(creds.downloader().download(_url, maxBytes: _max)),
        PackFailure.invalidUrl,
      );
    });

    test('a redirect loop ends', () async {
      final server = _FakeServer(
        (_) async => _ok(
          const [],
          status: 302,
          headers: {'location': 'https://pota.app/again.csv'},
        ),
      );
      expect(
        await _failure(server.downloader().download(_url, maxBytes: _max)),
        PackFailure.network,
      );
      expect(server.requests, hasLength(4));
    });

    test('a stalled body times out and leaves nothing behind', () async {
      final server = _FakeServer(
        (_) async =>
            http.StreamedResponse(StreamController<List<int>>().stream, 200),
      );
      expect(
        await _failure(
          server
              .downloader(idle: const Duration(milliseconds: 50))
              .download(_url, maxBytes: _max),
        ),
        PackFailure.timeout,
      );
      expect(server.clientsClosed, 1);
      expect(server.leftFiles, isFalse);
    });

    test('a server that never answers times out', () async {
      final server = _FakeServer(
        (_) => Completer<http.StreamedResponse>().future,
      );
      expect(
        await _failure(
          server
              .downloader(connect: const Duration(milliseconds: 50))
              .download(_url, maxBytes: _max),
        ),
        PackFailure.timeout,
      );
    });

    test('connection errors and untrusted certificates differ', () async {
      final down = _FakeServer(
        (_) async => throw http.ClientException('Connection refused'),
      );
      expect(
        await _failure(down.downloader().download(_url, maxBytes: _max)),
        PackFailure.network,
      );
      final tls = _FakeServer(
        (_) async =>
            throw const HandshakeException('CERTIFICATE_VERIFY_FAILED'),
      );
      expect(
        await _failure(tls.downloader().download(_url, maxBytes: _max)),
        PackFailure.certificate,
      );
    });

    test('a directory that cannot be made is a storage failure', () async {
      final downloader = PackDownloader(
        clientFactory: () => MockClient((_) async => http.Response('', 200)),
        tempDirectory: () async => throw const FileSystemException('full'),
      );
      expect(
        await _failure(downloader.download(_url, maxBytes: _max)),
        PackFailure.storage,
      );
    });
  });

  group('installing', () {
    late _RecordingStore store;
    late _FakeServer server;
    late ProviderContainer container;

    void start(List<int> body) {
      store = _RecordingStore();
      server = _FakeServer((_) async => _ok(body));
      container = ProviderContainer(
        overrides: [
          referencePackStoreProvider.overrideWithValue(store),
          packDownloaderProvider.overrideWithValue(server.downloader()),
        ],
      );
      addTearDown(container.dispose);
    }

    test(
      'a download is parsed, stored with its source, and cleaned up',
      () async {
        final bytes = utf8.encode(_potaCsv);
        start(bytes);
        final phases = <PackPhase>[];
        final info = await container
            .read(referencePackActionsProvider)
            .download(
              ReferenceProgram.pota,
              onProgress: (phase, _, _) {
                if (phases.isEmpty || phases.last != phase) phases.add(phase);
              },
            );
        expect(info.count, 2);
        expect(phases, [PackPhase.downloading, PackPhase.installing]);
        final call = store.installs.single;
        expect(call.program, ReferenceProgram.pota);
        expect(call.references.map((r) => r.reference), ['US-0001', 'US-0002']);
        expect(call.sourceUrl, 'https://pota.app/all_parks_ext.csv');
        expect(call.sha256, sha256.convert(bytes).toString());
        expect(call.licenceNote, contains('pota.app'));
        expect(server.leftFiles, isFalse);
      },
    );

    test('an edited address is used and recorded', () async {
      start(utf8.encode(_potaCsv));
      await container
          .read(referencePackActionsProvider)
          .download(
            ReferenceProgram.pota,
            urlText: 'https://mirror.example.org/parks.csv',
          );
      expect(server.requests.single.url.host, 'mirror.example.org');
      expect(
        store.installs.single.sourceUrl,
        'https://mirror.example.org/parks.csv',
      );
    });

    test('an insecure address stops before any request', () async {
      start(utf8.encode(_potaCsv));
      expect(
        await _failure(
          container
              .read(referencePackActionsProvider)
              .download(ReferenceProgram.pota, urlText: 'http://pota.app/x'),
        ),
        PackFailure.insecureUrl,
      );
      expect(server.requests, isEmpty);
    });

    test('an HTML page or a file of another programme is refused', () async {
      for (final body in [
        '<html><body>Access denied</body></html>',
        'SummitCode,SummitName\nG/LD-001,Scafell\n',
      ]) {
        start(utf8.encode(body));
        expect(
          await _failure(
            container
                .read(referencePackActionsProvider)
                .download(ReferenceProgram.pota),
          ),
          PackFailure.invalidFile,
          reason: body,
        );
        expect(server.leftFiles, isFalse, reason: 'temp file removed');
      }
    });

    test('invalid UTF-8 is refused', () async {
      start([...utf8.encode('"reference","name"\n'), 0xff, 0xfe, 0x0a]);
      expect(
        await _failure(
          container
              .read(referencePackActionsProvider)
              .download(ReferenceProgram.pota),
        ),
        PackFailure.invalidFile,
      );
    });

    test('remove clears the pack', () async {
      start(const []);
      await container
          .read(referencePackActionsProvider)
          .remove(ReferenceProgram.sota);
      expect(store.cleared, [ReferenceProgram.sota]);
    });
  });
}

typedef _Install = ({
  ReferenceProgram program,
  List<ProgramReference> references,
  String sourceUrl,
  String sha256,
  String? licenceNote,
});

class _RecordingStore extends Fake implements ReferencePackStore {
  final List<_Install> installs = [];
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
    installs.add((
      program: program,
      references: list,
      sourceUrl: sourceUrl,
      sha256: sha256,
      licenceNote: licenceNote,
    ));
    return ReferencePackInfo(
      program: program,
      count: list.length,
      sha256: sha256,
      sourceUrl: sourceUrl,
      fetchedAt: fetchedAt.millisecondsSinceEpoch,
      version: '2026-10-03',
      licenceNote: licenceNote,
    );
  }

  @override
  Future<void> clear(ReferenceProgram program) async => cleared.add(program);
}
