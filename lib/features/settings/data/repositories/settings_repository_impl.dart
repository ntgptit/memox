import 'package:flutter/material.dart';
import 'package:memox/core/logging/app_logger.dart';
import 'package:memox/features/settings/data/mappers/app_settings_mapper.dart';
import 'package:memox/features/settings/domain/entities/app_setting.dart';
import 'package:memox/features/settings/domain/repositories/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl({
    required Future<SharedPreferences> Function() sharedPreferencesLoader,
    required AppLogger logger,
  }) : _sharedPreferencesLoader = sharedPreferencesLoader,
       _logger = logger;

  final Future<SharedPreferences> Function() _sharedPreferencesLoader;
  final AppLogger _logger;

  @override
  Future<AppSettings> load() async {
    final sharedPreferences = await _sharedPreferencesLoader();
    return AppSettingsMapper.fromPreferences(sharedPreferences);
  }

  @override
  Future<void> save(AppSettings settings) async {
    final sharedPreferences = await _sharedPreferencesLoader();
    _logger.info('Persisting application settings');
    await AppSettingsMapper.toPreferences(sharedPreferences, settings);
  }

  @override
  Future<void> updateLocaleCode(String? localeCode) async {
    final settings = await load();
    await save(settings.copyWith(localeCode: localeCode));
  }

  @override
  Future<void> updateSeedColorValue(int seedColorValue) async {
    final settings = await load();
    await save(settings.copyWith(seedColorValue: seedColorValue));
  }

  @override
  Future<void> updateThemeMode(ThemeMode themeMode) async {
    final settings = await load();
    await save(settings.copyWith(themeMode: themeMode));
  }

  @override
  Future<void> updateDailyGoal(int dailyGoal) async {
    final settings = await load();
    await save(settings.copyWith(dailyGoal: dailyGoal));
  }

  @override
  Future<void> updateSessionLimitMinutes(int sessionLimitMinutes) async {
    final settings = await load();
    await save(settings.copyWith(sessionLimitMinutes: sessionLimitMinutes));
  }

  @override
  Future<void> updateAutoAdvanceDelay(double autoAdvanceDelay) async {
    final settings = await load();
    await save(settings.copyWith(autoAdvanceDelay: autoAdvanceDelay));
  }

  @override
  Future<void> updateStudyReminder({required bool studyReminder}) async {
    final settings = await load();
    await save(settings.copyWith(studyReminder: studyReminder));
  }

  @override
  Future<void> updateReminderTime(TimeOfDay? reminderTime) async {
    final settings = await load();
    await save(settings.copyWith(reminderTime: reminderTime));
  }

  @override
  Future<void> updateStreakReminder({required bool streakReminder}) async {
    final settings = await load();
    await save(settings.copyWith(streakReminder: streakReminder));
  }
}
