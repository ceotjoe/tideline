import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show FutureProviderFamily;
import 'package:intl/intl.dart';
import 'package:tideline/l10n/generated/app_localizations.dart';
import 'package:tideline/src/design/theme.dart';
import 'package:tideline/src/services/app_services.dart';
import 'package:tideline/src/widgets/frequency_field.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';

/// What the worked-before index says about a contact that is about to be
/// logged.
@immutable
class WorkedInfo {
  /// Creates the answer.
  const new(this.status, this.summary);

  /// How the contact relates to what was worked: new call, band, mode, slot
  /// or worked before.
  final WorkedSlotStatus status;

  /// Everything known about the call (any variant of its home call).
  final WorkedSummary summary;
}

/// Asks the index about [call] on [band] in [mode].
///
/// The one lookup behind the worked-before hint of the normal log and of
/// contest mode, so both always agree. Returns null for a call that is not
/// valid (yet). Variants of one home call (`DL1ABC/P`) count as the same
/// station, as for the DXCC hint.
Future<WorkedInfo?> lookupWorkedInfo(
  WorkedBeforeRepository index,
  String accountId, {
  required String call,
  required Band band,
  required Mode mode,
}) async {
  if (Callsign.tryParse(call) == null) return null;
  final summary = await index.lookupBase(accountId, call);
  return WorkedInfo(summary.slotStatus(band.name, mode.mode), summary);
}

/// The question put to [workedInfoProvider].
@immutable
class WorkedQuery {
  /// Creates the query.
  const new({required this.call, required this.band, required this.mode});

  /// Callsign as typed.
  final String call;

  /// Band of the contact.
  final Band band;

  /// Mode of the contact.
  final Mode mode;

  @override
  bool operator ==(Object other) =>
      other is WorkedQuery &&
      other.call == call &&
      other.band == band &&
      other.mode.mode == mode.mode;

  @override
  int get hashCode => Object.hash(call, band, mode.mode);
}

/// The index answer for a contact in the normal log. Refreshes after every
/// change of the log, so it is current right after a QSO is saved.
final FutureProviderFamily<WorkedInfo?, WorkedQuery> workedInfoProvider =
    FutureProvider.autoDispose.family<WorkedInfo?, WorkedQuery>((
      ref,
      query,
    ) async {
      final account = ref.watch(activeAccountProvider);
      if (account == null) return null;
      ref.watch(logProvider);
      return await lookupWorkedInfo(
        ref.watch(workedBeforeRepositoryProvider),
        account.id,
        call: query.call,
        band: query.band,
        mode: query.mode,
      );
    });

/// The icon of a worked-before status. Always shown with its text.
IconData workedStatusIcon(WorkedSlotStatus status) => switch (status) {
  WorkedSlotStatus.newCall => Icons.fiber_new_outlined,
  WorkedSlotStatus.newBand => Icons.add_chart,
  WorkedSlotStatus.newMode => Icons.graphic_eq,
  WorkedSlotStatus.newSlot => Icons.grid_view_outlined,
  WorkedSlotStatus.workedBefore => Icons.menu_book_outlined,
};

/// The localised sentence for [info]: the status, and for a call that was
/// worked before, the date of the first contact and the bands.
String workedHintText(AppLocalizations l10n, WorkedInfo info) {
  final label = switch (info.status) {
    WorkedSlotStatus.newCall => l10n.workedHintNewCall,
    WorkedSlotStatus.newBand => l10n.workedHintNewBand,
    WorkedSlotStatus.newMode => l10n.workedHintNewMode,
    WorkedSlotStatus.newSlot => l10n.workedHintNewSlot,
    WorkedSlotStatus.workedBefore => l10n.workedHintWorked,
  };
  final first = info.summary.firstTime;
  if (info.status == WorkedSlotStatus.newCall || first == null) return label;
  final bands = [for (final name in info.summary.bands) ?Band.tryParse(name)]
    ..sort((a, b) => a.lowerHz.compareTo(b.lowerHz));
  // A date in UTC, like every QSO time; only the formatting is local.
  final date = DateFormat.yMMMd(l10n.localeName)
      .format(DateTime.fromMillisecondsSinceEpoch(first, isUtc: true));
  final names = bands.map(bandDisplayName).join(', ');
  return '$label · ${l10n.workedHintDetails(date, names)}';
}

/// The worked-before line under the callsign field of the normal log: an
/// icon plus text, announced to screen readers when it changes.
class WorkedHintLine extends ConsumerWidget {
  /// Creates the line for the entry [call] on [band] in [mode].
  const new({
    required this.call,
    required this.band,
    required this.mode,
    super.key,
  });

  /// Callsign as typed.
  final String call;

  /// Selected band, if any.
  final Band? band;

  /// Selected mode, if any.
  final Mode? mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final band = this.band;
    final mode = this.mode;
    if (band == null || mode == null || call.trim().length < 3) {
      return const SizedBox.shrink();
    }
    final info = ref
        .watch(
          workedInfoProvider(
            WorkedQuery(
              call: call.trim().toUpperCase(),
              band: band,
              mode: mode,
            ),
          ),
        )
        .value;
    if (info == null) return const SizedBox.shrink();
    final text = workedHintText(AppLocalizations.of(context), info);
    return Padding(
      padding: EdgeInsets.only(top: context.metrics.xs),
      child: Semantics(
        liveRegion: true,
        container: true,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: Icon(
                workedStatusIcon(info.status),
                size: 18,
                color: context.colors.textSecondary,
              ),
            ),
            SizedBox(width: context.metrics.sm),
            Expanded(
              child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
            ),
          ],
        ),
      ),
    );
  }
}
