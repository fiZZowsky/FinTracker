import 'package:fintracker/data/models/ocr_engine_type.dart';
import 'package:flutter/material.dart';
import '../../data/services/preferences_service.dart';
import '../../helpers/service_locator.dart';
import '../../data/models/currency_code.dart';

class SettingsViewModel extends ChangeNotifier {
  final PreferencesService _prefs = getIt<PreferencesService>();

  OcrEngineType _selectedOcrEngine = OcrEngineType.tesseractOCR;
  OcrEngineType get selectedOcrEngine => _selectedOcrEngine;
  CurrencyCode _defaultCurrency = CurrencyCode.pln;
  CurrencyCode get defaultCurrency => _defaultCurrency;

  SettingsViewModel() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _selectedOcrEngine = await _prefs.getOcrEngine();
    final currencyStr = await _prefs.getDefaultCurrency();
    _defaultCurrency = CurrencyCodeExtension.fromCode(currencyStr);

    notifyListeners();
  }

  Future<void> setOcrEngine(OcrEngineType engine) async {
    _selectedOcrEngine = engine;
    await _prefs.setOcrEngine(engine);
    notifyListeners();
  }

  Future<void> updateDefaultCurrency(CurrencyCode newCurrency) async {
    _defaultCurrency = newCurrency;
    notifyListeners();
    await _prefs.setDefaultCurrency(newCurrency.code);
  }
}
