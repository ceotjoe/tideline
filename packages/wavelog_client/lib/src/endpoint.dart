import 'package:meta/meta.dart';

/// Thrown when a server address cannot be used.
class InvalidServerUrlException implements Exception {
  /// Creates the exception for [reason].
  const new(this.reason);

  /// Why the address was rejected (developer-facing).
  final InvalidServerUrlReason reason;

  @override
  String toString() => 'InvalidServerUrlException(${reason.name})';
}

/// Why a server address was rejected.
enum InvalidServerUrlReason {
  /// Not a parseable absolute http(s) URL.
  malformed,

  /// Plain HTTP to a host that is not on a private network.
  insecurePublicHttp,

  /// Plain HTTP to a private host without the user's explicit opt-in.
  httpNotAllowed,

  /// Contains credentials, a query or a fragment.
  unexpectedParts,
}

/// Location of a Wavelog installation's API v2.
///
/// Wavelog routes the API at `<base>/index.php/api/v2/…`; servers with URL
/// rewriting also accept `<base>/api/v2/…`. See
/// docs/architecture/wavelog-api.md.
@immutable
class WavelogEndpoint {
  /// Creates an endpoint for an already-normalised [baseUri].
  const new(this.baseUri, {required this.usesIndexPhp});

  /// Parses user input such as `log.example.org`,
  /// `https://example.org/wavelog/` or `https://example.org/index.php`.
  ///
  /// Plain `http` is only accepted when [allowHttpOnPrivateNetwork] is true
  /// *and* the host is a private, link-local, loopback or `.local` address
  /// (ADR 0009).
  factory parse(
    String input, {
    bool allowHttpOnPrivateNetwork = false,
    bool usesIndexPhp = true,
  }) {
    var text = input.trim();
    if (!text.contains('://')) text = 'https://$text';
    final uri = Uri.tryParse(text);
    if (uri == null ||
        !(uri.isScheme('https') || uri.isScheme('http')) ||
        uri.host.isEmpty) {
      throw const InvalidServerUrlException(InvalidServerUrlReason.malformed);
    }
    if (uri.userInfo.isNotEmpty || uri.hasQuery || uri.hasFragment) {
      throw const InvalidServerUrlException(
        InvalidServerUrlReason.unexpectedParts,
      );
    }
    if (uri.isScheme('http')) {
      if (!isPrivateHost(uri.host)) {
        throw const InvalidServerUrlException(
          InvalidServerUrlReason.insecurePublicHttp,
        );
      }
      if (!allowHttpOnPrivateNetwork) {
        throw const InvalidServerUrlException(
          InvalidServerUrlReason.httpNotAllowed,
        );
      }
    }
    final segments = [
      for (final s in uri.pathSegments)
        if (s.isNotEmpty) s,
    ];
    // Users often paste a page URL; strip index.php and anything after it.
    final indexPhp = segments.indexOf('index.php');
    final baseSegments = indexPhp >= 0
        ? segments.sublist(0, indexPhp)
        : segments;
    return WavelogEndpoint(
      uri.replace(pathSegments: baseSegments),
      usesIndexPhp: usesIndexPhp,
    );
  }

  /// The installation's base, without `index.php` and trailing slash.
  final Uri baseUri;

  /// Whether API paths are prefixed with `index.php/`.
  final bool usesIndexPhp;

  /// The same installation with the other `index.php` variant.
  WavelogEndpoint get alternative =>
      WavelogEndpoint(baseUri, usesIndexPhp: !usesIndexPhp);

  /// URL of an API v2 resource, e.g. `resolve('qso', id: '42')`.
  Uri resolve(String resource, {String? id, Map<String, String>? query}) =>
      baseUri.replace(
        pathSegments: [
          ...baseUri.pathSegments,
          if (usesIndexPhp) 'index.php',
          'api',
          'v2',
          if (resource.isNotEmpty) resource,
          ?id,
        ],
        queryParameters: query == null || query.isEmpty ? null : query,
      );

  /// Whether [host] is on a private network: RFC 1918, loopback,
  /// link-local, IPv6 unique-local, or an mDNS `.local` name.
  static bool isPrivateHost(String host) {
    final h = host.toLowerCase();
    if (h == 'localhost' || h.endsWith('.local')) return true;
    final v4 = RegExp(r'^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$')
        .firstMatch(h);
    if (v4 != null) {
      final o = [for (var i = 1; i <= 4; i++) int.parse(v4[i]!)];
      if (o.any((x) => x > 255)) return false;
      return o[0] == 10 ||
          o[0] == 127 ||
          (o[0] == 172 && o[1] >= 16 && o[1] <= 31) ||
          (o[0] == 192 && o[1] == 168) ||
          (o[0] == 169 && o[1] == 254);
    }
    final v6 = h.replaceAll('[', '').replaceAll(']', '');
    if (v6.contains(':')) {
      return v6 == '::1' ||
          v6.startsWith('fe80:') ||
          v6.startsWith('fc') ||
          v6.startsWith('fd');
    }
    return false;
  }

  @override
  bool operator ==(Object other) =>
      other is WavelogEndpoint &&
      other.baseUri == baseUri &&
      other.usesIndexPhp == usesIndexPhp;

  @override
  int get hashCode => Object.hash(baseUri, usesIndexPhp);

  @override
  String toString() => 'WavelogEndpoint($baseUri, indexPhp: $usesIndexPhp)';
}
