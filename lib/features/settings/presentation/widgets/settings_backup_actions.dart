import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/backup/backup_data.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/providers/backup_providers.dart';
import 'package:memox/features/settings/presentation/widgets/backup_list_sheet.dart';

Future<void> handleBackupToDrive(BuildContext context, WidgetRef ref) async {
  try {
    final result = await ref.read(backupServiceProvider).backupToDrive();

    if (!context.mounted) {
      return;
    }

    switch (result) {
      case BackupSuccess():
        context.showSnackBar(context.l10n.settingsBackupSuccess);
      case BackupFailure(:final message):
        context.showSnackBar(message, isError: true);
    }
  } catch (_) {
    if (!context.mounted) {
      return;
    }

    context.showSnackBar(context.l10n.settingsBackupFailed, isError: true);
  }
}

Future<void> handleShowBackupList(BuildContext context, WidgetRef ref) async {
  try {
    final backups = await ref.read(backupServiceProvider).listDriveBackups();

    if (!context.mounted) {
      return;
    }

    if (backups.isEmpty) {
      context.showSnackBar(context.l10n.settingsNoBackups);
      return;
    }

    final selectedId = await showBackupListSheet(context, backups: backups);

    if (selectedId == null || !context.mounted) {
      return;
    }

    await _confirmAndRestore(context, ref, selectedId);
  } catch (_) {
    if (!context.mounted) {
      return;
    }

    context.showSnackBar(context.l10n.settingsRestoreFailed, isError: true);
  }
}

Future<void> _confirmAndRestore(
  BuildContext context,
  WidgetRef ref,
  String fileId,
) async {
  final confirmed = await context.showConfirmDialog(
    title: context.l10n.settingsRestoreConfirmTitle,
    message: context.l10n.settingsRestoreConfirmMessage,
    confirmText: context.l10n.settingsRestoreAction,
    isDestructive: true,
  );

  if (confirmed != true || !context.mounted) {
    return;
  }

  final result = await ref.read(backupServiceProvider).restoreFromDrive(fileId);

  if (!context.mounted) {
    return;
  }

  switch (result) {
    case ImportSuccess(:final folders, :final decks, :final cards):
      context.showSnackBar(
        context.l10n.settingsRestoreSuccess(folders, decks, cards),
      );
    case ImportFailure(:final message):
      context.showSnackBar(message, isError: true);
  }
}
