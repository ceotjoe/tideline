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

  @override
  String get onboardingWelcomeTitle => 'Willkommen bei Tideline';

  @override
  String get onboardingWelcomeBody =>
      'Tideline speichert deine QSOs zuerst auf diesem Gerät – mit oder ohne Verbindung – und synchronisiert sie mit deinem eigenen Wavelog-Server, sobald er erreichbar ist. Dein Log wird nirgendwo anders hin gesendet.';

  @override
  String get onboardingStart => 'Mit Wavelog verbinden';

  @override
  String onboardingStepOf(int current, int total) {
    return 'Schritt $current von $total';
  }

  @override
  String get onboardingServerTitle => 'Dein Wavelog-Server';

  @override
  String get onboardingServerBody =>
      'Gib die Adresse ein, mit der du Wavelog im Browser öffnest. Wavelog 3.1 oder neuer wird benötigt.';

  @override
  String get fieldServerUrl => 'Serveradresse';

  @override
  String get fieldServerUrlHint => 'https://log.example.org';

  @override
  String get fieldAccountLabel => 'Name für dieses Konto (optional)';

  @override
  String get fieldAccountLabelHint => 'Zum Beispiel Privat oder Clubstation';

  @override
  String get onboardingAllowHttp =>
      'Unverschlüsselte Verbindung erlauben (nur lokales Netz)';

  @override
  String get onboardingAllowHttpWarning =>
      'Nur für einen Server in deinem eigenen Netz. Token und QSOs werden unverschlüsselt übertragen. Niemals über das Internet verwenden.';

  @override
  String get actionContinue => 'Weiter';

  @override
  String get actionBack => 'Zurück';

  @override
  String get onboardingTokenTitle => 'API-Token';

  @override
  String get onboardingTokenBody =>
      'Öffne in Wavelog dein Benutzermenü, wähle API und erstelle einen neuen v2-Token. Füge ihn hier ein. Er beginnt mit wl2_ und wird nur im sicheren Speicher dieses Geräts abgelegt.';

  @override
  String get fieldToken => 'API-Token';

  @override
  String get onboardingScopesRequired => 'Erforderliche Berechtigungen';

  @override
  String get onboardingScopesOptional => 'Optionale Berechtigungen';

  @override
  String get scopeQsoWrite =>
      'qso:write – QSOs hochladen und hochgeladene korrigieren';

  @override
  String get scopeQsoRead =>
      'qso:read – vor erneutem Senden den Server prüfen, damit nichts doppelt landet';

  @override
  String get scopeStationRead =>
      'station:read – deine Stationsstandorte abrufen';

  @override
  String get scopeQsoDelete =>
      'qso:delete – in Tideline Gelöschtes auch in Wavelog löschen';

  @override
  String get scopeContest =>
      'contest:read und contest:write – Contest-Sessions in Wavelog (ab 3.2)';

  @override
  String get scopeLookup =>
      'lookup:read – Online-Rufzeichenabfragen bei Verbindung';

  @override
  String get scopeGranted => 'erteilt';

  @override
  String get scopeMissing => 'fehlt';

  @override
  String get actionCheckToken => 'Verbindung prüfen';

  @override
  String get onboardingChecking => 'Server wird geprüft …';

  @override
  String get onboardingStationTitle => 'Stationsstandort';

  @override
  String get onboardingStationBody =>
      'Neue QSOs werden zu diesem Stationsstandort hochgeladen. Du kannst für jedes QSO einen anderen wählen.';

  @override
  String get onboardingServerVersion31 =>
      'Mit Wavelog 3.1 verbunden. Contest-Sessions benötigen Wavelog 3.2 oder neuer.';

  @override
  String get onboardingServerVersion32 =>
      'Mit Wavelog 3.2 oder neuer verbunden.';

  @override
  String get onboardingNoStations =>
      'Dein Wavelog-Konto hat noch keinen Stationsstandort. Lege in Wavelog unter Stationseinrichtung einen an und prüfe dann erneut.';

  @override
  String get onboardingFinish => 'Loslegen';

  @override
  String get problemInvalidUrl =>
      'Das sieht nicht nach einer Webadresse aus. Verwende die Adresse, mit der du Wavelog öffnest, zum Beispiel https://log.example.org.';

  @override
  String get problemInsecurePublicHttp =>
      'Unverschlüsseltes http:// ist nur für Server im eigenen Netz möglich. Für Server im Internet bitte https:// verwenden.';

  @override
  String get problemHttpNeedsOptIn =>
      'Diese Adresse nutzt unverschlüsseltes http://. Aktiviere „Unverschlüsselte Verbindung erlauben“, wenn der Server in deinem eigenen Netz steht.';

  @override
  String get problemUnreachable =>
      'Der Server hat nicht geantwortet. Prüfe Adresse und Verbindung. Du kannst Tideline auch später einrichten.';

  @override
  String get problemNoApiV2 =>
      'Der Server antwortet, aber nicht wie Wavelog 3.1 oder neuer. Prüfe die Adresse oder aktualisiere Wavelog.';

  @override
  String get problemTokenInvalid =>
      'Wavelog akzeptiert diesen Token nicht. Kopiere ihn erneut (er beginnt mit wl2_) oder erstelle einen neuen.';

  @override
  String get problemTokenExpired =>
      'Dieser Token ist abgelaufen. Erstelle in Wavelog einen neuen.';

  @override
  String problemMissingScopes(Object scopes) {
    return 'Diesem Token fehlen Berechtigungen, die Tideline braucht: $scopes. Erstelle einen Token, der sie enthält.';
  }

  @override
  String get problemServerError =>
      'Der Server hat einen Fehler gemeldet. Bitte versuche es gleich noch einmal.';

  @override
  String get problemCertificateRejected =>
      'Die Verbindung ist nicht vertrauenswürdig, daher wurde nichts gesendet. Wenn es dein eigener Server ist, prüfe sein Zertifikat und versuche es erneut.';

  @override
  String get certTitle => 'Unbekanntes Zertifikat';

  @override
  String get certBody =>
      'Dein Gerät vertraut dem Zertifikat dieses Servers nicht. Das ist bei selbst betriebenen Servern üblich. Fahre nur fort, wenn der Fingerabdruck unten mit dem deines Servers übereinstimmt. Ändert er sich später, hält Tideline an und fragt erneut.';

  @override
  String get certFingerprint => 'SHA-256-Fingerabdruck';

  @override
  String certValidity(String from, String until) {
    return 'Gültig von $from bis $until';
  }

  @override
  String get certTrust => 'Diesem Zertifikat vertrauen';

  @override
  String get certCancel => 'Abbrechen';

  @override
  String get statusSynced => 'Synchronisiert';

  @override
  String get statusLocal => 'Nur auf Gerät';

  @override
  String get statusQueued => 'Wartet';

  @override
  String get statusUploading => 'Wird hochgeladen';

  @override
  String get statusVerifying => 'Wird geprüft';

  @override
  String get statusConflict => 'Entscheidung nötig';

  @override
  String get statusBlocked => 'Token-Problem';

  @override
  String get statusRejected => 'Abgelehnt';

  @override
  String get unitMhz => 'MHz';

  @override
  String get unitUtc => 'UTC';

  @override
  String get fieldCallsign => 'Rufzeichen';

  @override
  String get fieldBand => 'Band';

  @override
  String get fieldMode => 'Betriebsart';

  @override
  String get fieldFrequency => 'Frequenz';

  @override
  String get fieldRstSent => 'RST gesendet';

  @override
  String get fieldRstRcvd => 'RST empfangen';

  @override
  String get fieldName => 'Name';

  @override
  String get fieldGrid => 'Locator';

  @override
  String get fieldComment => 'Kommentar';

  @override
  String get fieldStation => 'Stationsstandort';

  @override
  String get fieldDateUtc => 'Datum und Zeit';

  @override
  String get fieldCountry => 'DXCC-Gebiet';

  @override
  String get issueInvalidCall =>
      'Gib ein Rufzeichen ein, zum Beispiel DL1ABC oder EA8/DL1ABC/P.';

  @override
  String get issueMissingBand => 'Wähle ein Band oder gib eine Frequenz ein.';

  @override
  String get issueMissingMode => 'Wähle eine Betriebsart.';

  @override
  String get issueInvalidFrequency =>
      'Gib die Frequenz in MHz (14.205) oder kHz (14205) ein.';

  @override
  String get issueFrequencyOutsideBand =>
      'Diese Frequenz liegt außerhalb des gewählten Bands.';

  @override
  String get issueInvalidGrid =>
      'Ein Locator hat 4, 6 oder 8 Zeichen, etwa JO40 oder JO40hd.';

  @override
  String get issueNoStation =>
      'Gespeichert. Wähle einen Stationsstandort, damit dieses QSO hochgeladen werden kann.';

  @override
  String get issueTimeInFuture =>
      'Gespeichert, aber die Zeit liegt in der Zukunft. Prüfe die Uhr deines Geräts.';

  @override
  String qsoLoggedAnnouncement(String call) {
    return 'QSO mit $call geloggt.';
  }

  @override
  String timeNow(String time) {
    return 'Jetzt: $time';
  }

  @override
  String timeManual(String time) {
    return 'Festgelegt: $time';
  }

  @override
  String get actionChangeTime => 'Zeit ändern';

  @override
  String get actionUseNow => 'Aktuelle Zeit verwenden';

  @override
  String dxccSummary(String name, String continent, int cq, int itu) {
    return '$name · $continent · CQ $cq · ITU $itu';
  }

  @override
  String workedBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'schon $count-mal gearbeitet',
      one: 'schon einmal gearbeitet',
    );
    return '$_temp0';
  }

  @override
  String get explainSynced => 'Dieses QSO ist sicher in deinem Wavelog.';

  @override
  String get explainLocal =>
      'Nur auf diesem Gerät gespeichert. Wähle einen Stationsstandort, damit es hochgeladen werden kann.';

  @override
  String get explainQueued =>
      'Auf diesem Gerät gespeichert und wartet auf die nächste Synchronisierung.';

  @override
  String get explainUploading => 'Wird gerade an Wavelog gesendet.';

  @override
  String get explainVerifying =>
      'Der letzte Versuch wurde nicht sauber beendet. Tideline prüft dein Wavelog, bevor es erneut sendet, damit das QSO nie doppelt landet.';

  @override
  String get explainConflict => 'Dieses QSO braucht deine Entscheidung.';

  @override
  String get explainRejected =>
      'Wavelog hat dieses QSO nicht angenommen. Korrigiere es, dann wird es erneut gesendet.';

  @override
  String get explainBlocked =>
      'Wartet, bis der Token des Kontos wieder funktioniert. Es geht nichts verloren.';

  @override
  String get problemSyncNetwork =>
      'Dein Wavelog war nicht erreichbar; Tideline versucht es erneut.';

  @override
  String get problemSyncRateLimited =>
      'Dein Wavelog hat um eine Pause gebeten; es geht automatisch weiter.';

  @override
  String get problemSyncServerError =>
      'Dein Wavelog hat einen internen Fehler gemeldet.';

  @override
  String get problemSyncInvalidData =>
      'Wavelog hat ein Problem mit den Daten des QSOs gefunden.';

  @override
  String get problemSyncStationNotAllowed =>
      'Der Stationsstandort existiert in Wavelog nicht mehr oder der Token darf ihn nicht nutzen. Wähle einen anderen.';

  @override
  String get problemSyncMissingPermission =>
      'Dem Token fehlt dafür eine Berechtigung. Erstelle einen Token mit den im Handbuch genannten Berechtigungen.';

  @override
  String get problemSyncTokenInvalid =>
      'Wavelog akzeptiert den Token nicht mehr. Gib in den Einstellungen einen neuen ein.';

  @override
  String get problemSyncTokenExpired =>
      'Der Token ist abgelaufen. Gib in den Einstellungen einen neuen ein.';

  @override
  String get problemSyncReadOnlyFields =>
      'Du hast Zeit, Betriebsart, Frequenz oder Station geändert. Wavelog kann diese bei einem hochgeladenen QSO nicht ändern.';

  @override
  String get problemSyncSameMinuteTwin =>
      'Ein anderes QSO mit gleichem Rufzeichen, Band und Betriebsart in derselben Minute ist schon in Wavelog, das nur eines davon speichern kann. Korrigiere die Zeit, wenn es ein eigener Kontakt ist, oder lösche eines.';

  @override
  String get qsoNotFound => 'Dieses QSO existiert nicht mehr.';

  @override
  String get qsoDetails => 'QSO-Details';

  @override
  String serverSaid(String message) {
    return 'Wavelog meldet: $message';
  }

  @override
  String get conflictReplace => 'In Wavelog ersetzen';

  @override
  String get conflictKeepServer => 'Ich korrigiere es in Wavelog';

  @override
  String get conflictReplaceNeedsDelete =>
      'Zum Ersetzen braucht der Token die Berechtigung qso:delete.';

  @override
  String get actionDeleteQso => 'QSO löschen';

  @override
  String get deleteQsoTitle => 'Dieses QSO löschen?';

  @override
  String get deleteQsoBody =>
      'Es wird von diesem Gerät und, falls hochgeladen, aus deinem Wavelog entfernt.';

  @override
  String get deleteQsoLocalOnly =>
      'Es wird von diesem Gerät entfernt. Die Kopie in Wavelog bleibt, weil der Token keine Löschberechtigung hat.';

  @override
  String get syncHistory => 'Sync-Verlauf';

  @override
  String get journalLogged => 'Auf diesem Gerät geloggt';

  @override
  String get journalImported => 'Aus einer Datei importiert';

  @override
  String get journalEditQueued => 'Änderung wartet auf Upload';

  @override
  String get journalRequestStarted => 'Wird an Wavelog gesendet';

  @override
  String get journalUploaded => 'In Wavelog gespeichert';

  @override
  String get journalPatched => 'Änderung in Wavelog übernommen';

  @override
  String get journalDeletedOnServer => 'In Wavelog gelöscht';

  @override
  String get journalDeletedLocallyOnly =>
      'Hier gelöscht; die Wavelog-Kopie bleibt (keine Löschberechtigung)';

  @override
  String get journalVerified => 'In Wavelog gefunden, kein Duplikat angelegt';

  @override
  String get journalNotOnServer => 'Noch nicht in Wavelog, wird gesendet';

  @override
  String get journalRetry => 'Neuer Versuch später';

  @override
  String get journalRejected => 'Von Wavelog abgelehnt';

  @override
  String get journalConflict => 'Braucht deine Entscheidung';

  @override
  String get journalConflictResolved => 'Entscheidung getroffen';

  @override
  String get journalAccountBlocked => 'Token funktioniert nicht mehr';

  @override
  String get journalRunStarted => 'Synchronisierung gestartet';

  @override
  String get journalRunFinished => 'Synchronisierung beendet';

  @override
  String get logEmptyBodyReady =>
      'Logge oben dein erstes QSO. Es wird sofort auf diesem Gerät gespeichert – mit oder ohne Verbindung.';

  @override
  String get recentQsos => 'Letzte QSOs';

  @override
  String get contextHint =>
      'Gib ein Rufzeichen ein, um DXCC-Gebiet, Zonen und frühere Verbindungen zu sehen. Das funktioniert offline.';

  @override
  String contextWae(String name) {
    return 'WAE: $name';
  }

  @override
  String contextDxccNumber(int number) {
    return 'DXCC-Gebiet $number';
  }

  @override
  String get contextWorkedBefore => 'Schon gearbeitet';

  @override
  String get contextNewOne => 'Noch nicht in deinem Log – ein neues!';

  @override
  String certSubjectLine(String value) {
    return 'Ausgestellt für: $value';
  }

  @override
  String certIssuerLine(String value) {
    return 'Ausgestellt von: $value';
  }

  @override
  String get syncRunning => 'Synchronisiere mit deinem Wavelog …';

  @override
  String syncCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count QSOs synchronisiert.',
      one: '1 QSO synchronisiert.',
      zero: 'Alles ist aktuell.',
    );
    return '$_temp0';
  }

  @override
  String get syncOffline =>
      'Dein Wavelog ist gerade nicht erreichbar. Deine QSOs sind auf diesem Gerät sicher und werden später synchronisiert.';

  @override
  String get syncBlocked =>
      'Der Token funktioniert nicht mehr. Gib in den Einstellungen einen neuen ein; es geht nichts verloren.';

  @override
  String get syncRateLimited =>
      'Dein Wavelog hat um eine Pause gebeten. Die Synchronisierung geht automatisch weiter.';

  @override
  String syncNeedsReview(int count) {
    return '$count neue QSOs sind bereit. Bitte prüfe den Upload zuerst.';
  }

  @override
  String get actionPreviewUpload => 'Upload-Vorschau';

  @override
  String get previewTitle => 'Vor dem Upload';

  @override
  String previewToUpload(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count QSOs werden hochgeladen.',
      one: '1 QSO wird hochgeladen.',
    );
    return '$_temp0';
  }

  @override
  String previewDuplicates(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count sehen nach Duplikaten vorhandener QSOs aus; Wavelog behält jeweils nur eines.',
      one: '1 sieht nach einem Duplikat eines vorhandenen QSOs aus; Wavelog behält nur eines.',
    );
    return '$_temp0';
  }

  @override
  String previewServerParsed(int parsed, int total) {
    return 'Der Testlauf von Wavelog hat $parsed von $total akzeptiert.';
  }

  @override
  String get previewServerUnreachable =>
      'Wavelog konnte gerade nicht gefragt werden; der Upload prüft trotzdem jedes QSO.';

  @override
  String get previewSafety =>
      'Jedes QSO wird vor jedem neuen Versuch mit deinem Wavelog abgeglichen, damit nichts doppelt gesendet wird.';

  @override
  String get previewUpload => 'Hochladen';
}
