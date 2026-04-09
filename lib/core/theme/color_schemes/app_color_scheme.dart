import 'package:flutter/material.dart';
import 'package:memox/core/theme/color_schemes/custom_colors.dart';
import 'package:memox/core/theme/tokens/color_tokens.dart';
import 'package:memox/core/theme/tokens/elevation_tokens.dart';

mixin AppColorScheme {
  static const double _primaryShadeShift = 0.18;
  static const double _secondaryShadeShift = 0.10;
  static const double _minimumLightness = 0.30;
  static const double _maximumLightness = 0.42;
  static const double _containerMix = 0.12;

  static ColorScheme light([Color seedColor = ColorTokens.seed]) {
    final base = ColorScheme.fromSeed(seedColor: seedColor);
    final primary = _shade(
      seedColor,
      amount: _primaryShadeShift,
      minLightness: _minimumLightness,
      maxLightness: _maximumLightness,
    );
    final secondary = _shade(
      base.secondary,
      amount: _secondaryShadeShift,
      minLightness: _minimumLightness,
      maxLightness: _maximumLightness,
    );

    return base.copyWith(
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: _tonalSurface(
        accent: primary,
        surface: ColorTokens.surfaceContainerLowestLight,
      ),
      onPrimaryContainer: primary,
      secondary: secondary,
      onSecondary: Colors.white,
      secondaryContainer: _tonalSurface(
        accent: secondary,
        surface: ColorTokens.surfaceContainerLowLight,
      ),
      onSecondaryContainer: secondary,
      tertiary: ColorTokens.masteryLight,
      onTertiary: Colors.white,
      tertiaryContainer: _tonalSurface(
        accent: ColorTokens.masteryLight,
        surface: ColorTokens.surfaceContainerLowestLight,
      ),
      onTertiaryContainer: ColorTokens.masteryLight,
      error: ColorTokens.errorLight,
      surface: ColorTokens.lightSurface,
      surfaceBright: ColorTokens.surfaceBrightLight,
      surfaceDim: ColorTokens.surfaceDimLight,
      surfaceContainerLowest: ColorTokens.surfaceContainerLowestLight,
      surfaceContainerLow: ColorTokens.surfaceContainerLowLight,
      surfaceContainer: ColorTokens.surfaceContainerLight,
      surfaceContainerHigh: ColorTokens.surfaceContainerHighLight,
      surfaceContainerHighest: ColorTokens.surfaceContainerHighestLight,
      onSurface: ColorTokens.lightOnSurface,
      onSurfaceVariant: ColorTokens.lightOnSurfaceVariant,
      outline: ColorTokens.outlineLight,
      outlineVariant: ColorTokens.outlineVariantLight,
      shadow: ColorTokens.lightOnSurface.withValues(
        alpha: ElevationTokens.shadowOpacity,
      ),
      surfaceTint: Colors.transparent,
    );
  }

  static ColorScheme dark([Color seedColor = ColorTokens.seed]) =>
      ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
      ).copyWith(
        surface: ColorTokens.darkSurface,
        onSurface: ColorTokens.darkOnSurface,
        onSurfaceVariant: ColorTokens.darkOnSurfaceVariant,
        outline: ColorTokens.darkOnSurface.withValues(alpha: 0.15),
        outlineVariant: ColorTokens.darkOnSurface.withValues(alpha: 0.10),
        error: ColorTokens.errorDark,
        shadow: ColorTokens.darkOnSurface.withValues(
          alpha: ElevationTokens.shadowOpacity,
        ),
        surfaceTint: Colors.transparent,
      );

  static CustomColors customColorsFor(Brightness brightness) =>
      brightness == Brightness.dark ? CustomColors.dark : CustomColors.light;

  static Color _shade(
    Color color, {
    required double amount,
    required double minLightness,
    required double maxLightness,
  }) {
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness - amount).clamp(
      minLightness,
      maxLightness,
    );

    return hsl.withLightness(lightness).toColor();
  }

  static Color _tonalSurface({required Color accent, required Color surface}) =>
      Color.lerp(surface, accent, _containerMix) ?? surface;
}
