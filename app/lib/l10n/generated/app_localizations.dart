import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('en', 'XA'),
  ];

  /// App name. Do not translate.
  ///
  /// In en, this message translates to:
  /// **'Tideline'**
  String get appTitle;

  /// Tagline under the app name.
  ///
  /// In en, this message translates to:
  /// **'The offline logger for Wavelog'**
  String get appTagline;

  /// Navigation destination: the QSO log.
  ///
  /// In en, this message translates to:
  /// **'Log'**
  String get navLog;

  /// Navigation destination: sync status and history.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get navSync;

  /// Navigation destination: settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// Title shown when the log is empty.
  ///
  /// In en, this message translates to:
  /// **'No QSOs yet'**
  String get logEmptyTitle;

  /// Title on the sync screen when the queue is empty.
  ///
  /// In en, this message translates to:
  /// **'Nothing to sync'**
  String get syncEmptyTitle;

  /// Explanation on the sync screen.
  ///
  /// In en, this message translates to:
  /// **'When you log QSOs, they wait here until Tideline can reach your Wavelog server.'**
  String get syncEmptyBody;

  /// Text equivalent of the tide gauge sync indicator.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{All QSOs synced} =1{1 QSO waiting to sync} other{{count} QSOs waiting to sync}}'**
  String tideGaugeLabel(int count);

  /// Settings section heading.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// Setting label: colour theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// Theme option: follow the OS light/dark setting.
  ///
  /// In en, this message translates to:
  /// **'Match system'**
  String get themeSystem;

  /// Theme option.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// Theme option.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// Theme option for bright outdoor use.
  ///
  /// In en, this message translates to:
  /// **'Sunlight (maximum contrast)'**
  String get themeSunlight;

  /// Theme option: red on black to preserve night vision.
  ///
  /// In en, this message translates to:
  /// **'Night red'**
  String get themeNightRed;

  /// Setting label: size and spacing of controls.
  ///
  /// In en, this message translates to:
  /// **'Touch targets'**
  String get settingsDensity;

  /// Density option.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get densityComfortable;

  /// Density option with larger touch targets for gloves.
  ///
  /// In en, this message translates to:
  /// **'Glove mode (extra large)'**
  String get densityGlove;

  /// Toggle: wider letter, word and line spacing for easier reading.
  ///
  /// In en, this message translates to:
  /// **'Extra text spacing'**
  String get settingsTextSpacing;

  /// Setting label: app language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// Language option: use the device language.
  ///
  /// In en, this message translates to:
  /// **'Match system'**
  String get languageSystem;

  /// Settings entry that opens the shortcut overview.
  ///
  /// In en, this message translates to:
  /// **'Keyboard shortcuts'**
  String get settingsKeyboard;

  /// Title of the shortcut overview overlay.
  ///
  /// In en, this message translates to:
  /// **'Keyboard shortcuts'**
  String get shortcutsTitle;

  /// Button closing the shortcut overview.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get shortcutsClose;

  /// Group heading for shortcuts that work on every screen.
  ///
  /// In en, this message translates to:
  /// **'Everywhere'**
  String get shortcutScopeGlobal;

  /// Group heading for logging shortcuts.
  ///
  /// In en, this message translates to:
  /// **'Logging'**
  String get shortcutScopeLogging;

  /// Group heading for contest shortcuts.
  ///
  /// In en, this message translates to:
  /// **'Contest mode'**
  String get shortcutScopeContest;

  /// Command name.
  ///
  /// In en, this message translates to:
  /// **'Show keyboard shortcuts'**
  String get commandShowShortcuts;

  /// Command name.
  ///
  /// In en, this message translates to:
  /// **'Go to log'**
  String get commandGoToLog;

  /// Command name.
  ///
  /// In en, this message translates to:
  /// **'Go to sync'**
  String get commandGoToSync;

  /// Command name.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get commandGoToSettings;

  /// Command name: start synchronisation immediately.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get commandSyncNow;

  /// Command name: start entering a new contact.
  ///
  /// In en, this message translates to:
  /// **'New QSO'**
  String get commandNewQso;

  /// Command name: save the contact being entered.
  ///
  /// In en, this message translates to:
  /// **'Log QSO'**
  String get commandLogQso;

  /// Command name: discard the contact being entered.
  ///
  /// In en, this message translates to:
  /// **'Clear entry'**
  String get commandClearEntry;

  /// Command name.
  ///
  /// In en, this message translates to:
  /// **'Edit last QSO'**
  String get commandEditLastQso;

  /// Command name: move to the next entry field.
  ///
  /// In en, this message translates to:
  /// **'Next field'**
  String get commandNextField;

  /// Command name: switch to the next higher band.
  ///
  /// In en, this message translates to:
  /// **'Next band'**
  String get commandBandUp;

  /// Command name: switch to the next lower band.
  ///
  /// In en, this message translates to:
  /// **'Previous band'**
  String get commandBandDown;

  /// Command name: cycle the operating mode.
  ///
  /// In en, this message translates to:
  /// **'Next mode'**
  String get commandNextMode;

  /// Name of the Control key in shortcut lists.
  ///
  /// In en, this message translates to:
  /// **'Ctrl'**
  String get keyControl;

  /// Name of the Shift key.
  ///
  /// In en, this message translates to:
  /// **'Shift'**
  String get keyShift;

  /// Name of the Alt key (Option on Apple keyboards is shown as a symbol).
  ///
  /// In en, this message translates to:
  /// **'Alt'**
  String get keyAlt;

  /// Name of the Enter/Return key.
  ///
  /// In en, this message translates to:
  /// **'Enter'**
  String get keyEnter;

  /// Name of the Escape key.
  ///
  /// In en, this message translates to:
  /// **'Esc'**
  String get keyEscape;

  /// Name of the space bar.
  ///
  /// In en, this message translates to:
  /// **'Space'**
  String get keySpace;

  /// Name of the Tab key.
  ///
  /// In en, this message translates to:
  /// **'Tab'**
  String get keyTab;

  /// Name of the Page Up key.
  ///
  /// In en, this message translates to:
  /// **'Page Up'**
  String get keyPageUp;

  /// Name of the Page Down key.
  ///
  /// In en, this message translates to:
  /// **'Page Down'**
  String get keyPageDown;

  /// Settings section shown only in debug builds.
  ///
  /// In en, this message translates to:
  /// **'Developer options'**
  String get settingsDeveloper;

  /// Debug toggle that mirrors the layout to test right-to-left languages.
  ///
  /// In en, this message translates to:
  /// **'Force right-to-left layout'**
  String get debugForceRtl;

  /// Debug-only language option with accented, longer text.
  ///
  /// In en, this message translates to:
  /// **'Pseudo-locale (testing)'**
  String get languagePseudo;

  /// Title when the database exists but its key is gone from the secure store.
  ///
  /// In en, this message translates to:
  /// **'Your log can\'t be unlocked'**
  String get startupKeyMissingTitle;

  /// Explanation of the missing database key situation.
  ///
  /// In en, this message translates to:
  /// **'Tideline found its log on this device, but the key that unlocks it is missing from the system\'s secure storage. This can happen after restoring the device from a backup. Nothing has been deleted. Restore a Tideline backup, or reinstall the app to start a new log.'**
  String get startupKeyMissingBody;

  /// Title of the generic startup error screen.
  ///
  /// In en, this message translates to:
  /// **'Tideline couldn\'t start'**
  String get startupErrorTitle;

  /// Generic startup error explanation.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while opening your log. Your QSOs have not been changed. Please restart the app; if this keeps happening, report it on GitHub.'**
  String get startupErrorBody;

  /// Shown in the shortcut list for a command without a shortcut.
  ///
  /// In en, this message translates to:
  /// **'Not assigned'**
  String get shortcutsUnbound;

  /// Separator between two alternative shortcuts for the same command.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get shortcutsOr;

  /// Onboarding welcome title.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Tideline'**
  String get onboardingWelcomeTitle;

  /// Onboarding welcome explanation.
  ///
  /// In en, this message translates to:
  /// **'Tideline saves your QSOs on this device first, with or without a connection, and syncs them to your own Wavelog server whenever it can reach it. Your log is never sent anywhere else.'**
  String get onboardingWelcomeBody;

  /// Button starting setup.
  ///
  /// In en, this message translates to:
  /// **'Connect to Wavelog'**
  String get onboardingStart;

  /// Onboarding progress.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String onboardingStepOf(int current, int total);

  /// Onboarding step title.
  ///
  /// In en, this message translates to:
  /// **'Your Wavelog server'**
  String get onboardingServerTitle;

  /// Onboarding server explanation.
  ///
  /// In en, this message translates to:
  /// **'Enter the address you use to open Wavelog in your browser. Wavelog 3.1 or newer is needed.'**
  String get onboardingServerBody;

  /// Label of the server URL field.
  ///
  /// In en, this message translates to:
  /// **'Server address'**
  String get fieldServerUrl;

  /// Example server URL. Keep as an example address.
  ///
  /// In en, this message translates to:
  /// **'https://log.example.org'**
  String get fieldServerUrlHint;

  /// Label of the account name field.
  ///
  /// In en, this message translates to:
  /// **'Name for this account (optional)'**
  String get fieldAccountLabel;

  /// Hint for the account name field.
  ///
  /// In en, this message translates to:
  /// **'For example Personal or Club station'**
  String get fieldAccountLabelHint;

  /// Opt-in for plain HTTP on the LAN.
  ///
  /// In en, this message translates to:
  /// **'Allow an unencrypted connection (local network only)'**
  String get onboardingAllowHttp;

  /// Warning for plain HTTP.
  ///
  /// In en, this message translates to:
  /// **'Only for a server in your own network. Your token and QSOs travel without encryption. Never use this over the internet.'**
  String get onboardingAllowHttpWarning;

  /// Generic continue button.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get actionContinue;

  /// Generic back button.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get actionBack;

  /// Onboarding step title.
  ///
  /// In en, this message translates to:
  /// **'API token'**
  String get onboardingTokenTitle;

  /// Onboarding token explanation.
  ///
  /// In en, this message translates to:
  /// **'In Wavelog, open your user menu, choose API and create a new v2 token. Paste it here. It starts with wl2_ and is kept only in this device\'s secure storage.'**
  String get onboardingTokenBody;

  /// Label of the token field.
  ///
  /// In en, this message translates to:
  /// **'API token'**
  String get fieldToken;

  /// Heading for required token scopes.
  ///
  /// In en, this message translates to:
  /// **'Required permissions'**
  String get onboardingScopesRequired;

  /// Heading for optional token scopes.
  ///
  /// In en, this message translates to:
  /// **'Optional permissions'**
  String get onboardingScopesOptional;

  /// Explanation of a token scope. Keep the scope name.
  ///
  /// In en, this message translates to:
  /// **'qso:write – upload your QSOs and correct uploaded ones'**
  String get scopeQsoWrite;

  /// Explanation of a token scope. Keep the scope name.
  ///
  /// In en, this message translates to:
  /// **'qso:read – check the server before sending again, so nothing is duplicated'**
  String get scopeQsoRead;

  /// Explanation of a token scope. Keep the scope name.
  ///
  /// In en, this message translates to:
  /// **'station:read – list your station locations'**
  String get scopeStationRead;

  /// Explanation of a token scope. Keep the scope name.
  ///
  /// In en, this message translates to:
  /// **'qso:delete – also delete in Wavelog what you delete in Tideline'**
  String get scopeQsoDelete;

  /// Explanation of token scopes. Keep the scope names.
  ///
  /// In en, this message translates to:
  /// **'contest:read and contest:write – contest sessions in Wavelog (3.2 or newer)'**
  String get scopeContest;

  /// Explanation of a token scope. Keep the scope name.
  ///
  /// In en, this message translates to:
  /// **'lookup:read – online callsign lookups while connected'**
  String get scopeLookup;

  /// Screen-reader label: the token has this permission.
  ///
  /// In en, this message translates to:
  /// **'granted'**
  String get scopeGranted;

  /// Screen-reader label: the token lacks this permission.
  ///
  /// In en, this message translates to:
  /// **'missing'**
  String get scopeMissing;

  /// Button that checks server and token.
  ///
  /// In en, this message translates to:
  /// **'Check connection'**
  String get actionCheckToken;

  /// Progress label.
  ///
  /// In en, this message translates to:
  /// **'Checking your server…'**
  String get onboardingChecking;

  /// Onboarding step title.
  ///
  /// In en, this message translates to:
  /// **'Station location'**
  String get onboardingStationTitle;

  /// Station step explanation.
  ///
  /// In en, this message translates to:
  /// **'New QSOs are uploaded to this station location. You can choose another one for each QSO.'**
  String get onboardingStationBody;

  /// Result of the server check.
  ///
  /// In en, this message translates to:
  /// **'Connected to Wavelog 3.1. Contest sessions need Wavelog 3.2 or newer.'**
  String get onboardingServerVersion31;

  /// Result of the server check.
  ///
  /// In en, this message translates to:
  /// **'Connected to Wavelog 3.2 or newer.'**
  String get onboardingServerVersion32;

  /// Shown when the account has no stations.
  ///
  /// In en, this message translates to:
  /// **'Your Wavelog account has no station locations yet. Create one in Wavelog under Station Setup, then check again.'**
  String get onboardingNoStations;

  /// Button finishing setup.
  ///
  /// In en, this message translates to:
  /// **'Start logging'**
  String get onboardingFinish;

  /// Onboarding problem.
  ///
  /// In en, this message translates to:
  /// **'That doesn\'t look like a web address. Use the address you open Wavelog with, for example https://log.example.org.'**
  String get problemInvalidUrl;

  /// Onboarding problem.
  ///
  /// In en, this message translates to:
  /// **'Unencrypted http:// is only possible for servers in your own network. Use https:// for servers on the internet.'**
  String get problemInsecurePublicHttp;

  /// Onboarding problem.
  ///
  /// In en, this message translates to:
  /// **'This address uses unencrypted http://. Switch on “Allow an unencrypted connection” if the server is in your own network.'**
  String get problemHttpNeedsOptIn;

  /// Onboarding problem.
  ///
  /// In en, this message translates to:
  /// **'The server didn\'t answer. Check the address and your connection. You can also set Tideline up later.'**
  String get problemUnreachable;

  /// Onboarding problem.
  ///
  /// In en, this message translates to:
  /// **'This server answers, but not like Wavelog 3.1 or newer. Check the address, or update Wavelog.'**
  String get problemNoApiV2;

  /// Onboarding problem.
  ///
  /// In en, this message translates to:
  /// **'Wavelog doesn\'t accept this token. Copy it again (it starts with wl2_) or create a new one.'**
  String get problemTokenInvalid;

  /// Onboarding problem.
  ///
  /// In en, this message translates to:
  /// **'This token has expired. Create a new one in Wavelog.'**
  String get problemTokenExpired;

  /// Onboarding problem.
  ///
  /// In en, this message translates to:
  /// **'This token is missing permissions Tideline needs: {scopes}. Create a token that includes them.'**
  String problemMissingScopes(Object scopes);

  /// Onboarding problem.
  ///
  /// In en, this message translates to:
  /// **'The server reported a problem. Please try again in a moment.'**
  String get problemServerError;

  /// Onboarding problem.
  ///
  /// In en, this message translates to:
  /// **'The connection isn\'t trusted, so nothing was sent. If this is your own server, check its certificate and try again.'**
  String get problemCertificateRejected;

  /// Trust-on-first-use dialog title.
  ///
  /// In en, this message translates to:
  /// **'Unknown certificate'**
  String get certTitle;

  /// Trust-on-first-use explanation.
  ///
  /// In en, this message translates to:
  /// **'Your device doesn\'t trust this server\'s certificate. That is common for self-hosted servers. Only continue if the fingerprint below matches the one of your server. If it ever changes, Tideline will stop and ask you again.'**
  String get certBody;

  /// Label.
  ///
  /// In en, this message translates to:
  /// **'SHA-256 fingerprint'**
  String get certFingerprint;

  /// Certificate validity.
  ///
  /// In en, this message translates to:
  /// **'Valid from {from} to {until}'**
  String certValidity(String from, String until);

  /// Button.
  ///
  /// In en, this message translates to:
  /// **'Trust this certificate'**
  String get certTrust;

  /// Button.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get certCancel;

  /// Sync state chip.
  ///
  /// In en, this message translates to:
  /// **'Synced'**
  String get statusSynced;

  /// Sync state chip: saved locally, not ready to upload.
  ///
  /// In en, this message translates to:
  /// **'On device'**
  String get statusLocal;

  /// Sync state chip.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get statusQueued;

  /// Sync state chip.
  ///
  /// In en, this message translates to:
  /// **'Uploading'**
  String get statusUploading;

  /// Sync state chip: checking the server before retrying.
  ///
  /// In en, this message translates to:
  /// **'Checking'**
  String get statusVerifying;

  /// Sync state chip: conflict.
  ///
  /// In en, this message translates to:
  /// **'Needs decision'**
  String get statusConflict;

  /// Sync state chip: account token not working.
  ///
  /// In en, this message translates to:
  /// **'Token problem'**
  String get statusBlocked;

  /// Sync state chip.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// Unit.
  ///
  /// In en, this message translates to:
  /// **'MHz'**
  String get unitMhz;

  /// Time zone label. Keep UTC.
  ///
  /// In en, this message translates to:
  /// **'UTC'**
  String get unitUtc;

  /// Field label.
  ///
  /// In en, this message translates to:
  /// **'Callsign'**
  String get fieldCallsign;

  /// Field label.
  ///
  /// In en, this message translates to:
  /// **'Band'**
  String get fieldBand;

  /// Field label.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get fieldMode;

  /// Field label.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get fieldFrequency;

  /// Live interpretation under the frequency field. {mhz} is the frequency in MHz, {band} the amateur band such as '20 m'. Keep the middle dot.
  ///
  /// In en, this message translates to:
  /// **'{mhz} MHz · {band}'**
  String freqReadoutInBand(String mhz, String band);

  /// Live interpretation under the frequency field when the frequency is in no amateur band. {mhz} is the frequency in MHz.
  ///
  /// In en, this message translates to:
  /// **'{mhz} MHz · outside amateur bands'**
  String freqReadoutOutsideBands(String mhz);

  /// Live hint under the frequency field when the input cannot be read.
  ///
  /// In en, this message translates to:
  /// **'Not a frequency. Type MHz (14.205) or kHz (14205).'**
  String get freqReadoutUnreadable;

  /// Hint under the empty frequency field.
  ///
  /// In en, this message translates to:
  /// **'Type MHz (14.205) or kHz (14205).'**
  String get freqReadoutEmpty;

  /// Screen reader text for the frequency interpretation. {band} is spoken, e.g. '20 metres'.
  ///
  /// In en, this message translates to:
  /// **'{mhz} megahertz, {band}'**
  String freqReadoutSemanticsInBand(String mhz, String band);

  /// Screen reader text for the frequency interpretation outside amateur bands.
  ///
  /// In en, this message translates to:
  /// **'{mhz} megahertz, outside amateur bands'**
  String freqReadoutSemanticsOutsideBands(String mhz);

  /// Field label. Keep RST.
  ///
  /// In en, this message translates to:
  /// **'RST sent'**
  String get fieldRstSent;

  /// Field label. Keep RST.
  ///
  /// In en, this message translates to:
  /// **'RST received'**
  String get fieldRstRcvd;

  /// Field label: operator name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get fieldName;

  /// Field label: Maidenhead grid locator.
  ///
  /// In en, this message translates to:
  /// **'Locator'**
  String get fieldGrid;

  /// Field label.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get fieldComment;

  /// Field label.
  ///
  /// In en, this message translates to:
  /// **'Station location'**
  String get fieldStation;

  /// Field label.
  ///
  /// In en, this message translates to:
  /// **'Date and time'**
  String get fieldDateUtc;

  /// Field label.
  ///
  /// In en, this message translates to:
  /// **'DXCC entity'**
  String get fieldCountry;

  /// Entry validation.
  ///
  /// In en, this message translates to:
  /// **'Enter a callsign, for example DL1ABC or EA8/DL1ABC/P.'**
  String get issueInvalidCall;

  /// Entry validation.
  ///
  /// In en, this message translates to:
  /// **'Choose a band or enter a frequency.'**
  String get issueMissingBand;

  /// Entry validation.
  ///
  /// In en, this message translates to:
  /// **'Choose a mode.'**
  String get issueMissingMode;

  /// Entry validation.
  ///
  /// In en, this message translates to:
  /// **'Enter the frequency in MHz (14.205) or kHz (14205).'**
  String get issueInvalidFrequency;

  /// Entry validation.
  ///
  /// In en, this message translates to:
  /// **'This frequency is outside the selected band.'**
  String get issueFrequencyOutsideBand;

  /// Entry validation.
  ///
  /// In en, this message translates to:
  /// **'A locator has 4, 6 or 8 characters, like JO40 or JO40hd.'**
  String get issueInvalidGrid;

  /// Warning after logging.
  ///
  /// In en, this message translates to:
  /// **'Saved. Choose a station location so this QSO can be uploaded.'**
  String get issueNoStation;

  /// Warning after logging.
  ///
  /// In en, this message translates to:
  /// **'Saved, but the time is in the future. Check your device clock.'**
  String get issueTimeInFuture;

  /// Screen-reader announcement after logging.
  ///
  /// In en, this message translates to:
  /// **'QSO with {call} logged.'**
  String qsoLoggedAnnouncement(String call);

  /// Current QSO time shown in the form.
  ///
  /// In en, this message translates to:
  /// **'Now: {time}'**
  String timeNow(String time);

  /// Manually chosen QSO time.
  ///
  /// In en, this message translates to:
  /// **'Set: {time}'**
  String timeManual(String time);

  /// Button.
  ///
  /// In en, this message translates to:
  /// **'Change time'**
  String get actionChangeTime;

  /// Button.
  ///
  /// In en, this message translates to:
  /// **'Use current time'**
  String get actionUseNow;

  /// Offline DXCC information for a callsign.
  ///
  /// In en, this message translates to:
  /// **'{name} · {continent} · CQ {cq} · ITU {itu}'**
  String dxccSummary(String name, String continent, int cq, int itu);

  /// Worked-before hint.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{worked once before} other{worked {count} times before}}'**
  String workedBefore(int count);

  /// Sync explanation.
  ///
  /// In en, this message translates to:
  /// **'This QSO is safely in your Wavelog.'**
  String get explainSynced;

  /// Sync explanation.
  ///
  /// In en, this message translates to:
  /// **'Saved on this device only. Choose a station location so it can be uploaded.'**
  String get explainLocal;

  /// Sync explanation.
  ///
  /// In en, this message translates to:
  /// **'Saved on this device and waiting for the next sync.'**
  String get explainQueued;

  /// Sync explanation.
  ///
  /// In en, this message translates to:
  /// **'Being sent to Wavelog right now.'**
  String get explainUploading;

  /// Sync explanation.
  ///
  /// In en, this message translates to:
  /// **'The last attempt didn\'t finish cleanly. Tideline checks your Wavelog before trying again, so the QSO is never duplicated.'**
  String get explainVerifying;

  /// Sync explanation.
  ///
  /// In en, this message translates to:
  /// **'This QSO needs your decision.'**
  String get explainConflict;

  /// Sync explanation.
  ///
  /// In en, this message translates to:
  /// **'Wavelog didn\'t accept this QSO. Correct it and it will be sent again.'**
  String get explainRejected;

  /// Sync explanation.
  ///
  /// In en, this message translates to:
  /// **'Waiting until the account\'s token works again. Nothing is lost.'**
  String get explainBlocked;

  /// Sync problem.
  ///
  /// In en, this message translates to:
  /// **'Your Wavelog wasn\'t reachable; Tideline will try again.'**
  String get problemSyncNetwork;

  /// Sync problem.
  ///
  /// In en, this message translates to:
  /// **'Your Wavelog asked Tideline to slow down; it will continue automatically.'**
  String get problemSyncRateLimited;

  /// Sync problem.
  ///
  /// In en, this message translates to:
  /// **'Your Wavelog reported an internal error.'**
  String get problemSyncServerError;

  /// Sync problem.
  ///
  /// In en, this message translates to:
  /// **'Wavelog found a problem with the QSO\'s data.'**
  String get problemSyncInvalidData;

  /// Sync problem.
  ///
  /// In en, this message translates to:
  /// **'The station location doesn\'t exist in Wavelog anymore, or the token can\'t use it. Choose another one.'**
  String get problemSyncStationNotAllowed;

  /// Sync problem.
  ///
  /// In en, this message translates to:
  /// **'The token lacks a permission for this. Create a token with the permissions listed in the manual.'**
  String get problemSyncMissingPermission;

  /// Sync problem.
  ///
  /// In en, this message translates to:
  /// **'Wavelog no longer accepts the token. Enter a new one in Settings.'**
  String get problemSyncTokenInvalid;

  /// Sync problem.
  ///
  /// In en, this message translates to:
  /// **'The token has expired. Enter a new one in Settings.'**
  String get problemSyncTokenExpired;

  /// Sync problem.
  ///
  /// In en, this message translates to:
  /// **'You changed the time, mode, frequency or station. Wavelog can\'t change these on an uploaded QSO.'**
  String get problemSyncReadOnlyFields;

  /// Sync problem.
  ///
  /// In en, this message translates to:
  /// **'Another QSO with the same callsign, band and mode in the same minute is already in Wavelog, which can store only one of them. Correct the time if this is a separate contact, or delete one.'**
  String get problemSyncSameMinuteTwin;

  /// Detail view placeholder.
  ///
  /// In en, this message translates to:
  /// **'This QSO no longer exists.'**
  String get qsoNotFound;

  /// Screen title.
  ///
  /// In en, this message translates to:
  /// **'QSO details'**
  String get qsoDetails;

  /// Prefix for the server's original message.
  ///
  /// In en, this message translates to:
  /// **'Wavelog said: {message}'**
  String serverSaid(String message);

  /// Conflict action: delete and re-create on the server.
  ///
  /// In en, this message translates to:
  /// **'Replace in Wavelog'**
  String get conflictReplace;

  /// Conflict action: keep the server version.
  ///
  /// In en, this message translates to:
  /// **'I\'ll fix it in Wavelog'**
  String get conflictKeepServer;

  /// Hint.
  ///
  /// In en, this message translates to:
  /// **'Replacing needs a token with the qso:delete permission.'**
  String get conflictReplaceNeedsDelete;

  /// Button.
  ///
  /// In en, this message translates to:
  /// **'Delete QSO'**
  String get actionDeleteQso;

  /// Dialog title.
  ///
  /// In en, this message translates to:
  /// **'Delete this QSO?'**
  String get deleteQsoTitle;

  /// Dialog body.
  ///
  /// In en, this message translates to:
  /// **'It will be removed from this device and, if it was uploaded, from your Wavelog.'**
  String get deleteQsoBody;

  /// Dialog body.
  ///
  /// In en, this message translates to:
  /// **'It will be removed from this device. The copy in Wavelog stays, because the token has no delete permission.'**
  String get deleteQsoLocalOnly;

  /// Heading of the journal.
  ///
  /// In en, this message translates to:
  /// **'Sync history'**
  String get syncHistory;

  /// Journal entry.
  ///
  /// In en, this message translates to:
  /// **'Logged on this device'**
  String get journalLogged;

  /// Journal entry.
  ///
  /// In en, this message translates to:
  /// **'Imported from a file'**
  String get journalImported;

  /// Journal entry.
  ///
  /// In en, this message translates to:
  /// **'Change waiting for upload'**
  String get journalEditQueued;

  /// Journal entry.
  ///
  /// In en, this message translates to:
  /// **'Sending to Wavelog'**
  String get journalRequestStarted;

  /// Journal entry.
  ///
  /// In en, this message translates to:
  /// **'Stored in Wavelog'**
  String get journalUploaded;

  /// Journal entry.
  ///
  /// In en, this message translates to:
  /// **'Change applied in Wavelog'**
  String get journalPatched;

  /// Journal entry.
  ///
  /// In en, this message translates to:
  /// **'Deleted in Wavelog'**
  String get journalDeletedOnServer;

  /// Journal entry.
  ///
  /// In en, this message translates to:
  /// **'Deleted here; the Wavelog copy stays (no delete permission)'**
  String get journalDeletedLocallyOnly;

  /// Journal entry.
  ///
  /// In en, this message translates to:
  /// **'Found in Wavelog, no duplicate created'**
  String get journalVerified;

  /// Journal entry.
  ///
  /// In en, this message translates to:
  /// **'Not in Wavelog yet, will be sent'**
  String get journalNotOnServer;

  /// Journal entry.
  ///
  /// In en, this message translates to:
  /// **'Will try again later'**
  String get journalRetry;

  /// Journal entry.
  ///
  /// In en, this message translates to:
  /// **'Rejected by Wavelog'**
  String get journalRejected;

  /// Journal entry.
  ///
  /// In en, this message translates to:
  /// **'Needs your decision'**
  String get journalConflict;

  /// Journal entry.
  ///
  /// In en, this message translates to:
  /// **'Decision made'**
  String get journalConflictResolved;

  /// Journal entry.
  ///
  /// In en, this message translates to:
  /// **'Token stopped working'**
  String get journalAccountBlocked;

  /// Journal entry.
  ///
  /// In en, this message translates to:
  /// **'Sync started'**
  String get journalRunStarted;

  /// Journal entry.
  ///
  /// In en, this message translates to:
  /// **'Sync finished'**
  String get journalRunFinished;

  /// Empty log hint.
  ///
  /// In en, this message translates to:
  /// **'Log your first QSO above. It is saved on this device right away, with or without a connection.'**
  String get logEmptyBodyReady;

  /// Heading.
  ///
  /// In en, this message translates to:
  /// **'Recent QSOs'**
  String get recentQsos;

  /// Context panel hint.
  ///
  /// In en, this message translates to:
  /// **'Type a callsign to see its DXCC entity, zones and whether you worked it before. This works offline.'**
  String get contextHint;

  /// WAE-only entity line.
  ///
  /// In en, this message translates to:
  /// **'WAE: {name}'**
  String contextWae(String name);

  /// ADIF DXCC code.
  ///
  /// In en, this message translates to:
  /// **'DXCC entity {number}'**
  String contextDxccNumber(int number);

  /// Heading.
  ///
  /// In en, this message translates to:
  /// **'Worked before'**
  String get contextWorkedBefore;

  /// No previous QSOs with this station.
  ///
  /// In en, this message translates to:
  /// **'Not in your log yet – a new one!'**
  String get contextNewOne;

  /// Certificate subject line.
  ///
  /// In en, this message translates to:
  /// **'Issued to: {value}'**
  String certSubjectLine(String value);

  /// Certificate issuer line.
  ///
  /// In en, this message translates to:
  /// **'Issued by: {value}'**
  String certIssuerLine(String value);

  /// Sync status.
  ///
  /// In en, this message translates to:
  /// **'Syncing with your Wavelog…'**
  String get syncRunning;

  /// Sync result.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Everything is up to date.} =1{Synced 1 QSO.} other{Synced {count} QSOs.}}'**
  String syncCompleted(int count);

  /// Sync result.
  ///
  /// In en, this message translates to:
  /// **'Your Wavelog isn\'t reachable right now. Your QSOs are safe on this device and will sync later.'**
  String get syncOffline;

  /// Sync result.
  ///
  /// In en, this message translates to:
  /// **'The token no longer works. Enter a new one in Settings; nothing is lost.'**
  String get syncBlocked;

  /// Sync result.
  ///
  /// In en, this message translates to:
  /// **'Your Wavelog asked for a pause. Sync continues automatically.'**
  String get syncRateLimited;

  /// Sync waiting for the dry-run review.
  ///
  /// In en, this message translates to:
  /// **'{count} new QSOs are ready. Please review the upload first.'**
  String syncNeedsReview(int count);

  /// Button.
  ///
  /// In en, this message translates to:
  /// **'Preview upload'**
  String get actionPreviewUpload;

  /// Dialog title.
  ///
  /// In en, this message translates to:
  /// **'Before uploading'**
  String get previewTitle;

  /// Preview line.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 QSO will be uploaded.} other{{count} QSOs will be uploaded.}}'**
  String previewToUpload(int count);

  /// Preview line.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 looks like a duplicate of a QSO you already have; Wavelog will keep only one.} other{{count} look like duplicates of QSOs you already have; Wavelog will keep only one of each.}}'**
  String previewDuplicates(int count);

  /// Preview line.
  ///
  /// In en, this message translates to:
  /// **'Wavelog\'s test run accepted {parsed} of {total}.'**
  String previewServerParsed(int parsed, int total);

  /// Preview line.
  ///
  /// In en, this message translates to:
  /// **'Wavelog couldn\'t be asked right now; the upload will check each QSO anyway.'**
  String get previewServerUnreachable;

  /// Preview reassurance.
  ///
  /// In en, this message translates to:
  /// **'Each QSO is checked against your Wavelog before any retry, so nothing is sent twice.'**
  String get previewSafety;

  /// Button.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get previewUpload;

  /// Settings section.
  ///
  /// In en, this message translates to:
  /// **'Wavelog account'**
  String get settingsAccount;

  /// Settings section.
  ///
  /// In en, this message translates to:
  /// **'Import, export and backup'**
  String get settingsData;

  /// Settings section.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get settingsSecurity;

  /// Account detail.
  ///
  /// In en, this message translates to:
  /// **'Uses a certificate you trusted manually'**
  String get accountPinned;

  /// Account detail.
  ///
  /// In en, this message translates to:
  /// **'Token expires on {date}'**
  String accountTokenExpires(String date);

  /// Account detail.
  ///
  /// In en, this message translates to:
  /// **'Token without expiry date'**
  String get accountTokenNoExpiry;

  /// Button.
  ///
  /// In en, this message translates to:
  /// **'Enter a new token'**
  String get actionReplaceToken;

  /// Confirmation.
  ///
  /// In en, this message translates to:
  /// **'New token saved. Syncing…'**
  String get tokenReplaced;

  /// Button.
  ///
  /// In en, this message translates to:
  /// **'Remove account from this device'**
  String get actionRemoveAccount;

  /// Dialog title.
  ///
  /// In en, this message translates to:
  /// **'Remove this account?'**
  String get removeAccountTitle;

  /// Dialog body.
  ///
  /// In en, this message translates to:
  /// **'Its QSOs are removed from this device. Your Wavelog is not changed.'**
  String get removeAccountBody;

  /// Warning in the remove dialog.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 QSO has not reached Wavelog yet and would be lost. Export or back up first.} other{{count} QSOs have not reached Wavelog yet and would be lost. Export or back up first.}}'**
  String removeAccountUnsynced(int count);

  /// Button.
  ///
  /// In en, this message translates to:
  /// **'Import ADIF file'**
  String get actionImportAdif;

  /// Hint.
  ///
  /// In en, this message translates to:
  /// **'For example a paper log typed in elsewhere, or another logger\'s export.'**
  String get importAdifHint;

  /// Button.
  ///
  /// In en, this message translates to:
  /// **'Export log as ADIF'**
  String get actionExportAdif;

  /// Hint.
  ///
  /// In en, this message translates to:
  /// **'Readable by every logging program. Not encrypted.'**
  String get exportAdifHint;

  /// Confirmation.
  ///
  /// In en, this message translates to:
  /// **'Log exported.'**
  String get exportDone;

  /// Button.
  ///
  /// In en, this message translates to:
  /// **'Create encrypted backup'**
  String get actionCreateBackup;

  /// Hint.
  ///
  /// In en, this message translates to:
  /// **'Everything except your token, protected by a passphrase.'**
  String get backupHint;

  /// Confirmation.
  ///
  /// In en, this message translates to:
  /// **'Backup saved.'**
  String get backupDone;

  /// Button.
  ///
  /// In en, this message translates to:
  /// **'Restore a backup'**
  String get actionRestoreBackup;

  /// Confirmation.
  ///
  /// In en, this message translates to:
  /// **'Restored {added} QSOs ({skipped} were already here).'**
  String restoreDone(int added, int skipped);

  /// Error.
  ///
  /// In en, this message translates to:
  /// **'That passphrase doesn\'t open this backup.'**
  String get restoreWrongPassphrase;

  /// Error.
  ///
  /// In en, this message translates to:
  /// **'This file isn\'t a Tideline backup or is damaged.'**
  String get restoreInvalidFile;

  /// Dialog title.
  ///
  /// In en, this message translates to:
  /// **'Backup passphrase'**
  String get backupPassphraseTitle;

  /// Hint.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters. Without it the backup cannot be opened – keep it safe.'**
  String get backupPassphraseHint;

  /// Field label.
  ///
  /// In en, this message translates to:
  /// **'Passphrase'**
  String get fieldPassphrase;

  /// Field label.
  ///
  /// In en, this message translates to:
  /// **'Repeat passphrase'**
  String get fieldPassphraseRepeat;

  /// Validation.
  ///
  /// In en, this message translates to:
  /// **'The passphrases don\'t match.'**
  String get passphraseMismatch;

  /// Dialog title.
  ///
  /// In en, this message translates to:
  /// **'Import finished'**
  String get importDoneTitle;

  /// Import result.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 QSO added.} other{{count} QSOs added.}}'**
  String importImported(int count);

  /// Import result.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 was already in your log and skipped.} other{{count} were already in your log and skipped.}}'**
  String importDuplicates(int count);

  /// Import result.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 record had no valid callsign, time, band or mode.} other{{count} records had no valid callsign, time, band or mode.}}'**
  String importRejected(int count);

  /// Import result.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{The file had 1 formatting problem that was worked around.} other{The file had {count} formatting problems that were worked around.}}'**
  String importWarnings(int count);

  /// Import result.
  ///
  /// In en, this message translates to:
  /// **'Imported QSOs belong to station location {name}.'**
  String importStation(String name);

  /// Error.
  ///
  /// In en, this message translates to:
  /// **'This file is too large to import (maximum 64 MB).'**
  String get importTooLarge;

  /// Setting.
  ///
  /// In en, this message translates to:
  /// **'App lock'**
  String get settingsAppLock;

  /// Setting hint.
  ///
  /// In en, this message translates to:
  /// **'Ask for Face ID, fingerprint or the device PIN when opening Tideline.'**
  String get settingsAppLockHint;

  /// Lock screen title.
  ///
  /// In en, this message translates to:
  /// **'Tideline is locked'**
  String get appLockTitle;

  /// Button.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get appLockUnlock;

  /// Reason shown by the system authentication dialog.
  ///
  /// In en, this message translates to:
  /// **'Unlock your log'**
  String get appLockReason;

  /// Setting: use the Atkinson Hyperlegible font.
  ///
  /// In en, this message translates to:
  /// **'Easy-to-read font'**
  String get settingsReadingFont;

  /// Setting hint. Keep the font name.
  ///
  /// In en, this message translates to:
  /// **'Atkinson Hyperlegible: clearly distinct letters such as 0 and O, 1, l and I.'**
  String get settingsReadingFontHint;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'en':
      {
        switch (locale.countryCode) {
          case 'XA':
            return AppLocalizationsEnXa();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
