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

  /// Live interpretation under the frequency field for frequencies below 1 MHz. {khz} is the frequency in kHz, {band} the amateur band such as '630 m'. Keep the middle dot.
  ///
  /// In en, this message translates to:
  /// **'{khz} kHz · {band}'**
  String freqReadoutInBandKhz(String khz, String band);

  /// Live interpretation under the frequency field when a frequency below 1 MHz is in no amateur band. {khz} is the frequency in kHz.
  ///
  /// In en, this message translates to:
  /// **'{khz} kHz · outside amateur bands'**
  String freqReadoutOutsideBandsKhz(String khz);

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

  /// Screen reader text for the frequency interpretation below 1 MHz. {band} is spoken, e.g. '630 metres'.
  ///
  /// In en, this message translates to:
  /// **'{khz} kilohertz, {band}'**
  String freqReadoutSemanticsInBandKhz(String khz, String band);

  /// Screen reader text for the frequency interpretation below 1 MHz, outside amateur bands.
  ///
  /// In en, this message translates to:
  /// **'{khz} kilohertz, outside amateur bands'**
  String freqReadoutSemanticsOutsideBandsKhz(String khz);

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

  /// Journal entry.
  ///
  /// In en, this message translates to:
  /// **'Contest session created on Wavelog'**
  String get journalContestSessionCreated;

  /// Journal entry.
  ///
  /// In en, this message translates to:
  /// **'QSOs linked to the Wavelog contest session'**
  String get journalContestQsosLinked;

  /// Journal entry.
  ///
  /// In en, this message translates to:
  /// **'Contest session kept on this device only'**
  String get journalContestSessionLocalOnly;

  /// Journal entry.
  ///
  /// In en, this message translates to:
  /// **'Contest session not synced yet; will retry'**
  String get journalContestSessionRetry;

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

  /// Button: close a dialog or editor without saving.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// Button: close an information dialog.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// Button: save changes.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// Command: clear the callsign and exchange being entered in contest mode.
  ///
  /// In en, this message translates to:
  /// **'Wipe entry'**
  String get commandWipeEntry;

  /// Command: put the cursor in the callsign field.
  ///
  /// In en, this message translates to:
  /// **'Go to callsign'**
  String get commandFocusCall;

  /// Command: toggle the score and rates panel.
  ///
  /// In en, this message translates to:
  /// **'Show or hide score and rates'**
  String get commandToggleRates;

  /// Command and button: end the running contest session.
  ///
  /// In en, this message translates to:
  /// **'End contest session'**
  String get commandEndContest;

  /// Command: open contest mode (the entry screen or the session setup).
  ///
  /// In en, this message translates to:
  /// **'Open contest mode'**
  String get commandOpenContest;

  /// Title of the contest screens.
  ///
  /// In en, this message translates to:
  /// **'Contest mode'**
  String get contestTitle;

  /// Tooltip of the log screen button that opens contest mode.
  ///
  /// In en, this message translates to:
  /// **'Contest mode'**
  String get contestOpenAction;

  /// Banner on the log screen. The name is a proper contest name.
  ///
  /// In en, this message translates to:
  /// **'Contest session active: {name}'**
  String contestBannerActive(String name);

  /// Banner button: go back to the running contest.
  ///
  /// In en, this message translates to:
  /// **'Return to contest'**
  String get contestBannerReturn;

  /// Title of the session setup screen.
  ///
  /// In en, this message translates to:
  /// **'Contest session'**
  String get contestSetupTitle;

  /// Error title on the setup screen.
  ///
  /// In en, this message translates to:
  /// **'Contests could not be loaded'**
  String get contestSetupLoadFailed;

  /// Error explanation on the setup screen.
  ///
  /// In en, this message translates to:
  /// **'Your normal log still works. Restart Tideline and try again.'**
  String get contestSetupLoadFailedBody;

  /// Notice on the setup screen.
  ///
  /// In en, this message translates to:
  /// **'A contest session is already running. End it before you start another one.'**
  String get contestSetupSessionRunning;

  /// Heading of the contest list on the setup screen.
  ///
  /// In en, this message translates to:
  /// **'Contest'**
  String get contestSetupChooseContest;

  /// Label of the contest search field.
  ///
  /// In en, this message translates to:
  /// **'Search contests'**
  String get contestSearchLabel;

  /// Shown when the contest search has no result.
  ///
  /// In en, this message translates to:
  /// **'No contest matches your search.'**
  String get contestSearchEmpty;

  /// Label: contest definition shipped with the app.
  ///
  /// In en, this message translates to:
  /// **'Built in'**
  String get contestBuiltin;

  /// Label: contest definition the user imported.
  ///
  /// In en, this message translates to:
  /// **'Imported by you'**
  String get contestImported;

  /// Shown when no station profile is available.
  ///
  /// In en, this message translates to:
  /// **'This account has no station location yet. Sync once to load your Wavelog station locations, then try again.'**
  String get contestSetupNeedStation;

  /// Heading above the station location choice.
  ///
  /// In en, this message translates to:
  /// **'Station'**
  String get contestSetupStation;

  /// Heading of the section where the operator enters what they send.
  ///
  /// In en, this message translates to:
  /// **'My exchange'**
  String get contestSetupExchange;

  /// Help text for my exchange.
  ///
  /// In en, this message translates to:
  /// **'This is what you send to every station. The suggestions come from your station location; please check them.'**
  String get contestSetupExchangeHelp;

  /// Notice: signal report.
  ///
  /// In en, this message translates to:
  /// **'The report is sent automatically: 59 for voice, 599 for CW and digital modes.'**
  String get contestSetupRstAuto;

  /// Notice: serial numbers.
  ///
  /// In en, this message translates to:
  /// **'The serial number starts at 1 and counts up with every QSO. A number is never used twice, even if you delete a QSO.'**
  String get contestSetupSerialAuto;

  /// Heading of the Cabrillo category choices.
  ///
  /// In en, this message translates to:
  /// **'Cabrillo categories'**
  String get contestSetupCabrillo;

  /// Help text for the Cabrillo categories. The values themselves are protocol tokens and are not translated.
  ///
  /// In en, this message translates to:
  /// **'These go into the header of the Cabrillo log you send to the sponsor. The values are fixed terms of the Cabrillo format.'**
  String get contestSetupCabrilloHelp;

  /// Cabrillo CATEGORY-OPERATOR field name.
  ///
  /// In en, this message translates to:
  /// **'Operator category'**
  String get contestCatOperator;

  /// Cabrillo CATEGORY-ASSISTED field name.
  ///
  /// In en, this message translates to:
  /// **'Assistance'**
  String get contestCatAssisted;

  /// Cabrillo CATEGORY-BAND field name.
  ///
  /// In en, this message translates to:
  /// **'Band category'**
  String get contestCatBand;

  /// Cabrillo CATEGORY-MODE field name.
  ///
  /// In en, this message translates to:
  /// **'Mode category'**
  String get contestCatMode;

  /// Cabrillo CATEGORY-POWER field name.
  ///
  /// In en, this message translates to:
  /// **'Power'**
  String get contestCatPower;

  /// Cabrillo CATEGORY-STATION field name.
  ///
  /// In en, this message translates to:
  /// **'Station type'**
  String get contestCatStation;

  /// Cabrillo CATEGORY-TRANSMITTER field name.
  ///
  /// In en, this message translates to:
  /// **'Transmitters'**
  String get contestCatTransmitter;

  /// Cabrillo CATEGORY-OVERLAY field name.
  ///
  /// In en, this message translates to:
  /// **'Overlay'**
  String get contestCatOverlay;

  /// Dropdown choice: no Cabrillo category value.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get contestCatNotSet;

  /// Button: start the contest session.
  ///
  /// In en, this message translates to:
  /// **'Start session'**
  String get contestStart;

  /// Error after a failed start.
  ///
  /// In en, this message translates to:
  /// **'The session could not be started. Nothing was changed. Try again.'**
  String get contestStartFailed;

  /// Heading of the session list.
  ///
  /// In en, this message translates to:
  /// **'Past sessions'**
  String get contestPastTitle;

  /// Shown when there are no sessions.
  ///
  /// In en, this message translates to:
  /// **'No contest sessions yet.'**
  String get contestPastEmpty;

  /// Session state.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get contestStateActive;

  /// Session state.
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get contestStateEnded;

  /// Button: reopen an ended session.
  ///
  /// In en, this message translates to:
  /// **'Reopen'**
  String get contestReopen;

  /// Tooltip: open the list of contest sessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get contestSessionsAction;

  /// Error title when the definition of the running session is gone.
  ///
  /// In en, this message translates to:
  /// **'Contest rules not found'**
  String get contestMissingTitle;

  /// Error explanation.
  ///
  /// In en, this message translates to:
  /// **'The rules for this session are no longer on this device. Your QSOs are safe. End the session to carry on.'**
  String get contestMissingBody;

  /// Dialog title.
  ///
  /// In en, this message translates to:
  /// **'End the contest session?'**
  String get contestEndTitle;

  /// Dialog body.
  ///
  /// In en, this message translates to:
  /// **'Your QSOs stay in the log. You can reopen the session later from the session list.'**
  String get contestEndBody;

  /// Label of the exchange element: RST.
  ///
  /// In en, this message translates to:
  /// **'RST'**
  String get contestKindRst;

  /// Label of the exchange element: serial number.
  ///
  /// In en, this message translates to:
  /// **'Serial no.'**
  String get contestKindSerial;

  /// Label of the exchange element: CQ zone.
  ///
  /// In en, this message translates to:
  /// **'CQ zone'**
  String get contestKindCqZone;

  /// Label of the exchange element: ITU zone.
  ///
  /// In en, this message translates to:
  /// **'ITU zone'**
  String get contestKindItuZone;

  /// Label of the exchange element: Maidenhead locator.
  ///
  /// In en, this message translates to:
  /// **'Grid'**
  String get contestKindGrid;

  /// Label of the exchange element: state or province.
  ///
  /// In en, this message translates to:
  /// **'State or province'**
  String get contestKindState;

  /// Label of the exchange element: ARRL section.
  ///
  /// In en, this message translates to:
  /// **'Section'**
  String get contestKindSection;

  /// Label of the exchange element: DARC local chapter code.
  ///
  /// In en, this message translates to:
  /// **'DOK'**
  String get contestKindDok;

  /// Label of the exchange element: power.
  ///
  /// In en, this message translates to:
  /// **'Power'**
  String get contestKindPower;

  /// Label of the exchange element: operator name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get contestKindName;

  /// Label of the exchange element: free text exchange.
  ///
  /// In en, this message translates to:
  /// **'Exchange'**
  String get contestKindText;

  /// Field label for an optional exchange element.
  ///
  /// In en, this message translates to:
  /// **'{label} (optional)'**
  String contestOptionalLabel(String label);

  /// Error: exchange value missing.
  ///
  /// In en, this message translates to:
  /// **'{label} is required.'**
  String contestErrorMissing(String label);

  /// Error: exchange value malformed.
  ///
  /// In en, this message translates to:
  /// **'{label} is not valid.'**
  String contestErrorInvalid(String label);

  /// Error: exchange value out of range.
  ///
  /// In en, this message translates to:
  /// **'{label} is out of range.'**
  String contestErrorOutOfRange(String label);

  /// Name of a multiplier type in the contest score.
  ///
  /// In en, this message translates to:
  /// **'Zone'**
  String get contestMultZone;

  /// Name of a multiplier type in the contest score.
  ///
  /// In en, this message translates to:
  /// **'ITU zone'**
  String get contestMultItuZone;

  /// Name of a multiplier type in the contest score.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get contestMultDxcc;

  /// Name of a multiplier type in the contest score.
  ///
  /// In en, this message translates to:
  /// **'Prefix'**
  String get contestMultPrefix;

  /// Name of a multiplier type in the contest score.
  ///
  /// In en, this message translates to:
  /// **'State or province'**
  String get contestMultState;

  /// Name of a multiplier type in the contest score.
  ///
  /// In en, this message translates to:
  /// **'DOK'**
  String get contestMultDok;

  /// Hint under the callsign: the station is a dupe.
  ///
  /// In en, this message translates to:
  /// **'Dupe: already worked on {bands} ({modes})'**
  String contestHintDupe(String bands, String modes);

  /// Hint: worked in this contest on another band or mode.
  ///
  /// In en, this message translates to:
  /// **'Already worked on {bands} ({modes}); not a dupe here'**
  String contestHintWorkedElsewhere(String bands, String modes);

  /// Hint: logging this QSO adds multipliers.
  ///
  /// In en, this message translates to:
  /// **'New multiplier: {items}'**
  String contestHintNewMultiplier(String items);

  /// Hint.
  ///
  /// In en, this message translates to:
  /// **'Outside this contest\'s bands or modes: scores 0 points.'**
  String get contestHintOutOfContest;

  /// Hint from the main log.
  ///
  /// In en, this message translates to:
  /// **'In your log: worked before on this band and mode'**
  String get contestHintLogWorked;

  /// Hint from the main log.
  ///
  /// In en, this message translates to:
  /// **'In your log: worked before, new band'**
  String get contestHintLogNewBand;

  /// Hint from the main log.
  ///
  /// In en, this message translates to:
  /// **'In your log: worked before, new mode'**
  String get contestHintLogNewMode;

  /// Hint from the main log.
  ///
  /// In en, this message translates to:
  /// **'In your log: worked before, new combination of band and mode'**
  String get contestHintLogNewSlot;

  /// Hint: the call is known.
  ///
  /// In en, this message translates to:
  /// **'Callsign is in the super check partial list'**
  String get contestHintInScp;

  /// Label before suggested callsigns that contain what was typed.
  ///
  /// In en, this message translates to:
  /// **'Super check:'**
  String get contestHintScpMatches;

  /// Label before callsigns one character away from what was typed.
  ///
  /// In en, this message translates to:
  /// **'Did you mean:'**
  String get contestHintNPlusOne;

  /// Accessibility label of a callsign suggestion. The call is spelled letter by letter.
  ///
  /// In en, this message translates to:
  /// **'Use {call}'**
  String contestUseCall(String call);

  /// Read-only summary of the exchange I send.
  ///
  /// In en, this message translates to:
  /// **'Sent: {items}'**
  String contestSentSummary(String items);

  /// Shown when the exchange to send is empty.
  ///
  /// In en, this message translates to:
  /// **'Nothing to send'**
  String get contestSentNothing;

  /// Screen-reader announcement after logging. The call is spelled letter by letter. dupe is yes or no.
  ///
  /// In en, this message translates to:
  /// **'Logged {call}, serial {serial}{dupe, select, yes{, dupe} other{}}'**
  String contestLoggedAnnouncement(String call, int serial, String dupe);

  /// Screen-reader announcement after logging in a contest without serial numbers. dupe is yes or no.
  ///
  /// In en, this message translates to:
  /// **'Logged {call}{dupe, select, yes{, dupe} other{}}'**
  String contestLoggedAnnouncementNoSerial(String call, String dupe);

  /// Error after a failed save.
  ///
  /// In en, this message translates to:
  /// **'The QSO could not be saved. What you typed is still here. Try again.'**
  String get contestSaveFailed;

  /// Heading of the recent QSO list in contest mode.
  ///
  /// In en, this message translates to:
  /// **'Recent QSOs'**
  String get contestRecentTitle;

  /// Shown when the session has no QSOs.
  ///
  /// In en, this message translates to:
  /// **'No QSOs in this session yet. Type a callsign and the exchange, then press Enter.'**
  String get contestRecentEmpty;

  /// Sent and received exchange of a QSO row.
  ///
  /// In en, this message translates to:
  /// **'{sent} → {rcvd}'**
  String contestRowExchange(String sent, String rcvd);

  /// Accessibility hint of a QSO row.
  ///
  /// In en, this message translates to:
  /// **'Edit this QSO'**
  String get contestRowEditHint;

  /// Short flag on a QSO row.
  ///
  /// In en, this message translates to:
  /// **'Dupe'**
  String get contestFlagDupe;

  /// Short flag on a QSO row: it added a multiplier.
  ///
  /// In en, this message translates to:
  /// **'Mult'**
  String get contestFlagMult;

  /// Short flag on a QSO row: outside the contest bands or modes.
  ///
  /// In en, this message translates to:
  /// **'Out'**
  String get contestFlagOut;

  /// Points of a QSO.
  ///
  /// In en, this message translates to:
  /// **'{points, plural, =1{1 pt} other{{points} pts}}'**
  String contestPoints(int points);

  /// Heading of the inline editor.
  ///
  /// In en, this message translates to:
  /// **'Edit QSO'**
  String get contestEditTitle;

  /// Shows the sent exchange in the editor.
  ///
  /// In en, this message translates to:
  /// **'Sent (cannot be changed): {items}'**
  String contestEditSent(String items);

  /// Dialog title.
  ///
  /// In en, this message translates to:
  /// **'Delete this QSO?'**
  String get contestDeleteTitle;

  /// Dialog body.
  ///
  /// In en, this message translates to:
  /// **'{call} will be removed from this device and from the contest score.'**
  String contestDeleteBody(String call);

  /// Dialog body for contests with serial numbers.
  ///
  /// In en, this message translates to:
  /// **'{call} will be removed from this device and from the contest score. Serial {serial} stays used and is never given out again.'**
  String contestDeleteBodySerial(String call, String serial);

  /// Heading of the score panel.
  ///
  /// In en, this message translates to:
  /// **'Score and rates'**
  String get contestPanelTitle;

  /// One-line summary of the collapsed score panel.
  ///
  /// In en, this message translates to:
  /// **'{qsos} QSOs · {points} points · estimate {score}'**
  String contestPanelSummary(int qsos, int points, int score);

  /// Column and metric: number of QSOs.
  ///
  /// In en, this message translates to:
  /// **'QSOs'**
  String get contestQsos;

  /// Column and metric: QSO points.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get contestPointsLabel;

  /// Column and metric: multipliers.
  ///
  /// In en, this message translates to:
  /// **'Multipliers'**
  String get contestMultipliers;

  /// Metric: number of duplicate contacts.
  ///
  /// In en, this message translates to:
  /// **'Dupes'**
  String get contestDupes;

  /// Label of the total score.
  ///
  /// In en, this message translates to:
  /// **'Claimed score (estimate)'**
  String get contestScoreEstimate;

  /// Note under the score.
  ///
  /// In en, this message translates to:
  /// **'An estimate for your own use. The contest sponsor\'s log check decides the real result.'**
  String get contestScoreEstimateNote;

  /// Heading of the rates block.
  ///
  /// In en, this message translates to:
  /// **'Rates'**
  String get contestRatesTitle;

  /// Rate label.
  ///
  /// In en, this message translates to:
  /// **'Last 10 minutes'**
  String get contestRate10Min;

  /// Rate label.
  ///
  /// In en, this message translates to:
  /// **'Last 60 minutes'**
  String get contestRate60Min;

  /// Rate label.
  ///
  /// In en, this message translates to:
  /// **'Last 10 QSOs'**
  String get contestRateLast10;

  /// Rate label.
  ///
  /// In en, this message translates to:
  /// **'Last 100 QSOs'**
  String get contestRateLast100;

  /// Rate label.
  ///
  /// In en, this message translates to:
  /// **'Best 60 minutes'**
  String get contestRateBest;

  /// A rate in QSOs per hour.
  ///
  /// In en, this message translates to:
  /// **'{rate}/h'**
  String contestRatePerHour(int rate);

  /// The best 60-minute window: count and start time (UTC).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 QSO} other{{count} QSOs}} from {time} {utc}'**
  String contestRateBestValue(int count, String time, String utc);

  /// Heading of the per-band table.
  ///
  /// In en, this message translates to:
  /// **'By band'**
  String get contestBandsTitle;

  /// Shown when the per-band table is empty.
  ///
  /// In en, this message translates to:
  /// **'No scoring QSOs yet.'**
  String get contestBandsEmpty;

  /// Screen-reader text of a label and its value.
  ///
  /// In en, this message translates to:
  /// **'{label}: {value}'**
  String contestLabelValue(String label, String value);

  /// Command and menu entry: save the contest session as a Cabrillo log file.
  ///
  /// In en, this message translates to:
  /// **'Export Cabrillo log'**
  String get commandExportCabrillo;

  /// Tooltip of the overflow menu button in the contest screen.
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get contestMoreActions;

  /// Field label for the Cabrillo CATEGORY-TIME header (6, 8, 12 or 24 hours).
  ///
  /// In en, this message translates to:
  /// **'Time category'**
  String get contestCatTime;

  /// Title of the Cabrillo export dialogs.
  ///
  /// In en, this message translates to:
  /// **'Export Cabrillo log'**
  String get cabrilloExportTitle;

  /// Intro above the list of problems found before a Cabrillo export.
  ///
  /// In en, this message translates to:
  /// **'The log has problems that contest checkers may reject:'**
  String get cabrilloIssuesIntro;

  /// Button: save the Cabrillo log although problems were found.
  ///
  /// In en, this message translates to:
  /// **'Export anyway'**
  String get cabrilloExportAnyway;

  /// Snackbar after the Cabrillo file was saved.
  ///
  /// In en, this message translates to:
  /// **'Cabrillo log saved.'**
  String get cabrilloExportDone;

  /// Snackbar when the Cabrillo export failed.
  ///
  /// In en, this message translates to:
  /// **'The Cabrillo log could not be created or saved.'**
  String get cabrilloExportFailed;

  /// Warning shown in the contest screen and the session list when the definition has no Cabrillo contest name.
  ///
  /// In en, this message translates to:
  /// **'Cabrillo export is not available: this contest has no Cabrillo name.'**
  String get cabrilloUnavailableBanner;

  /// Body of the dialog explaining that Cabrillo export is not offered. {contest} is the contest name.
  ///
  /// In en, this message translates to:
  /// **'{contest} has no Cabrillo contest name in its definition, so no log that a contest robot would accept can be written. Add a cabrillo name to the definition, or use the ADIF export in Settings.'**
  String cabrilloUnavailableBody(String contest);

  /// Cabrillo problem.
  ///
  /// In en, this message translates to:
  /// **'The contest has no Cabrillo name.'**
  String get cabrilloIssueMissingContest;

  /// Cabrillo problem.
  ///
  /// In en, this message translates to:
  /// **'The station has no callsign.'**
  String get cabrilloIssueMissingCallsign;

  /// Cabrillo problem.
  ///
  /// In en, this message translates to:
  /// **'The session has no QSOs.'**
  String get cabrilloIssueEmptyLog;

  /// Cabrillo problem.
  ///
  /// In en, this message translates to:
  /// **'The exchange has a different number of items than the first QSO.'**
  String get cabrilloIssueExchangeCountMismatch;

  /// Cabrillo problem.
  ///
  /// In en, this message translates to:
  /// **'The frequency or band cannot be determined.'**
  String get cabrilloIssueMissingFrequency;

  /// Cabrillo problem.
  ///
  /// In en, this message translates to:
  /// **'A callsign is empty.'**
  String get cabrilloIssueMissingQsoCall;

  /// Cabrillo problem.
  ///
  /// In en, this message translates to:
  /// **'An exchange value contains a space; it is written with a hyphen.'**
  String get cabrilloIssueTokenContainsWhitespace;

  /// Cabrillo export problem.
  ///
  /// In en, this message translates to:
  /// **'An exchange value is empty; a hyphen is written in its place.'**
  String get cabrilloIssueEmptyExchangeToken;

  /// Cabrillo problem.
  ///
  /// In en, this message translates to:
  /// **'There are more than 6 address lines; the extra lines are dropped.'**
  String get cabrilloIssueTooManyAddressLines;

  /// Cabrillo problem.
  ///
  /// In en, this message translates to:
  /// **'An address line is longer than 45 characters; it is cut off.'**
  String get cabrilloIssueAddressLineTooLong;

  /// Cabrillo problem.
  ///
  /// In en, this message translates to:
  /// **'The transmitter number must be 0 or 1.'**
  String get cabrilloIssueInvalidTransmitterId;

  /// Which QSOs a Cabrillo problem concerns. {first} is the 1-based position of the first affected QSO.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{QSO no. {first}} other{{count} QSOs, the first is no. {first}}}'**
  String cabrilloIssueQsos(int count, int first);

  /// Wavelog state of a contest session: it is not mirrored on Wavelog.
  ///
  /// In en, this message translates to:
  /// **'Only on this device'**
  String get contestSyncLocal;

  /// Wavelog state of a contest session: it will be created on Wavelog at the next sync.
  ///
  /// In en, this message translates to:
  /// **'Waiting for upload to Wavelog'**
  String get contestSyncPending;

  /// Wavelog state of a contest session: Tideline is checking whether a lost create request went through.
  ///
  /// In en, this message translates to:
  /// **'Being checked on Wavelog'**
  String get contestSyncVerifying;

  /// Wavelog state of a contest session: it exists on Wavelog.
  ///
  /// In en, this message translates to:
  /// **'On Wavelog'**
  String get contestSyncCreated;

  /// Wavelog state of a contest session followed by the reason it is not synced. Keep the colon.
  ///
  /// In en, this message translates to:
  /// **'{state}: {reason}'**
  String contestSyncWithReason(String state, String reason);

  /// Screen reader label of the session sync status. {status} is the state text.
  ///
  /// In en, this message translates to:
  /// **'Wavelog: {status}'**
  String contestSyncStatusLabel(String status);

  /// Reason a contest session stays local.
  ///
  /// In en, this message translates to:
  /// **'The contest is not activated on your Wavelog server.'**
  String get contestSyncProblemNotActive;

  /// Reason a contest session is not synced. Keep contest:write as is.
  ///
  /// In en, this message translates to:
  /// **'The API token lacks the contest:write permission.'**
  String get contestSyncProblemMissingPermission;

  /// Reason a contest session stays local.
  ///
  /// In en, this message translates to:
  /// **'Your Wavelog server is older than version 3.2 and has no contest sessions.'**
  String get contestSyncProblemServerTooOld;

  /// Reason a contest session is not synced.
  ///
  /// In en, this message translates to:
  /// **'The session was deleted in Wavelog.'**
  String get contestSyncProblemDeletedOnServer;

  /// Reason a contest session stays local.
  ///
  /// In en, this message translates to:
  /// **'This contest has no ADIF contest name.'**
  String get contestSyncProblemNoAdifName;

  /// Reason a contest session is not synced.
  ///
  /// In en, this message translates to:
  /// **'The station location is not on the Wavelog server.'**
  String get contestSyncProblemStationUnknown;

  /// Reason a contest session is not synced.
  ///
  /// In en, this message translates to:
  /// **'Wavelog rejected the session.'**
  String get contestSyncProblemRejected;

  /// Fallback reason for an unknown contest sync problem.
  ///
  /// In en, this message translates to:
  /// **'Wavelog reported a problem.'**
  String get contestSyncProblemUnknown;

  /// Hint under the callsign field: the call was never worked.
  ///
  /// In en, this message translates to:
  /// **'New call: not in your log yet'**
  String get workedHintNewCall;

  /// Hint under the callsign field.
  ///
  /// In en, this message translates to:
  /// **'Worked before, but not on this band'**
  String get workedHintNewBand;

  /// Hint under the callsign field.
  ///
  /// In en, this message translates to:
  /// **'Worked before, but not in this mode'**
  String get workedHintNewMode;

  /// Hint under the callsign field.
  ///
  /// In en, this message translates to:
  /// **'Worked before, but not on this band and mode together'**
  String get workedHintNewSlot;

  /// Hint under the callsign field.
  ///
  /// In en, this message translates to:
  /// **'Worked before on this band and mode'**
  String get workedHintWorked;

  /// Details after a worked-before hint: date of the first contact and the bands worked.
  ///
  /// In en, this message translates to:
  /// **'first contact {date}, bands {bands}'**
  String workedHintDetails(String date, String bands);

  /// Settings section header.
  ///
  /// In en, this message translates to:
  /// **'Worked-before index'**
  String get settingsWorkedBefore;

  /// Settings action.
  ///
  /// In en, this message translates to:
  /// **'Rebuild worked-before index'**
  String get actionRebuildWorkedBefore;

  /// Explains the rebuild action.
  ///
  /// In en, this message translates to:
  /// **'Builds the index from your log again. Contacts from your Wavelog server come back with the next sync.'**
  String get rebuildWorkedBeforeHint;

  /// Confirmation dialog title.
  ///
  /// In en, this message translates to:
  /// **'Rebuild the index?'**
  String get rebuildWorkedBeforeConfirmTitle;

  /// Confirmation dialog text.
  ///
  /// In en, this message translates to:
  /// **'Your log is not changed. Hints for stations you only worked on other devices or in Wavelog are missing until the next sync has loaded them again.'**
  String get rebuildWorkedBeforeConfirmBody;

  /// Confirm button of the rebuild dialog.
  ///
  /// In en, this message translates to:
  /// **'Rebuild'**
  String get actionRebuild;

  /// Progress text while the index is rebuilt.
  ///
  /// In en, this message translates to:
  /// **'Rebuilding the index…'**
  String get rebuildWorkedBeforeProgress;

  /// Shown after a rebuild.
  ///
  /// In en, this message translates to:
  /// **'Index rebuilt. The next sync adds the contacts from your Wavelog server.'**
  String get rebuildWorkedBeforeDone;

  /// Shown when the rebuild failed.
  ///
  /// In en, this message translates to:
  /// **'The index could not be rebuilt.'**
  String get rebuildWorkedBeforeFailed;

  /// Settings section header (MASTER.SCP callsign list).
  ///
  /// In en, this message translates to:
  /// **'Super check partial'**
  String get settingsScp;

  /// Explains the super check partial list.
  ///
  /// In en, this message translates to:
  /// **'Callsign suggestions while you log a contest. The list is not part of Tideline: you download it yourself.'**
  String get scpHint;

  /// Shown when no MASTER.SCP is installed.
  ///
  /// In en, this message translates to:
  /// **'No list installed'**
  String get scpNone;

  /// Summary of the installed list.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 callsign} other{{count} callsigns}} · installed {date}'**
  String scpPackSummary(int count, String date);

  /// Where the installed list came from.
  ///
  /// In en, this message translates to:
  /// **'Source: {source}'**
  String scpSource(String source);

  /// Source of a list that was imported from a file.
  ///
  /// In en, this message translates to:
  /// **'a file you imported'**
  String get scpSourceFile;

  /// Label of the URL field.
  ///
  /// In en, this message translates to:
  /// **'Download address (https)'**
  String get scpUrlLabel;

  /// Helper text under the URL field.
  ///
  /// In en, this message translates to:
  /// **'Tideline contacts this address only when you press Download, and sends nothing about you.'**
  String get scpUrlHelper;

  /// Button.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get actionDownload;

  /// Button.
  ///
  /// In en, this message translates to:
  /// **'Import file'**
  String get actionImportFile;

  /// Button.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get actionRemove;

  /// Progress text while MASTER.SCP downloads.
  ///
  /// In en, this message translates to:
  /// **'Downloading the list…'**
  String get scpDownloading;

  /// Progress text with the size so far.
  ///
  /// In en, this message translates to:
  /// **'Downloading the list… {kib} KiB'**
  String scpDownloadingSize(int kib);

  /// Shown after a list was installed.
  ///
  /// In en, this message translates to:
  /// **'List installed: {count, plural, =1{1 callsign} other{{count} callsigns}}.'**
  String scpInstalled(int count);

  /// Dialog title.
  ///
  /// In en, this message translates to:
  /// **'Remove the list?'**
  String get scpRemoveTitle;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Callsign suggestions stop until you install a list again.'**
  String get scpRemoveBody;

  /// Shown after removal.
  ///
  /// In en, this message translates to:
  /// **'List removed.'**
  String get scpRemoved;

  /// Download error.
  ///
  /// In en, this message translates to:
  /// **'Only https addresses are allowed.'**
  String get scpErrorInsecureUrl;

  /// Download error.
  ///
  /// In en, this message translates to:
  /// **'This is not a usable address. It must not contain a user name, a password, a query (?…) or a fragment (#…).'**
  String get scpErrorInvalidUrl;

  /// Download error.
  ///
  /// In en, this message translates to:
  /// **'The server could not be reached. Check your connection and the address.'**
  String get scpErrorNetwork;

  /// Download error.
  ///
  /// In en, this message translates to:
  /// **'The server took too long to answer.'**
  String get scpErrorTimeout;

  /// Download error.
  ///
  /// In en, this message translates to:
  /// **'The certificate of the server is not trusted, so nothing was downloaded.'**
  String get scpErrorCertificate;

  /// Download error.
  ///
  /// In en, this message translates to:
  /// **'The file is larger than 8 MiB. It was not stored.'**
  String get scpErrorTooLarge;

  /// Download error.
  ///
  /// In en, this message translates to:
  /// **'The server answered with HTTP status {code}.'**
  String scpErrorStatus(int code);

  /// Download or import error.
  ///
  /// In en, this message translates to:
  /// **'This is not a MASTER.SCP file (one callsign per line).'**
  String get scpErrorInvalidFile;

  /// Import error.
  ///
  /// In en, this message translates to:
  /// **'The file could not be read.'**
  String get scpErrorUnreadable;

  /// Settings section header.
  ///
  /// In en, this message translates to:
  /// **'Contest definitions'**
  String get settingsContestDefinitions;

  /// Explains contest definitions.
  ///
  /// In en, this message translates to:
  /// **'The rules of each contest are data files. Bundled definitions are always available; you can add your own.'**
  String get contestDefsHint;

  /// Origin of a contest definition.
  ///
  /// In en, this message translates to:
  /// **'Bundled'**
  String get contestDefBuiltin;

  /// Origin of a contest definition.
  ///
  /// In en, this message translates to:
  /// **'Imported by you'**
  String get contestDefUser;

  /// Version of a definition.
  ///
  /// In en, this message translates to:
  /// **'version {version}'**
  String contestDefVersion(int version);

  /// Settings action.
  ///
  /// In en, this message translates to:
  /// **'Import definition'**
  String get actionImportDefinition;

  /// Explains the import action.
  ///
  /// In en, this message translates to:
  /// **'A JSON file of up to 256 KiB.'**
  String get importDefinitionHint;

  /// Shown after an import.
  ///
  /// In en, this message translates to:
  /// **'Imported “{name}”.'**
  String contestDefImported(String name);

  /// Shown when an earlier import with the same id was replaced.
  ///
  /// In en, this message translates to:
  /// **'Updated “{name}”.'**
  String contestDefReplaced(String name);

  /// Dialog title.
  ///
  /// In en, this message translates to:
  /// **'Definition not imported'**
  String get contestDefRejectedTitle;

  /// Location of the problem in the file (a JSON path).
  ///
  /// In en, this message translates to:
  /// **'Technical detail: {path}'**
  String contestDefTechnical(String path);

  /// Import error.
  ///
  /// In en, this message translates to:
  /// **'The file is larger than 256 KiB.'**
  String get contestDefFileTooLarge;

  /// Import error.
  ///
  /// In en, this message translates to:
  /// **'The file is not valid UTF-8 text.'**
  String get contestDefNotText;

  /// Import error.
  ///
  /// In en, this message translates to:
  /// **'The file could not be read.'**
  String get contestDefUnreadable;

  /// Import error.
  ///
  /// In en, this message translates to:
  /// **'This id belongs to a bundled contest. Choose a different id in the file.'**
  String get contestDefIdClash;

  /// Tooltip of the delete button.
  ///
  /// In en, this message translates to:
  /// **'Delete definition {name}'**
  String actionDeleteDefinition(String name);

  /// Dialog title.
  ///
  /// In en, this message translates to:
  /// **'Delete “{name}”?'**
  String contestDefDeleteTitle(String name);

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'Only the definition is removed. Your QSOs are not affected.'**
  String get contestDefDeleteBody;

  /// Shown after deletion.
  ///
  /// In en, this message translates to:
  /// **'Deleted “{name}”.'**
  String contestDefDeleted(String name);

  /// Delete result.
  ///
  /// In en, this message translates to:
  /// **'A contest session in your log uses this definition, so it cannot be deleted.'**
  String get contestDefInUse;

  /// Delete result.
  ///
  /// In en, this message translates to:
  /// **'Bundled definitions cannot be deleted.'**
  String get contestDefBuiltinNoDelete;

  /// Delete result.
  ///
  /// In en, this message translates to:
  /// **'This definition no longer exists.'**
  String get contestDefNotFound;

  /// Why a contest definition was rejected.
  ///
  /// In en, this message translates to:
  /// **'The definition is larger than 256 KiB.'**
  String get contestDefErrorTooLarge;

  /// Why a contest definition was rejected.
  ///
  /// In en, this message translates to:
  /// **'The file is not valid JSON.'**
  String get contestDefErrorMalformedJson;

  /// Why a contest definition was rejected.
  ///
  /// In en, this message translates to:
  /// **'A value has the wrong type.'**
  String get contestDefErrorWrongType;

  /// Why a contest definition was rejected.
  ///
  /// In en, this message translates to:
  /// **'The file contains a setting that Tideline does not know.'**
  String get contestDefErrorUnknownKey;

  /// Why a contest definition was rejected.
  ///
  /// In en, this message translates to:
  /// **'A required setting is missing.'**
  String get contestDefErrorMissingKey;

  /// Why a contest definition was rejected.
  ///
  /// In en, this message translates to:
  /// **'This schema version is not supported (only version 1).'**
  String get contestDefErrorUnsupportedSchema;

  /// Why a contest definition was rejected.
  ///
  /// In en, this message translates to:
  /// **'The id must have 1 to 64 characters: lower-case letters, digits and hyphens.'**
  String get contestDefErrorInvalidId;

  /// Why a contest definition was rejected.
  ///
  /// In en, this message translates to:
  /// **'A number or a text length is outside the allowed range.'**
  String get contestDefErrorOutOfRange;

  /// Why a contest definition was rejected.
  ///
  /// In en, this message translates to:
  /// **'A text is too long.'**
  String get contestDefErrorTooLong;

  /// Why a contest definition was rejected.
  ///
  /// In en, this message translates to:
  /// **'A text contains control characters.'**
  String get contestDefErrorInvalidCharacters;

  /// Why a contest definition was rejected.
  ///
  /// In en, this message translates to:
  /// **'A list has too many entries.'**
  String get contestDefErrorTooManyElements;

  /// Why a contest definition was rejected.
  ///
  /// In en, this message translates to:
  /// **'A list has too few entries.'**
  String get contestDefErrorTooFewElements;

  /// Why a contest definition was rejected.
  ///
  /// In en, this message translates to:
  /// **'A band name is not a known ADIF band.'**
  String get contestDefErrorUnknownBand;

  /// Why a contest definition was rejected.
  ///
  /// In en, this message translates to:
  /// **'A setting has a value that Tideline does not know.'**
  String get contestDefErrorUnknownValue;

  /// Why a contest definition was rejected.
  ///
  /// In en, this message translates to:
  /// **'The last points rule must apply to every contact, so it cannot have a condition.'**
  String get contestDefErrorLastRuleHasWhen;

  /// Why a contest definition was rejected.
  ///
  /// In en, this message translates to:
  /// **'A variant of the exchange may depend only on your own station.'**
  String get contestDefErrorVariantPredicateNotMine;

  /// Why a contest definition was rejected.
  ///
  /// In en, this message translates to:
  /// **'A received exchange element may depend only on the other station.'**
  String get contestDefErrorElementPredicateNotTheirs;

  /// Why a contest definition was rejected.
  ///
  /// In en, this message translates to:
  /// **'A sent exchange element cannot have a condition.'**
  String get contestDefErrorElementWhenNotAllowed;

  /// Why a contest definition was rejected.
  ///
  /// In en, this message translates to:
  /// **'One side of the exchange may contain only one serial number.'**
  String get contestDefErrorMultipleSerials;

  /// Why a contest definition was rejected.
  ///
  /// In en, this message translates to:
  /// **'Two exchange elements store into the same ADIF field.'**
  String get contestDefErrorDuplicateField;

  /// Why a contest definition was rejected.
  ///
  /// In en, this message translates to:
  /// **'Two multipliers have the same id.'**
  String get contestDefErrorDuplicateId;

  /// Why a contest definition was rejected.
  ///
  /// In en, this message translates to:
  /// **'A default value uses an unknown placeholder.'**
  String get contestDefErrorInvalidPlaceholder;

  /// Why a contest definition was rejected.
  ///
  /// In en, this message translates to:
  /// **'A default value does not fit its exchange element.'**
  String get contestDefErrorInvalidValue;

  /// Why a contest definition was rejected.
  ///
  /// In en, this message translates to:
  /// **'A default value is not allowed here (received side and serial numbers).'**
  String get contestDefErrorDefaultNotAllowed;

  /// Why a contest definition was rejected.
  ///
  /// In en, this message translates to:
  /// **'A multiplier uses a source that does not exist or that no received exchange contains.'**
  String get contestDefErrorInvalidMultiplierSource;

  /// Why a contest definition was rejected.
  ///
  /// In en, this message translates to:
  /// **'A condition is empty.'**
  String get contestDefErrorEmptyPredicate;

  /// Why a contest definition was rejected.
  ///
  /// In en, this message translates to:
  /// **'The score type does not fit the multipliers.'**
  String get contestDefErrorInvalidCombination;

  /// Why a contest definition was rejected.
  ///
  /// In en, this message translates to:
  /// **'The same value is listed twice.'**
  String get contestDefErrorDuplicateValue;
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
