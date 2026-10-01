// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Tideline';

  @override
  String get appTagline => 'The offline logger for Wavelog';

  @override
  String get navLog => 'Log';

  @override
  String get navSync => 'Sync';

  @override
  String get navSettings => 'Settings';

  @override
  String get logEmptyTitle => 'No QSOs yet';

  @override
  String get logEmptyBody =>
      'Logging arrives in the next release. Everything you log will be saved on this device first, with or without a connection.';

  @override
  String get syncEmptyTitle => 'Nothing to sync';

  @override
  String get syncEmptyBody =>
      'When you log QSOs, they wait here until Tideline can reach your Wavelog server.';

  @override
  String tideGaugeLabel(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString QSOs waiting to sync',
      one: '1 QSO waiting to sync',
      zero: 'All QSOs synced',
    );
    return '$_temp0';
  }

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeSystem => 'Match system';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSunlight => 'Sunlight (maximum contrast)';

  @override
  String get themeNightRed => 'Night red';

  @override
  String get settingsDensity => 'Touch targets';

  @override
  String get densityComfortable => 'Standard';

  @override
  String get densityGlove => 'Glove mode (extra large)';

  @override
  String get settingsTextSpacing => 'Extra text spacing';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageSystem => 'Match system';

  @override
  String get settingsKeyboard => 'Keyboard shortcuts';

  @override
  String get shortcutsTitle => 'Keyboard shortcuts';

  @override
  String get shortcutsClose => 'Close';

  @override
  String get shortcutScopeGlobal => 'Everywhere';

  @override
  String get shortcutScopeLogging => 'Logging';

  @override
  String get shortcutScopeContest => 'Contest mode';

  @override
  String get commandShowShortcuts => 'Show keyboard shortcuts';

  @override
  String get commandGoToLog => 'Go to log';

  @override
  String get commandGoToSync => 'Go to sync';

  @override
  String get commandGoToSettings => 'Open settings';

  @override
  String get commandSyncNow => 'Sync now';

  @override
  String get commandNewQso => 'New QSO';

  @override
  String get commandLogQso => 'Log QSO';

  @override
  String get commandClearEntry => 'Clear entry';

  @override
  String get commandEditLastQso => 'Edit last QSO';

  @override
  String get commandNextField => 'Next field';

  @override
  String get commandBandUp => 'Next band';

  @override
  String get commandBandDown => 'Previous band';

  @override
  String get commandNextMode => 'Next mode';

  @override
  String get syncNotYetAvailable => 'Sync arrives in the next release.';

  @override
  String get keyControl => 'Ctrl';

  @override
  String get keyShift => 'Shift';

  @override
  String get keyAlt => 'Alt';

  @override
  String get keyEnter => 'Enter';

  @override
  String get keyEscape => 'Esc';

  @override
  String get keySpace => 'Space';

  @override
  String get keyTab => 'Tab';

  @override
  String get keyPageUp => 'Page Up';

  @override
  String get keyPageDown => 'Page Down';

  @override
  String get settingsDeveloper => 'Developer options';

  @override
  String get debugForceRtl => 'Force right-to-left layout';

  @override
  String get languagePseudo => 'Pseudo-locale (testing)';

  @override
  String get startupKeyMissingTitle => 'Your log can\'t be unlocked';

  @override
  String get startupKeyMissingBody =>
      'Tideline found its log on this device, but the key that unlocks it is missing from the system\'s secure storage. This can happen after restoring the device from a backup. Nothing has been deleted. Restore a Tideline backup, or reinstall the app to start a new log.';

  @override
  String get startupErrorTitle => 'Tideline couldn\'t start';

  @override
  String get startupErrorBody =>
      'Something went wrong while opening your log. Your QSOs have not been changed. Please restart the app; if this keeps happening, report it on GitHub.';

  @override
  String get shortcutsUnbound => 'Not assigned';

  @override
  String get shortcutsOr => 'or';
}

/// The translations for English (`en_XA`).
class AppLocalizationsEnXa extends AppLocalizationsEn {
  AppLocalizationsEnXa() : super('en_XA');

  @override
  String get appTitle => '[Ţîðéļîñé····]';

  @override
  String get appTagline => '[Ţĥé öƒƒļîñé ļöĝĝéŕ ƒöŕ Ŵáṽéļöĝ············]';

  @override
  String get navLog => '[Ļöĝ··]';

  @override
  String get navSync => '[Šýñç··]';

  @override
  String get navSettings => '[Šéţţîñĝš····]';

  @override
  String get logEmptyTitle => '[Ñö ǪŠÖš ýéţ·····]';

  @override
  String get logEmptyBody =>
      '[Ļöĝĝîñĝ áŕŕîṽéš îñ ţĥé ñéẋţ ŕéļéášé. Éṽéŕýţĥîñĝ ýöû ļöĝ ŵîļļ ƀé šáṽéð öñ ţĥîš ðéṽîçé ƒîŕšţ, ŵîţĥ öŕ ŵîţĥöûţ á çöññéçţîöñ.·················································]';

  @override
  String get syncEmptyTitle => '[Ñöţĥîñĝ ţö šýñç······]';

  @override
  String get syncEmptyBody =>
      '[Ŵĥéñ ýöû ļöĝ ǪŠÖš, ţĥéý ŵáîţ ĥéŕé ûñţîļ Ţîðéļîñé çáñ ŕéáçĥ ýöûŕ Ŵáṽéļöĝ šéŕṽéŕ.································]';

  @override
  String tideGaugeLabel(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString[ ǪŠÖš ŵáîţîñĝ ţö šýñç·········]',
      one: '[1 ǪŠÖ ŵáîţîñĝ ţö šýñç·········]',
      zero: '[Åļļ ǪŠÖš šýñçéð······]',
    );
    return '$_temp0';
  }

  @override
  String get settingsAppearance => '[Åþþéáŕáñçé····]';

  @override
  String get settingsTheme => '[Ţĥéɱé··]';

  @override
  String get themeSystem => '[Ṁáţçĥ šýšţéɱ·····]';

  @override
  String get themeLight => '[Ļîĝĥţ··]';

  @override
  String get themeDark => '[Ðáŕķ··]';

  @override
  String get themeSunlight => '[Šûñļîĝĥţ (ɱáẋîɱûɱ çöñţŕášţ)···········]';

  @override
  String get themeNightRed => '[Ñîĝĥţ ŕéð····]';

  @override
  String get settingsDensity => '[Ţöûçĥ ţáŕĝéţš······]';

  @override
  String get densityComfortable => '[Šţáñðáŕð····]';

  @override
  String get densityGlove => '[Ĝļöṽé ɱöðé (éẋţŕá ļáŕĝé)··········]';

  @override
  String get settingsTextSpacing => '[Éẋţŕá ţéẋţ šþáçîñĝ········]';

  @override
  String get settingsLanguage => '[Ļáñĝûáĝé····]';

  @override
  String get languageSystem => '[Ṁáţçĥ šýšţéɱ·····]';

  @override
  String get settingsKeyboard => '[Ķéýƀöáŕð šĥöŕţçûţš········]';

  @override
  String get shortcutsTitle => '[Ķéýƀöáŕð šĥöŕţçûţš········]';

  @override
  String get shortcutsClose => '[Çļöšé··]';

  @override
  String get shortcutScopeGlobal => '[Éṽéŕýŵĥéŕé····]';

  @override
  String get shortcutScopeLogging => '[Ļöĝĝîñĝ···]';

  @override
  String get shortcutScopeContest => '[Çöñţéšţ ɱöðé·····]';

  @override
  String get commandShowShortcuts => '[Šĥöŵ ķéýƀöáŕð šĥöŕţçûţš··········]';

  @override
  String get commandGoToLog => '[Ĝö ţö ļöĝ····]';

  @override
  String get commandGoToSync => '[Ĝö ţö šýñç····]';

  @override
  String get commandGoToSettings => '[Öþéñ šéţţîñĝš······]';

  @override
  String get commandSyncNow => '[Šýñç ñöŵ····]';

  @override
  String get commandNewQso => '[Ñéŵ ǪŠÖ···]';

  @override
  String get commandLogQso => '[Ļöĝ ǪŠÖ···]';

  @override
  String get commandClearEntry => '[Çļéáŕ éñţŕý·····]';

  @override
  String get commandEditLastQso => '[Éðîţ ļášţ ǪŠÖ······]';

  @override
  String get commandNextField => '[Ñéẋţ ƒîéļð····]';

  @override
  String get commandBandUp => '[Ñéẋţ ƀáñð····]';

  @override
  String get commandBandDown => '[Þŕéṽîöûš ƀáñð······]';

  @override
  String get commandNextMode => '[Ñéẋţ ɱöðé····]';

  @override
  String get syncNotYetAvailable =>
      '[Šýñç áŕŕîṽéš îñ ţĥé ñéẋţ ŕéļéášé.··············]';

  @override
  String get keyControl => '[Çţŕļ··]';

  @override
  String get keyShift => '[Šĥîƒţ··]';

  @override
  String get keyAlt => '[Åļţ··]';

  @override
  String get keyEnter => '[Éñţéŕ··]';

  @override
  String get keyEscape => '[Éšç··]';

  @override
  String get keySpace => '[Šþáçé··]';

  @override
  String get keyTab => '[Ţáƀ··]';

  @override
  String get keyPageUp => '[Þáĝé Ûþ···]';

  @override
  String get keyPageDown => '[Þáĝé Ðöŵñ····]';

  @override
  String get settingsDeveloper => '[Ðéṽéļöþéŕ öþţîöñš·······]';

  @override
  String get debugForceRtl => '[Ƒöŕçé ŕîĝĥţ-ţö-ļéƒţ ļáýöûţ···········]';

  @override
  String get languagePseudo => '[Þšéûðö-ļöçáļé (ţéšţîñĝ)··········]';

  @override
  String get startupKeyMissingTitle =>
      '[Ýöûŕ ļöĝ çáñ\'ţ ƀé ûñļöçķéð···········]';

  @override
  String get startupKeyMissingBody =>
      '[Ţîðéļîñé ƒöûñð îţš ļöĝ öñ ţĥîš ðéṽîçé, ƀûţ ţĥé ķéý ţĥáţ ûñļöçķš îţ îš ɱîššîñĝ ƒŕöɱ ţĥé šýšţéɱ\'š šéçûŕé šţöŕáĝé. Ţĥîš çáñ ĥáþþéñ áƒţéŕ ŕéšţöŕîñĝ ţĥé ðéṽîçé ƒŕöɱ á ƀáçķûþ. Ñöţĥîñĝ ĥáš ƀééñ ðéļéţéð. Ŕéšţöŕé á Ţîðéļîñé ƀáçķûþ, öŕ ŕéîñšţáļļ ţĥé áþþ ţö šţáŕţ á ñéŵ ļöĝ.··········································································································]';

  @override
  String get startupErrorTitle => '[Ţîðéļîñé çöûļðñ\'ţ šţáŕţ··········]';

  @override
  String get startupErrorBody =>
      '[Šöɱéţĥîñĝ ŵéñţ ŵŕöñĝ ŵĥîļé öþéñîñĝ ýöûŕ ļöĝ. Ýöûŕ ǪŠÖš ĥáṽé ñöţ ƀééñ çĥáñĝéð. Þļéášé ŕéšţáŕţ ţĥé áþþ; îƒ ţĥîš ķééþš ĥáþþéñîñĝ, ŕéþöŕţ îţ öñ ĜîţĤûƀ.···························································]';

  @override
  String get shortcutsUnbound => '[Ñöţ áššîĝñéð·····]';

  @override
  String get shortcutsOr => '[öŕ·]';
}
