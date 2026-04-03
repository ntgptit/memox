import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';

mixin AppTextTheme {
  static TextTheme build(ColorScheme colorScheme) {
    final base = GoogleFonts.plusJakartaSansTextTheme(
      ThemeData(brightness: colorScheme.brightness).textTheme,
    );

    TextStyle? heading(TextStyle? style, double fontSize) => style?.copyWith(
      color: colorScheme.onSurface,
      fontSize: fontSize,
      fontWeight: TypographyTokens.semiBold,
      height: TypographyTokens.headingHeight,
      letterSpacing: TypographyTokens.headingSpacing,
    );

    TextStyle? body(TextStyle? style, double fontSize) => style?.copyWith(
      color: colorScheme.onSurface,
      fontSize: fontSize,
      fontWeight: TypographyTokens.regular,
      height: TypographyTokens.bodyHeight,
    );

    TextStyle? label(
      TextStyle? style,
      double fontSize, {
      required FontWeight fontWeight,
      required Color color,
      required double height,
      double? letterSpacing,
    }) => style?.copyWith(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
    );

    TextStyle? caption(TextStyle? style, double fontSize) => style?.copyWith(
      color: colorScheme.onSurfaceVariant,
      fontSize: fontSize,
      fontWeight: TypographyTokens.regular,
      height: TypographyTokens.captionHeight,
    );

    return base.copyWith(
      displayLarge: heading(base.displayLarge, TypographyTokens.displayLarge),
      displayMedium: heading(
        base.displayMedium,
        TypographyTokens.displayMedium,
      ),
      displaySmall: heading(base.displaySmall, TypographyTokens.headlineLarge),
      headlineLarge: heading(
        base.headlineLarge,
        TypographyTokens.headlineLarge,
      ),
      headlineMedium: heading(
        base.headlineMedium,
        TypographyTokens.headlineMedium,
      ),
      headlineSmall: heading(base.headlineSmall, TypographyTokens.titleLarge),
      titleLarge: heading(base.titleLarge, TypographyTokens.titleLarge),
      titleMedium: heading(base.titleMedium, TypographyTokens.titleMedium),
      titleSmall: heading(base.titleSmall, TypographyTokens.titleSmall),
      bodyLarge: body(base.bodyLarge, TypographyTokens.bodyLarge),
      bodyMedium: body(base.bodyMedium, TypographyTokens.bodyMedium),
      bodySmall: caption(base.bodySmall, TypographyTokens.bodySmall),
      labelLarge: label(
        base.labelLarge,
        TypographyTokens.labelLarge,
        fontWeight: TypographyTokens.medium,
        color: colorScheme.onSurface,
        height: TypographyTokens.bodyHeight,
        letterSpacing: TypographyTokens.labelSpacing,
      ),
      labelMedium: label(
        base.labelMedium,
        TypographyTokens.labelMedium,
        fontWeight: TypographyTokens.regular,
        color: colorScheme.onSurfaceVariant,
        height: TypographyTokens.bodyHeight,
      ),
      labelSmall: caption(base.labelSmall, TypographyTokens.labelSmall),
    );
  }
}
