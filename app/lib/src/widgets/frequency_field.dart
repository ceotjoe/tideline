import 'package:flutter/material.dart';
import 'package:tideline/l10n/generated/app_localizations.dart';
import 'package:tideline/src/design/theme.dart';
import 'package:tideline_domain/tideline_domain.dart';

/// Display form of an ADIF band name: `20m` becomes `20 m`, `70cm` becomes
/// `70 cm`. Names without a numeric prefix (`submm`) stay as they are.
/// Presentation only; the stored band stays the ADIF name.
String bandDisplayName(Band band) {
  final match = RegExp(r'^([\d.]+)([a-z]+)$').firstMatch(band.name);
  return match == null ? band.name : '${match[1]} ${match[2]}';
}

/// A frequency text field with a live interpretation underneath
/// ("14.205 MHz · 20 m"), so the operator sees how `472`, `14205` or
/// `14.205` was understood before logging.
///
/// The interpretation is a live region for screen readers and always pairs
/// an icon with text. Reusable by the contest entry.
class FrequencyField extends StatelessWidget {
  /// Creates the field. [controller] holds exactly what the operator typed.
  const new({
    required this.controller,
    required this.onChanged,
    this.errorText,
    super.key,
  });

  /// The typed text.
  final TextEditingController controller;

  /// Called with the raw text on every edit.
  final ValueChanged<String> onChanged;

  /// A validation error from the entry form, shown on the field instead of
  /// the hint for unreadable input.
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: l10n.fieldFrequency,
            errorText: errorText,
          ),
          onChanged: onChanged,
        ),
        Padding(
          padding: EdgeInsets.only(top: context.metrics.xs),
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) => _Readout(
              text: value.text,
              suppressUnreadable: errorText != null,
            ),
          ),
        ),
      ],
    );
  }
}

class _Readout extends StatelessWidget {
  const new({required this.text, required this.suppressUnreadable});

  final String text;
  final bool suppressUnreadable;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final reading = Frequency.interpretUserInput(text);

    final (
      IconData icon,
      Color color,
      String label,
      String spoken,
    ) = switch (reading) {
      _ when text.trim().isEmpty => (
        Icons.info_outline,
        c.textSecondary,
        l10n.freqReadoutEmpty,
        l10n.freqReadoutEmpty,
      ),
      null => (
        Icons.error_outline,
        c.error,
        l10n.freqReadoutUnreadable,
        l10n.freqReadoutUnreadable,
      ),
      (:final hz, band: final band?) => (
        Icons.waves,
        c.textSecondary,
        l10n.freqReadoutInBand(Frequency.toAdifMhz(hz), bandDisplayName(band)),
        l10n.freqReadoutSemanticsInBand(
          Frequency.toAdifMhz(hz),
          bandDisplayName(band),
        ),
      ),
      (:final hz, band: null) => (
        Icons.warning_amber_rounded,
        c.text,
        l10n.freqReadoutOutsideBands(Frequency.toAdifMhz(hz)),
        l10n.freqReadoutSemanticsOutsideBands(Frequency.toAdifMhz(hz)),
      ),
    };

    // The form already explains unreadable input on the field itself.
    if (reading == null && text.trim().isNotEmpty && suppressUnreadable) {
      return const SizedBox.shrink();
    }

    return Semantics(
      container: true,
      liveRegion: true,
      label: spoken,
      child: ExcludeSemantics(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: color),
            SizedBox(width: context.metrics.sm),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
