import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';

class InfoBar extends StatelessWidget {
  const InfoBar({
    required this.icon,
    required this.text,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => AppCard(
    onTap: onTap,
    backgroundColor: context.colors.surfaceContainerLow,
    borderRadius: RadiusTokens.md,
    leftBorderColor: context.colors.primary,
    padding: const EdgeInsets.symmetric(
      horizontal: SpacingTokens.lg,
      vertical: SpacingTokens.md,
    ),
    child: Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: context.colors.primary.withValues(
              alpha: OpacityTokens.softTint,
            ),
            borderRadius: BorderRadius.circular(RadiusTokens.input),
          ),
          child: SizedBox.square(
            dimension: SizeTokens.touchTarget,
            child: Center(
              child: Icon(
                icon,
                size: SizeTokens.iconSm,
                color: context.colors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: SpacingTokens.lg),
        Expanded(child: Text(text, style: context.textTheme.bodyMedium)),
      ],
    ),
  );
}
