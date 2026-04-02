import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';

enum ToastType { success, error, info }

mixin Toast {
  static void show(
    BuildContext context,
    String message, {
    ToastType type = ToastType.info,
  }) {
    final (backgroundColor, icon) = switch (type) {
      ToastType.success => (context.customColors.success, Icons.check_circle),
      ToastType.error => (context.customColors.ratingAgain, Icons.error_outline),
      ToastType.info => (context.colors.inverseSurface, Icons.info_outline),
    };
    final foregroundColor = _foregroundColor(context, backgroundColor);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        content: Row(
          children: [
            Icon(icon, color: foregroundColor),
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

  static Color _foregroundColor(BuildContext context, Color backgroundColor) {
    if (ThemeData.estimateBrightnessForColor(backgroundColor) == Brightness.dark) {
      return context.colors.surface;
    }

    return context.colors.onSurface;
  }
}
