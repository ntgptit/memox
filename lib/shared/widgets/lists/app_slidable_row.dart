import 'package:flutter/material.dart';
import 'package:memox/core/constants/app_strings.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/utils/color_utils.dart';

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
    confirmDismiss: (direction) => _handleDismiss(context, direction),
    background: _ActionBackground(
      alignment: Alignment.centerLeft,
      color: context.colors.primary,
      icon: Icons.edit_outlined,
    ),
    secondaryBackground: _ActionBackground(
      alignment: Alignment.centerRight,
      color: context.customColors.ratingAgain,
      icon: Icons.delete_outline,
    ),
    movementDuration: DurationTokens.slow,
    dismissThresholds: const {
      DismissDirection.startToEnd: 0.25,
      DismissDirection.endToStart: 0.25,
    },
    child: child,
  );

  Future<bool> _handleDismiss(
    BuildContext context,
    DismissDirection direction,
  ) async {
    if (direction == DismissDirection.startToEnd) {
      if (onEdit != null) {
        onEdit!();
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
        title: deleteLabel ?? AppStrings.deleteAction,
        message: deleteConfirmMessage ?? AppStrings.confirmDeleteMessage,
        confirmText: deleteLabel ?? AppStrings.deleteAction,
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
      onDelete!();
      return false;
    }

    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    final controller = messenger.showSnackBar(
      SnackBar(
        content: const Text(AppStrings.deletedMessage),
        duration: undoDuration,
        action: SnackBarAction(label: AppStrings.undoAction, onPressed: () {}),
      ),
    );
    final reason = await controller.closed;

    if (reason != SnackBarClosedReason.action) {
      onDelete!();
    }

    return false;
  }
}

class _ActionBackground extends StatelessWidget {
  const _ActionBackground({
    required this.alignment,
    required this.color,
    required this.icon,
  });

  final Alignment alignment;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: color.withValues(alpha: OpacityTokens.overlay),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: SizeTokens.touchTarget),
      child: Align(
        alignment: alignment,
        child: Icon(icon, color: AppColorUtils.foregroundOn(color)),
      ),
    ),
  );
}
