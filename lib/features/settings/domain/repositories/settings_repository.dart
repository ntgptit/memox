import 'package:flutter/material.dart';
import 'package:memox/features/settings/domain/entities/app_setting.dart';

abstract interface class SettingsRepository {
  Future<AppSettings> load();

  Future<void> save(AppSettings settings);

  Future<void> updateThemeMode(ThemeMode themeMode);

  Future<void> updateSeedColorValue(int seedColorValue);

  Future<void> updateDailyGoal(int dailyGoal);

  Future<void> updateSessionLimitMinutes(int sessionLimitMinutes);

  Future<void> updateAutoAdvanceDelay(double autoAdvanceDelay);

  Future<void> updateStudyReminder({required bool studyReminder});

  Future<void> updateReminderTime(TimeOfDay? reminderTime);

  Future<void> updateStreakReminder({required bool streakReminder});

  Future<void> updateLocaleCode(String? localeCode);
}
