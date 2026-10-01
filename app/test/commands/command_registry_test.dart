import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tideline/src/commands/command.dart';
import 'package:tideline/src/commands/command_registry.dart';

void main() {
  group('KeyChord', () {
    test('round-trips through its stored form', () {
      const chord = KeyChord(
        LogicalKeyboardKey.keyS,
        primary: true,
        shift: true,
      );
      expect(KeyChord.parse(chord.serialize()), chord);
    });

    test('rejects malformed stored values', () {
      expect(KeyChord.parse(''), isNull);
      expect(KeyChord.parse('primary+nope'), isNull);
      expect(KeyChord.parse('hyper+${LogicalKeyboardKey.keyA.keyId}'), isNull);
    });

    test('primary maps to Cmd on Apple and Ctrl elsewhere', () {
      const chord = KeyChord(LogicalKeyboardKey.keyN, primary: true);
      final apple = chord.toActivator(ShortcutPlatform.apple);
      final other = chord.toActivator(ShortcutPlatform.other);
      expect((apple.meta, apple.control), (true, false));
      expect((other.meta, other.control), (false, true));
    });
  });

  group('CommandRegistry', () {
    test('user overrides replace defaults', () {
      final registry = CommandRegistry(
        tidelineCommands,
        overrides: [
          (
            commandId: CommandIds.logQso,
            chords: const [KeyChord(LogicalKeyboardKey.f5)],
          ),
        ],
      );
      final command = tidelineCommands.firstWhere(
        (c) => c.id == CommandIds.logQso,
      );
      expect(registry.bindingsOf(command), const [
        KeyChord(LogicalKeyboardKey.f5),
      ]);
    });

    test('detects a global chord reused on a screen', () {
      final registry = CommandRegistry(
        tidelineCommands,
        overrides: [
          (
            commandId: CommandIds.newQso,
            chords: const [KeyChord(LogicalKeyboardKey.f1)],
          ),
        ],
      );
      expect(
        registry.conflicts().single.commandIds,
        containsAll([CommandIds.showShortcuts, CommandIds.newQso]),
      );
    });

    test('logging and contest may share chords (separate screens)', () {
      // Enter logs a QSO in both scopes by design once contest mode lands.
      final registry = CommandRegistry([
        TidelineCommand(
          id: 'a',
          scope: CommandScope.logging,
          label: (l) => '',
          defaults: const [KeyChord(LogicalKeyboardKey.enter)],
        ),
        TidelineCommand(
          id: 'b',
          scope: CommandScope.contest,
          label: (l) => '',
          defaults: const [KeyChord(LogicalKeyboardKey.enter)],
        ),
      ]);
      expect(registry.conflicts(), isEmpty);
    });

    test('rejects duplicate command ids', () {
      expect(
        () => CommandRegistry([...tidelineCommands, tidelineCommands.first]),
        throwsArgumentError,
      );
    });
  });
}
