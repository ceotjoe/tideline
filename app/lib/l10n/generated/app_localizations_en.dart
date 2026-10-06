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
  String get actionHideKeyboard => 'Hide keyboard';

  @override
  String get navCallsigns => 'Callsigns';

  @override
  String get navSync => 'Sync';

  @override
  String get navSettings => 'Settings';

  @override
  String get logEmptyTitle => 'No QSOs yet';

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
  String get commandGoToCallsigns => 'Go to callsigns';

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
  String get legacyDatabaseTitle =>
      'Your earlier log could not be carried over';

  @override
  String get legacyDatabaseBody =>
      'This version no longer encrypts the log with its own key, so the log of the earlier version can\'t be opened. Tideline started with an empty log. The old file is still on this device but is not used. QSOs that were already synced are still in your Wavelog logbook.';

  @override
  String get startupErrorTitle => 'Tideline couldn\'t start';

  @override
  String get startupErrorBody =>
      'Something went wrong while opening your log. Your QSOs have not been changed. Please restart the app; if this keeps happening, report it on GitHub.';

  @override
  String get shortcutsUnbound => 'Not assigned';

  @override
  String get shortcutsOr => 'or';

  @override
  String get onboardingWelcomeTitle => 'Welcome to Tideline';

  @override
  String get onboardingWelcomeBody =>
      'Tideline saves your QSOs on this device first, with or without a connection, and syncs them to your own Wavelog server whenever it can reach it. Your log is never sent anywhere else.';

  @override
  String get onboardingStart => 'Connect to Wavelog';

  @override
  String get onboardingTryDemo => 'Try the demo (no Wavelog needed)';

  @override
  String get onboardingDemoHint =>
      'The demo runs entirely on this device with a made-up station. Nothing is sent anywhere, and you can remove it later.';

  @override
  String get accountDemoLabel => 'Demo';

  @override
  String get accountDemoNote =>
      'Demo account: no server, nothing leaves this device';

  @override
  String onboardingStepOf(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get onboardingServerTitle => 'Your Wavelog server';

  @override
  String get onboardingServerBody =>
      'Enter the address you use to open Wavelog in your browser. Wavelog 3.1 or newer is needed.';

  @override
  String get fieldServerUrl => 'Server address';

  @override
  String get fieldServerUrlHint => 'https://log.example.org';

  @override
  String get fieldAccountLabel => 'Name for this account (optional)';

  @override
  String get fieldAccountLabelHint => 'For example Personal or Club station';

  @override
  String get onboardingAllowHttp =>
      'Allow an unencrypted connection (local network only)';

  @override
  String get onboardingAllowHttpWarning =>
      'Only for a server in your own network. Your token and QSOs travel without encryption. Never use this over the internet.';

  @override
  String get actionContinue => 'Continue';

  @override
  String get actionBack => 'Back';

  @override
  String get onboardingTokenTitle => 'API token';

  @override
  String get onboardingTokenBody =>
      'In Wavelog, open your user menu, choose API and create a new v2 token. Paste it here. It starts with wl2_ and is kept only in this device\'s secure storage.';

  @override
  String get fieldToken => 'API token';

  @override
  String get onboardingScopesRequired => 'Required permissions';

  @override
  String get onboardingScopesOptional => 'Optional permissions';

  @override
  String get scopeQsoWrite =>
      'qso:write – upload your QSOs and correct uploaded ones';

  @override
  String get scopeQsoRead =>
      'qso:read – check the server before sending again, so nothing is duplicated';

  @override
  String get scopeStationRead => 'station:read – list your station locations';

  @override
  String get scopeQsoDelete =>
      'qso:delete – also delete in Wavelog what you delete in Tideline';

  @override
  String get scopeContest =>
      'contest:read and contest:write – contest sessions in Wavelog (3.2 or newer)';

  @override
  String get scopeLookup =>
      'lookup:read – online callsign lookups while connected';

  @override
  String get scopeGranted => 'granted';

  @override
  String get scopeMissing => 'missing';

  @override
  String get actionCheckToken => 'Check connection';

  @override
  String get onboardingChecking => 'Checking your server…';

  @override
  String get onboardingStationTitle => 'Station location';

  @override
  String get onboardingStationBody =>
      'New QSOs are uploaded to this station location. You can choose another one for each QSO.';

  @override
  String get onboardingServerVersion31 =>
      'Connected to Wavelog 3.1. Contest sessions need Wavelog 3.2 or newer.';

  @override
  String get onboardingServerVersion32 => 'Connected to Wavelog 3.2 or newer.';

  @override
  String get onboardingNoStations =>
      'Your Wavelog account has no station locations yet. Create one in Wavelog under Station Setup, then check again.';

  @override
  String get onboardingFinish => 'Start logging';

  @override
  String get problemInvalidUrl =>
      'That doesn\'t look like a web address. Use the address you open Wavelog with, for example https://log.example.org.';

  @override
  String get problemInsecurePublicHttp =>
      'Unencrypted http:// is only possible for servers in your own network. Use https:// for servers on the internet.';

  @override
  String get problemHttpNeedsOptIn =>
      'This address uses unencrypted http://. Switch on “Allow an unencrypted connection” if the server is in your own network.';

  @override
  String get problemUnreachable =>
      'The server didn\'t answer. Check the address and your connection. You can also set Tideline up later.';

  @override
  String get problemNoApiV2 =>
      'This server answers, but not like Wavelog 3.1 or newer. Check the address, or update Wavelog.';

  @override
  String get problemTokenInvalid =>
      'Wavelog doesn\'t accept this token. Copy it again (it starts with wl2_) or create a new one.';

  @override
  String get problemTokenExpired =>
      'This token has expired. Create a new one in Wavelog.';

  @override
  String problemMissingScopes(Object scopes) {
    return 'This token is missing permissions Tideline needs: $scopes. Create a token that includes them.';
  }

  @override
  String get problemServerError =>
      'The server reported a problem. Please try again in a moment.';

  @override
  String get problemCertificateRejected =>
      'The connection isn\'t trusted, so nothing was sent. If this is your own server, check its certificate and try again.';

  @override
  String get certTitle => 'Unknown certificate';

  @override
  String get certBody =>
      'Your device doesn\'t trust this server\'s certificate. That is common for self-hosted servers. Only continue if the fingerprint below matches the one of your server. If it ever changes, Tideline will stop and ask you again.';

  @override
  String get certFingerprint => 'SHA-256 fingerprint';

  @override
  String certValidity(String from, String until) {
    return 'Valid from $from to $until';
  }

  @override
  String get certTrust => 'Trust this certificate';

  @override
  String get certCancel => 'Cancel';

  @override
  String get statusSynced => 'Synced';

  @override
  String get statusLocal => 'On device';

  @override
  String get statusQueued => 'Waiting';

  @override
  String get statusUploading => 'Uploading';

  @override
  String get statusVerifying => 'Checking';

  @override
  String get statusConflict => 'Needs decision';

  @override
  String get statusBlocked => 'Token problem';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get unitMhz => 'MHz';

  @override
  String get unitUtc => 'UTC';

  @override
  String get fieldCallsign => 'Callsign';

  @override
  String get fieldBand => 'Band';

  @override
  String get fieldMode => 'Mode';

  @override
  String get fieldFrequency => 'Frequency';

  @override
  String freqReadoutInBand(String mhz, String band) {
    return '$mhz MHz · $band';
  }

  @override
  String freqReadoutOutsideBands(String mhz) {
    return '$mhz MHz · outside amateur bands';
  }

  @override
  String freqReadoutInBandKhz(String khz, String band) {
    return '$khz kHz · $band';
  }

  @override
  String freqReadoutOutsideBandsKhz(String khz) {
    return '$khz kHz · outside amateur bands';
  }

  @override
  String get freqReadoutUnreadable =>
      'Not a frequency. Type MHz (14.205) or kHz (14205).';

  @override
  String get freqReadoutEmpty => 'Type MHz (14.205) or kHz (14205).';

  @override
  String freqReadoutSemanticsInBand(String mhz, String band) {
    return '$mhz megahertz, $band';
  }

  @override
  String freqReadoutSemanticsOutsideBands(String mhz) {
    return '$mhz megahertz, outside amateur bands';
  }

  @override
  String freqReadoutSemanticsInBandKhz(String khz, String band) {
    return '$khz kilohertz, $band';
  }

  @override
  String freqReadoutSemanticsOutsideBandsKhz(String khz) {
    return '$khz kilohertz, outside amateur bands';
  }

  @override
  String get fieldRstSent => 'RST sent';

  @override
  String get fieldRstRcvd => 'RST received';

  @override
  String get fieldName => 'Name';

  @override
  String get fieldGrid => 'Locator';

  @override
  String get fieldComment => 'Comment';

  @override
  String get fieldStation => 'Station location';

  @override
  String get fieldDateUtc => 'Date and time';

  @override
  String get fieldCountry => 'DXCC entity';

  @override
  String get issueInvalidCall =>
      'Enter a callsign, for example DL1ABC or EA8/DL1ABC/P.';

  @override
  String get issueMissingBand => 'Choose a band or enter a frequency.';

  @override
  String get issueMissingMode => 'Choose a mode.';

  @override
  String get issueInvalidFrequency =>
      'Enter the frequency in MHz (14.205) or kHz (14205).';

  @override
  String get issueFrequencyOutsideBand =>
      'This frequency is outside the selected band.';

  @override
  String get issueInvalidGrid =>
      'A locator has 4, 6 or 8 characters, like JO40 or JO40hd.';

  @override
  String get issueNoStation =>
      'Saved. Choose a station location so this QSO can be uploaded.';

  @override
  String get issueTimeInFuture =>
      'Saved, but the time is in the future. Check your device clock.';

  @override
  String qsoLoggedAnnouncement(String call) {
    return 'QSO with $call logged.';
  }

  @override
  String timeNow(String time) {
    return 'Now: $time';
  }

  @override
  String timeManual(String time) {
    return 'Set: $time';
  }

  @override
  String get actionChangeTime => 'Change time';

  @override
  String get actionUseNow => 'Use current time';

  @override
  String dxccSummary(String name, String continent, int cq, int itu) {
    return '$name · $continent · CQ $cq · ITU $itu';
  }

  @override
  String workedBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'worked $count times before',
      one: 'worked once before',
    );
    return '$_temp0';
  }

  @override
  String get explainSynced => 'This QSO is safely in your Wavelog.';

  @override
  String get explainLocal =>
      'Saved on this device only. Choose a station location so it can be uploaded.';

  @override
  String get explainQueued =>
      'Saved on this device and waiting for the next sync.';

  @override
  String get explainUploading => 'Being sent to Wavelog right now.';

  @override
  String get explainVerifying =>
      'The last attempt didn\'t finish cleanly. Tideline checks your Wavelog before trying again, so the QSO is never duplicated.';

  @override
  String get explainConflict => 'This QSO needs your decision.';

  @override
  String get explainRejected =>
      'Wavelog didn\'t accept this QSO. Correct it and it will be sent again.';

  @override
  String get explainBlocked =>
      'Waiting until the account\'s token works again. Nothing is lost.';

  @override
  String get problemSyncNetwork =>
      'Your Wavelog wasn\'t reachable; Tideline will try again.';

  @override
  String get problemSyncRateLimited =>
      'Your Wavelog asked Tideline to slow down; it will continue automatically.';

  @override
  String get problemSyncServerError =>
      'Your Wavelog reported an internal error.';

  @override
  String get problemSyncInvalidData =>
      'Wavelog found a problem with the QSO\'s data.';

  @override
  String get problemSyncStationNotAllowed =>
      'The station location doesn\'t exist in Wavelog anymore, or the token can\'t use it. Choose another one.';

  @override
  String get problemSyncMissingPermission =>
      'The token lacks a permission for this. Create a token with the permissions listed in the manual.';

  @override
  String get problemSyncTokenInvalid =>
      'Wavelog no longer accepts the token. Enter a new one in Settings.';

  @override
  String get problemSyncTokenExpired =>
      'The token has expired. Enter a new one in Settings.';

  @override
  String get problemSyncReadOnlyFields =>
      'You changed the time, mode, frequency or station. Wavelog can\'t change these on an uploaded QSO.';

  @override
  String get problemSyncSameMinuteTwin =>
      'Another QSO with the same callsign, band and mode in the same minute is already in Wavelog, which can store only one of them. Correct the time if this is a separate contact, or delete one.';

  @override
  String get qsoNotFound => 'This QSO no longer exists.';

  @override
  String get qsoDetails => 'QSO details';

  @override
  String serverSaid(String message) {
    return 'Wavelog said: $message';
  }

  @override
  String get conflictReplace => 'Replace in Wavelog';

  @override
  String get conflictKeepServer => 'I\'ll fix it in Wavelog';

  @override
  String get conflictReplaceNeedsDelete =>
      'Replacing needs a token with the qso:delete permission.';

  @override
  String get actionDeleteQso => 'Delete QSO';

  @override
  String get deleteQsoTitle => 'Delete this QSO?';

  @override
  String get deleteQsoBody =>
      'It will be removed from this device and, if it was uploaded, from your Wavelog.';

  @override
  String get deleteQsoLocalOnly =>
      'It will be removed from this device. The copy in Wavelog stays, because the token has no delete permission.';

  @override
  String get syncHistory => 'Sync history';

  @override
  String get journalLogged => 'Logged on this device';

  @override
  String get journalImported => 'Imported from a file';

  @override
  String get journalEditQueued => 'Change waiting for upload';

  @override
  String get journalRequestStarted => 'Sending to Wavelog';

  @override
  String get journalUploaded => 'Stored in Wavelog';

  @override
  String get journalPatched => 'Change applied in Wavelog';

  @override
  String get journalDeletedOnServer => 'Deleted in Wavelog';

  @override
  String get journalDeletedLocallyOnly =>
      'Deleted here; the Wavelog copy stays (no delete permission)';

  @override
  String get journalVerified => 'Found in Wavelog, no duplicate created';

  @override
  String get journalNotOnServer => 'Not in Wavelog yet, will be sent';

  @override
  String get journalRetry => 'Will try again later';

  @override
  String get journalRejected => 'Rejected by Wavelog';

  @override
  String get journalConflict => 'Needs your decision';

  @override
  String get journalConflictResolved => 'Decision made';

  @override
  String get journalAccountBlocked => 'Token stopped working';

  @override
  String get journalRunStarted => 'Sync started';

  @override
  String get journalRunFinished => 'Sync finished';

  @override
  String get journalContestSessionCreated =>
      'Contest session created on Wavelog';

  @override
  String get journalContestQsosLinked =>
      'QSOs linked to the Wavelog contest session';

  @override
  String get journalContestSessionLocalOnly =>
      'Contest session kept on this device only';

  @override
  String get journalContestSessionRetry =>
      'Contest session not synced yet; will retry';

  @override
  String get logEmptyBodyReady =>
      'Log your first QSO above. It is saved on this device right away, with or without a connection.';

  @override
  String get recentQsos => 'Recent QSOs';

  @override
  String certSubjectLine(String value) {
    return 'Issued to: $value';
  }

  @override
  String certIssuerLine(String value) {
    return 'Issued by: $value';
  }

  @override
  String get syncRunning => 'Syncing with your Wavelog…';

  @override
  String syncCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Synced $count QSOs.',
      one: 'Synced 1 QSO.',
      zero: 'Everything is up to date.',
    );
    return '$_temp0';
  }

  @override
  String get syncOffline =>
      'Your Wavelog isn\'t reachable right now. Your QSOs are safe on this device and will sync later.';

  @override
  String get syncBlocked =>
      'The token no longer works. Enter a new one in Settings; nothing is lost.';

  @override
  String get syncRateLimited =>
      'Your Wavelog asked for a pause. Sync continues automatically.';

  @override
  String syncNeedsReview(int count) {
    return '$count new QSOs are ready. Please review the upload first.';
  }

  @override
  String get actionPreviewUpload => 'Preview upload';

  @override
  String get previewTitle => 'Before uploading';

  @override
  String previewToUpload(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count QSOs will be uploaded.',
      one: '1 QSO will be uploaded.',
    );
    return '$_temp0';
  }

  @override
  String previewDuplicates(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count look like duplicates of QSOs you already have; Wavelog will keep only one of each.',
      one: '1 looks like a duplicate of a QSO you already have; Wavelog will keep only one.',
    );
    return '$_temp0';
  }

  @override
  String previewServerParsed(int parsed, int total) {
    return 'Wavelog\'s test run accepted $parsed of $total.';
  }

  @override
  String get previewServerUnreachable =>
      'Wavelog couldn\'t be asked right now; the upload will check each QSO anyway.';

  @override
  String get previewSafety =>
      'Each QSO is checked against your Wavelog before any retry, so nothing is sent twice.';

  @override
  String get previewUpload => 'Upload';

  @override
  String get settingsAccount => 'Wavelog account';

  @override
  String get settingsData => 'Import, export and backup';

  @override
  String get settingsSecurity => 'Security';

  @override
  String get accountPinned => 'Uses a certificate you trusted manually';

  @override
  String accountTokenExpires(String date) {
    return 'Token expires on $date';
  }

  @override
  String get accountTokenNoExpiry => 'Token without expiry date';

  @override
  String get actionReplaceToken => 'Enter a new token';

  @override
  String get tokenReplaced => 'New token saved. Syncing…';

  @override
  String get actionRemoveAccount => 'Remove account from this device';

  @override
  String get removeAccountTitle => 'Remove this account?';

  @override
  String get removeAccountBody =>
      'Its QSOs are removed from this device. Your Wavelog is not changed.';

  @override
  String removeAccountUnsynced(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count QSOs have not reached Wavelog yet and would be lost. Export or back up first.',
      one: '1 QSO has not reached Wavelog yet and would be lost. Export or back up first.',
    );
    return '$_temp0';
  }

  @override
  String get actionImportAdif => 'Import ADIF file';

  @override
  String get importAdifHint =>
      'For example a paper log typed in elsewhere, or another logger\'s export.';

  @override
  String get actionExportAdif => 'Export log as ADIF';

  @override
  String get exportAdifHint =>
      'Readable by every logging program. Not encrypted.';

  @override
  String get exportDone => 'Log exported.';

  @override
  String get actionCreateBackup => 'Create backup';

  @override
  String get backupHint =>
      'Everything except your token. The file is not encrypted: keep it somewhere safe.';

  @override
  String get backupDone => 'Backup saved.';

  @override
  String get actionRestoreBackup => 'Restore a backup';

  @override
  String restoreDone(int added, int skipped) {
    return 'Restored $added QSOs ($skipped were already here).';
  }

  @override
  String get restoreOldEncryptedBackup =>
      'This backup was encrypted by an earlier version of Tideline. This version can\'t open it any more.';

  @override
  String get restoreInvalidFile =>
      'This file isn\'t a Tideline backup or is damaged.';

  @override
  String get importDoneTitle => 'Import finished';

  @override
  String importImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count QSOs added.',
      one: '1 QSO added.',
    );
    return '$_temp0';
  }

  @override
  String importDuplicates(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count were already in your log and skipped.',
      one: '1 was already in your log and skipped.',
    );
    return '$_temp0';
  }

  @override
  String importRejected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count records had no valid callsign, time, band or mode.',
      one: '1 record had no valid callsign, time, band or mode.',
    );
    return '$_temp0';
  }

  @override
  String importWarnings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'The file had $count formatting problems that were worked around.',
      one: 'The file had 1 formatting problem that was worked around.',
    );
    return '$_temp0';
  }

  @override
  String importStation(String name) {
    return 'Imported QSOs belong to station location $name.';
  }

  @override
  String get importTooLarge =>
      'This file is too large to import (maximum 64 MB).';

  @override
  String get settingsAppLock => 'App lock';

  @override
  String get settingsAppLockHint =>
      'Ask for Face ID, fingerprint or the device PIN when opening Tideline.';

  @override
  String get appLockTitle => 'Tideline is locked';

  @override
  String get appLockUnlock => 'Unlock';

  @override
  String get appLockReason => 'Unlock your log';

  @override
  String get settingsReadingFont => 'Easy-to-read font';

  @override
  String get settingsReadingFontHint =>
      'Atkinson Hyperlegible: clearly distinct letters such as 0 and O, 1, l and I.';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionClose => 'Close';

  @override
  String get actionSave => 'Save';

  @override
  String get commandWipeEntry => 'Wipe entry';

  @override
  String get commandFocusCall => 'Go to callsign';

  @override
  String get commandToggleRates => 'Show or hide score and rates';

  @override
  String get commandEndContest => 'End contest session';

  @override
  String get commandOpenContest => 'Open contest mode';

  @override
  String get contestTitle => 'Contest mode';

  @override
  String get contestOpenAction => 'Contest mode';

  @override
  String contestBannerActive(String name) {
    return 'Contest session active: $name';
  }

  @override
  String get contestBannerReturn => 'Return to contest';

  @override
  String get contestSetupTitle => 'Contest session';

  @override
  String get contestSetupLoadFailed => 'Contests could not be loaded';

  @override
  String get contestSetupLoadFailedBody =>
      'Your normal log still works. Restart Tideline and try again.';

  @override
  String get contestSetupSessionRunning =>
      'A contest session is already running. End it before you start another one.';

  @override
  String get contestSetupChooseContest => 'Contest';

  @override
  String get contestSearchLabel => 'Search contests';

  @override
  String get contestSearchEmpty => 'No contest matches your search.';

  @override
  String get contestSetupChooseHint =>
      'Choose a contest from the list to set up the session.';

  @override
  String get contestBuiltin => 'Built in';

  @override
  String get contestImported => 'Imported by you';

  @override
  String get contestSetupNeedStation =>
      'This account has no station location yet. Sync once to load your Wavelog station locations, then try again.';

  @override
  String get contestSetupStation => 'Station';

  @override
  String get contestSetupExchange => 'My exchange';

  @override
  String get contestSetupExchangeHelp =>
      'This is what you send to every station. The suggestions come from your station location; please check them.';

  @override
  String get contestSetupRstAuto =>
      'The report is sent automatically: 59 for voice, 599 for CW and digital modes.';

  @override
  String get contestSetupSerialAuto =>
      'The serial number starts at 1 and counts up with every QSO. A number is never used twice, even if you delete a QSO.';

  @override
  String get contestSetupCabrillo => 'Cabrillo categories';

  @override
  String get contestSetupCabrilloHelp =>
      'These go into the header of the Cabrillo log you send to the sponsor. The values are fixed terms of the Cabrillo format.';

  @override
  String get contestCatOperator => 'Operator category';

  @override
  String get contestCatAssisted => 'Assistance';

  @override
  String get contestCatBand => 'Band category';

  @override
  String get contestCatMode => 'Mode category';

  @override
  String get contestCatPower => 'Power';

  @override
  String get contestCatStation => 'Station type';

  @override
  String get contestCatTransmitter => 'Transmitters';

  @override
  String get contestCatOverlay => 'Overlay';

  @override
  String get contestCatNotSet => 'Not set';

  @override
  String get contestStart => 'Start session';

  @override
  String get contestStartFailed =>
      'The session could not be started. Nothing was changed. Try again.';

  @override
  String get contestPastTitle => 'Past sessions';

  @override
  String get contestPastEmpty => 'No contest sessions yet.';

  @override
  String get contestStateActive => 'Running';

  @override
  String get contestStateEnded => 'Ended';

  @override
  String get contestReopen => 'Reopen';

  @override
  String get contestSessionsAction => 'Sessions';

  @override
  String get contestMissingTitle => 'Contest rules not found';

  @override
  String get contestMissingBody =>
      'The rules for this session are no longer on this device. Your QSOs are safe. End the session to carry on.';

  @override
  String get contestEndTitle => 'End the contest session?';

  @override
  String get contestEndBody =>
      'Your QSOs stay in the log. You can reopen the session later from the session list.';

  @override
  String get contestKindRst => 'RST';

  @override
  String get contestKindSerial => 'Serial no.';

  @override
  String get contestKindCqZone => 'CQ zone';

  @override
  String get contestKindItuZone => 'ITU zone';

  @override
  String get contestKindGrid => 'Grid';

  @override
  String get contestKindState => 'State or province';

  @override
  String get contestKindSection => 'Section';

  @override
  String get contestKindDok => 'DOK';

  @override
  String get contestKindPower => 'Power';

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
    return '$label is required.';
  }

  @override
  String contestErrorInvalid(String label) {
    return '$label is not valid.';
  }

  @override
  String contestErrorOutOfRange(String label) {
    return '$label is out of range.';
  }

  @override
  String get contestMultZone => 'Zone';

  @override
  String get contestMultItuZone => 'ITU zone';

  @override
  String get contestMultDxcc => 'Country';

  @override
  String get contestMultPrefix => 'Prefix';

  @override
  String get contestMultState => 'State or province';

  @override
  String get contestMultDok => 'DOK';

  @override
  String contestHintDupe(String bands, String modes) {
    return 'Dupe: already worked on $bands ($modes)';
  }

  @override
  String contestHintWorkedElsewhere(String bands, String modes) {
    return 'Already worked on $bands ($modes); not a dupe here';
  }

  @override
  String contestHintNewMultiplier(String items) {
    return 'New multiplier: $items';
  }

  @override
  String get contestHintOutOfContest =>
      'Outside this contest\'s bands or modes: scores 0 points.';

  @override
  String get contestHintLogWorked =>
      'In your log: worked before on this band and mode';

  @override
  String get contestHintLogNewBand => 'In your log: worked before, new band';

  @override
  String get contestHintLogNewMode => 'In your log: worked before, new mode';

  @override
  String get contestHintLogNewSlot =>
      'In your log: worked before, new combination of band and mode';

  @override
  String get contestHintInScp => 'Callsign is in the super check partial list';

  @override
  String get contestHintScpMatches => 'Super check:';

  @override
  String get contestHintNPlusOne => 'Did you mean:';

  @override
  String contestUseCall(String call) {
    return 'Use $call';
  }

  @override
  String contestSentSummary(String items) {
    return 'Sent: $items';
  }

  @override
  String get contestSentNothing => 'Nothing to send';

  @override
  String contestLoggedAnnouncement(String call, int serial, String dupe) {
    String _temp0 = intl.Intl.selectLogic(dupe, {'yes': ', dupe', 'other': ''});
    return 'Logged $call, serial $serial$_temp0';
  }

  @override
  String contestLoggedAnnouncementNoSerial(String call, String dupe) {
    String _temp0 = intl.Intl.selectLogic(dupe, {'yes': ', dupe', 'other': ''});
    return 'Logged $call$_temp0';
  }

  @override
  String get contestSaveFailed =>
      'The QSO could not be saved. What you typed is still here. Try again.';

  @override
  String get contestRecentTitle => 'Recent QSOs';

  @override
  String get contestRecentEmpty =>
      'No QSOs in this session yet. Type a callsign and the exchange, then press Enter.';

  @override
  String contestRowExchange(String sent, String rcvd) {
    return '$sent → $rcvd';
  }

  @override
  String get contestRowEditHint => 'Edit this QSO';

  @override
  String get contestFlagDupe => 'Dupe';

  @override
  String get contestFlagMult => 'Mult';

  @override
  String get contestFlagOut => 'Out';

  @override
  String contestPoints(int points) {
    String _temp0 = intl.Intl.pluralLogic(
      points,
      locale: localeName,
      other: '$points pts',
      one: '1 pt',
    );
    return '$_temp0';
  }

  @override
  String get contestEditTitle => 'Edit QSO';

  @override
  String contestEditSent(String items) {
    return 'Sent (cannot be changed): $items';
  }

  @override
  String get contestDeleteTitle => 'Delete this QSO?';

  @override
  String contestDeleteBody(String call) {
    return '$call will be removed from this device and from the contest score.';
  }

  @override
  String contestDeleteBodySerial(String call, String serial) {
    return '$call will be removed from this device and from the contest score. Serial $serial stays used and is never given out again.';
  }

  @override
  String get contestPanelTitle => 'Score and rates';

  @override
  String contestPanelSummary(int qsos, int points, int score) {
    return '$qsos QSOs · $points points · estimate $score';
  }

  @override
  String get contestQsos => 'QSOs';

  @override
  String get contestPointsLabel => 'Points';

  @override
  String get contestMultipliers => 'Multipliers';

  @override
  String get contestDupes => 'Dupes';

  @override
  String get contestScoreEstimate => 'Claimed score (estimate)';

  @override
  String get contestScoreEstimateNote =>
      'An estimate for your own use. The contest sponsor\'s log check decides the real result.';

  @override
  String get contestRatesTitle => 'Rates';

  @override
  String get contestRate10Min => 'Last 10 minutes';

  @override
  String get contestRate60Min => 'Last 60 minutes';

  @override
  String get contestRateLast10 => 'Last 10 QSOs';

  @override
  String get contestRateLast100 => 'Last 100 QSOs';

  @override
  String get contestRateBest => 'Best 60 minutes';

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
    return '$_temp0 from $time $utc';
  }

  @override
  String get contestBandsTitle => 'By band';

  @override
  String get contestBandsEmpty => 'No scoring QSOs yet.';

  @override
  String contestLabelValue(String label, String value) {
    return '$label: $value';
  }

  @override
  String get commandExportCabrillo => 'Export Cabrillo log';

  @override
  String get contestMoreActions => 'More actions';

  @override
  String get contestCatTime => 'Time category';

  @override
  String get cabrilloExportTitle => 'Export Cabrillo log';

  @override
  String get cabrilloIssuesIntro =>
      'The log has problems that contest checkers may reject:';

  @override
  String get cabrilloExportAnyway => 'Export anyway';

  @override
  String get cabrilloExportDone => 'Cabrillo log saved.';

  @override
  String get cabrilloExportFailed =>
      'The Cabrillo log could not be created or saved.';

  @override
  String get cabrilloUnavailableBanner =>
      'Cabrillo export is not available: this contest has no Cabrillo name.';

  @override
  String cabrilloUnavailableBody(String contest) {
    return '$contest has no Cabrillo contest name in its definition, so no log that a contest robot would accept can be written. Add a cabrillo name to the definition, or use the ADIF export in Settings.';
  }

  @override
  String get cabrilloIssueMissingContest => 'The contest has no Cabrillo name.';

  @override
  String get cabrilloIssueMissingCallsign => 'The station has no callsign.';

  @override
  String get cabrilloIssueEmptyLog => 'The session has no QSOs.';

  @override
  String get cabrilloIssueExchangeCountMismatch =>
      'The exchange has a different number of items than the first QSO.';

  @override
  String get cabrilloIssueMissingFrequency =>
      'The frequency or band cannot be determined.';

  @override
  String get cabrilloIssueMissingQsoCall => 'A callsign is empty.';

  @override
  String get cabrilloIssueTokenContainsWhitespace =>
      'An exchange value contains a space; it is written with a hyphen.';

  @override
  String get cabrilloIssueEmptyExchangeToken =>
      'An exchange value is empty; a hyphen is written in its place.';

  @override
  String get cabrilloIssueTooManyAddressLines =>
      'There are more than 6 address lines; the extra lines are dropped.';

  @override
  String get cabrilloIssueAddressLineTooLong =>
      'An address line is longer than 45 characters; it is cut off.';

  @override
  String get cabrilloIssueInvalidTransmitterId =>
      'The transmitter number must be 0 or 1.';

  @override
  String cabrilloIssueQsos(int count, int first) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count QSOs, the first is no. $first',
      one: 'QSO no. $first',
    );
    return '$_temp0';
  }

  @override
  String get contestSyncLocal => 'Only on this device';

  @override
  String get contestSyncPending => 'Waiting for upload to Wavelog';

  @override
  String get contestSyncVerifying => 'Being checked on Wavelog';

  @override
  String get contestSyncCreated => 'On Wavelog';

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
      'The contest is not activated on your Wavelog server.';

  @override
  String get contestSyncProblemMissingPermission =>
      'The API token lacks the contest:write permission.';

  @override
  String get contestSyncProblemServerTooOld =>
      'Your Wavelog server is older than version 3.2 and has no contest sessions.';

  @override
  String get contestSyncProblemDeletedOnServer =>
      'The session was deleted in Wavelog.';

  @override
  String get contestSyncProblemNoAdifName =>
      'This contest has no ADIF contest name.';

  @override
  String get contestSyncProblemStationUnknown =>
      'The station location is not on the Wavelog server.';

  @override
  String get contestSyncProblemRejected => 'Wavelog rejected the session.';

  @override
  String get contestSyncProblemUnknown => 'Wavelog reported a problem.';

  @override
  String get workedHintNewCall => 'New call: not in your log yet';

  @override
  String get workedHintNewBand => 'Worked before, but not on this band';

  @override
  String get workedHintNewMode => 'Worked before, but not in this mode';

  @override
  String get workedHintNewSlot =>
      'Worked before, but not on this band and mode together';

  @override
  String get workedHintWorked => 'Worked before on this band and mode';

  @override
  String workedHintDetails(String date, String bands) {
    return 'first contact $date, bands $bands';
  }

  @override
  String get settingsWorkedBefore => 'Worked-before index';

  @override
  String get actionRebuildWorkedBefore => 'Rebuild worked-before index';

  @override
  String get rebuildWorkedBeforeHint =>
      'Builds the index from your log again. Contacts from your Wavelog server come back with the next sync.';

  @override
  String get rebuildWorkedBeforeConfirmTitle => 'Rebuild the index?';

  @override
  String get rebuildWorkedBeforeConfirmBody =>
      'Your log is not changed. Hints for stations you only worked on other devices or in Wavelog are missing until the next sync has loaded them again.';

  @override
  String get actionRebuild => 'Rebuild';

  @override
  String get rebuildWorkedBeforeProgress => 'Rebuilding the index…';

  @override
  String get rebuildWorkedBeforeDone =>
      'Index rebuilt. The next sync adds the contacts from your Wavelog server.';

  @override
  String get rebuildWorkedBeforeFailed => 'The index could not be rebuilt.';

  @override
  String get settingsScp => 'Super check partial';

  @override
  String get scpHint =>
      'Callsign suggestions while you log a contest. The list is not part of Tideline: you download it yourself.';

  @override
  String get scpNone => 'No list installed';

  @override
  String scpPackSummary(int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count callsigns',
      one: '1 callsign',
    );
    return '$_temp0 · installed $date';
  }

  @override
  String scpSource(String source) {
    return 'Source: $source';
  }

  @override
  String get scpSourceFile => 'a file you imported';

  @override
  String get scpUrlLabel => 'Download address (https)';

  @override
  String get scpUrlHelper =>
      'Tideline contacts this address only when you press Download, and sends nothing about you.';

  @override
  String get actionDownload => 'Download';

  @override
  String get actionImportFile => 'Import file';

  @override
  String get actionRemove => 'Remove';

  @override
  String get scpDownloading => 'Downloading the list…';

  @override
  String scpDownloadingSize(int kib) {
    return 'Downloading the list… $kib KiB';
  }

  @override
  String scpInstalled(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count callsigns',
      one: '1 callsign',
    );
    return 'List installed: $_temp0.';
  }

  @override
  String get scpRemoveTitle => 'Remove the list?';

  @override
  String get scpRemoveBody =>
      'Callsign suggestions stop until you install a list again.';

  @override
  String get scpRemoved => 'List removed.';

  @override
  String get scpErrorInsecureUrl => 'Only https addresses are allowed.';

  @override
  String get scpErrorInvalidUrl =>
      'This is not a usable address. It must not contain a user name, a password, a query (?…) or a fragment (#…).';

  @override
  String get scpErrorNetwork =>
      'The server could not be reached. Check your connection and the address.';

  @override
  String get scpErrorTimeout => 'The server took too long to answer.';

  @override
  String get scpErrorCertificate =>
      'The certificate of the server is not trusted, so nothing was downloaded.';

  @override
  String get scpErrorTooLarge =>
      'The file is larger than 8 MiB. It was not stored.';

  @override
  String scpErrorStatus(int code) {
    return 'The server answered with HTTP status $code.';
  }

  @override
  String get scpErrorInvalidFile =>
      'This is not a MASTER.SCP file (one callsign per line).';

  @override
  String get scpErrorUnreadable => 'The file could not be read.';

  @override
  String get settingsContestDefinitions => 'Contest definitions';

  @override
  String get contestDefsHint =>
      'The rules of each contest are data files. Bundled definitions are always available; you can add your own.';

  @override
  String get contestDefBuiltin => 'Bundled';

  @override
  String get contestDefUser => 'Imported by you';

  @override
  String contestDefVersion(int version) {
    return 'version $version';
  }

  @override
  String get actionImportDefinition => 'Import definition';

  @override
  String get importDefinitionHint => 'A JSON file of up to 256 KiB.';

  @override
  String contestDefImported(String name) {
    return 'Imported “$name”.';
  }

  @override
  String contestDefReplaced(String name) {
    return 'Updated “$name”.';
  }

  @override
  String get contestDefRejectedTitle => 'Definition not imported';

  @override
  String contestDefTechnical(String path) {
    return 'Technical detail: $path';
  }

  @override
  String get contestDefFileTooLarge => 'The file is larger than 256 KiB.';

  @override
  String get contestDefNotText => 'The file is not valid UTF-8 text.';

  @override
  String get contestDefUnreadable => 'The file could not be read.';

  @override
  String get contestDefIdClash =>
      'This id belongs to a bundled contest. Choose a different id in the file.';

  @override
  String actionDeleteDefinition(String name) {
    return 'Delete definition $name';
  }

  @override
  String contestDefDeleteTitle(String name) {
    return 'Delete “$name”?';
  }

  @override
  String get contestDefDeleteBody =>
      'Only the definition is removed. Your QSOs are not affected.';

  @override
  String contestDefDeleted(String name) {
    return 'Deleted “$name”.';
  }

  @override
  String get contestDefInUse =>
      'A contest session in your log uses this definition, so it cannot be deleted.';

  @override
  String get contestDefBuiltinNoDelete =>
      'Bundled definitions cannot be deleted.';

  @override
  String get contestDefNotFound => 'This definition no longer exists.';

  @override
  String get contestDefErrorTooLarge =>
      'The definition is larger than 256 KiB.';

  @override
  String get contestDefErrorMalformedJson => 'The file is not valid JSON.';

  @override
  String get contestDefErrorWrongType => 'A value has the wrong type.';

  @override
  String get contestDefErrorUnknownKey =>
      'The file contains a setting that Tideline does not know.';

  @override
  String get contestDefErrorMissingKey => 'A required setting is missing.';

  @override
  String get contestDefErrorUnsupportedSchema =>
      'This schema version is not supported (only version 1).';

  @override
  String get contestDefErrorInvalidId =>
      'The id must have 1 to 64 characters: lower-case letters, digits and hyphens.';

  @override
  String get contestDefErrorOutOfRange =>
      'A number or a text length is outside the allowed range.';

  @override
  String get contestDefErrorTooLong => 'A text is too long.';

  @override
  String get contestDefErrorInvalidCharacters =>
      'A text contains control characters.';

  @override
  String get contestDefErrorTooManyElements => 'A list has too many entries.';

  @override
  String get contestDefErrorTooFewElements => 'A list has too few entries.';

  @override
  String get contestDefErrorUnknownBand =>
      'A band name is not a known ADIF band.';

  @override
  String get contestDefErrorUnknownValue =>
      'A setting has a value that Tideline does not know.';

  @override
  String get contestDefErrorLastRuleHasWhen =>
      'The last points rule must apply to every contact, so it cannot have a condition.';

  @override
  String get contestDefErrorVariantPredicateNotMine =>
      'A variant of the exchange may depend only on your own station.';

  @override
  String get contestDefErrorElementPredicateNotTheirs =>
      'A received exchange element may depend only on the other station.';

  @override
  String get contestDefErrorElementWhenNotAllowed =>
      'A sent exchange element cannot have a condition.';

  @override
  String get contestDefErrorMultipleSerials =>
      'One side of the exchange may contain only one serial number.';

  @override
  String get contestDefErrorDuplicateField =>
      'Two exchange elements store into the same ADIF field.';

  @override
  String get contestDefErrorDuplicateId => 'Two multipliers have the same id.';

  @override
  String get contestDefErrorInvalidPlaceholder =>
      'A default value uses an unknown placeholder.';

  @override
  String get contestDefErrorInvalidValue =>
      'A default value does not fit its exchange element.';

  @override
  String get contestDefErrorDefaultNotAllowed =>
      'A default value is not allowed here (received side and serial numbers).';

  @override
  String get contestDefErrorInvalidMultiplierSource =>
      'A multiplier uses a source that does not exist or that no received exchange contains.';

  @override
  String get contestDefErrorEmptyPredicate => 'A condition is empty.';

  @override
  String get contestDefErrorInvalidCombination =>
      'The score type does not fit the multipliers.';

  @override
  String get contestDefErrorDuplicateValue => 'The same value is listed twice.';

  @override
  String get settingsReferencePacks => 'Reference lists (SOTA, POTA, WWFF)';

  @override
  String get packsHint =>
      'Offline lists of summits, parks and flora and fauna areas for activations. They are not part of Tideline: you download each one yourself, directly from its official source. Each list is 10 to 25 MB.';

  @override
  String get packNameSota => 'Summits on the Air (SOTA)';

  @override
  String get packNamePota => 'Parks on the Air (POTA)';

  @override
  String get packNameWwff => 'World Wide Flora & Fauna (WWFF)';

  @override
  String get packNone => 'No list installed';

  @override
  String packSummary(int count, String version, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count references',
      one: '1 reference',
    );
    return '$_temp0 · list dated $version · downloaded $date';
  }

  @override
  String get actionUpdate => 'Update';

  @override
  String get packDownloading => 'Downloading…';

  @override
  String packDownloadingSize(String size) {
    return 'Downloading… $size';
  }

  @override
  String get packInstalling => 'Reading and storing the list…';

  @override
  String packInstalled(String program, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count references',
      one: '1 reference',
    );
    return '$program list installed: $_temp0.';
  }

  @override
  String get packCancelled =>
      'Download cancelled. The installed list was not changed.';

  @override
  String packRemoveTitle(String program) {
    return 'Remove the $program list?';
  }

  @override
  String packRemoveBody(String program) {
    return 'Searching for $program references stops until you install a list again. Your activations and QSOs are not affected.';
  }

  @override
  String packRemoved(String program) {
    return '$program list removed.';
  }

  @override
  String get packErrorTooLarge =>
      'The file is larger than allowed. It was not stored.';

  @override
  String packErrorInvalidFile(String program) {
    return 'This is not a $program list. Check the address.';
  }

  @override
  String get packErrorStorage =>
      'The file could not be stored on this device. Check the free space.';

  @override
  String get activationOpenAction => 'Start an activation';

  @override
  String get activationSetupTitle => 'Start an activation';

  @override
  String get activationProgramLabel => 'Program';

  @override
  String get activationReferenceLabelSota => 'Summit reference';

  @override
  String get activationReferenceLabelPota => 'Park reference';

  @override
  String get activationReferenceLabelWwff => 'Area reference';

  @override
  String activationReferenceExample(String example) {
    return 'Example: $example';
  }

  @override
  String activationReferenceInvalid(String program, String example) {
    return 'This is not a $program reference. Example: $example';
  }

  @override
  String activationReferenceKnown(String program, String name) {
    return 'In your $program list: $name';
  }

  @override
  String activationReferenceUnknown(String program) {
    return 'Not in your $program list. You can still use it.';
  }

  @override
  String activationNoPack(String program) {
    return 'No $program list is installed, so references cannot be looked up. You can still type one. Download the list in Settings.';
  }

  @override
  String get activationOpenSettings => 'Open settings';

  @override
  String get activationMatches => 'Matches';

  @override
  String activationNearby(String grid) {
    return 'Nearest to $grid';
  }

  @override
  String get activationNoMatches => 'Nothing found.';

  @override
  String unitKilometers(int km) {
    return '$km km';
  }

  @override
  String get activationGridLabel => 'Your grid square at the reference';

  @override
  String get activationGridFromReference =>
      'Taken from the position of the reference.';

  @override
  String get activationGridFromStation => 'Taken from the Wavelog location.';

  @override
  String get activationGridNone =>
      'No grid square known. You can leave it empty.';

  @override
  String activationLocationCarries(String reference) {
    return 'This Wavelog location carries $reference, so your QSOs reach Wavelog with it.';
  }

  @override
  String activationLocationSuggest(String name, String reference) {
    return 'The Wavelog location “$name” carries $reference.';
  }

  @override
  String get activationUseLocation => 'Use this location';

  @override
  String activationLocationNone(String reference) {
    return 'No Wavelog location carries $reference. Wavelog files every QSO under its location’s own reference and ignores the one in the upload. Tideline keeps $reference on each QSO and in ADIF exports. To have it on Wavelog too, create a location with this reference there, then choose it here.';
  }

  @override
  String get activationErrorNoStation =>
      'No Wavelog location yet. Connect to Wavelog once to load your locations.';

  @override
  String activationRunning(String reference) {
    return '$reference is still running. Starting a new activation ends it.';
  }

  @override
  String get activationStart => 'Start activation';

  @override
  String get activationStartFailed =>
      'The activation could not be started. Try again.';

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
      other: '$remaining to go',
      one: '1 to go',
    );
    return '$counted of $required QSOs · $_temp0';
  }

  @override
  String activationProgressValid(int counted, int required) {
    return 'Valid activation: $counted QSOs (needs $required)';
  }

  @override
  String get activationWindowDay => 'Counted per UTC day.';

  @override
  String get activationWindowSession => 'Counted over the whole activation.';

  @override
  String activationDuplicates(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count QSOs',
      one: '1 QSO',
    );
    return '$_temp0 not counted (same call, band and mode).';
  }

  @override
  String activationDuplicatesCall(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count QSOs',
      one: '1 QSO',
    );
    return '$_temp0 not counted (same station again).';
  }

  @override
  String get activationEnd => 'End activation';

  @override
  String activationEndTitle(String reference) {
    return 'End $reference?';
  }

  @override
  String get activationEndBody =>
      'New QSOs are no longer added to this activation. Logged QSOs stay as they are.';

  @override
  String get activationEnded => 'Activation ended.';

  @override
  String get activationTheirReferenceSota => 'Their summit (S2S)';

  @override
  String get activationTheirReferencePota => 'Their park (P2P)';

  @override
  String get activationTheirReferenceWwff => 'Their area (WWFF)';

  @override
  String get activationIssueTheirReference => 'This is not a valid reference.';

  @override
  String get commandStartActivation => 'Start an activation';

  @override
  String get commandEndActivation => 'End the running activation';

  @override
  String get settingsAppearanceAndLanguage => 'Appearance and language';

  @override
  String get settingsAppearanceHint => 'Theme, text and language';

  @override
  String get settingsReferenceData => 'Reference data';

  @override
  String get settingsReferenceDataHint => 'Lists and indexes you download';

  @override
  String get settingsSecurityAndBackup => 'Security and backup';

  @override
  String get settingsSecurityAndBackupHint => 'App lock, ADIF and backup';

  @override
  String get settingsAccounts => 'Wavelog accounts';

  @override
  String get accountsHint => 'Servers, tokens and the account you log to';

  @override
  String get accountsInUse => 'In use for logging';

  @override
  String accountsPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count QSOs waiting',
      one: '1 QSO waiting',
      zero: 'Nothing waiting',
    );
    return '$_temp0';
  }

  @override
  String get accountsAdd => 'Add account';

  @override
  String get accountsUseForLogging => 'Use for logging';

  @override
  String get accountsRename => 'Rename';

  @override
  String get accountsRenameTitle => 'Rename this account';

  @override
  String get accountsSwitch => 'Switch account';

  @override
  String get accountsManage => 'Manage accounts';

  @override
  String accountsSwitchedTo(String name) {
    return 'Logging to $name';
  }

  @override
  String get accountsBlockedContest =>
      'A contest session is running. End it before you switch accounts.';

  @override
  String get accountsBlockedActivation =>
      'An activation is running. End it before you switch accounts.';

  @override
  String get accountsPendingTitle => 'Waiting, per account';

  @override
  String get accountsExportRemove => 'Export log, then remove';

  @override
  String get accountsAddTitle => 'Add a Wavelog account';

  @override
  String accountsActsOn(String name) {
    return 'Account: $name';
  }

  @override
  String get commandGoBack => 'Go back';

  @override
  String get menuGo => 'Go';

  @override
  String get menuOperate => 'Operate';

  @override
  String get menuHelp => 'Help';

  @override
  String get menuWindow => 'Window';

  @override
  String get actionCopyCallsign => 'Copy callsign';

  @override
  String get actionOpenQso => 'Open QSO';

  @override
  String callsignCopied(String call) {
    return 'Copied $call';
  }

  @override
  String get callsignFillIn => 'Fill in';

  @override
  String get callsignFillInLabel =>
      'Fill in name and locator from earlier contacts';

  @override
  String callsignKnown(String details) {
    return 'Known from earlier contacts: $details';
  }

  @override
  String get callsignNoteTooltip => 'Callsign note';

  @override
  String get callsignNoteTooltipHas => 'Callsign note (there is one)';

  @override
  String callsignNoteTitle(String call) {
    return 'Note for $call';
  }

  @override
  String get callsignNoteHint =>
      'Only on this device (and in your backup). Not sent to Wavelog.';

  @override
  String get callsignNoteField => 'Note';

  @override
  String get callsignNoteDelete => 'Delete note';

  @override
  String callsignNoteLine(String text) {
    return 'Note: $text';
  }

  @override
  String get callsignDirectoryTitle => 'Callsign directory';

  @override
  String get callsignDirectoryBody =>
      'Names, places and locators from your QSO history, kept on this device, so they are there offline. It is part of the worked-before index and is rebuilt with it.';

  @override
  String callsignDirectoryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stations',
      one: '1 station',
      zero: 'No stations yet',
    );
    return '$_temp0';
  }

  @override
  String get callsignSearch => 'Search call, name or place';

  @override
  String get callsignEmpty =>
      'Nothing found. Stations appear here as you log and sync.';

  @override
  String get callsignHasNote => 'Has a note';

  @override
  String callsignLastWorked(String date) {
    return 'Last worked $date';
  }

  @override
  String callsignZones(String dxcc, String cq, String itu) {
    return 'DXCC $dxcc · CQ $cq · ITU $itu';
  }

  @override
  String get freeSpaceTitle => 'Free up space';

  @override
  String get freeSpaceEntry => 'Remove synced QSOs from this device';

  @override
  String get freeSpaceEntryHint => 'Wavelog keeps them.';

  @override
  String get freeSpaceIntro =>
      'This removes the copies on this device of QSOs that Wavelog already has. Nothing is deleted on Wavelog. Tideline asks Wavelog first and keeps everything it cannot find there. Worked-before hints and station names stay.';

  @override
  String get freeSpaceScope => 'Which QSOs';

  @override
  String get freeSpaceOlder1 => 'Older than 1 year';

  @override
  String get freeSpaceOlder2 => 'Older than 2 years';

  @override
  String get freeSpaceOlder5 => 'Older than 5 years';

  @override
  String get freeSpaceAll => 'All synced QSOs';

  @override
  String freeSpaceEligible(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count QSOs can be removed',
      one: '1 QSO can be removed',
      zero: 'No QSOs can be removed',
    );
    return '$_temp0';
  }

  @override
  String get freeSpaceStaying => 'Staying on this device';

  @override
  String freeSpaceBlockedNotSynced(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count QSOs are not on Wavelog yet',
      one: '1 QSO is not on Wavelog yet',
    );
    return '$_temp0';
  }

  @override
  String freeSpaceBlockedChanged(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count QSOs were changed after they were sent',
      one: '1 QSO was changed after it was sent',
    );
    return '$_temp0';
  }

  @override
  String freeSpaceBlockedContest(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count QSOs belong to contest sessions',
      one: '1 QSO belongs to a contest session',
    );
    return '$_temp0';
  }

  @override
  String freeSpaceBlockedActivation(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count QSOs belong to activations',
      one: '1 QSO belongs to an activation',
    );
    return '$_temp0';
  }

  @override
  String get freeSpaceCheck => 'Check with Wavelog';

  @override
  String get freeSpaceChecking => 'Asking Wavelog …';

  @override
  String freeSpaceConfirmedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Wavelog has $count of them',
      one: 'Wavelog has 1 of them',
      zero: 'Wavelog has none of them',
    );
    return '$_temp0';
  }

  @override
  String freeSpaceMissingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count were not found on Wavelog and stay',
      one: '1 was not found on Wavelog and stays',
    );
    return '$_temp0';
  }

  @override
  String get freeSpaceOffline =>
      'Wavelog could not be reached. Nothing was removed.';

  @override
  String get freeSpaceUnauthorized =>
      'The token no longer works. Enter a new token first. Nothing was removed.';

  @override
  String get freeSpaceServerProblem =>
      'Wavelog answered with an error. Nothing was removed.';

  @override
  String get freeSpaceTooMany =>
      'There are too many QSOs in that period to check at once. Choose a shorter period.';

  @override
  String freeSpaceRemoveButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Remove $count QSOs from this device',
      one: 'Remove 1 QSO from this device',
    );
    return '$_temp0';
  }

  @override
  String get freeSpaceConfirmTitle => 'Remove from this device?';

  @override
  String freeSpaceConfirmBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count QSOs',
      one: '1 QSO',
    );
    return '$_temp0 will be removed from this device. They stay on Wavelog. You can save them as an ADIF file first.';
  }

  @override
  String get freeSpaceExportRemove => 'Export, then remove';

  @override
  String get freeSpaceRemoveOnly => 'Remove';

  @override
  String freeSpaceDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Removed $count QSOs from this device. They are still on Wavelog.',
      one: 'Removed 1 QSO from this device. It is still on Wavelog.',
    );
    return '$_temp0';
  }

  @override
  String freeSpaceSoFar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count QSOs removed so far',
      one: '1 QSO removed so far',
      zero: 'Nothing removed so far',
    );
    return '$_temp0';
  }

  @override
  String get qsoRemoveFromDevice => 'Remove from this device';

  @override
  String get qsoRemoveFromDeviceHint =>
      'Wavelog keeps it. Tideline checks that first.';

  @override
  String get qsoNotRemoved =>
      'Not removed: Wavelog could not confirm this QSO.';

  @override
  String journalEvictedLocally(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count QSOs removed from this device (still on Wavelog)',
      one: '1 QSO removed from this device (still on Wavelog)',
    );
    return '$_temp0';
  }

  @override
  String get commandFastLogEntry => 'Fast Log Entry';

  @override
  String get fleTitle => 'Fast Log Entry';

  @override
  String get fleIntro =>
      'Type QSOs as shorthand, one per line. Nothing is logged until you confirm at the bottom.';

  @override
  String get fleStation => 'Station location';

  @override
  String get fleTextLabel => 'QSOs';

  @override
  String get fleExample =>
      '20m cw\n1734 DL1ABC 599 579\n5 G4XYZ\n1800 F5ABC jn18';

  @override
  String get fleSyntaxTitle => 'How the shorthand works';

  @override
  String get fleSyntaxBody =>
      'One QSO per line: time, callsign, then optional reports, locator, reference, @name.\nBand, mode or frequency on a line of their own apply to the lines after it (20m, cw, 14.205).\nAfter the first time, only the changed digits are needed: 1734, then 5 means 1735, 40 means 1740.\nDate: date 2026-10-02, or day + for the next day. Time zone: timezone +2 (your local time is then converted to UTC).\nReports: 59, 599, -12. One report is the one you sent.\nMore: <comment>, [QSL message], <tx_pwr:50>.';

  @override
  String get flePreview => 'Preview';

  @override
  String get fleEmpty => 'Nothing to read yet.';

  @override
  String fleLine(int number) {
    return 'Line $number';
  }

  @override
  String get fleHeaderLine => 'Sets what follows';

  @override
  String get fleDuplicate =>
      'Duplicate: already in the log or earlier in this text';

  @override
  String get fleWarnBackwards =>
      'Earlier than the QSO before. A day + missing?';

  @override
  String get fleWarnFuture => 'In the future';

  @override
  String get fleSkipProblems => 'Skip lines with problems';

  @override
  String get fleLogDuplicates => 'Also log duplicates';

  @override
  String fleSummary(int qsos, int problems, int dupes) {
    String _temp0 = intl.Intl.pluralLogic(
      qsos,
      locale: localeName,
      other: '$qsos QSOs',
      one: '1 QSO',
    );
    String _temp1 = intl.Intl.pluralLogic(
      problems,
      locale: localeName,
      other: '$problems problems',
      one: '1 problem',
      zero: 'no problems',
    );
    String _temp2 = intl.Intl.pluralLogic(
      dupes,
      locale: localeName,
      other: '$dupes duplicates',
      one: '1 duplicate',
      zero: 'no duplicates',
    );
    return '$_temp0 to log · $_temp1 · $_temp2';
  }

  @override
  String fleLogButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Log $count QSOs',
      one: 'Log 1 QSO',
      zero: 'Log QSOs',
    );
    return '$_temp0';
  }

  @override
  String fleActivationNotice(String reference) {
    return 'These QSOs go into your running activation $reference.';
  }

  @override
  String fleLogged(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Logged $count QSOs',
      one: 'Logged 1 QSO',
    );
    return '$_temp0';
  }

  @override
  String fleQsoDetails(String time, String band, String mode, String rst) {
    return '$time UTC · $band $mode · $rst';
  }

  @override
  String fleProblemUnknownToken(String token) {
    return 'Not understood: $token';
  }

  @override
  String get fleProblemUnclosedBracket => 'A [ or < is never closed';

  @override
  String fleProblemInvalidTime(String token) {
    return 'Not a time: $token';
  }

  @override
  String get fleProblemMissingTime =>
      'No time yet. Start with a full time like 1734.';

  @override
  String get fleProblemMissingCall => 'No callsign on this line';

  @override
  String get fleProblemMissingBand =>
      'No band yet. Put a band (20m) or frequency (14.205) on a line before.';

  @override
  String get fleProblemMissingMode =>
      'No mode yet. Put a mode (cw, ssb, ft8) on a line before.';

  @override
  String fleProblemUnsupportedBand(String token) {
    return 'Band not supported: $token';
  }

  @override
  String fleProblemFrequencyOutsideBands(String token) {
    return 'Frequency is not in an amateur band: $token';
  }

  @override
  String fleProblemInvalidDate(String token) {
    return 'Not a date: $token';
  }

  @override
  String get fleProblemInvalidDayShift => 'Too many + after day';

  @override
  String fleProblemInvalidTimezone(String token) {
    return 'Time zone must be between -12 and +14: $token';
  }

  @override
  String fleProblemSecondCallsign(String token) {
    return 'A second callsign: $token. One QSO per line.';
  }

  @override
  String fleProblemDuplicateSegment(String token) {
    return 'Twice on one line: $token';
  }

  @override
  String fleProblemReportBeforeCall(String token) {
    return 'Reports come after the callsign: $token';
  }

  @override
  String fleProblemTooManyReports(String token) {
    return 'More than two reports: $token';
  }

  @override
  String fleProblemInvalidReport(String token) {
    return 'Report does not fit the mode: $token';
  }

  @override
  String fleProblemInvalidFieldName(String token) {
    return 'Not a field name: $token';
  }

  @override
  String fleProblemReservedField(String token) {
    return 'This field cannot be set here: $token';
  }

  @override
  String fleProblemValueTooLong(String token) {
    return 'Too long: $token';
  }

  @override
  String get fleProblemLineTooLong => 'The line is too long';

  @override
  String get fleProblemTooManyLines => 'Too many lines. The rest was not read.';

  @override
  String get fleLogFailed =>
      'The QSOs could not be logged. Nothing was logged.';

  @override
  String get fleNoStation => 'Choose a station location first.';

  @override
  String get settingsFieldMode => 'Field mode';

  @override
  String get settingsFieldModeHint => 'Sunlight, big buttons, less battery use';

  @override
  String get fieldModeIntro =>
      'For operating outdoors: one switch sets the sunlight theme, glove mode, the battery saver and keeps the screen on. Switching it off puts your theme and button size back. You can also set each part on its own below.';

  @override
  String get fieldModeSwitch => 'Field mode';

  @override
  String get fieldModeSwitchHint => 'Sets the four options below together';

  @override
  String get fieldModeParts => 'The parts';

  @override
  String get fieldModeSunlight => 'Sunlight theme (maximum contrast)';

  @override
  String get fieldModeBatterySaver => 'Battery saver';

  @override
  String get fieldModeBatterySaverHint =>
      'The tide stands still and the clock updates once a minute. Sync still runs when you open the app, when the network returns and when you ask.';

  @override
  String get fieldModeKeepScreenOn => 'Keep the screen on while logging';

  @override
  String get fieldModeKeepScreenOnHint =>
      'Only while the log, Fast Log Entry or the contest screen is open. This uses more battery.';
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
  String get actionHideKeyboard => '[Ĥîðé ķéýƀöáŕð······]';

  @override
  String get navCallsigns => '[Çáļļšîĝñš····]';

  @override
  String get navSync => '[Šýñç··]';

  @override
  String get navSettings => '[Šéţţîñĝš····]';

  @override
  String get logEmptyTitle => '[Ñö ǪŠÖš ýéţ·····]';

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
  String get commandGoToCallsigns => '[Ĝö ţö çáļļšîĝñš······]';

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
  String get legacyDatabaseTitle =>
      '[Ýöûŕ éáŕļîéŕ ļöĝ çöûļð ñöţ ƀé çáŕŕîéð öṽéŕ·················]';

  @override
  String get legacyDatabaseBody =>
      '[Ţĥîš ṽéŕšîöñ ñö ļöñĝéŕ éñçŕýþţš ţĥé ļöĝ ŵîţĥ îţš öŵñ ķéý, šö ţĥé ļöĝ öƒ ţĥé éáŕļîéŕ ṽéŕšîöñ çáñ\'ţ ƀé öþéñéð. Ţîðéļîñé šţáŕţéð ŵîţĥ áñ éɱþţý ļöĝ. Ţĥé öļð ƒîļé îš šţîļļ öñ ţĥîš ðéṽîçé ƀûţ îš ñöţ ûšéð. ǪŠÖš ţĥáţ ŵéŕé áļŕéáðý šýñçéð áŕé šţîļļ îñ ýöûŕ Ŵáṽéļöĝ ļöĝƀööķ.··········································································································]';

  @override
  String get startupErrorTitle => '[Ţîðéļîñé çöûļðñ\'ţ šţáŕţ··········]';

  @override
  String get startupErrorBody =>
      '[Šöɱéţĥîñĝ ŵéñţ ŵŕöñĝ ŵĥîļé öþéñîñĝ ýöûŕ ļöĝ. Ýöûŕ ǪŠÖš ĥáṽé ñöţ ƀééñ çĥáñĝéð. Þļéášé ŕéšţáŕţ ţĥé áþþ; îƒ ţĥîš ķééþš ĥáþþéñîñĝ, ŕéþöŕţ îţ öñ ĜîţĤûƀ.···························································]';

  @override
  String get shortcutsUnbound => '[Ñöţ áššîĝñéð·····]';

  @override
  String get shortcutsOr => '[öŕ·]';

  @override
  String get onboardingWelcomeTitle => '[Ŵéļçöɱé ţö Ţîðéļîñé········]';

  @override
  String get onboardingWelcomeBody =>
      '[Ţîðéļîñé šáṽéš ýöûŕ ǪŠÖš öñ ţĥîš ðéṽîçé ƒîŕšţ, ŵîţĥ öŕ ŵîţĥöûţ á çöññéçţîöñ, áñð šýñçš ţĥéɱ ţö ýöûŕ öŵñ Ŵáṽéļöĝ šéŕṽéŕ ŵĥéñéṽéŕ îţ çáñ ŕéáçĥ îţ. Ýöûŕ ļöĝ îš ñéṽéŕ šéñţ áñýŵĥéŕé éļšé.·········································································]';

  @override
  String get onboardingStart => '[Çöññéçţ ţö Ŵáṽéļöĝ········]';

  @override
  String get onboardingTryDemo =>
      '[Ţŕý ţĥé ðéɱö (ñö Ŵáṽéļöĝ ñééðéð)·············]';

  @override
  String get onboardingDemoHint =>
      '[Ţĥé ðéɱö ŕûñš éñţîŕéļý öñ ţĥîš ðéṽîçé ŵîţĥ á ɱáðé-ûþ šţáţîöñ. Ñöţĥîñĝ îš šéñţ áñýŵĥéŕé, áñð ýöû çáñ ŕéɱöṽé îţ ļáţéŕ.···············································]';

  @override
  String get accountDemoLabel => '[Ðéɱö··]';

  @override
  String get accountDemoNote =>
      '[Ðéɱö áççöûñţ: ñö šéŕṽéŕ, ñöţĥîñĝ ļéáṽéš ţĥîš ðéṽîçé·····················]';

  @override
  String onboardingStepOf(int current, int total) {
    return '[Šţéþ ··]$current[ öƒ ··]$total';
  }

  @override
  String get onboardingServerTitle => '[Ýöûŕ Ŵáṽéļöĝ šéŕṽéŕ········]';

  @override
  String get onboardingServerBody =>
      '[Éñţéŕ ţĥé áððŕéšš ýöû ûšé ţö öþéñ Ŵáṽéļöĝ îñ ýöûŕ ƀŕöŵšéŕ. Ŵáṽéļöĝ 3.1 öŕ ñéŵéŕ îš ñééðéð.····································]';

  @override
  String get fieldServerUrl => '[Šéŕṽéŕ áððŕéšš······]';

  @override
  String get fieldServerUrlHint => '[ĥţţþš://ļöĝ.éẋáɱþļé.öŕĝ··········]';

  @override
  String get fieldAccountLabel =>
      '[Ñáɱé ƒöŕ ţĥîš áççöûñţ (öþţîöñáļ)·············]';

  @override
  String get fieldAccountLabelHint =>
      '[Ƒöŕ éẋáɱþļé Þéŕšöñáļ öŕ Çļûƀ šţáţîöñ···············]';

  @override
  String get onboardingAllowHttp =>
      '[Åļļöŵ áñ ûñéñçŕýþţéð çöññéçţîöñ (ļöçáļ ñéţŵöŕķ öñļý)·····················]';

  @override
  String get onboardingAllowHttpWarning =>
      '[Öñļý ƒöŕ á šéŕṽéŕ îñ ýöûŕ öŵñ ñéţŵöŕķ. Ýöûŕ ţöķéñ áñð ǪŠÖš ţŕáṽéļ ŵîţĥöûţ éñçŕýþţîöñ. Ñéṽéŕ ûšé ţĥîš öṽéŕ ţĥé îñţéŕñéţ.················································]';

  @override
  String get actionContinue => '[Çöñţîñûé····]';

  @override
  String get actionBack => '[Ɓáçķ··]';

  @override
  String get onboardingTokenTitle => '[ÅÞÎ ţöķéñ····]';

  @override
  String get onboardingTokenBody =>
      '[Îñ Ŵáṽéļöĝ, öþéñ ýöûŕ ûšéŕ ɱéñû, çĥööšé ÅÞÎ áñð çŕéáţé á ñéŵ ṽ2 ţöķéñ. Þášţé îţ ĥéŕé. Îţ šţáŕţš ŵîţĥ ŵļ2_ áñð îš ķéþţ öñļý îñ ţĥîš ðéṽîçé\'š šéçûŕé šţöŕáĝé.······························································]';

  @override
  String get fieldToken => '[ÅÞÎ ţöķéñ····]';

  @override
  String get onboardingScopesRequired => '[Ŕéǫûîŕéð þéŕɱîššîöñš········]';

  @override
  String get onboardingScopesOptional => '[Öþţîöñáļ þéŕɱîššîöñš········]';

  @override
  String get scopeQsoWrite =>
      '[ǫšö:ŵŕîţé – ûþļöáð ýöûŕ ǪŠÖš áñð çöŕŕéçţ ûþļöáðéð öñéš······················]';

  @override
  String get scopeQsoRead =>
      '[ǫšö:ŕéáð – çĥéçķ ţĥé šéŕṽéŕ ƀéƒöŕé šéñðîñĝ áĝáîñ, šö ñöţĥîñĝ îš ðûþļîçáţéð······························]';

  @override
  String get scopeStationRead =>
      '[šţáţîöñ:ŕéáð – ļîšţ ýöûŕ šţáţîöñ ļöçáţîöñš·················]';

  @override
  String get scopeQsoDelete =>
      '[ǫšö:ðéļéţé – áļšö ðéļéţé îñ Ŵáṽéļöĝ ŵĥáţ ýöû ðéļéţé îñ Ţîðéļîñé··························]';

  @override
  String get scopeContest =>
      '[çöñţéšţ:ŕéáð áñð çöñţéšţ:ŵŕîţé – çöñţéšţ šéššîöñš îñ Ŵáṽéļöĝ (3.2 öŕ ñéŵéŕ)······························]';

  @override
  String get scopeLookup =>
      '[ļööķûþ:ŕéáð – öñļîñé çáļļšîĝñ ļööķûþš ŵĥîļé çöññéçţéð······················]';

  @override
  String get scopeGranted => '[ĝŕáñţéð···]';

  @override
  String get scopeMissing => '[ɱîššîñĝ···]';

  @override
  String get actionCheckToken => '[Çĥéçķ çöññéçţîöñ·······]';

  @override
  String get onboardingChecking => '[Çĥéçķîñĝ ýöûŕ šéŕṽéŕ…·········]';

  @override
  String get onboardingStationTitle => '[Šţáţîöñ ļöçáţîöñ·······]';

  @override
  String get onboardingStationBody =>
      '[Ñéŵ ǪŠÖš áŕé ûþļöáðéð ţö ţĥîš šţáţîöñ ļöçáţîöñ. Ýöû çáñ çĥööšé áñöţĥéŕ öñé ƒöŕ éáçĥ ǪŠÖ.····································]';

  @override
  String get onboardingServerVersion31 =>
      '[Çöññéçţéð ţö Ŵáṽéļöĝ 3.1. Çöñţéšţ šéššîöñš ñééð Ŵáṽéļöĝ 3.2 öŕ ñéŵéŕ.····························]';

  @override
  String get onboardingServerVersion32 =>
      '[Çöññéçţéð ţö Ŵáṽéļöĝ 3.2 öŕ ñéŵéŕ.··············]';

  @override
  String get onboardingNoStations =>
      '[Ýöûŕ Ŵáṽéļöĝ áççöûñţ ĥáš ñö šţáţîöñ ļöçáţîöñš ýéţ. Çŕéáţé öñé îñ Ŵáṽéļöĝ ûñðéŕ Šţáţîöñ Šéţûþ, ţĥéñ çĥéçķ áĝáîñ.·············································]';

  @override
  String get onboardingFinish => '[Šţáŕţ ļöĝĝîñĝ······]';

  @override
  String get problemInvalidUrl =>
      '[Ţĥáţ ðöéšñ\'ţ ļööķ ļîķé á ŵéƀ áððŕéšš. Ûšé ţĥé áððŕéšš ýöû öþéñ Ŵáṽéļöĝ ŵîţĥ, ƒöŕ éẋáɱþļé ĥţţþš://ļöĝ.éẋáɱþļé.öŕĝ.··············································]';

  @override
  String get problemInsecurePublicHttp =>
      '[Ûñéñçŕýþţéð ĥţţþ:// îš öñļý þöššîƀļé ƒöŕ šéŕṽéŕš îñ ýöûŕ öŵñ ñéţŵöŕķ. Ûšé ĥţţþš:// ƒöŕ šéŕṽéŕš öñ ţĥé îñţéŕñéţ.·············································]';

  @override
  String get problemHttpNeedsOptIn =>
      '[Ţĥîš áððŕéšš ûšéš ûñéñçŕýþţéð ĥţţþ://. Šŵîţçĥ öñ “Åļļöŵ áñ ûñéñçŕýþţéð çöññéçţîöñ” îƒ ţĥé šéŕṽéŕ îš îñ ýöûŕ öŵñ ñéţŵöŕķ.················································]';

  @override
  String get problemUnreachable =>
      '[Ţĥé šéŕṽéŕ ðîðñ\'ţ áñšŵéŕ. Çĥéçķ ţĥé áððŕéšš áñð ýöûŕ çöññéçţîöñ. Ýöû çáñ áļšö šéţ Ţîðéļîñé ûþ ļáţéŕ.········································]';

  @override
  String get problemNoApiV2 =>
      '[Ţĥîš šéŕṽéŕ áñšŵéŕš, ƀûţ ñöţ ļîķé Ŵáṽéļöĝ 3.1 öŕ ñéŵéŕ. Çĥéçķ ţĥé áððŕéšš, öŕ ûþðáţé Ŵáṽéļöĝ.······································]';

  @override
  String get problemTokenInvalid =>
      '[Ŵáṽéļöĝ ðöéšñ\'ţ áççéþţ ţĥîš ţöķéñ. Çöþý îţ áĝáîñ (îţ šţáŕţš ŵîţĥ ŵļ2_) öŕ çŕéáţé á ñéŵ öñé.·····································]';

  @override
  String get problemTokenExpired =>
      '[Ţĥîš ţöķéñ ĥáš éẋþîŕéð. Çŕéáţé á ñéŵ öñé îñ Ŵáṽéļöĝ.·····················]';

  @override
  String problemMissingScopes(Object scopes) {
    return '[Ţĥîš ţöķéñ îš ɱîššîñĝ þéŕɱîššîöñš Ţîðéļîñé ñééðš: ····················]$scopes[. Çŕéáţé á ţöķéñ ţĥáţ îñçļûðéš ţĥéɱ.···············]';
  }

  @override
  String get problemServerError =>
      '[Ţĥé šéŕṽéŕ ŕéþöŕţéð á þŕöƀļéɱ. Þļéášé ţŕý áĝáîñ îñ á ɱöɱéñţ.························]';

  @override
  String get problemCertificateRejected =>
      '[Ţĥé çöññéçţîöñ îšñ\'ţ ţŕûšţéð, šö ñöţĥîñĝ ŵáš šéñţ. Îƒ ţĥîš îš ýöûŕ öŵñ šéŕṽéŕ, çĥéçķ îţš çéŕţîƒîçáţé áñð ţŕý áĝáîñ.··············································]';

  @override
  String get certTitle => '[Ûñķñöŵñ çéŕţîƒîçáţé········]';

  @override
  String get certBody =>
      '[Ýöûŕ ðéṽîçé ðöéšñ\'ţ ţŕûšţ ţĥîš šéŕṽéŕ\'š çéŕţîƒîçáţé. Ţĥáţ îš çöɱɱöñ ƒöŕ šéļƒ-ĥöšţéð šéŕṽéŕš. Öñļý çöñţîñûé îƒ ţĥé ƒîñĝéŕþŕîñţ ƀéļöŵ ɱáţçĥéš ţĥé öñé öƒ ýöûŕ šéŕṽéŕ. Îƒ îţ éṽéŕ çĥáñĝéš, Ţîðéļîñé ŵîļļ šţöþ áñð ášķ ýöû áĝáîñ.·························································································]';

  @override
  String get certFingerprint => '[ŠĤÅ-256 ƒîñĝéŕþŕîñţ········]';

  @override
  String certValidity(String from, String until) {
    return '[Ṽáļîð ƒŕöɱ ·····]$from[ ţö ··]$until';
  }

  @override
  String get certTrust => '[Ţŕûšţ ţĥîš çéŕţîƒîçáţé·········]';

  @override
  String get certCancel => '[Çáñçéļ···]';

  @override
  String get statusSynced => '[Šýñçéð···]';

  @override
  String get statusLocal => '[Öñ ðéṽîçé····]';

  @override
  String get statusQueued => '[Ŵáîţîñĝ···]';

  @override
  String get statusUploading => '[Ûþļöáðîñĝ····]';

  @override
  String get statusVerifying => '[Çĥéçķîñĝ····]';

  @override
  String get statusConflict => '[Ñééðš ðéçîšîöñ······]';

  @override
  String get statusBlocked => '[Ţöķéñ þŕöƀļéɱ······]';

  @override
  String get statusRejected => '[Ŕéĵéçţéð····]';

  @override
  String get unitMhz => '[ṀĤž··]';

  @override
  String get unitUtc => '[ÛŢÇ··]';

  @override
  String get fieldCallsign => '[Çáļļšîĝñ····]';

  @override
  String get fieldBand => '[Ɓáñð··]';

  @override
  String get fieldMode => '[Ṁöðé··]';

  @override
  String get fieldFrequency => '[Ƒŕéǫûéñçý····]';

  @override
  String freqReadoutInBand(String mhz, String band) {
    return '$mhz[ ṀĤž · ···]$band';
  }

  @override
  String freqReadoutOutsideBands(String mhz) {
    return '$mhz[ ṀĤž · öûţšîðé áɱáţéûŕ ƀáñðš············]';
  }

  @override
  String freqReadoutInBandKhz(String khz, String band) {
    return '$khz[ ķĤž · ···]$band';
  }

  @override
  String freqReadoutOutsideBandsKhz(String khz) {
    return '$khz[ ķĤž · öûţšîðé áɱáţéûŕ ƀáñðš············]';
  }

  @override
  String get freqReadoutUnreadable =>
      '[Ñöţ á ƒŕéǫûéñçý. Ţýþé ṀĤž (14.205) öŕ ķĤž (14205).····················]';

  @override
  String get freqReadoutEmpty =>
      '[Ţýþé ṀĤž (14.205) öŕ ķĤž (14205).··············]';

  @override
  String freqReadoutSemanticsInBand(String mhz, String band) {
    return '$mhz[ ɱéĝáĥéŕţž, ·····]$band';
  }

  @override
  String freqReadoutSemanticsOutsideBands(String mhz) {
    return '$mhz[ ɱéĝáĥéŕţž, öûţšîðé áɱáţéûŕ ƀáñðš··············]';
  }

  @override
  String freqReadoutSemanticsInBandKhz(String khz, String band) {
    return '$khz[ ķîļöĥéŕţž, ·····]$band';
  }

  @override
  String freqReadoutSemanticsOutsideBandsKhz(String khz) {
    return '$khz[ ķîļöĥéŕţž, öûţšîðé áɱáţéûŕ ƀáñðš··············]';
  }

  @override
  String get fieldRstSent => '[ŔŠŢ šéñţ····]';

  @override
  String get fieldRstRcvd => '[ŔŠŢ ŕéçéîṽéð·····]';

  @override
  String get fieldName => '[Ñáɱé··]';

  @override
  String get fieldGrid => '[Ļöçáţöŕ···]';

  @override
  String get fieldComment => '[Çöɱɱéñţ···]';

  @override
  String get fieldStation => '[Šţáţîöñ ļöçáţîöñ·······]';

  @override
  String get fieldDateUtc => '[Ðáţé áñð ţîɱé······]';

  @override
  String get fieldCountry => '[ÐẊÇÇ éñţîţý·····]';

  @override
  String get issueInvalidCall =>
      '[Éñţéŕ á çáļļšîĝñ, ƒöŕ éẋáɱþļé ÐĻ1ÅƁÇ öŕ ÉÅ8/ÐĻ1ÅƁÇ/Þ.······················]';

  @override
  String get issueMissingBand =>
      '[Çĥööšé á ƀáñð öŕ éñţéŕ á ƒŕéǫûéñçý.··············]';

  @override
  String get issueMissingMode => '[Çĥööšé á ɱöðé.······]';

  @override
  String get issueInvalidFrequency =>
      '[Éñţéŕ ţĥé ƒŕéǫûéñçý îñ ṀĤž (14.205) öŕ ķĤž (14205).·····················]';

  @override
  String get issueFrequencyOutsideBand =>
      '[Ţĥîš ƒŕéǫûéñçý îš öûţšîðé ţĥé šéļéçţéð ƀáñð.··················]';

  @override
  String get issueInvalidGrid =>
      '[Å ļöçáţöŕ ĥáš 4, 6 öŕ 8 çĥáŕáçţéŕš, ļîķé ĴÖ40 öŕ ĴÖ40ĥð.·······················]';

  @override
  String get issueNoStation =>
      '[Šáṽéð. Çĥööšé á šţáţîöñ ļöçáţîöñ šö ţĥîš ǪŠÖ çáñ ƀé ûþļöáðéð.·························]';

  @override
  String get issueTimeInFuture =>
      '[Šáṽéð, ƀûţ ţĥé ţîɱé îš îñ ţĥé ƒûţûŕé. Çĥéçķ ýöûŕ ðéṽîçé çļöçķ.·························]';

  @override
  String qsoLoggedAnnouncement(String call) {
    return '[ǪŠÖ ŵîţĥ ····]$call[ ļöĝĝéð.····]';
  }

  @override
  String timeNow(String time) {
    return '[Ñöŵ: ··]$time';
  }

  @override
  String timeManual(String time) {
    return '[Šéţ: ··]$time';
  }

  @override
  String get actionChangeTime => '[Çĥáñĝé ţîɱé·····]';

  @override
  String get actionUseNow => '[Ûšé çûŕŕéñţ ţîɱé·······]';

  @override
  String dxccSummary(String name, String continent, int cq, int itu) {
    return '$name[ · ··]$continent[ · ÇǪ ···]$cq[ · ÎŢÛ ···]$itu';
  }

  @override
  String workedBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '[ŵöŕķéð ···]$count[ ţîɱéš ƀéƒöŕé······]',
      one: '[ŵöŕķéð öñçé ƀéƒöŕé········]',
    );
    return '$_temp0';
  }

  @override
  String get explainSynced =>
      '[Ţĥîš ǪŠÖ îš šáƒéļý îñ ýöûŕ Ŵáṽéļöĝ.··············]';

  @override
  String get explainLocal =>
      '[Šáṽéð öñ ţĥîš ðéṽîçé öñļý. Çĥööšé á šţáţîöñ ļöçáţîöñ šö îţ çáñ ƀé ûþļöáðéð.······························]';

  @override
  String get explainQueued =>
      '[Šáṽéð öñ ţĥîš ðéṽîçé áñð ŵáîţîñĝ ƒöŕ ţĥé ñéẋţ šýñç.·····················]';

  @override
  String get explainUploading =>
      '[Ɓéîñĝ šéñţ ţö Ŵáṽéļöĝ ŕîĝĥţ ñöŵ.·············]';

  @override
  String get explainVerifying =>
      '[Ţĥé ļášţ áţţéɱþţ ðîðñ\'ţ ƒîñîšĥ çļéáñļý. Ţîðéļîñé çĥéçķš ýöûŕ Ŵáṽéļöĝ ƀéƒöŕé ţŕýîñĝ áĝáîñ, šö ţĥé ǪŠÖ îš ñéṽéŕ ðûþļîçáţéð.·················································]';

  @override
  String get explainConflict => '[Ţĥîš ǪŠÖ ñééðš ýöûŕ ðéçîšîöñ.············]';

  @override
  String get explainRejected =>
      '[Ŵáṽéļöĝ ðîðñ\'ţ áççéþţ ţĥîš ǪŠÖ. Çöŕŕéçţ îţ áñð îţ ŵîļļ ƀé šéñţ áĝáîñ.····························]';

  @override
  String get explainBlocked =>
      '[Ŵáîţîñĝ ûñţîļ ţĥé áççöûñţ\'š ţöķéñ ŵöŕķš áĝáîñ. Ñöţĥîñĝ îš ļöšţ.··························]';

  @override
  String get problemSyncNetwork =>
      '[Ýöûŕ Ŵáṽéļöĝ ŵášñ\'ţ ŕéáçĥáƀļé; Ţîðéļîñé ŵîļļ ţŕý áĝáîñ.······················]';

  @override
  String get problemSyncRateLimited =>
      '[Ýöûŕ Ŵáṽéļöĝ ášķéð Ţîðéļîñé ţö šļöŵ ðöŵñ; îţ ŵîļļ çöñţîñûé áûţöɱáţîçáļļý.······························]';

  @override
  String get problemSyncServerError =>
      '[Ýöûŕ Ŵáṽéļöĝ ŕéþöŕţéð áñ îñţéŕñáļ éŕŕöŕ.················]';

  @override
  String get problemSyncInvalidData =>
      '[Ŵáṽéļöĝ ƒöûñð á þŕöƀļéɱ ŵîţĥ ţĥé ǪŠÖ\'š ðáţá.··················]';

  @override
  String get problemSyncStationNotAllowed =>
      '[Ţĥé šţáţîöñ ļöçáţîöñ ðöéšñ\'ţ éẋîšţ îñ Ŵáṽéļöĝ áñýɱöŕé, öŕ ţĥé ţöķéñ çáñ\'ţ ûšé îţ. Çĥööšé áñöţĥéŕ öñé.·········································]';

  @override
  String get problemSyncMissingPermission =>
      '[Ţĥé ţöķéñ ļáçķš á þéŕɱîššîöñ ƒöŕ ţĥîš. Çŕéáţé á ţöķéñ ŵîţĥ ţĥé þéŕɱîššîöñš ļîšţéð îñ ţĥé ɱáñûáļ.·······································]';

  @override
  String get problemSyncTokenInvalid =>
      '[Ŵáṽéļöĝ ñö ļöñĝéŕ áççéþţš ţĥé ţöķéñ. Éñţéŕ á ñéŵ öñé îñ Šéţţîñĝš.··························]';

  @override
  String get problemSyncTokenExpired =>
      '[Ţĥé ţöķéñ ĥáš éẋþîŕéð. Éñţéŕ á ñéŵ öñé îñ Šéţţîñĝš.·····················]';

  @override
  String get problemSyncReadOnlyFields =>
      '[Ýöû çĥáñĝéð ţĥé ţîɱé, ɱöðé, ƒŕéǫûéñçý öŕ šţáţîöñ. Ŵáṽéļöĝ çáñ\'ţ çĥáñĝé ţĥéšé öñ áñ ûþļöáðéð ǪŠÖ.·······································]';

  @override
  String get problemSyncSameMinuteTwin =>
      '[Åñöţĥéŕ ǪŠÖ ŵîţĥ ţĥé šáɱé çáļļšîĝñ, ƀáñð áñð ɱöðé îñ ţĥé šáɱé ɱîñûţé îš áļŕéáðý îñ Ŵáṽéļöĝ, ŵĥîçĥ çáñ šţöŕé öñļý öñé öƒ ţĥéɱ. Çöŕŕéçţ ţĥé ţîɱé îƒ ţĥîš îš á šéþáŕáţé çöñţáçţ, öŕ ðéļéţé öñé.············································································]';

  @override
  String get qsoNotFound => '[Ţĥîš ǪŠÖ ñö ļöñĝéŕ éẋîšţš.···········]';

  @override
  String get qsoDetails => '[ǪŠÖ ðéţáîļš·····]';

  @override
  String serverSaid(String message) {
    return '[Ŵáṽéļöĝ šáîð: ······]$message';
  }

  @override
  String get conflictReplace => '[Ŕéþļáçé îñ Ŵáṽéļöĝ········]';

  @override
  String get conflictKeepServer => '[Î\'ļļ ƒîẋ îţ îñ Ŵáṽéļöĝ·········]';

  @override
  String get conflictReplaceNeedsDelete =>
      '[Ŕéþļáçîñĝ ñééðš á ţöķéñ ŵîţĥ ţĥé ǫšö:ðéļéţé þéŕɱîššîöñ.······················]';

  @override
  String get actionDeleteQso => '[Ðéļéţé ǪŠÖ····]';

  @override
  String get deleteQsoTitle => '[Ðéļéţé ţĥîš ǪŠÖ?·······]';

  @override
  String get deleteQsoBody =>
      '[Îţ ŵîļļ ƀé ŕéɱöṽéð ƒŕöɱ ţĥîš ðéṽîçé áñð, îƒ îţ ŵáš ûþļöáðéð, ƒŕöɱ ýöûŕ Ŵáṽéļöĝ.································]';

  @override
  String get deleteQsoLocalOnly =>
      '[Îţ ŵîļļ ƀé ŕéɱöṽéð ƒŕöɱ ţĥîš ðéṽîçé. Ţĥé çöþý îñ Ŵáṽéļöĝ šţáýš, ƀéçáûšé ţĥé ţöķéñ ĥáš ñö ðéļéţé þéŕɱîššîöñ.···········································]';

  @override
  String get syncHistory => '[Šýñç ĥîšţöŕý·····]';

  @override
  String get journalLogged => '[Ļöĝĝéð öñ ţĥîš ðéṽîçé·········]';

  @override
  String get journalImported => '[Îɱþöŕţéð ƒŕöɱ á ƒîļé········]';

  @override
  String get journalEditQueued => '[Çĥáñĝé ŵáîţîñĝ ƒöŕ ûþļöáð··········]';

  @override
  String get journalRequestStarted => '[Šéñðîñĝ ţö Ŵáṽéļöĝ········]';

  @override
  String get journalUploaded => '[Šţöŕéð îñ Ŵáṽéļöĝ·······]';

  @override
  String get journalPatched => '[Çĥáñĝé áþþļîéð îñ Ŵáṽéļöĝ··········]';

  @override
  String get journalDeletedOnServer => '[Ðéļéţéð îñ Ŵáṽéļöĝ········]';

  @override
  String get journalDeletedLocallyOnly =>
      '[Ðéļéţéð ĥéŕé; ţĥé Ŵáṽéļöĝ çöþý šţáýš (ñö ðéļéţé þéŕɱîššîöñ)························]';

  @override
  String get journalVerified =>
      '[Ƒöûñð îñ Ŵáṽéļöĝ, ñö ðûþļîçáţé çŕéáţéð················]';

  @override
  String get journalNotOnServer =>
      '[Ñöţ îñ Ŵáṽéļöĝ ýéţ, ŵîļļ ƀé šéñţ·············]';

  @override
  String get journalRetry => '[Ŵîļļ ţŕý áĝáîñ ļáţéŕ········]';

  @override
  String get journalRejected => '[Ŕéĵéçţéð ƀý Ŵáṽéļöĝ········]';

  @override
  String get journalConflict => '[Ñééðš ýöûŕ ðéçîšîöñ········]';

  @override
  String get journalConflictResolved => '[Ðéçîšîöñ ɱáðé······]';

  @override
  String get journalAccountBlocked => '[Ţöķéñ šţöþþéð ŵöŕķîñĝ·········]';

  @override
  String get journalRunStarted => '[Šýñç šţáŕţéð·····]';

  @override
  String get journalRunFinished => '[Šýñç ƒîñîšĥéð······]';

  @override
  String get journalContestSessionCreated =>
      '[Çöñţéšţ šéššîöñ çŕéáţéð öñ Ŵáṽéļöĝ··············]';

  @override
  String get journalContestQsosLinked =>
      '[ǪŠÖš ļîñķéð ţö ţĥé Ŵáṽéļöĝ çöñţéšţ šéššîöñ·················]';

  @override
  String get journalContestSessionLocalOnly =>
      '[Çöñţéšţ šéššîöñ ķéþţ öñ ţĥîš ðéṽîçé öñļý················]';

  @override
  String get journalContestSessionRetry =>
      '[Çöñţéšţ šéššîöñ ñöţ šýñçéð ýéţ; ŵîļļ ŕéţŕý·················]';

  @override
  String get logEmptyBodyReady =>
      '[Ļöĝ ýöûŕ ƒîŕšţ ǪŠÖ áƀöṽé. Îţ îš šáṽéð öñ ţĥîš ðéṽîçé ŕîĝĥţ áŵáý, ŵîţĥ öŕ ŵîţĥöûţ á çöññéçţîöñ.······································]';

  @override
  String get recentQsos => '[Ŕéçéñţ ǪŠÖš·····]';

  @override
  String certSubjectLine(String value) {
    return '[Îššûéð ţö: ·····]$value';
  }

  @override
  String certIssuerLine(String value) {
    return '[Îššûéð ƀý: ·····]$value';
  }

  @override
  String get syncRunning => '[Šýñçîñĝ ŵîţĥ ýöûŕ Ŵáṽéļöĝ…···········]';

  @override
  String syncCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '[Šýñçéð ···]$count[ ǪŠÖš.···]',
      one: '[Šýñçéð 1 ǪŠÖ.······]',
      zero: '[Éṽéŕýţĥîñĝ îš ûþ ţö ðáţé.··········]',
    );
    return '$_temp0';
  }

  @override
  String get syncOffline =>
      '[Ýöûŕ Ŵáṽéļöĝ îšñ\'ţ ŕéáçĥáƀļé ŕîĝĥţ ñöŵ. Ýöûŕ ǪŠÖš áŕé šáƒé öñ ţĥîš ðéṽîçé áñð ŵîļļ šýñç ļáţéŕ.······································]';

  @override
  String get syncBlocked =>
      '[Ţĥé ţöķéñ ñö ļöñĝéŕ ŵöŕķš. Éñţéŕ á ñéŵ öñé îñ Šéţţîñĝš; ñöţĥîñĝ îš ļöšţ.·····························]';

  @override
  String get syncRateLimited =>
      '[Ýöûŕ Ŵáṽéļöĝ ášķéð ƒöŕ á þáûšé. Šýñç çöñţîñûéš áûţöɱáţîçáļļý.·························]';

  @override
  String syncNeedsReview(int count) {
    return '$count[ ñéŵ ǪŠÖš áŕé ŕéáðý. Þļéášé ŕéṽîéŵ ţĥé ûþļöáð ƒîŕšţ.·····················]';
  }

  @override
  String get actionPreviewUpload => '[Þŕéṽîéŵ ûþļöáð······]';

  @override
  String get previewTitle => '[Ɓéƒöŕé ûþļöáðîñĝ·······]';

  @override
  String previewToUpload(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count[ ǪŠÖš ŵîļļ ƀé ûþļöáðéð.··········]',
      one: '[1 ǪŠÖ ŵîļļ ƀé ûþļöáðéð.··········]',
    );
    return '$_temp0';
  }

  @override
  String previewDuplicates(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count[ ļööķ ļîķé ðûþļîçáţéš öƒ ǪŠÖš ýöû áļŕéáðý ĥáṽé; Ŵáṽéļöĝ ŵîļļ ķééþ öñļý öñé öƒ éáçĥ.··································]',
      one: '[1 ļööķš ļîķé á ðûþļîçáţé öƒ á ǪŠÖ ýöû áļŕéáðý ĥáṽé; Ŵáṽéļöĝ ŵîļļ ķééþ öñļý öñé.································]',
    );
    return '$_temp0';
  }

  @override
  String previewServerParsed(int parsed, int total) {
    return '[Ŵáṽéļöĝ\'š ţéšţ ŕûñ áççéþţéð ············]$parsed[ öƒ ··]$total[.·]';
  }

  @override
  String get previewServerUnreachable =>
      '[Ŵáṽéļöĝ çöûļðñ\'ţ ƀé ášķéð ŕîĝĥţ ñöŵ; ţĥé ûþļöáð ŵîļļ çĥéçķ éáçĥ ǪŠÖ áñýŵáý.······························]';

  @override
  String get previewSafety =>
      '[Éáçĥ ǪŠÖ îš çĥéçķéð áĝáîñšţ ýöûŕ Ŵáṽéļöĝ ƀéƒöŕé áñý ŕéţŕý, šö ñöţĥîñĝ îš šéñţ ţŵîçé.··································]';

  @override
  String get previewUpload => '[Ûþļöáð···]';

  @override
  String get settingsAccount => '[Ŵáṽéļöĝ áççöûñţ······]';

  @override
  String get settingsData => '[Îɱþöŕţ, éẋþöŕţ áñð ƀáçķûþ··········]';

  @override
  String get settingsSecurity => '[Šéçûŕîţý····]';

  @override
  String get accountPinned =>
      '[Ûšéš á çéŕţîƒîçáţé ýöû ţŕûšţéð ɱáñûáļļý················]';

  @override
  String accountTokenExpires(String date) {
    return '[Ţöķéñ éẋþîŕéš öñ ·······]$date';
  }

  @override
  String get accountTokenNoExpiry => '[Ţöķéñ ŵîţĥöûţ éẋþîŕý ðáţé··········]';

  @override
  String get actionReplaceToken => '[Éñţéŕ á ñéŵ ţöķéñ·······]';

  @override
  String get tokenReplaced => '[Ñéŵ ţöķéñ šáṽéð. Šýñçîñĝ…··········]';

  @override
  String get actionRemoveAccount =>
      '[Ŕéɱöṽé áççöûñţ ƒŕöɱ ţĥîš ðéṽîçé·············]';

  @override
  String get removeAccountTitle => '[Ŕéɱöṽé ţĥîš áççöûñţ?········]';

  @override
  String get removeAccountBody =>
      '[Îţš ǪŠÖš áŕé ŕéɱöṽéð ƒŕöɱ ţĥîš ðéṽîçé. Ýöûŕ Ŵáṽéļöĝ îš ñöţ çĥáñĝéð.···························]';

  @override
  String removeAccountUnsynced(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count[ ǪŠÖš ĥáṽé ñöţ ŕéáçĥéð Ŵáṽéļöĝ ýéţ áñð ŵöûļð ƀé ļöšţ. Éẋþöŕţ öŕ ƀáçķ ûþ ƒîŕšţ.································]',
      one: '[1 ǪŠÖ ĥáš ñöţ ŕéáçĥéð Ŵáṽéļöĝ ýéţ áñð ŵöûļð ƀé ļöšţ. Éẋþöŕţ öŕ ƀáçķ ûþ ƒîŕšţ.·······························]',
    );
    return '$_temp0';
  }

  @override
  String get actionImportAdif => '[Îɱþöŕţ ÅÐÎƑ ƒîļé·······]';

  @override
  String get importAdifHint =>
      '[Ƒöŕ éẋáɱþļé á þáþéŕ ļöĝ ţýþéð îñ éļšéŵĥéŕé, öŕ áñöţĥéŕ ļöĝĝéŕ\'š éẋþöŕţ.·····························]';

  @override
  String get actionExportAdif => '[Éẋþöŕţ ļöĝ áš ÅÐÎƑ········]';

  @override
  String get exportAdifHint =>
      '[Ŕéáðáƀļé ƀý éṽéŕý ļöĝĝîñĝ þŕöĝŕáɱ. Ñöţ éñçŕýþţéð.····················]';

  @override
  String get exportDone => '[Ļöĝ éẋþöŕţéð.······]';

  @override
  String get actionCreateBackup => '[Çŕéáţé ƀáçķûþ······]';

  @override
  String get backupHint =>
      '[Éṽéŕýţĥîñĝ éẋçéþţ ýöûŕ ţöķéñ. Ţĥé ƒîļé îš ñöţ éñçŕýþţéð: ķééþ îţ šöɱéŵĥéŕé šáƒé.································]';

  @override
  String get backupDone => '[Ɓáçķûþ šáṽéð.······]';

  @override
  String get actionRestoreBackup => '[Ŕéšţöŕé á ƀáçķûþ·······]';

  @override
  String restoreDone(int added, int skipped) {
    return '[Ŕéšţöŕéð ····]$added[ ǪŠÖš (···]$skipped[ ŵéŕé áļŕéáðý ĥéŕé).········]';
  }

  @override
  String get restoreOldEncryptedBackup =>
      '[Ţĥîš ƀáçķûþ ŵáš éñçŕýþţéð ƀý áñ éáŕļîéŕ ṽéŕšîöñ öƒ Ţîðéļîñé. Ţĥîš ṽéŕšîöñ çáñ\'ţ öþéñ îţ áñý ɱöŕé.·······································]';

  @override
  String get restoreInvalidFile =>
      '[Ţĥîš ƒîļé îšñ\'ţ á Ţîðéļîñé ƀáçķûþ öŕ îš ðáɱáĝéð.····················]';

  @override
  String get importDoneTitle => '[Îɱþöŕţ ƒîñîšĥéð······]';

  @override
  String importImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count[ ǪŠÖš áððéð.·····]',
      one: '[1 ǪŠÖ áððéð.·····]',
    );
    return '$_temp0';
  }

  @override
  String importDuplicates(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count[ ŵéŕé áļŕéáðý îñ ýöûŕ ļöĝ áñð šķîþþéð.················]',
      one: '[1 ŵáš áļŕéáðý îñ ýöûŕ ļöĝ áñð šķîþþéð.················]',
    );
    return '$_temp0';
  }

  @override
  String importRejected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count[ ŕéçöŕðš ĥáð ñö ṽáļîð çáļļšîĝñ, ţîɱé, ƀáñð öŕ ɱöðé.·····················]',
      one: '[1 ŕéçöŕð ĥáð ñö ṽáļîð çáļļšîĝñ, ţîɱé, ƀáñð öŕ ɱöðé.·····················]',
    );
    return '$_temp0';
  }

  @override
  String importWarnings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '[Ţĥé ƒîļé ĥáð ······]$count[ ƒöŕɱáţţîñĝ þŕöƀļéɱš ţĥáţ ŵéŕé ŵöŕķéð áŕöûñð.··················]',
      one: '[Ţĥé ƒîļé ĥáð 1 ƒöŕɱáţţîñĝ þŕöƀļéɱ ţĥáţ ŵáš ŵöŕķéð áŕöûñð.·······················]',
    );
    return '$_temp0';
  }

  @override
  String importStation(String name) {
    return '[Îɱþöŕţéð ǪŠÖš ƀéļöñĝ ţö šţáţîöñ ļöçáţîöñ ·················]$name[.·]';
  }

  @override
  String get importTooLarge =>
      '[Ţĥîš ƒîļé îš ţöö ļáŕĝé ţö îɱþöŕţ (ɱáẋîɱûɱ 64 ṀƁ).····················]';

  @override
  String get settingsAppLock => '[Åþþ ļöçķ····]';

  @override
  String get settingsAppLockHint =>
      '[Åšķ ƒöŕ Ƒáçé ÎÐ, ƒîñĝéŕþŕîñţ öŕ ţĥé ðéṽîçé ÞÎÑ ŵĥéñ öþéñîñĝ Ţîðéļîñé.····························]';

  @override
  String get appLockTitle => '[Ţîðéļîñé îš ļöçķéð········]';

  @override
  String get appLockUnlock => '[Ûñļöçķ···]';

  @override
  String get appLockReason => '[Ûñļöçķ ýöûŕ ļöĝ······]';

  @override
  String get settingsReadingFont => '[Éášý-ţö-ŕéáð ƒöñţ·······]';

  @override
  String get settingsReadingFontHint =>
      '[Åţķîñšöñ Ĥýþéŕļéĝîƀļé: çļéáŕļý ðîšţîñçţ ļéţţéŕš šûçĥ áš 0 áñð Ö, 1, ļ áñð Î.·······························]';

  @override
  String get actionCancel => '[Çáñçéļ···]';

  @override
  String get actionClose => '[Çļöšé··]';

  @override
  String get actionSave => '[Šáṽé··]';

  @override
  String get commandWipeEntry => '[Ŵîþé éñţŕý····]';

  @override
  String get commandFocusCall => '[Ĝö ţö çáļļšîĝñ······]';

  @override
  String get commandToggleRates => '[Šĥöŵ öŕ ĥîðé šçöŕé áñð ŕáţéš············]';

  @override
  String get commandEndContest => '[Éñð çöñţéšţ šéššîöñ········]';

  @override
  String get commandOpenContest => '[Öþéñ çöñţéšţ ɱöðé·······]';

  @override
  String get contestTitle => '[Çöñţéšţ ɱöðé·····]';

  @override
  String get contestOpenAction => '[Çöñţéšţ ɱöðé·····]';

  @override
  String contestBannerActive(String name) {
    return '[Çöñţéšţ šéššîöñ áçţîṽé: ··········]$name';
  }

  @override
  String get contestBannerReturn => '[Ŕéţûŕñ ţö çöñţéšţ·······]';

  @override
  String get contestSetupTitle => '[Çöñţéšţ šéššîöñ······]';

  @override
  String get contestSetupLoadFailed =>
      '[Çöñţéšţš çöûļð ñöţ ƀé ļöáðéð············]';

  @override
  String get contestSetupLoadFailedBody =>
      '[Ýöûŕ ñöŕɱáļ ļöĝ šţîļļ ŵöŕķš. Ŕéšţáŕţ Ţîðéļîñé áñð ţŕý áĝáîñ.························]';

  @override
  String get contestSetupSessionRunning =>
      '[Å çöñţéšţ šéššîöñ îš áļŕéáðý ŕûññîñĝ. Éñð îţ ƀéƒöŕé ýöû šţáŕţ áñöţĥéŕ öñé.······························]';

  @override
  String get contestSetupChooseContest => '[Çöñţéšţ···]';

  @override
  String get contestSearchLabel => '[Šéáŕçĥ çöñţéšţš······]';

  @override
  String get contestSearchEmpty =>
      '[Ñö çöñţéšţ ɱáţçĥéš ýöûŕ šéáŕçĥ.·············]';

  @override
  String get contestSetupChooseHint =>
      '[Çĥööšé á çöñţéšţ ƒŕöɱ ţĥé ļîšţ ţö šéţ ûþ ţĥé šéššîöñ.······················]';

  @override
  String get contestBuiltin => '[Ɓûîļţ îñ····]';

  @override
  String get contestImported => '[Îɱþöŕţéð ƀý ýöû······]';

  @override
  String get contestSetupNeedStation =>
      '[Ţĥîš áççöûñţ ĥáš ñö šţáţîöñ ļöçáţîöñ ýéţ. Šýñç öñçé ţö ļöáð ýöûŕ Ŵáṽéļöĝ šţáţîöñ ļöçáţîöñš, ţĥéñ ţŕý áĝáîñ.···········································]';

  @override
  String get contestSetupStation => '[Šţáţîöñ···]';

  @override
  String get contestSetupExchange => '[Ṁý éẋçĥáñĝé·····]';

  @override
  String get contestSetupExchangeHelp =>
      '[Ţĥîš îš ŵĥáţ ýöû šéñð ţö éṽéŕý šţáţîöñ. Ţĥé šûĝĝéšţîöñš çöɱé ƒŕöɱ ýöûŕ šţáţîöñ ļöçáţîöñ; þļéášé çĥéçķ ţĥéɱ.···········································]';

  @override
  String get contestSetupRstAuto =>
      '[Ţĥé ŕéþöŕţ îš šéñţ áûţöɱáţîçáļļý: 59 ƒöŕ ṽöîçé, 599 ƒöŕ ÇŴ áñð ðîĝîţáļ ɱöðéš.·······························]';

  @override
  String get contestSetupSerialAuto =>
      '[Ţĥé šéŕîáļ ñûɱƀéŕ šţáŕţš áţ 1 áñð çöûñţš ûþ ŵîţĥ éṽéŕý ǪŠÖ. Å ñûɱƀéŕ îš ñéṽéŕ ûšéð ţŵîçé, éṽéñ îƒ ýöû ðéļéţé á ǪŠÖ.··············································]';

  @override
  String get contestSetupCabrillo => '[Çáƀŕîļļö çáţéĝöŕîéš········]';

  @override
  String get contestSetupCabrilloHelp =>
      '[Ţĥéšé ĝö îñţö ţĥé ĥéáðéŕ öƒ ţĥé Çáƀŕîļļö ļöĝ ýöû šéñð ţö ţĥé šþöñšöŕ. Ţĥé ṽáļûéš áŕé ƒîẋéð ţéŕɱš öƒ ţĥé Çáƀŕîļļö ƒöŕɱáţ.················································]';

  @override
  String get contestCatOperator => '[Öþéŕáţöŕ çáţéĝöŕý·······]';

  @override
  String get contestCatAssisted => '[Åššîšţáñçé····]';

  @override
  String get contestCatBand => '[Ɓáñð çáţéĝöŕý······]';

  @override
  String get contestCatMode => '[Ṁöðé çáţéĝöŕý······]';

  @override
  String get contestCatPower => '[Þöŵéŕ··]';

  @override
  String get contestCatStation => '[Šţáţîöñ ţýþé·····]';

  @override
  String get contestCatTransmitter => '[Ţŕáñšɱîţţéŕš·····]';

  @override
  String get contestCatOverlay => '[Öṽéŕļáý···]';

  @override
  String get contestCatNotSet => '[Ñöţ šéţ···]';

  @override
  String get contestStart => '[Šţáŕţ šéššîöñ······]';

  @override
  String get contestStartFailed =>
      '[Ţĥé šéššîöñ çöûļð ñöţ ƀé šţáŕţéð. Ñöţĥîñĝ ŵáš çĥáñĝéð. Ţŕý áĝáîñ.··························]';

  @override
  String get contestPastTitle => '[Þášţ šéššîöñš······]';

  @override
  String get contestPastEmpty => '[Ñö çöñţéšţ šéššîöñš ýéţ.··········]';

  @override
  String get contestStateActive => '[Ŕûññîñĝ···]';

  @override
  String get contestStateEnded => '[Éñðéð··]';

  @override
  String get contestReopen => '[Ŕéöþéñ···]';

  @override
  String get contestSessionsAction => '[Šéššîöñš····]';

  @override
  String get contestMissingTitle => '[Çöñţéšţ ŕûļéš ñöţ ƒöûñð··········]';

  @override
  String get contestMissingBody =>
      '[Ţĥé ŕûļéš ƒöŕ ţĥîš šéššîöñ áŕé ñö ļöñĝéŕ öñ ţĥîš ðéṽîçé. Ýöûŕ ǪŠÖš áŕé šáƒé. Éñð ţĥé šéššîöñ ţö çáŕŕý öñ.··········································]';

  @override
  String get contestEndTitle => '[Éñð ţĥé çöñţéšţ šéššîöñ?··········]';

  @override
  String get contestEndBody =>
      '[Ýöûŕ ǪŠÖš šţáý îñ ţĥé ļöĝ. Ýöû çáñ ŕéöþéñ ţĥé šéššîöñ ļáţéŕ ƒŕöɱ ţĥé šéššîöñ ļîšţ.·································]';

  @override
  String get contestKindRst => '[ŔŠŢ··]';

  @override
  String get contestKindSerial => '[Šéŕîáļ ñö.····]';

  @override
  String get contestKindCqZone => '[ÇǪ žöñé···]';

  @override
  String get contestKindItuZone => '[ÎŢÛ žöñé····]';

  @override
  String get contestKindGrid => '[Ĝŕîð··]';

  @override
  String get contestKindState => '[Šţáţé öŕ þŕöṽîñçé·······]';

  @override
  String get contestKindSection => '[Šéçţîöñ···]';

  @override
  String get contestKindDok => '[ÐÖĶ··]';

  @override
  String get contestKindPower => '[Þöŵéŕ··]';

  @override
  String get contestKindName => '[Ñáɱé··]';

  @override
  String get contestKindText => '[Éẋçĥáñĝé····]';

  @override
  String contestOptionalLabel(String label) {
    return '$label[ (öþţîöñáļ)·····]';
  }

  @override
  String contestErrorMissing(String label) {
    return '$label[ îš ŕéǫûîŕéð.······]';
  }

  @override
  String contestErrorInvalid(String label) {
    return '$label[ îš ñöţ ṽáļîð.······]';
  }

  @override
  String contestErrorOutOfRange(String label) {
    return '$label[ îš öûţ öƒ ŕáñĝé.·······]';
  }

  @override
  String get contestMultZone => '[Žöñé··]';

  @override
  String get contestMultItuZone => '[ÎŢÛ žöñé····]';

  @override
  String get contestMultDxcc => '[Çöûñţŕý···]';

  @override
  String get contestMultPrefix => '[Þŕéƒîẋ···]';

  @override
  String get contestMultState => '[Šţáţé öŕ þŕöṽîñçé·······]';

  @override
  String get contestMultDok => '[ÐÖĶ··]';

  @override
  String contestHintDupe(String bands, String modes) {
    return '[Ðûþé: áļŕéáðý ŵöŕķéð öñ ··········]$bands[ (·]$modes[)·]';
  }

  @override
  String contestHintWorkedElsewhere(String bands, String modes) {
    return '[Åļŕéáðý ŵöŕķéð öñ ········]$bands[ (·]$modes[); ñöţ á ðûþé ĥéŕé········]';
  }

  @override
  String contestHintNewMultiplier(String items) {
    return '[Ñéŵ ɱûļţîþļîéŕ: ·······]$items';
  }

  @override
  String get contestHintOutOfContest =>
      '[Öûţšîðé ţĥîš çöñţéšţ\'š ƀáñðš öŕ ɱöðéš: šçöŕéš 0 þöîñţš.······················]';

  @override
  String get contestHintLogWorked =>
      '[Îñ ýöûŕ ļöĝ: ŵöŕķéð ƀéƒöŕé öñ ţĥîš ƀáñð áñð ɱöðé····················]';

  @override
  String get contestHintLogNewBand =>
      '[Îñ ýöûŕ ļöĝ: ŵöŕķéð ƀéƒöŕé, ñéŵ ƀáñð···············]';

  @override
  String get contestHintLogNewMode =>
      '[Îñ ýöûŕ ļöĝ: ŵöŕķéð ƀéƒöŕé, ñéŵ ɱöðé···············]';

  @override
  String get contestHintLogNewSlot =>
      '[Îñ ýöûŕ ļöĝ: ŵöŕķéð ƀéƒöŕé, ñéŵ çöɱƀîñáţîöñ öƒ ƀáñð áñð ɱöðé························]';

  @override
  String get contestHintInScp =>
      '[Çáļļšîĝñ îš îñ ţĥé šûþéŕ çĥéçķ þáŕţîáļ ļîšţ··················]';

  @override
  String get contestHintScpMatches => '[Šûþéŕ çĥéçķ:·····]';

  @override
  String get contestHintNPlusOne => '[Ðîð ýöû ɱéáñ:······]';

  @override
  String contestUseCall(String call) {
    return '[Ûšé ··]$call';
  }

  @override
  String contestSentSummary(String items) {
    return '[Šéñţ: ···]$items';
  }

  @override
  String get contestSentNothing => '[Ñöţĥîñĝ ţö šéñð······]';

  @override
  String contestLoggedAnnouncement(String call, int serial, String dupe) {
    String _temp0 = intl.Intl.selectLogic(dupe, {
      'yes': '[, ðûþé···]',
      'other': '',
    });
    return '[Ļöĝĝéð ···]$call[, šéŕîáļ ····]$serial$_temp0';
  }

  @override
  String contestLoggedAnnouncementNoSerial(String call, String dupe) {
    String _temp0 = intl.Intl.selectLogic(dupe, {
      'yes': '[, ðûþé···]',
      'other': '',
    });
    return '[Ļöĝĝéð ···]$call$_temp0';
  }

  @override
  String get contestSaveFailed =>
      '[Ţĥé ǪŠÖ çöûļð ñöţ ƀé šáṽéð. Ŵĥáţ ýöû ţýþéð îš šţîļļ ĥéŕé. Ţŕý áĝáîñ.····························]';

  @override
  String get contestRecentTitle => '[Ŕéçéñţ ǪŠÖš·····]';

  @override
  String get contestRecentEmpty =>
      '[Ñö ǪŠÖš îñ ţĥîš šéššîöñ ýéţ. Ţýþé á çáļļšîĝñ áñð ţĥé éẋçĥáñĝé, ţĥéñ þŕéšš Éñţéŕ.································]';

  @override
  String contestRowExchange(String sent, String rcvd) {
    return '$sent[ → ··]$rcvd';
  }

  @override
  String get contestRowEditHint => '[Éðîţ ţĥîš ǪŠÖ······]';

  @override
  String get contestFlagDupe => '[Ðûþé··]';

  @override
  String get contestFlagMult => '[Ṁûļţ··]';

  @override
  String get contestFlagOut => '[Öûţ··]';

  @override
  String contestPoints(int points) {
    String _temp0 = intl.Intl.pluralLogic(
      points,
      locale: localeName,
      other: '$points[ þţš··]',
      one: '[1 þţ··]',
    );
    return '$_temp0';
  }

  @override
  String get contestEditTitle => '[Éðîţ ǪŠÖ····]';

  @override
  String contestEditSent(String items) {
    return '[Šéñţ (çáññöţ ƀé çĥáñĝéð): ···········]$items';
  }

  @override
  String get contestDeleteTitle => '[Ðéļéţé ţĥîš ǪŠÖ?·······]';

  @override
  String contestDeleteBody(String call) {
    return '$call[ ŵîļļ ƀé ŕéɱöṽéð ƒŕöɱ ţĥîš ðéṽîçé áñð ƒŕöɱ ţĥé çöñţéšţ šçöŕé.·························]';
  }

  @override
  String contestDeleteBodySerial(String call, String serial) {
    return '$call[ ŵîļļ ƀé ŕéɱöṽéð ƒŕöɱ ţĥîš ðéṽîçé áñð ƒŕöɱ ţĥé çöñţéšţ šçöŕé. Šéŕîáļ ····························]$serial[ šţáýš ûšéð áñð îš ñéṽéŕ ĝîṽéñ öûţ áĝáîñ.·················]';
  }

  @override
  String get contestPanelTitle => '[Šçöŕé áñð ŕáţéš······]';

  @override
  String contestPanelSummary(int qsos, int points, int score) {
    return '$qsos[ ǪŠÖš · ····]$points[ þöîñţš · éšţîɱáţé ········]$score';
  }

  @override
  String get contestQsos => '[ǪŠÖš··]';

  @override
  String get contestPointsLabel => '[Þöîñţš···]';

  @override
  String get contestMultipliers => '[Ṁûļţîþļîéŕš·····]';

  @override
  String get contestDupes => '[Ðûþéš··]';

  @override
  String get contestScoreEstimate => '[Çļáîɱéð šçöŕé (éšţîɱáţé)··········]';

  @override
  String get contestScoreEstimateNote =>
      '[Åñ éšţîɱáţé ƒöŕ ýöûŕ öŵñ ûšé. Ţĥé çöñţéšţ šþöñšöŕ\'š ļöĝ çĥéçķ ðéçîðéš ţĥé ŕéáļ ŕéšûļţ.···································]';

  @override
  String get contestRatesTitle => '[Ŕáţéš··]';

  @override
  String get contestRate10Min => '[Ļášţ 10 ɱîñûţéš······]';

  @override
  String get contestRate60Min => '[Ļášţ 60 ɱîñûţéš······]';

  @override
  String get contestRateLast10 => '[Ļášţ 10 ǪŠÖš·····]';

  @override
  String get contestRateLast100 => '[Ļášţ 100 ǪŠÖš······]';

  @override
  String get contestRateBest => '[Ɓéšţ 60 ɱîñûţéš······]';

  @override
  String contestRatePerHour(int rate) {
    return '$rate[/ĥ·]';
  }

  @override
  String contestRateBestValue(int count, String time, String utc) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count[ ǪŠÖš··]',
      one: '[1 ǪŠÖ··]',
    );
    return '$_temp0[ ƒŕöɱ ···]$time[ ·]$utc';
  }

  @override
  String get contestBandsTitle => '[Ɓý ƀáñð···]';

  @override
  String get contestBandsEmpty => '[Ñö šçöŕîñĝ ǪŠÖš ýéţ.········]';

  @override
  String contestLabelValue(String label, String value) {
    return '$label[: ·]$value';
  }

  @override
  String get commandExportCabrillo => '[Éẋþöŕţ Çáƀŕîļļö ļöĝ········]';

  @override
  String get contestMoreActions => '[Ṁöŕé áçţîöñš·····]';

  @override
  String get contestCatTime => '[Ţîɱé çáţéĝöŕý······]';

  @override
  String get cabrilloExportTitle => '[Éẋþöŕţ Çáƀŕîļļö ļöĝ········]';

  @override
  String get cabrilloIssuesIntro =>
      '[Ţĥé ļöĝ ĥáš þŕöƀļéɱš ţĥáţ çöñţéšţ çĥéçķéŕš ɱáý ŕéĵéçţ:······················]';

  @override
  String get cabrilloExportAnyway => '[Éẋþöŕţ áñýŵáý······]';

  @override
  String get cabrilloExportDone => '[Çáƀŕîļļö ļöĝ šáṽéð.········]';

  @override
  String get cabrilloExportFailed =>
      '[Ţĥé Çáƀŕîļļö ļöĝ çöûļð ñöţ ƀé çŕéáţéð öŕ šáṽéð.···················]';

  @override
  String get cabrilloUnavailableBanner =>
      '[Çáƀŕîļļö éẋþöŕţ îš ñöţ áṽáîļáƀļé: ţĥîš çöñţéšţ ĥáš ñö Çáƀŕîļļö ñáɱé.····························]';

  @override
  String cabrilloUnavailableBody(String contest) {
    return '$contest[ ĥáš ñö Çáƀŕîļļö çöñţéšţ ñáɱé îñ îţš ðéƒîñîţîöñ, šö ñö ļöĝ ţĥáţ á çöñţéšţ ŕöƀöţ ŵöûļð áççéþţ çáñ ƀé ŵŕîţţéñ. Åðð á çáƀŕîļļö ñáɱé ţö ţĥé ðéƒîñîţîöñ, öŕ ûšé ţĥé ÅÐÎƑ éẋþöŕţ îñ Šéţţîñĝš.··········································································]';
  }

  @override
  String get cabrilloIssueMissingContest =>
      '[Ţĥé çöñţéšţ ĥáš ñö Çáƀŕîļļö ñáɱé.··············]';

  @override
  String get cabrilloIssueMissingCallsign =>
      '[Ţĥé šţáţîöñ ĥáš ñö çáļļšîĝñ.············]';

  @override
  String get cabrilloIssueEmptyLog => '[Ţĥé šéššîöñ ĥáš ñö ǪŠÖš.··········]';

  @override
  String get cabrilloIssueExchangeCountMismatch =>
      '[Ţĥé éẋçĥáñĝé ĥáš á ðîƒƒéŕéñţ ñûɱƀéŕ öƒ îţéɱš ţĥáñ ţĥé ƒîŕšţ ǪŠÖ.··························]';

  @override
  String get cabrilloIssueMissingFrequency =>
      '[Ţĥé ƒŕéǫûéñçý öŕ ƀáñð çáññöţ ƀé ðéţéŕɱîñéð.··················]';

  @override
  String get cabrilloIssueMissingQsoCall => '[Å çáļļšîĝñ îš éɱþţý.········]';

  @override
  String get cabrilloIssueTokenContainsWhitespace =>
      '[Åñ éẋçĥáñĝé ṽáļûé çöñţáîñš á šþáçé; îţ îš ŵŕîţţéñ ŵîţĥ á ĥýþĥéñ.··························]';

  @override
  String get cabrilloIssueEmptyExchangeToken =>
      '[Åñ éẋçĥáñĝé ṽáļûé îš éɱþţý; á ĥýþĥéñ îš ŵŕîţţéñ îñ îţš þļáçé.·························]';

  @override
  String get cabrilloIssueTooManyAddressLines =>
      '[Ţĥéŕé áŕé ɱöŕé ţĥáñ 6 áððŕéšš ļîñéš; ţĥé éẋţŕá ļîñéš áŕé ðŕöþþéð.··························]';

  @override
  String get cabrilloIssueAddressLineTooLong =>
      '[Åñ áððŕéšš ļîñé îš ļöñĝéŕ ţĥáñ 45 çĥáŕáçţéŕš; îţ îš çûţ öƒƒ.························]';

  @override
  String get cabrilloIssueInvalidTransmitterId =>
      '[Ţĥé ţŕáñšɱîţţéŕ ñûɱƀéŕ ɱûšţ ƀé 0 öŕ 1.················]';

  @override
  String cabrilloIssueQsos(int count, int first) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count[ ǪŠÖš, ţĥé ƒîŕšţ îš ñö. ··········]$first',
      one: '[ǪŠÖ ñö. ····]$first',
    );
    return '$_temp0';
  }

  @override
  String get contestSyncLocal => '[Öñļý öñ ţĥîš ðéṽîçé········]';

  @override
  String get contestSyncPending =>
      '[Ŵáîţîñĝ ƒöŕ ûþļöáð ţö Ŵáṽéļöĝ············]';

  @override
  String get contestSyncVerifying => '[Ɓéîñĝ çĥéçķéð öñ Ŵáṽéļöĝ··········]';

  @override
  String get contestSyncCreated => '[Öñ Ŵáṽéļöĝ····]';

  @override
  String contestSyncWithReason(String state, String reason) {
    return '$state[: ·]$reason';
  }

  @override
  String contestSyncStatusLabel(String status) {
    return '[Ŵáṽéļöĝ: ····]$status';
  }

  @override
  String get contestSyncProblemNotActive =>
      '[Ţĥé çöñţéšţ îš ñöţ áçţîṽáţéð öñ ýöûŕ Ŵáṽéļöĝ šéŕṽéŕ.·····················]';

  @override
  String get contestSyncProblemMissingPermission =>
      '[Ţĥé ÅÞÎ ţöķéñ ļáçķš ţĥé çöñţéšţ:ŵŕîţé þéŕɱîššîöñ.····················]';

  @override
  String get contestSyncProblemServerTooOld =>
      '[Ýöûŕ Ŵáṽéļöĝ šéŕṽéŕ îš öļðéŕ ţĥáñ ṽéŕšîöñ 3.2 áñð ĥáš ñö çöñţéšţ šéššîöñš.······························]';

  @override
  String get contestSyncProblemDeletedOnServer =>
      '[Ţĥé šéššîöñ ŵáš ðéļéţéð îñ Ŵáṽéļöĝ.··············]';

  @override
  String get contestSyncProblemNoAdifName =>
      '[Ţĥîš çöñţéšţ ĥáš ñö ÅÐÎƑ çöñţéšţ ñáɱé.················]';

  @override
  String get contestSyncProblemStationUnknown =>
      '[Ţĥé šţáţîöñ ļöçáţîöñ îš ñöţ öñ ţĥé Ŵáṽéļöĝ šéŕṽéŕ.····················]';

  @override
  String get contestSyncProblemRejected =>
      '[Ŵáṽéļöĝ ŕéĵéçţéð ţĥé šéššîöñ.············]';

  @override
  String get contestSyncProblemUnknown =>
      '[Ŵáṽéļöĝ ŕéþöŕţéð á þŕöƀļéɱ.···········]';

  @override
  String get workedHintNewCall => '[Ñéŵ çáļļ: ñöţ îñ ýöûŕ ļöĝ ýéţ············]';

  @override
  String get workedHintNewBand =>
      '[Ŵöŕķéð ƀéƒöŕé, ƀûţ ñöţ öñ ţĥîš ƀáñð··············]';

  @override
  String get workedHintNewMode =>
      '[Ŵöŕķéð ƀéƒöŕé, ƀûţ ñöţ îñ ţĥîš ɱöðé··············]';

  @override
  String get workedHintNewSlot =>
      '[Ŵöŕķéð ƀéƒöŕé, ƀûţ ñöţ öñ ţĥîš ƀáñð áñð ɱöðé ţöĝéţĥéŕ······················]';

  @override
  String get workedHintWorked =>
      '[Ŵöŕķéð ƀéƒöŕé öñ ţĥîš ƀáñð áñð ɱöðé··············]';

  @override
  String workedHintDetails(String date, String bands) {
    return '[ƒîŕšţ çöñţáçţ ······]$date[, ƀáñðš ····]$bands';
  }

  @override
  String get settingsWorkedBefore => '[Ŵöŕķéð-ƀéƒöŕé îñðéẋ········]';

  @override
  String get actionRebuildWorkedBefore =>
      '[Ŕéƀûîļð ŵöŕķéð-ƀéƒöŕé îñðéẋ···········]';

  @override
  String get rebuildWorkedBeforeHint =>
      '[Ɓûîļðš ţĥé îñðéẋ ƒŕöɱ ýöûŕ ļöĝ áĝáîñ. Çöñţáçţš ƒŕöɱ ýöûŕ Ŵáṽéļöĝ šéŕṽéŕ çöɱé ƀáçķ ŵîţĥ ţĥé ñéẋţ šýñç.·········································]';

  @override
  String get rebuildWorkedBeforeConfirmTitle => '[Ŕéƀûîļð ţĥé îñðéẋ?········]';

  @override
  String get rebuildWorkedBeforeConfirmBody =>
      '[Ýöûŕ ļöĝ îš ñöţ çĥáñĝéð. Ĥîñţš ƒöŕ šţáţîöñš ýöû öñļý ŵöŕķéð öñ öţĥéŕ ðéṽîçéš öŕ îñ Ŵáṽéļöĝ áŕé ɱîššîñĝ ûñţîļ ţĥé ñéẋţ šýñç ĥáš ļöáðéð ţĥéɱ áĝáîñ.··························································]';

  @override
  String get actionRebuild => '[Ŕéƀûîļð···]';

  @override
  String get rebuildWorkedBeforeProgress => '[Ŕéƀûîļðîñĝ ţĥé îñðéẋ…·········]';

  @override
  String get rebuildWorkedBeforeDone =>
      '[Îñðéẋ ŕéƀûîļţ. Ţĥé ñéẋţ šýñç áððš ţĥé çöñţáçţš ƒŕöɱ ýöûŕ Ŵáṽéļöĝ šéŕṽéŕ.·····························]';

  @override
  String get rebuildWorkedBeforeFailed =>
      '[Ţĥé îñðéẋ çöûļð ñöţ ƀé ŕéƀûîļţ.·············]';

  @override
  String get settingsScp => '[Šûþéŕ çĥéçķ þáŕţîáļ········]';

  @override
  String get scpHint =>
      '[Çáļļšîĝñ šûĝĝéšţîöñš ŵĥîļé ýöû ļöĝ á çöñţéšţ. Ţĥé ļîšţ îš ñöţ þáŕţ öƒ Ţîðéļîñé: ýöû ðöŵñļöáð îţ ýöûŕšéļƒ.··········································]';

  @override
  String get scpNone => '[Ñö ļîšţ îñšţáļļéð·······]';

  @override
  String scpPackSummary(int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count[ çáļļšîĝñš····]',
      one: '[1 çáļļšîĝñ····]',
    );
    return '$_temp0[ · îñšţáļļéð ······]$date';
  }

  @override
  String scpSource(String source) {
    return '[Šöûŕçé: ····]$source';
  }

  @override
  String get scpSourceFile => '[á ƒîļé ýöû îɱþöŕţéð········]';

  @override
  String get scpUrlLabel => '[Ðöŵñļöáð áððŕéšš (ĥţţþš)··········]';

  @override
  String get scpUrlHelper =>
      '[Ţîðéļîñé çöñţáçţš ţĥîš áððŕéšš öñļý ŵĥéñ ýöû þŕéšš Ðöŵñļöáð, áñð šéñðš ñöţĥîñĝ áƀöûţ ýöû.····································]';

  @override
  String get actionDownload => '[Ðöŵñļöáð····]';

  @override
  String get actionImportFile => '[Îɱþöŕţ ƒîļé·····]';

  @override
  String get actionRemove => '[Ŕéɱöṽé···]';

  @override
  String get scpDownloading => '[Ðöŵñļöáðîñĝ ţĥé ļîšţ…·········]';

  @override
  String scpDownloadingSize(int kib) {
    return '[Ðöŵñļöáðîñĝ ţĥé ļîšţ… ·········]$kib[ ĶîƁ··]';
  }

  @override
  String scpInstalled(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count[ çáļļšîĝñš····]',
      one: '[1 çáļļšîĝñ····]',
    );
    return '[Ļîšţ îñšţáļļéð: ·······]$_temp0[.·]';
  }

  @override
  String get scpRemoveTitle => '[Ŕéɱöṽé ţĥé ļîšţ?·······]';

  @override
  String get scpRemoveBody =>
      '[Çáļļšîĝñ šûĝĝéšţîöñš šţöþ ûñţîļ ýöû îñšţáļļ á ļîšţ áĝáîñ.·······················]';

  @override
  String get scpRemoved => '[Ļîšţ ŕéɱöṽéð.······]';

  @override
  String get scpErrorInsecureUrl =>
      '[Öñļý ĥţţþš áððŕéššéš áŕé áļļöŵéð.··············]';

  @override
  String get scpErrorInvalidUrl =>
      '[Ţĥîš îš ñöţ á ûšáƀļé áððŕéšš. Îţ ɱûšţ ñöţ çöñţáîñ á ûšéŕ ñáɱé, á þáššŵöŕð, á ǫûéŕý (?…) öŕ á ƒŕáĝɱéñţ (#…).···········································]';

  @override
  String get scpErrorNetwork =>
      '[Ţĥé šéŕṽéŕ çöûļð ñöţ ƀé ŕéáçĥéð. Çĥéçķ ýöûŕ çöññéçţîöñ áñð ţĥé áððŕéšš.·····························]';

  @override
  String get scpErrorTimeout =>
      '[Ţĥé šéŕṽéŕ ţööķ ţöö ļöñĝ ţö áñšŵéŕ.··············]';

  @override
  String get scpErrorCertificate =>
      '[Ţĥé çéŕţîƒîçáţé öƒ ţĥé šéŕṽéŕ îš ñöţ ţŕûšţéð, šö ñöţĥîñĝ ŵáš ðöŵñļöáðéð.·····························]';

  @override
  String get scpErrorTooLarge =>
      '[Ţĥé ƒîļé îš ļáŕĝéŕ ţĥáñ 8 ṀîƁ. Îţ ŵáš ñöţ šţöŕéð.····················]';

  @override
  String scpErrorStatus(int code) {
    return '[Ţĥé šéŕṽéŕ áñšŵéŕéð ŵîţĥ ĤŢŢÞ šţáţûš ···············]$code[.·]';
  }

  @override
  String get scpErrorInvalidFile =>
      '[Ţĥîš îš ñöţ á ṀÅŠŢÉŔ.ŠÇÞ ƒîļé (öñé çáļļšîĝñ þéŕ ļîñé).······················]';

  @override
  String get scpErrorUnreadable => '[Ţĥé ƒîļé çöûļð ñöţ ƀé ŕéáð.···········]';

  @override
  String get settingsContestDefinitions => '[Çöñţéšţ ðéƒîñîţîöñš········]';

  @override
  String get contestDefsHint =>
      '[Ţĥé ŕûļéš öƒ éáçĥ çöñţéšţ áŕé ðáţá ƒîļéš. Ɓûñðļéð ðéƒîñîţîöñš áŕé áļŵáýš áṽáîļáƀļé; ýöû çáñ áðð ýöûŕ öŵñ.··········································]';

  @override
  String get contestDefBuiltin => '[Ɓûñðļéð···]';

  @override
  String get contestDefUser => '[Îɱþöŕţéð ƀý ýöû······]';

  @override
  String contestDefVersion(int version) {
    return '[ṽéŕšîöñ ····]$version';
  }

  @override
  String get actionImportDefinition => '[Îɱþöŕţ ðéƒîñîţîöñ·······]';

  @override
  String get importDefinitionHint =>
      '[Å ĴŠÖÑ ƒîļé öƒ ûþ ţö 256 ĶîƁ.············]';

  @override
  String contestDefImported(String name) {
    return '[Îɱþöŕţéð “····]$name[”.·]';
  }

  @override
  String contestDefReplaced(String name) {
    return '[Ûþðáţéð “····]$name[”.·]';
  }

  @override
  String get contestDefRejectedTitle => '[Ðéƒîñîţîöñ ñöţ îɱþöŕţéð··········]';

  @override
  String contestDefTechnical(String path) {
    return '[Ţéçĥñîçáļ ðéţáîļ: ········]$path';
  }

  @override
  String get contestDefFileTooLarge =>
      '[Ţĥé ƒîļé îš ļáŕĝéŕ ţĥáñ 256 ĶîƁ.·············]';

  @override
  String get contestDefNotText =>
      '[Ţĥé ƒîļé îš ñöţ ṽáļîð ÛŢƑ-8 ţéẋţ.··············]';

  @override
  String get contestDefUnreadable => '[Ţĥé ƒîļé çöûļð ñöţ ƀé ŕéáð.···········]';

  @override
  String get contestDefIdClash =>
      '[Ţĥîš îð ƀéļöñĝš ţö á ƀûñðļéð çöñţéšţ. Çĥööšé á ðîƒƒéŕéñţ îð îñ ţĥé ƒîļé.·····························]';

  @override
  String actionDeleteDefinition(String name) {
    return '[Ðéļéţé ðéƒîñîţîöñ ········]$name';
  }

  @override
  String contestDefDeleteTitle(String name) {
    return '[Ðéļéţé “····]$name[”?·]';
  }

  @override
  String get contestDefDeleteBody =>
      '[Öñļý ţĥé ðéƒîñîţîöñ îš ŕéɱöṽéð. Ýöûŕ ǪŠÖš áŕé ñöţ áƒƒéçţéð.························]';

  @override
  String contestDefDeleted(String name) {
    return '[Ðéļéţéð “····]$name[”.·]';
  }

  @override
  String get contestDefInUse =>
      '[Å çöñţéšţ šéššîöñ îñ ýöûŕ ļöĝ ûšéš ţĥîš ðéƒîñîţîöñ, šö îţ çáññöţ ƀé ðéļéţéð.·······························]';

  @override
  String get contestDefBuiltinNoDelete =>
      '[Ɓûñðļéð ðéƒîñîţîöñš çáññöţ ƀé ðéļéţéð.················]';

  @override
  String get contestDefNotFound =>
      '[Ţĥîš ðéƒîñîţîöñ ñö ļöñĝéŕ éẋîšţš.··············]';

  @override
  String get contestDefErrorTooLarge =>
      '[Ţĥé ðéƒîñîţîöñ îš ļáŕĝéŕ ţĥáñ 256 ĶîƁ.················]';

  @override
  String get contestDefErrorMalformedJson =>
      '[Ţĥé ƒîļé îš ñöţ ṽáļîð ĴŠÖÑ.···········]';

  @override
  String get contestDefErrorWrongType =>
      '[Å ṽáļûé ĥáš ţĥé ŵŕöñĝ ţýþé.···········]';

  @override
  String get contestDefErrorUnknownKey =>
      '[Ţĥé ƒîļé çöñţáîñš á šéţţîñĝ ţĥáţ Ţîðéļîñé ðöéš ñöţ ķñöŵ.·······················]';

  @override
  String get contestDefErrorMissingKey =>
      '[Å ŕéǫûîŕéð šéţţîñĝ îš ɱîššîñĝ.············]';

  @override
  String get contestDefErrorUnsupportedSchema =>
      '[Ţĥîš šçĥéɱá ṽéŕšîöñ îš ñöţ šûþþöŕţéð (öñļý ṽéŕšîöñ 1).······················]';

  @override
  String get contestDefErrorInvalidId =>
      '[Ţĥé îð ɱûšţ ĥáṽé 1 ţö 64 çĥáŕáçţéŕš: ļöŵéŕ-çášé ļéţţéŕš, ðîĝîţš áñð ĥýþĥéñš.·······························]';

  @override
  String get contestDefErrorOutOfRange =>
      '[Å ñûɱƀéŕ öŕ á ţéẋţ ļéñĝţĥ îš öûţšîðé ţĥé áļļöŵéð ŕáñĝé.······················]';

  @override
  String get contestDefErrorTooLong => '[Å ţéẋţ îš ţöö ļöñĝ.········]';

  @override
  String get contestDefErrorInvalidCharacters =>
      '[Å ţéẋţ çöñţáîñš çöñţŕöļ çĥáŕáçţéŕš.··············]';

  @override
  String get contestDefErrorTooManyElements =>
      '[Å ļîšţ ĥáš ţöö ɱáñý éñţŕîéš.············]';

  @override
  String get contestDefErrorTooFewElements =>
      '[Å ļîšţ ĥáš ţöö ƒéŵ éñţŕîéš.···········]';

  @override
  String get contestDefErrorUnknownBand =>
      '[Å ƀáñð ñáɱé îš ñöţ á ķñöŵñ ÅÐÎƑ ƀáñð.···············]';

  @override
  String get contestDefErrorUnknownValue =>
      '[Å šéţţîñĝ ĥáš á ṽáļûé ţĥáţ Ţîðéļîñé ðöéš ñöţ ķñöŵ.····················]';

  @override
  String get contestDefErrorLastRuleHasWhen =>
      '[Ţĥé ļášţ þöîñţš ŕûļé ɱûšţ áþþļý ţö éṽéŕý çöñţáçţ, šö îţ çáññöţ ĥáṽé á çöñðîţîöñ.································]';

  @override
  String get contestDefErrorVariantPredicateNotMine =>
      '[Å ṽáŕîáñţ öƒ ţĥé éẋçĥáñĝé ɱáý ðéþéñð öñļý öñ ýöûŕ öŵñ šţáţîöñ.·························]';

  @override
  String get contestDefErrorElementPredicateNotTheirs =>
      '[Å ŕéçéîṽéð éẋçĥáñĝé éļéɱéñţ ɱáý ðéþéñð öñļý öñ ţĥé öţĥéŕ šţáţîöñ.··························]';

  @override
  String get contestDefErrorElementWhenNotAllowed =>
      '[Å šéñţ éẋçĥáñĝé éļéɱéñţ çáññöţ ĥáṽé á çöñðîţîöñ.····················]';

  @override
  String get contestDefErrorMultipleSerials =>
      '[Öñé šîðé öƒ ţĥé éẋçĥáñĝé ɱáý çöñţáîñ öñļý öñé šéŕîáļ ñûɱƀéŕ.························]';

  @override
  String get contestDefErrorDuplicateField =>
      '[Ţŵö éẋçĥáñĝé éļéɱéñţš šţöŕé îñţö ţĥé šáɱé ÅÐÎƑ ƒîéļð.······················]';

  @override
  String get contestDefErrorDuplicateId =>
      '[Ţŵö ɱûļţîþļîéŕš ĥáṽé ţĥé šáɱé îð.··············]';

  @override
  String get contestDefErrorInvalidPlaceholder =>
      '[Å ðéƒáûļţ ṽáļûé ûšéš áñ ûñķñöŵñ þļáçéĥöļðéŕ.··················]';

  @override
  String get contestDefErrorInvalidValue =>
      '[Å ðéƒáûļţ ṽáļûé ðöéš ñöţ ƒîţ îţš éẋçĥáñĝé éļéɱéñţ.····················]';

  @override
  String get contestDefErrorDefaultNotAllowed =>
      '[Å ðéƒáûļţ ṽáļûé îš ñöţ áļļöŵéð ĥéŕé (ŕéçéîṽéð šîðé áñð šéŕîáļ ñûɱƀéŕš).·····························]';

  @override
  String get contestDefErrorInvalidMultiplierSource =>
      '[Å ɱûļţîþļîéŕ ûšéš á šöûŕçé ţĥáţ ðöéš ñöţ éẋîšţ öŕ ţĥáţ ñö ŕéçéîṽéð éẋçĥáñĝé çöñţáîñš.··································]';

  @override
  String get contestDefErrorEmptyPredicate =>
      '[Å çöñðîţîöñ îš éɱþţý.·········]';

  @override
  String get contestDefErrorInvalidCombination =>
      '[Ţĥé šçöŕé ţýþé ðöéš ñöţ ƒîţ ţĥé ɱûļţîþļîéŕš.··················]';

  @override
  String get contestDefErrorDuplicateValue =>
      '[Ţĥé šáɱé ṽáļûé îš ļîšţéð ţŵîçé.·············]';

  @override
  String get settingsReferencePacks =>
      '[Ŕéƒéŕéñçé ļîšţš (ŠÖŢÅ, ÞÖŢÅ, ŴŴƑƑ)··············]';

  @override
  String get packsHint =>
      '[Öƒƒļîñé ļîšţš öƒ šûɱɱîţš, þáŕķš áñð ƒļöŕá áñð ƒáûñá áŕéáš ƒöŕ áçţîṽáţîöñš. Ţĥéý áŕé ñöţ þáŕţ öƒ Ţîðéļîñé: ýöû ðöŵñļöáð éáçĥ öñé ýöûŕšéļƒ, ðîŕéçţļý ƒŕöɱ îţš öƒƒîçîáļ šöûŕçé. Éáçĥ ļîšţ îš 10 ţö 25 ṀƁ.················································································]';

  @override
  String get packNameSota => '[Šûɱɱîţš öñ ţĥé Åîŕ (ŠÖŢÅ)··········]';

  @override
  String get packNamePota => '[Þáŕķš öñ ţĥé Åîŕ (ÞÖŢÅ)··········]';

  @override
  String get packNameWwff => '[Ŵöŕļð Ŵîðé Ƒļöŕá & Ƒáûñá (ŴŴƑƑ)·············]';

  @override
  String get packNone => '[Ñö ļîšţ îñšţáļļéð·······]';

  @override
  String packSummary(int count, String version, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count[ ŕéƒéŕéñçéš·····]',
      one: '[1 ŕéƒéŕéñçé·····]',
    );
    return '$_temp0[ · ļîšţ ðáţéð ······]$version[ · ðöŵñļöáðéð ······]$date';
  }

  @override
  String get actionUpdate => '[Ûþðáţé···]';

  @override
  String get packDownloading => '[Ðöŵñļöáðîñĝ…·····]';

  @override
  String packDownloadingSize(String size) {
    return '[Ðöŵñļöáðîñĝ… ······]$size';
  }

  @override
  String get packInstalling => '[Ŕéáðîñĝ áñð šţöŕîñĝ ţĥé ļîšţ…············]';

  @override
  String packInstalled(String program, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count[ ŕéƒéŕéñçéš·····]',
      one: '[1 ŕéƒéŕéñçé·····]',
    );
    return '$program[ ļîšţ îñšţáļļéð: ·······]$_temp0[.·]';
  }

  @override
  String get packCancelled =>
      '[Ðöŵñļöáð çáñçéļļéð. Ţĥé îñšţáļļéð ļîšţ ŵáš ñöţ çĥáñĝéð.······················]';

  @override
  String packRemoveTitle(String program) {
    return '[Ŕéɱöṽé ţĥé ·····]$program[ ļîšţ?···]';
  }

  @override
  String packRemoveBody(String program) {
    return '[Šéáŕçĥîñĝ ƒöŕ ······]$program[ ŕéƒéŕéñçéš šţöþš ûñţîļ ýöû îñšţáļļ á ļîšţ áĝáîñ. Ýöûŕ áçţîṽáţîöñš áñð ǪŠÖš áŕé ñöţ áƒƒéçţéð.······································]';
  }

  @override
  String packRemoved(String program) {
    return '$program[ ļîšţ ŕéɱöṽéð.······]';
  }

  @override
  String get packErrorTooLarge =>
      '[Ţĥé ƒîļé îš ļáŕĝéŕ ţĥáñ áļļöŵéð. Îţ ŵáš ñöţ šţöŕéð.·····················]';

  @override
  String packErrorInvalidFile(String program) {
    return '[Ţĥîš îš ñöţ á ······]$program[ ļîšţ. Çĥéçķ ţĥé áððŕéšš.··········]';
  }

  @override
  String get packErrorStorage =>
      '[Ţĥé ƒîļé çöûļð ñöţ ƀé šţöŕéð öñ ţĥîš ðéṽîçé. Çĥéçķ ţĥé ƒŕéé šþáçé.···························]';

  @override
  String get activationOpenAction => '[Šţáŕţ áñ áçţîṽáţîöñ········]';

  @override
  String get activationSetupTitle => '[Šţáŕţ áñ áçţîṽáţîöñ········]';

  @override
  String get activationProgramLabel => '[Þŕöĝŕáɱ···]';

  @override
  String get activationReferenceLabelSota => '[Šûɱɱîţ ŕéƒéŕéñçé·······]';

  @override
  String get activationReferenceLabelPota => '[Þáŕķ ŕéƒéŕéñçé······]';

  @override
  String get activationReferenceLabelWwff => '[Åŕéá ŕéƒéŕéñçé······]';

  @override
  String activationReferenceExample(String example) {
    return '[Éẋáɱþļé: ····]$example';
  }

  @override
  String activationReferenceInvalid(String program, String example) {
    return '[Ţĥîš îš ñöţ á ······]$program[ ŕéƒéŕéñçé. Éẋáɱþļé: ·········]$example';
  }

  @override
  String activationReferenceKnown(String program, String name) {
    return '[Îñ ýöûŕ ····]$program[ ļîšţ: ···]$name';
  }

  @override
  String activationReferenceUnknown(String program) {
    return '[Ñöţ îñ ýöûŕ ·····]$program[ ļîšţ. Ýöû çáñ šţîļļ ûšé îţ.············]';
  }

  @override
  String activationNoPack(String program) {
    return '[Ñö ··]$program[ ļîšţ îš îñšţáļļéð, šö ŕéƒéŕéñçéš çáññöţ ƀé ļööķéð ûþ. Ýöû çáñ šţîļļ ţýþé öñé. Ðöŵñļöáð ţĥé ļîšţ îñ Šéţţîñĝš.············································]';
  }

  @override
  String get activationOpenSettings => '[Öþéñ šéţţîñĝš······]';

  @override
  String get activationMatches => '[Ṁáţçĥéš···]';

  @override
  String activationNearby(String grid) {
    return '[Ñéáŕéšţ ţö ·····]$grid';
  }

  @override
  String get activationNoMatches => '[Ñöţĥîñĝ ƒöûñð.······]';

  @override
  String unitKilometers(int km) {
    return '$km[ ķɱ··]';
  }

  @override
  String get activationGridLabel =>
      '[Ýöûŕ ĝŕîð šǫûáŕé áţ ţĥé ŕéƒéŕéñçé··············]';

  @override
  String get activationGridFromReference =>
      '[Ţáķéñ ƒŕöɱ ţĥé þöšîţîöñ öƒ ţĥé ŕéƒéŕéñçé.·················]';

  @override
  String get activationGridFromStation =>
      '[Ţáķéñ ƒŕöɱ ţĥé Ŵáṽéļöĝ ļöçáţîöñ.·············]';

  @override
  String get activationGridNone =>
      '[Ñö ĝŕîð šǫûáŕé ķñöŵñ. Ýöû çáñ ļéáṽé îţ éɱþţý.··················]';

  @override
  String activationLocationCarries(String reference) {
    return '[Ţĥîš Ŵáṽéļöĝ ļöçáţîöñ çáŕŕîéš ············]$reference[, šö ýöûŕ ǪŠÖš ŕéáçĥ Ŵáṽéļöĝ ŵîţĥ îţ.···············]';
  }

  @override
  String activationLocationSuggest(String name, String reference) {
    return '[Ţĥé Ŵáṽéļöĝ ļöçáţîöñ “·········]$name[” çáŕŕîéš ····]$reference[.·]';
  }

  @override
  String get activationUseLocation => '[Ûšé ţĥîš ļöçáţîöñ·······]';

  @override
  String activationLocationNone(String reference) {
    return '[Ñö Ŵáṽéļöĝ ļöçáţîöñ çáŕŕîéš ············]$reference[. Ŵáṽéļöĝ ƒîļéš éṽéŕý ǪŠÖ ûñðéŕ îţš ļöçáţîöñ’š öŵñ ŕéƒéŕéñçé áñð îĝñöŕéš ţĥé öñé îñ ţĥé ûþļöáð. Ţîðéļîñé ķééþš ·············································]$reference[ öñ éáçĥ ǪŠÖ áñð îñ ÅÐÎƑ éẋþöŕţš. Ţö ĥáṽé îţ öñ Ŵáṽéļöĝ ţöö, çŕéáţé á ļöçáţîöñ ŵîţĥ ţĥîš ŕéƒéŕéñçé ţĥéŕé, ţĥéñ çĥööšé îţ ĥéŕé.···················································]';
  }

  @override
  String get activationErrorNoStation =>
      '[Ñö Ŵáṽéļöĝ ļöçáţîöñ ýéţ. Çöññéçţ ţö Ŵáṽéļöĝ öñçé ţö ļöáð ýöûŕ ļöçáţîöñš.·····························]';

  @override
  String activationRunning(String reference) {
    return '$reference[ îš šţîļļ ŕûññîñĝ. Šţáŕţîñĝ á ñéŵ áçţîṽáţîöñ éñðš îţ.······················]';
  }

  @override
  String get activationStart => '[Šţáŕţ áçţîṽáţîöñ·······]';

  @override
  String get activationStartFailed =>
      '[Ţĥé áçţîṽáţîöñ çöûļð ñöţ ƀé šţáŕţéð. Ţŕý áĝáîñ.···················]';

  @override
  String activationBannerTitle(String program, String reference) {
    return '$program[ ·]$reference';
  }

  @override
  String activationBannerTitleNamed(
    String program,
    String reference,
    String name,
  ) {
    return '$program[ ·]$reference[ · ··]$name';
  }

  @override
  String activationProgress(int counted, int required, int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: '$remaining[ ţö ĝö···]',
      one: '[1 ţö ĝö···]',
    );
    return '$counted[ öƒ ··]$required[ ǪŠÖš · ····]$_temp0';
  }

  @override
  String activationProgressValid(int counted, int required) {
    return '[Ṽáļîð áçţîṽáţîöñ: ········]$counted[ ǪŠÖš (ñééðš ······]$required[)·]';
  }

  @override
  String get activationWindowDay => '[Çöûñţéð þéŕ ÛŢÇ ðáý.········]';

  @override
  String get activationWindowSession =>
      '[Çöûñţéð öṽéŕ ţĥé ŵĥöļé áçţîṽáţîöñ.··············]';

  @override
  String activationDuplicates(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count[ ǪŠÖš··]',
      one: '[1 ǪŠÖ··]',
    );
    return '$_temp0[ ñöţ çöûñţéð (šáɱé çáļļ, ƀáñð áñð ɱöðé).················]';
  }

  @override
  String activationDuplicatesCall(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count[ ǪŠÖš··]',
      one: '[1 ǪŠÖ··]',
    );
    return '$_temp0[ ñöţ çöûñţéð (šáɱé šţáţîöñ áĝáîñ).··············]';
  }

  @override
  String get activationEnd => '[Éñð áçţîṽáţîöñ······]';

  @override
  String activationEndTitle(String reference) {
    return '[Éñð ··]$reference[?·]';
  }

  @override
  String get activationEndBody =>
      '[Ñéŵ ǪŠÖš áŕé ñö ļöñĝéŕ áððéð ţö ţĥîš áçţîṽáţîöñ. Ļöĝĝéð ǪŠÖš šţáý áš ţĥéý áŕé.································]';

  @override
  String get activationEnded => '[Åçţîṽáţîöñ éñðéð.·······]';

  @override
  String get activationTheirReferenceSota => '[Ţĥéîŕ šûɱɱîţ (Š2Š)········]';

  @override
  String get activationTheirReferencePota => '[Ţĥéîŕ þáŕķ (Þ2Þ)·······]';

  @override
  String get activationTheirReferenceWwff => '[Ţĥéîŕ áŕéá (ŴŴƑƑ)·······]';

  @override
  String get activationIssueTheirReference =>
      '[Ţĥîš îš ñöţ á ṽáļîð ŕéƒéŕéñçé.············]';

  @override
  String get commandStartActivation => '[Šţáŕţ áñ áçţîṽáţîöñ········]';

  @override
  String get commandEndActivation => '[Éñð ţĥé ŕûññîñĝ áçţîṽáţîöñ···········]';

  @override
  String get settingsAppearanceAndLanguage =>
      '[Åþþéáŕáñçé áñð ļáñĝûáĝé··········]';

  @override
  String get settingsAppearanceHint => '[Ţĥéɱé, ţéẋţ áñð ļáñĝûáĝé··········]';

  @override
  String get settingsReferenceData => '[Ŕéƒéŕéñçé ðáţá······]';

  @override
  String get settingsReferenceDataHint =>
      '[Ļîšţš áñð îñðéẋéš ýöû ðöŵñļöáð············]';

  @override
  String get settingsSecurityAndBackup => '[Šéçûŕîţý áñð ƀáçķûþ········]';

  @override
  String get settingsSecurityAndBackupHint =>
      '[Åþþ ļöçķ, ÅÐÎƑ áñð ƀáçķûþ··········]';

  @override
  String get settingsAccounts => '[Ŵáṽéļöĝ áççöûñţš·······]';

  @override
  String get accountsHint =>
      '[Šéŕṽéŕš, ţöķéñš áñð ţĥé áççöûñţ ýöû ļöĝ ţö·················]';

  @override
  String get accountsInUse => '[Îñ ûšé ƒöŕ ļöĝĝîñĝ········]';

  @override
  String accountsPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count[ ǪŠÖš ŵáîţîñĝ······]',
      one: '[1 ǪŠÖ ŵáîţîñĝ······]',
      zero: '[Ñöţĥîñĝ ŵáîţîñĝ······]',
    );
    return '$_temp0';
  }

  @override
  String get accountsAdd => '[Åðð áççöûñţ·····]';

  @override
  String get accountsUseForLogging => '[Ûšé ƒöŕ ļöĝĝîñĝ······]';

  @override
  String get accountsRename => '[Ŕéñáɱé···]';

  @override
  String get accountsRenameTitle => '[Ŕéñáɱé ţĥîš áççöûñţ········]';

  @override
  String get accountsSwitch => '[Šŵîţçĥ áççöûñţ······]';

  @override
  String get accountsManage => '[Ṁáñáĝé áççöûñţš······]';

  @override
  String accountsSwitchedTo(String name) {
    return '[Ļöĝĝîñĝ ţö ·····]$name';
  }

  @override
  String get accountsBlockedContest =>
      '[Å çöñţéšţ šéššîöñ îš ŕûññîñĝ. Éñð îţ ƀéƒöŕé ýöû šŵîţçĥ áççöûñţš.··························]';

  @override
  String get accountsBlockedActivation =>
      '[Åñ áçţîṽáţîöñ îš ŕûññîñĝ. Éñð îţ ƀéƒöŕé ýöû šŵîţçĥ áççöûñţš.························]';

  @override
  String get accountsPendingTitle => '[Ŵáîţîñĝ, þéŕ áççöûñţ········]';

  @override
  String get accountsExportRemove => '[Éẋþöŕţ ļöĝ, ţĥéñ ŕéɱöṽé··········]';

  @override
  String get accountsAddTitle => '[Åðð á Ŵáṽéļöĝ áççöûñţ·········]';

  @override
  String accountsActsOn(String name) {
    return '[Åççöûñţ: ····]$name';
  }

  @override
  String get commandGoBack => '[Ĝö ƀáçķ···]';

  @override
  String get menuGo => '[Ĝö·]';

  @override
  String get menuOperate => '[Öþéŕáţé···]';

  @override
  String get menuHelp => '[Ĥéļþ··]';

  @override
  String get menuWindow => '[Ŵîñðöŵ···]';

  @override
  String get actionCopyCallsign => '[Çöþý çáļļšîĝñ······]';

  @override
  String get actionOpenQso => '[Öþéñ ǪŠÖ····]';

  @override
  String callsignCopied(String call) {
    return '[Çöþîéð ···]$call';
  }

  @override
  String get callsignFillIn => '[Ƒîļļ îñ···]';

  @override
  String get callsignFillInLabel =>
      '[Ƒîļļ îñ ñáɱé áñð ļöçáţöŕ ƒŕöɱ éáŕļîéŕ çöñţáçţš···················]';

  @override
  String callsignKnown(String details) {
    return '[Ķñöŵñ ƒŕöɱ éáŕļîéŕ çöñţáçţš: ············]$details';
  }

  @override
  String get callsignNoteTooltip => '[Çáļļšîĝñ ñöţé······]';

  @override
  String get callsignNoteTooltipHas =>
      '[Çáļļšîĝñ ñöţé (ţĥéŕé îš öñé)············]';

  @override
  String callsignNoteTitle(String call) {
    return '[Ñöţé ƒöŕ ····]$call';
  }

  @override
  String get callsignNoteHint =>
      '[Öñļý öñ ţĥîš ðéṽîçé (áñð îñ ýöûŕ ƀáçķûþ). Ñöţ šéñţ ţö Ŵáṽéļöĝ.·························]';

  @override
  String get callsignNoteField => '[Ñöţé··]';

  @override
  String get callsignNoteDelete => '[Ðéļéţé ñöţé·····]';

  @override
  String callsignNoteLine(String text) {
    return '[Ñöţé: ···]$text';
  }

  @override
  String get callsignDirectoryTitle => '[Çáļļšîĝñ ðîŕéçţöŕý········]';

  @override
  String get callsignDirectoryBody =>
      '[Ñáɱéš, þļáçéš áñð ļöçáţöŕš ƒŕöɱ ýöûŕ ǪŠÖ ĥîšţöŕý, ķéþţ öñ ţĥîš ðéṽîçé, šö ţĥéý áŕé ţĥéŕé öƒƒļîñé. Îţ îš þáŕţ öƒ ţĥé ŵöŕķéð-ƀéƒöŕé îñðéẋ áñð îš ŕéƀûîļţ ŵîţĥ îţ.································································]';

  @override
  String callsignDirectoryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count[ šţáţîöñš····]',
      one: '[1 šţáţîöñ····]',
      zero: '[Ñö šţáţîöñš ýéţ······]',
    );
    return '$_temp0';
  }

  @override
  String get callsignSearch => '[Šéáŕçĥ çáļļ, ñáɱé öŕ þļáçé···········]';

  @override
  String get callsignEmpty =>
      '[Ñöţĥîñĝ ƒöûñð. Šţáţîöñš áþþéáŕ ĥéŕé áš ýöû ļöĝ áñð šýñç.·······················]';

  @override
  String get callsignHasNote => '[Ĥáš á ñöţé····]';

  @override
  String callsignLastWorked(String date) {
    return '[Ļášţ ŵöŕķéð ·····]$date';
  }

  @override
  String callsignZones(String dxcc, String cq, String itu) {
    return '[ÐẊÇÇ ··]$dxcc[ · ÇǪ ···]$cq[ · ÎŢÛ ···]$itu';
  }

  @override
  String get freeSpaceTitle => '[Ƒŕéé ûþ šþáçé······]';

  @override
  String get freeSpaceEntry =>
      '[Ŕéɱöṽé šýñçéð ǪŠÖš ƒŕöɱ ţĥîš ðéṽîçé··············]';

  @override
  String get freeSpaceEntryHint => '[Ŵáṽéļöĝ ķééþš ţĥéɱ.········]';

  @override
  String get freeSpaceIntro =>
      '[Ţĥîš ŕéɱöṽéš ţĥé çöþîéš öñ ţĥîš ðéṽîçé öƒ ǪŠÖš ţĥáţ Ŵáṽéļöĝ áļŕéáðý ĥáš. Ñöţĥîñĝ îš ðéļéţéð öñ Ŵáṽéļöĝ. Ţîðéļîñé ášķš Ŵáṽéļöĝ ƒîŕšţ áñð ķééþš éṽéŕýţĥîñĝ îţ çáññöţ ƒîñð ţĥéŕé. Ŵöŕķéð-ƀéƒöŕé ĥîñţš áñð šţáţîöñ ñáɱéš šţáý.························································································]';

  @override
  String get freeSpaceScope => '[Ŵĥîçĥ ǪŠÖš····]';

  @override
  String get freeSpaceOlder1 => '[Öļðéŕ ţĥáñ 1 ýéáŕ·······]';

  @override
  String get freeSpaceOlder2 => '[Öļðéŕ ţĥáñ 2 ýéáŕš········]';

  @override
  String get freeSpaceOlder5 => '[Öļðéŕ ţĥáñ 5 ýéáŕš········]';

  @override
  String get freeSpaceAll => '[Åļļ šýñçéð ǪŠÖš······]';

  @override
  String freeSpaceEligible(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count[ ǪŠÖš çáñ ƀé ŕéɱöṽéð········]',
      one: '[1 ǪŠÖ çáñ ƀé ŕéɱöṽéð········]',
      zero: '[Ñö ǪŠÖš çáñ ƀé ŕéɱöṽéð·········]',
    );
    return '$_temp0';
  }

  @override
  String get freeSpaceStaying => '[Šţáýîñĝ öñ ţĥîš ðéṽîçé·········]';

  @override
  String freeSpaceBlockedNotSynced(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count[ ǪŠÖš áŕé ñöţ öñ Ŵáṽéļöĝ ýéţ············]',
      one: '[1 ǪŠÖ îš ñöţ öñ Ŵáṽéļöĝ ýéţ···········]',
    );
    return '$_temp0';
  }

  @override
  String freeSpaceBlockedChanged(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count[ ǪŠÖš ŵéŕé çĥáñĝéð áƒţéŕ ţĥéý ŵéŕé šéñţ················]',
      one: '[1 ǪŠÖ ŵáš çĥáñĝéð áƒţéŕ îţ ŵáš šéñţ··············]',
    );
    return '$_temp0';
  }

  @override
  String freeSpaceBlockedContest(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count[ ǪŠÖš ƀéļöñĝ ţö çöñţéšţ šéššîöñš·············]',
      one: '[1 ǪŠÖ ƀéļöñĝš ţö á çöñţéšţ šéššîöñ··············]',
    );
    return '$_temp0';
  }

  @override
  String freeSpaceBlockedActivation(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count[ ǪŠÖš ƀéļöñĝ ţö áçţîṽáţîöñš···········]',
      one: '[1 ǪŠÖ ƀéļöñĝš ţö áñ áçţîṽáţîöñ············]',
    );
    return '$_temp0';
  }

  @override
  String get freeSpaceCheck => '[Çĥéçķ ŵîţĥ Ŵáṽéļöĝ········]';

  @override
  String get freeSpaceChecking => '[Åšķîñĝ Ŵáṽéļöĝ …·······]';

  @override
  String freeSpaceConfirmedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '[Ŵáṽéļöĝ ĥáš ·····]$count[ öƒ ţĥéɱ····]',
      one: '[Ŵáṽéļöĝ ĥáš 1 öƒ ţĥéɱ·········]',
      zero: '[Ŵáṽéļöĝ ĥáš ñöñé öƒ ţĥéɱ··········]',
    );
    return '$_temp0';
  }

  @override
  String freeSpaceMissingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count[ ŵéŕé ñöţ ƒöûñð öñ Ŵáṽéļöĝ áñð šţáý··············]',
      one: '[1 ŵáš ñöţ ƒöûñð öñ Ŵáṽéļöĝ áñð šţáýš···············]',
    );
    return '$_temp0';
  }

  @override
  String get freeSpaceOffline =>
      '[Ŵáṽéļöĝ çöûļð ñöţ ƀé ŕéáçĥéð. Ñöţĥîñĝ ŵáš ŕéɱöṽéð.····················]';

  @override
  String get freeSpaceUnauthorized =>
      '[Ţĥé ţöķéñ ñö ļöñĝéŕ ŵöŕķš. Éñţéŕ á ñéŵ ţöķéñ ƒîŕšţ. Ñöţĥîñĝ ŵáš ŕéɱöṽéð.·····························]';

  @override
  String get freeSpaceServerProblem =>
      '[Ŵáṽéļöĝ áñšŵéŕéð ŵîţĥ áñ éŕŕöŕ. Ñöţĥîñĝ ŵáš ŕéɱöṽéð.·····················]';

  @override
  String get freeSpaceTooMany =>
      '[Ţĥéŕé áŕé ţöö ɱáñý ǪŠÖš îñ ţĥáţ þéŕîöð ţö çĥéçķ áţ öñçé. Çĥööšé á šĥöŕţéŕ þéŕîöð.·································]';

  @override
  String freeSpaceRemoveButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '[Ŕéɱöṽé ···]$count[ ǪŠÖš ƒŕöɱ ţĥîš ðéṽîçé·········]',
      one: '[Ŕéɱöṽé 1 ǪŠÖ ƒŕöɱ ţĥîš ðéṽîçé············]',
    );
    return '$_temp0';
  }

  @override
  String get freeSpaceConfirmTitle => '[Ŕéɱöṽé ƒŕöɱ ţĥîš ðéṽîçé?··········]';

  @override
  String freeSpaceConfirmBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count[ ǪŠÖš··]',
      one: '[1 ǪŠÖ··]',
    );
    return '$_temp0[ ŵîļļ ƀé ŕéɱöṽéð ƒŕöɱ ţĥîš ðéṽîçé. Ţĥéý šţáý öñ Ŵáṽéļöĝ. Ýöû çáñ šáṽé ţĥéɱ áš áñ ÅÐÎƑ ƒîļé ƒîŕšţ.·······································]';
  }

  @override
  String get freeSpaceExportRemove => '[Éẋþöŕţ, ţĥéñ ŕéɱöṽé········]';

  @override
  String get freeSpaceRemoveOnly => '[Ŕéɱöṽé···]';

  @override
  String freeSpaceDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '[Ŕéɱöṽéð ····]$count[ ǪŠÖš ƒŕöɱ ţĥîš ðéṽîçé. Ţĥéý áŕé šţîļļ öñ Ŵáṽéļöĝ.····················]',
      one: '[Ŕéɱöṽéð 1 ǪŠÖ ƒŕöɱ ţĥîš ðéṽîçé. Îţ îš šţîļļ öñ Ŵáṽéļöĝ.······················]',
    );
    return '$_temp0';
  }

  @override
  String freeSpaceSoFar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count[ ǪŠÖš ŕéɱöṽéð šö ƒáŕ········]',
      one: '[1 ǪŠÖ ŕéɱöṽéð šö ƒáŕ········]',
      zero: '[Ñöţĥîñĝ ŕéɱöṽéð šö ƒáŕ·········]',
    );
    return '$_temp0';
  }

  @override
  String get qsoRemoveFromDevice => '[Ŕéɱöṽé ƒŕöɱ ţĥîš ðéṽîçé··········]';

  @override
  String get qsoRemoveFromDeviceHint =>
      '[Ŵáṽéļöĝ ķééþš îţ. Ţîðéļîñé çĥéçķš ţĥáţ ƒîŕšţ.··················]';

  @override
  String get qsoNotRemoved =>
      '[Ñöţ ŕéɱöṽéð: Ŵáṽéļöĝ çöûļð ñöţ çöñƒîŕɱ ţĥîš ǪŠÖ.····················]';

  @override
  String journalEvictedLocally(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count[ ǪŠÖš ŕéɱöṽéð ƒŕöɱ ţĥîš ðéṽîçé (šţîļļ öñ Ŵáṽéļöĝ)····················]',
      one: '[1 ǪŠÖ ŕéɱöṽéð ƒŕöɱ ţĥîš ðéṽîçé (šţîļļ öñ Ŵáṽéļöĝ)····················]',
    );
    return '$_temp0';
  }

  @override
  String get commandFastLogEntry => '[Ƒášţ Ļöĝ Éñţŕý······]';

  @override
  String get fleTitle => '[Ƒášţ Ļöĝ Éñţŕý······]';

  @override
  String get fleIntro =>
      '[Ţýþé ǪŠÖš áš šĥöŕţĥáñð, öñé þéŕ ļîñé. Ñöţĥîñĝ îš ļöĝĝéð ûñţîļ ýöû çöñƒîŕɱ áţ ţĥé ƀöţţöɱ.····································]';

  @override
  String get fleStation => '[Šţáţîöñ ļöçáţîöñ·······]';

  @override
  String get fleTextLabel => '[ǪŠÖš··]';

  @override
  String get fleExample =>
      '[20ɱ çŵ\n1734 ÐĻ1ÅƁÇ 599 579\n5 Ĝ4ẊÝŽ\n1800 Ƒ5ÅƁÇ ĵñ18····················]';

  @override
  String get fleSyntaxTitle => '[Ĥöŵ ţĥé šĥöŕţĥáñð ŵöŕķš··········]';

  @override
  String get fleSyntaxBody =>
      '[Öñé ǪŠÖ þéŕ ļîñé: ţîɱé, çáļļšîĝñ, ţĥéñ öþţîöñáļ ŕéþöŕţš, ļöçáţöŕ, ŕéƒéŕéñçé, @ñáɱé.\nƁáñð, ɱöðé öŕ ƒŕéǫûéñçý öñ á ļîñé öƒ ţĥéîŕ öŵñ áþþļý ţö ţĥé ļîñéš áƒţéŕ îţ (20ɱ, çŵ, 14.205).\nÅƒţéŕ ţĥé ƒîŕšţ ţîɱé, öñļý ţĥé çĥáñĝéð ðîĝîţš áŕé ñééðéð: 1734, ţĥéñ 5 ɱéáñš 1735, 40 ɱéáñš 1740.\nÐáţé: ðáţé 2026-10-02, öŕ ðáý + ƒöŕ ţĥé ñéẋţ ðáý. Ţîɱé žöñé: ţîɱéžöñé +2 (ýöûŕ ļöçáļ ţîɱé îš ţĥéñ çöñṽéŕţéð ţö ÛŢÇ).\nŔéþöŕţš: 59, 599, -12. Öñé ŕéþöŕţ îš ţĥé öñé ýöû šéñţ.\nṀöŕé: <çöɱɱéñţ>, [ǪŠĻ ɱéššáĝé], <ţẋ_þŵŕ:50>.·····································································································································································································]';

  @override
  String get flePreview => '[Þŕéṽîéŵ···]';

  @override
  String get fleEmpty => '[Ñöţĥîñĝ ţö ŕéáð ýéţ.········]';

  @override
  String fleLine(int number) {
    return '[Ļîñé ··]$number';
  }

  @override
  String get fleHeaderLine => '[Šéţš ŵĥáţ ƒöļļöŵš·······]';

  @override
  String get fleDuplicate =>
      '[Ðûþļîçáţé: áļŕéáðý îñ ţĥé ļöĝ öŕ éáŕļîéŕ îñ ţĥîš ţéẋţ······················]';

  @override
  String get fleWarnBackwards =>
      '[Éáŕļîéŕ ţĥáñ ţĥé ǪŠÖ ƀéƒöŕé. Å ðáý + ɱîššîñĝ?··················]';

  @override
  String get fleWarnFuture => '[Îñ ţĥé ƒûţûŕé······]';

  @override
  String get fleSkipProblems => '[Šķîþ ļîñéš ŵîţĥ þŕöƀļéɱš··········]';

  @override
  String get fleLogDuplicates => '[Åļšö ļöĝ ðûþļîçáţéš········]';

  @override
  String fleSummary(int qsos, int problems, int dupes) {
    String _temp0 = intl.Intl.pluralLogic(
      qsos,
      locale: localeName,
      other: '$qsos[ ǪŠÖš··]',
      one: '[1 ǪŠÖ··]',
    );
    String _temp1 = intl.Intl.pluralLogic(
      problems,
      locale: localeName,
      other: '$problems[ þŕöƀļéɱš····]',
      one: '[1 þŕöƀļéɱ····]',
      zero: '[ñö þŕöƀļéɱš·····]',
    );
    String _temp2 = intl.Intl.pluralLogic(
      dupes,
      locale: localeName,
      other: '$dupes[ ðûþļîçáţéš·····]',
      one: '[1 ðûþļîçáţé·····]',
      zero: '[ñö ðûþļîçáţéš······]',
    );
    return '$_temp0[ ţö ļöĝ · ····]$_temp1[ · ··]$_temp2';
  }

  @override
  String fleLogButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '[Ļöĝ ··]$count[ ǪŠÖš··]',
      one: '[Ļöĝ 1 ǪŠÖ····]',
      zero: '[Ļöĝ ǪŠÖš····]',
    );
    return '$_temp0';
  }

  @override
  String fleActivationNotice(String reference) {
    return '[Ţĥéšé ǪŠÖš ĝö îñţö ýöûŕ ŕûññîñĝ áçţîṽáţîöñ ··················]$reference[.·]';
  }

  @override
  String fleLogged(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '[Ļöĝĝéð ···]$count[ ǪŠÖš··]',
      one: '[Ļöĝĝéð 1 ǪŠÖ·····]',
    );
    return '$_temp0';
  }

  @override
  String fleQsoDetails(String time, String band, String mode, String rst) {
    return '$time[ ÛŢÇ · ···]$band[ ·]$mode[ · ··]$rst';
  }

  @override
  String fleProblemUnknownToken(String token) {
    return '[Ñöţ ûñðéŕšţööð: ·······]$token';
  }

  @override
  String get fleProblemUnclosedBracket =>
      '[Å [ öŕ < îš ñéṽéŕ çļöšéð··········]';

  @override
  String fleProblemInvalidTime(String token) {
    return '[Ñöţ á ţîɱé: ·····]$token';
  }

  @override
  String get fleProblemMissingTime =>
      '[Ñö ţîɱé ýéţ. Šţáŕţ ŵîţĥ á ƒûļļ ţîɱé ļîķé 1734.···················]';

  @override
  String get fleProblemMissingCall => '[Ñö çáļļšîĝñ öñ ţĥîš ļîñé··········]';

  @override
  String get fleProblemMissingBand =>
      '[Ñö ƀáñð ýéţ. Þûţ á ƀáñð (20ɱ) öŕ ƒŕéǫûéñçý (14.205) öñ á ļîñé ƀéƒöŕé.····························]';

  @override
  String get fleProblemMissingMode =>
      '[Ñö ɱöðé ýéţ. Þûţ á ɱöðé (çŵ, ššƀ, ƒţ8) öñ á ļîñé ƀéƒöŕé.·······················]';

  @override
  String fleProblemUnsupportedBand(String token) {
    return '[Ɓáñð ñöţ šûþþöŕţéð: ········]$token';
  }

  @override
  String fleProblemFrequencyOutsideBands(String token) {
    return '[Ƒŕéǫûéñçý îš ñöţ îñ áñ áɱáţéûŕ ƀáñð: ···············]$token';
  }

  @override
  String fleProblemInvalidDate(String token) {
    return '[Ñöţ á ðáţé: ·····]$token';
  }

  @override
  String get fleProblemInvalidDayShift => '[Ţöö ɱáñý + áƒţéŕ ðáý········]';

  @override
  String fleProblemInvalidTimezone(String token) {
    return '[Ţîɱé žöñé ɱûšţ ƀé ƀéţŵééñ -12 áñð +14: ················]$token';
  }

  @override
  String fleProblemSecondCallsign(String token) {
    return '[Å šéçöñð çáļļšîĝñ: ········]$token[. Öñé ǪŠÖ þéŕ ļîñé.········]';
  }

  @override
  String fleProblemDuplicateSegment(String token) {
    return '[Ţŵîçé öñ öñé ļîñé: ········]$token';
  }

  @override
  String fleProblemReportBeforeCall(String token) {
    return '[Ŕéþöŕţš çöɱé áƒţéŕ ţĥé çáļļšîĝñ: ··············]$token';
  }

  @override
  String fleProblemTooManyReports(String token) {
    return '[Ṁöŕé ţĥáñ ţŵö ŕéþöŕţš: ··········]$token';
  }

  @override
  String fleProblemInvalidReport(String token) {
    return '[Ŕéþöŕţ ðöéš ñöţ ƒîţ ţĥé ɱöðé: ············]$token';
  }

  @override
  String fleProblemInvalidFieldName(String token) {
    return '[Ñöţ á ƒîéļð ñáɱé: ········]$token';
  }

  @override
  String fleProblemReservedField(String token) {
    return '[Ţĥîš ƒîéļð çáññöţ ƀé šéţ ĥéŕé: ·············]$token';
  }

  @override
  String fleProblemValueTooLong(String token) {
    return '[Ţöö ļöñĝ: ····]$token';
  }

  @override
  String get fleProblemLineTooLong => '[Ţĥé ļîñé îš ţöö ļöñĝ········]';

  @override
  String get fleProblemTooManyLines =>
      '[Ţöö ɱáñý ļîñéš. Ţĥé ŕéšţ ŵáš ñöţ ŕéáð.················]';

  @override
  String get fleLogFailed =>
      '[Ţĥé ǪŠÖš çöûļð ñöţ ƀé ļöĝĝéð. Ñöţĥîñĝ ŵáš ļöĝĝéð.····················]';

  @override
  String get fleNoStation => '[Çĥööšé á šţáţîöñ ļöçáţîöñ ƒîŕšţ.·············]';

  @override
  String get settingsFieldMode => '[Ƒîéļð ɱöðé····]';

  @override
  String get settingsFieldModeHint =>
      '[Šûñļîĝĥţ, ƀîĝ ƀûţţöñš, ļéšš ƀáţţéŕý ûšé················]';

  @override
  String get fieldModeIntro =>
      '[Ƒöŕ öþéŕáţîñĝ öûţðööŕš: öñé šŵîţçĥ šéţš ţĥé šûñļîĝĥţ ţĥéɱé, ĝļöṽé ɱöðé, ţĥé ƀáţţéŕý šáṽéŕ áñð ķééþš ţĥé šçŕééñ öñ. Šŵîţçĥîñĝ îţ öƒƒ þûţš ýöûŕ ţĥéɱé áñð ƀûţţöñ šîžé ƀáçķ. Ýöû çáñ áļšö šéţ éáçĥ þáŕţ öñ îţš öŵñ ƀéļöŵ.······················································································]';

  @override
  String get fieldModeSwitch => '[Ƒîéļð ɱöðé····]';

  @override
  String get fieldModeSwitchHint =>
      '[Šéţš ţĥé ƒöûŕ öþţîöñš ƀéļöŵ ţöĝéţĥéŕ···············]';

  @override
  String get fieldModeParts => '[Ţĥé þáŕţš····]';

  @override
  String get fieldModeSunlight =>
      '[Šûñļîĝĥţ ţĥéɱé (ɱáẋîɱûɱ çöñţŕášţ)··············]';

  @override
  String get fieldModeBatterySaver => '[Ɓáţţéŕý šáṽéŕ······]';

  @override
  String get fieldModeBatterySaverHint =>
      '[Ţĥé ţîðé šţáñðš šţîļļ áñð ţĥé çļöçķ ûþðáţéš öñçé á ɱîñûţé. Šýñç šţîļļ ŕûñš ŵĥéñ ýöû öþéñ ţĥé áþþ, ŵĥéñ ţĥé ñéţŵöŕķ ŕéţûŕñš áñð ŵĥéñ ýöû ášķ.························································]';

  @override
  String get fieldModeKeepScreenOn =>
      '[Ķééþ ţĥé šçŕééñ öñ ŵĥîļé ļöĝĝîñĝ·············]';

  @override
  String get fieldModeKeepScreenOnHint =>
      '[Öñļý ŵĥîļé ţĥé ļöĝ, Ƒášţ Ļöĝ Éñţŕý öŕ ţĥé çöñţéšţ šçŕééñ îš öþéñ. Ţĥîš ûšéš ɱöŕé ƀáţţéŕý.····································]';
}
