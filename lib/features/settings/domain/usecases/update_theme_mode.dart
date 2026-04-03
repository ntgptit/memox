import 'package:flutter/material.dart';
import 'package:memox/features/settings/domain/repositories/settings_repository.dart';

final class UpdateThemeModeUseCase {
  const UpdateThemeModeUseCase(this._repository);

  final SettingsRepository _repository;

  Future<void> call(ThemeMode themeMode) => _repository.updateThemeMode(themeMode);
}
