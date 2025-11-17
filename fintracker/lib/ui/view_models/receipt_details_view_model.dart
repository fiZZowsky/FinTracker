import 'package:flutter/material.dart';
import '../../data/models/receipt_model.dart';
import '../../data/services/receipt_service.dart';
import '../../helpers/service_locator.dart';

class ReceiptDetailsViewModel extends ChangeNotifier {
  final ReceiptService _receiptService = getIt<ReceiptService>();

  ReceiptModel? _receipt;
  ReceiptModel? get receipt => _receipt;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _hasError = false;
  bool get hasError => _hasError;

  Future<void> fetchReceiptDetails(int id) async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      _receipt = await _receiptService.getReceiptById(id);
      if (_receipt == null) {
        throw Exception("Receipt not found");
      }
    } catch (e) {
      debugPrint('Error fetching receipt details: $e');
      _hasError = true;
    }

    _isLoading = false;
    notifyListeners();
  }
}
