import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';

mixin AppTextTheme {
  static TextTheme build(ColorScheme colorScheme) {
    final base = GoogleFonts.plusJakartaSansTextTheme(
      ThemeData(brightness: colorScheme.brightness).textTheme,
    );

    TextStyle? heading(TextStyle? style) => style?.copyWith(
      color: colorScheme.onSurface,
      fontWeight: TypographyTokens.semiBold,
      letterSpacing: TypographyTokens.headingSpacing,
    );

    TextStyle? body(TextStyle? style) => style?.copyWith(
      color: colorScheme.onSurface,
      fontWeight: TypographyTokens.regular,
      height: TypographyTokens.bodyHeight,
    );

    TextStyle? caption(TextStyle? style) => style?.copyWith(
      color: colorScheme.onSurfaceVariant,
      fontWeight: TypographyTokens.regular,
      fontSize: TypographyTokens.caption,
      height: TypographyTokens.captionHeight,
    );

    return base.copyWith(
      displayLarge: heading(base.displayLarge),
      displayMedium: heading(base.displayMedium),
      displaySmall: heading(base.displaySmall),
      headlineLarge: heading(base.headlineLarge),
      headlineMedium: heading(base.headlineMedium),
      headlineSmall: heading(base.headlineSmall),
      titleLarge: heading(base.titleLarge),
      titleMedium: heading(base.titleMedium),
      titleSmall: heading(base.titleSmall),
      bodyLarge: body(base.bodyLarge),
      bodyMedium: body(base.bodyMedium),
      bodySmall: caption(base.bodySmall),
      labelLarge: heading(base.labelLarge),
      labelMedium: body(base.labelMedium),
      labelSmall: caption(base.labelSmall),
    );
  }
}
