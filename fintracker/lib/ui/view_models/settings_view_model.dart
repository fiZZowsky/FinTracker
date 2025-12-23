import 'package:flutter/material.dart';
import '../../data/services/preferences_service.dart';
import '../../helpers/service_locator.dart';

class SettingsViewModel extends ChangeNotifier {
  final PreferencesService _prefs = getIt<PreferencesService>();

  bool _useAzureOcr = false;
  bool get useAzureOcr => _useAzureOcr;

  SettingsViewModel() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _useAzureOcr = await _prefs.getUseAzureOcr();
    notifyListeners();
  }

  Future<void> toggleAzureOcr(bool value) async {
    _useAzureOcr = value;
    await _prefs.setUseAzureOcr(value);
    notifyListeners();
  }
}
