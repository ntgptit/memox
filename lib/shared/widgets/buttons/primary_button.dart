import 'package:flutter/material.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/shared/widgets/animations/scale_tap.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.fullWidth = true,
    this.height = SizeTokens.buttonHeightLg,
    this.backgroundColor,
    this.foregroundColor,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool fullWidth;
  final double height;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final progressColor =
        foregroundColor ?? Theme.of(context).colorScheme.onPrimary;
    final child = FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: FilledButton.styleFrom(
        minimumSize: Size(0, height),
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.button),
        ),
      ),
      child: _ButtonChild(
        label: label,
        icon: icon,
        isLoading: isLoading,
        progressColor: progressColor,
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

class _ButtonChild extends StatelessWidget {
  const _ButtonChild({
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
