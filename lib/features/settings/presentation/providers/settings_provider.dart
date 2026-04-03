import 'dart:async';

import 'package:flutter/material.dart';
import 'package:memox/core/providers/repository_providers.dart';
import 'package:memox/core/providers/service_providers.dart';
import 'package:memox/core/providers/usecase_providers.dart';
import 'package:memox/features/settings/domain/entities/app_setting.dart';
import 'package:memox/features/settings/domain/repositories/settings_data_repository.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_provider.g.dart';

const String settingsExportFileName = 'memox_export.json';
const int studyReminderNotificationId = 4100;
const int streakReminderNotificationId = 4101;

@Riverpod(keepAlive: true)
class Settings extends _$Settings {
  @override
  Future<AppSettings> build() async {
    final settings = await ref.watch(getSettingsUseCaseProvider).call();
    unawaited(_syncReminders(settings));
    return settings;
  }

  Future<String> exportCardsJson() async {
    final content = await ref
        .read(settingsDataRepositoryProvider)
        .exportCardsJson();
    final l10n = _localizedStrings(await _currentSettings());
    await ref
        .read(shareServiceProvider)
        .shareJson(
          content: content,
          fileName: settingsExportFileName,
          subject: l10n.settingsExportShareSubject,
        );
    return settingsExportFileName;
  }

  Future<SettingsImportSummary?> importCardsJson() async {
    final file = await ref
        .read(filePickerServiceProvider)
        .pickTextFile(allowedExtensions: const <String>['json']);

    if (file == null) {
      return null;
    }

    return ref
        .read(settingsDataRepositoryProvider)
        .importCardsJson(file.content);
  }

  Future<SettingsHistoryClearSummary> clearStudyHistory() =>
      ref.read(settingsDataRepositoryProvider).clearStudyHistory();

  Future<void> updateAutoAdvanceDelay(double autoAdvanceDelay) async {
    final current = await _currentSettings();
    await _persistSettings(
      current.copyWith(autoAdvanceDelay: autoAdvanceDelay),
    );
  }

  Future<void> updateDailyGoal(int dailyGoal) async {
    final current = await _currentSettings();
    final boundedGoal = dailyGoal.clamp(
      AppSettings.dailyGoalMin,
      AppSettings.dailyGoalMax,
    );
    await _persistSettings(current.copyWith(dailyGoal: boundedGoal));
  }

  Future<void> updateLocale(String? localeCode) async {
    final current = await _currentSettings();
    await _persistSettings(current.copyWith(localeCode: localeCode));
  }

  Future<void> updateReminderTime(TimeOfDay time) async {
    final current = await _currentSettings();
    await _persistSettings(
      current.copyWith(reminderTime: time, studyReminder: true),
    );
  }

  Future<void> updateSeedColor(int seedColorValue) async {
    final current = await _currentSettings();
    await _persistSettings(current.copyWith(seedColorValue: seedColorValue));
  }

  Future<void> updateSessionLimitMinutes(int sessionLimitMinutes) async {
    final current = await _currentSettings();

    if (!AppSettings.sessionLimitOptions.contains(sessionLimitMinutes)) {
      return;
    }

    await _persistSettings(
      current.copyWith(sessionLimitMinutes: sessionLimitMinutes),
    );
  }

  Future<void> updateStreakReminder({required bool streakReminder}) async {
    final current = await _currentSettings();
    await _persistSettings(current.copyWith(streakReminder: streakReminder));
  }

  Future<void> updateStudyReminder({required bool studyReminder}) async {
    final current = await _currentSettings();
    final reminderTime =
        current.reminderTime ?? AppSettings.defaultReminderTime;
    await _persistSettings(
      current.copyWith(
        studyReminder: studyReminder,
        reminderTime: studyReminder ? reminderTime : current.reminderTime,
      ),
    );
  }

  Future<void> updateThemeMode(ThemeMode themeMode) async {
    final current = await _currentSettings();
    await _persistSettings(current.copyWith(themeMode: themeMode));
  }

  Future<AppSettings> _currentSettings() async {
    final current = _asyncValueOrNull(state);

    if (current != null) {
      return current;
    }

    return future;
  }

  L10n _localizedStrings(AppSettings settings) => lookupL10n(
    settings.locale ?? WidgetsBinding.instance.platformDispatcher.locale,
  );

  Future<void> _persistSettings(AppSettings next) async {
    final previous = _asyncValueOrNull(state);
    state = AsyncValue<AppSettings>.data(next);

    try {
      await ref.read(settingsRepositoryProvider).save(next);
      await _syncReminders(next);
    } catch (_) {
      if (previous != null) {
        state = AsyncValue<AppSettings>.data(previous);
      }

      rethrow;
    }
  }

  Future<void> _syncReminders(AppSettings settings) async {
    final notificationService = ref.read(notificationServiceProvider);
    final l10n = _localizedStrings(settings);
    final reminderTime =
        settings.reminderTime ?? AppSettings.defaultReminderTime;

    if (!settings.studyReminder) {
      await notificationService.cancel(studyReminderNotificationId);
    }

    if (settings.studyReminder) {
      await notificationService.scheduleDaily(
        id: studyReminderNotificationId,
        title: l10n.settingsStudyReminderNotificationTitle,
        body: l10n.settingsStudyReminderNotificationBody(settings.dailyGoal),
        time: reminderTime,
      );
    }

    if (!settings.streakReminder) {
      await notificationService.cancel(streakReminderNotificationId);
    }

    if (settings.streakReminder) {
      await notificationService.scheduleDaily(
        id: streakReminderNotificationId,
        title: l10n.settingsStreakReminderNotificationTitle,
        body: l10n.settingsStreakReminderNotificationBody,
        time: reminderTime,
      );
    }
  }
}

T? _asyncValueOrNull<T>(AsyncValue<T> value) => switch (value) {
  AsyncData<T>(:final value) => value,
  _ => null,
};
