import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../ui/view_models/auth_view_model.dart';
import '../../helpers/service_locator.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      try {
        final authViewModel = getIt<AuthViewModel>();
        authViewModel.logout();
      } catch (e) {
        debugPrint('Błąd podczas wymuszania wylogowania w AuthInterceptor: $e');
      }
    }

    super.onError(err, handler);
  }
}
