import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
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
  Widget build(BuildContext context) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(icon, color: valueColor),
          const SizedBox(height: SpacingTokens.sm),
        ],
        Text(
          value,
          style: context.appTextStyles.statNumberSm.copyWith(color: valueColor),
        ),
        const SizedBox(height: SpacingTokens.xs),
        Text(label, style: context.appTextStyles.statLabel),
      ],
    ),
  );
}
