import 'package:flutter/material.dart';

enum NotificationType { success, error, info }

class NotificationService {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  void showNotification(
    String message, {
    NotificationType type = NotificationType.info,
  }) {
    if (scaffoldMessengerKey.currentState == null) {
      debugPrint(
          "Błąd: NotificationService.scaffoldMessengerKey nie jest podpięty do MaterialApp.");
      return;
    }

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
      content: Text(message, style: const TextStyle(color: Colors.white)),
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
}
