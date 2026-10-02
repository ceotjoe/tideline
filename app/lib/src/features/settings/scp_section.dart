import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:tideline/l10n/generated/app_localizations.dart';
import 'package:tideline/src/design/theme.dart';
import 'package:tideline/src/design/tokens/metrics.dart';
import 'package:tideline/src/features/settings/reference_messages.dart';
import 'package:tideline/src/services/data_transfer.dart';
import 'package:tideline/src/services/scp_download.dart';
import 'package:tideline_data/tideline_data.dart';

/// The MASTER.SCP list (super check partial): what is installed, and the
/// three ways to change it. Nothing is downloaded unless the user presses
/// "Download".
class ScpSection extends ConsumerStatefulWidget {
  /// Creates the section.
  const new({super.key});

  @override
  ConsumerState<ScpSection> createState() => _ScpSectionState();
}

class _ScpSectionState extends ConsumerState<ScpSection> {
  final _url = TextEditingController(text: defaultScpUrl);
  bool _urlEdited = false;
  bool _busy = false;
  int _received = 0;
  int? _total;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Start from the address the installed list came from, unless the user
    // already typed something.
    ref.listenManual(scpInfoProvider, (_, next) {
      final source = next.value?.sourceUrl;
      if (!_urlEdited && source != null && source.startsWith('https://')) {
        _url.text = source;
      }
    }, fireImmediately: true);
  }

  @override
  void dispose() {
    _url.dispose();
    super.dispose();
  }

  Future<void> _run(Future<ScpPackInfo> Function() action) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _busy = true;
      _received = 0;
      _total = null;
      _error = null;
    });
    String? error;
    ScpPackInfo? info;
    try {
      info = await action();
    } on ScpException catch (e) {
      error = scpFailureText(l10n, e);
    } on ImportTooLargeException {
      error = l10n.scpErrorTooLarge;
    } on _Cancelled {
      // The picker was dismissed: not an error.
    } on Object {
      error = l10n.scpErrorUnreadable;
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = error;
    });
    if (info != null) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(l10n.scpInstalled(info.callCount))),
        );
    }
  }

  Future<void> _download() => _run(
    () => ref
        .read(scpActionsProvider)
        .download(
          _url.text,
          onProgress: (received, total) {
            if (!mounted) return;
            setState(() {
              _received = received;
              _total = total;
            });
          },
        ),
  );

  Future<void> _importFile() async {
    final transfer = ref.read(dataTransferProvider);
    final actions = ref.read(scpActionsProvider);
    await _run(() async {
      final bytes = await transfer.pickFile(const [
        'scp',
        'txt',
      ], maxBytes: maxScpBytes);
      // Cancelled: nothing to install, nothing to report.
      if (bytes == null) throw const _Cancelled();
      return await actions.importBytes(bytes);
    });
  }

  Future<void> _remove() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final actions = ref.read(scpActionsProvider);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.scpRemoveTitle),
        content: Text(l10n.scpRemoveBody),
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
    await actions.remove();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.scpRemoved)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final metrics = context.metrics;
    final info = ref.watch(scpInfoProvider).value;
    final theme = Theme.of(context);
    final date = DateFormat.yMMMd(l10n.localeName);
    final fromFile = info?.sourceUrl == scpLocalFileSource;
    final kib = _received ~/ 1024;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: metrics.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.scpHint, style: theme.textTheme.bodyMedium),
          SizedBox(height: metrics.sm),
          Semantics(
            container: true,
            child: info == null
                ? Text(l10n.scpNone, style: theme.textTheme.titleSmall)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.scpPackSummary(
                          info.callCount,
                          date.format(
                            DateTime.fromMillisecondsSinceEpoch(
                              info.fetchedAt,
                              isUtc: true,
                            ),
                          ),
                        ),
                        style: theme.textTheme.titleSmall,
                      ),
                      Directionality(
                        textDirection: fromFile
                            ? Directionality.of(context)
                            : TextDirection.ltr,
                        child: Text(
                          l10n.scpSource(
                            fromFile ? l10n.scpSourceFile : info.sourceUrl,
                          ),
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
          ),
          SizedBox(height: metrics.md),
          TextField(
            controller: _url,
            enabled: !_busy,
            keyboardType: TextInputType.url,
            autocorrect: false,
            enableSuggestions: false,
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(
              labelText: l10n.scpUrlLabel,
              helperText: l10n.scpUrlHelper,
              helperMaxLines: 3,
            ),
            onChanged: (_) => _urlEdited = true,
          ),
          SizedBox(height: metrics.sm),
          Wrap(
            spacing: metrics.sm,
            runSpacing: metrics.sm,
            children: [
              FilledButton.icon(
                onPressed: _busy ? null : _download,
                icon: const Icon(Icons.download_outlined),
                label: Text(l10n.actionDownload),
              ),
              OutlinedButton.icon(
                onPressed: _busy ? null : _importFile,
                icon: const Icon(Icons.file_open_outlined),
                label: Text(l10n.actionImportFile),
              ),
              if (info != null)
                OutlinedButton.icon(
                  onPressed: _busy ? null : _remove,
                  icon: const Icon(Icons.delete_outline),
                  label: Text(l10n.actionRemove),
                ),
            ],
          ),
          if (_busy) ...[
            SizedBox(height: metrics.sm),
            Semantics(
              liveRegion: true,
              label: l10n.scpDownloading,
              child: LinearProgressIndicator(
                value: _total == null || _total == 0
                    ? null
                    : (_received / _total!).clamp(0, 1),
              ),
            ),
            SizedBox(height: metrics.xs),
            Text(
              _received == 0
                  ? l10n.scpDownloading
                  : l10n.scpDownloadingSize(kib),
              style: theme.textTheme.bodySmall,
            ),
          ],
          if (_error != null) ...[
            SizedBox(height: metrics.sm),
            Semantics(
              liveRegion: true,
              container: true,
              child: Container(
                padding: EdgeInsets.all(metrics.sm),
                decoration: BoxDecoration(
                  color: context.colors.rejected.background,
                  borderRadius: const BorderRadius.all(
                    TidelineMetrics.radiusSm,
                  ),
                  border: Border.all(
                    color: context.colors.rejected.foreground.withValues(
                      alpha: .4,
                    ),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ExcludeSemantics(
                      child: Icon(
                        Icons.error_outline,
                        size: 20,
                        color: context.colors.rejected.foreground,
                      ),
                    ),
                    SizedBox(width: metrics.sm),
                    Expanded(
                      child: Text(
                        _error!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: context.colors.rejected.foreground,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The picker was dismissed.
class _Cancelled implements Exception {
  const new();
}
