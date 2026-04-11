import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    required this.value,
    required this.label,
    this.valueColor,
    this.icon,
    super.key,
  });

  final String value;
  final String label;
  final Color? valueColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final accentColor = valueColor ?? context.colors.primary;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            DecoratedBox(
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: OpacityTokens.softTint),
                border: Border.all(
                  color: accentColor.withValues(
                    alpha: OpacityTokens.borderSubtle,
                  ),
                ),
                borderRadius: BorderRadius.circular(RadiusTokens.lg),
              ),
              child: SizedBox.square(
                dimension: SizeTokens.touchTarget,
                child: Icon(icon, color: accentColor, size: SizeTokens.iconMd),
              ),
            ),
            const SizedBox(height: SpacingTokens.md),
          ],
          Text(
            value,
            style: context.appTextStyles.statNumberMd.copyWith(
              color: accentColor,
            ),
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(label, style: context.appTextStyles.statLabel),
        ],
      ),
    );
  }
}
