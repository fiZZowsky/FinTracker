import 'package:flutter/material.dart';
import '../../data/models/receipt_model.dart';
import '../../data/services/receipt_service.dart';
import '../../helpers/service_locator.dart';

class ReceiptEditViewModel extends ChangeNotifier {
  final ReceiptService _receiptService = getIt<ReceiptService>();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<bool> saveReceipt(ReceiptModel receipt) async {
    _isLoading = true;
    notifyListeners();

    try {
      bool success;
      if (receipt.id > 0) {
        success = await _receiptService.updateReceipt(receipt.id, receipt);
      } else {
        success = await _receiptService.createReceipt(receipt);
      }
      return success;
    } catch (e) {
      debugPrint('Error saving receipt: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
