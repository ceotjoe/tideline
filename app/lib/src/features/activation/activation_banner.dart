import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tideline/l10n/generated/app_localizations.dart';
import 'package:tideline/src/design/theme.dart';
import 'package:tideline/src/features/activation/activation_labels.dart';
import 'package:tideline/src/features/activation/activation_providers.dart';
import 'package:tideline_domain/tideline_domain.dart';

/// Asks whether to end the running activation and ends it. Does nothing
/// without one.
Future<void> endActivationFlow(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final activation = ref.read(activeActivationProvider).value;
  if (activation == null) return;
  final repository = ref.read(activationRepositoryProvider);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.activationEndTitle(activation.reference)),
      content: Text(l10n.activationEndBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.actionCancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.activationEnd),
        ),
      ],
    ),
  );
  if (!(confirmed ?? false)) return;
  await repository.end(
    activation.id,
    DateTime.now().toUtc().millisecondsSinceEpoch,
  );
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(l10n.activationEnded)));
}

/// The running activation with its progress toward validity. Shown on the
/// log screen while one runs; empty otherwise.
///
/// The progress is a bar and a sentence: the bar is for a glance, the
/// sentence says the same in words (and is what screen readers get).
class ActivationBanner extends ConsumerWidget {
  /// Creates the banner.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activation = ref.watch(activeActivationProvider).value;
    if (activation == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final metrics = context.metrics;
    final theme = Theme.of(context);
    final progress = ref.watch(activationProgressProvider).value;
    final place = ref
        .watch(
          activationReferenceProvider((
            program: activation.program,
            reference: activation.reference,
          )),
        )
        .value;
    final title = place == null
        ? l10n.activationBannerTitle(
            activation.program.code,
            activation.reference,
          )
        : l10n.activationBannerTitleNamed(
            activation.program.code,
            activation.reference,
            place.name,
          );
    final window = progress == null
        ? null
        : ref.watch(activationRulesProvider(activation.program)).value?.window;
    return Semantics(
      container: true,
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: metrics.md,
          vertical: metrics.sm,
        ),
        color: context.colors.surfaceVariant,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ExcludeSemantics(
                  child: Icon(Icons.terrain, color: context.colors.primary),
                ),
                SizedBox(width: metrics.sm),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton(
                  onPressed: () => endActivationFlow(context, ref),
                  child: Text(l10n.activationEnd),
                ),
              ],
            ),
            if (progress != null) ...[
              SizedBox(height: metrics.xs),
              ExcludeSemantics(
                child: LinearProgressIndicator(
                  value: progress.required == 0
                      ? 0
                      : (progress.counted / progress.required).clamp(0, 1),
                  minHeight: 8,
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                ),
              ),
              SizedBox(height: metrics.xs),
              Row(
                children: [
                  ExcludeSemantics(
                    child: Icon(
                      progress.isValid
                          ? Icons.check_circle_outline
                          : Icons.pending_outlined,
                      size: 18,
                      color: progress.isValid
                          ? context.colors.synced.foreground
                          : context.colors.textSecondary,
                    ),
                  ),
                  SizedBox(width: metrics.xs),
                  Expanded(
                    child: Text(
                      progressText(l10n, progress),
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
              if (window != null)
                Text(
                  window == ActivationWindow.utcDay
                      ? l10n.activationWindowDay
                      : l10n.activationWindowSession,
                  style: theme.textTheme.bodySmall,
                ),
              if (progress.duplicates > 0)
                Text(
                  l10n.activationDuplicates(progress.duplicates),
                  style: theme.textTheme.bodySmall,
                ),
            ],
          ],
        ),
      ),
    );
  }
}
