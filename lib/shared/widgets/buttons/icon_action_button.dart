import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';

class IconActionButton extends StatelessWidget {
  const IconActionButton({
    required this.icon,
    this.onTap,
    this.tooltip,
    this.size = SizeTokens.touchTarget,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final String? tooltip;
  final double size;

  @override
  Widget build(BuildContext context) => IconButton.outlined(
    onPressed: onTap,
    tooltip: tooltip,
    style: IconButton.styleFrom(minimumSize: Size.square(size)).copyWith(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return context.colors.surfaceContainer;
        }

        return context.colors.surfaceContainerHigh;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return context.colors.onSurface.withValues(
            alpha: OpacityTokens.disabledText,
          );
        }

        return context.colors.onSurface;
      }),
      side: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return BorderSide(
            color: context.colors.onSurface.withValues(
              alpha: OpacityTokens.borderSubtle,
            ),
          );
        }

        return BorderSide(
          color: context.colors.onSurface.withValues(
            alpha: OpacityTokens.selected,
          ),
        );
      }),
    ),
    icon: Icon(icon, size: SizeTokens.iconMd),
  );
}
