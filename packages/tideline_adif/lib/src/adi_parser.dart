import 'dart:convert';
import 'dart:typed_data';

import 'package:meta/meta.dart';

/// A problem found while parsing; parsing continues past it.
@immutable
class AdifWarning {
  /// Creates a warning at byte [offset].
  const new(this.kind, this.offset, {this.recordIndex, this.field});

  /// What went wrong.
  final AdifWarningKind kind;

  /// Byte offset in the input.
  final int offset;

  /// Index of the affected record, if inside one.
  final int? recordIndex;

  /// Name of the affected field, if known.
  final String? field;

  @override
  String toString() =>
      'AdifWarning(${kind.name} at $offset'
      '${recordIndex != null ? ', record $recordIndex' : ''}'
      '${field != null ? ', $field' : ''})';
}

/// Kinds of [AdifWarning].
enum AdifWarningKind {
  /// A `<…>` tag that is not a valid data-specifier; skipped.
  malformedTag,

  /// A field whose declared length runs past the end of the file.
  truncatedField,

  /// The same field appears twice in a record; the first value is kept.
  duplicateField,

  /// Data that is neither valid UTF-8 nor consistent with the length;
  /// decoded as Latin-1.
  encodingFallback,

  /// The file ended inside a record without `<EOR>`; the record is kept.
  missingEndOfRecord,
}

/// Thrown when input exceeds the parser's safety limits.
class AdifLimitException implements Exception {
  /// Creates the exception.
  const new(this.message);

  /// Which limit was exceeded.
  final String message;

  @override
  String toString() => 'AdifLimitException: $message';
}

/// Result of parsing an ADI file.
@immutable
class AdifDocument {
  /// Creates a document.
  const new({
    required this.headerText,
    required this.headerFields,
    required this.records,
    required this.warnings,
  });

  /// Free text before the first header field.
  final String headerText;

  /// Header fields by upper-case name (`ADIF_VER`, `PROGRAMID`, …).
  final Map<String, String> headerFields;

  /// Records as upper-case field name → value, in file order.
  final List<Map<String, String>> records;

  /// Recoverable problems, in file order.
  final List<AdifWarning> warnings;
}

/// Strict, defensive parser for the ADIF ADI format.
///
/// ADI is untrusted input: the parser never throws on malformed content
/// (it records [AdifWarning]s instead) and enforces size limits.
///
/// Lengths: ADI is defined as ASCII, but real files contain UTF-8 whose
/// lengths count either bytes (PHP-based loggers) or characters. The parser
/// first tries the byte interpretation and falls back to characters, then
/// to Latin-1. See docs/adr/0017-adif-import-export.md.
class AdiParser {
  /// Creates a parser with safety limits.
  const new({this.maxRecords = 500000, this.maxFieldLength = 65536});

  /// Maximum number of records accepted.
  final int maxRecords;

  /// Maximum declared length of a single field.
  final int maxFieldLength;

  static final RegExp _fieldName = RegExp(r'^[A-Za-z0-9_][A-Za-z0-9_ ]*$');

  /// Parses [bytes].
  AdifDocument parse(Uint8List bytes) {
    final warnings = <AdifWarning>[];
    final records = <Map<String, String>>[];
    final headerFields = <String, String>{};
    var headerText = '';

    var pos = 0;
    final length = bytes.length;

    int indexOfByte(int byte, int from) {
      for (var i = from; i < length; i++) {
        if (bytes[i] == byte) return i;
      }
      return -1;
    }

    // Skip a UTF-8 byte-order mark and leading whitespace: many exporters
    // emit them before a headerless file's first tag.
    if (length >= 3 &&
        bytes[0] == 0xEF &&
        bytes[1] == 0xBB &&
        bytes[2] == 0xBF) {
      pos = 3;
    }
    while (pos < length &&
        const [0x20, 0x09, 0x0A, 0x0D].contains(bytes[pos])) {
      pos++;
    }
    // Header: present unless the first character is '<'.
    var inHeader = pos < length && bytes[pos] != 0x3C; // '<'
    var current = <String, String>{};
    var textEnd = -1;

    while (pos < length) {
      final open = indexOfByte(0x3C, pos);
      if (open < 0) break;
      if (inHeader && textEnd < 0) textEnd = open;
      final close = indexOfByte(0x3E, open + 1); // '>'
      if (close < 0) {
        warnings.add(AdifWarning(AdifWarningKind.malformedTag, open));
        break;
      }
      final tag = latin1.decode(bytes.sublist(open + 1, close));
      final parts = tag.split(':');
      final name = parts.first.trim().toUpperCase();
      pos = close + 1;

      if (parts.length == 1) {
        if (name == 'EOH' && inHeader) {
          inHeader = false;
          headerText = _decodeLoose(
            bytes.sublist(0, textEnd < 0 ? open : textEnd),
          ).trim();
          continue;
        }
        if (name == 'EOR' && inHeader) {
          // No <EOH> before the first <EOR>: the file has no header, and the
          // "header fields" read so far are really the first record.
          inHeader = false;
          current = Map.of(headerFields);
          headerFields.clear();
          headerText = '';
          textEnd = -1;
        }
        if (name == 'EOR' && !inHeader) {
          if (current.isNotEmpty) {
            if (records.length >= maxRecords) {
              throw AdifLimitException('more than $maxRecords records');
            }
            records.add(current);
          }
          current = <String, String>{};
          continue;
        }
        warnings.add(
          AdifWarning(
            AdifWarningKind.malformedTag,
            open,
            recordIndex: inHeader ? null : records.length,
          ),
        );
        continue;
      }

      final declared = int.tryParse(parts[1].trim());
      if (declared == null ||
          declared < 0 ||
          parts.length > 3 ||
          !_fieldName.hasMatch(name)) {
        warnings.add(
          AdifWarning(
            AdifWarningKind.malformedTag,
            open,
            recordIndex: inHeader ? null : records.length,
          ),
        );
        continue;
      }
      if (declared > maxFieldLength) {
        throw AdifLimitException('field $name longer than $maxFieldLength');
      }

      final (value, consumed, warning) = _readValue(bytes, pos, declared);
      if (warning != null) {
        warnings.add(
          AdifWarning(
            warning,
            pos,
            recordIndex: inHeader ? null : records.length,
            field: name,
          ),
        );
      }
      pos += consumed;

      final target = inHeader ? headerFields : current;
      if (target.containsKey(name)) {
        warnings.add(
          AdifWarning(
            AdifWarningKind.duplicateField,
            open,
            recordIndex: inHeader ? null : records.length,
            field: name,
          ),
        );
      } else {
        target[name] = value;
      }
    }

    if (inHeader) {
      // Neither <EOH> nor <EOR>: there are no records; keep it as header.
      headerText = _decodeLoose(
        bytes.sublist(0, textEnd < 0 ? length : textEnd),
      ).trim();
    }
    if (current.isNotEmpty) {
      warnings.add(
        AdifWarning(
          AdifWarningKind.missingEndOfRecord,
          length,
          recordIndex: records.length,
        ),
      );
      records.add(current);
    }
    return AdifDocument(
      headerText: headerText,
      headerFields: Map.unmodifiable(headerFields),
      records: List.unmodifiable(records),
      warnings: List.unmodifiable(warnings),
    );
  }

  /// Reads a value of [declared] length starting at [start]. Returns the
  /// value, the number of bytes consumed and an optional warning.
  (String, int, AdifWarningKind?) _readValue(
    Uint8List bytes,
    int start,
    int declared,
  ) {
    final available = bytes.length - start;
    if (declared > available) {
      return (
        _decodeLoose(bytes.sublist(start)),
        available,
        AdifWarningKind.truncatedField,
      );
    }
    final slice = bytes.sublist(start, start + declared);
    bool atBoundary(int consumed) =>
        start + consumed >= bytes.length ||
        const [0x3C, 0x20, 0x0A, 0x0D, 0x09].contains(bytes[start + consumed]);

    // 1. Length in bytes, valid UTF-8 (or plain ASCII), ending where the
    //    next tag or whitespace starts.
    String? asBytes;
    try {
      asBytes = utf8.decode(slice);
      if (atBoundary(declared)) return (asBytes, declared, null);
    } on FormatException {
      // not valid UTF-8 at this length
    }
    // 2. Length in characters: take [declared] characters, if that ends on
    //    a boundary.
    final end = start + declared * 4 > bytes.length
        ? bytes.length
        : start + declared * 4;
    final rest = utf8.decode(bytes.sublist(start, end), allowMalformed: true);
    final value = String.fromCharCodes(rest.runes.take(declared));
    final consumed = utf8.encode(value).length;
    if (!value.contains('\uFFFD') && atBoundary(consumed)) {
      return (value, consumed, null);
    }
    // 3. Byte interpretation without a clean boundary (e.g. no space
    //    between fields is still valid ADI).
    if (asBytes != null) return (asBytes, declared, null);
    // 4. Latin-1 (legacy Windows files).
    return (latin1.decode(slice), declared, AdifWarningKind.encodingFallback);
  }

  String _decodeLoose(List<int> bytes) =>
      utf8.decode(bytes, allowMalformed: true);
}
