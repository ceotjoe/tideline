import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tideline/l10n/generated/app_localizations.dart';
import 'package:tideline/src/features/callsigns/callsign_providers.dart';
import 'package:tideline_data/tideline_data.dart';

/// Opens the note of [call] for editing. Saving an empty text removes it.
Future<void> showCallsignNoteDialog(
  BuildContext context,
  WidgetRef ref,
  String call,
) async {
  final notes = ref.read(callsignNoteRepositoryProvider);
  final key = CallsignNoteRepository.keyOf(call);
  if (key == null) return;
  final current = await notes.find(key);
  if (!context.mounted) return;
  final result = await showDialog<_NoteResult>(
    context: context,
    builder: (context) => _NoteDialog(call: key, initial: current ?? ''),
  );
  switch (result) {
    case _Save(:final text):
      await notes.save(key, text);
    case _Delete():
      await notes.delete(key);
    case null:
      break;
  }
}

sealed class _NoteResult {
  const new();
}

final class _Save extends _NoteResult {
  const new(this.text);

  final String text;
}

final class _Delete extends _NoteResult {
  const new();
}

/// Owns its text controller, so the field is not used after disposal while
/// the dialog fades out.
class _NoteDialog extends StatefulWidget {
  const new({required this.call, required this.initial});

  final String call;
  final String initial;

  @override
  State<_NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<_NoteDialog> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.callsignNoteTitle(widget.call)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.callsignNoteHint,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              autofocus: true,
              minLines: 3,
              maxLines: 8,
              maxLength: CallsignNoteRepository.maxLength,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(labelText: l10n.callsignNoteField),
            ),
          ],
        ),
      ),
      actions: [
        if (widget.initial.isNotEmpty)
          TextButton(
            onPressed: () => Navigator.of(context).pop(const _Delete()),
            child: Text(l10n.callsignNoteDelete),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_Save(_controller.text)),
          child: Text(l10n.actionSave),
        ),
      ],
    );
  }
}
