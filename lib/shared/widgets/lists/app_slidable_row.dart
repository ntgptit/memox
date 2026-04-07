import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';

class AppSlidableRow extends StatelessWidget {
  const AppSlidableRow({
    required this.child,
    this.onDelete,
    this.deleteLabel,
    this.confirmDelete = true,
    this.deleteConfirmMessage,
    this.onEdit,
    this.onArchive,
    this.showUndoSnackbar = true,
    this.undoDuration = DurationTokens.toast,
    super.key,
  });

  final Widget child;
  final VoidCallback? onDelete;
  final String? deleteLabel;
  final bool confirmDelete;
  final String? deleteConfirmMessage;
  final VoidCallback? onEdit;
  final VoidCallback? onArchive;
  final bool showUndoSnackbar;
  final Duration undoDuration;

  @override
  Widget build(BuildContext context) => Dismissible(
    key: key ?? child.key ?? ValueKey<Object>(child),
    confirmDismiss: (direction) => _handleRowDismiss(
      context: context,
      direction: direction,
      onDelete: onDelete,
      deleteLabel: deleteLabel,
      confirmDelete: confirmDelete,
      deleteConfirmMessage: deleteConfirmMessage,
      onEdit: onEdit,
      onArchive: onArchive,
      showUndoSnackbar: showUndoSnackbar,
      undoDuration: undoDuration,
    ),
    background: _ActionBackground(
      alignment: Alignment.centerLeft,
      color: context.colors.surfaceContainerHighest,
      icon: Icons.edit_outlined,
      iconColor: context.colors.onSurface,
    ),
    secondaryBackground: _ActionBackground(
      alignment: Alignment.centerRight,
      color: context.colors.errorContainer,
      icon: Icons.delete_outline,
      iconColor: context.colors.onErrorContainer,
    ),
    movementDuration: DurationTokens.slow,
    dismissThresholds: const {
      DismissDirection.startToEnd: 0.25,
      DismissDirection.endToStart: 0.25,
    },
    child: child,
  );
}

Future<bool> _handleRowDismiss({
  required BuildContext context,
  required DismissDirection direction,
  required VoidCallback? onDelete,
  required String? deleteLabel,
  required bool confirmDelete,
  required String? deleteConfirmMessage,
  required VoidCallback? onEdit,
  required VoidCallback? onArchive,
  required bool showUndoSnackbar,
  required Duration undoDuration,
}) async {
  if (direction == DismissDirection.startToEnd) {
    if (onEdit != null) {
      onEdit();
      return false;
    }

    onArchive?.call();
    return false;
  }

  if (onDelete == null) {
    return false;
  }

  if (confirmDelete) {
    final confirmed = await context.showConfirmDialog(
      title: deleteLabel ?? context.l10n.deleteAction,
      message: deleteConfirmMessage ?? context.l10n.confirmDeleteMessage,
      confirmText: deleteLabel ?? context.l10n.deleteAction,
      isDestructive: true,
    );

    if (confirmed != true) {
      return false;
    }
  }

  if (!context.mounted) {
    return false;
  }

  if (!showUndoSnackbar) {
    onDelete();
    return false;
  }

  final reason = await _showUndoDeleteSnackBar(context, undoDuration);

  if (reason != SnackBarClosedReason.action) {
    onDelete();
  }

  return false;
}

Future<SnackBarClosedReason> _showUndoDeleteSnackBar(
  BuildContext context,
  Duration duration,
) {
  final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
  final controller = messenger.showSnackBar(
    SnackBar(
      content: Text(context.l10n.deletedMessage),
      duration: duration,
      action: SnackBarAction(label: context.l10n.undoAction, onPressed: () {}),
    ),
  );

  return controller.closed;
}

class _ActionBackground extends StatelessWidget {
  const _ActionBackground({
    required this.alignment,
    required this.color,
    required this.icon,
    required this.iconColor,
  });

  final Alignment alignment;
  final Color color;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: color.withValues(alpha: OpacityTokens.overlay),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: SizeTokens.touchTarget),
      child: Align(
        alignment: alignment,
        child: Icon(icon, color: iconColor),
      ),
    ),
  );
}
