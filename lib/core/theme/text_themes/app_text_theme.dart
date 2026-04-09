import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';

mixin AppTextTheme {
  static TextTheme build(ColorScheme colorScheme) {
    final base = GoogleFonts.plusJakartaSansTextTheme(
      ThemeData(brightness: colorScheme.brightness).textTheme,
    );

    TextStyle? heading(
      TextStyle? style,
      double fontSize, {
      FontWeight fontWeight = TypographyTokens.semiBold,
      Color? color,
      double height = TypographyTokens.headingHeight,
      double? letterSpacing = TypographyTokens.headingSpacing,
    }) => style?.copyWith(
      color: color ?? colorScheme.onSurface,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
    );

    TextStyle? title(
      TextStyle? style,
      double fontSize, {
      required FontWeight fontWeight,
      Color? color,
      double height = TypographyTokens.bodyHeight,
      double? letterSpacing,
    }) => style?.copyWith(
      color: color ?? colorScheme.onSurface,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
    );

    TextStyle? body(
      TextStyle? style,
      double fontSize, {
      Color? color,
      FontWeight fontWeight = TypographyTokens.regular,
      double height = TypographyTokens.bodyHeight,
    }) => style?.copyWith(
      color: color ?? colorScheme.onSurface,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
    );

    return base.copyWith(
      displayLarge: heading(
        base.displayLarge,
        TypographyTokens.displayLarge,
        fontWeight: TypographyTokens.bold,
      ),
      displayMedium: heading(
        base.displayMedium,
        TypographyTokens.displayMedium,
        fontWeight: TypographyTokens.bold,
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
      headlineSmall: heading(
        base.headlineSmall,
        TypographyTokens.headlineMedium,
        fontWeight: TypographyTokens.medium,
        letterSpacing: TypographyTokens.bodySpacing,
      ),
      titleLarge: heading(base.titleLarge, TypographyTokens.titleLarge),
      titleMedium: title(
        base.titleMedium,
        TypographyTokens.titleMedium,
        fontWeight: TypographyTokens.medium,
      ),
      titleSmall: title(
        base.titleSmall,
        TypographyTokens.titleSmall,
        fontWeight: TypographyTokens.bold,
      ),
      bodyLarge: body(base.bodyLarge, TypographyTokens.bodyLarge),
      bodyMedium: body(base.bodyMedium, TypographyTokens.bodyMedium),
      bodySmall: body(
        base.bodySmall,
        TypographyTokens.bodySmall,
        color: colorScheme.onSurfaceVariant,
      ),
      labelLarge: label(
        base.labelLarge,
        TypographyTokens.labelLarge,
        fontWeight: TypographyTokens.medium,
        color: colorScheme.onSurfaceVariant,
        height: TypographyTokens.bodyHeight,
        letterSpacing: TypographyTokens.labelSpacing,
      ),
      labelMedium: label(
        base.labelMedium,
        TypographyTokens.labelMedium,
        fontWeight: TypographyTokens.medium,
        color: colorScheme.onSurfaceVariant,
        height: TypographyTokens.captionHeight,
        letterSpacing: TypographyTokens.labelSpacing,
      ),
      labelSmall: label(
        base.labelSmall,
        TypographyTokens.labelSmall,
        fontWeight: TypographyTokens.bold,
        color: colorScheme.onSurfaceVariant,
        height: TypographyTokens.captionHeight,
        letterSpacing: TypographyTokens.sectionSpacing,
      ),
    );
  }

  static TextStyle? label(
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
}
