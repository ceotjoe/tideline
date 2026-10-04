import 'package:flutter/material.dart';
import 'package:tideline/src/design/theme.dart';

/// A section title inside a settings page.
class SettingsSectionHeader extends StatelessWidget {
  /// Creates a header showing [text].
  const new(this.text, {super.key});

  /// The title.
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsetsDirectional.fromSTEB(
      context.metrics.md,
      context.metrics.lg,
      context.metrics.md,
      context.metrics.xs,
    ),
    child: Semantics(
      header: true,
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    ),
  );
}

/// A labelled group of radio options.
class SettingsRadioGroup<T> extends StatelessWidget {
  /// Creates a group of [options] with [value] selected.
  const new({
    required this.title,
    required this.value,
    required this.onChanged,
    required this.options,
    this.showTitle = true,
    super.key,
  });

  /// The group's label.
  final String title;

  /// Whether [title] is shown (it is always the semantics label).
  final bool showTitle;

  /// The selected option.
  final T value;

  /// Called with the newly chosen option.
  final ValueChanged<T> onChanged;

  /// The options and their labels.
  final Map<T, String> options;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (showTitle)
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            context.metrics.md,
            context.metrics.sm,
            context.metrics.md,
            0,
          ),
          child: Semantics(
            header: true,
            child: Text(
              title,
              style: Theme.of(context).textTheme.labelLarge
                  ?.copyWith(color: context.colors.textSecondary),
            ),
          ),
        ),
      RadioGroup<T>(
        groupValue: value,
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
        child: Column(
          children: [
            for (final MapEntry(key: option, value: label) in options.entries)
              RadioListTile<T>(value: option, title: Text(label)),
          ],
        ),
      ),
    ],
  );
}
