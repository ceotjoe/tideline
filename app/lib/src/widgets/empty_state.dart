import 'package:flutter/material.dart';
import 'package:tideline/src/design/theme.dart';

/// A calm, centred message for screens without content yet.
class EmptyState extends StatelessWidget {
  /// Creates an empty state with [icon], [title] and [body].
  const new({
    required this.icon,
    required this.title,
    required this.body,
    this.action,
    super.key,
  });

  /// Decorative icon (excluded from semantics).
  final IconData icon;

  /// Short headline.
  final String title;

  /// Explanation in plain language.
  final String body;

  /// Optional call to action.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final metrics = context.metrics;
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(metrics.lg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ExcludeSemantics(
                child: Icon(icon, size: 56, color: context.colors.primary),
              ),
              SizedBox(height: metrics.md),
              Semantics(
                header: true,
                child: Text(
                  title,
                  style: textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: metrics.sm),
              Text(
                body,
                style: textTheme.bodyLarge?.copyWith(
                  color: context.colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              if (action != null) ...[SizedBox(height: metrics.lg), action!],
            ],
          ),
        ),
      ),
    );
  }
}
