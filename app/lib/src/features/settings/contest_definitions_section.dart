import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tideline/l10n/generated/app_localizations.dart';
import 'package:tideline/src/design/theme.dart';
import 'package:tideline/src/features/contest/contest_providers.dart';
import 'package:tideline/src/features/settings/reference_messages.dart';
import 'package:tideline/src/services/contest_definition_import.dart';
import 'package:tideline_data/tideline_data.dart';

/// Bundled and user contest definitions: import your own, delete them
/// again.
class ContestDefinitionsSection extends ConsumerWidget {
  /// Creates the section.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final definitions = ref.watch(contestDefinitionsProvider).value ?? const [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.metrics.md),
          child: Text(
            l10n.contestDefsHint,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        for (final stored in definitions)
          _DefinitionTile(
            stored: stored,
            onDelete: () => _delete(context, ref, stored),
          ),
        ListTile(
          leading: const Icon(Icons.upload_file_outlined),
          title: Text(l10n.actionImportDefinition),
          subtitle: Text(l10n.importDefinitionHint),
          onTap: () => _import(context, ref),
        ),
      ],
    );
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final result = await ref
        .read(contestDefinitionImporterProvider)
        .pickAndImport();
    if (result == null || !context.mounted) return;
    final definition = result.definition;
    if (definition != null) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              result.replaced
                  ? l10n.contestDefReplaced(definition.name)
                  : l10n.contestDefImported(definition.name),
            ),
          ),
        );
      return;
    }
    final text = definitionProblemText(l10n, result);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.contestDefRejectedTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text.message),
            if (text.path != null) ...[
              SizedBox(height: context.metrics.sm),
              // A JSON path such as $.exchange.sent[1].kind: technical, so
              // it is selectable and always left to right.
              Directionality(
                textDirection: TextDirection.ltr,
                child: SelectableText(
                  l10n.contestDefTechnical(text.path!),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.shortcutsClose),
          ),
        ],
      ),
    );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    StoredContestDefinition stored,
  ) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final name = stored.definition.name;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.contestDefDeleteTitle(name)),
        content: Text(l10n.contestDefDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.actionRemove),
          ),
        ],
      ),
    );
    if (!(confirmed ?? false)) return;
    final result = await ref
        .read(contestDefinitionImporterProvider)
        .delete(stored.definition.id);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(deleteResultText(l10n, result, name))),
      );
  }
}

class _DefinitionTile extends StatelessWidget {
  const new({required this.stored, required this.onDelete});

  final StoredContestDefinition stored;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final def = stored.definition;
    final origin = stored.builtin
        ? l10n.contestDefBuiltin
        : l10n.contestDefUser;
    return ListTile(
      leading: Icon(
        stored.builtin
            ? Icons.inventory_2_outlined
            : Icons.description_outlined,
      ),
      title: Text(def.name),
      subtitle: Text([origin, l10n.contestDefVersion(def.version)].join(' · ')),
      trailing: stored.builtin
          ? null
          : IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: l10n.actionDeleteDefinition(def.name),
              onPressed: onDelete,
            ),
    );
  }
}
