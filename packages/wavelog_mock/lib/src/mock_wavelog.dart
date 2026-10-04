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

/// A contest in the mock's catalog (Wavelog `contest` table row).
class MockContest {
  /// Creates a catalog row.
  const new({
    required this.id,
    required this.name,
    required this.adifName,
    this.active = true,
  });

  /// Instance-local id.
  final int id;

  /// Display name.
  final String name;

  /// ADIF contest name.
  final String adifName;

  /// Whether the admin activated it (only active ones are in the catalog and
  /// accepted for sessions).
  final bool active;
}

/// A contest session stored by the mock server.
class MockContestSession {
  /// Creates a session.
  new({
    required this.id,
    required this.contest,
    required this.timeStart,
    required this.timeEnd,
    required this.stationId,
    required this.comment,
    required this.settings,
  });

  /// Session id.
  final int id;

  /// The contest row.
  MockContest contest;

  /// `YYYY-MM-DD HH:MM:SS`.
  String timeStart;

  /// `YYYY-MM-DD HH:MM:SS`.
  String timeEnd;

  /// Station location id.
  int stationId;

  /// Comment.
  String comment;

  /// Settings, merged over [MockWavelog.sessionSettingsDefaults].
  Map<String, Object?> settings;

  /// Linked QSO ids.
  final Set<int> qsoIds = {};
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
    List<MockContest>? contests,
  }) : tokens = tokens ?? {},
       stations = stations ?? [],
       contests = contests ?? defaultContests;

  /// Real rows of Wavelog's contest table (`install/assets/install.sql`);
  /// `DARC-WAEDC-SSB` is shipped inactive here to exercise the
  /// "not active" rejection.
  static const defaultContests = [
    MockContest(id: 1, name: 'Other', adifName: 'Other'),
    MockContest(id: 51, name: 'CQ WW WPX Contest (CW)', adifName: 'CQ-WPX-CW'),
    MockContest(id: 54, name: 'CQ WW DX Contest (CW)', adifName: 'CQ-WW-CW'),
    MockContest(id: 56, name: 'CQ WW DX Contest (SSB)', adifName: 'CQ-WW-SSB'),
    MockContest(id: 62, name: 'WAE DX Contest (CW)', adifName: 'DARC-WAEDC-CW'),
    MockContest(
      id: 64,
      name: 'WAE DX Contest (SSB)',
      adifName: 'DARC-WAEDC-SSB',
      active: false,
    ),
  ];

  /// Contest table rows known to the instance.
  final List<MockContest> contests;

  /// Contest sessions by id.
  final Map<int, MockContestSession> contestSessions = {};

  /// Defaults merged into every session's settings
  /// (`Contesting_model::session_settings_defaults`).
  static const sessionSettingsDefaults = <String, Object?>{
    'exchangetype': 'Serial',
    'copyexchangeto': '',
    'exchangefields': ['serial'],
    'callbook_lookup': true,
    'custom_name': '',
    'serial_per_band': false,
    'serial_scope': 'station',
  };

  int _nextSessionId = 1;

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

  /// Starts listening on [port] (0 = any free port).
  ///
  /// By default only the loopback interface listens, so only this computer
  /// can reach the server. Pass [address] (for example
  /// `InternetAddress.anyIPv4`) to test from a device in the same network.
  /// The mock has no TLS and a published token: never use it on a network
  /// you do not trust.
  Future<void> start({int port = 0, InternetAddress? address}) async {
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
      address ?? InternetAddress.loopbackIPv4,
      port,
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
      case 'catalog'
          when version == MockWavelogVersion.v3_2 && request.method == 'GET':
        return _catalog(request.url.queryParameters['topic']);
      case 'contest' when version == MockWavelogVersion.v3_2:
        return await _contest(request, tok, id);
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
    _applyStationOwnFields(normalised, station);

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

  /// Wavelog's `Logbook_model::import` fills the own-station fields of every
  /// uploaded QSO from the station location and discards what the upload said
  /// (verified 2026-10-03 on `dev`, docs/architecture/wavelog-api.md, "Own
  /// references"). The mock does the same, so a test can never rely on a
  /// per-QSO `my_pota_ref` reaching the server.
  void _applyStationOwnFields(Map<String, Object?> fields, int stationId) {
    const mapping = {
      'my_gridsquare': 'gridsquare',
      'my_sota_ref': 'sota',
      'my_wwff_ref': 'wwff',
      'my_pota_ref': 'pota',
      'my_sig': 'sig',
      'my_sig_info': 'sig_info',
      'my_iota': 'iota',
    };
    final station = stations.firstWhere((s) => s['id'] == stationId);
    for (final MapEntry(key: field, value: stationKey) in mapping.entries) {
      fields.remove(field);
      final value = '${station[stationKey] ?? ''}'.trim().toUpperCase();
      if (value.isNotEmpty) fields[field] = value;
    }
  }

  Response _listQsos(Map<String, String> query) {
    final format = (query['format'] ?? 'json').toLowerCase();
    if (format != 'json' && format != 'adif') {
      return _json(400, {
        'error': {
          'code': 'validation_error',
          'message': 'Unknown format',
          'details': {
            'allowed': ['json', 'adif'],
          },
        },
      });
    }
    if (format == 'adif') return _listQsosAdif(query);
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

  /// `format=adif`: ascending id, `since_id` floor, default 1000 per page.
  Response _listQsosAdif(Map<String, String> query) {
    final sinceRaw = query['since_id'];
    final since = sinceRaw == null ? 0 : int.tryParse(sinceRaw);
    if (since == null) {
      return _error(400, 'validation_error', 'since_id must be numeric');
    }
    final station = int.tryParse(query['station_id'] ?? '');
    var perPage = int.tryParse(query['per_page'] ?? '') ?? 1000;
    if (perPage < 1) perPage = 1000;
    if (perPage > 5000) perPage = 5000;
    final page = (int.tryParse(query['page'] ?? '') ?? 1).clamp(1, 1 << 20);
    final matching =
        qsos.values
            .where(
              (q) =>
                  q.id > since && (station == null || q.stationId == station),
            )
            .toList()
          ..sort((a, b) => a.id.compareTo(b.id));
    final start = (page - 1) * perPage;
    final slice = matching.skip(start).take(perPage).toList();
    final adif = StringBuffer('Wavelog mock ADIF export\n<adif_ver:5>3.1.5\n')
      ..writeln('<eoh>');
    var last = since;
    for (final q in slice) {
      adif.writeln(_adifRecord(q));
      if (q.id > last) last = q.id;
    }
    return _json(200, {
      'data': {
        'exported': slice.length,
        'lastfetchedid': last,
        'adif': slice.isEmpty ? null : adif.toString(),
      },
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

  String _adifRecord(MockQso q) {
    final out = StringBuffer();
    void field(String name, Object? value) {
      final text = '${value ?? ''}';
      if (text.isEmpty) return;
      out.write('<$name:${utf8.encode(text).length}>$text ');
    }

    final f = q.fields;
    final dateTime = '${f['qso_date']}'.split(' ');
    field('call', f['call']);
    field('band', f['band']);
    field('mode', f['mode']);
    field('submode', f['submode']);
    field('qso_date', dateTime.first.replaceAll('-', ''));
    field(
      'time_on',
      dateTime.length > 1 ? dateTime[1].replaceAll(':', '') : '',
    );
    final hz = num.tryParse('${f['freq']}');
    if (hz != null) field('freq', (hz / 1e6).toStringAsFixed(6));
    field('rst_sent', f['rst_sent']);
    field('rst_rcvd', f['rst_rcvd']);
    field('contest_id', f['contest_id']);
    field('stx', f['stx']);
    field('srx', f['srx']);
    field('stx_string', f['stx_string']);
    field('srx_string', f['srx_string']);
    out.write('<eor>');
    return out.toString();
  }

  Response _catalog(String? topic) {
    if (topic == null) {
      return _json(200, {
        'data': {
          'topics': ['contest', 'dxcc', 'subdivisions'],
        },
      });
    }
    if (topic.toLowerCase() != 'contest') {
      return _error(400, 'validation_error', 'Topic not mocked: $topic');
    }
    return _json(200, {
      'data': [
        for (final c in contests)
          if (c.active) {'id': c.id, 'contest': c.adifName, 'name': c.name},
      ],
      'meta': {'topic': 'contest'},
    });
  }

  Future<Response> _contest(Request request, MockToken tok, int? id) async {
    bool has(String verb) => tok.scopes.contains('contest:$verb');
    final query = request.url.queryParameters;
    switch (request.method) {
      case 'GET' when id == null:
        if (!has('read')) return _insufficientScope('contest:read');
        final station = int.tryParse(query['station_id'] ?? '');
        final since = int.tryParse(query['since_id'] ?? '') ?? 0;
        final list =
            contestSessions.values
                .where(
                  (s) =>
                      s.id > since &&
                      (station == null || s.stationId == station),
                )
                .toList()
              ..sort((a, b) => b.id.compareTo(a.id));
        return _json(200, {
          'data': [for (final s in list) _session(s)],
        });
      case 'GET':
        if (!has('read')) return _insufficientScope('contest:read');
        final s = contestSessions[id];
        if (s == null) return _contestNotFound();
        return _json(200, {'data': _session(s, withQsoIds: true)});
      case 'POST' when id == null:
        if (!has('write')) return _insufficientScope('contest:write');
        return await _createSession(request);
      case 'PATCH' when id != null:
        if (!has('write')) return _insufficientScope('contest:write');
        final s = contestSessions[id];
        if (s == null) return _contestNotFound();
        return await _patchSession(request, s);
      case 'DELETE' when id != null:
        if (!has('delete')) return _insufficientScope('contest:delete');
        final s = contestSessions[id];
        if (s == null) return _contestNotFound();
        final deleteQsos = query['delete_qsos'] == 'true';
        if (deleteQsos && !tok.scopes.contains('qso:delete')) {
          return _insufficientScope('qso:delete');
        }
        contestSessions.remove(id);
        for (final qid in s.qsoIds) {
          if (deleteQsos) {
            qsos.remove(qid);
          } else {
            qsos[qid]?.fields.remove('contest_id');
          }
        }
        return Response(204);
      default:
        return _error(405, 'method_not_allowed', 'Method not allowed');
    }
  }

  Future<Response> _createSession(Request request) async {
    final body = await _jsonBody(request);
    if (body == null) return _error(400, 'invalid_json', 'Invalid JSON');
    final contest = _resolveContest(body);
    if (contest is Response) return contest;
    final start = _parseTime(body['time_start']);
    final end = _parseTime(body['time_end']);
    if (start == null || end == null) {
      return _validation('time_start and time_end must be datetimes', {
        'format': 'YYYY-MM-DD HH:MM[:SS]',
      });
    }
    final station = int.tryParse('${body['station_id']}');
    if (station == null) {
      return _validation('Missing required field: station_id', {
        'missing': ['station_id'],
      });
    }
    if (!stations.any((s) => s['id'] == station)) {
      return _error(403, 'forbidden', 'station_id not accessible');
    }
    final settings = _validSettings(body['settings'] ?? <String, Object?>{});
    if (settings is Response) return settings;
    final links = _qsoIdList(body['qso_ids']);
    if (links is Response) return links;
    final session = MockContestSession(
      id: _nextSessionId++,
      contest: contest as MockContest,
      timeStart: start,
      timeEnd: end,
      stationId: station,
      comment: '${body['comment'] ?? ''}',
      settings: _derive(settings as Map<String, Object?>),
    );
    contestSessions[session.id] = session;
    final result = _link(session, links as List<int>);
    return _json(
      201,
      {
        'data': {..._session(session), if (links.isNotEmpty) ...result},
      },
      headers: {'location': '/index.php/api/v2/contest/${session.id}'},
    );
  }

  Future<Response> _patchSession(Request request, MockContestSession s) async {
    final body = await _jsonBody(request);
    if (body == null) return _error(400, 'invalid_json', 'Invalid JSON');
    const fieldKeys = [
      'contest',
      'contest_id',
      'time_start',
      'time_end',
      'station_id',
      'comment',
      'settings',
    ];
    final hasFields = fieldKeys.any(body.containsKey);
    final link = _qsoIdList(body['link_qso_ids']);
    if (link is Response) return link;
    final unlink = _qsoIdList(body['unlink_qso_ids']);
    if (unlink is Response) return unlink;
    if (!hasFields && (link as List).isEmpty && (unlink as List).isEmpty) {
      return _error(400, 'validation_error', 'No editable fields in request');
    }
    if (body.containsKey('contest') || body.containsKey('contest_id')) {
      final contest = _resolveContest(body);
      if (contest is Response) return contest;
      s.contest = contest as MockContest;
    }
    for (final key in ['time_start', 'time_end']) {
      if (!body.containsKey(key)) continue;
      final t = _parseTime(body[key]);
      if (t == null) return _validation('$key must be a datetime', null);
      if (key == 'time_start') {
        s.timeStart = t;
      } else {
        s.timeEnd = t;
      }
    }
    if (body.containsKey('station_id')) {
      final station = int.tryParse('${body['station_id']}');
      if (station == null || !stations.any((x) => x['id'] == station)) {
        return _error(403, 'forbidden', 'station_id not accessible');
      }
      s.stationId = station;
    }
    if (body.containsKey('comment')) s.comment = '${body['comment']}';
    if (body.containsKey('settings')) {
      final settings = _validSettings(body['settings']);
      if (settings is Response) return settings;
      s.settings = _derive({
        ...s.settings,
        ...settings as Map<String, Object?>,
      });
    }
    final result = <String, Object?>{};
    if ((link as List<int>).isNotEmpty) result.addAll(_link(s, link));
    if ((unlink as List<int>).isNotEmpty) {
      var removed = 0;
      for (final qid in unlink) {
        if (s.qsoIds.remove(qid)) {
          qsos[qid]?.fields.remove('contest_id');
          removed++;
        }
      }
      result['unlinked'] = removed;
    }
    return _json(200, {
      'data': {..._session(s), ...result},
    });
  }

  /// Links [ids] like `Contest_resource::perform_link`: ids already in this
  /// session are a no-op, ids in another session are skipped.
  Map<String, Object?> _link(MockContestSession s, List<int> ids) {
    var linked = 0;
    final skipped = <int>[];
    for (final qid in ids) {
      final other = contestSessions.values.any(
        (o) => o.id != s.id && o.qsoIds.contains(qid),
      );
      if (other) {
        skipped.add(qid);
      } else if (s.qsoIds.add(qid)) {
        qsos[qid]?.fields['contest_id'] = s.contest.adifName;
        linked++;
      }
    }
    return {'linked': linked, 'skipped': skipped};
  }

  Object _resolveContest(Map<String, Object?> body) {
    final name = '${body['contest'] ?? ''}'.trim();
    MockContest? found;
    String field;
    if (name.isNotEmpty) {
      field = 'contest';
      found = contests.where((c) => c.adifName == name).firstOrNull;
    } else if (body['contest_id'] != null) {
      field = 'contest_id';
      final cid = int.tryParse('${body['contest_id']}');
      found = contests.where((c) => c.id == cid).firstOrNull;
    } else {
      return _validation(
        'Missing required field: contest (ADIF contest name) or contest_id',
        {
          'missing': ['contest'],
        },
      );
    }
    if (found == null) {
      return _validation('Unknown contest', {'field': field});
    }
    if (!found.active) {
      return _validation('Contest is not active: ${found.adifName}', {
        'field': field,
      });
    }
    return found;
  }

  /// Mirrors `Contesting_model::validate_session_settings`.
  Object _validSettings(Object? settings) {
    if (settings is! Map<String, Object?>) {
      return _validation('Invalid settings: settings must be an object', null);
    }
    final errors = <String>[];
    final unknown = settings.keys.where(
      (k) => !sessionSettingsDefaults.containsKey(k),
    );
    if (unknown.isNotEmpty) {
      errors.add('unknown settings key(s): ${unknown.join(', ')}');
    }
    final fields = settings['exchangefields'];
    if (settings.containsKey('exchangefields') &&
        (fields is! List ||
            fields.isEmpty ||
            fields.any(
              (f) => !['serial', 'gridsquare', 'exchange'].contains(f),
            ))) {
      errors.add(
        'exchangefields must be a non-empty array of: '
        'serial, gridsquare, exchange',
      );
    }
    if (settings.containsKey('serial_scope') &&
        !['station', 'operator'].contains(settings['serial_scope'])) {
      errors.add("serial_scope must be 'station' or 'operator'");
    }
    for (final flag in ['callbook_lookup', 'serial_per_band']) {
      if (settings.containsKey(flag) && settings[flag] is! bool) {
        errors.add('$flag must be a boolean');
      }
    }
    if (errors.isNotEmpty) {
      return _validation('Invalid settings: ${errors.join('; ')}', {
        'errors': errors,
      });
    }
    return settings;
  }

  Map<String, Object?> _derive(Map<String, Object?> settings) {
    final fields =
        ((settings['exchangefields'] ??
                    sessionSettingsDefaults['exchangefields'])!
                as List)
            .cast<String>();
    final s = fields.contains('serial');
    final g = fields.contains('gridsquare');
    final e = fields.contains('exchange');
    final type = s && g && e
        ? 'SerialGridExchange'
        : s && g
        ? 'Serialgridsquare'
        : s && e
        ? 'Serialexchange'
        : e && g
        ? 'Exchangegridsquare'
        : s
        ? 'Serial'
        : 'Exchange';
    return {...settings, 'exchangetype': type};
  }

  /// A list of numeric QSO ids that exist on the server, else a 400/403.
  Object _qsoIdList(Object? raw) {
    if (raw == null) return <int>[];
    if (raw is! List) {
      return _validation('QSO id list must be an array', null);
    }
    final ids = <int>[];
    for (final v in raw) {
      final n = v is int ? v : int.tryParse('$v');
      if (n == null) return _validation('QSO ids must be numeric', null);
      if (!ids.contains(n)) ids.add(n);
    }
    final foreign = ids.where((i) => !qsos.containsKey(i)).toList();
    if (foreign.isNotEmpty) {
      return _json(403, {
        'error': {
          'code': 'forbidden',
          'message': 'QSO ids not accessible for this token',
          'details': {'qso_ids': foreign},
        },
      });
    }
    return ids;
  }

  /// Accepts `YYYY-MM-DD HH:MM[:SS]` and normalises to seconds.
  String? _parseTime(Object? raw) {
    final text = '${raw ?? ''}'.trim();
    final m = RegExp(r'^(\d{4}-\d{2}-\d{2}) (\d{2}):(\d{2})(?::(\d{2}))?$')
        .firstMatch(text);
    if (m == null) return null;
    final normalised = '${m[1]} ${m[2]}:${m[3]}:${m[4] ?? '00'}';
    final parsed = DateTime.tryParse(normalised.replaceFirst(' ', 'T'));
    return parsed == null ? null : normalised;
  }

  Map<String, Object?> _session(
    MockContestSession s, {
    bool withQsoIds = false,
  }) => {
    'id': s.id,
    'contest': s.contest.adifName,
    'contest_name': s.contest.name,
    'time_start': s.timeStart,
    'time_end': s.timeEnd,
    'station_id': s.stationId,
    'comment': s.comment,
    'settings': {...sessionSettingsDefaults, ...s.settings},
    'qso_count': s.qsoIds.length,
    'created_at': '2026-10-02 12:00:00',
    'updated_at': '2026-10-02 12:00:00',
    if (withQsoIds) 'qso_ids': (s.qsoIds.toList()..sort()),
  };

  Response _contestNotFound() =>
      _error(404, 'not_found', 'Contest session not found');

  Response _validation(String message, Map<String, Object?>? details) =>
      _json(400, {
        'error': {
          'code': 'validation_error',
          'message': message,
          'details': details,
        },
      });

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
