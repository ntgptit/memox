import 'package:dio/dio.dart';
import 'package:memox/core/logging/app_logger.dart';

final class LoggingInterceptor extends Interceptor {
  const LoggingInterceptor(this._logger);

  final AppLogger _logger;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.debug(
      '[HTTP] ${options.method} ${options.uri} '
      'query=${options.queryParameters}',
    );
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    _logger.debug(
      '[HTTP] ${response.requestOptions.method} ${response.requestOptions.uri} '
      'status=${response.statusCode}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.error(
      '[HTTP] ${err.requestOptions.method} ${err.requestOptions.uri}',
      error: err.error ?? err,
      stackTrace: err.stackTrace,
    );
    handler.next(err);
  }
}
