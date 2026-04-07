import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/settings/domain/entities/app_setting.dart';
import 'package:memox/features/settings/presentation/providers/settings_provider.dart';
import 'package:memox/features/settings/presentation/widgets/settings_choice_row.dart';
import 'package:memox/features/settings/presentation/widgets/settings_group_card.dart';
import 'package:memox/features/settings/presentation/widgets/settings_section_header.dart';
import 'package:memox/shared/widgets/buttons/app_pressable.dart';
import 'package:memox/shared/widgets/inputs/app_switch_tile.dart';
import 'package:memox/shared/widgets/layout/spacing.dart';

class SettingsNotificationsSection extends ConsumerWidget {
  const SettingsNotificationsSection({required this.settings, super.key});

  final AppSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminderTime =
        settings.reminderTime ?? AppSettings.defaultReminderTime;
    final formattedTime = MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(reminderTime);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionHeader(label: context.l10n.settingsNotificationsSection),
        const Gap.lg(),
        SettingsGroupCard(
          children: [
            _SettingsSwitchRow(
              label: context.l10n.settingsStudyReminderTitle,
              value: settings.studyReminder,
              onChanged: (value) => ref
                  .read(settingsProvider.notifier)
                  .updateStudyReminder(studyReminder: value),
            ),
            if (settings.studyReminder)
              SettingsChoiceRow(
                title: context.l10n.settingsReminderTimeTitle,
                valueLabel: formattedTime,
                onTap: () => _pickReminderTime(context, ref),
              ),
            _SettingsSwitchRow(
              label: context.l10n.settingsStreakReminderTitle,
              value: settings.streakReminder,
              onChanged: (value) => ref
                  .read(settingsProvider.notifier)
                  .updateStreakReminder(streakReminder: value),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickReminderTime(BuildContext context, WidgetRef ref) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: settings.reminderTime ?? AppSettings.defaultReminderTime,
    );

    if (selected == null) {
      return;
    }

    await ref.read(settingsProvider.notifier).updateReminderTime(selected);
  }
}

class _SettingsSwitchRow extends StatelessWidget {
  const _SettingsSwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => AppPressable(
    onTap: () => onChanged(!value),
    borderRadius: RadiusTokens.none,
    padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
    child: AppSwitchTile(label: label, value: value, onChanged: onChanged),
  );
}
