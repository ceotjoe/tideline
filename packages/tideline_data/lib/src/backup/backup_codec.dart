import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// The backup file could not be read (corrupt, truncated or not a Tideline
/// backup).
class BackupFormatException implements Exception {
  /// Creates the exception.
  const new(this.reason);

  /// Developer-facing reason.
  final String reason;

  @override
  String toString() => 'BackupFormatException($reason)';
}

/// The passphrase does not decrypt the backup (or the file was altered).
class BackupPassphraseException implements Exception {
  /// Creates the exception.
  const new();

  @override
  String toString() => 'BackupPassphraseException';
}

/// Encrypted backup container:
///
/// `TIDELINE-BACKUP 1\n` + header JSON + `\n` + XChaCha20-Poly1305
/// ciphertext (with MAC) of the gzipped payload. The key is derived from the
/// passphrase with Argon2id; the header is authenticated as associated data.
/// See docs/security/threat-model.md (T3).
class BackupCodec {
  /// Creates a codec. Defaults follow the OWASP Argon2id recommendation
  /// (19 MiB, 2 iterations, 1 lane).
  const new({this.memoryKiB = 19456, this.iterations = 2});

  /// Argon2id memory in KiB for new backups.
  final int memoryKiB;

  /// Argon2id iterations for new backups.
  final int iterations;

  static const _magic = 'TIDELINE-BACKUP 1\n';

  // Limits for parameters read from a file, so a crafted backup cannot make
  // the app allocate unbounded memory or spin for minutes.
  static const _maxMemoryKiB = 262144;
  static const _maxIterations = 10;

  /// Encrypts [payload] with [passphrase].
  Future<Uint8List> encrypt(List<int> payload, String passphrase) async {
    final salt = SecretKeyData.random(length: 16).bytes;
    final cipher = Xchacha20.poly1305Aead();
    final nonce = cipher.newNonce();
    final header = utf8.encode(
      jsonEncode({
        'kdf': 'argon2id',
        'm': memoryKiB,
        't': iterations,
        'p': 1,
        'salt': base64.encode(salt),
        'cipher': 'xchacha20-poly1305',
        'nonce': base64.encode(nonce),
      }),
    );
    final key = await _deriveKey(passphrase, salt, memoryKiB, iterations);
    final box = await cipher.encrypt(
      gzip.encode(payload),
      secretKey: key,
      nonce: nonce,
      aad: header,
    );
    return Uint8List.fromList([
      ...ascii.encode(_magic),
      ...header,
      0x0A,
      ...box.cipherText,
      ...box.mac.bytes,
    ]);
  }

  /// Decrypts a backup made by [encrypt].
  Future<List<int>> decrypt(List<int> file, String passphrase) async {
    final magic = ascii.encode(_magic);
    if (file.length < magic.length || !_startsWith(file, magic)) {
      throw const BackupFormatException('not a Tideline backup');
    }
    final headerEnd = file.indexOf(0x0A, magic.length);
    if (headerEnd < 0 || headerEnd - magic.length > 4096) {
      throw const BackupFormatException('no header');
    }
    final header = file.sublist(magic.length, headerEnd);
    final Map<String, dynamic> h;
    try {
      h = jsonDecode(utf8.decode(header)) as Map<String, dynamic>;
    } on Object {
      throw const BackupFormatException('malformed header');
    }
    final m = h['m'];
    final t = h['t'];
    if (h['kdf'] != 'argon2id' ||
        h['cipher'] != 'xchacha20-poly1305' ||
        h['p'] != 1 ||
        m is! int ||
        t is! int ||
        m < 8 ||
        m > _maxMemoryKiB ||
        t < 1 ||
        t > _maxIterations) {
      throw const BackupFormatException('unsupported parameters');
    }
    final List<int> salt;
    final List<int> nonce;
    try {
      salt = base64.decode(h['salt'] as String);
      nonce = base64.decode(h['nonce'] as String);
    } on Object {
      throw const BackupFormatException('malformed salt or nonce');
    }
    final body = file.sublist(headerEnd + 1);
    if (body.length < 16 || nonce.length != 24 || salt.length < 16) {
      throw const BackupFormatException('truncated');
    }
    final key = await _deriveKey(passphrase, salt, m, t);
    try {
      final plain = await Xchacha20.poly1305Aead().decrypt(
        SecretBox(
          body.sublist(0, body.length - 16),
          nonce: nonce,
          mac: Mac(body.sublist(body.length - 16)),
        ),
        secretKey: key,
        aad: header,
      );
      return gzip.decode(plain);
    } on SecretBoxAuthenticationError {
      throw const BackupPassphraseException();
    } on FormatException {
      throw const BackupFormatException('corrupt payload');
    }
  }

  static bool _startsWith(List<int> data, List<int> prefix) {
    for (var i = 0; i < prefix.length; i++) {
      if (data[i] != prefix[i]) return false;
    }
    return true;
  }

  static Future<SecretKey> _deriveKey(
    String passphrase,
    List<int> salt,
    int memory,
    int iterations,
  ) => Argon2id(
    parallelism: 1,
    memory: memory,
    iterations: iterations,
    hashLength: 32,
  ).deriveKey(secretKey: SecretKey(utf8.encode(passphrase)), nonce: salt);
}
