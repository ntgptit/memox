import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';

class SettingsChoiceRow extends StatelessWidget {
  const SettingsChoiceRow({
    required this.title,
    required this.valueLabel,
    required this.onTap,
    super.key,
  });

  final String title;
  final String valueLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AppCard(
    onTap: onTap,
    padding: const EdgeInsets.symmetric(
      horizontal: SpacingTokens.lg,
      vertical: SpacingTokens.md,
    ),
    child: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: SizeTokens.listItemCompact),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: context.textTheme.titleMedium),
                const SizedBox(height: SpacingTokens.xs),
                Text(valueLabel, style: context.textTheme.bodySmall),
              ],
            ),
          ),
          Icon(
            Icons.expand_more_outlined,
            color: context.colors.onSurfaceVariant,
          ),
        ],
      ),
    ),
  );
}
