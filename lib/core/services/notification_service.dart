import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

abstract interface class NotificationService {
  Future<void> cancel(int id);

  Future<void> initialize();

  Future<void> scheduleDaily({
    required String body,
    required int id,
    required TimeOfDay time,
    required String title,
  });

  Future<void> show({required String title, required String body});
}

final class LocalNotificationService implements NotificationService {
  LocalNotificationService() : _plugin = FlutterLocalNotificationsPlugin();

  static const String _channelId = 'memox_study_reminders';
  static const String _channelName = 'Study reminders';
  static const String _channelDescription =
      'Daily study and streak reminders for MemoX';

  final FlutterLocalNotificationsPlugin _plugin;
  var _isInitialized = false;

  @override
  Future<void> cancel(int id) async {
    if (!_isSupportedPlatform) {
      return;
    }

    await initialize();
    await _plugin.cancel(id);
  }

  @override
  Future<void> initialize() async {
    if (_isInitialized || !_isSupportedPlatform) {
      return;
    }

    tz.initializeTimeZones();
    tz.setLocalLocation(_buildFixedOffsetLocation());
    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
        macOS: DarwinInitializationSettings(),
      ),
    );
    _isInitialized = true;
  }

  @override
  Future<void> scheduleDaily({
    required String body,
    required int id,
    required TimeOfDay time,
    required String title,
  }) async {
    if (!_isSupportedPlatform) {
      return;
    }

    await initialize();
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      _nextScheduledDate(time),
      _notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  @override
  Future<void> show({required String title, required String body}) async {
    if (!_isSupportedPlatform) {
      return;
    }

    await initialize();
    await _plugin.show(0, title, body, _notificationDetails);
  }

  tz.Location _buildFixedOffsetLocation() {
    final now = DateTime.now();
    final offset = now.timeZoneOffset.inMilliseconds;
    final abbreviation = now.timeZoneName;

    return tz.Location('device-local', <int>[0], <int>[0], <tz.TimeZone>[
      tz.TimeZone(offset, isDst: false, abbreviation: abbreviation),
    ]);
  }

  NotificationDetails get _notificationDetails => const NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
    ),
    iOS: DarwinNotificationDetails(),
    macOS: DarwinNotificationDetails(),
  );

  tz.TZDateTime _nextScheduledDate(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  bool get _isSupportedPlatform {
    if (kIsWeb) {
      return false;
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => true,
      TargetPlatform.iOS => true,
      TargetPlatform.macOS => true,
      _ => false,
    };
  }
}

final class NoopNotificationService implements NotificationService {
  const NoopNotificationService();

  @override
  Future<void> cancel(int id) async {}

  @override
  Future<void> initialize() async {}

  @override
  Future<void> scheduleDaily({
    required String body,
    required int id,
    required TimeOfDay time,
    required String title,
  }) async {}

  @override
  Future<void> show({required String title, required String body}) async {}
}
