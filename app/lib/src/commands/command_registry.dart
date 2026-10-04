import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:tideline/src/commands/command.dart';

/// Ids of all commands. Stored in user overrides: never rename.
abstract final class CommandIds {
  static const showShortcuts = 'app.showShortcuts';
  static const goToLog = 'nav.log';
  static const goToSync = 'nav.sync';
  static const goToSettings = 'nav.settings';
  static const goBack = 'nav.back';
  static const syncNow = 'sync.now';
  static const newQso = 'log.new';
  static const logQso = 'log.save';
  static const clearEntry = 'log.clear';
  static const editLastQso = 'log.editLast';
  static const bandUp = 'contest.bandUp';
  static const bandDown = 'contest.bandDown';
  static const nextMode = 'contest.nextMode';
  static const openContest = 'contest.open';
  static const contestLog = 'contest.log';
  static const contestWipe = 'contest.wipe';
  static const contestEditLast = 'contest.editLast';
  static const contestFocusCall = 'contest.focusCall';
  static const contestToggleRates = 'contest.toggleRates';
  static const contestEnd = 'contest.end';
  static const contestExportCabrillo = 'contest.exportCabrillo';
  static const startActivation = 'activation.start';
  static const fastLogEntry = 'log.fle';
  static const endActivation = 'activation.end';
}

/// Every command Tideline knows, with its default shortcuts.
///
/// The shortcut overlay and the manual's shortcut table are generated from
/// this list, so a command added here is automatically discoverable.
final List<TidelineCommand> tidelineCommands = [
  TidelineCommand(
    id: CommandIds.showShortcuts,
    scope: CommandScope.global,
    label: (l) => l.commandShowShortcuts,
    defaults: const [
      KeyChord(LogicalKeyboardKey.slash, primary: true),
      KeyChord(LogicalKeyboardKey.f1),
    ],
  ),
  TidelineCommand(
    id: CommandIds.goToLog,
    scope: CommandScope.global,
    label: (l) => l.commandGoToLog,
    defaults: const [KeyChord(LogicalKeyboardKey.digit1, primary: true)],
  ),
  TidelineCommand(
    id: CommandIds.goToSync,
    scope: CommandScope.global,
    label: (l) => l.commandGoToSync,
    defaults: const [KeyChord(LogicalKeyboardKey.digit2, primary: true)],
  ),
  TidelineCommand(
    id: CommandIds.goToSettings,
    scope: CommandScope.global,
    label: (l) => l.commandGoToSettings,
    defaults: const [KeyChord(LogicalKeyboardKey.comma, primary: true)],
  ),
  TidelineCommand(
    id: CommandIds.goBack,
    scope: CommandScope.global,
    label: (l) => l.commandGoBack,
    fallback: true,
    defaults: const [
      KeyChord(LogicalKeyboardKey.escape),
      KeyChord(LogicalKeyboardKey.arrowLeft, alt: true),
      KeyChord(LogicalKeyboardKey.bracketLeft, primary: true),
    ],
  ),
  TidelineCommand(
    id: CommandIds.syncNow,
    scope: CommandScope.global,
    label: (l) => l.commandSyncNow,
    defaults: const [
      KeyChord(LogicalKeyboardKey.keyS, primary: true, shift: true),
    ],
  ),
  TidelineCommand(
    id: CommandIds.openContest,
    scope: CommandScope.global,
    label: (l) => l.commandOpenContest,
    defaults: const [
      KeyChord(LogicalKeyboardKey.keyC, primary: true, shift: true),
    ],
  ),
  TidelineCommand(
    id: CommandIds.startActivation,
    scope: CommandScope.global,
    label: (l) => l.commandStartActivation,
    defaults: const [
      KeyChord(LogicalKeyboardKey.keyA, primary: true, shift: true),
    ],
  ),
  TidelineCommand(
    id: CommandIds.fastLogEntry,
    scope: CommandScope.global,
    label: (l) => l.commandFastLogEntry,
    defaults: const [
      KeyChord(LogicalKeyboardKey.keyF, primary: true, shift: true),
    ],
  ),
  TidelineCommand(
    id: CommandIds.newQso,
    scope: CommandScope.logging,
    label: (l) => l.commandNewQso,
    defaults: const [KeyChord(LogicalKeyboardKey.keyN, primary: true)],
  ),
  TidelineCommand(
    id: CommandIds.logQso,
    scope: CommandScope.logging,
    label: (l) => l.commandLogQso,
    defaults: const [KeyChord(LogicalKeyboardKey.enter)],
  ),
  TidelineCommand(
    id: CommandIds.clearEntry,
    scope: CommandScope.logging,
    label: (l) => l.commandClearEntry,
    defaults: const [KeyChord(LogicalKeyboardKey.escape)],
  ),
  TidelineCommand(
    id: CommandIds.editLastQso,
    scope: CommandScope.logging,
    label: (l) => l.commandEditLastQso,
    defaults: const [KeyChord(LogicalKeyboardKey.keyE, primary: true)],
  ),
  TidelineCommand(
    id: CommandIds.endActivation,
    scope: CommandScope.logging,
    label: (l) => l.commandEndActivation,
    defaults: const [
      KeyChord(LogicalKeyboardKey.keyE, primary: true, shift: true),
    ],
  ),
  TidelineCommand(
    id: CommandIds.contestLog,
    scope: CommandScope.contest,
    label: (l) => l.commandLogQso,
    defaults: const [KeyChord(LogicalKeyboardKey.enter)],
  ),
  TidelineCommand(
    id: CommandIds.contestWipe,
    scope: CommandScope.contest,
    label: (l) => l.commandWipeEntry,
    defaults: const [KeyChord(LogicalKeyboardKey.escape)],
  ),
  TidelineCommand(
    id: CommandIds.contestEditLast,
    scope: CommandScope.contest,
    label: (l) => l.commandEditLastQso,
    defaults: const [KeyChord(LogicalKeyboardKey.keyE, primary: true)],
  ),
  TidelineCommand(
    id: CommandIds.contestFocusCall,
    scope: CommandScope.contest,
    label: (l) => l.commandFocusCall,
    defaults: const [KeyChord(LogicalKeyboardKey.keyL, primary: true)],
  ),
  TidelineCommand(
    id: CommandIds.bandUp,
    scope: CommandScope.contest,
    label: (l) => l.commandBandUp,
    defaults: const [KeyChord(LogicalKeyboardKey.pageUp)],
  ),
  TidelineCommand(
    id: CommandIds.bandDown,
    scope: CommandScope.contest,
    label: (l) => l.commandBandDown,
    defaults: const [KeyChord(LogicalKeyboardKey.pageDown)],
  ),
  TidelineCommand(
    id: CommandIds.nextMode,
    scope: CommandScope.contest,
    label: (l) => l.commandNextMode,
    defaults: const [KeyChord(LogicalKeyboardKey.keyM, primary: true)],
  ),
  TidelineCommand(
    id: CommandIds.contestToggleRates,
    scope: CommandScope.contest,
    label: (l) => l.commandToggleRates,
    defaults: const [KeyChord(LogicalKeyboardKey.keyR, primary: true)],
  ),
  TidelineCommand(
    id: CommandIds.contestEnd,
    scope: CommandScope.contest,
    label: (l) => l.commandEndContest,
    defaults: const [
      KeyChord(LogicalKeyboardKey.keyE, primary: true, shift: true),
    ],
  ),
  TidelineCommand(
    id: CommandIds.contestExportCabrillo,
    scope: CommandScope.contest,
    label: (l) => l.commandExportCabrillo,
    defaults: const [
      KeyChord(LogicalKeyboardKey.keyX, primary: true, shift: true),
    ],
  ),
];

/// A stored override: `chords` replaces the defaults of `commandId`
/// (empty = unbound).
typedef BindingOverride = ({String commandId, List<KeyChord> chords});

/// Two commands of overlapping scopes share a key chord.
typedef BindingConflict = ({KeyChord chord, List<String> commandIds});

/// Resolves effective bindings from defaults and user overrides.
class CommandRegistry {
  /// Creates a registry for [commands] with user [overrides] applied.
  new(this.commands, {List<BindingOverride> overrides = const []})
    : _overrides = {for (final o in overrides) o.commandId: o.chords} {
    final ids = <String>{};
    for (final c in commands) {
      if (!ids.add(c.id)) {
        throw ArgumentError('Duplicate command id ${c.id}');
      }
    }
  }

  /// All registered commands.
  final List<TidelineCommand> commands;
  final Map<String, List<KeyChord>> _overrides;

  /// Effective chords of [command].
  List<KeyChord> bindingsOf(TidelineCommand command) =>
      _overrides[command.id] ?? command.defaults;

  /// The shortcut map for Flutter's `Shortcuts` widget.
  ///
  /// Commands of different scopes may share a chord. They end up in one
  /// intent, and whichever has a handler on the current screen runs.
  Map<ShortcutActivator, Intent> shortcutMap(ShortcutPlatform platform) {
    final byChord = <KeyChord, List<String>>{};
    // Fallback commands go last, so a screen's own command wins.
    final ordered = [
      ...commands.where((c) => !c.fallback),
      ...commands.where((c) => c.fallback),
    ];
    for (final c in ordered) {
      for (final chord in bindingsOf(c)) {
        (byChord[chord] ??= []).add(c.id);
      }
    }
    return {
      for (final MapEntry(key: chord, value: ids) in byChord.entries)
        chord.toActivator(platform): CommandIntent(
          ids.first,
          alternatives: ids.skip(1).toList(),
        ),
    };
  }

  /// Chords bound to more than one command whose scopes can be active at
  /// the same time (global overlaps with everything; logging and contest
  /// are separate screens).
  List<BindingConflict> conflicts() {
    final byChord = <KeyChord, List<TidelineCommand>>{};
    for (final c in commands) {
      for (final chord in bindingsOf(c)) {
        (byChord[chord] ??= []).add(c);
      }
    }
    final result = <BindingConflict>[];
    for (final MapEntry(key: chord, value: cmds) in byChord.entries) {
      for (var i = 0; i < cmds.length; i++) {
        for (var j = i + 1; j < cmds.length; j++) {
          // A fallback yields to the other command by design.
          if (cmds[i].fallback || cmds[j].fallback) continue;
          final a = cmds[i].scope;
          final b = cmds[j].scope;
          if (a == b || a == CommandScope.global || b == CommandScope.global) {
            result.add((chord: chord, commandIds: [cmds[i].id, cmds[j].id]));
          }
        }
      }
    }
    return result;
  }
}
