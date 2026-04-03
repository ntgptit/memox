import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/logging/logger_impl.dart';
import 'package:memox/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:memox/features/settings/domain/entities/app_setting.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('settings repository reads persisted preferences', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'settings.theme_mode': 'dark',
      'settings.seed_color': 0xFF4DB6AC,
      'settings.locale_code': 'vi',
      'settings.sync_enabled': true,
      'settings.daily_goal': 30,
      'settings.session_limit': 20,
      'settings.auto_advance_delay': 2.0,
      'settings.study_reminder': true,
      'settings.reminder_hour': 7,
      'settings.reminder_minute': 45,
      'settings.streak_reminder': false,
    });

    final repository = _buildRepository();
    final settings = await repository.load();

    expect(settings.themeMode, ThemeMode.dark);
    expect(settings.seedColorValue, 0xFF4DB6AC);
    expect(settings.localeCode, 'vi');
    expect(settings.syncEnabled, isTrue);
    expect(settings.dailyGoal, 30);
    expect(settings.sessionLimitMinutes, 20);
    expect(settings.autoAdvanceDelay, 2);
    expect(settings.studyReminder, isTrue);
    expect(settings.reminderTime, const TimeOfDay(hour: 7, minute: 45));
    expect(settings.streakReminder, isFalse);
  });

  test('settings persist across repository restart', () async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    final repository = _buildRepository();

    await repository.save(
      const AppSettings(
        themeMode: ThemeMode.light,
        seedColorValue: 0xFF81C784,
        dailyGoal: 40,
        sessionLimitMinutes: 30,
        autoAdvanceDelay: 3,
        studyReminder: true,
        reminderTime: TimeOfDay(hour: 21, minute: 15),
      ),
    );

    final reloaded = await _buildRepository().load();

    expect(reloaded.themeMode, ThemeMode.light);
    expect(reloaded.seedColorValue, 0xFF81C784);
    expect(reloaded.dailyGoal, 40);
    expect(reloaded.sessionLimitMinutes, 30);
    expect(reloaded.autoAdvanceDelay, 3);
    expect(reloaded.studyReminder, isTrue);
    expect(reloaded.reminderTime, const TimeOfDay(hour: 21, minute: 15));
    expect(reloaded.streakReminder, isTrue);
  });
}

SettingsRepositoryImpl _buildRepository() => const SettingsRepositoryImpl(
  sharedPreferencesLoader: SharedPreferences.getInstance,
  logger: LoggerImpl(),
);
