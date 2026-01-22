import 'package:fintracker/data/models/ocr_engine_type.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _budgetKey = 'monthly_budget_limit';
  static const String _ocrEngineKey = 'ocr_engine_type';
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

  Future<void> setOcrEngine(OcrEngineType engine) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_ocrEngineKey, engine.index);
  }

  Future<OcrEngineType> getOcrEngine() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_ocrEngineKey) ?? 0;
    return OcrEngineType.values.firstWhere(
      (e) => e.index == index,
      orElse: () => OcrEngineType.tesseractOCR,
    );
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
