// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get homePage => 'Home';

  @override
  String get scannerPage => 'Scanner';

  @override
  String get finansesPage => 'Finanses';

  @override
  String get settingsPage => 'Settings';

  @override
  String get themeSwitch => 'Dark Mode';

  @override
  String get themeSwitchSystem => 'Use system settings';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System Default';

  @override
  String get languagePolish => 'Polish';

  @override
  String get languageEnglish => 'English';

  @override
  String get noReceiptsAdded => 'No receipts have been added yet.';

  @override
  String get errorFetchingData => 'An error occurred while fetching data.';

  @override
  String get networkError => 'Network error: Could not connect to server.';

  @override
  String get unknownError => 'An unknown error occurred.';

  @override
  String get languageChangedToPl => 'Language changed to Polish';

  @override
  String get languageChangedToEn => 'Language changed to English';

  @override
  String get scannerTitle => 'Use the camera to scan a receipt';

  @override
  String get scannerCameraAccess => 'Launch Camera';

  @override
  String get scannerGalleryAccess => 'Choose from Gallery';

  @override
  String get scannerUploadSuccess => 'Receipt uploaded successfully';

  @override
  String get scannerUploadError => 'Error uploading receipt';
}
