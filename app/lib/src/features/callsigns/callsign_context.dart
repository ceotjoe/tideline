import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tideline/l10n/generated/app_localizations.dart';
import 'package:tideline/src/design/theme.dart';
import 'package:tideline/src/features/callsigns/callsign_note_dialog.dart';
import 'package:tideline/src/features/callsigns/callsign_providers.dart';
import 'package:tideline_data/tideline_data.dart';

/// "Anna · Berlin · JO62": the values worth showing for [info].
String callsignDetails(CallsignInfo info) => [
  ?info.name,
  ?info.qth,
  ?info.gridsquare,
  if (info.name == null && info.qth == null) ?info.country,
].join(' · ');

/// What the history knows about the call being entered, and the user's own
/// note about it. Shows nothing for a station without either. Values are only
/// offered: [onFill] copies them into empty fields, never over typed text.
class CallsignContextLine extends ConsumerWidget {
  /// Creates the line for the entry [call].
  const new({
    required this.call,
    required this.nameEmpty,
    required this.gridEmpty,
    required this.onFill,
    super.key,
  });

  /// The callsign as typed.
  final String call;

  /// Whether the name field is empty (so the name can be filled in).
  final bool nameEmpty;

  /// Whether the locator field is empty.
  final bool gridEmpty;

  /// Copies the known name and locator into the empty fields.
  final void Function(CallsignInfo info) onFill;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typed = call.trim();
    if (typed.length < 3) return const SizedBox.shrink();
    final info = ref.watch(callsignInfoProvider(typed)).value;
    final note = ref.watch(callsignNoteProvider(typed)).value;
    final known = info != null && !info.isBare ? info : null;
    if (known == null && note == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final metrics = context.metrics;
    final text = Theme.of(context).textTheme.bodyMedium;
    final fillable =
        known != null &&
        ((nameEmpty && known.name != null) ||
            (gridEmpty && known.gridsquare != null));

    return Padding(
      padding: EdgeInsets.only(top: metrics.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (known != null)
            Semantics(
              liveRegion: true,
              container: true,
              child: Row(
                children: [
                  ExcludeSemantics(
                    child: Icon(
                      Icons.person_search_outlined,
                      size: 18,
                      color: context.colors.textSecondary,
                    ),
                  ),
                  SizedBox(width: metrics.sm),
                  Expanded(
                    child: Text(
                      l10n.callsignKnown(callsignDetails(known)),
                      style: text,
                    ),
                  ),
                  if (fillable)
                    Semantics(
                      label: l10n.callsignFillInLabel,
                      excludeSemantics: true,
                      button: true,
                      child: TextButton(
                        onPressed: () => onFill(known),
                        child: Text(l10n.callsignFillIn),
                      ),
                    ),
                ],
              ),
            ),
          if (note != null)
            InkWell(
              onTap: () => showCallsignNoteDialog(context, ref, typed),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: metrics.minTouchTarget),
                child: Row(
                  children: [
                    ExcludeSemantics(
                      child: Icon(
                        Icons.sticky_note_2_outlined,
                        size: 18,
                        color: context.colors.textSecondary,
                      ),
                    ),
                    SizedBox(width: metrics.sm),
                    Expanded(
                      child: Text(
                        l10n.callsignNoteLine(note),
                        style: text,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
