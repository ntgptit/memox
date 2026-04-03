import 'package:flutter/material.dart';

abstract final class TypographyTokens {
  // ── Font Family ──
  static const String fontFamily = 'Plus Jakarta Sans';

  // ── Font Weights ──
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // ── Letter Spacing ──
  static const double headingSpacing = -0.02;
  static const double bodySpacing = 0;
  static const double labelSpacing = 0.06;
  static const double sectionSpacing = 0.08;

  // ── Line Heights ──
  static const double displayHeight = 1.1;
  static const double headingHeight = 1.2;
  static const double bodyHeight = 1.5;
  static const double captionHeight = 1.4;
  static const double relaxedHeight = 1.6;

  // ── Collapsed Type Scale (48 / 32 / 24 / 20 / 16 / 14 / 12) ──
  static const double displayLarge = 32;
  static const double displayMedium = 32;
  static const double statDisplay = 48;
  static const double headlineLarge = 24;
  static const double headlineMedium = 20;
  static const double titleLarge = 24;
  static const double titleMedium = 16;
  static const double titleSmall = 16;
  static const double bodyLarge = 16;
  static const double bodyMedium = 16;
  static const double bodySmall = 14;
  static const double labelLarge = 14;
  static const double labelMedium = 12;
  static const double labelSmall = 12;
  static const double caption = 12;

  // ── Max Line Width (readability) ──
  static const int maxCharsPerLine = 60;
}
