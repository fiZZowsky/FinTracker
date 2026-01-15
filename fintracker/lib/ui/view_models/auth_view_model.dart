import 'package:flutter/material.dart';
import '../../data/models/auth_models.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/preferences_service.dart';
import '../../helpers/service_locator.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = getIt<AuthService>();
  final PreferencesService _prefs = getIt<PreferencesService>();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  String? _userName;
  String? get userName => _userName;

  AuthViewModel() {
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final token = await _prefs.getAuthToken();
    _userName = await _prefs.getUserName();
    _isLoggedIn = token != null && token.isNotEmpty;
    notifyListeners();
  }

  Future<String?> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authService.login(
        LoginRequest(email: email, password: password),
      );

      await _prefs.setAuthToken(response.token);
      await _prefs.setRefreshToken(response.refreshToken);
      await _prefs.setUserName(response.name);

      _userName = response.name;
      _isLoggedIn = true;
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> register(
      String name, String email, String password, String confirm) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authService.register(
        RegisterRequest(
          name: name,
          email: email,
          password: password,
          confirmPassword: confirm,
        ),
      );

      await _prefs.setAuthToken(response.token);
      await _prefs.setRefreshToken(response.refreshToken);
      await _prefs.setUserName(response.name);

      _userName = response.name;
      _isLoggedIn = true;
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _prefs.clearAuthData();
    _isLoggedIn = false;
    _userName = null;
    notifyListeners();
  }

  Future<bool> changePassword(
      String current, String newPass, String confirm) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.changePassword(current, newPass, confirm);
      return true;
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAccount() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.deleteAccount();
      await logout();
      return true;
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
