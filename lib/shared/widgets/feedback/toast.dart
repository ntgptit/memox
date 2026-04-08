import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';

enum ToastType { success, error, info }

mixin Toast {
  static void show(
    BuildContext context,
    String message, {
    ToastType type = ToastType.info,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final (iconColor, icon) = switch (type) {
      ToastType.success => (
        context.customColors.success,
        Icons.check_circle_outline,
      ),
      ToastType.error => (context.colors.error, Icons.error_outline),
      ToastType.info => (context.colors.inversePrimary, Icons.info_outline),
    };
    final backgroundColor = context.colors.inverseSurface;
    final foregroundColor = context.colors.onInverseSurface;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: backgroundColor,
          action: actionLabel == null || onAction == null
              ? null
              : SnackBarAction(label: actionLabel, onPressed: onAction),
          content: Row(
            children: [
              Icon(icon, color: iconColor),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(
                child: Text(
                  message,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: foregroundColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
