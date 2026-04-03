import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/features/settings/domain/entities/app_setting.dart';
import 'package:memox/features/settings/presentation/providers/settings_provider.dart';
import 'package:memox/features/settings/presentation/widgets/settings_choice_row.dart';
import 'package:memox/features/settings/presentation/widgets/settings_section_header.dart';
import 'package:memox/features/settings/presentation/widgets/settings_stepper_row.dart';
import 'package:memox/shared/widgets/dialogs/choice_bottom_sheet.dart';
import 'package:memox/shared/widgets/layout/spacing.dart';

class SettingsStudyingSection extends ConsumerWidget {
  const SettingsStudyingSection({required this.settings, super.key});

  final AppSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SettingsSectionHeader(label: context.l10n.settingsStudyingSection),
      const Gap.lg(),
      SettingsStepperRow(
        title: context.l10n.settingsDailyGoalTitle,
        valueLabel: context.l10n.settingsGoalValue(settings.dailyGoal),
        canDecrease: settings.dailyGoal > AppSettings.dailyGoalMin,
        canIncrease: settings.dailyGoal < AppSettings.dailyGoalMax,
        onDecrease: () => ref
            .read(settingsProvider.notifier)
            .updateDailyGoal(settings.dailyGoal - AppSettings.dailyGoalStep),
        onIncrease: () => ref
            .read(settingsProvider.notifier)
            .updateDailyGoal(settings.dailyGoal + AppSettings.dailyGoalStep),
      ),
      const Gap.md(),
      SettingsStepperRow(
        title: context.l10n.settingsSessionLimitTitle,
        valueLabel: context.l10n.settingsSessionLimitValue(
          settings.sessionLimitMinutes,
        ),
        canDecrease: canDecreaseSessionLimit(settings.sessionLimitMinutes),
        canIncrease: canIncreaseSessionLimit(settings.sessionLimitMinutes),
        onDecrease: () =>
            shiftSessionLimit(ref, settings.sessionLimitMinutes, -1),
        onIncrease: () =>
            shiftSessionLimit(ref, settings.sessionLimitMinutes, 1),
      ),
      const Gap.md(),
      SettingsChoiceRow(
        title: context.l10n.settingsAutoAdvanceTitle,
        valueLabel: context.l10n.settingsAutoAdvanceValue(
          settings.autoAdvanceDelay.toStringAsFixed(1),
        ),
        onTap: () => pickAutoAdvance(context, ref),
      ),
    ],
  );
}

bool canDecreaseSessionLimit(int current) =>
    AppSettings.sessionLimitOptions.indexOf(current) > 0;

bool canIncreaseSessionLimit(int current) {
  final index = AppSettings.sessionLimitOptions.indexOf(current);
  return index >= 0 && index < AppSettings.sessionLimitOptions.length - 1;
}

Future<void> pickAutoAdvance(BuildContext context, WidgetRef ref) async {
  final selected = await showChoiceBottomSheet<double>(
    context,
    title: context.l10n.settingsAutoAdvancePickerTitle,
    options: AppSettings.autoAdvanceDelayOptions
        .map(
          (value) => ChoiceOption<double>(
            value: value,
            title: context.l10n.settingsAutoAdvanceValue(
              value.toStringAsFixed(1),
            ),
          ),
        )
        .toList(),
  );

  if (selected == null) {
    return;
  }

  await ref.read(settingsProvider.notifier).updateAutoAdvanceDelay(selected);
}

Future<void> shiftSessionLimit(WidgetRef ref, int current, int delta) async {
  final currentIndex = AppSettings.sessionLimitOptions.indexOf(current);

  if (currentIndex == -1) {
    return;
  }

  final nextIndex = currentIndex + delta;

  if (nextIndex < 0 || nextIndex >= AppSettings.sessionLimitOptions.length) {
    return;
  }

  await ref
      .read(settingsProvider.notifier)
      .updateSessionLimitMinutes(AppSettings.sessionLimitOptions[nextIndex]);
}
