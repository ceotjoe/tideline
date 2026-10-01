import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Named arguments and constructors that take user-visible text.
final _textSinks = RegExp(
  r'''(?:\b(?:Text|SelectableText|Tooltip|SnackBar|Semantics)\s*\(\s*|'''
  r'''\b(?:label|labelText|hintText|helperText|errorText|tooltip|title|'''
  r'''message|semanticsLabel|semanticLabel|subtitle|content)\s*:\s*'''
  r'''(?:Text\s*\(\s*)?)(['"])((?:(?!\1).)*[A-Za-z]{2,}(?:(?!\1).)*)\1''',
);

/// Files whose literals are deliberately not translated.
const _allowedFiles = {
  // Language endonyms are never translated.
  'lib/src/settings/language_names.dart',
};

void main() {
  test('no hard-coded user-facing strings in lib/src', () {
    final offenders = <String>[];
    final files = Directory('lib/src')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));
    for (final file in files) {
      final path = file.path.replaceAll(r'\', '/');
      if (_allowedFiles.contains(path)) continue;
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.trimLeft().startsWith('//')) continue;
        if (line.contains('// l10n-ignore')) continue;
        for (final m in _textSinks.allMatches(line)) {
          offenders.add('$path:${i + 1}: ${m.group(0)}');
        }
      }
    }
    expect(
      offenders,
      isEmpty,
      reason:
          'Move these strings to lib/l10n/arb/app_en.arb (and app_de.arb):\n'
          '${offenders.join('\n')}',
    );
  });

  test('the scanner catches hard-coded strings', () {
    expect(_textSinks.hasMatch("Text('Hello world')"), isTrue);
    expect(_textSinks.hasMatch('tooltip: "Sync now"'), isTrue);
    expect(_textSinks.hasMatch("title: Text('Settings')"), isTrue);
    expect(_textSinks.hasMatch('Text(l10n.navLog)'), isFalse);
    expect(_textSinks.hasMatch("Text('')"), isFalse);
  });

  test('every language has every key with matching placeholders', () {
    final dir = Directory('lib/l10n/arb');
    Map<String, String> load(String name) {
      final json = jsonDecode(
        File('${dir.path}/$name').readAsStringSync(),
      ) as Map<String, dynamic>;
      return {
        for (final MapEntry(:key, :value) in json.entries)
          if (!key.startsWith('@')) key: value as String,
      };
    }

    Set<String> placeholders(String message) => {
      for (final m in RegExp(r'\{(\w+)[,}]').allMatches(message)) m.group(1)!,
    };

    final template = load('app_en.arb');
    for (final file in dir.listSync().whereType<File>()) {
      final name = file.uri.pathSegments.last;
      if (name == 'app_en.arb') continue;
      final translation = load(name);
      for (final MapEntry(:key, :value) in template.entries) {
        expect(translation, contains(key), reason: '$name is missing $key');
        expect(
          placeholders(translation[key]!),
          placeholders(value),
          reason: '$name: placeholders of $key differ',
        );
      }
    }
  });
}
