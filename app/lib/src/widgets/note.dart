import 'package:flutter/material.dart';
import 'package:tideline/src/design/theme.dart';

/// How a [Note] reads: good news, a hint, or something to act on.
enum NoteKind {
  /// Everything is fine.
  good,

  /// Information.
  info,

  /// Something the user should know or do.
  warning,
}

/// A short message with an icon. The icon and the text carry the meaning;
/// colour only supports them.
class Note extends StatelessWidget {
  /// Creates a note.
  const new(this.message, {this.kind = NoteKind.info, this.action, super.key});

  /// The message.
  final String message;

  /// How it reads.
  final NoteKind kind;

  /// An optional button under the message.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final status = switch (kind) {
      NoteKind.good => colors.synced,
      NoteKind.info => colors.pending,
      NoteKind.warning => colors.conflict,
    };
    final icon = switch (kind) {
      NoteKind.good => Icons.check_circle_outline,
      NoteKind.info => Icons.info_outline,
      NoteKind.warning => Icons.warning_amber_outlined,
    };
    return Semantics(
      container: true,
      child: Container(
        padding: EdgeInsets.all(context.metrics.sm),
        decoration: BoxDecoration(
          color: status.background,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: Icon(icon, size: 20, color: status.foreground),
            ),
            SizedBox(width: context.metrics.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: status.foreground),
                  ),
                  if (action != null) ...[
                    SizedBox(height: context.metrics.xs),
                    action!,
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
