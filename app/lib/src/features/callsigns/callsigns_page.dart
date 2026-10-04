import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tideline/l10n/generated/app_localizations.dart';
import 'package:tideline/src/design/theme.dart';
import 'package:tideline/src/features/callsigns/callsign_context.dart';
import 'package:tideline/src/features/callsigns/callsign_note_dialog.dart';
import 'package:tideline/src/features/callsigns/callsign_providers.dart';
import 'package:tideline/src/widgets/callsign_text.dart';

/// The offline callsign directory: search the stations known from the QSO
/// history, and read or write the note about one.
class CallsignsPage extends ConsumerStatefulWidget {
  /// Creates the page.
  const new({super.key});

  @override
  ConsumerState<CallsignsPage> createState() => _CallsignsPageState();
}

class _CallsignsPageState extends ConsumerState<CallsignsPage> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final metrics = context.metrics;
    final results = ref.watch(callsignSearchProvider(_query.text.trim()));
    final withNote = ref.watch(callsignNoteCallsProvider).value ?? const {};
    final date = DateFormat.yMMMd(l10n.localeName);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.callsignDirectoryTitle)),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(metrics.md),
            child: TextField(
              controller: _query,
              textInputAction: TextInputAction.search,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: l10n.callsignSearch,
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(
            child: switch (results) {
              AsyncData(:final value) when value.isEmpty => Padding(
                padding: EdgeInsets.all(metrics.md),
                child: Text(l10n.callsignEmpty),
              ),
              AsyncData(:final value) => ListView.builder(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                itemCount: value.length,
                itemBuilder: (context, i) {
                  final info = value[i];
                  final lastWorked = date.format(
                    DateTime.fromMillisecondsSinceEpoch(
                      info.lastTime,
                      isUtc: true,
                    ),
                  );
                  final details = callsignDetails(info);
                  return ListTile(
                    title: CallsignText(info.call),
                    subtitle: Text(
                      [
                        if (details.isNotEmpty) details,
                        if (info.dxcc != null &&
                            info.cqz != null &&
                            info.ituz != null)
                          l10n.callsignZones(
                            '${info.dxcc}',
                            '${info.cqz}',
                            '${info.ituz}',
                          ),
                        l10n.callsignLastWorked(lastWorked),
                      ].join('\n'),
                    ),
                    isThreeLine: true,
                    trailing: withNote.contains(info.call)
                        ? Semantics(
                            label: l10n.callsignHasNote,
                            child: const Icon(Icons.sticky_note_2),
                          )
                        : const Icon(Icons.sticky_note_2_outlined),
                    onTap: () =>
                        showCallsignNoteDialog(context, ref, info.call),
                  );
                },
              ),
              _ => const Center(child: CircularProgressIndicator()),
            },
          ),
        ],
      ),
    );
  }
}
