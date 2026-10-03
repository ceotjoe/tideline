import 'dart:async';

/// Thrown when text is not well-formed CSV.
final class CsvFormatException implements Exception {
  /// Creates the exception.
  const new(this.message);

  /// What is wrong.
  final String message;

  @override
  String toString() => 'CsvFormatException: $message';
}

/// Splits a stream of text chunks into CSV records (RFC 4180).
///
/// Handles quoted fields, `""` escapes, commas and line breaks inside quotes,
/// and chunks that end anywhere, even between the two quotes of an escape.
/// Blank lines are skipped. A field longer than [maxFieldLength] or a record
/// with more than [maxColumns] fields throws, so hostile input cannot make
/// the parser allocate without bound.
Stream<List<String>> csvRows(
  Stream<String> chunks, {
  int maxFieldLength = 16 * 1024,
  int maxColumns = 64,
}) async* {
  final field = StringBuffer();
  var fieldLength = 0;
  final row = <String>[];
  var inQuotes = false;
  // A quote was seen inside a quoted field; the next char decides whether it
  // was an escape (another quote) or the end of the field.
  var pendingQuote = false;
  var sawAnything = false;
  var afterCr = false;

  void endField() {
    row.add(field.toString());
    field.clear();
    fieldLength = 0;
    if (row.length > maxColumns) {
      throw const CsvFormatException('Too many columns in a record');
    }
  }

  void put(String c) {
    field.write(c);
    if (++fieldLength > maxFieldLength) {
      throw const CsvFormatException('A field is too long');
    }
  }

  List<String>? endRecord() {
    if (!sawAnything) return null;
    endField();
    sawAnything = false;
    final done = List<String>.of(row);
    row.clear();
    return done;
  }

  await for (final chunk in chunks) {
    for (var i = 0; i < chunk.length; i++) {
      final c = chunk[i];
      if (afterCr) {
        afterCr = false;
        if (c == '\n') continue;
      }
      if (pendingQuote) {
        pendingQuote = false;
        if (c == '"') {
          put('"');
          continue;
        }
        inQuotes = false; // the quote closed the field; handle c below
      }
      if (inQuotes) {
        if (c == '"') {
          pendingQuote = true;
        } else {
          put(c);
        }
        continue;
      }
      switch (c) {
        case '"':
          if (fieldLength != 0) {
            throw const CsvFormatException('A quote inside an unquoted field');
          }
          inQuotes = true;
          sawAnything = true;
        case ',':
          sawAnything = true;
          endField();
        case '\r' || '\n':
          afterCr = c == '\r';
          final r = endRecord();
          if (r != null) yield r;
        default:
          sawAnything = true;
          put(c);
      }
    }
  }
  if (inQuotes && !pendingQuote) {
    throw const CsvFormatException('A quoted field is not closed');
  }
  final r = endRecord();
  if (r != null) yield r;
}
