import 'package:flutter/material.dart';
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
    return ListTile(
      selected: selected,
      selectedTileColor: context.colors.surfaceVariant,
      onTap: onTap,
      title: Row(
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
      ),
      subtitle: Text(details),
      trailing: SyncStatusChip(state: item.status?.state),
    );
  }
}
