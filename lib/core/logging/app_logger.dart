import 'package:memox/core/logging/log_level.dart';

abstract interface class AppLogger {
  void log(LogLevel level, String message, {Object? error, StackTrace? stackTrace});

  void debug(String message);

  void info(String message);

  void warning(String message, {Object? error, StackTrace? stackTrace});

  void error(String message, {Object? error, StackTrace? stackTrace});
}
