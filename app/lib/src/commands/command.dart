import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:tideline/l10n/generated/app_localizations.dart';

/// Where a command is available. See docs/adr/0011-command-registry.md.
enum CommandScope {
  /// On every screen.
  global,

  /// On logging screens.
  logging,

  /// In contest mode.
  contest,
}

/// Whether shortcuts use ⌘ (Apple platforms) or Ctrl (everything else).
enum ShortcutPlatform {
  /// iOS, iPadOS and macOS: the primary modifier is ⌘.
  apple,

  /// Android, Windows, Linux: the primary modifier is Ctrl.
  other;

  /// The family of [platform].
  factory of(TargetPlatform platform) => switch (platform) {
    TargetPlatform.iOS || TargetPlatform.macOS => apple,
    _ => other,
  };
}

/// A platform-neutral key combination.
///
/// [primary] means ⌘ on Apple platforms and Ctrl elsewhere, so one default
/// works everywhere.
@immutable
class KeyChord {
  /// Creates a chord.
  const new(
    this.key, {
    this.primary = false,
    this.shift = false,
    this.alt = false,
  });

  /// Parses the format produced by [serialize]; null if malformed.
  static KeyChord? parse(String value) {
    final parts = value.split('+');
    final keyId = int.tryParse(parts.last);
    if (keyId == null) return null;
    final key = LogicalKeyboardKey.findKeyByKeyId(keyId);
    if (key == null) return null;
    final mods = parts.sublist(0, parts.length - 1).toSet();
    if (!mods.every({'primary', 'shift', 'alt'}.contains)) return null;
    return KeyChord(
      key,
      primary: mods.contains('primary'),
      shift: mods.contains('shift'),
      alt: mods.contains('alt'),
    );
  }

  /// The non-modifier key.
  final LogicalKeyboardKey key;

  /// ⌘ on Apple platforms, Ctrl elsewhere.
  final bool primary;

  /// Shift.
  final bool shift;

  /// Alt / Option.
  final bool alt;

  /// Stable string form for storage, e.g. `primary+shift+110`.
  String serialize() => [
    if (primary) 'primary',
    if (shift) 'shift',
    if (alt) 'alt',
    '${key.keyId}',
  ].join('+');

  /// The Flutter activator for [platform].
  SingleActivator toActivator(ShortcutPlatform platform) => SingleActivator(
    key,
    control: primary && platform == ShortcutPlatform.other,
    meta: primary && platform == ShortcutPlatform.apple,
    shift: shift,
    alt: alt,
  );

  @override
  bool operator ==(Object other) =>
      other is KeyChord &&
      other.key == key &&
      other.primary == primary &&
      other.shift == shift &&
      other.alt == alt;

  @override
  int get hashCode => Object.hash(key, primary, shift, alt);
}

/// A user command that can be triggered by keyboard, menu or button.
@immutable
class TidelineCommand {
  /// Declares a command.
  const new({
    required this.id,
    required this.scope,
    required this.label,
    this.defaults = const [],
    this.fallback = false,
  });

  /// Stable identifier, used for stored overrides. Never rename.
  final String id;

  /// Where the command is available.
  final CommandScope scope;

  /// Localised, human-readable name.
  final String Function(AppLocalizations l10n) label;

  /// Default key bindings.
  final List<KeyChord> defaults;

  /// Whether this command only runs when no other command bound to the same
  /// chord has a handler on the current screen. Escape clears the entry on the
  /// log screen and goes back everywhere else, without that being a conflict.
  final bool fallback;
}

/// Intent dispatched when a command's shortcut is pressed.
class CommandIntent extends Intent {
  /// Creates an intent for the command with [commandId]. [alternatives] are
  /// commands of other scopes bound to the same chord (Enter logs a QSO on
  /// the log screen and in contest mode).
  const new(this.commandId, {this.alternatives = const []});

  /// The command to run.
  final String commandId;

  /// Further commands on the same chord; the first one that has a handler
  /// in the current part of the app runs.
  final List<String> alternatives;

  /// [commandId] followed by [alternatives].
  Iterable<String> get candidates sync* {
    yield commandId;
    yield* alternatives;
  }
}
