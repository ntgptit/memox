import 'package:flutter/material.dart';

mixin AppColorUtils {
  static Color foregroundOn(Color background) {
    final brightness = ThemeData.estimateBrightnessForColor(background);
    return brightness == Brightness.dark ? Colors.white : Colors.black;
  }

  static Color withOpacity(Color color, double opacity) =>
      color.withValues(alpha: opacity);
}
