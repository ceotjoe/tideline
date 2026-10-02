import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tideline/src/features/contest/contest_providers.dart';
import 'package:tideline/src/services/app_services.dart';
import 'package:tideline/src/services/scp_download.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';

final String _scp = [
  '# MASTER.SCP test list',
  for (var i = 0; i < 20; i++) 'DL${i + 1}ABC',
  'W1AW',
  '',
].join('\n');

class _FakeServer {
  new(this.handler);

  final Future<http.StreamedResponse> Function(http.BaseRequest request)
  handler;
  final List<http.BaseRequest> requests = [];
  int clientsMade = 0;
  int clientsClosed = 0;

  http.Client make() {
    clientsMade++;
    return _ClosingClient(
      MockClient.streaming((request, body) {
        requests.add(request);
        return handler(request);
      }),
      () => clientsClosed++,
    );
  }

  ScpDownloader downloader({
    Duration idle = const Duration(seconds: 5),
    Duration connect = const Duration(seconds: 5),
  }) => ScpDownloader(
    clientFactory: make,
    idleTimeout: idle,
    connectTimeout: connect,
  );
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
  String body, {
  int status = 200,
  Map<String, String> headers = const {},
  bool withLength = true,
}) {
  final bytes = utf8.encode(body);
  return http.StreamedResponse(
    Stream.value(bytes),
    status,
    contentLength: withLength ? bytes.length : null,
    headers: headers,
  );
}

Future<ScpFailure> _failure(Future<Object?> call) async {
  try {
    await call;
  } on ScpException catch (e) {
    return e.failure;
  }
  fail('expected an ScpException');
}

final Uri _url = Uri.parse(defaultScpUrl);

void main() {
  group('address check', () {
    test('the default address is https and accepted', () {
      expect(parseScpUrl(defaultScpUrl), _url);
      expect(
        parseScpUrl('  https://example.org:8443/a/MASTER.SCP '),
        isNotNull,
      );
    });

    test('http and other schemes are rejected as insecure', () {
      for (final bad in [
        'http://www.supercheckpartial.com/MASTER.SCP',
        'HTTP://example.org/MASTER.SCP',
        'ftp://example.org/MASTER.SCP',
        'file:///etc/passwd',
        'javascript:alert(1)',
      ]) {
        expect(
          () => parseScpUrl(bad),
          throwsA(
            isA<ScpException>().having(
              (e) => e.failure,
              bad,
              ScpFailure.insecureUrl,
            ),
          ),
        );
      }
    });

    test('addresses that could carry user data are unusable', () {
      for (final bad in [
        '',
        'www.example.org/MASTER.SCP',
        'https://',
        'https://user:pw@example.org/MASTER.SCP',
        'https://example.org/MASTER.SCP?call=DO1HOZ',
        'https://example.org/MASTER.SCP?',
        'https://example.org/MASTER.SCP#me',
      ]) {
        expect(
          () => parseScpUrl(bad),
          throwsA(
            isA<ScpException>().having(
              (e) => e.failure,
              bad,
              ScpFailure.invalidUrl,
            ),
          ),
        );
      }
    });
  });

  group('download', () {
    test('returns the text and sends only a neutral request', () async {
      final server = _FakeServer((_) async => _ok(_scp));
      final progress = <int>[];
      final text = await server.downloader().download(
        _url,
        onProgress: (received, total) => progress.add(received),
      );
      expect(text, _scp);
      expect(progress, isNotEmpty);
      final request = server.requests.single;
      expect(request.method, 'GET');
      expect(request.url, _url);
      expect(request.url.hasQuery, isFalse);
      expect(request.headers['user-agent'], startsWith('Tideline/'));
      expect(request.headers.keys.map((k) => k.toLowerCase()).toSet(), {
        'user-agent',
        'accept',
      });
      expect(server.clientsClosed, 1);
    });

    test('an http address never reaches the network', () async {
      final server = _FakeServer((_) async => _ok(_scp));
      expect(
        await _failure(
          server.downloader().download(
            Uri.parse('http://example.org/MASTER.SCP'),
          ),
        ),
        ScpFailure.insecureUrl,
      );
      expect(server.clientsMade, 0);
    });

    test('a file over the limit is refused by its announced size', () async {
      final server = _FakeServer(
        (_) async => http.StreamedResponse(
          const Stream.empty(),
          200,
          contentLength: maxScpBytes + 1,
        ),
      );
      expect(
        await _failure(server.downloader().download(_url)),
        ScpFailure.tooLarge,
      );
      expect(server.clientsClosed, 1);
    });

    test('a stream over the limit is aborted when it crosses it', () async {
      var chunksRead = 0;
      final server = _FakeServer((_) async {
        Stream<List<int>> chunks() async* {
          for (var i = 0; i < 64; i++) {
            chunksRead++;
            yield Uint8List(1024 * 1024)..fillRange(0, 1024 * 1024, 0x41);
          }
        }

        // No content length: the server does not announce its size.
        return http.StreamedResponse(chunks(), 200);
      });
      expect(
        await _failure(server.downloader().download(_url)),
        ScpFailure.tooLarge,
      );
      expect(chunksRead, lessThan(12));
      expect(server.clientsClosed, 1);
    });

    test('content that is not a MASTER.SCP is rejected', () async {
      for (final body in [
        '<html><body>Error 500</body></html>',
        '',
        '# only a comment\n',
        '\u0000\u0001\u0002 binary',
      ]) {
        final server = _FakeServer((_) async => _ok(body));
        expect(
          await _failure(server.downloader().download(_url)),
          ScpFailure.invalidFile,
          reason: body,
        );
      }
    });

    test('invalid UTF-8 is rejected', () async {
      final server = _FakeServer(
        (_) async =>
            http.StreamedResponse(Stream.value([0xff, 0xfe, 0x00, 0xd8]), 200),
      );
      expect(
        await _failure(server.downloader().download(_url)),
        ScpFailure.invalidFile,
      );
    });

    test('an HTTP error status is reported with its code', () async {
      final server = _FakeServer((_) async => _ok('nope', status: 404));
      try {
        await server.downloader().download(_url);
        fail('expected a failure');
      } on ScpException catch (e) {
        expect((e.failure, e.statusCode), (ScpFailure.httpStatus, 404));
      }
    });

    test('redirects to https are followed, to http are refused', () async {
      final ok = _FakeServer((request) async {
        if (request.url.host == 'www.supercheckpartial.com') {
          return _ok(
            '',
            status: 301,
            headers: {'location': 'https://cdn.example.org/MASTER.SCP'},
          );
        }
        return _ok(_scp);
      });
      expect(await ok.downloader().download(_url), _scp);
      expect(ok.requests.map((r) => r.url.host), [
        'www.supercheckpartial.com',
        'cdn.example.org',
      ]);

      final downgrade = _FakeServer(
        (_) async => _ok(
          '',
          status: 302,
          headers: {'location': 'http://cdn.example.org/MASTER.SCP'},
        ),
      );
      expect(
        await _failure(downgrade.downloader().download(_url)),
        ScpFailure.insecureUrl,
      );
      expect(downgrade.requests, hasLength(1));
    });

    test('a redirect loop ends', () async {
      final server = _FakeServer(
        (_) async => _ok('', status: 302, headers: {'location': '/again'}),
      );
      expect(
        await _failure(server.downloader().download(_url)),
        ScpFailure.network,
      );
      expect(server.requests, hasLength(4));
    });

    test('a stalled body times out', () async {
      final server = _FakeServer(
        (_) async =>
            http.StreamedResponse(StreamController<List<int>>().stream, 200),
      );
      expect(
        await _failure(
          server
              .downloader(idle: const Duration(milliseconds: 50))
              .download(_url),
        ),
        ScpFailure.timeout,
      );
      expect(server.clientsClosed, 1);
    });

    test('a server that never answers times out', () async {
      final server = _FakeServer(
        (_) => Completer<http.StreamedResponse>().future,
      );
      expect(
        await _failure(
          server
              .downloader(connect: const Duration(milliseconds: 50))
              .download(_url),
        ),
        ScpFailure.timeout,
      );
    });

    test(
      'connection errors and untrusted certificates are told apart',
      () async {
        final down = _FakeServer(
          (_) async => throw http.ClientException('Connection refused'),
        );
        expect(
          await _failure(down.downloader().download(_url)),
          ScpFailure.network,
        );
        final tls = _FakeServer(
          (_) async =>
              throw const HandshakeException('CERTIFICATE_VERIFY_FAILED'),
        );
        expect(
          await _failure(tls.downloader().download(_url)),
          ScpFailure.certificate,
        );
      },
    );
  });

  group('installing', () {
    test(
      'a download is stored with its source, and the contest list reloads',
      () async {
        final store = _RecordingStore();
        var loads = 0;
        final server = _FakeServer((_) async => _ok(_scp));
        final container = ProviderContainer(
          overrides: [
            scpStoreProvider.overrideWithValue(store),
            publicHttpClientFactoryProvider.overrideWithValue(server.make),
            scpDatabaseProvider.overrideWith((ref) async {
              loads++;
              return null;
            }),
          ],
        );
        addTearDown(container.dispose);
        await container.read(scpDatabaseProvider.future);
        expect(loads, 1);

        final info = await container
            .read(scpActionsProvider)
            .download(defaultScpUrl);
        expect(info.callCount, 21);
        expect(store.replaced.single, (text: _scp, source: defaultScpUrl));

        await container.read(scpDatabaseProvider.future);
        expect(
          loads,
          2,
          reason: 'the contest list is reloaded after a download',
        );

        await container.read(scpActionsProvider).remove();
        expect(store.cleared, 1);
        await container.read(scpDatabaseProvider.future);
        expect(loads, 3, reason: 'and after a removal');
      },
    );
  });
}

class _RecordingStore extends Fake implements ScpStore {
  final List<({String text, String source})> replaced = [];
  int cleared = 0;

  @override
  Future<ScpPackInfo> replace(
    String text, {
    required String sourceUrl,
    required DateTime fetchedAt,
  }) async {
    replaced.add((text: text, source: sourceUrl));
    return ScpPackInfo(
      callCount: ScpDatabase.parse(text).length,
      sha256: 'x',
      sourceUrl: sourceUrl,
      fetchedAt: fetchedAt.millisecondsSinceEpoch,
    );
  }

  @override
  Future<void> clear() async => cleared++;
}
