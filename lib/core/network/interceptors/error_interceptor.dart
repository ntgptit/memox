import 'package:dio/dio.dart';
import 'package:memox/core/errors/app_exception.dart';

final class ErrorInterceptor extends Interceptor {
  const ErrorInterceptor();

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(
      err.copyWith(
        error: _map(err),
      ),
    );
  }

  AppException _map(DioException error) {
    if (_isTimeout(error)) {
      return const NetworkException('Network timeout');
    }

    final statusCode = error.response?.statusCode;

    if (statusCode != null) {
      return NetworkException(
        'Request failed with status $statusCode',
        statusCode: statusCode,
      );
    }

    if (error.type == DioExceptionType.cancel) {
      return const UnknownAppException('Request was cancelled');
    }

    return UnknownAppException(error.message ?? 'Unexpected network error');
  }

  bool _isTimeout(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout;
  }
}
