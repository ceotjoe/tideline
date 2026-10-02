import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tideline/l10n/generated/app_localizations.dart';
import 'package:tideline/src/design/theme.dart';
import 'package:tideline/src/design/tokens/color_tokens.dart';
import 'package:tideline/src/design/tokens/metrics.dart';
import 'package:tideline/src/features/contest/contest_hints.dart';
import 'package:tideline/src/features/contest/contest_labels.dart';
import 'package:tideline/src/widgets/frequency_field.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';

/// The hints under the callsign field: country, dupe, multiplier, main-log
/// history and super check suggestions. Every hint is an icon plus text;
/// the whole block is a live region, so screen readers announce changes.
class ContestHintsView extends ConsumerWidget {
  /// Creates the view. [onPickCall] is called when a suggestion is tapped.
  const new({required this.onPickCall, super.key});

  /// Fills the callsign field with a suggested call.
  final ValueChanged<String> onPickCall;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final metrics = context.metrics;
    final hints = ref.watch(contestHintsProvider);
    if (hints.isEmpty) return SizedBox(height: metrics.minTouchTarget / 2);

    final rows = <Widget>[
      if (hints.dxcc case final match?)
        _Hint(
          icon: Icons.public,
          text: l10n.dxccSummary(
            match.entity.name,
            match.continent,
            match.cqz,
            match.ituz,
          ),
        ),
      ..._statusHints(context, hints),
      if (hints.worked case final worked?
          when worked != WorkedSlotStatus.newCall)
        _Hint(
          icon: Icons.menu_book_outlined,
          text: switch (worked) {
            WorkedSlotStatus.newCall => '',
            WorkedSlotStatus.newBand => l10n.contestHintLogNewBand,
            WorkedSlotStatus.newMode => l10n.contestHintLogNewMode,
            WorkedSlotStatus.newSlot => l10n.contestHintLogNewSlot,
            WorkedSlotStatus.workedBefore => l10n.contestHintLogWorked,
          },
        ),
      if (hints.inScp)
        _Hint(icon: Icons.verified_outlined, text: l10n.contestHintInScp),
      if (hints.scpMatches.isNotEmpty)
        _Suggestions(
          label: l10n.contestHintScpMatches,
          calls: hints.scpMatches,
          onPick: onPickCall,
        ),
      if (hints.nPlusOne.isNotEmpty)
        _Suggestions(
          label: l10n.contestHintNPlusOne,
          calls: hints.nPlusOne,
          onPick: onPickCall,
        ),
    ];

    return Semantics(
      container: true,
      liveRegion: true,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: metrics.xs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (i, row) in rows.indexed) ...[
              if (i > 0) SizedBox(height: metrics.xs),
              row,
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _statusHints(BuildContext context, ContestHints hints) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final previous = hints.previous;
    String bands() => [
      for (final b in previous?.workedBands ?? const <Band>[])
        bandDisplayName(b),
    ].join(', ');
    String modes() => (previous?.workedModes ?? const <String>[]).join(', ');
    return [
      if (hints.isDupe)
        _Badge(
          icon: Icons.block,
          colors: c.rejected,
          text: l10n.contestHintDupe(bands(), modes()),
        )
      else if (previous != null && previous.previous.isNotEmpty)
        _Hint(
          icon: Icons.history,
          text: l10n.contestHintWorkedElsewhere(bands(), modes()),
        ),
      if (hints.status == QsoScoreStatus.outOfContest)
        _Hint(
          icon: Icons.do_not_disturb_on_outlined,
          text: l10n.contestHintOutOfContest,
        ),
      if (hints.multipliers.isNotEmpty)
        _Badge(
          icon: Icons.stars,
          colors: c.synced,
          text: l10n.contestHintNewMultiplier(
            [
              for (final m in hints.multipliers)
                '${multiplierLabel(l10n, m.multiplierId)} ${m.value}',
            ].join(', '),
          ),
        ),
    ];
  }
}

class _Hint extends StatelessWidget {
  const new({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ExcludeSemantics(
        child: Icon(icon, size: 18, color: context.colors.textSecondary),
      ),
      SizedBox(width: context.metrics.sm),
      Expanded(
        child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
      ),
    ],
  );
}

/// A highlighted hint (dupe, new multiplier): tinted fill, icon and text.
class _Badge extends StatelessWidget {
  const new({required this.icon, required this.colors, required this.text});

  final IconData icon;
  final StatusColors colors;
  final String text;

  @override
  Widget build(BuildContext context) {
    final metrics = context.metrics;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: metrics.sm,
        vertical: metrics.xs,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: const BorderRadius.all(TidelineMetrics.radiusSm),
        border: Border.all(color: colors.foreground.withValues(alpha: .4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(
            child: Icon(icon, size: 20, color: colors.foreground),
          ),
          SizedBox(width: metrics.sm),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.labelLarge
                  ?.copyWith(color: colors.foreground),
            ),
          ),
        ],
      ),
    );
  }
}

class _Suggestions extends StatelessWidget {
  const new({required this.label, required this.calls, required this.onPick});

  final String label;
  final List<String> calls;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    final metrics = context.metrics;
    return Wrap(
      spacing: metrics.sm,
      runSpacing: metrics.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        for (final call in calls)
          _CallChip(call: call, onTap: () => onPick(call)),
      ],
    );
  }
}

class _CallChip extends StatelessWidget {
  const new({required this.call, required this.onTap});

  final String call;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return Semantics(
      button: true,
      label: l10n.contestUseCall(call.split('').join(' ')),
      excludeSemantics: true,
      child: Material(
        color: c.surfaceVariant,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(TidelineMetrics.radiusSm),
          side: BorderSide(color: c.outline),
        ),
        child: InkWell(
          borderRadius: const BorderRadius.all(TidelineMetrics.radiusSm),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: context.metrics.minTouchTarget,
              minHeight: context.metrics.minTouchTarget,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: context.metrics.sm),
              child: Center(
                widthFactor: 1,
                child: Text(
                  call,
                  style: TidelineType.callsign.copyWith(
                    fontSize: 16,
                    color: c.text,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
