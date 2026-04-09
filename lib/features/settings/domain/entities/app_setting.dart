import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_setting.freezed.dart';
part 'app_setting.g.dart';

@freezed
abstract class AppSettings with _$AppSettings {
  const factory AppSettings({
    @Default(ThemeMode.system) ThemeMode themeMode,
    @Default(0xFF24389C) int seedColorValue,
    String? localeCode,
    @Default(false) bool syncEnabled,
    @Default(20) int dailyGoal,
    @Default(15) int sessionLimitMinutes,
    @Default(1.5) double autoAdvanceDelay,
    @Default(false) bool studyReminder,
    @TimeOfDayConverter() TimeOfDay? reminderTime,
    @Default(true) bool streakReminder,
  }) = _AppSettings;
  const AppSettings._();

  factory AppSettings.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsFromJson(json);

  static const int dailyGoalMin = 10;
  static const int dailyGoalMax = 200;
  static const int dailyGoalStep = 10;
  static const List<int> sessionLimitOptions = <int>[5, 10, 15, 20, 30];
  static const List<double> autoAdvanceDelayOptions = <double>[1, 1.5, 2, 3];
  static const TimeOfDay defaultReminderTime = TimeOfDay(hour: 20, minute: 0);
  Color get seedColor => Color(seedColorValue);

  Duration get autoAdvanceDuration =>
      Duration(milliseconds: (autoAdvanceDelay * 1000).round());

  Locale? get locale {
    final code = localeCode;

    if (code == null || code.isEmpty) {
      return null;
    }

    return Locale(code);
  }

  static const AppSettings defaults = AppSettings();
}

class TimeOfDayConverter
    implements JsonConverter<TimeOfDay?, Map<String, dynamic>?> {
  const TimeOfDayConverter();

  @override
  TimeOfDay? fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }

    final hour = json['hour'];
    final minute = json['minute'];

    if (hour is! int || minute is! int) {
      return null;
    }

    return TimeOfDay(hour: hour, minute: minute);
  }

  @override
  Map<String, dynamic>? toJson(TimeOfDay? object) {
    if (object == null) {
      return null;
    }

    return <String, dynamic>{'hour': object.hour, 'minute': object.minute};
  }
}
