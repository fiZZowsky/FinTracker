import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:fintracker/data/services/retry_interceptor.dart';
import 'package:flutter/foundation.dart';
import '../../helpers/service_locator.dart';
import 'preferences_service.dart';
import 'auth_interceptor.dart';
import 'package:dio/io.dart';

class ApiClient {
  final Dio _dio;
  late final Dio _tokenDio;
  Completer<bool>? _refreshCompleter;

  // static const String baseUrl = 'https://10.0.2.2:7297';
  static const String baseUrl =
      'https://fintracker-api-a7ecfxaneehfb4hq.westeurope-01.azurewebsites.net';

  ApiClient()
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 40),
          receiveTimeout: const Duration(seconds: 40),
          sendTimeout: const Duration(seconds: 40),
        )) {
    _tokenDio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    _dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      },
    );

    _tokenDio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      },
    );

    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(RetryInterceptor(dio: _dio));
    _dio.interceptors.add(AuthInterceptor());

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = getIt<PreferencesService>();
        final token = await prefs.getAuthToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException err, handler) async {
        if (err.response?.statusCode == 401) {
          if (_refreshCompleter != null) {
            debugPrint('Czekam na zakończenie odświeżania tokena...');
            final success = await _refreshCompleter!.future;

            if (success) {
              return _retryRequest(err, handler);
            } else {
              return handler.next(err);
            }
          }

          _refreshCompleter = Completer<bool>();

          debugPrint('Rozpoczynam odświeżanie tokena...');
          final refreshed = await _performRefreshToken();

          _refreshCompleter?.complete(refreshed);
          _refreshCompleter = null;

          if (refreshed) {
            return _retryRequest(err, handler);
          }
        }

        return handler.next(err);
      },
    ));
  }

  Future<bool> _performRefreshToken() async {
    try {
      final prefs = getIt<PreferencesService>();
      final oldAccessToken = await prefs.getAuthToken();
      final oldRefreshToken = await prefs.getRefreshToken();

      if (oldAccessToken == null || oldRefreshToken == null) {
        return false;
      }

      final response = await _tokenDio.post('/api/Auth/refresh-token', data: {
        'accessToken': oldAccessToken,
        'refreshToken': oldRefreshToken,
      });

      if (response.statusCode == 200) {
        final newToken = response.data['token'];
        final newRefreshToken = response.data['refreshToken'];

        await prefs.setAuthToken(newToken);
        await prefs.setRefreshToken(newRefreshToken);
        debugPrint('✅ Token odświeżony pomyślnie');
        return true;
      }
    } catch (e) {
      debugPrint('Błąd odświeżania tokena: $e');
      await getIt<PreferencesService>().clearAuthData();
    }
    return false;
  }

  Future<void> _retryRequest(
      DioException err, ErrorInterceptorHandler handler) async {
    try {
      final prefs = getIt<PreferencesService>();
      final newToken = await prefs.getAuthToken();
      final options = err.requestOptions;
      options.headers['Authorization'] = 'Bearer $newToken';

      final response = await _dio.fetch(options);
      return handler.resolve(response);
    } catch (e) {
      if (e is DioException) {
        return handler.next(e);
      }
      return handler.next(err);
    }
  }

  Future<dynamic> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    final response = await _dio.get(path, queryParameters: queryParameters);
    return response.data;
  }

  Future<dynamic> post(String path, {dynamic data}) async {
    final response = await _dio.post(path, data: data);
    return response.data;
  }

  Future<dynamic> postFormData(String path, FormData data) async {
    final response = await _dio.post(path, data: data);
    return response.data;
  }

  Future<dynamic> put(String path, {dynamic data}) async {
    final response = await _dio.put(path, data: data);
    return response.data;
  }

  Future<dynamic> delete(String path) async {
    final response = await _dio.delete(path);
    return response.data;
  }
}
