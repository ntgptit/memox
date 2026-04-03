import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/features/settings/domain/entities/app_setting.dart';
import 'package:memox/features/settings/domain/repositories/settings_repository.dart';
import 'package:memox/features/settings/domain/usecases/update_theme_mode.dart';

void main() {
  test('update theme mode use case forwards mode to repository', () async {
    final repository = _MutableSettingsRepository();
    final useCase = UpdateThemeModeUseCase(repository);

    await useCase.call(ThemeMode.dark);

    expect(repository.themeMode, ThemeMode.dark);
  });
}

final class _MutableSettingsRepository implements SettingsRepository {
  ThemeMode? themeMode;

  @override
  Future<AppSettings> load() async => AppSettings.defaults;

  @override
  Future<void> save(AppSettings settings) async {}

  @override
  Future<void> updateAutoAdvanceDelay(double autoAdvanceDelay) async {}

  @override
  Future<void> updateDailyGoal(int dailyGoal) async {}

  @override
  Future<void> updateLocaleCode(String? localeCode) async {}

  @override
  Future<void> updateReminderTime(TimeOfDay? reminderTime) async {}

  @override
  Future<void> updateSeedColorValue(int seedColorValue) async {}

  @override
  Future<void> updateSessionLimitMinutes(int sessionLimitMinutes) async {}

  @override
  Future<void> updateStreakReminder({required bool streakReminder}) async {}

  @override
  Future<void> updateStudyReminder({required bool studyReminder}) async {}

  @override
  Future<void> updateThemeMode(ThemeMode nextThemeMode) async {
    themeMode = nextThemeMode;
  }
}
