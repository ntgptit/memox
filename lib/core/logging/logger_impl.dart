import 'package:flutter/foundation.dart';
import 'package:memox/core/logging/app_logger.dart';
import 'package:memox/core/logging/log_level.dart';

final class LoggerImpl implements AppLogger {
  const LoggerImpl();

  @override
  void debug(String message) => log(LogLevel.debug, message);

  @override
  void info(String message) => log(LogLevel.info, message);

  @override
  void warning(String message, {Object? error, StackTrace? stackTrace}) =>
      log(LogLevel.warning, message, error: error, stackTrace: stackTrace);

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) =>
      log(LogLevel.error, message, error: error, stackTrace: stackTrace);

  @override
  void log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (kReleaseMode) {
      return;
    }

    final buffer = StringBuffer('[${level.name.toUpperCase()}] $message');
    if (error != null) {
      buffer.write(' | error: $error');
    }
    if (stackTrace != null) {
      buffer.write('\n$stackTrace');
    }
    debugPrint(buffer.toString());
  }
}
