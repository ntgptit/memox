import 'package:flutter/material.dart';
import 'package:memox/core/theme/tokens/color_tokens.dart';

mixin AppColorUtils {
  static Color foregroundOn(Color background) {
    final brightness = ThemeData.estimateBrightnessForColor(background);
    return brightness == Brightness.dark
        ? ColorTokens.surfaceLight
        : ColorTokens.onSurfaceLight;
  }

  static Color withOpacity(Color color, double opacity) =>
      color.withValues(alpha: opacity);
}
