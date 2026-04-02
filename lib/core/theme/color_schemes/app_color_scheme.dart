import 'package:flutter/material.dart';
import 'package:memox/core/theme/color_schemes/custom_colors.dart';
import 'package:memox/core/theme/tokens/color_tokens.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';

mixin AppColorScheme {
  static ColorScheme light([Color seedColor = ColorTokens.seed]) =>
      ColorScheme.fromSeed(seedColor: seedColor).copyWith(
        surface: ColorTokens.lightSurface,
        onSurface: ColorTokens.lightOnSurface,
        onSurfaceVariant: ColorTokens.lightOnSurfaceVariant,
        outline: ColorTokens.lightOnSurface.withValues(
          alpha: OpacityTokens.outline,
        ),
        outlineVariant: ColorTokens.lightOnSurface.withValues(
          alpha: OpacityTokens.outline,
        ),
        error: ColorTokens.errorLight,
        shadow: Colors.transparent,
        surfaceTint: Colors.transparent,
      );

  static ColorScheme dark([Color seedColor = ColorTokens.seed]) =>
      ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
      ).copyWith(
        surface: ColorTokens.darkSurface,
        onSurface: ColorTokens.darkOnSurface,
        onSurfaceVariant: ColorTokens.darkOnSurfaceVariant,
        outline: ColorTokens.darkOnSurface.withValues(
          alpha: OpacityTokens.outline,
        ),
        outlineVariant: ColorTokens.darkOnSurface.withValues(
          alpha: OpacityTokens.outline,
        ),
        error: ColorTokens.errorDark,
        shadow: Colors.transparent,
        surfaceTint: Colors.transparent,
      );

  static CustomColors customColorsFor(Brightness brightness) =>
      brightness == Brightness.dark ? CustomColors.dark : CustomColors.light;
}
