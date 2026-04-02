import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';

class ThemeTypographySection extends StatelessWidget {
  const ThemeTypographySection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.themeTypographyTitle, style: textTheme.titleMedium),
          const SizedBox(height: SpacingTokens.lg),
          Text(l10n.themeDisplayLabel, style: textTheme.displaySmall),
          const SizedBox(height: SpacingTokens.sm),
          Text(l10n.themeHeadlineLabel, style: textTheme.headlineSmall),
          const SizedBox(height: SpacingTokens.sm),
          Text(l10n.themeBodyCopy, style: textTheme.bodyLarge),
          const SizedBox(height: SpacingTokens.sm),
          Text(l10n.themeCaptionCopy, style: textTheme.labelSmall),
        ],
      ),
    );
  }
}
