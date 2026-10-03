import 'package:flutter/material.dart';
import 'package:tideline/src/design/theme.dart';
import 'package:tideline/src/design/tokens/metrics.dart';

/// An error message with an icon, announced to screen readers when it
/// appears. Colour is never the only signal: the icon and the text carry it.
class ErrorBox extends StatelessWidget {
  /// Creates the box.
  const new(this.message, {super.key});

  /// The localised message.
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        padding: EdgeInsets.all(context.metrics.sm),
        decoration: BoxDecoration(
          color: colors.rejected.background,
          borderRadius: const BorderRadius.all(TidelineMetrics.radiusSm),
          border: Border.all(
            color: colors.rejected.foreground.withValues(alpha: .4),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: Icon(
                Icons.error_outline,
                size: 20,
                color: colors.rejected.foreground,
              ),
            ),
            SizedBox(width: context.metrics.sm),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: colors.rejected.foreground),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
