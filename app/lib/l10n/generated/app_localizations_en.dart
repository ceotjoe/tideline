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

  @override
  String get onboardingWelcomeTitle => 'Welcome to Tideline';

  @override
  String get onboardingWelcomeBody =>
      'Tideline saves your QSOs on this device first, with or without a connection, and syncs them to your own Wavelog server whenever it can reach it. Your log is never sent anywhere else.';

  @override
  String get onboardingStart => 'Connect to Wavelog';

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
  String get logEmptyBodyReady =>
      'Log your first QSO above. It is saved on this device right away, with or without a connection.';

  @override
  String get recentQsos => 'Recent QSOs';

  @override
  String get contextHint =>
      'Type a callsign to see its DXCC entity, zones and whether you worked it before. This works offline.';

  @override
  String contextWae(String name) {
    return 'WAE: $name';
  }

  @override
  String contextDxccNumber(int number) {
    return 'DXCC entity $number';
  }

  @override
  String get contextWorkedBefore => 'Worked before';

  @override
  String get contextNewOne => 'Not in your log yet – a new one!';

  @override
  String certSubjectLine(String value) {
    return 'Issued to: $value';
  }

  @override
  String certIssuerLine(String value) {
    return 'Issued by: $value';
  }
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

  @override
  String get onboardingWelcomeTitle => '[Ŵéļçöɱé ţö Ţîðéļîñé········]';

  @override
  String get onboardingWelcomeBody =>
      '[Ţîðéļîñé šáṽéš ýöûŕ ǪŠÖš öñ ţĥîš ðéṽîçé ƒîŕšţ, ŵîţĥ öŕ ŵîţĥöûţ á çöññéçţîöñ, áñð šýñçš ţĥéɱ ţö ýöûŕ öŵñ Ŵáṽéļöĝ šéŕṽéŕ ŵĥéñéṽéŕ îţ çáñ ŕéáçĥ îţ. Ýöûŕ ļöĝ îš ñéṽéŕ šéñţ áñýŵĥéŕé éļšé.·········································································]';

  @override
  String get onboardingStart => '[Çöññéçţ ţö Ŵáṽéļöĝ········]';

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
  String get logEmptyBodyReady =>
      '[Ļöĝ ýöûŕ ƒîŕšţ ǪŠÖ áƀöṽé. Îţ îš šáṽéð öñ ţĥîš ðéṽîçé ŕîĝĥţ áŵáý, ŵîţĥ öŕ ŵîţĥöûţ á çöññéçţîöñ.······································]';

  @override
  String get recentQsos => '[Ŕéçéñţ ǪŠÖš·····]';

  @override
  String get contextHint =>
      '[Ţýþé á çáļļšîĝñ ţö šéé îţš ÐẊÇÇ éñţîţý, žöñéš áñð ŵĥéţĥéŕ ýöû ŵöŕķéð îţ ƀéƒöŕé. Ţĥîš ŵöŕķš öƒƒļîñé.········································]';

  @override
  String contextWae(String name) {
    return '[ŴÅÉ: ··]$name';
  }

  @override
  String contextDxccNumber(int number) {
    return '[ÐẊÇÇ éñţîţý ·····]$number';
  }

  @override
  String get contextWorkedBefore => '[Ŵöŕķéð ƀéƒöŕé······]';

  @override
  String get contextNewOne => '[Ñöţ îñ ýöûŕ ļöĝ ýéţ – á ñéŵ öñé!·············]';

  @override
  String certSubjectLine(String value) {
    return '[Îššûéð ţö: ·····]$value';
  }

  @override
  String certIssuerLine(String value) {
    return '[Îššûéð ƀý: ·····]$value';
  }
}
