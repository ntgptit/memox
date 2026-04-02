import 'package:flutter/material.dart';
import 'package:memox/core/logging/app_logger.dart';
import 'package:memox/features/settings/domain/entities/app_setting.dart';
import 'package:memox/features/settings/domain/repositories/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl({
    required Future<SharedPreferences> Function() sharedPreferencesLoader,
    required AppLogger logger,
  })  : _sharedPreferencesLoader = sharedPreferencesLoader,
        _logger = logger;

  static const String _themeModeKey = 'settings.theme_mode';
  static const String _seedColorKey = 'settings.seed_color';
  static const String _localeCodeKey = 'settings.locale_code';
  static const String _syncEnabledKey = 'settings.sync_enabled';
  static const String _dailyGoalKey = 'settings.daily_goal';
  static const String _sessionLimitKey = 'settings.session_limit';

  final Future<SharedPreferences> Function() _sharedPreferencesLoader;
  final AppLogger _logger;

  @override
  Future<AppSettings> getSettings() async {
    final sharedPreferences = await _sharedPreferencesLoader();
    return AppSettings(
      themeMode: _parseThemeMode(
        sharedPreferences.getString(_themeModeKey),
      ),
      seedColorValue: sharedPreferences.getInt(_seedColorKey) ??
          AppSettings.defaults.seedColorValue,
      localeCode: sharedPreferences.getString(_localeCodeKey),
      syncEnabled: sharedPreferences.getBool(_syncEnabledKey) ?? false,
      dailyGoal: sharedPreferences.getInt(_dailyGoalKey) ?? 20,
      sessionLimit: sharedPreferences.getInt(_sessionLimitKey) ?? 20,
    );
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    final sharedPreferences = await _sharedPreferencesLoader();
    _logger.info('Persisting application settings');
    await sharedPreferences.setString(_themeModeKey, settings.themeMode.name);
    await sharedPreferences.setInt(_seedColorKey, settings.seedColorValue);

    final localeCode = settings.localeCode;

    if (localeCode == null || localeCode.isEmpty) {
      await sharedPreferences.remove(_localeCodeKey);
    }

    if (localeCode != null && localeCode.isNotEmpty) {
      await sharedPreferences.setString(_localeCodeKey, localeCode);
    }

    await sharedPreferences.setBool(_syncEnabledKey, settings.syncEnabled);
    await sharedPreferences.setInt(_dailyGoalKey, settings.dailyGoal);
    await sharedPreferences.setInt(_sessionLimitKey, settings.sessionLimit);
  }

  @override
  Future<void> updateLocaleCode(String? localeCode) async {
    final settings = await getSettings();
    await saveSettings(settings.copyWith(localeCode: localeCode));
  }

  @override
  Future<void> updateSeedColorValue(int seedColorValue) async {
    final settings = await getSettings();
    await saveSettings(settings.copyWith(seedColorValue: seedColorValue));
  }

  @override
  Future<void> updateThemeMode(ThemeMode themeMode) async {
    final settings = await getSettings();
    await saveSettings(settings.copyWith(themeMode: themeMode));
  }

  ThemeMode _parseThemeMode(String? value) {
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }
}
