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

  /// Whether `GET /catalog?topic=contest` exists (Wavelog 3.2+).
  Future<bool> hasContestCatalog() async {
    try {
      await _get('catalog', query: {'topic': 'contest'});
      return true;
    } on WavelogNotFound {
      return false;
    }
  }

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
    Map<String, String>? query,
    bool authenticated = true,
  }) async {
    final request = http.Request(
      'GET',
      endpoint.resolve(resource, query: query),
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
