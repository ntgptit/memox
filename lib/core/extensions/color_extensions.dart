import 'package:flutter/material.dart';

extension ColorX on Color {
  bool get isDark =>
      ThemeData.estimateBrightnessForColor(this) == Brightness.dark;

  Color opacity(double value) => withValues(alpha: value);
}
