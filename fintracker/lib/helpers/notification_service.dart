import 'package:fintracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

enum NotificationType { success, error, info }

class NotificationService {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  void showNotification(
    String messageKey, {
    NotificationType type = NotificationType.info,
  }) {
    if (scaffoldMessengerKey.currentState == null ||
        scaffoldMessengerKey.currentContext == null) {
      debugPrint(
          "Błąd: NotificationService.scaffoldMessengerKey nie jest podpięty.");
      return;
    }

    final context = scaffoldMessengerKey.currentContext!;
    final l10n = AppLocalizations.of(context)!;
    final String translatedMessage = _getTranslatedString(l10n, messageKey);

    Color backgroundColor;
    switch (type) {
      case NotificationType.success:
        backgroundColor = Colors.green.shade600;
        break;
      case NotificationType.error:
        backgroundColor = Colors.red.shade600;
        break;
      case NotificationType.info:
        final context = scaffoldMessengerKey.currentContext;
        backgroundColor = context != null
            ? Theme.of(context).colorScheme.secondary
            : Colors.blue.shade600;
        break;
    }

    final snackBar = SnackBar(
      content:
          Text(translatedMessage, style: const TextStyle(color: Colors.white)),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 3),
    );

    scaffoldMessengerKey.currentState!
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  static String _getTranslatedString(AppLocalizations l10n, String key) {
    switch (key) {
      case 'networkError':
        return l10n.networkError;
      case 'unknownError':
        return l10n.unknownError;
      case 'languageChangedToPl':
        return l10n.languageChangedToPl;
      case 'languageChangedToEn':
        return l10n.languageChangedToEn;

      case 'errorFetchingData':
        return l10n.errorFetchingData;

      case 'receiptSaveSuccess':
        return l10n.receiptSaveSuccess;
      case 'receiptSaveError':
        return l10n.receiptSaveError;

      case 'scannerUploadSuccess':
        return l10n.scannerUploadSuccess;
      case 'scannerUploadError':
        return l10n.scannerUploadError;

      default:
        debugPrint('Brakujący klucz l10n w NotificationService: $key');
        return key;
    }
  }
}
