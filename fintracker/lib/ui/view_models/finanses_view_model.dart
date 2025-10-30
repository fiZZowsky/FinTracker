import 'package:flutter/material.dart';
import '../../data/models/receipt_model.dart';
import '../../data/services/receipt_service.dart';
import '../../helpers/service_locator.dart';

class FinansesViewModel extends ChangeNotifier {
  final ReceiptService _receiptService = getIt<ReceiptService>();

  bool _isLoading = false;
  List<ReceiptModel> _receipts = [];
  bool _hasError = false;

  bool get isLoading => _isLoading;
  List<ReceiptModel> get receipts => _receipts;
  bool get hasError => _hasError;

  FinansesViewModel() {
    fetchReceipts();
  }

  Future<void> fetchReceipts() async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      _receipts = await _receiptService.getReceipts();
    } catch (e) {
      _hasError = true;
    }

    _isLoading = false;
    notifyListeners();
  }
}
