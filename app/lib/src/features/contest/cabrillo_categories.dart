import 'package:tideline/l10n/generated/app_localizations.dart';
import 'package:tideline_domain/tideline_domain.dart';

/// The Cabrillo 3.0 category fields a session records for the log header.
///
/// The values are protocol tokens and are never translated; only the field
/// names shown next to them are.
enum CabrilloCategory {
  /// `CATEGORY-OPERATOR`.
  operator('CATEGORY-OPERATOR', ['SINGLE-OP', 'MULTI-OP', 'CHECKLOG']),

  /// `CATEGORY-ASSISTED`.
  assisted('CATEGORY-ASSISTED', ['NON-ASSISTED', 'ASSISTED']),

  /// `CATEGORY-BAND`.
  band('CATEGORY-BAND', [
    'ALL',
    '160M',
    '80M',
    '40M',
    '20M',
    '15M',
    '10M',
    '6M',
    '4M',
    '2M',
    '222',
    '432',
    '902',
    '1.2G',
    '2.3G',
    '3.4G',
    '5.7G',
    '10G',
    '24G',
    '47G',
    '75G',
    '122G',
    '134G',
    '241G',
    'Light',
    'VHF-3-BAND',
    'VHF-FM-ONLY',
  ]),

  /// `CATEGORY-MODE`.
  mode('CATEGORY-MODE', ['CW', 'DIGI', 'FM', 'RTTY', 'SSB', 'MIXED']),

  /// `CATEGORY-POWER`.
  power('CATEGORY-POWER', ['HIGH', 'LOW', 'QRP']),

  /// `CATEGORY-STATION`.
  station('CATEGORY-STATION', [
    'DISTRIBUTED',
    'FIXED',
    'MOBILE',
    'PORTABLE',
    'ROVER',
    'ROVER-LIMITED',
    'ROVER-UNLIMITED',
    'EXPEDITION',
    'HQ',
    'SCHOOL',
    'EXPLORER',
  ]),

  /// `CATEGORY-TRANSMITTER`.
  transmitter('CATEGORY-TRANSMITTER', [
    'ONE',
    'TWO',
    'LIMITED',
    'UNLIMITED',
    'SWL',
  ]),

  /// `CATEGORY-OVERLAY`.
  overlay('CATEGORY-OVERLAY', [
    'CLASSIC',
    'ROOKIE',
    'TB-WIRES',
    'YOUTH',
    'NOVICE-TECH',
  ]);

  new(this.tag, this.tokens);

  /// The Cabrillo header tag; also the key in `ContestSession.cabrillo`.
  final String tag;

  /// The allowed tokens.
  final List<String> tokens;

  /// The localised name of the field.
  String label(AppLocalizations l10n) => switch (this) {
    operator => l10n.contestCatOperator,
    assisted => l10n.contestCatAssisted,
    band => l10n.contestCatBand,
    mode => l10n.contestCatMode,
    power => l10n.contestCatPower,
    station => l10n.contestCatStation,
    transmitter => l10n.contestCatTransmitter,
    overlay => l10n.contestCatOverlay,
  };
}

/// Starting values for a new session of [definition]: the common choices
/// for single operators. Power, station and overlay stay unset, because
/// they are claims the operator must make.
Map<CabrilloCategory, String> defaultCabrilloCategories(
  ContestDefinition definition,
) {
  final modes = definition.modes;
  final mode = modes.length > 1
      ? 'MIXED'
      : switch (modes.single) {
          ModeCategory.cw => 'CW',
          ModeCategory.phone => 'SSB',
          ModeCategory.digi => 'DIGI',
        };
  return {
    CabrilloCategory.operator: 'SINGLE-OP',
    CabrilloCategory.assisted: 'NON-ASSISTED',
    CabrilloCategory.band: 'ALL',
    CabrilloCategory.mode: mode,
    CabrilloCategory.transmitter: 'ONE',
  };
}
