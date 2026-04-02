import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/errors/global_error_handler.dart';
import 'package:memox/core/logging/app_logger.dart';
import 'package:memox/core/logging/logger_impl.dart';
import 'package:memox/core/services/file_picker_service.dart';
import 'package:memox/core/services/haptic_service.dart';
import 'package:memox/core/services/notification_service.dart';
import 'package:memox/core/services/share_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'service_providers.g.dart';

@Riverpod(keepAlive: true)
AppLogger appLogger(Ref ref) => const LoggerImpl();

@Riverpod(keepAlive: true)
GlobalErrorHandler globalErrorHandler(Ref ref) {
  return GlobalErrorHandler(ref.watch(appLoggerProvider));
}

@Riverpod(keepAlive: true)
NotificationService notificationService(Ref ref) {
  return const NoopNotificationService();
}

@Riverpod(keepAlive: true)
ShareService shareService(Ref ref) => const NoopShareService();

@Riverpod(keepAlive: true)
FilePickerService filePickerService(Ref ref) => const NoopFilePickerService();

@Riverpod(keepAlive: true)
HapticService hapticService(Ref ref) => const SystemHapticService();
