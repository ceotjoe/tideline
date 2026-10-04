import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tideline/l10n/generated/app_localizations.dart';
import 'package:tideline/src/design/theme.dart';
import 'package:tideline/src/widgets/callsign_text.dart';
import 'package:tideline/src/widgets/status_chip.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';

/// UTC time as HH:MM. QSO times are UTC; this formatting is presentation.
String utcClock(UtcDateTime t) =>
    '${t.value.hour.toString().padLeft(2, '0')}:'
    '${t.value.minute.toString().padLeft(2, '0')}';

enum _Choice { open, copy }

/// One QSO in the log list.
class QsoTile extends StatelessWidget {
  /// Creates the tile.
  const new({required this.item, this.onTap, this.selected = false, super.key});

  /// The QSO and its status.
  final LoggedQso item;

  /// Opens the QSO.
  final VoidCallback? onTap;

  /// Highlighted (shown in the detail pane).
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final q = item.qso;
    final freq = q.freqHz == null
        ? null
        : '${Frequency.toAdifMhz(q.freqHz!)} ${l10n.unitMhz}';
    final details = [
      '${utcClock(q.timeOn)} ${l10n.unitUtc}',
      q.band.name,
      q.mode.label,
      ?freq,
    ].join(' · ');
    final chip = SyncStatusChip(state: item.status?.state);
    // Narrow panes (or large text) cannot fit the chip beside the text, and
    // ListTile fails outright when the trailing widget takes the whole
    // width; there the chip goes under the details.
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < _sideBySideMinWidth;
        final tile = ListTile(
          selected: selected,
          selectedTileColor: context.colors.surfaceVariant,
          onTap: onTap,
          title: _title(context, q),
          subtitle: stacked
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(details),
                    SizedBox(height: context.metrics.xs),
                    chip,
                  ],
                )
              : Text(details),
          trailing: stacked ? null : chip,
        );
        // A right click (or a long press of a trackpad) offers the same two
        // things a desktop list usually does.
        return GestureDetector(
          behavior: HitTestBehavior.deferToChild,
          // A pointer shortcut only: screen readers use the tile's own tap.
          excludeFromSemantics: true,
          onSecondaryTapUp: (d) => _showMenu(context, d.globalPosition),
          child: tile,
        );
      },
    );
  }

  Future<void> _showMenu(BuildContext context, Offset position) async {
    final l10n = AppLocalizations.of(context);
    final call = item.qso.call.value;
    final overlay =
        Overlay.of(context).context.findRenderObject()! as RenderBox;
    final choice = await showMenu<_Choice>(
      context: context,
      position: RelativeRect.fromRect(
        position & const Size(1, 1),
        Offset.zero & overlay.size,
      ),
      items: [
        if (onTap != null)
          PopupMenuItem(value: _Choice.open, child: Text(l10n.actionOpenQso)),
        PopupMenuItem(
          value: _Choice.copy,
          child: Text(l10n.actionCopyCallsign),
        ),
      ],
    );
    switch (choice) {
      case _Choice.open:
        onTap?.call();
      case _Choice.copy:
        await Clipboard.setData(ClipboardData(text: call));
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(l10n.callsignCopied(call))));
        }
      case null:
        break;
    }
  }

  /// Below this width the sync chip moves under the details.
  static const double _sideBySideMinWidth = 320;

  Widget _title(BuildContext context, Qso q) => Row(
    children: [
      Flexible(child: CallsignText(q.call.value)),
      if (q.field('NAME') case final name?) ...[
        SizedBox(width: context.metrics.sm),
        Flexible(
          child: Text(
            name,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    ],
  );
}
