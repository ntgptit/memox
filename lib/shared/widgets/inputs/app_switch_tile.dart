import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';

class AppSwitchTile extends StatelessWidget {
  const AppSwitchTile({
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
    super.key,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => AppCard(
    onTap: () => onChanged(!value),
    backgroundColor: context.customColors.surfaceDim,
    borderColor: context.colors.outline.withValues(
      alpha: OpacityTokens.borderSubtle,
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: SpacingTokens.lg,
      vertical: SpacingTokens.md,
    ),
    child: Row(
      children: [
        Expanded(
          child: subtitle == null
              ? Text(label, style: context.textTheme.titleMedium)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: context.textTheme.titleMedium),
                    const SizedBox(height: SpacingTokens.xs),
                    Text(
                      subtitle!,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
        ),
        Switch.adaptive(value: value, onChanged: onChanged),
      ],
    ),
  );
}
