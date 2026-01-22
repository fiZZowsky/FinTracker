import 'package:fintracker/data/models/ocr_engine_type.dart';
import 'package:flutter/material.dart';
import '../../data/services/preferences_service.dart';
import '../../helpers/service_locator.dart';

class SettingsViewModel extends ChangeNotifier {
  final PreferencesService _prefs = getIt<PreferencesService>();

  OcrEngineType _selectedOcrEngine = OcrEngineType.tesseractOCR;
  OcrEngineType get selectedOcrEngine => _selectedOcrEngine;

  SettingsViewModel() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _selectedOcrEngine = await _prefs.getOcrEngine();
    notifyListeners();
  }

  Future<void> setOcrEngine(OcrEngineType engine) async {
    _selectedOcrEngine = engine;
    await _prefs.setOcrEngine(engine);
    notifyListeners();
  }
}
