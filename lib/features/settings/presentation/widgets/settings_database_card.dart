import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/providers/service_providers.dart';
import 'package:memox/core/services/database_export_service.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/shared/widgets/buttons/secondary_button.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';
import 'package:memox/shared/widgets/feedback/toast.dart';

class SettingsDatabaseCard extends ConsumerWidget {
  const SettingsDatabaseCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.settingsDataTitle,
          style: context.textTheme.titleMedium,
        ),
        const SizedBox(height: SpacingTokens.sm),
        Text(
          context.l10n.settingsDataSubtitle,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: SpacingTokens.lg),
        SecondaryButton(
          label: context.l10n.exportDatabaseAction,
          icon: Icons.download_outlined,
          onPressed: () => _exportDatabase(context, ref),
        ),
      ],
    ),
  );

  Future<void> _exportDatabase(BuildContext context, WidgetRef ref) async {
    final result = await ref
        .read(databaseExportServiceProvider)
        .exportCurrentDatabase();

    if (!context.mounted) {
      return;
    }

    switch (result) {
      case DatabaseExportSuccess(:final fileName):
        Toast.show(
          context,
          context.l10n.databaseExportSuccess(fileName),
          type: ToastType.success,
        );
      case DatabaseExportFailure(:final reason):
        context.showSnackBar(_failureMessage(context, reason), isError: true);
    }
  }

  String _failureMessage(
    BuildContext context,
    DatabaseExportFailureReason reason,
  ) => switch (reason) {
    DatabaseExportFailureReason.unsupported =>
      context.l10n.databaseExportUnsupported,
    DatabaseExportFailureReason.unavailable =>
      context.l10n.databaseExportUnavailable,
    DatabaseExportFailureReason.unexpected => context.l10n.databaseExportFailed,
  };
}
