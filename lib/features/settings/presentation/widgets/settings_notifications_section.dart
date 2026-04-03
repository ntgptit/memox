import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/features/settings/domain/entities/app_setting.dart';
import 'package:memox/features/settings/presentation/providers/settings_provider.dart';
import 'package:memox/features/settings/presentation/widgets/settings_action_row.dart';
import 'package:memox/features/settings/presentation/widgets/settings_section_header.dart';
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
        AppSwitchTile(
          label: context.l10n.settingsStudyReminderTitle,
          value: settings.studyReminder,
          onChanged: (value) => ref
              .read(settingsProvider.notifier)
              .updateStudyReminder(studyReminder: value),
        ),
        if (settings.studyReminder) ...[
          const Gap.md(),
          SettingsActionRow(
            title: '${context.l10n.settingsReminderTimeTitle} · $formattedTime',
            icon: Icons.schedule_outlined,
            onTap: () => _pickReminderTime(context, ref),
          ),
        ],
        const Gap.md(),
        AppSwitchTile(
          label: context.l10n.settingsStreakReminderTitle,
          value: settings.streakReminder,
          onChanged: (value) => ref
              .read(settingsProvider.notifier)
              .updateStreakReminder(streakReminder: value),
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
