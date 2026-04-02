import 'package:memox/core/logging/app_logger.dart';

final class GlobalErrorHandler {
  const GlobalErrorHandler(this._logger);

  final AppLogger _logger;

  void handle(
    Object error, {
    StackTrace? stackTrace,
    String message = 'Unhandled application error',
  }) {
    _logger.error(message, error: error, stackTrace: stackTrace);
  }
}
