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
        sessionLimit:
            sharedPreferences.getInt(sessionLimitKey) ??
            AppSettings.defaults.sessionLimit,
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
    await sharedPreferences.setInt(sessionLimitKey, settings.sessionLimit);
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
}
