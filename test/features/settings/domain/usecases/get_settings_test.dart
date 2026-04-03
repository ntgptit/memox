import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/features/settings/domain/entities/app_setting.dart';
import 'package:memox/features/settings/domain/repositories/settings_repository.dart';
import 'package:memox/features/settings/domain/usecases/get_settings.dart';

void main() {
  test('get settings use case returns settings from repository', () async {
    const repository = _FakeSettingsRepository(
      AppSettings(
        themeMode: ThemeMode.dark,
        seedColorValue: 0xFF4DB6AC,
        localeCode: 'vi',
        syncEnabled: true,
        dailyGoal: 30,
      ),
    );
    const useCase = GetSettingsUseCase(repository);

    final settings = await useCase.call();

    expect(settings.themeMode, ThemeMode.dark);
    expect(settings.seedColorValue, 0xFF4DB6AC);
    expect(settings.localeCode, 'vi');
    expect(settings.syncEnabled, isTrue);
    expect(settings.dailyGoal, 30);
    expect(settings.sessionLimitMinutes, 15);
  });
}

final class _FakeSettingsRepository implements SettingsRepository {
  const _FakeSettingsRepository(this._settings);

  final AppSettings _settings;

  @override
  Future<AppSettings> load() async => _settings;

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
  Future<void> updateThemeMode(ThemeMode themeMode) async {}
}
