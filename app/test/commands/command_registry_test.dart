import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tideline/l10n/generated/app_localizations.dart';
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

  group('contest commands', () {
    const contestIds = [
      CommandIds.contestLog,
      CommandIds.contestWipe,
      CommandIds.contestEditLast,
      CommandIds.contestFocusCall,
      CommandIds.bandUp,
      CommandIds.bandDown,
      CommandIds.nextMode,
      CommandIds.contestToggleRates,
      CommandIds.contestEnd,
    ];
    final registry = CommandRegistry(tidelineCommands);

    test('every contest command is registered with a binding', () {
      for (final id in [...contestIds, CommandIds.openContest]) {
        final command = tidelineCommands.where((c) => c.id == id).singleOrNull;
        expect(command, isNotNull, reason: '$id is not in the registry');
        expect(
          registry.bindingsOf(command!),
          isNotEmpty,
          reason: '$id has no default binding',
        );
      }
      for (final id in contestIds) {
        expect(
          tidelineCommands.firstWhere((c) => c.id == id).scope,
          CommandScope.contest,
          reason: id,
        );
      }
      expect(
        tidelineCommands
            .firstWhere((c) => c.id == CommandIds.openContest)
            .scope,
        CommandScope.global,
      );
    });

    test('bindings exist for macOS and for other platforms', () {
      for (final platform in ShortcutPlatform.values) {
        final map = registry.shortcutMap(platform);
        for (final id in contestIds) {
          final command = tidelineCommands.firstWhere((c) => c.id == id);
          for (final chord in registry.bindingsOf(command)) {
            final activator = chord.toActivator(platform);
            final intent =
                map.entries
                        .firstWhere(
                          (e) =>
                              (e.key as SingleActivator).trigger ==
                                  activator.trigger &&
                              (e.key as SingleActivator).control ==
                                  activator.control &&
                              (e.key as SingleActivator).meta ==
                                  activator.meta &&
                              (e.key as SingleActivator).shift ==
                                  activator.shift,
                        )
                        .value
                    as CommandIntent;
            expect(intent.candidates, contains(id), reason: '$id on $platform');
          }
        }
      }
    });

    test('labels exist in English and German', () {
      for (final locale in ['en', 'de']) {
        final l10n = lookupAppLocalizations(Locale(locale));
        for (final id in [...contestIds, CommandIds.openContest]) {
          final label = tidelineCommands
              .firstWhere((c) => c.id == id)
              .label(l10n);
          expect(label.trim(), isNotEmpty, reason: '$id ($locale)');
        }
      }
    });

    test('contest commands do not clash with each other or global ones', () {
      expect(registry.conflicts(), isEmpty);
    });

    test('a chord shared with the log screen reaches whichever is active', () {
      final map = registry.shortcutMap(ShortcutPlatform.other);
      final enter =
          map.entries
                  .firstWhere(
                    (e) =>
                        (e.key as SingleActivator).trigger ==
                        LogicalKeyboardKey.enter,
                  )
                  .value
              as CommandIntent;
      expect(
        enter.candidates,
        containsAll([CommandIds.logQso, CommandIds.contestLog]),
      );
    });
  });
}
