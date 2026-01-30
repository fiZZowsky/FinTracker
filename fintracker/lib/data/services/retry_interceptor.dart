import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final int retryInterval;

  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.retryInterval = 1000,
  });

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err)) {
      var extra = err.requestOptions.extra;
      var retries = extra['retries'] ?? 0;

      if (retries < maxRetries) {
        retries++;
        extra['retries'] = retries;

        await Future.delayed(Duration(milliseconds: retryInterval));

        try {
          var response = await dio.fetch(err.requestOptions);
          return handler.resolve(response);
        } catch (e) {
          return super.onError(err, handler);
        }
      }
    }

    return super.onError(err, handler);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.response != null && err.response!.statusCode == 503);
  }
}
