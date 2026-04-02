import 'package:flutter/material.dart';
import 'package:memox/core/constants/app_strings.dart';
import 'package:memox/core/providers/usecase_providers.dart';
import 'package:memox/features/settings/domain/entities/app_setting.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_provider.g.dart';

@Riverpod(keepAlive: true)
class Settings extends _$Settings {
  @override
  Future<AppSettings> build() async {
    return ref.watch(getSettingsUseCaseProvider).call();
  }

  Future<void> updateLocale(String? localeCode) async {
    await ref.read(updateLocaleUseCaseProvider).call(localeCode);
    ref.invalidateSelf();
    await future;
  }

  Future<void> updateSeedColor(int seedColorValue) async {
    await ref.read(updateSeedColorUseCaseProvider).call(seedColorValue);
    ref.invalidateSelf();
    await future;
  }

  Future<void> updateThemeMode(ThemeMode themeMode) async {
    await ref.read(updateThemeModeUseCaseProvider).call(themeMode);
    ref.invalidateSelf();
    await future;
  }
}

@riverpod
String settingsScreenTitle(Ref ref) => AppStrings.settingsTitle;
