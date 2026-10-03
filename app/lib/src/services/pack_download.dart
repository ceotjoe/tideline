import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show StreamProviderFamily;
import 'package:http/http.dart' as http;
import 'package:tideline/src/app_version.dart';
import 'package:tideline/src/providers.dart';
import 'package:tideline/src/services/scp_download.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';

/// The neutral User-Agent of reference pack downloads.
const String packUserAgent = 'Tideline/$appVersion';

/// Where a reference pack comes from and how large it may be.
class ReferencePackSource {
  /// Creates the description.
  const new({
    required this.program,
    required this.defaultUrl,
    required this.maxBytes,
    required this.licenceNote,
  });

  /// The programme the file belongs to.
  final ReferenceProgram program;

  /// The official address. Shown before the download; the user can change it.
  final String defaultUrl;

  /// The hard limit for the file (ADR 0021).
  final int maxBytes;

  /// Recorded with the installed pack (ADR 0013).
  final String licenceNote;
}

/// The official sources (verified 2026-10-03, ADR 0021).
const Map<ReferenceProgram, ReferencePackSource> referencePackSources = {
  ReferenceProgram.pota: ReferencePackSource(
    program: ReferenceProgram.pota,
    defaultUrl: 'https://pota.app/all_parks_ext.csv',
    maxBytes: 20 * 1024 * 1024,
    licenceNote: 'Downloaded by the user from pota.app; not redistributed.',
  ),
  ReferenceProgram.sota: ReferencePackSource(
    program: ReferenceProgram.sota,
    defaultUrl: 'https://www.sotadata.org.uk/summitslist.csv',
    maxBytes: 60 * 1024 * 1024,
    licenceNote:
        'Downloaded by the user from sotadata.org.uk; not '
        'redistributed.',
  ),
  ReferenceProgram.wwff: ReferencePackSource(
    program: ReferenceProgram.wwff,
    defaultUrl: 'https://wwff.co/wwff-data/wwff_directory.csv',
    maxBytes: 60 * 1024 * 1024,
    licenceNote: 'Downloaded by the user from wwff.co; not redistributed.',
  ),
};

/// Why a reference pack download or install failed. The UI localises each.
enum PackFailure {
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

  /// The file is larger than the limit.
  tooLarge,

  /// The server answered with a status other than 200.
  httpStatus,

  /// The content is not a pack of the expected kind.
  invalidFile,

  /// The file could not be stored on the device.
  storage,

  /// The user cancelled. Not an error to show.
  cancelled,
}

/// A failed download or install.
class PackException implements Exception {
  /// Creates the exception.
  const new(this.failure, {this.statusCode});

  /// What went wrong.
  final PackFailure failure;

  /// The HTTP status for [PackFailure.httpStatus].
  final int? statusCode;

  @override
  String toString() => 'PackException(${failure.name}, $statusCode)';
}

/// Checks an address the user typed, with the rules of [parseScpUrl]: plain
/// https only, nothing that could carry information about the user.
Uri parsePackUrl(String input) {
  try {
    return parseScpUrl(input);
  } on ScpException catch (e) {
    throw PackException(
      e.failure == ScpFailure.insecureUrl
          ? PackFailure.insecureUrl
          : PackFailure.invalidUrl,
    );
  }
}

/// A downloaded file in a temporary directory. The caller deletes it.
class DownloadedPack {
  /// Creates the record.
  const new({required this.file, required this.bytes, required this.sha256});

  /// The file.
  final File file;

  /// Its size.
  final int bytes;

  /// SHA-256 of its content, as 64 lowercase hex characters.
  final String sha256;

  /// Deletes the file and its temporary directory; never throws.
  Future<void> delete() async {
    try {
      await file.parent.delete(recursive: true);
    } on FileSystemException {
      // Nothing more can be done; the OS clears its temp area.
    }
  }
}

/// Lets the user stop a download or install that is running.
class PackCancellation {
  /// Creates a token that is not cancelled.
  new();

  bool _cancelled = false;

  /// Whether [cancel] was called.
  bool get isCancelled => _cancelled;

  /// Stops the work at the next chunk. Whatever was fetched so far is
  /// discarded and the installed pack stays as it was.
  void cancel() => _cancelled = true;

  /// Throws [PackFailure.cancelled] if [cancel] was called.
  void check() {
    if (_cancelled) throw const PackException(PackFailure.cancelled);
  }
}

/// Receives the bytes read so far and the expected total, if known.
typedef PackProgress = void Function(int received, int? total);

/// Downloads a large public file over https into a temporary file.
///
/// Same rules as the MASTER.SCP download: normal TLS validation only,
/// redirects followed by hand (at most [maxRedirects], https only), no query,
/// cookies or identifiers, and a neutral User-Agent. The body is streamed to
/// disk and hashed on the way, so a 25 MB list never sits in memory. The
/// size limit is checked against `Content-Length` and again while reading.
class PackDownloader {
  /// Creates the downloader. [clientFactory] gives a fresh client per
  /// download, closed afterwards. [tempDirectory] makes the directory the file
  /// goes to.
  const new({
    required this.clientFactory,
    this.tempDirectory = _systemTemp,
    this.userAgent = packUserAgent,
    this.connectTimeout = const Duration(seconds: 20),
    this.idleTimeout = const Duration(seconds: 20),
    this.totalTimeout = const Duration(minutes: 5),
    this.maxRedirects = 3,
  });

  static Future<Directory> _systemTemp() =>
      Directory.systemTemp.createTemp('tideline_pack_');

  /// Makes the HTTP client.
  final http.Client Function() clientFactory;

  /// Makes a fresh empty directory for the file.
  final Future<Directory> Function() tempDirectory;

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

  /// Downloads [url] (already checked with [parsePackUrl]) and returns the
  /// file. Throws [PackException]; nothing is left on disk then.
  Future<DownloadedPack> download(
    Uri url, {
    required int maxBytes,
    PackProgress? onProgress,
    PackCancellation? cancel,
  }) async {
    if (url.scheme != 'https') {
      throw const PackException(PackFailure.insecureUrl);
    }
    final Directory dir;
    try {
      dir = await tempDirectory();
    } on FileSystemException {
      throw const PackException(PackFailure.storage);
    }
    final client = clientFactory();
    var ok = false;
    try {
      final pack = await _fetch(
        client,
        url,
        File('${dir.path}/pack.csv'),
        maxBytes,
        onProgress,
        cancel,
      ).timeout(totalTimeout);
      ok = true;
      return pack;
    } on TimeoutException {
      throw const PackException(PackFailure.timeout);
    } finally {
      // Closing also aborts anything still in flight.
      client.close();
      if (!ok) {
        try {
          await dir.delete(recursive: true);
        } on FileSystemException {
          // Best effort.
        }
      }
    }
  }

  Future<DownloadedPack> _fetch(
    http.Client client,
    Uri start,
    File target,
    int maxBytes,
    PackProgress? onProgress,
    PackCancellation? cancel,
  ) async {
    var url = start;
    for (var hops = 0; ; hops++) {
      cancel?.check();
      final request = http.Request('GET', url)
        ..followRedirects = false
        ..headers['user-agent'] = userAgent
        ..headers['accept'] = 'text/csv, text/plain, */*;q=0.1';
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
          throw const PackException(PackFailure.network);
        }
        final next = Uri.tryParse(location);
        if (next == null) throw const PackException(PackFailure.network);
        url = url.resolveUri(next);
        if (url.scheme != 'https') {
          throw const PackException(PackFailure.insecureUrl);
        }
        if (url.host.isEmpty || url.userInfo.isNotEmpty) {
          throw const PackException(PackFailure.invalidUrl);
        }
        continue;
      }
      if (status != 200) {
        _discard(response);
        throw PackException(PackFailure.httpStatus, statusCode: status);
      }
      final total = response.contentLength;
      if (total != null && total > maxBytes) {
        _discard(response);
        throw const PackException(PackFailure.tooLarge);
      }
      return await _save(response, target, maxBytes, total, onProgress, cancel);
    }
  }

  Future<DownloadedPack> _save(
    http.StreamedResponse response,
    File target,
    int maxBytes,
    int? total,
    PackProgress? onProgress,
    PackCancellation? cancel,
  ) async {
    final digestSink = _DigestSink();
    final hasher = sha256.startChunkedConversion(digestSink);
    final IOSink out;
    try {
      out = target.openWrite();
    } on FileSystemException {
      throw const PackException(PackFailure.storage);
    }
    var received = 0;
    // Each chunk must arrive within [idleTimeout]; a stalled server ends the
    // download instead of hanging it.
    final chunks = StreamIterator(response.stream);
    try {
      while (await chunks.moveNext().timeout(idleTimeout)) {
        cancel?.check();
        final chunk = chunks.current;
        received += chunk.length;
        if (received > maxBytes) {
          throw const PackException(PackFailure.tooLarge);
        }
        hasher.add(chunk);
        out.add(chunk);
        onProgress?.call(received, total);
      }
      hasher.close();
      await out.flush();
      await out.close();
    } on PackException {
      rethrow;
    } on FileSystemException {
      throw const PackException(PackFailure.storage);
    } on Object catch (e) {
      throw _classify(e);
    } finally {
      unawaited(chunks.cancel());
      // A failed write leaves the sink in an error state; ignore its errors.
      unawaited(out.close().catchError((Object _) {}));
    }
    return DownloadedPack(
      file: target,
      bytes: received,
      sha256: digestSink.value.toString(),
    );
  }

  /// Drops a response body we will not read. The cancel is not awaited:
  /// some streams only complete it once data arrives.
  void _discard(http.StreamedResponse response) =>
      unawaited(response.stream.listen(null).cancel());

  PackException _classify(Object error) {
    if (error is PackException) return error;
    if (error is TimeoutException) {
      return const PackException(PackFailure.timeout);
    }
    final text = error.toString();
    if (error is TlsException ||
        text.contains('CERTIFICATE_VERIFY_FAILED') ||
        text.contains('HandshakeException')) {
      return const PackException(PackFailure.certificate);
    }
    return const PackException(PackFailure.network);
  }
}

class _DigestSink implements Sink<Digest> {
  late Digest value;

  @override
  void add(Digest data) => value = data;

  @override
  void close() {}
}

/// The pack downloader. Tests replace the client with a fake.
final packDownloaderProvider = Provider<PackDownloader>(
  (ref) =>
      PackDownloader(clientFactory: ref.watch(publicHttpClientFactoryProvider)),
);

/// The store of the downloaded SOTA, POTA and WWFF lists.
final referencePackStoreProvider = Provider<ReferencePackStore>(
  (ref) => ReferencePackStore(ref.watch(databaseProvider)),
);

/// Metadata of an installed pack, or null. Follows installs and removals.
final StreamProviderFamily<ReferencePackInfo?, ReferenceProgram>
referencePackInfoProvider = StreamProvider.autoDispose
    .family<ReferencePackInfo?, ReferenceProgram>(
      (ref, program) =>
          ref.watch(referencePackStoreProvider).watchInfo(program),
    );

/// What the install is doing, for the progress display.
enum PackPhase {
  /// Reading the file from the server.
  downloading,

  /// Reading the file and storing the references.
  installing,
}

/// Receives the phase and, while downloading, the bytes so far and the total.
typedef PackInstallProgress = void Function(
  PackPhase phase,
  int received,
  int? total,
);

/// Downloads and installs, or removes, a reference pack.
class ReferencePackActions {
  /// Creates the actions.
  const new(this._ref);

  final Ref _ref;

  /// Downloads from [urlText] (the source's default when null) and installs.
  /// Throws [PackException]. The installed pack stays as it was on failure.
  Future<ReferencePackInfo> download(
    ReferenceProgram program, {
    String? urlText,
    PackInstallProgress? onProgress,
    PackCancellation? cancel,
  }) async {
    final source = referencePackSources[program]!;
    final url = parsePackUrl(urlText ?? source.defaultUrl);
    final pack = await _ref
        .read(packDownloaderProvider)
        .download(
          url,
          maxBytes: source.maxBytes,
          onProgress: (r, t) => onProgress?.call(PackPhase.downloading, r, t),
          cancel: cancel,
        );
    try {
      onProgress?.call(PackPhase.installing, pack.bytes, pack.bytes);
      return await installFile(
        program,
        pack.file,
        sha256: pack.sha256,
        sourceUrl: url.toString(),
        cancel: cancel,
      );
    } finally {
      await pack.delete();
    }
  }

  /// Installs the pack in [file]. Throws [PackException].
  Future<ReferencePackInfo> installFile(
    ReferenceProgram program,
    File file, {
    required String sha256,
    required String sourceUrl,
    PackCancellation? cancel,
  }) async {
    final source = referencePackSources[program]!;
    final parser = ReferencePackParser(program);
    // Checked for every reference: a throw here aborts the install, whose
    // transaction was not started yet, so the installed pack is untouched.
    Stream<ProgramReference> references() =>
        parser.parse(file.openRead().transform(utf8.decoder)).map((r) {
          cancel?.check();
          return r;
        });
    try {
      final info = await _ref
          .read(referencePackStoreProvider)
          .install(
            program,
            references(),
            sourceUrl: sourceUrl,
            sha256: sha256,
            fetchedAt: DateTime.now().toUtc(),
            sourceDate: parser.sourceDate,
            licenceNote: source.licenceNote,
          );
      return info;
    } on ReferencePackFormatException {
      throw const PackException(PackFailure.invalidFile);
    } on FormatException {
      // Invalid UTF-8.
      throw const PackException(PackFailure.invalidFile);
    } on FileSystemException {
      throw const PackException(PackFailure.storage);
    }
  }

  /// Removes the pack.
  Future<void> remove(ReferenceProgram program) =>
      _ref.read(referencePackStoreProvider).clear(program);
}

/// Installs and removes reference packs.
final referencePackActionsProvider = Provider<ReferencePackActions>(
  ReferencePackActions.new,
);
