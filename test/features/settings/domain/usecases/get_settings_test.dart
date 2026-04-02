import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/features/settings/domain/entities/app_setting.dart';
import 'package:memox/features/settings/domain/repositories/settings_repository.dart';
import 'package:memox/features/settings/domain/usecases/get_settings.dart';

void main() {
  test('get settings use case returns settings from repository', () async {
    final repository = _FakeSettingsRepository(
      const AppSettings(
        themeMode: ThemeMode.dark,
        seedColorValue: 0xFF4DB6AC,
        localeCode: 'vi',
        syncEnabled: true,
        dailyGoal: 30,
        sessionLimit: 15,
      ),
    );
    final useCase = GetSettingsUseCase(repository);

    final settings = await useCase.call();

    expect(settings.themeMode, ThemeMode.dark);
    expect(settings.seedColorValue, 0xFF4DB6AC);
    expect(settings.localeCode, 'vi');
    expect(settings.syncEnabled, isTrue);
    expect(settings.dailyGoal, 30);
    expect(settings.sessionLimit, 15);
  });
}

final class _FakeSettingsRepository implements SettingsRepository {
  const _FakeSettingsRepository(this._settings);

  final AppSettings _settings;

  @override
  Future<AppSettings> getSettings() async => _settings;

  @override
  Future<void> saveSettings(AppSettings settings) async {}

  @override
  Future<void> updateLocaleCode(String? localeCode) async {}

  @override
  Future<void> updateSeedColorValue(int seedColorValue) async {}

  @override
  Future<void> updateThemeMode(ThemeMode themeMode) async {}
}
