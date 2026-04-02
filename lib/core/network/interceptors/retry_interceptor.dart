import 'package:dio/dio.dart';

final class RetryInterceptor extends Interceptor {
  RetryInterceptor(
    this._dio, {
    this.maxRetries = 1,
  });

  final Dio _dio;
  final int maxRetries;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (!_shouldRetry(err)) {
      handler.next(err);
      return;
    }

    final attempt = (err.requestOptions.extra['retry_attempt'] as int?) ?? 0;

    if (attempt >= maxRetries) {
      handler.next(err);
      return;
    }

    err.requestOptions.extra['retry_attempt'] = attempt + 1;

    try {
      final response = await _dio.fetch<dynamic>(err.requestOptions);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  bool _shouldRetry(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout) {
      return true;
    }

    if (error.type == DioExceptionType.receiveTimeout) {
      return true;
    }

    final statusCode = error.response?.statusCode;
    return statusCode != null && statusCode >= 500;
  }
}
