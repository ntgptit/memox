import 'package:flutter/material.dart';

abstract final class ColorTokens {
  // ── Seed Colors (cho ColorScheme.fromSeed) ──
  static const Color seed = seedIndigo;
  static const Color seedIndigo = Color(0xFF5C6BC0);
  static const Color seedTeal = Color(0xFF4DB6AC);
  static const Color seedRose = Color(0xFFE57373);
  static const Color seedAmber = Color(0xFFFFB74D);
  static const Color seedSlate = Color(0xFF78909C);
  static const Color seedSage = Color(0xFF81C784);

  // ── Available Seed Colors (for settings color picker) ──
  static const List<Color> availableSeeds = [
    seedIndigo,
    seedTeal,
    seedRose,
    seedAmber,
    seedSlate,
    seedSage,
  ];

  // ── Surface Overrides (warmer than M3 defaults) ──
  static const Color lightSurface = surfaceLight;
  static const Color darkSurface = surfaceDark;
  static const Color lightOnSurface = onSurfaceLight;
  static const Color darkOnSurface = onSurfaceDark;
  static const Color lightOnSurfaceVariant = Color(0xFF6A6A6F);
  static const Color darkOnSurfaceVariant = Color(0xFFC2C2C8);
  static const Color surfaceLight = Color(0xFFFAFAFA); // warm white
  static const Color surfaceDark = Color(0xFF1C1C1E); // charcoal
  static const Color surfaceDimLight = Color(0xFFF5F5F5);
  static const Color surfaceDimDark = Color(0xFF2C2C2E);
  static const Color onSurfaceLight = Color(0xFF1D1D1F); // soft black
  static const Color onSurfaceDark = Color(0xFFE5E5E7);

  // ── Semantic Colors (via ThemeExtension) ──
  static const Color successLight = Color(0xFF4DB6AC);
  static const Color successDark = Color(0xFF80CBC4);
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color warningDark = Color(0xFFFFCC80);
  static const Color errorLight = Color(0xFFE57373);
  static const Color errorDark = Color(0xFFEF9A9A);
  static const Color masteryLight = Color(0xFF66BB6A);
  static const Color masteryDark = Color(0xFF81C784);

  // ── Mastery Gradient Stops ──
  static const Color masteryLow = Color(0xFFE57373); // coral
  static const Color masteryMid = Color(0xFFFFB74D); // amber
  static const Color masteryHigh = Color(0xFF4DB6AC); // teal

  // ── Card Status Colors ──
  static const Color statusNew = Color(0xFF9E9E9E); // gray
  static const Color statusLearning = Color(0xFFFFB74D); // amber
  static const Color statusReviewing = Color(0xFF5C6BC0); // indigo
  static const Color statusMastered = Color(0xFF4DB6AC); // teal

  // ── Rating Colors ──
  static const Color ratingAgain = Color(0xFFE57373);
  static const Color ratingHard = Color(0xFFFFB74D);
  static const Color ratingGood = Color(0xFF5C6BC0);
  static const Color ratingEasy = Color(0xFF4DB6AC);

  // ── Self-assessment Colors ──
  static const Color selfMissed = Color(0xFFE57373);
  static const Color selfPartial = Color(0xFFFFB74D);
  static const Color selfGotIt = Color(0xFF4DB6AC);
}
