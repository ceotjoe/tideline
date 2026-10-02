import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:tideline/src/app_version.dart';
import 'package:tideline/src/features/contest/contest_providers.dart';
import 'package:tideline/src/services/app_services.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';

/// Where the MASTER.SCP download field starts. The user can change it.
const String defaultScpUrl = 'https://www.supercheckpartial.com/MASTER.SCP';

/// The hard limit for a MASTER.SCP file, downloaded or imported (8 MiB).
const int maxScpBytes = 8 * 1024 * 1024;

/// What is stored as the source of a list that came from a file.
const String scpLocalFileSource = 'file';

/// The neutral User-Agent of the download: the app and its version, nothing
/// about the user or the device.
const String scpUserAgent = 'Tideline/$appVersion';

/// Why a MASTER.SCP download or import failed. The UI localises each one.
enum ScpFailure {
  /// The address does not use https (including redirects to http).
  insecureUrl,

  /// The address is unusable: no host, or it carries a user name, password,
  /// query or fragment.
  invalidUrl,

  /// The server could not be reached or the connection broke.
  network,

  /// Connecting, or waiting for data, took too long.
  timeout,

  /// The TLS certificate was not trusted. There is no way around this.
  certificate,

  /// The file is larger than [maxScpBytes].
  tooLarge,

  /// The server answered with a status other than 200.
  httpStatus,

  /// The content is not a MASTER.SCP file.
  invalidFile,
}

/// A failed download or import.
class ScpException implements Exception {
  /// Creates the exception.
  const new(this.failure, {this.statusCode});

  /// What went wrong.
  final ScpFailure failure;

  /// The HTTP status for [ScpFailure.httpStatus].
  final int? statusCode;

  @override
  String toString() => 'ScpException(${failure.name}, $statusCode)';
}

/// Checks the address the user typed. Only plain https addresses pass:
/// nothing that could carry information about the user (user info, query,
/// fragment) and nothing that is not encrypted.
Uri parseScpUrl(String input) {
  final uri = Uri.tryParse(input.trim());
  if (uri == null || !uri.hasScheme) {
    throw const ScpException(ScpFailure.invalidUrl);
  }
  if (uri.scheme != 'https') throw const ScpException(ScpFailure.insecureUrl);
  if (uri.host.isEmpty ||
      uri.userInfo.isNotEmpty ||
      uri.hasQuery ||
      uri.hasFragment) {
    throw const ScpException(ScpFailure.invalidUrl);
  }
  return uri;
}

final RegExp _callLine = RegExp(r'^[A-Za-z0-9/]{3,15}$');

/// Throws [ScpFailure.invalidFile] unless [text] looks like MASTER.SCP: at
/// least 95 % of its lines (comments and blank lines aside) are callsigns.
/// `ScpDatabase.parse` skips bad lines silently, so an HTML error page would
/// otherwise end up as an empty list.
void validateScpText(String text) {
  var content = 0;
  var valid = 0;
  for (final line in const LineSplitter().convert(text)) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
    content++;
    if (_callLine.hasMatch(trimmed)) valid++;
  }
  if (valid == 0 || valid * 100 < content * 95) {
    throw const ScpException(ScpFailure.invalidFile);
  }
}

/// Decodes [bytes] strictly and validates them.
String decodeScp(List<int> bytes) {
  if (bytes.length > maxScpBytes) throw const ScpException(ScpFailure.tooLarge);
  final String text;
  try {
    text = utf8.decode(bytes);
  } on FormatException {
    throw const ScpException(ScpFailure.invalidFile);
  }
  validateScpText(text);
  return text;
}

/// Receives the bytes read so far and the expected total, if known.
typedef ScpProgress = void Function(int received, int? total);

/// Downloads MASTER.SCP over https with hard limits.
///
/// - Normal TLS validation only. There is no pinning here and no switch to
///   turn validation off.
/// - Redirects are followed by hand, at most [maxRedirects] times, and only
///   to https addresses.
/// - At most [maxScpBytes] are read, counted after decompression; the
///   download is aborted beyond that.
/// - It sends a GET with a neutral User-Agent and an Accept header, and
///   nothing else: no query, no cookies, no identifiers.
class ScpDownloader {
  /// Creates the downloader. [clientFactory] gives a fresh client per
  /// download, which is closed afterwards.
  const new({
    required this.clientFactory,
    this.userAgent = scpUserAgent,
    this.connectTimeout = const Duration(seconds: 20),
    this.idleTimeout = const Duration(seconds: 20),
    this.totalTimeout = const Duration(minutes: 2),
    this.maxRedirects = 3,
  });

  /// Makes the HTTP client.
  final http.Client Function() clientFactory;

  /// The User-Agent header.
  final String userAgent;

  /// How long to wait for the response headers.
  final Duration connectTimeout;

  /// How long the body may stall.
  final Duration idleTimeout;

  /// The longest a whole download may take.
  final Duration totalTimeout;

  /// How many redirects are followed.
  final int maxRedirects;

  /// Downloads [url] (already checked with [parseScpUrl]) and returns the
  /// validated text. Throws [ScpException].
  Future<String> download(Uri url, {ScpProgress? onProgress}) async {
    if (url.scheme != 'https') throw const ScpException(ScpFailure.insecureUrl);
    final client = clientFactory();
    try {
      final bytes = await _fetch(client, url, onProgress).timeout(totalTimeout);
      return decodeScp(bytes);
    } on TimeoutException {
      throw const ScpException(ScpFailure.timeout);
    } finally {
      // Closing also aborts anything still in flight.
      client.close();
    }
  }

  Future<List<int>> _fetch(
    http.Client client,
    Uri start,
    ScpProgress? onProgress,
  ) async {
    var url = start;
    for (var hops = 0; ; hops++) {
      final request = http.Request('GET', url)
        ..followRedirects = false
        ..headers['user-agent'] = userAgent
        ..headers['accept'] = 'text/plain, */*;q=0.1';
      final http.StreamedResponse response;
      try {
        response = await client.send(request).timeout(connectTimeout);
      } on Object catch (e) {
        throw _classify(e);
      }
      final status = response.statusCode;
      if (const {301, 302, 303, 307, 308}.contains(status)) {
        _discard(response);
        final location = response.headers['location'];
        if (location == null || hops >= maxRedirects) {
          throw const ScpException(ScpFailure.network);
        }
        final next = Uri.tryParse(location);
        if (next == null) throw const ScpException(ScpFailure.network);
        url = url.resolveUri(next);
        // A redirect must not downgrade to plain http, and the target may
        // not smuggle in credentials.
        if (url.scheme != 'https') {
          throw const ScpException(ScpFailure.insecureUrl);
        }
        if (url.host.isEmpty || url.userInfo.isNotEmpty) {
          throw const ScpException(ScpFailure.invalidUrl);
        }
        continue;
      }
      if (status != 200) {
        _discard(response);
        throw ScpException(ScpFailure.httpStatus, statusCode: status);
      }
      final total = response.contentLength;
      if (total != null && total > maxScpBytes) {
        _discard(response);
        throw const ScpException(ScpFailure.tooLarge);
      }
      final builder = BytesBuilder(copy: false);
      // Each chunk must arrive within [idleTimeout]; a stalled server ends
      // the download instead of hanging it.
      final chunks = StreamIterator(response.stream);
      try {
        while (await chunks.moveNext().timeout(idleTimeout)) {
          builder.add(chunks.current);
          if (builder.length > maxScpBytes) {
            throw const ScpException(ScpFailure.tooLarge);
          }
          onProgress?.call(builder.length, total);
        }
      } on ScpException {
        rethrow;
      } on Object catch (e) {
        throw _classify(e);
      } finally {
        unawaited(chunks.cancel());
      }
      return builder.takeBytes();
    }
  }

  /// Drops a response body we will not read. The cancel is not awaited:
  /// some streams only complete it once data arrives, which would turn a
  /// clear error into a timeout.
  void _discard(http.StreamedResponse response) =>
      unawaited(response.stream.listen(null).cancel());

  ScpException _classify(Object error) {
    if (error is ScpException) return error;
    if (error is TimeoutException) {
      return const ScpException(ScpFailure.timeout);
    }
    final text = error.toString();
    if (error is TlsException ||
        text.contains('CERTIFICATE_VERIFY_FAILED') ||
        text.contains('HandshakeException')) {
      return const ScpException(ScpFailure.certificate);
    }
    return const ScpException(ScpFailure.network);
  }
}

/// A plain HTTP client for public downloads: platform trust roots, nothing
/// else. Not used for Wavelog, which has its own pinning-aware client.
http.Client publicHttpClient() => IOClient(
  HttpClient()
    ..connectionTimeout = const Duration(seconds: 15)
    ..userAgent = scpUserAgent,
);

/// Makes the HTTP client of public downloads. Tests replace it.
final publicHttpClientFactoryProvider = Provider<http.Client Function()>(
  (ref) => publicHttpClient,
);

/// The MASTER.SCP downloader.
final scpDownloaderProvider = Provider<ScpDownloader>(
  (ref) =>
      ScpDownloader(clientFactory: ref.watch(publicHttpClientFactoryProvider)),
);

/// Metadata of the installed list, or null.
final FutureProvider<ScpPackInfo?> scpInfoProvider =
    FutureProvider.autoDispose<ScpPackInfo?>(
      (ref) => ref.watch(scpStoreProvider).info(),
    );

/// Installs and removes the list and tells the app that it changed, so the
/// contest hints pick up the new list.
class ScpActions {
  /// Creates the actions.
  const new(this._ref);

  final Ref _ref;

  /// Downloads from [urlText] and installs the list. Returns its metadata.
  /// Throws [ScpException].
  Future<ScpPackInfo> download(
    String urlText, {
    ScpProgress? onProgress,
  }) async {
    final url = parseScpUrl(urlText);
    final text = await _ref
        .read(scpDownloaderProvider)
        .download(url, onProgress: onProgress);
    return await _install(text, url.toString());
  }

  /// Installs the list from the bytes of a file the user picked.
  Future<ScpPackInfo> importBytes(Uint8List bytes) =>
      _install(decodeScp(bytes), scpLocalFileSource);

  /// Removes the installed list.
  Future<void> remove() async {
    await _ref.read(scpStoreProvider).clear();
    _refresh();
  }

  Future<ScpPackInfo> _install(String text, String source) async {
    try {
      final info = await _ref
          .read(scpStoreProvider)
          .replace(text, sourceUrl: source, fetchedAt: DateTime.now().toUtc());
      _refresh();
      return info;
    } on ScpFormatException {
      throw const ScpException(ScpFailure.tooLarge);
    }
  }

  void _refresh() => _ref
    ..invalidate(scpInfoProvider)
    ..invalidate(scpDatabaseProvider);
}

/// Installs and removes the list.
final scpActionsProvider = Provider<ScpActions>(ScpActions.new);
