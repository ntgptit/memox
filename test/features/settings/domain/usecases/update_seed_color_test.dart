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
  Future<AppSettings> getSettings() async => const AppSettings();

  @override
  Future<void> saveSettings(AppSettings settings) async {}

  @override
  Future<void> updateLocaleCode(String? localeCode) async {}

  @override
  Future<void> updateSeedColorValue(int nextSeedColorValue) async {
    seedColorValue = nextSeedColorValue;
  }

  @override
  Future<void> updateThemeMode(ThemeMode themeMode) async {}
}
