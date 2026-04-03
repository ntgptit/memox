import 'package:flutter/material.dart';
import 'package:memox/features/settings/domain/entities/app_setting.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract final class AppSettingsMapper {
  const AppSettingsMapper._();

  static const String themeModeKey = 'settings.theme_mode';
  static const String seedColorKey = 'settings.seed_color';
  static const String localeCodeKey = 'settings.locale_code';
  static const String syncEnabledKey = 'settings.sync_enabled';
  static const String dailyGoalKey = 'settings.daily_goal';
  static const String sessionLimitKey = 'settings.session_limit';
  static const String autoAdvanceDelayKey = 'settings.auto_advance_delay';
  static const String studyReminderKey = 'settings.study_reminder';
  static const String reminderHourKey = 'settings.reminder_hour';
  static const String reminderMinuteKey = 'settings.reminder_minute';
  static const String streakReminderKey = 'settings.streak_reminder';

  static AppSettings fromPreferences(SharedPreferences sharedPreferences) =>
      AppSettings(
        themeMode: parseThemeMode(sharedPreferences.getString(themeModeKey)),
        seedColorValue:
            sharedPreferences.getInt(seedColorKey) ??
            AppSettings.defaults.seedColorValue,
        localeCode: sharedPreferences.getString(localeCodeKey),
        syncEnabled: sharedPreferences.getBool(syncEnabledKey) ?? false,
        dailyGoal:
            sharedPreferences.getInt(dailyGoalKey) ??
            AppSettings.defaults.dailyGoal,
        sessionLimitMinutes:
            sharedPreferences.getInt(sessionLimitKey) ??
            AppSettings.defaults.sessionLimitMinutes,
        autoAdvanceDelay:
            sharedPreferences.getDouble(autoAdvanceDelayKey) ??
            AppSettings.defaults.autoAdvanceDelay,
        studyReminder:
            sharedPreferences.getBool(studyReminderKey) ??
            AppSettings.defaults.studyReminder,
        reminderTime: _readReminderTime(sharedPreferences),
        streakReminder:
            sharedPreferences.getBool(streakReminderKey) ??
            AppSettings.defaults.streakReminder,
      );

  static Future<void> toPreferences(
    SharedPreferences sharedPreferences,
    AppSettings settings,
  ) async {
    await sharedPreferences.setString(themeModeKey, settings.themeMode.name);
    await sharedPreferences.setInt(seedColorKey, settings.seedColorValue);
    await _writeLocaleCode(sharedPreferences, settings.localeCode);
    await sharedPreferences.setBool(syncEnabledKey, settings.syncEnabled);
    await sharedPreferences.setInt(dailyGoalKey, settings.dailyGoal);
    await sharedPreferences.setInt(
      sessionLimitKey,
      settings.sessionLimitMinutes,
    );
    await sharedPreferences.setDouble(
      autoAdvanceDelayKey,
      settings.autoAdvanceDelay,
    );
    await sharedPreferences.setBool(studyReminderKey, settings.studyReminder);
    await _writeReminderTime(sharedPreferences, settings.reminderTime);
    await sharedPreferences.setBool(streakReminderKey, settings.streakReminder);
  }

  static ThemeMode parseThemeMode(String? value) => switch (value) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  static Future<void> _writeLocaleCode(
    SharedPreferences sharedPreferences,
    String? localeCode,
  ) async {
    if (localeCode == null || localeCode.isEmpty) {
      await sharedPreferences.remove(localeCodeKey);
      return;
    }

    await sharedPreferences.setString(localeCodeKey, localeCode);
  }

  static TimeOfDay? _readReminderTime(SharedPreferences sharedPreferences) {
    final hour = sharedPreferences.getInt(reminderHourKey);
    final minute = sharedPreferences.getInt(reminderMinuteKey);

    if (hour == null || minute == null) {
      return null;
    }

    return TimeOfDay(hour: hour, minute: minute);
  }

  static Future<void> _writeReminderTime(
    SharedPreferences sharedPreferences,
    TimeOfDay? reminderTime,
  ) async {
    if (reminderTime == null) {
      await sharedPreferences.remove(reminderHourKey);
      await sharedPreferences.remove(reminderMinuteKey);
      return;
    }

    await sharedPreferences.setInt(reminderHourKey, reminderTime.hour);
    await sharedPreferences.setInt(reminderMinuteKey, reminderTime.minute);
  }
}
