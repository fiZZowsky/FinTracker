import 'package:fintracker/data/services/preferences_service.dart';
import 'package:flutter/material.dart';
import '../../data/models/receipt_model.dart';
import '../../data/services/receipt_service.dart';
import '../../helpers/service_locator.dart';

class ReceiptDetailsViewModel extends ChangeNotifier {
  final ReceiptService _receiptService = getIt<ReceiptService>();
  final PreferencesService _prefsService = getIt<PreferencesService>();

  ReceiptModel? _receipt;
  ReceiptModel? get receipt => _receipt;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _hasError = false;
  bool get hasError => _hasError;

  String _currentCurrency = 'PLN';
  String get currentCurrency => _currentCurrency;

  Future<void> fetchReceiptDetails(int id) async {
    _isLoading = true;
    _hasError = false;
    _currentCurrency = await _prefsService.getDefaultCurrency();

    notifyListeners();

    try {
      _receipt = await _receiptService.getReceiptById(id,
          currencyCode: _currentCurrency);
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
