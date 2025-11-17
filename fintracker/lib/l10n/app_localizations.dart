import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('en'),
    Locale('pl')
  ];

  /// No description provided for @homePage.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homePage;

  /// No description provided for @scannerPage.
  ///
  /// In en, this message translates to:
  /// **'Scanner'**
  String get scannerPage;

  /// No description provided for @finansesPage.
  ///
  /// In en, this message translates to:
  /// **'Finanses'**
  String get finansesPage;

  /// No description provided for @settingsPage.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsPage;

  /// No description provided for @themeSwitch.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get themeSwitch;

  /// No description provided for @themeSwitchSystem.
  ///
  /// In en, this message translates to:
  /// **'Use system settings'**
  String get themeSwitchSystem;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get languageSystem;

  /// No description provided for @languagePolish.
  ///
  /// In en, this message translates to:
  /// **'Polish'**
  String get languagePolish;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @noReceiptsAdded.
  ///
  /// In en, this message translates to:
  /// **'No receipts have been added yet.'**
  String get noReceiptsAdded;

  /// No description provided for @errorFetchingData.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while fetching data.'**
  String get errorFetchingData;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error: Could not connect to server.'**
  String get networkError;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred.'**
  String get unknownError;

  /// No description provided for @languageChangedToPl.
  ///
  /// In en, this message translates to:
  /// **'Language changed to Polish'**
  String get languageChangedToPl;

  /// No description provided for @languageChangedToEn.
  ///
  /// In en, this message translates to:
  /// **'Language changed to English'**
  String get languageChangedToEn;

  /// No description provided for @scannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Use the camera to scan a receipt'**
  String get scannerTitle;

  /// No description provided for @scannerCameraAccess.
  ///
  /// In en, this message translates to:
  /// **'Launch Camera'**
  String get scannerCameraAccess;

  /// No description provided for @scannerGalleryAccess.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get scannerGalleryAccess;

  /// No description provided for @scannerUploadSuccess.
  ///
  /// In en, this message translates to:
  /// **'Receipt uploaded successfully'**
  String get scannerUploadSuccess;

  /// No description provided for @scannerUploadError.
  ///
  /// In en, this message translates to:
  /// **'Error uploading receipt'**
  String get scannerUploadError;

  /// No description provided for @finansesSummaryTab.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get finansesSummaryTab;

  /// No description provided for @finansesAllTab.
  ///
  /// In en, this message translates to:
  /// **'All Receipts'**
  String get finansesAllTab;

  /// No description provided for @filterWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get filterWeek;

  /// No description provided for @filterMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get filterMonth;

  /// No description provided for @filter6Months.
  ///
  /// In en, this message translates to:
  /// **'6 Months'**
  String get filter6Months;

  /// No description provided for @filterYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get filterYear;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get filterAll;

  /// No description provided for @finansesTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get finansesTotal;

  /// No description provided for @receiptEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Receipt'**
  String get receiptEditTitle;

  /// No description provided for @receiptSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get receiptSaveButton;

  /// No description provided for @receiptSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Receipt saved successfully'**
  String get receiptSaveSuccess;

  /// No description provided for @receiptSaveError.
  ///
  /// In en, this message translates to:
  /// **'Error saving receipt'**
  String get receiptSaveError;

  /// No description provided for @receiptStoreName.
  ///
  /// In en, this message translates to:
  /// **'Store Name'**
  String get receiptStoreName;

  /// No description provided for @receiptTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get receiptTotalAmount;

  /// No description provided for @receiptDate.
  ///
  /// In en, this message translates to:
  /// **'Date of Shopping'**
  String get receiptDate;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @receiptDetails.
  ///
  /// In en, this message translates to:
  /// **'Receipt Details'**
  String get receiptDetails;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @receiptUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Receipt updated successfully'**
  String get receiptUpdateSuccess;

  /// No description provided for @receiptUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Error updating receipt'**
  String get receiptUpdateError;
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
      <String>['en', 'pl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pl':
      return AppLocalizationsPl();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
