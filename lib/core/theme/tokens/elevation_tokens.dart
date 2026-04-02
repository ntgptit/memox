/// M3 uses tonal elevation (surface tint overlay) instead of shadows.
/// These values map to Material 3 elevation levels.
abstract final class ElevationTokens {
  static const double level0 = 0; // flat (default for cards)
  static const double level1 = 1; // subtle lift (pressed card)
  static const double level2 = 3; // FAB resting
  static const double level3 = 6; // FAB pressed, snackbar
  static const double level4 = 8; // navigation drawer
  static const double level5 = 12; // modal (dialog, bottom sheet)

  // ── Shadow Presets (very subtle, for cases where tonal isn't enough) ──
  static const double shadowOpacity = 0.06; // max 8% per design spec
}
