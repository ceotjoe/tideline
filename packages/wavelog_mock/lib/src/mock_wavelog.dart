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

/// A QSO stored by the mock server.
class MockQso {
  /// Creates a stored QSO.
  new({required this.id, required this.stationId, required this.fields});

  /// Server id.
  final int id;

  /// `station_profile_id`.
  final int stationId;

  /// Lower-case field name → value, as received (plus `qso_date`
  /// normalised to `YYYY-MM-DD HH:MM:SS`).
  final Map<String, Object?> fields;
}

/// A fault the mock injects into the next matching request.
enum MockFault {
  /// Store the QSO, then answer 500 (the client cannot know it worked).
  storeThenServerError,

  /// Answer 500 without storing.
  serverError,

  /// Store the QSO, then drop the connection without a response.
  storeThenDropConnection,

  /// Answer 401 token_expired.
  tokenExpired,
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

  /// QSOs on the "server", by id.
  final Map<int, MockQso> qsos = {};

  /// Faults to inject into upcoming `POST /qso` requests, in order.
  final List<MockFault> postQsoFaults = [];

  /// Fields Wavelog lets PATCH change (Qso_resource::editable_fields).
  static const editableFields = {
    'call',
    'band',
    'band_rx',
    'rst_sent',
    'rst_rcvd',
    'gridsquare',
    'name',
    'comment',
    'notes',
    'qth',
    'prop_mode',
    'sat_name',
    'sat_mode',
    'sota_ref',
    'pota_ref',
    'wwff_ref',
    'iota',
    'sig',
    'sig_info',
    'darc_dok',
    'state',
    'cnty',
    'cqz',
    'ituz',
    'qsl_via',
    'srx',
    'stx',
    'srx_string',
    'stx_string',
  };

  int _nextQsoId = 1000;

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
    _server = await shelf_io.serve(
      (request) async {
        try {
          return await _handle(request);
        } on _DropConnection {
          // Close the socket without a response: the client sees a broken
          // connection after the server already stored the QSO.
          request.hijack((channel) => channel.sink.close());
        }
      },
      InternetAddress.loopbackIPv4,
      0,
    );
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

    final id = api.length > 3 ? int.tryParse(api[3]) : null;
    if (resource == 'qso') return await _qso(request, tok, id);

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

  Future<Response> _qso(Request request, MockToken tok, int? id) async {
    String scope(String verb) => 'qso:$verb';
    switch (request.method) {
      case 'POST' when id == null:
        if (!tok.scopes.contains(scope('write'))) {
          return _insufficientScope(scope('write'));
        }
        final body = await _jsonBody(request);
        if (body == null) return _error(400, 'invalid_json', 'Invalid JSON');
        final station = int.tryParse('${body['station_profile_id']}');
        if (station == null || !stations.any((s) => s['id'] == station)) {
          return _error(403, 'forbidden', 'Station not accessible');
        }
        if (body['qsos'] is List) {
          final list = body['qsos']! as List;
          if (body['dryrun'] == true) {
            return _json(200, {
              'data': {'dryrun': true, 'parsed': list.length},
            });
          }
          return _error(400, 'validation_error', 'Bulk import not mocked');
        }
        return await _createQso(body, station);
      case 'GET' when id == null:
        if (!tok.scopes.contains(scope('read'))) {
          return _insufficientScope(scope('read'));
        }
        return _listQsos(request.url.queryParameters);
      case 'GET':
        final q = qsos[id];
        if (q == null) return _error(404, 'not_found', 'Not found');
        return _json(200, {'data': _format(q)});
      case 'PATCH' when id != null:
        if (!tok.scopes.contains(scope('write'))) {
          return _insufficientScope(scope('write'));
        }
        final q = qsos[id];
        if (q == null) return _error(404, 'not_found', 'Not found');
        final body = await _jsonBody(request) ?? {};
        final readOnly = body.keys.where((k) => !editableFields.contains(k));
        if (readOnly.isNotEmpty) {
          return _json(400, {
            'error': {
              'code': 'validation_error',
              'message': 'Read-only fields',
              'details': {'read_only': readOnly.toList()},
            },
          });
        }
        q.fields.addAll(body);
        return _json(200, {'data': _format(q)});
      case 'DELETE' when id != null:
        if (!tok.scopes.contains(scope('delete'))) {
          return _insufficientScope(scope('delete'));
        }
        if (qsos.remove(id) == null) {
          return _error(404, 'not_found', 'Not found');
        }
        return Response(204);
      default:
        return _error(405, 'method_not_allowed', 'Method not allowed');
    }
  }

  Future<Response> _createQso(Map<String, Object?> body, int station) async {
    final missing = [
      for (final f in ['call', 'band', 'mode', 'qso_date', 'time_on'])
        if ('${body[f] ?? ''}'.isEmpty) f,
    ];
    if (missing.isNotEmpty) {
      return _json(400, {
        'error': {
          'code': 'validation_error',
          'message': 'Missing fields',
          'details': {'missing': missing},
        },
      });
    }
    final time = '${body['time_on']}'.replaceAll(':', '');
    final hh = time.substring(0, 2);
    final mm = time.substring(2, 4);
    final ss = time.length >= 6 ? time.substring(4, 6) : '00';
    final normalised = <String, Object?>{
      ...body,
      'call': '${body['call']}'.toUpperCase(),
      'band': '${body['band']}'.toLowerCase(),
      'mode': '${body['mode']}'.toUpperCase(),
      'qso_date': '${body['qso_date']} $hh:$mm:$ss',
    }..remove('station_profile_id');

    // Wavelog's duplicate rule: call + minute + band + mode + station.
    final minute = '${body['qso_date']} $hh:$mm';
    final dupe = qsos.values.any(
      (q) =>
          q.stationId == station &&
          q.fields['call'] == normalised['call'] &&
          '${q.fields['qso_date']}'.startsWith(minute) &&
          q.fields['band'] == normalised['band'] &&
          q.fields['mode'] == normalised['mode'],
    );
    if (dupe) {
      return _json(400, {
        'error': {
          'code': 'validation_error',
          'message': 'Validation failed',
          'details': {
            'duplicate': ['Duplicate for ${normalised['call']}'],
          },
        },
      });
    }

    final fault = postQsoFaults.isEmpty ? null : postQsoFaults.removeAt(0);
    if (fault == MockFault.serverError) {
      return _error(500, 'internal_error', 'Internal error');
    }
    if (fault == MockFault.tokenExpired) {
      return _error(401, 'token_expired', 'Token expired');
    }
    final q = MockQso(id: _nextQsoId++, stationId: station, fields: normalised);
    qsos[q.id] = q;
    if (fault == MockFault.storeThenServerError) {
      return _error(500, 'internal_error', 'Internal error');
    }
    if (fault == MockFault.storeThenDropConnection) {
      throw const _DropConnection();
    }
    return _json(
      201,
      {'data': _format(q)},
      headers: {'location': '/index.php/api/v2/qso/${q.id}'},
    );
  }

  Response _listQsos(Map<String, String> query) {
    final call = query['callsign']?.toUpperCase();
    final since = query['qso_since'];
    final until = query['qso_until'];
    final station = int.tryParse(query['station_id'] ?? '');
    final perPage = (int.tryParse(query['per_page'] ?? '') ?? 100).clamp(
      1,
      5000,
    );
    final page = (int.tryParse(query['page'] ?? '') ?? 1).clamp(1, 1 << 20);
    final matching =
        qsos.values.where((q) {
            final date = '${q.fields['qso_date']}'.substring(0, 10);
            return (call == null || q.fields['call'] == call) &&
                (station == null || q.stationId == station) &&
                (since == null || date.compareTo(since) >= 0) &&
                (until == null || date.compareTo(until) <= 0);
          }).toList()
          ..sort((a, b) => b.id.compareTo(a.id)); // newest first, like Wavelog
    final start = (page - 1) * perPage;
    final slice = matching.skip(start).take(perPage).toList();
    return _json(200, {
      'data': [for (final q in slice) _format(q)],
      'meta': {
        'page': page,
        'per_page': perPage,
        'count': slice.length,
        'total': matching.length,
        'total_pages': (matching.length / perPage).ceil(),
        'has_more': start + slice.length < matching.length,
      },
    });
  }

  Map<String, Object?> _format(MockQso q) => {
    'id': q.id,
    'station_id': q.stationId,
    ...q.fields,
  };

  Future<Map<String, Object?>?> _jsonBody(Request request) async {
    try {
      final decoded = jsonDecode(await request.readAsString());
      return decoded is Map<String, Object?> ? decoded : null;
    } on FormatException {
      return null;
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

class _DropConnection implements Exception {
  const new();
}
