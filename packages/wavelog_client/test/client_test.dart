import 'package:http/http.dart' as http;
import 'package:test/test.dart';
import 'package:wavelog_client/wavelog_client.dart';
import 'package:wavelog_mock/wavelog_mock.dart';

const _token = 'wl2_test_token_value';
const _allScopes = {'qso:read', 'qso:write', 'station:read'};

void main() {
  late MockWavelog server;
  late http.Client httpClient;

  Future<MockWavelog> start({
    MockWavelogVersion version = MockWavelogVersion.v3_2,
    bool urlRewriting = false,
    MockToken token = const MockToken(scopes: _allScopes),
    int? rateLimitAfter,
  }) async {
    server = MockWavelog(
      version: version,
      urlRewriting: urlRewriting,
      tokens: {_token: token},
      rateLimitAfter: rateLimitAfter,
      stations: [
        {
          'id': 3,
          'name': 'Home',
          'callsign': 'DO1HOZ',
          'gridsquare': 'JO40',
          'dxcc': 230,
          'cq': 14,
          'itu': 28,
          'active': true,
        },
      ],
    );
    await server.start();
    addTearDown(server.stop);
    return server;
  }

  setUp(() => httpClient = http.Client());
  tearDown(() => httpClient.close());

  WavelogEndpoint endpoint({bool indexPhp = true}) =>
      WavelogEndpoint(server.baseUri, usesIndexPhp: indexPhp);

  group('probeServer', () {
    test('detects 3.2 features and token scopes', () async {
      await start();
      final caps = await probeServer(
        endpoint: endpoint(),
        token: _token,
        httpClient: httpClient,
      );
      expect(caps.usesIndexPhp, isTrue);
      expect(caps.hasContestSessions, isTrue);
      expect(caps.token.scopes, _allScopes);
      expect(caps.missingRequiredScopes, isEmpty);
    });

    test('treats 3.1 as supported without contest sessions', () async {
      await start(version: MockWavelogVersion.v3_1);
      final caps = await probeServer(
        endpoint: endpoint(),
        token: _token,
        httpClient: httpClient,
      );
      expect(caps.hasContestSessions, isFalse);
    });

    test('falls back to the URL-rewrite variant', () async {
      await start(urlRewriting: true);
      final caps = await probeServer(
        endpoint: endpoint(indexPhp: false),
        token: _token,
        httpClient: httpClient,
      );
      expect(caps.usesIndexPhp, isFalse);
    });

    test('finds index.php when the user entered the other variant', () async {
      await start();
      final caps = await probeServer(
        endpoint: endpoint(indexPhp: false),
        token: _token,
        httpClient: httpClient,
      );
      expect(caps.usesIndexPhp, isTrue);
    });

    test('reports missing scopes', () async {
      await start(token: const MockToken(scopes: {'qso:write'}));
      final caps = await probeServer(
        endpoint: endpoint(),
        token: _token,
        httpClient: httpClient,
      );
      expect(caps.missingRequiredScopes, {'qso:read', 'station:read'});
    });
  });

  group('errors', () {
    test('invalid token → WavelogUnauthorized', () async {
      await start();
      final client = WavelogClient(
        endpoint: endpoint(),
        token: 'wl2_wrong',
        httpClient: httpClient,
      );
      await expectLater(
        client.tokenInfo(),
        throwsA(
          isA<WavelogUnauthorized>()
              .having((e) => e.code, 'code', 'invalid_token')
              .having((e) => e.isExpired, 'isExpired', isFalse),
        ),
      );
    });

    test('expired token is recognised', () async {
      await start(token: const MockToken(scopes: _allScopes, expired: true));
      final client = WavelogClient(
        endpoint: endpoint(),
        token: _token,
        httpClient: httpClient,
      );
      await expectLater(
        client.stations(),
        throwsA(
          isA<WavelogUnauthorized>().having((e) => e.isExpired, 'x', true),
        ),
      );
    });

    test('missing scope → WavelogForbidden.isInsufficientScope', () async {
      await start(token: const MockToken(scopes: {'qso:write'}));
      final client = WavelogClient(
        endpoint: endpoint(),
        token: _token,
        httpClient: httpClient,
      );
      await expectLater(
        client.stations(),
        throwsA(
          isA<WavelogForbidden>().having(
            (e) => e.isInsufficientScope,
            'isInsufficientScope',
            isTrue,
          ),
        ),
      );
    });

    test('429 carries Retry-After', () async {
      await start(rateLimitAfter: 0);
      final client = WavelogClient(
        endpoint: endpoint(),
        token: _token,
        httpClient: httpClient,
      );
      await expectLater(
        client.stations(),
        throwsA(
          isA<WavelogRateLimited>().having(
            (e) => e.retryAfter,
            'retryAfter',
            const Duration(seconds: 30),
          ),
        ),
      );
    });

    test('unreachable server → WavelogNetworkError', () async {
      final client = WavelogClient(
        endpoint: WavelogEndpoint(
          Uri.parse('http://127.0.0.1:1'),
          usesIndexPhp: true,
        ),
        token: _token,
        httpClient: httpClient,
        timeout: const Duration(seconds: 2),
      );
      await expectLater(client.status(), throwsA(isA<WavelogNetworkError>()));
    });

    test('error text never contains the token', () async {
      await start(token: const MockToken(scopes: {}));
      final client = WavelogClient(
        endpoint: endpoint(),
        token: _token,
        httpClient: httpClient,
      );
      try {
        await client.stations();
        fail('expected an exception');
      } on WavelogException catch (e) {
        expect(e.toString(), isNot(contains(_token)));
      }
    });

    test('status is public; other calls send the bearer token', () async {
      await start();
      final client = WavelogClient(
        endpoint: endpoint(),
        token: _token,
        httpClient: httpClient,
      );
      await client.status();
      await client.tokenInfo();
      expect(server.requests.map((r) => r.hadBearerToken), [false, true]);
    });
  });

  test('parses stations', () async {
    await start();
    final stations = await WavelogClient(
      endpoint: endpoint(),
      token: _token,
      httpClient: httpClient,
    ).stations();
    expect(stations.single.id, 3);
    expect(stations.single.callsign, 'DO1HOZ');
    expect(stations.single.gridsquare, 'JO40');
    expect(stations.single.active, isTrue);
  });

  group('model parsing is strict', () {
    test('station without id is malformed', () {
      expect(
        () => WavelogStation.fromJson(const {'callsign': 'X'}),
        throwsFormatException,
      );
    });

    test('token expiry in Wavelog format is read as UTC', () {
      final info = TokenInfo.fromJson(const {
        'name': 't',
        'scopes': ['qso:read'],
        'expires_at': '2027-01-31 12:00:00',
      });
      expect(info.expiresAt, DateTime.utc(2027, 1, 31, 12));
    });
  });
}
