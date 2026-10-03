import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat, NumberFormat;
import 'package:tideline/l10n/generated/app_localizations.dart';
import 'package:tideline/src/design/theme.dart';
import 'package:tideline/src/features/settings/reference_messages.dart';
import 'package:tideline/src/services/pack_download.dart';
import 'package:tideline/src/widgets/error_box.dart';
import 'package:tideline_domain/tideline_domain.dart';

/// The SOTA, POTA and WWFF reference lists: what is installed and how to
/// change it. Nothing is downloaded unless the user presses "Download".
class ReferencePacksSection extends StatelessWidget {
  /// Creates the section.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final metrics = context.metrics;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: metrics.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.packsHint, style: Theme.of(context).textTheme.bodyMedium),
          for (final program in ReferenceProgram.values) ...[
            SizedBox(height: metrics.md),
            ReferencePackCard(program: program),
          ],
        ],
      ),
    );
  }
}

/// One programme's list.
class ReferencePackCard extends ConsumerStatefulWidget {
  /// Creates the card.
  const new({required this.program, super.key});

  /// The programme.
  final ReferenceProgram program;

  @override
  ConsumerState<ReferencePackCard> createState() => _ReferencePackCardState();
}

class _ReferencePackCardState extends ConsumerState<ReferencePackCard> {
  late final TextEditingController _url;
  bool _urlEdited = false;
  PackCancellation? _cancel;
  PackPhase _phase = PackPhase.downloading;
  int _received = 0;
  int? _total;
  String? _error;

  ReferenceProgram get _program => widget.program;
  bool get _busy => _cancel != null;

  @override
  void initState() {
    super.initState();
    _url = TextEditingController(
      text: referencePackSources[_program]!.defaultUrl,
    );
    // Start from the address the installed list came from, unless the user
    // already typed something.
    ref.listenManual(referencePackInfoProvider(_program), (_, next) {
      final source = next.value?.sourceUrl;
      if (!_urlEdited && source != null && source.startsWith('https://')) {
        _url.text = source;
      }
    }, fireImmediately: true);
  }

  @override
  void dispose() {
    _cancel?.cancel();
    _url.dispose();
    super.dispose();
  }

  Future<void> _download() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final actions = ref.read(referencePackActionsProvider);
    final cancel = PackCancellation();
    setState(() {
      _cancel = cancel;
      _phase = PackPhase.downloading;
      _received = 0;
      _total = null;
      _error = null;
    });
    String? error;
    String? message;
    try {
      final info = await actions.download(
        _program,
        urlText: _url.text,
        cancel: cancel,
        onProgress: (phase, received, total) {
          if (!mounted) return;
          setState(() {
            _phase = phase;
            _received = received;
            _total = total;
          });
        },
      );
      message = l10n.packInstalled(_program.code, info.count);
    } on PackException catch (e) {
      if (e.failure == PackFailure.cancelled) {
        message = l10n.packCancelled;
      } else {
        error = packFailureText(l10n, e, _program);
      }
    } on Object {
      error = l10n.packErrorStorage;
    }
    if (!mounted) return;
    setState(() {
      _cancel = null;
      _error = error;
    });
    if (message != null) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _remove() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final actions = ref.read(referencePackActionsProvider);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.packRemoveTitle(_program.code)),
        content: Text(l10n.packRemoveBody(_program.code)),
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
    await actions.remove(_program);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.packRemoved(_program.code))));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final metrics = context.metrics;
    final theme = Theme.of(context);
    final info = ref.watch(referencePackInfoProvider(_program)).value;
    final date = DateFormat.yMMMd(l10n.localeName);
    final size = NumberFormat('0.0', l10n.localeName);
    String mb(int bytes) => '${size.format(bytes / (1024 * 1024))} MB';
    final name = packName(l10n, _program);
    final progress = _total == null || _total == 0
        ? null
        : (_received / _total!).clamp(0, 1).toDouble();
    final status = _phase == PackPhase.installing
        ? l10n.packInstalling
        : _received == 0
        ? l10n.packDownloading
        : l10n.packDownloadingSize(mb(_received));
    return Card(
      child: Padding(
        padding: EdgeInsets.all(metrics.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(name, style: theme.textTheme.titleSmall),
            ),
            SizedBox(height: metrics.xs),
            Semantics(
              container: true,
              child: info == null
                  ? Text(l10n.packNone, style: theme.textTheme.bodyMedium)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.packSummary(
                            info.count,
                            info.version,
                            date.format(
                              DateTime.fromMillisecondsSinceEpoch(
                                info.fetchedAt,
                                isUtc: true,
                              ),
                            ),
                          ),
                          style: theme.textTheme.bodyMedium,
                        ),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            l10n.scpSource(info.sourceUrl),
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
                if (_busy)
                  OutlinedButton.icon(
                    onPressed: _cancel!.cancel,
                    icon: const Icon(Icons.close),
                    label: Text(l10n.actionCancel),
                  )
                else ...[
                  FilledButton.icon(
                    onPressed: _download,
                    icon: Icon(
                      info == null ? Icons.download_outlined : Icons.refresh,
                    ),
                    label: Text(
                      info == null ? l10n.actionDownload : l10n.actionUpdate,
                    ),
                  ),
                  if (info != null)
                    OutlinedButton.icon(
                      onPressed: _remove,
                      icon: const Icon(Icons.delete_outline),
                      label: Text(l10n.actionRemove),
                    ),
                ],
              ],
            ),
            if (_busy) ...[
              SizedBox(height: metrics.sm),
              Semantics(
                liveRegion: true,
                label: status,
                child: LinearProgressIndicator(
                  value: _phase == PackPhase.installing ? null : progress,
                ),
              ),
              SizedBox(height: metrics.xs),
              Text(status, style: theme.textTheme.bodySmall),
            ],
            if (_error != null) ...[
              SizedBox(height: metrics.sm),
              ErrorBox(_error!),
            ],
          ],
        ),
      ),
    );
  }
}
