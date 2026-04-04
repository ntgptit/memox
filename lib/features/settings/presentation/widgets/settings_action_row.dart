import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/shared/widgets/buttons/app_pressable.dart';
import 'package:memox/shared/widgets/layout/spacing.dart';

class SettingsActionRow extends StatelessWidget {
  const SettingsActionRow({
    required this.title,
    required this.icon,
    required this.onTap,
    this.titleColor,
    super.key,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) => AppPressable(
    onTap: onTap,
    borderRadius: RadiusTokens.none,
    padding: const EdgeInsets.symmetric(
      horizontal: SpacingTokens.lg,
      vertical: SpacingTokens.md,
    ),
    child: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: SizeTokens.listItemCompact),
      child: Row(
        children: [
          Icon(icon, color: titleColor ?? context.colors.onSurfaceVariant),
          const Gap.lg(),
          Expanded(
            child: Text(
              title,
              style: context.textTheme.titleMedium?.copyWith(color: titleColor),
            ),
          ),
          Icon(Icons.chevron_right, color: context.colors.onSurfaceVariant),
        ],
      ),
    ),
  );
}
