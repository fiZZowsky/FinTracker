import 'package:fintracker/data/models/ocr_engine_type.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PreferencesService {
  static const String _budgetKey = 'monthly_budget_limit';
  static const String _ocrEngineKey = 'ocr_engine_type';
  static const String _userNameKey = 'user_name';

  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';

  final _secureStorage = const FlutterSecureStorage();

  AndroidOptions _getAndroidOptions() => const AndroidOptions(
        resetOnError: true,
      );

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

  Future<void> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
  }

  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  Future<void> setAuthToken(String token) async {
    await _secureStorage.write(
      key: _tokenKey,
      value: token,
      aOptions: _getAndroidOptions(),
    );
  }

  Future<String?> getAuthToken() async {
    return await _secureStorage.read(
      key: _tokenKey,
      aOptions: _getAndroidOptions(),
    );
  }

  Future<void> setRefreshToken(String token) async {
    await _secureStorage.write(
      key: _refreshTokenKey,
      value: token,
      aOptions: _getAndroidOptions(),
    );
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(
      key: _refreshTokenKey,
      aOptions: _getAndroidOptions(),
    );
  }

  Future<void> clearAuthData() async {
    await _secureStorage.delete(
      key: _tokenKey,
      aOptions: _getAndroidOptions(),
    );
    await _secureStorage.delete(
      key: _refreshTokenKey,
      aOptions: _getAndroidOptions(),
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userNameKey);
  }
}
