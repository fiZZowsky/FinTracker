import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _budgetKey = 'monthly_budget_limit';
  static const String _azureOcrKey = 'use_azure_ocr';
  static const String _tokenKey = 'auth_token';
  static const String _userNameKey = 'user_name';
  static const String _refreshTokenKey = 'refresh_token';

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

  Future<void> setAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
  }

  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  Future<void> setRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshTokenKey, token);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userNameKey);
  }
}
