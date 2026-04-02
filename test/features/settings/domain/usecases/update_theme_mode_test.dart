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
  Future<AppSettings> getSettings() async => const AppSettings();

  @override
  Future<void> saveSettings(AppSettings settings) async {}

  @override
  Future<void> updateLocaleCode(String? localeCode) async {}

  @override
  Future<void> updateSeedColorValue(int seedColorValue) async {}

  @override
  Future<void> updateThemeMode(ThemeMode nextThemeMode) async {
    themeMode = nextThemeMode;
  }
}
