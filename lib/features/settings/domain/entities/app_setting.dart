import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_setting.freezed.dart';
part 'app_setting.g.dart';

@freezed
abstract class AppSettings with _$AppSettings {
  const AppSettings._();

  const factory AppSettings({
    @Default(ThemeMode.system) ThemeMode themeMode,
    @Default(0xFF5C6BC0) int seedColorValue,
    String? localeCode,
    @Default(false) bool syncEnabled,
    @Default(20) int dailyGoal,
    @Default(20) int sessionLimit,
  }) = _AppSettings;

  factory AppSettings.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsFromJson(json);

  Color get seedColor => Color(seedColorValue);

  Locale? get locale {
    final code = localeCode;

    if (code == null || code.isEmpty) {
      return null;
    }

    return Locale(code);
  }

  static const AppSettings defaults = AppSettings();
}
