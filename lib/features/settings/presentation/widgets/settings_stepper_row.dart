import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/shared/widgets/buttons/icon_action_button.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';

class SettingsStepperRow extends StatelessWidget {
  const SettingsStepperRow({
    required this.title,
    required this.valueLabel,
    required this.onDecrease,
    required this.onIncrease,
    this.canDecrease = true,
    this.canIncrease = true,
    super.key,
  });

  final String title;
  final String valueLabel;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;
  final bool canDecrease;
  final bool canIncrease;

  @override
  Widget build(BuildContext context) => AppCard(
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
          IconActionButton(
            icon: Icons.remove_outlined,
            onTap: canDecrease ? onDecrease : null,
            size: SizeTokens.buttonHeightSm,
          ),
          const SizedBox(width: SpacingTokens.sm),
          IconActionButton(
            icon: Icons.add_outlined,
            onTap: canIncrease ? onIncrease : null,
            size: SizeTokens.buttonHeightSm,
          ),
        ],
      ),
    ),
  );
}
