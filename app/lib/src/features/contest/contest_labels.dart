import 'package:tideline/l10n/generated/app_localizations.dart';
import 'package:tideline_domain/tideline_domain.dart';

/// The localised name of an exchange element.
String exchangeLabel(AppLocalizations l10n, ExchangeElement element) =>
    switch (element.kind) {
      ExchangeKind.rst => l10n.contestKindRst,
      ExchangeKind.serial => l10n.contestKindSerial,
      ExchangeKind.cqZone => l10n.contestKindCqZone,
      ExchangeKind.ituZone => l10n.contestKindItuZone,
      ExchangeKind.grid => l10n.contestKindGrid,
      ExchangeKind.state => l10n.contestKindState,
      ExchangeKind.section => l10n.contestKindSection,
      ExchangeKind.dok => l10n.contestKindDok,
      ExchangeKind.power => l10n.contestKindPower,
      ExchangeKind.name => l10n.contestKindName,
      ExchangeKind.text => l10n.contestKindText,
    };

/// The localised message for an exchange element that was rejected.
String exchangeErrorText(
  AppLocalizations l10n,
  ExchangeElement element,
  ExchangeError error,
) {
  final label = exchangeLabel(l10n, element);
  return switch (error) {
    ExchangeError.missing => l10n.contestErrorMissing(label),
    ExchangeError.invalidFormat => l10n.contestErrorInvalid(label),
    ExchangeError.outOfRange => l10n.contestErrorOutOfRange(label),
  };
}

/// The name of a multiplier. Ids of the bundled contests are translated;
/// ids of imported definitions are shown as written.
String multiplierLabel(AppLocalizations l10n, String id) => switch (id) {
  'zone' => l10n.contestMultZone,
  'itu-zone' => l10n.contestMultItuZone,
  'country' || 'dxcc' || 'dxcc-na' || 'dxcc-overseas' => l10n.contestMultDxcc,
  'prefix' => l10n.contestMultPrefix,
  'state-na' || 'state-overseas' => l10n.contestMultState,
  'dok' => l10n.contestMultDok,
  _ => id,
};
