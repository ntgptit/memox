import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/folders/domain/entities/folder_delete_summary.dart';
import 'package:memox/shared/widgets/buttons/primary_button.dart';
import 'package:memox/shared/widgets/buttons/secondary_button.dart';
import 'package:memox/shared/widgets/dialogs/app_dialog.dart';

class DeleteFolderConfirmDialog extends StatelessWidget {
  const DeleteFolderConfirmDialog({required this.summary, super.key});

  final FolderDeleteSummary summary;

  @override
  Widget build(BuildContext context) => AppDialog(
    title: Text(context.l10n.deleteFolder),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.deleteFolderConfirm(summary.totalItemCount)),
        const SizedBox(height: SpacingTokens.lg),
        Text(
          context.l10n.folderDeleteBreakdown(
            summary.subfolderCount,
            summary.deckCount,
            summary.cardCount,
            summary.reviewCount,
          ),
        ),
      ],
    ),
    actions: [
      SecondaryButton(
        label: context.l10n.cancelAction,
        onPressed: () => context.pop(false),
        fullWidth: false,
      ),
      PrimaryButton(
        label: context.l10n.deleteAction,
        onPressed: () => context.pop(true),
        fullWidth: false,
        backgroundColor: context.colors.error,
        foregroundColor: context.colors.onError,
      ),
    ],
  );
}

Future<bool?> showDeleteFolderConfirmDialog(
  BuildContext context, {
  required FolderDeleteSummary summary,
}) => showDialog<bool>(
  context: context,
  builder: (_) => DeleteFolderConfirmDialog(summary: summary),
);
