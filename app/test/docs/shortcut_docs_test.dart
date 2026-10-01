import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tideline/l10n/generated/app_localizations.dart';
import 'package:tideline/src/commands/command.dart';
import 'package:tideline/src/commands/command_registry.dart';
import 'package:tideline/src/commands/shortcuts_overlay.dart';

const _marker = '<!-- generated: shortcut table -->';

/// Renders the manual's shortcut table from the command registry.
String renderTable(AppLocalizations l10n) {
  final registry = CommandRegistry(tidelineCommands);
  String scope(CommandScope s) => switch (s) {
    CommandScope.global => l10n.shortcutScopeGlobal,
    CommandScope.logging => l10n.shortcutScopeLogging,
    CommandScope.contest => l10n.shortcutScopeContest,
  };
  String keys(TidelineCommand c, ShortcutPlatform p) {
    final chords = registry.bindingsOf(c);
    if (chords.isEmpty) return l10n.shortcutsUnbound;
    return chords
        .map((k) => '`${describeChord(k, p, l10n)}`')
        .join(' ${l10n.shortcutsOr} ');
  }

  final out = StringBuffer()
    ..writeln(_marker)
    ..writeln(
      '| ${l10n.shortcutsTitle} | | macOS / iPadOS | Windows / Android |',
    )
    ..writeln('|---|---|---|---|');
  for (final c in registry.commands) {
    out.writeln(
      '| ${c.label(l10n)} | ${scope(c.scope)} | '
      '${keys(c, ShortcutPlatform.apple)} | '
      '${keys(c, ShortcutPlatform.other)} |',
    );
  }
  return out.toString();
}

void main() {
  for (final locale in ['en', 'de']) {
    test('manual ($locale) lists the current shortcuts', () {
      final l10n = lookupAppLocalizations(Locale(locale));
      final file = File('../docs/manual/$locale/keyboard-shortcuts.md');
      final content = file.readAsStringSync();
      final head = content.contains(_marker)
          ? content.substring(0, content.indexOf(_marker))
          : '$content\n';
      final expected = '$head${renderTable(l10n)}';
      if (Platform.environment['UPDATE_DOCS'] == '1') {
        file.writeAsStringSync(expected);
      }
      expect(
        file.readAsStringSync(),
        expected,
        reason: 'Run: UPDATE_DOCS=1 flutter test test/docs',
      );
    });
  }

  test('default bindings have no conflicts', () {
    expect(CommandRegistry(tidelineCommands).conflicts(), isEmpty);
  });
}
