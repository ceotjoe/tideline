import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

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

/// The file is an encrypted backup of Tideline 0.5.x. Newer versions contain
/// no decryption code (ADR 0034), so it cannot be restored.
class BackupEncryptedException implements Exception {
  /// Creates the exception.
  const new();

  @override
  String toString() => 'BackupEncryptedException';
}

/// Plain backup container: `TIDELINE-BACKUP 2\n` + the SHA-256 of the body
/// (32 bytes) + the gzipped payload.
///
/// The file is **not encrypted** (ADR 0034); gzip only makes it smaller and
/// the hash only detects damage, it is no protection against tampering.
/// Backup files are untrusted input when restored, so the
/// decompressed size is capped.
class BackupCodec {
  /// Creates a codec.
  const new({this.maxPayloadBytes = 256 * 1024 * 1024});

  /// Largest payload accepted when restoring, after decompression.
  final int maxPayloadBytes;

  static const _magic = 'TIDELINE-BACKUP 2\n';
  static const _legacyMagic = 'TIDELINE-BACKUP 1\n';

  /// Wraps [payload] into a backup file.
  Uint8List encode(List<int> payload) {
    final body = gzip.encode(payload);
    return Uint8List.fromList([
      ...ascii.encode(_magic),
      ...sha256.convert(body).bytes,
      ...body,
    ]);
  }

  /// Unwraps a file made by [encode].
  List<int> decode(List<int> file) {
    final magic = ascii.encode(_magic);
    if (_startsWith(file, ascii.encode(_legacyMagic))) {
      throw const BackupEncryptedException();
    }
    if (!_startsWith(file, magic)) {
      throw const BackupFormatException('not a Tideline backup');
    }
    final hashEnd = magic.length + 32;
    if (file.length <= hashEnd) {
      throw const BackupFormatException('truncated');
    }
    final body = file.sublist(hashEnd);
    final expected = file.sublist(magic.length, hashEnd);
    final actual = sha256.convert(body).bytes;
    var same = true;
    for (var i = 0; i < 32; i++) {
      if (expected[i] != actual[i]) same = false;
    }
    if (!same) throw const BackupFormatException('damaged');
    final out = _CappedSink(maxPayloadBytes);
    try {
      gzip.decoder.startChunkedConversion(out)
        ..add(body)
        ..close();
    } on _TooLarge {
      throw const BackupFormatException('payload too large');
    } on Object {
      throw const BackupFormatException('corrupt payload');
    }
    return out.bytes.takeBytes();
  }

  static bool _startsWith(List<int> data, List<int> prefix) {
    if (data.length < prefix.length) return false;
    for (var i = 0; i < prefix.length; i++) {
      if (data[i] != prefix[i]) return false;
    }
    return true;
  }
}

class _TooLarge implements Exception {
  const new();
}

class _CappedSink implements Sink<List<int>> {
  new(this._max);

  final int _max;
  final BytesBuilder bytes = BytesBuilder(copy: false);

  @override
  void add(List<int> data) {
    if (bytes.length + data.length > _max) throw const _TooLarge();
    bytes.add(data);
  }

  @override
  void close() {}
}
