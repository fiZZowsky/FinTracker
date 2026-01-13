import 'package:flutter/foundation.dart';
import '../models/auth_models.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final dynamic data = await _apiClient.post(
        '/api/Auth/login',
        data: request.toJson(),
      );

      if (data is Map<String, dynamic>) {
        return AuthResponse.fromJson(data);
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      debugPrint('AuthService login error: $e');
      rethrow;
    }
  }

  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final dynamic data = await _apiClient.post(
        '/api/Auth/register',
        data: request.toJson(),
      );

      if (data is Map<String, dynamic>) {
        return AuthResponse.fromJson(data);
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      debugPrint('AuthService register error: $e');
      rethrow;
    }
  }
}
