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

  @override
  String get finansesSummaryTab => 'Summary';

  @override
  String get finansesAllTab => 'All Receipts';

  @override
  String get filterWeek => 'Week';

  @override
  String get filterMonth => 'Month';

  @override
  String get filter6Months => '6 Months';

  @override
  String get filterYear => 'Year';

  @override
  String get filterAll => 'All Time';

  @override
  String get finansesTotal => 'Total';

  @override
  String get receiptEditTitle => 'Edit Receipt';

  @override
  String get receiptSaveButton => 'Save';

  @override
  String get receiptSaveSuccess => 'Receipt saved successfully';

  @override
  String get receiptSaveError => 'Error saving receipt';

  @override
  String get receiptStoreName => 'Store Name';

  @override
  String get receiptTotalAmount => 'Total Amount';

  @override
  String get receiptDate => 'Date of Shopping';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get receiptDetails => 'Receipt Details';

  @override
  String get edit => 'Edit';

  @override
  String get receiptUpdateSuccess => 'Receipt updated successfully';

  @override
  String get receiptUpdateError => 'Error updating receipt';

  @override
  String get unsavedChangesTitle => 'Unsaved changes';

  @override
  String get unsavedChangesMessage =>
      'You have unsaved changes. Are you sure you want to leave and discard them?';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Leave';

  @override
  String get receiptAddTitle => 'Add Receipt';

  @override
  String get invalidValue => 'Invalid value';

  @override
  String get tryAgain => 'Try again';

  @override
  String get receiptCategory => 'Category';

  @override
  String get selectCategory => 'Select Category';

  @override
  String get noCategory => 'No category';

  @override
  String get welcomeBack => 'Welcome back!';

  @override
  String get recentReceipts => 'Recent Receipts';

  @override
  String get scanAction => 'Scan';

  @override
  String get addAction => 'Add';

  @override
  String get currentMonth => '(Current Month)';

  @override
  String get budgetRemaining => 'Remaining';

  @override
  String get budgetSpent => 'Spent';

  @override
  String get budgetLimit => 'Limit';

  @override
  String get categorySpozywcze => 'Groceries';

  @override
  String get categoryTransport => 'Transport';

  @override
  String get categoryMieszkanie => 'Housing';

  @override
  String get categoryInne => 'Other';

  @override
  String get chartTime => 'Over Time';

  @override
  String get chartCategories => 'Categories';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get noExpenses => 'No expenses in this period';

  @override
  String get settingsFinanceSection => 'Finance';

  @override
  String get budgetLimitSetting => 'Monthly Budget Limit';

  @override
  String get setBudgetTitle => 'Set Monthly Limit';

  @override
  String get amountLabel => 'Amount';

  @override
  String get save => 'Save';

  @override
  String get ocrSettingsTitle => 'OCR Engine';

  @override
  String get useAzureOcr => 'Use Azure AI Vision (Cloud)';

  @override
  String get useAzureOcrSubtitle => 'More accurate but slower.';

  @override
  String get noData => 'No data';

  @override
  String get noInternetTitle => 'No Connection';

  @override
  String get noInternetMessage =>
      'This app requires an internet connection to work properly.';

  @override
  String get exitApp => 'Exit';

  @override
  String get accountManagement => 'Account Management';

  @override
  String get changePassword => 'Change Password';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmNewPassword => 'Confirm New Password';

  @override
  String get passwordChangedSuccess => 'Password changed successfully.';

  @override
  String get deleteAccountConfirmationTitle => 'Delete Account';

  @override
  String get deleteAccountConfirmationMessage =>
      'Are you sure you want to delete your account? This action is irreversible and will delete all your receipts and settings.';

  @override
  String get delete => 'Delete';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get exportData => 'Export Data';

  @override
  String get selectDateRange => 'Select Date Range';

  @override
  String get exportCsv => 'CSV (Excel)';

  @override
  String get exportPdf => 'PDF';

  @override
  String get passwordTooShort => 'Password too short (min. 6 chars)';

  @override
  String get fintracker => 'FinTracker';

  @override
  String get authError => 'Login/Register error: Check your data';

  @override
  String get loginTitle => 'Login';

  @override
  String get registerTitle => 'Register';

  @override
  String get enterName => 'Enter Name';

  @override
  String get email => 'Email';

  @override
  String get invalidEmail => 'Invalid email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get loginButton => 'Login';

  @override
  String get registerButton => 'Register';

  @override
  String get dontHaveAccount => 'Don\'t have an account? Register';

  @override
  String get haveAccount => 'Already have an account? Login';

  @override
  String get addCategory => 'Add Category';

  @override
  String get operationError => 'An error occurred';

  @override
  String get manageCategories => 'Manage Categories';

  @override
  String get defaultCategory => 'Default';

  @override
  String get addStore => 'Add Store';

  @override
  String get manageStores => 'Manage Stores';

  @override
  String get defaultStore => 'Default';

  @override
  String get dateFutureError => 'Purchase date cannot be in the future';

  @override
  String get dateTooOldError => 'Purchase date is invalid (too old)';

  @override
  String get logout => 'Log out';

  @override
  String get operationSuccess => 'Operation successful';

  @override
  String get user => 'User';

  @override
  String get loggedIn => 'Logged in';

  @override
  String get loading => 'Loading';
}
