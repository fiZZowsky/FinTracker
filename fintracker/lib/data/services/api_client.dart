import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:fintracker/data/services/retry_interceptor.dart';
import 'package:flutter/foundation.dart';
import '../../helpers/service_locator.dart';
import 'preferences_service.dart';
import 'auth_interceptor.dart';

class ApiClient {
  final Dio _dio;
  bool _isRefreshing = false;

  static const String baseUrl =
      'https://fintracker-api-a7ecfxaneehfb4hq.westeurope-01.azurewebsites.net';

  ApiClient()
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 40),
          receiveTimeout: const Duration(seconds: 40),
          sendTimeout: const Duration(seconds: 40),
        )) {
    _dio.interceptors.add(RetryInterceptor(dio: _dio));
    _dio.interceptors.add(AuthInterceptor());
    (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = getIt<PreferencesService>();
        final token = await prefs.getAuthToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401 && !_isRefreshing) {
          _isRefreshing = true;
          try {
            final prefs = getIt<PreferencesService>();
            final oldAccessToken = await prefs.getAuthToken();
            final oldRefreshToken = await prefs.getRefreshToken();

            if (oldAccessToken != null && oldRefreshToken != null) {
              final refreshDio = Dio(BaseOptions(baseUrl: baseUrl));

              (refreshDio.httpClientAdapter as IOHttpClientAdapter)
                  .createHttpClient = () {
                final client = HttpClient();
                client.badCertificateCallback = (cert, host, port) => true;
                return client;
              };

              final response =
                  await refreshDio.post('/api/Auth/refresh-token', data: {
                'accessToken': oldAccessToken,
                'refreshToken': oldRefreshToken,
              });

              if (response.statusCode == 200) {
                final newToken = response.data['token'];
                final newRefreshToken = response.data['refreshToken'];

                await prefs.setAuthToken(newToken);
                await prefs.setRefreshToken(newRefreshToken);

                final options = e.requestOptions;
                options.headers['Authorization'] = 'Bearer $newToken';

                final retryResponse = await _dio.fetch(options);
                _isRefreshing = false;
                return handler.resolve(retryResponse);
              }
            }
          } catch (refreshError) {
            debugPrint('Refresh token failed: $refreshError');
            await getIt<PreferencesService>().clearAuthData();
          } finally {
            _isRefreshing = false;
          }
        }
        return handler.next(e);
      },
    ));
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
