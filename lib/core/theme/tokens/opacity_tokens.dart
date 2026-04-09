/// M3 state layer opacities.
abstract final class OpacityTokens {
  // ── State Layers ──
  static const double softTint = 0.05;
  static const double hover = 0.08;
  static const double focus = 0.12;
  static const double press = 0.12;
  static const double drag = 0.16;
  static const double selected = 0.18;
  static const double disabled = 0.38;

  // ── Content Opacities ──
  static const double subtleHint = 0.20;
  static const double hintText = 0.50;
  static const double disabledText = 0.38;
  static const double divider = 0.12;
  static const double outline = 0.08;
  static const double borderSubtle = 0.15;
  static const double surfaceGlass = 0.84;
  static const double overlay = 0.15; // swipe gesture overlay
  static const double surfaceScrim = 0.32; // behind dialogs
  static const double fadeOut = 0.40; // wrong answer, other options
}
