import 'dart:convert';

/// Writes ADIF ADI files.
///
/// Values are written as UTF-8 and lengths count bytes, which is what
/// PHP-based loggers such as Wavelog read and write. Field names are upper
/// case; empty values are omitted.
class AdiWriter {
  /// Creates a writer identifying itself as [programId] [programVersion].
  const new({
    required this.programVersion,
    this.programId = 'Tideline',
    this.adifVersion = '3.1.7',
  });

  /// PROGRAMID header field.
  final String programId;

  /// PROGRAMVERSION header field.
  final String programVersion;

  /// ADIF_VER header field.
  final String adifVersion;

  /// The header, with CREATED_TIMESTAMP from [createdUtc].
  String header({required DateTime createdUtc, String? comment}) {
    final ts = createdUtc.toUtc();
    String two(int v) => v.toString().padLeft(2, '0');
    final stamp =
        '${ts.year}${two(ts.month)}${two(ts.day)} '
        '${two(ts.hour)}${two(ts.minute)}${two(ts.second)}';
    final out = StringBuffer()
      ..writeln(comment ?? 'Exported by $programId $programVersion')
      ..writeln(_field('ADIF_VER', adifVersion))
      ..writeln(_field('PROGRAMID', programId))
      ..writeln(_field('PROGRAMVERSION', programVersion))
      ..writeln(_field('CREATED_TIMESTAMP', stamp))
      ..writeln('<EOH>');
    return out.toString();
  }

  /// One record. [fields] maps ADIF names to values.
  String record(Map<String, String> fields) {
    final out = StringBuffer();
    for (final MapEntry(:key, :value) in fields.entries) {
      if (value.isEmpty) continue;
      out
        ..write(_field(key, value))
        ..write(' ');
    }
    out.writeln('<EOR>');
    return out.toString();
  }

  /// A complete document.
  String document(
    Iterable<Map<String, String>> records, {
    required DateTime createdUtc,
  }) {
    final out = StringBuffer(header(createdUtc: createdUtc))..writeln();
    for (final r in records) {
      out.write(record(r));
    }
    return out.toString();
  }

  static String _field(String name, String value) {
    final upper = name.toUpperCase();
    if (!RegExp(r'^[A-Z0-9_]+$').hasMatch(upper)) {
      throw ArgumentError.value(name, 'name', 'not a valid ADIF field name');
    }
    return '<$upper:${utf8.encode(value).length}>$value';
  }
}
