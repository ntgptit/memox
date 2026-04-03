import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/features/settings/domain/entities/app_setting.dart';
import 'package:memox/features/settings/domain/repositories/settings_repository.dart';
import 'package:memox/features/settings/domain/usecases/update_seed_color.dart';

void main() {
  test('update seed color use case forwards color to repository', () async {
    final repository = _MutableSettingsRepository();
    final useCase = UpdateSeedColorUseCase(repository);

    await useCase.call(0xFF4DB6AC);

    expect(repository.seedColorValue, 0xFF4DB6AC);
  });
}

final class _MutableSettingsRepository implements SettingsRepository {
  int? seedColorValue;

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
  Future<void> updateSeedColorValue(int nextSeedColorValue) async {
    seedColorValue = nextSeedColorValue;
  }

  @override
  Future<void> updateSessionLimitMinutes(int sessionLimitMinutes) async {}

  @override
  Future<void> updateStreakReminder({required bool streakReminder}) async {}

  @override
  Future<void> updateStudyReminder({required bool studyReminder}) async {}

  @override
  Future<void> updateThemeMode(ThemeMode themeMode) async {}
}
