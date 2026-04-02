import 'package:flutter/material.dart';
import 'package:memox/core/constants/app_strings.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';

class ThemeTypographySection extends StatelessWidget {
  const ThemeTypographySection({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.themeTypographyTitle, style: textTheme.titleMedium),
          const SizedBox(height: SpacingTokens.lg),
          Text(AppStrings.themeDisplayLabel, style: textTheme.displaySmall),
          const SizedBox(height: SpacingTokens.sm),
          Text(AppStrings.themeHeadlineLabel, style: textTheme.headlineSmall),
          const SizedBox(height: SpacingTokens.sm),
          Text(AppStrings.themeBodyCopy, style: textTheme.bodyLarge),
          const SizedBox(height: SpacingTokens.sm),
          Text(AppStrings.themeCaptionCopy, style: textTheme.labelSmall),
        ],
      ),
    );
  }
}
