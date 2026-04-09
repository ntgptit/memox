import 'package:flutter/material.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/shared/widgets/animations/scale_tap.dart';

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.fullWidth = true,
    this.height = SizeTokens.buttonHeight,
    this.color,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool fullWidth;
  final double height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = color ?? theme.colorScheme.primary;
    final backgroundColor =
        color?.withValues(alpha: OpacityTokens.focus) ??
        theme.colorScheme.surfaceContainerHigh;
    final borderColor =
        color?.withValues(alpha: OpacityTokens.focus) ??
        theme.colorScheme.outlineVariant.withValues(
          alpha: OpacityTokens.borderSubtle,
        );
    final child = OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: Size(0, height),
        backgroundColor: backgroundColor,
        foregroundColor: accentColor,
        side: BorderSide(color: borderColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.button),
        ),
      ),
      child: _SecondaryButtonChild(
        label: label,
        icon: icon,
        isLoading: isLoading,
        progressColor: accentColor,
      ),
    );
    final wrapped = ScaleTap(
      onTap: isLoading ? null : onPressed,
      scaleDown: 0.98,
      child: child,
    );

    if (!fullWidth) {
      return wrapped;
    }

    return SizedBox(width: double.infinity, child: wrapped);
  }
}

class _SecondaryButtonChild extends StatelessWidget {
  const _SecondaryButtonChild({
    required this.label,
    required this.icon,
    required this.isLoading,
    required this.progressColor,
  });

  final String label;
  final IconData? icon;
  final bool isLoading;
  final Color progressColor;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox.square(
        dimension: SizeTokens.iconSm,
        child: CircularProgressIndicator(
          strokeWidth: SizeTokens.borderWidth,
          color: progressColor,
        ),
      );
    }

    if (icon == null) {
      return Text(label);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: SizeTokens.iconSm),
        const SizedBox(width: SpacingTokens.buttonGap),
        Text(label),
      ],
    );
  }
}
