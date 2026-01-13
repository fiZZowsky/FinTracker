import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import '../../helpers/service_locator.dart';
import 'preferences_service.dart';

class ApiClient {
  final Dio _dio;

  static const String _baseUrl =
      kIsWeb ? 'https://localhost:7297' : 'https://10.0.2.2:7297';

  ApiClient()
      : _dio = Dio(BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        )) {
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
        if (e.response?.statusCode == 401) {
          debugPrint(
              "Token expired or invalid. Logout logic could trigger here.");
        }
        return handler.next(e);
      },
    ));
  }

  Future<dynamic> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      debugPrint('ApiClient GET error: $e');
      rethrow;
    } catch (e) {
      debugPrint('ApiClient GET Unknown error: $e');
      rethrow;
    }
  }

  Future<dynamic> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return response.data;
    } on DioException catch (e) {
      debugPrint('ApiClient POST error: $e');
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> postFormData(String path, FormData data) async {
    try {
      final response = await _dio.post(path, data: data);
      return response.data;
    } on DioException catch (e) {
      debugPrint('ApiClient POST FormData error: $e');
      rethrow;
    }
  }

  Future<dynamic> put(String path, {dynamic data}) async {
    try {
      final response = await _dio.put(path, data: data);
      return response.data;
    } on DioException catch (e) {
      debugPrint('ApiClient PUT error: $e');
      rethrow;
    }
  }

  Future<dynamic> delete(String path) async {
    try {
      final response = await _dio.delete(path);
      return response.data;
    } on DioException catch (e) {
      debugPrint('ApiClient DELETE error: $e');
      rethrow;
    }
  }
}
