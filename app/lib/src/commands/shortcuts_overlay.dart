import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tideline/l10n/generated/app_localizations.dart';
import 'package:tideline/src/commands/command.dart';
import 'package:tideline/src/commands/command_registry.dart';
import 'package:tideline/src/design/theme.dart';

/// Human-readable text for [chord] on [platform], e.g. "⌘⇧S" or
/// "Ctrl+Shift+S".
String describeChord(
  KeyChord chord,
  ShortcutPlatform platform,
  AppLocalizations l10n,
) {
  final key = switch (chord.key) {
    LogicalKeyboardKey.enter => l10n.keyEnter,
    LogicalKeyboardKey.escape => l10n.keyEscape,
    LogicalKeyboardKey.space => l10n.keySpace,
    LogicalKeyboardKey.tab => l10n.keyTab,
    LogicalKeyboardKey.pageUp => l10n.keyPageUp,
    LogicalKeyboardKey.pageDown => l10n.keyPageDown,
    LogicalKeyboardKey.arrowLeft => '←',
    LogicalKeyboardKey.arrowRight => '→',
    LogicalKeyboardKey.arrowUp => '↑',
    LogicalKeyboardKey.arrowDown => '↓',
    final k => k.keyLabel.toUpperCase(),
  };
  if (platform == ShortcutPlatform.apple) {
    return [
      if (chord.alt) '⌥',
      if (chord.shift) '⇧',
      if (chord.primary) '⌘',
      key,
    ].join();
  }
  return [
    if (chord.primary) l10n.keyControl,
    if (chord.alt) l10n.keyAlt,
    if (chord.shift) l10n.keyShift,
    key,
  ].join('+');
}

/// Shows every command and its current shortcuts, grouped by scope.
Future<void> showShortcutsOverlay(
  BuildContext context,
  CommandRegistry registry,
) => showDialog<void>(
  context: context,
  builder: (context) => _ShortcutsDialog(registry: registry),
);

class _ShortcutsDialog extends StatelessWidget {
  const new({required this.registry});

  final CommandRegistry registry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final platform = ShortcutPlatform.of(Theme.of(context).platform);
    final metrics = context.metrics;

    String scopeTitle(CommandScope scope) => switch (scope) {
      CommandScope.global => l10n.shortcutScopeGlobal,
      CommandScope.logging => l10n.shortcutScopeLogging,
      CommandScope.contest => l10n.shortcutScopeContest,
    };

    return AlertDialog(
      title: Text(l10n.shortcutsTitle),
      content: SizedBox(
        width: 480,
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final scope in CommandScope.values) ...[
              Padding(
                padding: EdgeInsets.only(top: metrics.md, bottom: metrics.xs),
                child: Semantics(
                  header: true,
                  child: Text(
                    scopeTitle(scope),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
              for (final command in registry.commands.where(
                (c) => c.scope == scope,
              ))
                _ShortcutRow(
                  label: command.label(l10n),
                  chords: [
                    for (final chord in registry.bindingsOf(command))
                      describeChord(chord, platform, l10n),
                  ],
                ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          autofocus: true,
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.shortcutsClose),
        ),
      ],
    );
  }
}

class _ShortcutRow extends StatelessWidget {
  const new({required this.label, required this.chords});

  final String label;
  final List<String> chords;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final keys = chords.isEmpty
        ? l10n.shortcutsUnbound
        : chords.join(' ${l10n.shortcutsOr} ');
    return MergeSemantics(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: context.metrics.xs),
        child: Row(
          children: [
            Expanded(child: Text(label)),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.metrics.sm,
                vertical: context.metrics.xs,
              ),
              decoration: BoxDecoration(
                color: colors.surfaceVariant,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: colors.outline),
              ),
              child: Text(keys, style: Theme.of(context).textTheme.labelLarge),
            ),
          ],
        ),
      ),
    );
  }
}
