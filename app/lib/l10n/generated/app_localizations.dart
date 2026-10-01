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

  /// Explanation shown when the log is empty during the foundation phase.
  ///
  /// In en, this message translates to:
  /// **'Logging arrives in the next release. Everything you log will be saved on this device first, with or without a connection.'**
  String get logEmptyBody;

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

  /// Message when the user triggers sync in the foundation build.
  ///
  /// In en, this message translates to:
  /// **'Sync arrives in the next release.'**
  String get syncNotYetAvailable;

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
