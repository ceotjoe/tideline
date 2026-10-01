// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Tideline';

  @override
  String get appTagline => 'Der Offline-Logger für Wavelog';

  @override
  String get navLog => 'Log';

  @override
  String get navSync => 'Sync';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get logEmptyTitle => 'Noch keine QSOs';

  @override
  String get logEmptyBody =>
      'Das Loggen kommt mit der nächsten Version. Alles, was du loggst, wird zuerst auf diesem Gerät gespeichert – mit oder ohne Verbindung.';

  @override
  String get syncEmptyTitle => 'Nichts zu synchronisieren';

  @override
  String get syncEmptyBody =>
      'Geloggte QSOs warten hier, bis Tideline deinen Wavelog-Server erreicht.';

  @override
  String tideGaugeLabel(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString QSOs warten auf Synchronisierung',
      one: '1 QSO wartet auf Synchronisierung',
      zero: 'Alle QSOs synchronisiert',
    );
    return '$_temp0';
  }

  @override
  String get settingsAppearance => 'Darstellung';

  @override
  String get settingsTheme => 'Farbschema';

  @override
  String get themeSystem => 'Wie System';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get themeSunlight => 'Sonnenlicht (maximaler Kontrast)';

  @override
  String get themeNightRed => 'Nachtrot';

  @override
  String get settingsDensity => 'Bedienelemente';

  @override
  String get densityComfortable => 'Standard';

  @override
  String get densityGlove => 'Handschuhmodus (extra groß)';

  @override
  String get settingsTextSpacing => 'Größerer Textabstand';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get languageSystem => 'Wie System';

  @override
  String get settingsKeyboard => 'Tastenkürzel';

  @override
  String get shortcutsTitle => 'Tastenkürzel';

  @override
  String get shortcutsClose => 'Schließen';

  @override
  String get shortcutScopeGlobal => 'Überall';

  @override
  String get shortcutScopeLogging => 'Loggen';

  @override
  String get shortcutScopeContest => 'Contest-Modus';

  @override
  String get commandShowShortcuts => 'Tastenkürzel anzeigen';

  @override
  String get commandGoToLog => 'Zum Log';

  @override
  String get commandGoToSync => 'Zur Synchronisierung';

  @override
  String get commandGoToSettings => 'Einstellungen öffnen';

  @override
  String get commandSyncNow => 'Jetzt synchronisieren';

  @override
  String get commandNewQso => 'Neues QSO';

  @override
  String get commandLogQso => 'QSO loggen';

  @override
  String get commandClearEntry => 'Eingabe verwerfen';

  @override
  String get commandEditLastQso => 'Letztes QSO bearbeiten';

  @override
  String get commandNextField => 'Nächstes Feld';

  @override
  String get commandBandUp => 'Nächstes Band';

  @override
  String get commandBandDown => 'Vorheriges Band';

  @override
  String get commandNextMode => 'Nächste Betriebsart';

  @override
  String get syncNotYetAvailable =>
      'Die Synchronisierung kommt mit der nächsten Version.';

  @override
  String get keyControl => 'Strg';

  @override
  String get keyShift => 'Umschalt';

  @override
  String get keyAlt => 'Alt';

  @override
  String get keyEnter => 'Eingabe';

  @override
  String get keyEscape => 'Esc';

  @override
  String get keySpace => 'Leertaste';

  @override
  String get keyTab => 'Tab';

  @override
  String get keyPageUp => 'Bild auf';

  @override
  String get keyPageDown => 'Bild ab';

  @override
  String get settingsDeveloper => 'Entwickleroptionen';

  @override
  String get debugForceRtl => 'Rechts-nach-links-Layout erzwingen';

  @override
  String get languagePseudo => 'Pseudo-Sprache (Tests)';

  @override
  String get startupKeyMissingTitle => 'Dein Log lässt sich nicht entsperren';

  @override
  String get startupKeyMissingBody =>
      'Tideline hat sein Log auf diesem Gerät gefunden, aber der Schlüssel zum Entsperren fehlt im sicheren Speicher des Systems. Das kann nach dem Wiederherstellen des Geräts aus einer Sicherung passieren. Es wurde nichts gelöscht. Stelle eine Tideline-Sicherung wieder her oder installiere die App neu, um ein neues Log zu beginnen.';

  @override
  String get startupErrorTitle => 'Tideline konnte nicht starten';

  @override
  String get startupErrorBody =>
      'Beim Öffnen deines Logs ist ein Fehler aufgetreten. Deine QSOs wurden nicht verändert. Bitte starte die App neu; wenn das wiederholt passiert, melde es bitte auf GitHub.';

  @override
  String get shortcutsUnbound => 'Nicht belegt';

  @override
  String get shortcutsOr => 'oder';
}
