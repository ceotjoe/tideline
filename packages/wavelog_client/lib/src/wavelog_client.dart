import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:wavelog_client/src/endpoint.dart';
import 'package:wavelog_client/src/errors.dart';
import 'package:wavelog_client/src/models.dart';

/// Low-level client for the Wavelog API v2.
///
/// Stateless apart from the endpoint; retries and backoff belong to the sync
/// engine. The token is only ever placed in the `Authorization` header.
class WavelogClient {
  /// Creates a client for [endpoint] authenticated with `token`.
  ///
  /// [httpClient] is injected so the app can apply certificate pinning
  /// (ADR 0009).
  new({
    required this.endpoint,
    required this._token,
    required http.Client httpClient,
    this.timeout = const Duration(seconds: 20),
    this.maxResponseBytes = 16 * 1024 * 1024,
  }) : _http = httpClient;

  /// Where the API lives.
  final WavelogEndpoint endpoint;
  final String _token;
  final http.Client _http;

  /// Timeout per request.
  final Duration timeout;

  /// Responses larger than this are rejected (defence against hostile or
  /// broken servers).
  final int maxResponseBytes;

  /// `GET /status` (public). Completes normally if API v2 answers.
  Future<void> status() async {
    final body = await _get('status', authenticated: false);
    final data = body['data'];
    if (data is! Map || data['status'] != 'ok') {
      throw const WavelogMalformedResponse('status: not ok');
    }
  }

  /// `GET /token`: the token's name, scopes and expiry.
  Future<TokenInfo> tokenInfo() async {
    final data = await _dataObject(_get('token'));
    return await _parse(() => TokenInfo.fromJson(data));
  }

  /// `GET /station`: the user's station locations.
  Future<List<WavelogStation>> stations() async {
    final body = await _get('station');
    final data = body['data'];
    if (data is! List) {
      throw const WavelogMalformedResponse('station: data is not a list');
    }
    return await _parse(
      () => [
        for (final item in data)
          if (item is Map<String, Object?>)
            WavelogStation.fromJson(item)
          else
            throw const FormatException('station: element is not an object'),
      ],
    );
  }

  /// `POST /qso` with a single QSO. [fields] are lower-case ADIF names as
  /// Wavelog expects them (`qso_date` YYYY-MM-DD, `time_on` HH:MM:SS,
  /// `freq` in Hz). Returns the new server id.
  ///
  /// A duplicate is reported as [WavelogValidationError] with
  /// `isDuplicate` (ADR 0008).
  Future<int> createQso({
    required int stationProfileId,
    required Map<String, Object> fields,
  }) async {
    final body = await _send(
      _jsonRequest('POST', 'qso', {
        ...fields,
        'station_profile_id': stationProfileId,
      }),
    );
    final data = body['data'];
    final id = data is Map ? int.tryParse('${data['id']}') : null;
    if (id == null) {
      throw const WavelogMalformedResponse('qso create: no id');
    }
    return id;
  }

  /// `GET /qso` filtered by date range (inclusive, UTC dates), and optionally
  /// by callsign and station. Used to reconcile uncertain uploads (with
  /// [callsign]) and to check that QSOs are on the server (without it).
  /// Follows pagination, at most [maxPages] pages of [perPage] (500 to 5000);
  /// throws [WavelogMalformedResponse] if the server has more than that, so a
  /// partial list is never mistaken for the whole.
  Future<List<WavelogQso>> findQsos({
    required DateTime since,
    required DateTime until,
    String? callsign,
    int? stationId,
    int maxPages = 50,
    int perPage = 500,
  }) async {
    String day(DateTime d) {
      final u = d.toUtc();
      return '${u.year.toString().padLeft(4, '0')}-'
          '${u.month.toString().padLeft(2, '0')}-'
          '${u.day.toString().padLeft(2, '0')}';
    }

    final out = <WavelogQso>[];
    for (var page = 1; page <= maxPages; page++) {
      final body = await _get(
        'qso',
        query: {
          'callsign': ?callsign,
          'qso_since': day(since),
          'qso_until': day(until),
          'station_id': ?stationId?.toString(),
          'page': '$page',
          'per_page': '$perPage',
        },
      );
      final data = body['data'];
      if (data is! List) {
        throw const WavelogMalformedResponse('qso list: data is not a list');
      }
      out.addAll(
        await _parse(
          () => [
            for (final item in data)
              if (item is Map<String, Object?>)
                WavelogQso.fromJson(item)
              else
                throw const FormatException('qso: element is not an object'),
          ],
        ),
      );
      final meta = body['meta'];
      if (meta is! Map || meta['has_more'] != true) return out;
    }
    throw const WavelogMalformedResponse('qso list: too many pages');
  }

  /// `PATCH /qso/{id}` with editable fields only.
  Future<void> patchQso(int id, Map<String, Object> fields) async {
    await _send(_jsonRequest('PATCH', 'qso', fields, id: '$id'));
  }

  /// `DELETE /qso/{id}`. Treats "already gone" (404) as success.
  Future<void> deleteQso(int id) async {
    final request = http.Request('DELETE', endpoint.resolve('qso', id: '$id'))
      ..headers['Authorization'] = 'Bearer $_token'
      ..headers['Accept'] = 'application/json';
    try {
      await _send(request);
    } on WavelogNotFound {
      // Deleted already, or never visible to this token: nothing to do.
    }
  }

  /// Bulk dry run: lets the server parse [qsos] without storing them.
  Future<WavelogDryRun> dryRun({
    required int stationProfileId,
    required List<Map<String, Object>> qsos,
  }) async {
    final body = await _send(
      _jsonRequest('POST', 'qso', {
        'station_profile_id': stationProfileId,
        'qsos': qsos,
        'dryrun': true,
      }),
    );
    final data = body['data'];
    final parsed = data is Map ? int.tryParse('${data['parsed']}') : null;
    if (parsed == null) {
      throw const WavelogMalformedResponse('dry run: no parsed count');
    }
    return WavelogDryRun(parsed: parsed);
  }

  http.Request _jsonRequest(
    String method,
    String resource,
    Map<String, Object> body, {
    String? id,
  }) => http.Request(method, endpoint.resolve(resource, id: id))
    ..headers['Authorization'] = 'Bearer $_token'
    ..headers['Accept'] = 'application/json'
    ..headers['Content-Type'] = 'application/json'
    ..body = jsonEncode(body);

  /// Whether `GET /catalog?topic=contest` exists (Wavelog 3.2+).
  Future<bool> hasContestCatalog() async {
    try {
      await _get('catalog', query: {'topic': 'contest'});
      return true;
    } on WavelogNotFound {
      return false;
    }
  }

  /// `GET /catalog?topic=contest`: the contests the instance admin has
  /// activated (Wavelog 3.2+; needs no scope). Throws [WavelogNotFound] on
  /// older servers.
  Future<List<WavelogContest>> contestCatalog() async {
    final data = _dataList(
      await _get('catalog', query: {'topic': 'contest'}),
      'catalog',
    );
    return await _parse(
      () => _objects(data, 'contest', WavelogContest.fromJson),
    );
  }

  /// `GET /contest` (`contest:read`), newest first. [stationId] limits the
  /// list to one station, [sinceId] returns only sessions with a greater id.
  /// The sessions do not carry `qsoIds`; use [getContestSession] for that.
  Future<List<WavelogContestSession>> listContestSessions({
    int? stationId,
    int? sinceId,
  }) async {
    final data = _dataList(
      await _get(
        'contest',
        query: {
          'station_id': ?stationId?.toString(),
          'since_id': ?sinceId?.toString(),
        },
      ),
      'contest list',
    );
    return await _parse(
      () => _objects(data, 'contest session', WavelogContestSession.fromJson),
    );
  }

  /// `GET /contest/{id}` (`contest:read`), including `qsoIds`.
  Future<WavelogContestSession> getContestSession(int id) async {
    final data = await _dataObject(_get('contest', id: '$id'));
    return await _parse(() => WavelogContestSession.fromJson(data));
  }

  /// `POST /contest` (`contest:write`). [contestAdifName] must be an active
  /// contest of the instance (else [WavelogValidationError] with
  /// `isContestRejected`). The server requires an end time. [start] and
  /// [end] are sent as UTC `YYYY-MM-DD HH:MM:SS`. [qsoIds] are linked right
  /// away; ones already in another session come back in `skippedQsoIds`.
  Future<WavelogContestSession> createContestSession({
    required String contestAdifName,
    required DateTime start,
    required DateTime end,
    required int stationId,
    String? comment,
    Map<String, Object?>? settings,
    List<int>? qsoIds,
  }) async {
    final body = await _send(
      _jsonRequest('POST', 'contest', {
        'contest': contestAdifName,
        'time_start': _serverTime(start),
        'time_end': _serverTime(end),
        'station_id': stationId,
        'comment': ?comment,
        'settings': ?settings,
        if (qsoIds != null && qsoIds.isNotEmpty) 'qso_ids': qsoIds,
      }),
    );
    final data = body['data'];
    if (data is! Map<String, Object?>) {
      throw const WavelogMalformedResponse('contest create: no session');
    }
    return await _parse(() => WavelogContestSession.fromJson(data));
  }

  /// `PATCH /contest/{id}` (`contest:write`). Only the given parts change.
  /// Linking sets the QSOs' `contest_id` on the server and unlinking clears
  /// it; ids already in another session are reported as `skippedQsoIds`.
  /// Editing session fields needs officer level on a clubstation.
  Future<WavelogContestSession> patchContestSession(
    int id, {
    List<int> linkQsoIds = const [],
    List<int> unlinkQsoIds = const [],
    String? contestAdifName,
    DateTime? start,
    DateTime? end,
    int? stationId,
    String? comment,
    Map<String, Object?>? settings,
  }) async {
    final body = await _send(
      _jsonRequest('PATCH', 'contest', {
        'contest': ?contestAdifName,
        if (start != null) 'time_start': _serverTime(start),
        if (end != null) 'time_end': _serverTime(end),
        'station_id': ?stationId,
        'comment': ?comment,
        'settings': ?settings,
        if (linkQsoIds.isNotEmpty) 'link_qso_ids': linkQsoIds,
        if (unlinkQsoIds.isNotEmpty) 'unlink_qso_ids': unlinkQsoIds,
      }, id: '$id'),
    );
    final data = body['data'];
    if (data is! Map<String, Object?>) {
      throw const WavelogMalformedResponse('contest patch: no session');
    }
    return await _parse(() => WavelogContestSession.fromJson(data));
  }

  /// `DELETE /contest/{id}` (`contest:delete`). The QSOs stay in the log
  /// unless [deleteQsos] is set, which also needs `qso:delete`. Treats
  /// "already gone" (404) as success.
  Future<void> deleteContestSession(int id, {bool deleteQsos = false}) async {
    final request =
        http.Request(
            'DELETE',
            endpoint.resolve(
              'contest',
              id: '$id',
              query: deleteQsos ? {'delete_qsos': 'true'} : null,
            ),
          )
          ..headers['Authorization'] = 'Bearer $_token'
          ..headers['Accept'] = 'application/json';
    try {
      await _send(request);
    } on WavelogNotFound {
      // Already gone.
    }
  }

  /// `GET /qso?format=adif`: one page of QSOs in ascending id order as ADIF
  /// (the full field set, unlike the JSON list). Continue with
  /// `sinceId: page.lastFetchedId` while `page.exported > 0` (or
  /// `page.hasMore`). [perPage] is capped by the server at 5000.
  Future<WavelogAdifPage> fetchQsosAdif({
    int? sinceId,
    int? stationId,
    int perPage = 5000,
  }) async {
    final body = await _get(
      'qso',
      query: {
        'format': 'adif',
        'since_id': ?sinceId?.toString(),
        'station_id': ?stationId?.toString(),
        'per_page': '${perPage.clamp(1, 5000)}',
      },
    );
    final data = body['data'];
    if (data is! Map) {
      throw const WavelogMalformedResponse('qso adif: data is not an object');
    }
    final exported = _asIntOrNull(data['exported']);
    final last = _asIntOrNull(data['lastfetchedid']);
    final adif = data['adif'];
    if (exported == null || last == null || (adif != null && adif is! String)) {
      throw const WavelogMalformedResponse('qso adif: bad exported/adif');
    }
    final meta = body['meta'];
    return WavelogAdifPage(
      exported: exported,
      lastFetchedId: last,
      adif: adif as String? ?? '',
      hasMore: meta is Map && meta['has_more'] == true,
    );
  }

  static int? _asIntOrNull(Object? v) =>
      v is int ? v : (v is String ? int.tryParse(v) : null);

  /// `YYYY-MM-DD HH:MM:SS` in UTC, as Wavelog expects datetimes.
  static String _serverTime(DateTime t) {
    final u = t.toUtc();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${u.year.toString().padLeft(4, '0')}-${two(u.month)}-${two(u.day)} '
        '${two(u.hour)}:${two(u.minute)}:${two(u.second)}';
  }

  List<Object?> _dataList(Map<String, Object?> body, String what) {
    final data = body['data'];
    if (data is! List) {
      throw WavelogMalformedResponse('$what: data is not a list');
    }
    return data;
  }

  List<T> _objects<T>(
    List<Object?> data,
    String what,
    T Function(Map<String, Object?>) parse,
  ) => [
    for (final item in data)
      if (item is Map<String, Object?>)
        parse(item)
      else
        throw FormatException('$what: element is not an object'),
  ];

  Future<Map<String, Object?>> _dataObject(
    Future<Map<String, Object?>> response,
  ) async {
    final data = (await response)['data'];
    if (data is! Map<String, Object?>) {
      throw const WavelogMalformedResponse('data is not an object');
    }
    return data;
  }

  Future<T> _parse<T>(FutureOr<T> Function() parse) async {
    try {
      return await parse();
    } on FormatException catch (e) {
      throw WavelogMalformedResponse(e.message);
    }
  }

  Future<Map<String, Object?>> _get(
    String resource, {
    String? id,
    Map<String, String>? query,
    bool authenticated = true,
  }) async {
    final request = http.Request(
      'GET',
      endpoint.resolve(resource, id: id, query: query),
    )..headers['Accept'] = 'application/json';
    if (authenticated) {
      request.headers['Authorization'] = 'Bearer $_token';
    }
    return await _send(request);
  }

  Future<Map<String, Object?>> _send(http.BaseRequest request) async {
    final http.StreamedResponse response;
    final List<int> bytes;
    try {
      response = await _http.send(request).timeout(timeout);
      bytes = await _readLimited(response.stream).timeout(timeout);
    } on TimeoutException {
      throw const WavelogNetworkError('timeout');
    } on HandshakeException {
      throw const WavelogNetworkError('tls handshake failed');
    } on SocketException catch (e) {
      throw WavelogNetworkError('socket: ${e.osError?.errorCode ?? '-'}');
    } on http.ClientException {
      throw const WavelogNetworkError('client error');
    }

    final json = _decode(bytes);
    final status = response.statusCode;
    if (status >= 200 && status < 300) {
      return json ?? const {};
    }
    final error = json?['error'];
    final code = error is Map ? error['code']?.toString() : null;
    final message = error is Map ? error['message']?.toString() : null;
    final details = error is Map ? error['details'] : null;
    throw switch (status) {
      400 => WavelogValidationError(
        code: code,
        serverMessage: message,
        details: details,
      ),
      401 => WavelogUnauthorized(code: code, serverMessage: message),
      403 => WavelogForbidden(code: code, serverMessage: message),
      404 => WavelogNotFound(code: code, serverMessage: message),
      409 => WavelogConflict(code: code, serverMessage: message),
      429 => WavelogRateLimited(
        retryAfter: _retryAfter(response.headers, details),
        code: code,
        serverMessage: message,
      ),
      _ => WavelogServerError(
        statusCode: status,
        code: code,
        serverMessage: message,
      ),
    };
  }

  Future<List<int>> _readLimited(Stream<List<int>> stream) async {
    final out = <int>[];
    await for (final chunk in stream) {
      out.addAll(chunk);
      if (out.length > maxResponseBytes) {
        throw const WavelogMalformedResponse('response too large');
      }
    }
    return out;
  }

  Map<String, Object?>? _decode(List<int> bytes) {
    if (bytes.isEmpty) return null;
    try {
      final decoded = jsonDecode(utf8.decode(bytes));
      return decoded is Map<String, Object?> ? decoded : null;
    } on FormatException {
      return null;
    }
  }

  Duration _retryAfter(Map<String, String> headers, Object? details) {
    final header = int.tryParse(headers['retry-after'] ?? '');
    final fromDetails = details is Map
        ? int.tryParse('${details['retry_after']}')
        : null;
    final seconds = header ?? fromDetails ?? 60;
    return Duration(seconds: seconds.clamp(1, 3600));
  }
}

/// Finds out how to talk to a Wavelog installation and what it supports.
///
/// Tries the `index.php` URL variant first, then the rewritten one; checks
/// the token and its scopes; detects Wavelog 3.2 features. No version
/// endpoint is available to non-admin tokens (ADR 0007).
Future<ServerCapabilities> probeServer({
  required WavelogEndpoint endpoint,
  required String token,
  required http.Client httpClient,
}) async {
  WavelogClient clientFor(WavelogEndpoint e) =>
      WavelogClient(endpoint: e, token: token, httpClient: httpClient);

  var client = clientFor(endpoint);
  try {
    await client.status();
  } on WavelogException catch (first) {
    if (first is! WavelogNotFound && first is! WavelogMalformedResponse) {
      rethrow;
    }
    client = clientFor(endpoint.alternative);
    try {
      await client.status();
    } on WavelogException {
      // Report the failure of the preferred variant.
      throw first;
    }
  }
  final token0 = await client.tokenInfo();
  final contest = await client.hasContestCatalog();
  return ServerCapabilities(
    usesIndexPhp: client.endpoint.usesIndexPhp,
    token: token0,
    hasContestSessions: contest,
  );
}
