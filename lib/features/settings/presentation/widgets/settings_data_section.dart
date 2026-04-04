import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/features/settings/presentation/providers/settings_provider.dart';
import 'package:memox/features/settings/presentation/widgets/settings_action_row.dart';
import 'package:memox/features/settings/presentation/widgets/settings_group_card.dart';
import 'package:memox/features/settings/presentation/widgets/settings_section_header.dart';
import 'package:memox/shared/widgets/layout/spacing.dart';

class SettingsDataSection extends ConsumerWidget {
  const SettingsDataSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SettingsSectionHeader(label: context.l10n.settingsDataTitle),
      const Gap.lg(),
      SettingsGroupCard(
        children: [
          SettingsActionRow(
            title: context.l10n.settingsExportCardsAction,
            icon: Icons.ios_share_outlined,
            onTap: () => handleSettingsExport(context, ref),
          ),
          SettingsActionRow(
            title: context.l10n.settingsImportFromFileAction,
            icon: Icons.file_upload_outlined,
            onTap: () => handleSettingsImport(context, ref),
          ),
          SettingsActionRow(
            title: context.l10n.settingsClearHistoryAction,
            icon: Icons.delete_outline,
            titleColor: context.colors.error,
            onTap: () => handleSettingsClearHistory(context, ref),
          ),
        ],
      ),
    ],
  );
}

Future<void> handleSettingsClearHistory(
  BuildContext context,
  WidgetRef ref,
) async {
  final confirmed = await context.showConfirmDialog(
    title: context.l10n.settingsClearHistoryAction,
    message: context.l10n.settingsClearHistoryMessage,
    confirmText: context.l10n.deleteAction,
    isDestructive: true,
  );

  if (confirmed != true) {
    return;
  }

  final summary = await ref.read(settingsProvider.notifier).clearStudyHistory();

  if (!context.mounted) {
    return;
  }

  context.showSnackBar(
    context.l10n.settingsClearHistorySuccess(
      summary.sessionCount,
      summary.reviewCount,
    ),
  );
}

Future<void> handleSettingsExport(BuildContext context, WidgetRef ref) async {
  try {
    final fileName = await ref
        .read(settingsProvider.notifier)
        .exportCardsJson();

    if (!context.mounted) {
      return;
    }

    context.showSnackBar(context.l10n.settingsExportSuccess(fileName));
  } catch (_) {
    if (!context.mounted) {
      return;
    }

    context.showSnackBar(context.l10n.settingsExportFailed, isError: true);
  }
}

Future<void> handleSettingsImport(BuildContext context, WidgetRef ref) async {
  try {
    final summary = await ref.read(settingsProvider.notifier).importCardsJson();

    if (summary == null) {
      return;
    }

    if (!context.mounted) {
      return;
    }

    context.showSnackBar(
      context.l10n.settingsImportSuccess(
        summary.folderCount,
        summary.deckCount,
        summary.cardCount,
      ),
    );
  } catch (_) {
    if (!context.mounted) {
      return;
    }

    context.showSnackBar(context.l10n.settingsImportFailed, isError: true);
  }
}
