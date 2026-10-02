import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tideline/l10n/generated/app_localizations.dart';
import 'package:tideline/src/design/theme.dart';
import 'package:tideline/src/features/contest/contest_providers.dart';
import 'package:tideline/src/routing/routes.dart';

/// "Contest session active: name" with a way back to the contest screen.
/// Shown on the log screen while a session runs; empty otherwise.
class ContestBanner extends ConsumerWidget {
  /// Creates the banner.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(activeContestSessionProvider).value;
    if (session == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final metrics = context.metrics;
    final name =
        ref
            .watch(contestDefinitionsProvider)
            .value
            ?.where((d) => d.definition.id == session.definitionId)
            .firstOrNull
            ?.definition
            .name ??
        session.definitionId;
    return Semantics(
      container: true,
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: metrics.md,
          vertical: metrics.xs,
        ),
        color: context.colors.surfaceVariant,
        child: Row(
          children: [
            ExcludeSemantics(
              child: Icon(Icons.emoji_events, color: context.colors.primary),
            ),
            SizedBox(width: metrics.sm),
            Expanded(
              // Wraps the button under the text on narrow windows or large
              // text sizes instead of overflowing.
              child: Wrap(
                spacing: metrics.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    l10n.contestBannerActive(name),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  TextButton(
                    onPressed: () => context.push(Routes.contest),
                    child: Text(l10n.contestBannerReturn),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
