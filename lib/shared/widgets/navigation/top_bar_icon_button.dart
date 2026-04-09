import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';

class TopBarIconButton extends StatelessWidget {
  const TopBarIconButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.alignment = Alignment.center,
    this.slotWidth = SizeTokens.touchTarget,
    super.key,
  });

  static const double balancedSlotWidth =
      SizeTokens.touchTarget + SpacingTokens.xxxl;

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final Alignment alignment;
  final double slotWidth;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: slotWidth,
    child: Align(
      alignment: alignment,
      child: IconButton(
        style: IconButton.styleFrom(
          backgroundColor: context.colors.surfaceContainerLow,
          foregroundColor: context.colors.onSurfaceVariant,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RadiusTokens.input),
            side: BorderSide(
              color: context.colors.outlineVariant.withValues(
                alpha: OpacityTokens.borderSubtle,
              ),
            ),
          ),
        ),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(
          width: SizeTokens.touchTarget,
          height: SizeTokens.touchTarget,
        ),
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon),
      ),
    ),
  );
}
