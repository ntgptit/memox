import 'package:flutter/material.dart';

class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.seedColorValue = 0xFF5C6BC0,
    this.localeCode,
    this.syncEnabled = false,
    this.dailyGoal = 20,
    this.sessionLimit = 20,
  });

  final ThemeMode themeMode;
  final int seedColorValue;
  final String? localeCode;
  final bool syncEnabled;
  final int dailyGoal;
  final int sessionLimit;

  Color get seedColor => Color(seedColorValue);

  Locale? get locale {
    final code = localeCode;

    if (code == null || code.isEmpty) {
      return null;
    }

    return Locale(code);
  }

  AppSettings copyWith({
    ThemeMode? themeMode,
    int? seedColorValue,
    String? localeCode,
    bool? syncEnabled,
    int? dailyGoal,
    int? sessionLimit,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      seedColorValue: seedColorValue ?? this.seedColorValue,
      localeCode: localeCode ?? this.localeCode,
      syncEnabled: syncEnabled ?? this.syncEnabled,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      sessionLimit: sessionLimit ?? this.sessionLimit,
    );
  }

  static const AppSettings defaults = AppSettings();
}
