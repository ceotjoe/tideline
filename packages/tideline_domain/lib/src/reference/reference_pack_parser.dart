import 'dart:async';

import 'package:tideline_domain/src/reference/csv_rows.dart';
import 'package:tideline_domain/src/reference/program_reference.dart';
import 'package:tideline_domain/src/reference/reference_program.dart';

/// Thrown when a downloaded file is not a reference pack of the expected kind.
final class ReferencePackFormatException implements Exception {
  /// Creates the exception.
  const new(this.message);

  /// What is wrong.
  final String message;

  @override
  String toString() => 'ReferencePackFormatException: $message';
}

/// Parses the official CSV file of one programme into [ProgramReference]s.
///
/// Strict where it matters: the header row must contain every column the
/// parser needs, otherwise the whole file is rejected and nothing is
/// installed. Individual bad rows (invalid reference, wrong column count) are
/// skipped and counted in [skipped]. Extra columns are ignored.
///
/// Input comes in as text chunks and references go out one by one, so a
/// 25 MB file is never held in memory.
final class ReferencePackParser {
  /// Creates a parser for [program].
  ///
  /// At most [maxRows] data rows are read; more throws.
  new(this.program, {this.maxRows = 400000});

  /// The programme the file belongs to.
  final ReferenceProgram program;

  /// The cap on data rows.
  final int maxRows;

  /// Data rows that were not usable. Valid once the stream has ended.
  int get skipped => _skipped;
  int _skipped = 0;

  /// Data rows seen, usable or not. Valid once the stream has ended.
  int get rowCount => _rowCount;
  int _rowCount = 0;

  /// The date in the first line of a SOTA file (`Date=dd/mm/yyyy`), if any.
  DateTime? get sourceDate => _sourceDate;
  DateTime? _sourceDate;

  /// Parses [chunks]. Throws [ReferencePackFormatException] on a bad file.
  Stream<ProgramReference> parse(Stream<String> chunks) async* {
    _skipped = 0;
    _rowCount = 0;
    _sourceDate = null;
    Map<String, int>? columns;
    var first = true;
    try {
      await for (final row in csvRows(chunks)) {
        if (first) {
          first = false;
          // SOTA puts a title line (one field) above the real header.
          if (program == ReferenceProgram.sota && row.length == 1) {
            _sourceDate = _sotaTitleDate(row.single);
            continue;
          }
        }
        if (columns == null) {
          columns = _columnsOf(row);
          continue;
        }
        if (++_rowCount > maxRows) {
          throw const ReferencePackFormatException('Too many rows');
        }
        final ref = _toReference(row, columns);
        if (ref == null) {
          _skipped++;
        } else {
          yield ref;
        }
      }
    } on CsvFormatException catch (e) {
      throw ReferencePackFormatException(e.message);
    }
    if (columns == null) {
      throw const ReferencePackFormatException('The file is empty');
    }
  }

  List<String> get _required => switch (program) {
    ReferenceProgram.pota => const [
      'reference',
      'name',
      'active',
      'locationDesc',
      'latitude',
      'longitude',
    ],
    ReferenceProgram.sota => const [
      'SummitCode',
      'SummitName',
      'RegionName',
      'Longitude',
      'Latitude',
      'ValidFrom',
      'ValidTo',
    ],
    ReferenceProgram.wwff => const [
      'reference',
      'status',
      'name',
      'country',
      'latitude',
      'longitude',
      'validFrom',
      'validTo',
    ],
  };

  Map<String, int> _columnsOf(List<String> header) {
    final map = <String, int>{};
    for (var i = 0; i < header.length; i++) {
      // A byte order mark in front of the first name is harmless.
      map[header[i].replaceFirst('﻿', '').trim()] = i;
    }
    final missing = _required.where((c) => !map.containsKey(c)).toList();
    if (missing.isNotEmpty) {
      throw ReferencePackFormatException(
        'Not a ${program.code} file: missing column ${missing.first}',
      );
    }
    return map;
  }

  ProgramReference? _toReference(List<String> row, Map<String, int> cols) {
    String? cell(String name) {
      final i = cols[name];
      if (i == null || i >= row.length) return null;
      final v = row[i].trim();
      return v.isEmpty ? null : v;
    }

    final (
      refName,
      activeName,
      regionName,
      latName,
      lonName,
      fromName,
      toName,
    ) = switch (program) {
      ReferenceProgram.pota => (
        'reference',
        'active',
        'locationDesc',
        'latitude',
        'longitude',
        null,
        null,
      ),
      ReferenceProgram.sota => (
        'SummitCode',
        null,
        'RegionName',
        'Latitude',
        'Longitude',
        'ValidFrom',
        'ValidTo',
      ),
      ReferenceProgram.wwff => (
        'reference',
        'status',
        'country',
        'latitude',
        'longitude',
        'validFrom',
        'validTo',
      ),
    };

    final reference = cell(refName)?.toUpperCase();
    final name = cell(program == ReferenceProgram.sota ? 'SummitName' : 'name');
    if (reference == null ||
        name == null ||
        !program.isValidReference(reference)) {
      return null;
    }

    final active = switch (program) {
      ReferenceProgram.pota => cell(activeName!) == '1',
      // `national` entries are real references of a national list.
      ReferenceProgram.wwff => const {
        'active',
        'national',
      }.contains(cell(activeName!)?.toLowerCase()),
      ReferenceProgram.sota => true,
    };

    return ProgramReference(
      program: program,
      reference: reference,
      name: name,
      region: cell(regionName),
      latitude: _coordinate(cell(latName), 90),
      longitude: _coordinate(cell(lonName), 180),
      validFrom: fromName == null ? null : _date(cell(fromName)),
      validTo: toName == null ? null : _date(cell(toName)),
      active: active,
    );
  }

  static double? _coordinate(String? text, double limit) {
    if (text == null) return null;
    final v = double.tryParse(text);
    if (v == null || !v.isFinite || v.abs() > limit) return null;
    return v;
  }

  /// `dd/mm/yyyy` (SOTA) or `yyyy-mm-dd` (WWFF). `0000-00-00` and anything
  /// malformed give null.
  static DateTime? _date(String? text) {
    if (text == null) return null;
    final m =
        RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(text) ??
        RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(text);
    if (m == null) return null;
    final isDmy = text.contains('/');
    final y = int.parse(isDmy ? m[3]! : m[1]!);
    final mo = int.parse(m[2]!);
    final d = int.parse(isDmy ? m[1]! : m[3]!);
    if (y < 1900 || mo < 1 || mo > 12 || d < 1) return null;
    final dt = DateTime.utc(y, mo, d);
    return dt.month == mo && dt.day == d ? dt : null;
  }

  static DateTime? _sotaTitleDate(String title) {
    final m = RegExp(r'Date=(\d{2}/\d{2}/\d{4})').firstMatch(title);
    return m == null ? null : _date(m[1]);
  }
}
