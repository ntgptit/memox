import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/core/theme/color_schemes/custom_colors.dart';
import 'package:memox/core/theme/text_themes/custom_text_styles.dart';
import 'package:memox/core/theme/tokens/color_tokens.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';

void main() {
  testWidgets('light theme exposes custom extensions from md contract', (
    tester,
  ) async {
    CustomColors? customColors;
    AppTextStyles? appTextStyles;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Builder(
          builder: (context) {
            final theme = Theme.of(context);
            customColors = theme.extension<CustomColors>();
            appTextStyles = theme.extension<AppTextStyles>();
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(customColors, isNotNull);
    expect(customColors!.surfaceDim, ColorTokens.surfaceDimLight);
    expect(customColors!.masteryHigh, ColorTokens.masteryHigh);
    expect(customColors!.ratingAgain, ColorTokens.ratingAgain);

    expect(appTextStyles, isNotNull);
    expect(
      appTextStyles!.flashcardFront.fontSize,
      TypographyTokens.headlineMedium,
    );
    expect(
      appTextStyles!.flashcardHint.color?.a,
      closeTo(OpacityTokens.subtleHint, 0.001),
    );
    expect(appTextStyles!.statNumber.fontSize, TypographyTokens.statDisplay);
    expect(
      appTextStyles!.sectionLabel.letterSpacing,
      TypographyTokens.sectionSpacing,
    );
  });

  testWidgets('dark theme maps dark custom colors', (tester) async {
    CustomColors? customColors;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Builder(
          builder: (context) {
            customColors = Theme.of(context).extension<CustomColors>();
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(customColors, isNotNull);
    expect(customColors!.success, ColorTokens.successDark);
    expect(customColors!.surfaceDim, ColorTokens.surfaceDimDark);
    expect(customColors!.mastery, ColorTokens.masteryDark);
  });
}
