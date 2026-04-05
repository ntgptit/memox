import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/features/settings/domain/entities/app_setting.dart';
import 'package:memox/features/settings/presentation/providers/settings_provider.dart';
import 'package:memox/features/settings/presentation/widgets/settings_choice_row.dart';
import 'package:memox/shared/widgets/dialogs/choice_bottom_sheet.dart';

const String _systemSentinel = '__system__';

class SettingsLanguageRow extends ConsumerWidget {
  const SettingsLanguageRow({required this.settings, super.key});

  final AppSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) => SettingsChoiceRow(
    title: context.l10n.settingsLanguageTitle,
    valueLabel: _displayName(context, settings.localeCode),
    onTap: () => _pickLanguage(context, ref),
  );

  String _displayName(BuildContext context, String? code) => switch (code) {
    'en' => context.l10n.settingsLanguageEn,
    'ko' => context.l10n.settingsLanguageKo,
    'vi' => context.l10n.settingsLanguageVi,
    _ => context.l10n.settingsLanguageSystem,
  };

  Future<void> _pickLanguage(BuildContext context, WidgetRef ref) async {
    final selected = await showChoiceBottomSheet<String>(
      context,
      title: context.l10n.settingsLanguagePickerTitle,
      options: [
        ChoiceOption(
          value: _systemSentinel,
          title: context.l10n.settingsLanguageSystem,
          icon: Icons.brightness_auto_outlined,
        ),
        ChoiceOption(
          value: 'en',
          title: context.l10n.settingsLanguageEn,
          icon: Icons.language_outlined,
        ),
        ChoiceOption(
          value: 'ko',
          title: context.l10n.settingsLanguageKo,
          icon: Icons.language_outlined,
        ),
        ChoiceOption(
          value: 'vi',
          title: context.l10n.settingsLanguageVi,
          icon: Icons.language_outlined,
        ),
      ],
    );

    if (selected == null || !context.mounted) {
      return;
    }

    final localeCode = selected == _systemSentinel ? null : selected;
    await ref.read(settingsProvider.notifier).updateLocale(localeCode);
  }
}
