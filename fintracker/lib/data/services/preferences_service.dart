import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _budgetKey = 'monthly_budget_limit';
  static const String _azureOcrKey = 'use_azure_ocr';

  Future<void> setBudgetLimit(double amount) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_budgetKey, amount);
  }

  Future<double> getBudgetLimit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_budgetKey) ?? 3000.0;
  }

  Future<void> setUseAzureOcr(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_azureOcrKey, value);
  }

  Future<bool> getUseAzureOcr() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_azureOcrKey) ?? false;
  }
}
