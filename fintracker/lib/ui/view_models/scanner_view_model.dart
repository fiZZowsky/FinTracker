import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/services/receipt_service.dart';
import '../../helpers/service_locator.dart';
import '../../helpers/notification_service.dart';
import 'loading_view_model.dart';

class ScannerViewModel extends ChangeNotifier {
  final ReceiptService _receiptService = getIt<ReceiptService>();
  final LoadingViewModel _loadingViewModel;

  ScannerViewModel({required LoadingViewModel loadingViewModel})
      : _loadingViewModel = loadingViewModel;

  Future<void> scanWithCamera() async {
    try {
      final scanner = FlutterDocScanner();

      final result = await scanner.getScannedDocumentAsImages(page: 1);

      if (result != null) {
        final uriString = result['Uri'];

        final match = RegExp(r'imageUri=([^}]+)').firstMatch(uriString);
        if (match == null) throw 'Brak imageUri w odpowiedzi API';

        final fullUri = match.group(1)!;

        final filePath = fullUri.replaceFirst('file://', '');

        final file = XFile(filePath);

        await _uploadFile(file);
      }
    } catch (e) {
      debugPrint('Błąd aparatu: $e');
      getIt<NotificationService>().showNotification(
        'unknownError',
        type: NotificationType.error,
      );
    }
  }

  Future<void> pickFile() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? picked = await picker.pickImage(source: ImageSource.gallery);

      if (picked != null) {
        await _uploadFile(picked);
      }
    } catch (e) {
      debugPrint('Błąd wyboru pliku: $e');
      getIt<NotificationService>().showNotification(
        'unknownError',
        type: NotificationType.error,
      );
    }
  }

  Future<void> _uploadFile(XFile file) async {
    _loadingViewModel.show();
    try {
      final bool success = await _receiptService.uploadReceipt(file);

      if (success) {
        getIt<NotificationService>().showNotification(
          'scannerUploadSuccess',
          type: NotificationType.success,
        );
      } else {
        throw Exception('Upload failed on server');
      }
    } catch (e) {
      debugPrint('Błąd wysyłania: $e');
      getIt<NotificationService>().showNotification(
        'scannerUploadError',
        type: NotificationType.error,
      );
    } finally {
      _loadingViewModel.hide();
    }
  }
}
