import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/logging/logger_impl.dart';
import 'package:memox/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:memox/features/settings/domain/usecases/get_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('get settings use case reads persisted app preferences', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'settings.theme_mode': 'dark',
      'settings.seed_color': 0xFF4DB6AC,
      'settings.locale_code': 'vi',
      'settings.sync_enabled': true,
      'settings.daily_goal': 30,
      'settings.session_limit': 15,
    });

    final repository = SettingsRepositoryImpl(
      sharedPreferencesLoader: SharedPreferences.getInstance,
      logger: const LoggerImpl(),
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
