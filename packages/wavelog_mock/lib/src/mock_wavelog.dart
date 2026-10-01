import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

/// Wavelog feature levels relevant to Tideline.
enum MockWavelogVersion {
  /// 3.1.x: API v2 without contest sessions or catalog.
  v3_1,

  /// 3.2.x: adds contest sessions, logbooks and the catalog.
  v3_2,
}

/// A token known to the mock server.
class MockToken {
  /// Creates a token with [scopes].
  const new({
    required this.scopes,
    this.name = 'Tideline test',
    this.expiresAt,
    this.expired = false,
  });

  /// Granted scopes, e.g. `qso:write`.
  final Set<String> scopes;

  /// Display name.
  final String name;

  /// Expiry as Wavelog formats it (`YYYY-MM-DD HH:MM:SS`), or null.
  final String? expiresAt;

  /// Whether the server treats the token as expired.
  final bool expired;
}

/// A recorded request, for assertions in tests.
typedef RecordedRequest = ({String method, String path, bool hadBearerToken});

/// An in-process fake of the Wavelog API v2, implementing only behaviour
/// verified in docs/architecture/wavelog-api.md. CI never needs a real
/// Wavelog instance.
class MockWavelog {
  /// Creates a mock server.
  new({
    this.version = MockWavelogVersion.v3_2,
    this.urlRewriting = false,
    Map<String, MockToken>? tokens,
    List<Map<String, Object?>>? stations,
    this.rateLimitAfter,
    this.retryAfterSeconds = 30,
  }) : tokens = tokens ?? {},
       stations = stations ?? [];

  /// Feature level to emulate.
  final MockWavelogVersion version;

  /// Whether `/api/v2/…` works without `index.php/` (web-server rewrite).
  final bool urlRewriting;

  /// Known tokens by value (`wl2_…`).
  final Map<String, MockToken> tokens;

  /// Station objects as returned by `GET /station`.
  final List<Map<String, Object?>> stations;

  /// After this many authenticated requests, answer 429.
  final int? rateLimitAfter;

  /// `Retry-After` seconds sent with 429.
  final int retryAfterSeconds;

  /// Every request received, in order.
  final List<RecordedRequest> requests = [];

  HttpServer? _server;
  int _authenticatedCount = 0;

  /// Base URL of the running server (without `index.php`).
  Uri get baseUri {
    final server = _server;
    if (server == null) throw StateError('MockWavelog not started');
    return Uri.parse('http://127.0.0.1:${server.port}');
  }

  /// Starts listening on a free loopback port.
  Future<void> start() async {
    _server = await shelf_io.serve(_handle, InternetAddress.loopbackIPv4, 0);
  }

  /// Stops the server.
  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
  }

  Future<Response> _handle(Request request) async {
    final segments = request.url.pathSegments
        .where((s) => s.isNotEmpty)
        .toList();
    final auth = request.headers['authorization'];
    requests.add((
      method: request.method,
      path: '/${request.url.path}',
      hadBearerToken: auth != null && auth.startsWith('Bearer '),
    ));

    var api = segments;
    if (api.isNotEmpty && api.first == 'index.php') {
      api = api.sublist(1);
    } else if (!urlRewriting) {
      return _html404();
    }
    if (api.length < 2 || api[0] != 'api' || api[1] != 'v2') {
      return _html404();
    }
    final resource = api.length > 2 ? api[2] : 'status';
    if (api.length > 4) return _error(404, 'not_found', 'Not found');

    if (resource == 'status') {
      return _json(200, {
        'data': {'name': 'Wavelog API', 'status': 'ok'},
      });
    }

    final token = _authenticate(request);
    if (token is Response) return token;
    final tok = token! as MockToken;

    if (rateLimitAfter != null && ++_authenticatedCount > rateLimitAfter!) {
      return _json(
        429,
        {
          'error': {
            'code': 'rate_limited',
            'message': 'Too many requests',
            'details': {'retry_after': retryAfterSeconds},
          },
        },
        headers: {'retry-after': '$retryAfterSeconds'},
      );
    }

    switch (resource) {
      case 'token':
        return _json(200, {
          'data': {
            'id': 1,
            'name': tok.name,
            'owner': 'test',
            'user_id': 1,
            'scopes': tok.scopes.toList(),
            'expires_at': tok.expiresAt,
          },
        });
      case 'station' when request.method == 'GET':
        if (!tok.scopes.contains('station:read')) {
          return _insufficientScope('station:read');
        }
        return _json(200, {'data': stations});
      case 'catalog' when version == MockWavelogVersion.v3_2:
        return _json(200, {
          'data': [
            {'id': 1, 'contest': 'CQ-WW-CW', 'name': 'CQ WW DX Contest (CW)'},
          ],
        });
      default:
        return _error(404, 'not_found', 'Unknown resource');
    }
  }

  Object? _authenticate(Request request) {
    final header = request.headers['authorization'] ?? '';
    final value = header.startsWith('Bearer ')
        ? header.substring(7)
        : request.headers['x-api-key'] ?? '';
    if (value.isEmpty) {
      return _error(401, 'unauthorized', 'Missing API token');
    }
    final token = tokens[value];
    if (!value.startsWith('wl2_') || token == null) {
      return _error(401, 'invalid_token', 'Invalid token');
    }
    if (token.expired) {
      return _error(401, 'token_expired', 'Token expired');
    }
    return token;
  }

  Response _insufficientScope(String scope) => _json(403, {
    'error': {
      'code': 'insufficient_scope',
      'message': 'Token lacks scope',
      'details': {'required': scope},
    },
  });

  Response _error(int status, String code, String message) => _json(status, {
    'error': {'code': code, 'message': message, 'details': null},
  });

  Response _html404() => Response.notFound(
    '<html><body>404 Page Not Found</body></html>',
    headers: {'content-type': 'text/html'},
  );

  Response _json(
    int status,
    Object body, {
    Map<String, String> headers = const {},
  }) => Response(
    status,
    body: jsonEncode(body),
    headers: {'content-type': 'application/json', ...headers},
  );
}
