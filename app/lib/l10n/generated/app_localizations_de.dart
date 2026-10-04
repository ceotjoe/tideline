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
  String get actionHideKeyboard => 'Tastatur ausblenden';

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
  String freqReadoutInBand(String mhz, String band) {
    return '$mhz MHz · $band';
  }

  @override
  String freqReadoutOutsideBands(String mhz) {
    return '$mhz MHz · außerhalb der Amateurfunkbänder';
  }

  @override
  String freqReadoutInBandKhz(String khz, String band) {
    return '$khz kHz · $band';
  }

  @override
  String freqReadoutOutsideBandsKhz(String khz) {
    return '$khz kHz · außerhalb der Amateurfunkbänder';
  }

  @override
  String get freqReadoutUnreadable =>
      'Keine Frequenz. Gib MHz (14.205) oder kHz (14205) ein.';

  @override
  String get freqReadoutEmpty => 'Gib MHz (14.205) oder kHz (14205) ein.';

  @override
  String freqReadoutSemanticsInBand(String mhz, String band) {
    return '$mhz Megahertz, $band';
  }

  @override
  String freqReadoutSemanticsOutsideBands(String mhz) {
    return '$mhz Megahertz, außerhalb der Amateurfunkbänder';
  }

  @override
  String freqReadoutSemanticsInBandKhz(String khz, String band) {
    return '$khz Kilohertz, $band';
  }

  @override
  String freqReadoutSemanticsOutsideBandsKhz(String khz) {
    return '$khz Kilohertz, außerhalb der Amateurfunkbänder';
  }

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
  String get journalContestSessionCreated =>
      'Contest-Sitzung in Wavelog angelegt';

  @override
  String get journalContestQsosLinked =>
      'QSOs mit der Wavelog-Contest-Sitzung verknüpft';

  @override
  String get journalContestSessionLocalOnly =>
      'Contest-Sitzung bleibt nur auf diesem Gerät';

  @override
  String get journalContestSessionRetry =>
      'Contest-Sitzung noch nicht synchronisiert; neuer Versuch folgt';

  @override
  String get logEmptyBodyReady =>
      'Logge oben dein erstes QSO. Es wird sofort auf diesem Gerät gespeichert – mit oder ohne Verbindung.';

  @override
  String get recentQsos => 'Letzte QSOs';

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

  @override
  String get settingsAccount => 'Wavelog-Konto';

  @override
  String get settingsData => 'Import, Export und Sicherung';

  @override
  String get settingsSecurity => 'Sicherheit';

  @override
  String get accountPinned => 'Nutzt ein manuell vertrautes Zertifikat';

  @override
  String accountTokenExpires(String date) {
    return 'Token läuft am $date ab';
  }

  @override
  String get accountTokenNoExpiry => 'Token ohne Ablaufdatum';

  @override
  String get actionReplaceToken => 'Neuen Token eingeben';

  @override
  String get tokenReplaced => 'Neuer Token gespeichert. Synchronisiere …';

  @override
  String get actionRemoveAccount => 'Konto von diesem Gerät entfernen';

  @override
  String get removeAccountTitle => 'Dieses Konto entfernen?';

  @override
  String get removeAccountBody =>
      'Seine QSOs werden von diesem Gerät entfernt. Dein Wavelog bleibt unverändert.';

  @override
  String removeAccountUnsynced(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count QSOs sind noch nicht in Wavelog und gingen verloren. Exportiere oder sichere sie vorher.',
      one: '1 QSO ist noch nicht in Wavelog und ginge verloren. Exportiere oder sichere es vorher.',
    );
    return '$_temp0';
  }

  @override
  String get actionImportAdif => 'ADIF-Datei importieren';

  @override
  String get importAdifHint =>
      'Zum Beispiel ein anderswo erfasstes Papierlog oder der Export eines anderen Loggers.';

  @override
  String get actionExportAdif => 'Log als ADIF exportieren';

  @override
  String get exportAdifHint =>
      'Von jedem Logprogramm lesbar. Nicht verschlüsselt.';

  @override
  String get exportDone => 'Log exportiert.';

  @override
  String get actionCreateBackup => 'Verschlüsselte Sicherung erstellen';

  @override
  String get backupHint =>
      'Alles außer deinem Token, geschützt durch ein Passwort.';

  @override
  String get backupDone => 'Sicherung gespeichert.';

  @override
  String get actionRestoreBackup => 'Sicherung wiederherstellen';

  @override
  String restoreDone(int added, int skipped) {
    return '$added QSOs wiederhergestellt ($skipped waren schon vorhanden).';
  }

  @override
  String get restoreWrongPassphrase =>
      'Mit diesem Passwort lässt sich die Sicherung nicht öffnen.';

  @override
  String get restoreInvalidFile =>
      'Diese Datei ist keine Tideline-Sicherung oder beschädigt.';

  @override
  String get backupPassphraseTitle => 'Passwort der Sicherung';

  @override
  String get backupPassphraseHint =>
      'Mindestens 8 Zeichen. Ohne es lässt sich die Sicherung nicht öffnen – bewahre es gut auf.';

  @override
  String get fieldPassphrase => 'Passwort';

  @override
  String get fieldPassphraseRepeat => 'Passwort wiederholen';

  @override
  String get passphraseMismatch => 'Die Passwörter stimmen nicht überein.';

  @override
  String get importDoneTitle => 'Import abgeschlossen';

  @override
  String importImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count QSOs hinzugefügt.',
      one: '1 QSO hinzugefügt.',
    );
    return '$_temp0';
  }

  @override
  String importDuplicates(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count waren schon in deinem Log und wurden übersprungen.',
      one: '1 war schon in deinem Log und wurde übersprungen.',
    );
    return '$_temp0';
  }

  @override
  String importRejected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count Einträge hatten kein gültiges Rufzeichen, keine Zeit, kein Band oder keine Betriebsart.',
      one: '1 Eintrag hatte kein gültiges Rufzeichen, keine Zeit, kein Band oder keine Betriebsart.',
    );
    return '$_temp0';
  }

  @override
  String importWarnings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Die Datei hatte $count Formatprobleme, die umgangen wurden.',
      one: 'Die Datei hatte 1 Formatproblem, das umgangen wurde.',
    );
    return '$_temp0';
  }

  @override
  String importStation(String name) {
    return 'Importierte QSOs gehören zum Stationsstandort $name.';
  }

  @override
  String get importTooLarge =>
      'Diese Datei ist zu groß für den Import (maximal 64 MB).';

  @override
  String get settingsAppLock => 'App-Sperre';

  @override
  String get settingsAppLockHint =>
      'Beim Öffnen von Tideline nach Face ID, Fingerabdruck oder Geräte-PIN fragen.';

  @override
  String get appLockTitle => 'Tideline ist gesperrt';

  @override
  String get appLockUnlock => 'Entsperren';

  @override
  String get appLockReason => 'Entsperre dein Log';

  @override
  String get settingsReadingFont => 'Gut lesbare Schrift';

  @override
  String get settingsReadingFontHint =>
      'Atkinson Hyperlegible: deutlich unterscheidbare Zeichen wie 0 und O, 1, l und I.';

  @override
  String get actionCancel => 'Abbrechen';

  @override
  String get actionClose => 'Schließen';

  @override
  String get actionSave => 'Speichern';

  @override
  String get commandWipeEntry => 'Eingabe löschen';

  @override
  String get commandFocusCall => 'Zum Rufzeichen springen';

  @override
  String get commandToggleRates => 'Punkte und Raten ein- oder ausblenden';

  @override
  String get commandEndContest => 'Contest-Sitzung beenden';

  @override
  String get commandOpenContest => 'Contest-Modus öffnen';

  @override
  String get contestTitle => 'Contest-Modus';

  @override
  String get contestOpenAction => 'Contest-Modus';

  @override
  String contestBannerActive(String name) {
    return 'Contest-Sitzung läuft: $name';
  }

  @override
  String get contestBannerReturn => 'Zurück zum Contest';

  @override
  String get contestSetupTitle => 'Contest-Sitzung';

  @override
  String get contestSetupLoadFailed => 'Contests konnten nicht geladen werden';

  @override
  String get contestSetupLoadFailedBody =>
      'Dein normales Log funktioniert weiter. Starte Tideline neu und versuche es noch einmal.';

  @override
  String get contestSetupSessionRunning =>
      'Es läuft bereits eine Contest-Sitzung. Beende sie, bevor du eine neue startest.';

  @override
  String get contestSetupChooseContest => 'Contest';

  @override
  String get contestSearchLabel => 'Contests suchen';

  @override
  String get contestSearchEmpty => 'Kein Contest passt zu deiner Suche.';

  @override
  String get contestSetupChooseHint =>
      'Wähle einen Contest aus der Liste, um die Sitzung einzurichten.';

  @override
  String get contestBuiltin => 'Eingebaut';

  @override
  String get contestImported => 'Von dir importiert';

  @override
  String get contestSetupNeedStation =>
      'Für dieses Konto gibt es noch keinen Stationsstandort. Synchronisiere einmal, um deine Wavelog-Standorte zu laden, und versuche es dann erneut.';

  @override
  String get contestSetupStation => 'Station';

  @override
  String get contestSetupExchange => 'Mein Exchange';

  @override
  String get contestSetupExchangeHelp =>
      'Das sendest du an jede Station. Die Vorschläge stammen aus deinem Stationsstandort; bitte prüfen.';

  @override
  String get contestSetupRstAuto =>
      'Der Rapport wird automatisch gesendet: 59 bei Fonie, 599 bei CW und Digimodes.';

  @override
  String get contestSetupSerialAuto =>
      'Die laufende Nummer beginnt bei 1 und zählt mit jedem QSO hoch. Eine Nummer wird nie doppelt vergeben, auch nicht nach dem Löschen eines QSOs.';

  @override
  String get contestSetupCabrillo => 'Cabrillo-Kategorien';

  @override
  String get contestSetupCabrilloHelp =>
      'Diese Angaben stehen im Kopf des Cabrillo-Logs, das du an den Veranstalter sendest. Die Werte sind feste Begriffe des Cabrillo-Formats.';

  @override
  String get contestCatOperator => 'Betreiberkategorie';

  @override
  String get contestCatAssisted => 'Unterstützung';

  @override
  String get contestCatBand => 'Bandkategorie';

  @override
  String get contestCatMode => 'Betriebsartenkategorie';

  @override
  String get contestCatPower => 'Leistung';

  @override
  String get contestCatStation => 'Stationstyp';

  @override
  String get contestCatTransmitter => 'Sender';

  @override
  String get contestCatOverlay => 'Overlay';

  @override
  String get contestCatNotSet => 'Nicht gesetzt';

  @override
  String get contestStart => 'Sitzung starten';

  @override
  String get contestStartFailed =>
      'Die Sitzung konnte nicht gestartet werden. Es wurde nichts geändert. Versuche es noch einmal.';

  @override
  String get contestPastTitle => 'Frühere Sitzungen';

  @override
  String get contestPastEmpty => 'Noch keine Contest-Sitzungen.';

  @override
  String get contestStateActive => 'Läuft';

  @override
  String get contestStateEnded => 'Beendet';

  @override
  String get contestReopen => 'Wieder öffnen';

  @override
  String get contestSessionsAction => 'Sitzungen';

  @override
  String get contestMissingTitle => 'Contest-Regeln nicht gefunden';

  @override
  String get contestMissingBody =>
      'Die Regeln dieser Sitzung sind nicht mehr auf diesem Gerät. Deine QSOs sind sicher. Beende die Sitzung, um weiterzumachen.';

  @override
  String get contestEndTitle => 'Contest-Sitzung beenden?';

  @override
  String get contestEndBody =>
      'Deine QSOs bleiben im Log. Du kannst die Sitzung später aus der Sitzungsliste wieder öffnen.';

  @override
  String get contestKindRst => 'RST';

  @override
  String get contestKindSerial => 'Lfd. Nr.';

  @override
  String get contestKindCqZone => 'CQ-Zone';

  @override
  String get contestKindItuZone => 'ITU-Zone';

  @override
  String get contestKindGrid => 'Locator';

  @override
  String get contestKindState => 'Bundesstaat/Provinz';

  @override
  String get contestKindSection => 'Sektion';

  @override
  String get contestKindDok => 'DOK';

  @override
  String get contestKindPower => 'Leistung';

  @override
  String get contestKindName => 'Name';

  @override
  String get contestKindText => 'Exchange';

  @override
  String contestOptionalLabel(String label) {
    return '$label (optional)';
  }

  @override
  String contestErrorMissing(String label) {
    return '$label fehlt.';
  }

  @override
  String contestErrorInvalid(String label) {
    return '$label ist ungültig.';
  }

  @override
  String contestErrorOutOfRange(String label) {
    return '$label liegt außerhalb des Bereichs.';
  }

  @override
  String get contestMultZone => 'Zone';

  @override
  String get contestMultItuZone => 'ITU-Zone';

  @override
  String get contestMultDxcc => 'Land';

  @override
  String get contestMultPrefix => 'Präfix';

  @override
  String get contestMultState => 'Bundesstaat/Provinz';

  @override
  String get contestMultDok => 'DOK';

  @override
  String contestHintDupe(String bands, String modes) {
    return 'Dupe: bereits gearbeitet auf $bands ($modes)';
  }

  @override
  String contestHintWorkedElsewhere(String bands, String modes) {
    return 'Bereits gearbeitet auf $bands ($modes); hier kein Dupe';
  }

  @override
  String contestHintNewMultiplier(String items) {
    return 'Neuer Multiplikator: $items';
  }

  @override
  String get contestHintOutOfContest =>
      'Außerhalb der Bänder oder Betriebsarten dieses Contests: 0 Punkte.';

  @override
  String get contestHintLogWorked =>
      'Im Log: schon auf diesem Band und in dieser Betriebsart gearbeitet';

  @override
  String get contestHintLogNewBand => 'Im Log: schon gearbeitet, neues Band';

  @override
  String get contestHintLogNewMode =>
      'Im Log: schon gearbeitet, neue Betriebsart';

  @override
  String get contestHintLogNewSlot =>
      'Im Log: schon gearbeitet, neue Kombination aus Band und Betriebsart';

  @override
  String get contestHintInScp =>
      'Rufzeichen steht in der Super-Check-Partial-Liste';

  @override
  String get contestHintScpMatches => 'Super Check:';

  @override
  String get contestHintNPlusOne => 'Meintest du:';

  @override
  String contestUseCall(String call) {
    return '$call übernehmen';
  }

  @override
  String contestSentSummary(String items) {
    return 'Gesendet: $items';
  }

  @override
  String get contestSentNothing => 'Nichts zu senden';

  @override
  String contestLoggedAnnouncement(String call, int serial, String dupe) {
    String _temp0 = intl.Intl.selectLogic(dupe, {'yes': ', Dupe', 'other': ''});
    return '$call geloggt, laufende Nummer $serial$_temp0';
  }

  @override
  String contestLoggedAnnouncementNoSerial(String call, String dupe) {
    String _temp0 = intl.Intl.selectLogic(dupe, {'yes': ', Dupe', 'other': ''});
    return '$call geloggt$_temp0';
  }

  @override
  String get contestSaveFailed =>
      'Das QSO konnte nicht gespeichert werden. Deine Eingabe ist noch da. Versuche es noch einmal.';

  @override
  String get contestRecentTitle => 'Letzte QSOs';

  @override
  String get contestRecentEmpty =>
      'Noch keine QSOs in dieser Sitzung. Gib ein Rufzeichen und den Exchange ein und drücke Enter.';

  @override
  String contestRowExchange(String sent, String rcvd) {
    return '$sent → $rcvd';
  }

  @override
  String get contestRowEditHint => 'QSO bearbeiten';

  @override
  String get contestFlagDupe => 'Dupe';

  @override
  String get contestFlagMult => 'Mult';

  @override
  String get contestFlagOut => 'Außer';

  @override
  String contestPoints(int points) {
    String _temp0 = intl.Intl.pluralLogic(
      points,
      locale: localeName,
      other: '$points Pkt.',
      one: '1 Pkt.',
    );
    return '$_temp0';
  }

  @override
  String get contestEditTitle => 'QSO bearbeiten';

  @override
  String contestEditSent(String items) {
    return 'Gesendet (nicht änderbar): $items';
  }

  @override
  String get contestDeleteTitle => 'Dieses QSO löschen?';

  @override
  String contestDeleteBody(String call) {
    return '$call wird von diesem Gerät und aus der Contest-Wertung entfernt.';
  }

  @override
  String contestDeleteBodySerial(String call, String serial) {
    return '$call wird von diesem Gerät und aus der Contest-Wertung entfernt. Die laufende Nummer $serial bleibt vergeben und wird nie wieder verwendet.';
  }

  @override
  String get contestPanelTitle => 'Punkte und Raten';

  @override
  String contestPanelSummary(int qsos, int points, int score) {
    return '$qsos QSOs · $points Punkte · Schätzung $score';
  }

  @override
  String get contestQsos => 'QSOs';

  @override
  String get contestPointsLabel => 'Punkte';

  @override
  String get contestMultipliers => 'Multiplikatoren';

  @override
  String get contestDupes => 'Dupes';

  @override
  String get contestScoreEstimate => 'Beanspruchte Punktzahl (Schätzung)';

  @override
  String get contestScoreEstimateNote =>
      'Eine Schätzung für dich selbst. Das Ergebnis legt die Logprüfung des Veranstalters fest.';

  @override
  String get contestRatesTitle => 'Raten';

  @override
  String get contestRate10Min => 'Letzte 10 Minuten';

  @override
  String get contestRate60Min => 'Letzte 60 Minuten';

  @override
  String get contestRateLast10 => 'Letzte 10 QSOs';

  @override
  String get contestRateLast100 => 'Letzte 100 QSOs';

  @override
  String get contestRateBest => 'Beste 60 Minuten';

  @override
  String contestRatePerHour(int rate) {
    return '$rate/h';
  }

  @override
  String contestRateBestValue(int count, String time, String utc) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count QSOs',
      one: '1 QSO',
    );
    return '$_temp0 ab $time $utc';
  }

  @override
  String get contestBandsTitle => 'Nach Band';

  @override
  String get contestBandsEmpty => 'Noch keine QSOs mit Wertung.';

  @override
  String contestLabelValue(String label, String value) {
    return '$label: $value';
  }

  @override
  String get commandExportCabrillo => 'Cabrillo-Log exportieren';

  @override
  String get contestMoreActions => 'Weitere Aktionen';

  @override
  String get contestCatTime => 'Zeitkategorie';

  @override
  String get cabrilloExportTitle => 'Cabrillo-Log exportieren';

  @override
  String get cabrilloIssuesIntro =>
      'Das Log hat Probleme, die Auswertungen beanstanden können:';

  @override
  String get cabrilloExportAnyway => 'Trotzdem exportieren';

  @override
  String get cabrilloExportDone => 'Cabrillo-Log gespeichert.';

  @override
  String get cabrilloExportFailed =>
      'Das Cabrillo-Log konnte nicht erstellt oder gespeichert werden.';

  @override
  String get cabrilloUnavailableBanner =>
      'Cabrillo-Export nicht verfügbar: Für diesen Contest ist kein Cabrillo-Name hinterlegt.';

  @override
  String cabrilloUnavailableBody(String contest) {
    return '$contest hat in der Definition keinen Cabrillo-Namen, daher kann kein Log erzeugt werden, das ein Contest-Roboter akzeptiert. Trage in der Definition einen Cabrillo-Namen ein oder nutze den ADIF-Export in den Einstellungen.';
  }

  @override
  String get cabrilloIssueMissingContest =>
      'Der Contest hat keinen Cabrillo-Namen.';

  @override
  String get cabrilloIssueMissingCallsign => 'Die Station hat kein Rufzeichen.';

  @override
  String get cabrilloIssueEmptyLog => 'Die Sitzung hat keine QSOs.';

  @override
  String get cabrilloIssueExchangeCountMismatch =>
      'Der Austausch hat eine andere Anzahl an Angaben als das erste QSO.';

  @override
  String get cabrilloIssueMissingFrequency =>
      'Frequenz oder Band lassen sich nicht bestimmen.';

  @override
  String get cabrilloIssueMissingQsoCall => 'Ein Rufzeichen ist leer.';

  @override
  String get cabrilloIssueTokenContainsWhitespace =>
      'Ein Austauschwert enthält ein Leerzeichen; er wird mit Bindestrich geschrieben.';

  @override
  String get cabrilloIssueEmptyExchangeToken =>
      'Ein Exchange-Wert ist leer; an seiner Stelle wird ein Bindestrich geschrieben.';

  @override
  String get cabrilloIssueTooManyAddressLines =>
      'Es gibt mehr als 6 Adresszeilen; die übrigen entfallen.';

  @override
  String get cabrilloIssueAddressLineTooLong =>
      'Eine Adresszeile ist länger als 45 Zeichen und wird gekürzt.';

  @override
  String get cabrilloIssueInvalidTransmitterId =>
      'Die Sendernummer muss 0 oder 1 sein.';

  @override
  String cabrilloIssueQsos(int count, int first) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count QSOs, das erste ist Nr. $first',
      one: 'QSO Nr. $first',
    );
    return '$_temp0';
  }

  @override
  String get contestSyncLocal => 'Nur auf diesem Gerät';

  @override
  String get contestSyncPending => 'Wartet auf Upload zu Wavelog';

  @override
  String get contestSyncVerifying => 'Wird auf Wavelog geprüft';

  @override
  String get contestSyncCreated => 'Auf Wavelog';

  @override
  String contestSyncWithReason(String state, String reason) {
    return '$state: $reason';
  }

  @override
  String contestSyncStatusLabel(String status) {
    return 'Wavelog: $status';
  }

  @override
  String get contestSyncProblemNotActive =>
      'Der Contest ist auf deinem Wavelog-Server nicht aktiviert.';

  @override
  String get contestSyncProblemMissingPermission =>
      'Dem API-Token fehlt die Berechtigung contest:write.';

  @override
  String get contestSyncProblemServerTooOld =>
      'Dein Wavelog-Server ist älter als Version 3.2 und kennt keine Contest-Sitzungen.';

  @override
  String get contestSyncProblemDeletedOnServer =>
      'Die Sitzung wurde in Wavelog gelöscht.';

  @override
  String get contestSyncProblemNoAdifName =>
      'Dieser Contest hat keinen ADIF-Contest-Namen.';

  @override
  String get contestSyncProblemStationUnknown =>
      'Der Stationsstandort ist auf dem Wavelog-Server nicht bekannt.';

  @override
  String get contestSyncProblemRejected => 'Wavelog hat die Sitzung abgelehnt.';

  @override
  String get contestSyncProblemUnknown => 'Wavelog hat ein Problem gemeldet.';

  @override
  String get workedHintNewCall => 'Neues Rufzeichen: noch nicht im Log';

  @override
  String get workedHintNewBand =>
      'Schon gearbeitet, aber noch nicht auf diesem Band';

  @override
  String get workedHintNewMode =>
      'Schon gearbeitet, aber noch nicht in dieser Betriebsart';

  @override
  String get workedHintNewSlot =>
      'Schon gearbeitet, aber nicht mit dieser Kombination aus Band und Betriebsart';

  @override
  String get workedHintWorked =>
      'Schon auf diesem Band und in dieser Betriebsart gearbeitet';

  @override
  String workedHintDetails(String date, String bands) {
    return 'erstes QSO $date, Bänder $bands';
  }

  @override
  String get settingsWorkedBefore => 'Index „Schon gearbeitet“';

  @override
  String get actionRebuildWorkedBefore =>
      'Index „Schon gearbeitet“ neu aufbauen';

  @override
  String get rebuildWorkedBeforeHint =>
      'Baut den Index aus deinem Log neu auf. QSOs von deinem Wavelog-Server kommen bei der nächsten Synchronisierung wieder hinzu.';

  @override
  String get rebuildWorkedBeforeConfirmTitle => 'Index neu aufbauen?';

  @override
  String get rebuildWorkedBeforeConfirmBody =>
      'Dein Log bleibt unverändert. Hinweise zu Stationen, die du nur auf anderen Geräten oder in Wavelog gearbeitet hast, fehlen, bis die nächste Synchronisierung sie wieder geladen hat.';

  @override
  String get actionRebuild => 'Neu aufbauen';

  @override
  String get rebuildWorkedBeforeProgress => 'Index wird neu aufgebaut …';

  @override
  String get rebuildWorkedBeforeDone =>
      'Index neu aufgebaut. Die nächste Synchronisierung ergänzt die QSOs von deinem Wavelog-Server.';

  @override
  String get rebuildWorkedBeforeFailed =>
      'Der Index konnte nicht neu aufgebaut werden.';

  @override
  String get settingsScp => 'Super Check Partial';

  @override
  String get scpHint =>
      'Rufzeichen-Vorschläge beim Loggen eines Contests. Die Liste gehört nicht zu Tideline: Du lädst sie selbst herunter.';

  @override
  String get scpNone => 'Keine Liste installiert';

  @override
  String scpPackSummary(int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Rufzeichen',
      one: '1 Rufzeichen',
    );
    return '$_temp0 · installiert am $date';
  }

  @override
  String scpSource(String source) {
    return 'Quelle: $source';
  }

  @override
  String get scpSourceFile => 'eine von dir importierte Datei';

  @override
  String get scpUrlLabel => 'Download-Adresse (https)';

  @override
  String get scpUrlHelper =>
      'Tideline ruft diese Adresse nur ab, wenn du auf Herunterladen tippst, und sendet nichts über dich.';

  @override
  String get actionDownload => 'Herunterladen';

  @override
  String get actionImportFile => 'Datei importieren';

  @override
  String get actionRemove => 'Entfernen';

  @override
  String get scpDownloading => 'Liste wird heruntergeladen …';

  @override
  String scpDownloadingSize(int kib) {
    return 'Liste wird heruntergeladen … $kib KiB';
  }

  @override
  String scpInstalled(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Rufzeichen',
      one: '1 Rufzeichen',
    );
    return 'Liste installiert: $_temp0.';
  }

  @override
  String get scpRemoveTitle => 'Liste entfernen?';

  @override
  String get scpRemoveBody =>
      'Rufzeichen-Vorschläge entfallen, bis du wieder eine Liste installierst.';

  @override
  String get scpRemoved => 'Liste entfernt.';

  @override
  String get scpErrorInsecureUrl => 'Es sind nur https-Adressen erlaubt.';

  @override
  String get scpErrorInvalidUrl =>
      'Das ist keine brauchbare Adresse. Sie darf keinen Benutzernamen, kein Passwort, keine Abfrage (?…) und kein Fragment (#…) enthalten.';

  @override
  String get scpErrorNetwork =>
      'Der Server ist nicht erreichbar. Prüfe deine Verbindung und die Adresse.';

  @override
  String get scpErrorTimeout => 'Der Server hat zu lange nicht geantwortet.';

  @override
  String get scpErrorCertificate =>
      'Dem Zertifikat des Servers wird nicht vertraut. Es wurde nichts heruntergeladen.';

  @override
  String get scpErrorTooLarge =>
      'Die Datei ist größer als 8 MiB. Sie wurde nicht gespeichert.';

  @override
  String scpErrorStatus(int code) {
    return 'Der Server hat mit dem HTTP-Status $code geantwortet.';
  }

  @override
  String get scpErrorInvalidFile =>
      'Das ist keine MASTER.SCP-Datei (ein Rufzeichen pro Zeile).';

  @override
  String get scpErrorUnreadable => 'Die Datei konnte nicht gelesen werden.';

  @override
  String get settingsContestDefinitions => 'Contest-Definitionen';

  @override
  String get contestDefsHint =>
      'Die Regeln jedes Contests sind Datendateien. Mitgelieferte Definitionen sind immer da; du kannst eigene hinzufügen.';

  @override
  String get contestDefBuiltin => 'Mitgeliefert';

  @override
  String get contestDefUser => 'Von dir importiert';

  @override
  String contestDefVersion(int version) {
    return 'Version $version';
  }

  @override
  String get actionImportDefinition => 'Definition importieren';

  @override
  String get importDefinitionHint => 'Eine JSON-Datei mit bis zu 256 KiB.';

  @override
  String contestDefImported(String name) {
    return '„$name“ importiert.';
  }

  @override
  String contestDefReplaced(String name) {
    return '„$name“ aktualisiert.';
  }

  @override
  String get contestDefRejectedTitle => 'Definition nicht importiert';

  @override
  String contestDefTechnical(String path) {
    return 'Technische Angabe: $path';
  }

  @override
  String get contestDefFileTooLarge => 'Die Datei ist größer als 256 KiB.';

  @override
  String get contestDefNotText => 'Die Datei ist kein gültiger UTF-8-Text.';

  @override
  String get contestDefUnreadable => 'Die Datei konnte nicht gelesen werden.';

  @override
  String get contestDefIdClash =>
      'Diese ID gehört zu einem mitgelieferten Contest. Wähle in der Datei eine andere ID.';

  @override
  String actionDeleteDefinition(String name) {
    return 'Definition $name löschen';
  }

  @override
  String contestDefDeleteTitle(String name) {
    return '„$name“ löschen?';
  }

  @override
  String get contestDefDeleteBody =>
      'Es wird nur die Definition entfernt. Deine QSOs bleiben unberührt.';

  @override
  String contestDefDeleted(String name) {
    return '„$name“ gelöscht.';
  }

  @override
  String get contestDefInUse =>
      'Eine Contest-Sitzung in deinem Log verwendet diese Definition, sie kann daher nicht gelöscht werden.';

  @override
  String get contestDefBuiltinNoDelete =>
      'Mitgelieferte Definitionen können nicht gelöscht werden.';

  @override
  String get contestDefNotFound => 'Diese Definition gibt es nicht mehr.';

  @override
  String get contestDefErrorTooLarge =>
      'Die Definition ist größer als 256 KiB.';

  @override
  String get contestDefErrorMalformedJson =>
      'Die Datei ist kein gültiges JSON.';

  @override
  String get contestDefErrorWrongType => 'Ein Wert hat den falschen Typ.';

  @override
  String get contestDefErrorUnknownKey =>
      'Die Datei enthält eine Einstellung, die Tideline nicht kennt.';

  @override
  String get contestDefErrorMissingKey => 'Eine erforderliche Angabe fehlt.';

  @override
  String get contestDefErrorUnsupportedSchema =>
      'Diese Schema-Version wird nicht unterstützt (nur Version 1).';

  @override
  String get contestDefErrorInvalidId =>
      'Die ID muss 1 bis 64 Zeichen lang sein: Kleinbuchstaben, Ziffern und Bindestriche.';

  @override
  String get contestDefErrorOutOfRange =>
      'Eine Zahl oder eine Textlänge liegt außerhalb des erlaubten Bereichs.';

  @override
  String get contestDefErrorTooLong => 'Ein Text ist zu lang.';

  @override
  String get contestDefErrorInvalidCharacters =>
      'Ein Text enthält Steuerzeichen.';

  @override
  String get contestDefErrorTooManyElements =>
      'Eine Liste hat zu viele Einträge.';

  @override
  String get contestDefErrorTooFewElements =>
      'Eine Liste hat zu wenige Einträge.';

  @override
  String get contestDefErrorUnknownBand =>
      'Ein Bandname ist kein bekanntes ADIF-Band.';

  @override
  String get contestDefErrorUnknownValue =>
      'Eine Einstellung hat einen Wert, den Tideline nicht kennt.';

  @override
  String get contestDefErrorLastRuleHasWhen =>
      'Die letzte Punkteregel muss für jedes QSO gelten und darf deshalb keine Bedingung haben.';

  @override
  String get contestDefErrorVariantPredicateNotMine =>
      'Eine Variante des Austauschs darf nur von deiner eigenen Station abhängen.';

  @override
  String get contestDefErrorElementPredicateNotTheirs =>
      'Ein empfangenes Austauschelement darf nur von der Gegenstation abhängen.';

  @override
  String get contestDefErrorElementWhenNotAllowed =>
      'Ein gesendetes Austauschelement darf keine Bedingung haben.';

  @override
  String get contestDefErrorMultipleSerials =>
      'Eine Seite des Austauschs darf nur eine laufende Nummer enthalten.';

  @override
  String get contestDefErrorDuplicateField =>
      'Zwei Austauschelemente schreiben in dasselbe ADIF-Feld.';

  @override
  String get contestDefErrorDuplicateId =>
      'Zwei Multiplikatoren haben dieselbe ID.';

  @override
  String get contestDefErrorInvalidPlaceholder =>
      'Ein Standardwert verwendet einen unbekannten Platzhalter.';

  @override
  String get contestDefErrorInvalidValue =>
      'Ein Standardwert passt nicht zu seinem Austauschelement.';

  @override
  String get contestDefErrorDefaultNotAllowed =>
      'Ein Standardwert ist hier nicht erlaubt (empfangene Seite und laufende Nummern).';

  @override
  String get contestDefErrorInvalidMultiplierSource =>
      'Ein Multiplikator verwendet eine Quelle, die es nicht gibt oder die kein empfangener Austausch enthält.';

  @override
  String get contestDefErrorEmptyPredicate => 'Eine Bedingung ist leer.';

  @override
  String get contestDefErrorInvalidCombination =>
      'Die Wertungsart passt nicht zu den Multiplikatoren.';

  @override
  String get contestDefErrorDuplicateValue =>
      'Derselbe Wert ist doppelt aufgeführt.';

  @override
  String get settingsReferencePacks => 'Referenzlisten (SOTA, POTA, WWFF)';

  @override
  String get packsHint =>
      'Offline-Listen von Gipfeln, Parks und Flora-und-Fauna-Gebieten für Aktivierungen. Sie gehören nicht zu Tideline: Du lädst jede Liste selbst herunter, direkt von der offiziellen Quelle. Jede Liste ist 10 bis 25 MB groß.';

  @override
  String get packNameSota => 'Summits on the Air (SOTA)';

  @override
  String get packNamePota => 'Parks on the Air (POTA)';

  @override
  String get packNameWwff => 'World Wide Flora & Fauna (WWFF)';

  @override
  String get packNone => 'Keine Liste installiert';

  @override
  String packSummary(int count, String version, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Referenzen',
      one: '1 Referenz',
    );
    return '$_temp0 · Liste vom $version · geladen am $date';
  }

  @override
  String get actionUpdate => 'Aktualisieren';

  @override
  String get packDownloading => 'Wird heruntergeladen …';

  @override
  String packDownloadingSize(String size) {
    return 'Wird heruntergeladen … $size';
  }

  @override
  String get packInstalling => 'Liste wird gelesen und gespeichert …';

  @override
  String packInstalled(String program, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Referenzen',
      one: '1 Referenz',
    );
    return '$program-Liste installiert: $_temp0.';
  }

  @override
  String get packCancelled =>
      'Download abgebrochen. Die installierte Liste wurde nicht verändert.';

  @override
  String packRemoveTitle(String program) {
    return '$program-Liste entfernen?';
  }

  @override
  String packRemoveBody(String program) {
    return 'Die Suche nach $program-Referenzen ist dann nicht mehr möglich, bis Du wieder eine Liste installierst. Deine Aktivierungen und QSOs bleiben unverändert.';
  }

  @override
  String packRemoved(String program) {
    return '$program-Liste entfernt.';
  }

  @override
  String get packErrorTooLarge =>
      'Die Datei ist größer als erlaubt. Sie wurde nicht gespeichert.';

  @override
  String packErrorInvalidFile(String program) {
    return 'Das ist keine $program-Liste. Prüfe die Adresse.';
  }

  @override
  String get packErrorStorage =>
      'Die Datei konnte auf diesem Gerät nicht gespeichert werden. Prüfe den freien Speicher.';

  @override
  String get activationOpenAction => 'Aktivierung starten';

  @override
  String get activationSetupTitle => 'Aktivierung starten';

  @override
  String get activationProgramLabel => 'Programm';

  @override
  String get activationReferenceLabelSota => 'Gipfelreferenz';

  @override
  String get activationReferenceLabelPota => 'Parkreferenz';

  @override
  String get activationReferenceLabelWwff => 'Gebietsreferenz';

  @override
  String activationReferenceExample(String example) {
    return 'Beispiel: $example';
  }

  @override
  String activationReferenceInvalid(String program, String example) {
    return 'Das ist keine $program-Referenz. Beispiel: $example';
  }

  @override
  String activationReferenceKnown(String program, String name) {
    return 'In Deiner $program-Liste: $name';
  }

  @override
  String activationReferenceUnknown(String program) {
    return 'Nicht in Deiner $program-Liste. Du kannst sie trotzdem verwenden.';
  }

  @override
  String activationNoPack(String program) {
    return 'Es ist keine $program-Liste installiert, daher kann nicht nach Referenzen gesucht werden. Du kannst trotzdem eine eintippen. Lade die Liste in den Einstellungen herunter.';
  }

  @override
  String get activationOpenSettings => 'Einstellungen öffnen';

  @override
  String get activationMatches => 'Treffer';

  @override
  String activationNearby(String grid) {
    return 'Am nächsten zu $grid';
  }

  @override
  String get activationNoMatches => 'Nichts gefunden.';

  @override
  String unitKilometers(int km) {
    return '$km km';
  }

  @override
  String get activationGridLabel => 'Dein Locator an der Referenz';

  @override
  String get activationGridFromReference =>
      'Aus der Position der Referenz übernommen.';

  @override
  String get activationGridFromStation =>
      'Aus dem Wavelog-Standort übernommen.';

  @override
  String get activationGridNone =>
      'Kein Locator bekannt. Du kannst das Feld leer lassen.';

  @override
  String activationLocationCarries(String reference) {
    return 'Dieser Wavelog-Standort trägt $reference, deine QSOs erreichen Wavelog also mit dieser Referenz.';
  }

  @override
  String activationLocationSuggest(String name, String reference) {
    return 'Der Wavelog-Standort „$name“ trägt $reference.';
  }

  @override
  String get activationUseLocation => 'Diesen Standort verwenden';

  @override
  String activationLocationNone(String reference) {
    return 'Kein Wavelog-Standort trägt $reference. Wavelog legt jedes QSO unter der Referenz seines Standorts ab und ignoriert die Referenz im Upload. Tideline behält $reference bei jedem QSO und in ADIF-Exporten. Damit sie auch in Wavelog steht, lege dort einen Standort mit dieser Referenz an und wähle ihn hier.';
  }

  @override
  String get activationErrorNoStation =>
      'Noch kein Wavelog-Standort. Verbinde Dich einmal mit Wavelog, um Deine Standorte zu laden.';

  @override
  String activationRunning(String reference) {
    return '$reference läuft noch. Eine neue Aktivierung beendet sie.';
  }

  @override
  String get activationStart => 'Aktivierung starten';

  @override
  String get activationStartFailed =>
      'Die Aktivierung konnte nicht gestartet werden. Versuche es erneut.';

  @override
  String activationBannerTitle(String program, String reference) {
    return '$program $reference';
  }

  @override
  String activationBannerTitleNamed(
    String program,
    String reference,
    String name,
  ) {
    return '$program $reference · $name';
  }

  @override
  String activationProgress(int counted, int required, int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: 'noch $remaining',
      one: 'noch 1',
    );
    return '$counted von $required QSOs · $_temp0';
  }

  @override
  String activationProgressValid(int counted, int required) {
    return 'Gültige Aktivierung: $counted QSOs (nötig: $required)';
  }

  @override
  String get activationWindowDay => 'Gezählt pro UTC-Tag.';

  @override
  String get activationWindowSession => 'Gezählt über die ganze Aktivierung.';

  @override
  String activationDuplicates(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count QSOs',
      one: '1 QSO',
    );
    return '$_temp0 nicht gezählt (gleiches Rufzeichen, Band und Betriebsart).';
  }

  @override
  String get activationEnd => 'Aktivierung beenden';

  @override
  String activationEndTitle(String reference) {
    return '$reference beenden?';
  }

  @override
  String get activationEndBody =>
      'Neue QSOs werden dieser Aktivierung nicht mehr zugeordnet. Geloggte QSOs bleiben unverändert.';

  @override
  String get activationEnded => 'Aktivierung beendet.';

  @override
  String get activationTheirReferenceSota => 'Ihr Gipfel (S2S)';

  @override
  String get activationTheirReferencePota => 'Ihr Park (P2P)';

  @override
  String get activationTheirReferenceWwff => 'Ihr Gebiet (WWFF)';

  @override
  String get activationIssueTheirReference => 'Das ist keine gültige Referenz.';

  @override
  String get commandStartActivation => 'Aktivierung starten';

  @override
  String get commandEndActivation => 'Laufende Aktivierung beenden';

  @override
  String get settingsAppearanceAndLanguage => 'Darstellung und Sprache';

  @override
  String get settingsAppearanceHint => 'Farbschema, Text und Sprache';

  @override
  String get settingsReferenceData => 'Referenzdaten';

  @override
  String get settingsReferenceDataHint =>
      'Listen und Indizes zum Herunterladen';

  @override
  String get settingsSecurityAndBackup => 'Sicherheit und Backup';

  @override
  String get settingsSecurityAndBackupHint => 'App-Sperre, ADIF und Backup';

  @override
  String get settingsAccounts => 'Wavelog-Konten';

  @override
  String get accountsHint => 'Server, Token und das Konto, in das du loggst';

  @override
  String get accountsInUse => 'Zum Loggen in Verwendung';

  @override
  String accountsPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count QSOs warten',
      one: '1 QSO wartet',
      zero: 'Nichts wartet',
    );
    return '$_temp0';
  }

  @override
  String get accountsAdd => 'Konto hinzufügen';

  @override
  String get accountsUseForLogging => 'Zum Loggen verwenden';

  @override
  String get accountsRename => 'Umbenennen';

  @override
  String get accountsRenameTitle => 'Dieses Konto umbenennen';

  @override
  String get accountsSwitch => 'Konto wechseln';

  @override
  String get accountsManage => 'Konten verwalten';

  @override
  String accountsSwitchedTo(String name) {
    return 'Es wird in $name geloggt';
  }

  @override
  String get accountsBlockedContest =>
      'Eine Contest-Sitzung läuft. Beende sie, bevor du das Konto wechselst.';

  @override
  String get accountsBlockedActivation =>
      'Eine Aktivierung läuft. Beende sie, bevor du das Konto wechselst.';

  @override
  String get accountsPendingTitle => 'Wartend, pro Konto';

  @override
  String get accountsExportRemove => 'Log exportieren, dann entfernen';

  @override
  String get accountsAddTitle => 'Wavelog-Konto hinzufügen';

  @override
  String accountsActsOn(String name) {
    return 'Konto: $name';
  }

  @override
  String get commandGoBack => 'Zurück';

  @override
  String get menuGo => 'Gehe zu';

  @override
  String get menuOperate => 'Betrieb';

  @override
  String get menuHelp => 'Hilfe';

  @override
  String get menuWindow => 'Fenster';

  @override
  String get actionCopyCallsign => 'Rufzeichen kopieren';

  @override
  String get actionOpenQso => 'QSO öffnen';

  @override
  String callsignCopied(String call) {
    return '$call kopiert';
  }

  @override
  String get callsignFillIn => 'Übernehmen';

  @override
  String get callsignFillInLabel =>
      'Name und Locator aus früheren Kontakten übernehmen';

  @override
  String callsignKnown(String details) {
    return 'Aus früheren Kontakten bekannt: $details';
  }

  @override
  String get callsignNoteTooltip => 'Rufzeichen-Notiz';

  @override
  String get callsignNoteTooltipHas => 'Rufzeichen-Notiz (vorhanden)';

  @override
  String callsignNoteTitle(String call) {
    return 'Notiz für $call';
  }

  @override
  String get callsignNoteHint =>
      'Nur auf diesem Gerät (und in deinem Backup). Wird nicht an Wavelog gesendet.';

  @override
  String get callsignNoteField => 'Notiz';

  @override
  String get callsignNoteDelete => 'Notiz löschen';

  @override
  String callsignNoteLine(String text) {
    return 'Notiz: $text';
  }

  @override
  String get callsignDirectoryTitle => 'Rufzeichen-Verzeichnis';

  @override
  String get callsignDirectoryBody =>
      'Namen, Orte und Locator aus deinem QSO-Verlauf, auf diesem Gerät gespeichert, damit sie offline da sind. Es gehört zum Index „Schon gearbeitet“ und wird mit ihm neu aufgebaut.';

  @override
  String callsignDirectoryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Stationen',
      one: '1 Station',
      zero: 'Noch keine Stationen',
    );
    return '$_temp0';
  }

  @override
  String get callsignBrowse => 'Rufzeichen und Notizen durchsuchen';

  @override
  String get callsignSearch => 'Rufzeichen, Name oder Ort suchen';

  @override
  String get callsignEmpty =>
      'Nichts gefunden. Stationen erscheinen hier, wenn du loggst und synchronisierst.';

  @override
  String get callsignHasNote => 'Hat eine Notiz';

  @override
  String callsignLastWorked(String date) {
    return 'Zuletzt gearbeitet am $date';
  }

  @override
  String callsignZones(String dxcc, String cq, String itu) {
    return 'DXCC $dxcc · CQ $cq · ITU $itu';
  }

  @override
  String get freeSpaceTitle => 'Speicher freigeben';

  @override
  String get freeSpaceEntry =>
      'Synchronisierte QSOs von diesem Gerät entfernen';

  @override
  String get freeSpaceEntryHint => 'Wavelog behält sie.';

  @override
  String get freeSpaceIntro =>
      'Das entfernt die Kopien auf diesem Gerät von QSOs, die Wavelog schon hat. Auf Wavelog wird nichts gelöscht. Tideline fragt zuerst Wavelog und behält alles, was es dort nicht findet. „Schon gearbeitet“-Hinweise und Stationsnamen bleiben.';

  @override
  String get freeSpaceScope => 'Welche QSOs';

  @override
  String get freeSpaceOlder1 => 'Älter als 1 Jahr';

  @override
  String get freeSpaceOlder2 => 'Älter als 2 Jahre';

  @override
  String get freeSpaceOlder5 => 'Älter als 5 Jahre';

  @override
  String get freeSpaceAll => 'Alle synchronisierten QSOs';

  @override
  String freeSpaceEligible(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count QSOs können entfernt werden',
      one: '1 QSO kann entfernt werden',
      zero: 'Keine QSOs können entfernt werden',
    );
    return '$_temp0';
  }

  @override
  String get freeSpaceStaying => 'Bleiben auf diesem Gerät';

  @override
  String freeSpaceBlockedNotSynced(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count QSOs sind noch nicht in Wavelog',
      one: '1 QSO ist noch nicht in Wavelog',
    );
    return '$_temp0';
  }

  @override
  String freeSpaceBlockedChanged(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count QSOs wurden nach dem Senden geändert',
      one: '1 QSO wurde nach dem Senden geändert',
    );
    return '$_temp0';
  }

  @override
  String freeSpaceBlockedContest(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count QSOs gehören zu Contest-Sitzungen',
      one: '1 QSO gehört zu einer Contest-Sitzung',
    );
    return '$_temp0';
  }

  @override
  String freeSpaceBlockedActivation(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count QSOs gehören zu Aktivierungen',
      one: '1 QSO gehört zu einer Aktivierung',
    );
    return '$_temp0';
  }

  @override
  String get freeSpaceCheck => 'Bei Wavelog prüfen';

  @override
  String get freeSpaceChecking => 'Wavelog wird gefragt …';

  @override
  String freeSpaceConfirmedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Wavelog hat $count davon',
      one: 'Wavelog hat 1 davon',
      zero: 'Wavelog hat keines davon',
    );
    return '$_temp0';
  }

  @override
  String freeSpaceMissingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wurden auf Wavelog nicht gefunden und bleiben',
      one: '1 wurde auf Wavelog nicht gefunden und bleibt',
    );
    return '$_temp0';
  }

  @override
  String get freeSpaceOffline =>
      'Wavelog war nicht erreichbar. Es wurde nichts entfernt.';

  @override
  String get freeSpaceUnauthorized =>
      'Der Token funktioniert nicht mehr. Gib zuerst einen neuen Token ein. Es wurde nichts entfernt.';

  @override
  String get freeSpaceServerProblem =>
      'Wavelog hat mit einem Fehler geantwortet. Es wurde nichts entfernt.';

  @override
  String get freeSpaceTooMany =>
      'In diesem Zeitraum sind zu viele QSOs, um sie auf einmal zu prüfen. Wähle einen kürzeren Zeitraum.';

  @override
  String freeSpaceRemoveButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count QSOs von diesem Gerät entfernen',
      one: '1 QSO von diesem Gerät entfernen',
    );
    return '$_temp0';
  }

  @override
  String get freeSpaceConfirmTitle => 'Von diesem Gerät entfernen?';

  @override
  String freeSpaceConfirmBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count QSOs werden',
      one: '1 QSO wird',
    );
    return '$_temp0 von diesem Gerät entfernt. Sie bleiben auf Wavelog. Du kannst sie vorher als ADIF-Datei sichern.';
  }

  @override
  String get freeSpaceExportRemove => 'Exportieren, dann entfernen';

  @override
  String get freeSpaceRemoveOnly => 'Entfernen';

  @override
  String freeSpaceDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count QSOs von diesem Gerät entfernt. Sie sind noch auf Wavelog.',
      one: '1 QSO von diesem Gerät entfernt. Es ist noch auf Wavelog.',
    );
    return '$_temp0';
  }

  @override
  String freeSpaceSoFar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Bisher $count QSOs entfernt',
      one: 'Bisher 1 QSO entfernt',
      zero: 'Bisher nichts entfernt',
    );
    return '$_temp0';
  }

  @override
  String get qsoRemoveFromDevice => 'Von diesem Gerät entfernen';

  @override
  String get qsoRemoveFromDeviceHint =>
      'Wavelog behält es. Tideline prüft das zuerst.';

  @override
  String get qsoNotRemoved =>
      'Nicht entfernt: Wavelog konnte dieses QSO nicht bestätigen.';

  @override
  String journalEvictedLocally(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count QSOs von diesem Gerät entfernt (noch auf Wavelog)',
      one: '1 QSO von diesem Gerät entfernt (noch auf Wavelog)',
    );
    return '$_temp0';
  }
}
