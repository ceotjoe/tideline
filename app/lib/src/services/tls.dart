import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

/// Facts about a server certificate shown in the trust-on-first-use dialog.
typedef CertificateInfo = ({
  String sha256,
  String subject,
  String issuer,
  DateTime validFrom,
  DateTime validUntil,
});

/// SHA-256 fingerprint of [cert] (DER), as upper-case hex pairs separated by
/// colons, the way browsers display it.
String fingerprintOf(X509Certificate cert) => sha256
    .convert(cert.der)
    .bytes
    .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
    .join(':');

/// An HTTP client that trusts the platform roots and, if [pinnedSha256] is
/// set, additionally exactly that one certificate for [host]. Never accepts
/// anything else: there is no "ignore certificate errors" (ADR 0009).
http.Client pinnedHttpClient({String? host, String? pinnedSha256}) {
  final client = HttpClient()
    ..connectionTimeout = const Duration(seconds: 15)
    ..badCertificateCallback = (cert, certHost, port) =>
        pinnedSha256 != null &&
        certHost == host &&
        fingerprintOf(cert) == pinnedSha256;
  return IOClient(client);
}

/// Connects to [uri] only to read the certificate that failed validation.
/// Returns null if the certificate is valid (nothing to pin) or the server
/// cannot be reached. The connection is closed before any data is sent.
Future<CertificateInfo?> inspectUntrustedCertificate(Uri uri) async {
  CertificateInfo? seen;
  final client = HttpClient()
    ..connectionTimeout = const Duration(seconds: 15)
    ..badCertificateCallback = (cert, host, port) {
      seen = (
        sha256: fingerprintOf(cert),
        subject: cert.subject,
        issuer: cert.issuer,
        validFrom: cert.startValidity.toUtc(),
        validUntil: cert.endValidity.toUtc(),
      );
      return false; // never proceed
    };
  try {
    final request = await client
        .openUrl('HEAD', uri)
        .timeout(const Duration(seconds: 15));
    final response = await request.close();
    await response.drain<void>();
  } on Object {
    // Expected when the certificate is rejected.
  } finally {
    client.close(force: true);
  }
  return seen;
}
