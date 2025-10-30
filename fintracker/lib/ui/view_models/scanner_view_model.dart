import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../data/services/receipt_service.dart';
import '../../helpers/service_locator.dart';
import '../../helpers/notification_service.dart';
import 'loading_view_model.dart';

class ScannerViewModel extends ChangeNotifier {
  final ReceiptService _receiptService = getIt<ReceiptService>();
  final LoadingViewModel _loadingViewModel;
  final ImagePicker _imagePicker = ImagePicker();

  ScannerViewModel({required LoadingViewModel loadingViewModel})
      : _loadingViewModel = loadingViewModel;

  Future<void> scanWithCamera() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (photo != null) {
        await _uploadFile(photo);
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
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result != null && result.files.single.path != null) {
        final XFile file = XFile(result.files.single.path!);
        await _uploadFile(file);
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
          'Paragon wysłany pomyślnie', // TODO: Dodaj klucz l10n
          type: NotificationType.success,
        );
      } else {
        throw Exception('Upload failed on server');
      }
    } catch (e) {
      debugPrint('Błąd wysyłania: $e');
      getIt<NotificationService>().showNotification(
        'Błąd wysyłania paragonu', // TODO: Dodaj klucz l10n
        type: NotificationType.error,
      );
    } finally {
      _loadingViewModel.hide();
    }
  }
}
