import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import '../../data/services/receipt_service.dart';
import '../../data/services/preferences_service.dart';
import '../../helpers/service_locator.dart';
import '../../helpers/notification_service.dart';
import 'loading_view_model.dart';
import '../../data/models/receipt_model.dart';
import '../../data/models/ocr_engine_type.dart';

Future<String> _processImageInIsolate(String path) async {
  try {
    final file = File(path);
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) return path;

    var processed = img.grayscale(image);

    processed = img.contrast(processed, contrast: 125);

    final tempPath =
        path.replaceFirst('.jpg', '_bw.jpg').replaceFirst('.png', '_bw.png');
    final processedFile = File(tempPath);

    await processedFile.writeAsBytes(img.encodeJpg(processed, quality: 95));

    return tempPath;
  } catch (e) {
    return path;
  }
}

class ScannerViewModel extends ChangeNotifier {
  final ReceiptService _receiptService = getIt<ReceiptService>();
  final PreferencesService _prefs = getIt<PreferencesService>();
  final LoadingViewModel _loadingViewModel;

  ScannerViewModel({required LoadingViewModel loadingViewModel})
      : _loadingViewModel = loadingViewModel;

  Future<ReceiptModel?> scanWithCamera() async {
    try {
      final scanner = FlutterDocScanner();
      final result = await scanner.getScannedDocumentAsImages(page: 1);

      if (result != null) {
        final uriString = result['Uri'];
        final match = RegExp(r'imageUri=([^}]+)').firstMatch(uriString);
        if (match == null) throw 'Brak imageUri w odpowiedzi skanera';

        final fullUri = match.group(1)!;
        final filePath = fullUri.replaceFirst('file://', '');
        final file = XFile(filePath);

        return await _uploadFile(file);
      }
    } catch (e) {
      debugPrint('Błąd aparatu/skanera: $e');
      getIt<NotificationService>().showNotification(
        'unknownError',
        type: NotificationType.error,
      );
    }
    return null;
  }

  Future<ReceiptModel?> pickFile() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? picked = await picker.pickImage(source: ImageSource.gallery);

      if (picked != null) {
        return await _uploadFile(picked);
      }
    } catch (e) {
      debugPrint('Błąd wyboru pliku: $e');
      getIt<NotificationService>().showNotification(
        'unknownError',
        type: NotificationType.error,
      );
    }
    return null;
  }

  Future<ReceiptModel?> _uploadFile(XFile file) async {
    _loadingViewModel.show();
    ReceiptModel? parsedReceipt;

    try {
      final engine = await _prefs.getOcrEngine();
      String? recognizedText;

      String finalPath = file.path;

      if (engine == OcrEngineType.googleMlKit) {
        finalPath = await compute(_processImageInIsolate, file.path);
        final inputImage = InputImage.fromFilePath(finalPath);
        final textRecognizer =
            TextRecognizer(script: TextRecognitionScript.latin);

        try {
          final RecognizedText result =
              await textRecognizer.processImage(inputImage);
          recognizedText = result.text;
        } catch (mlError) {
          debugPrint("Błąd ML Kit: $mlError");
        } finally {
          textRecognizer.close();
        }
      } else {}

      parsedReceipt = await _receiptService.uploadReceipt(XFile(finalPath),
          extractedText: recognizedText);

      if (parsedReceipt == null) {
        throw Exception('Serwer zwrócił pusty wynik lub błąd parsowania');
      }

      return parsedReceipt;
    } catch (e) {
      getIt<NotificationService>().showNotification(
        'scannerUploadError',
        type: NotificationType.error,
      );
      return null;
    } finally {
      _loadingViewModel.hide();
    }
  }
}
