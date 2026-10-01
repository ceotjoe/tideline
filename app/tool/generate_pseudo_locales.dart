// Generates the en_XA pseudo-locale ARB file from the English template:
// accented and ~40 % longer, to catch truncation and hard-coded strings
// (anything not accented on screen was not localised).
//
// Right-to-left layouts are tested by combining en_XA with a forced RTL
// text direction (gen-l10n would require a real Arabic base locale for an
// ar_XB pseudo-locale). Pseudo-locales are only offered in debug builds
// and tests.
// Run: dart run tool/generate_pseudo_locales.dart (from app/).

import 'dart:convert';
import 'dart:io';

const _accents = {
  'a': 'á',
  'b': 'ƀ',
  'c': 'ç',
  'd': 'ð',
  'e': 'é',
  'f': 'ƒ',
  'g': 'ĝ',
  'h': 'ĥ',
  'i': 'î',
  'j': 'ĵ',
  'k': 'ķ',
  'l': 'ļ',
  'm': 'ɱ',
  'n': 'ñ',
  'o': 'ö',
  'p': 'þ',
  'q': 'ǫ',
  'r': 'ŕ',
  's': 'š',
  't': 'ţ',
  'u': 'û',
  'v': 'ṽ',
  'w': 'ŵ',
  'x': 'ẋ',
  'y': 'ý',
  'z': 'ž',
  'A': 'Å',
  'B': 'Ɓ',
  'C': 'Ç',
  'D': 'Ð',
  'E': 'É',
  'F': 'Ƒ',
  'G': 'Ĝ',
  'H': 'Ĥ',
  'I': 'Î',
  'J': 'Ĵ',
  'K': 'Ķ',
  'L': 'Ļ',
  'M': 'Ṁ',
  'N': 'Ñ',
  'O': 'Ö',
  'P': 'Þ',
  'Q': 'Ǫ',
  'R': 'Ŕ',
  'S': 'Š',
  'T': 'Ţ',
  'U': 'Û',
  'V': 'Ṽ',
  'W': 'Ŵ',
  'X': 'Ẋ',
  'Y': 'Ý',
  'Z': 'Ž',
};

Future<void> main() async {
  final dir = Directory('lib/l10n/arb');
  final template = File('${dir.path}/app_en.arb');
  final source =
      jsonDecode(await template.readAsString()) as Map<String, dynamic>;

  String accented(String text) {
    final body = text.split('').map((c) => _accents[c] ?? c).join();
    final pad = '·' * ((text.length * 0.4).ceil());
    return '[$body$pad]';
  }

  await _write(dir, 'en_XA', source, accented);
}

Future<void> _write(
  Directory dir,
  String locale,
  Map<String, dynamic> source,
  String Function(String) transformLiteral,
) async {
  final out = <String, Object?>{'@@locale': locale};
  for (final entry in source.entries) {
    if (entry.key.startsWith('@')) continue;
    out[entry.key] = _transformMessage(entry.value as String, transformLiteral);
  }
  const encoder = JsonEncoder.withIndent('  ');
  await File('${dir.path}/app_$locale.arb')
      .writeAsString('${encoder.convert(out)}\n');
}

/// Applies [literal] to the literal text of an ICU message, leaving
/// placeholders and plural/select syntax untouched.
String _transformMessage(String message, String Function(String) literal) {
  final out = StringBuffer();
  final run = StringBuffer();
  void flush() {
    if (run.isNotEmpty) {
      out.write(literal(run.toString()));
      run.clear();
    }
  }

  var i = 0;
  while (i < message.length) {
    if (message[i] != '{') {
      run.write(message[i]);
      i++;
      continue;
    }
    flush();
    final end = _matchingBrace(message, i);
    final inner = message.substring(i + 1, end);
    final firstComma = inner.indexOf(',');
    if (firstComma < 0) {
      out.write('{$inner}'); // simple placeholder
    } else {
      final secondComma = inner.indexOf(',', firstComma + 1);
      out
        ..write('{')
        ..write(inner.substring(0, secondComma + 1))
        ..write(_transformBranches(inner.substring(secondComma + 1), literal))
        ..write('}');
    }
    i = end + 1;
  }
  flush();
  return out.toString();
}

String _transformBranches(String branches, String Function(String) literal) {
  final out = StringBuffer();
  var i = 0;
  while (i < branches.length) {
    final open = branches.indexOf('{', i);
    if (open < 0) {
      out.write(branches.substring(i));
      break;
    }
    final end = _matchingBrace(branches, open);
    out
      ..write(branches.substring(i, open + 1))
      ..write(_transformMessage(branches.substring(open + 1, end), literal))
      ..write('}');
    i = end + 1;
  }
  return out.toString();
}

int _matchingBrace(String s, int open) {
  var depth = 0;
  for (var i = open; i < s.length; i++) {
    if (s[i] == '{') depth++;
    if (s[i] == '}' && --depth == 0) return i;
  }
  throw FormatException('Unbalanced braces', s, open);
}
