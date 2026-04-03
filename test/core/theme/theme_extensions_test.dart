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
    ThemeData? theme;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Builder(
          builder: (context) {
            final currentTheme = Theme.of(context);
            theme = currentTheme;
            customColors = currentTheme.extension<CustomColors>();
            appTextStyles = currentTheme.extension<AppTextStyles>();
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
      TypographyTokens.displayLarge,
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
    expect(theme, isNotNull);
    expect(
      theme!.textTheme.displayLarge?.fontSize,
      TypographyTokens.displayLarge,
    );
    expect(
      theme!.textTheme.headlineMedium?.fontSize,
      TypographyTokens.headlineMedium,
    );
    expect(theme!.textTheme.titleLarge?.fontSize, TypographyTokens.titleLarge);
    expect(
      theme!.textTheme.titleMedium?.fontSize,
      TypographyTokens.titleMedium,
    );
    expect(theme!.textTheme.bodyMedium?.fontSize, TypographyTokens.bodyMedium);
    expect(theme!.textTheme.bodySmall?.fontSize, TypographyTokens.bodySmall);
    expect(
      theme!.textTheme.labelMedium?.fontSize,
      TypographyTokens.labelMedium,
    );
    expect(theme!.textTheme.labelSmall?.fontSize, TypographyTokens.labelSmall);
    expect(
      theme!.filledButtonTheme.style?.textStyle?.resolve({})?.fontSize,
      TypographyTokens.bodyLarge,
    );
    expect(appTextStyles!.sectionLabel.fontSize, TypographyTokens.labelSmall);
    expect(appTextStyles!.breadcrumb.fontSize, TypographyTokens.bodySmall);
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

  testWidgets('theme centralizes hover and focus interactions', (tester) async {
    ThemeData? theme;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Builder(
          builder: (context) {
            theme = Theme.of(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      theme!.hoverColor,
      theme!.colorScheme.onSurface.withValues(alpha: OpacityTokens.hover),
    );
    expect(
      theme!.focusColor,
      theme!.colorScheme.primary.withValues(alpha: OpacityTokens.focus),
    );
    expect(
      theme!.iconButtonTheme.style?.backgroundColor?.resolve({
        WidgetState.hovered,
      }),
      theme!.colorScheme.onSurface.withValues(alpha: OpacityTokens.hover),
    );
    expect(
      theme!.iconButtonTheme.style?.backgroundColor?.resolve({
        WidgetState.focused,
      }),
      theme!.colorScheme.primary.withValues(alpha: OpacityTokens.focus),
    );
    expect(
      theme!.filledButtonTheme.style?.overlayColor?.resolve({
        WidgetState.hovered,
      }),
      theme!.colorScheme.onPrimary.withValues(alpha: OpacityTokens.hover),
    );
    expect(
      theme!.outlinedButtonTheme.style?.overlayColor?.resolve({
        WidgetState.focused,
      }),
      theme!.colorScheme.primary.withValues(alpha: OpacityTokens.focus),
    );
    expect(
      theme!.segmentedButtonTheme.style?.overlayColor?.resolve({
        WidgetState.pressed,
      }),
      theme!.colorScheme.primary.withValues(alpha: OpacityTokens.press),
    );
  });
}
