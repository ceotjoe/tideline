import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tideline/l10n/generated/app_localizations.dart';
import 'package:tideline/src/design/theme.dart';
import 'package:tideline/src/features/callsigns/callsign_providers.dart';

/// The callsign directory in settings: what it holds, and how many stations.
class CallsignDirectorySection extends ConsumerWidget {
  /// Creates the section.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final count = ref.watch(callsignDirectoryCountProvider).value ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.metrics.md),
          child: Text(l10n.callsignDirectoryBody),
        ),
        ListTile(
          leading: const Icon(Icons.person_search_outlined),
          title: Text(l10n.callsignDirectoryCount(count)),
        ),
      ],
    );
  }
}
