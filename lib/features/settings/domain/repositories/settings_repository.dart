import 'package:flutter/material.dart';
import 'package:memox/features/settings/domain/entities/app_setting.dart';

abstract interface class SettingsRepository {
  Future<AppSettings> getSettings();

  Future<void> saveSettings(AppSettings settings);

  Future<void> updateThemeMode(ThemeMode themeMode);

  Future<void> updateSeedColorValue(int seedColorValue);

  Future<void> updateLocaleCode(String? localeCode);
}
