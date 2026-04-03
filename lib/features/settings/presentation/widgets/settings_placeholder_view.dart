import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/providers/service_providers.dart';
import 'package:memox/core/services/database_export_service.dart';
import 'package:memox/shared/widgets/feedback/empty_state_view.dart';
import 'package:memox/shared/widgets/feedback/toast.dart';

class SettingsPlaceholderView extends ConsumerWidget {
  const SettingsPlaceholderView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exportService = ref.watch(databaseExportServiceProvider);
    return EmptyStateView(
      icon: Icons.settings_outlined,
      title: context.l10n.settingsTitle,
      subtitle: context.l10n.settingsSubtitle,
      actionLabel: exportService.isSupported
          ? context.l10n.exportDatabaseAction
          : null,
      onAction: exportService.isSupported
          ? () => _exportDatabase(context, ref)
          : null,
    );
  }

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
    DatabaseExportFailureReason.unexpected =>
      context.l10n.databaseExportFailed,
  };
}
