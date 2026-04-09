import 'package:flutter/material.dart';

abstract final class ColorTokens {
  // ── Seed Colors (cho ColorScheme.fromSeed) ──
  static const Color seed = seedIndigo;
  static const Color seedIndigo = Color(0xFF24389C);
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
  static const Color lightOnSurfaceVariant = Color(0xFF454652);
  static const Color darkOnSurfaceVariant = Color(0xFFC2C2C8);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1C1C1E); // charcoal
  static const Color surfaceBrightLight = Color(0xFFF7F9FB);
  static const Color surfaceDimLight = Color(0xFFE0E3E5);
  static const Color surfaceContainerLowestLight = Color(0xFFF7F9FB);
  static const Color surfaceContainerLowLight = Color(0xFFF2F4F6);
  static const Color surfaceContainerLight = Color(0xFFECEEF0);
  static const Color surfaceContainerHighLight = Color(0xFFE6E8EA);
  static const Color surfaceContainerHighestLight = Color(0xFFE0E3E5);
  static const Color surfaceDimDark = Color(0xFF2C2C2E);
  static const Color onSurfaceLight = Color(0xFF191C1E);
  static const Color onSurfaceDark = Color(0xFFE5E5E7);
  static const Color outlineLight = Color(0xFF757684);
  static const Color outlineVariantLight = Color(0xFFC5C5D4);

  // ── Semantic Colors (via ThemeExtension) ──
  static const Color successLight = Color(0xFF4DB6AC);
  static const Color successDark = Color(0xFF80CBC4);
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color warningDark = Color(0xFFFFCC80);
  static const Color errorLight = Color(0xFFBA1A1A);
  static const Color errorDark = Color(0xFFEF9A9A);
  static const Color masteryLight = Color(0xFF004E1A);
  static const Color masteryDark = Color(0xFFABF4AC);
  static const Color masteryFixedLight = Color(0xFFABF4AC);
  static const Color masteryFixedDark = Color(0xFF24452C);
  static const Color onMasteryFixedLight = Color(0xFF002107);
  static const Color onMasteryFixedDark = Color(0xFFE6F8E6);
  static const Color streakLight = Color(0xFFF97316);
  static const Color streakDark = Color(0xFFFFB77A);

  // ── Mastery Gradient Stops ──
  static const Color masteryLow = Color(0xFFE57373); // coral
  static const Color masteryMid = Color(0xFFFFB74D); // amber
  static const Color masteryHigh = Color(0xFF004E1A); // deep green

  // ── Card Status Colors ──
  static const Color statusNew = Color(0xFF9E9E9E); // gray
  static const Color statusLearning = Color(0xFFFFB74D); // amber
  static const Color statusReviewing = seedIndigo;
  static const Color statusMastered = masteryLight;

  // ── Rating Colors ──
  static const Color ratingAgain = Color(0xFFE57373);
  static const Color ratingHard = Color(0xFFFFB74D);
  static const Color ratingGood = seedIndigo;
  static const Color ratingEasy = Color(0xFF4DB6AC);

  // ── Self-assessment Colors ──
  static const Color selfMissed = Color(0xFFE57373);
  static const Color selfPartial = Color(0xFFFFB74D);
  static const Color selfGotIt = Color(0xFF4DB6AC);
}
