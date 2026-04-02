import 'package:flutter/animation.dart';

/// M3 motion easing curves.
abstract final class EasingTokens {
  // ── M3 Standard (for most UI transitions) ──
  static const Curve standard = Curves.easeInOut;

  // ── M3 Emphasized (for large/important transitions) ──
  static const Curve emphasized = Curves.easeInOutCubicEmphasized;
  static const Curve emphasizedDecelerate = Curves.easeOutCubic;
  static const Curve emphasizedAccelerate = Curves.easeInCubic;

  // ── Convenience ──
  static const Curve enter = Curves.easeOut; // elements appearing
  static const Curve exit = Curves.easeIn; // elements disappearing
  static const Curve move = Curves.easeInOut; // repositioning
  static const Curve bounce =
      Curves.elasticOut; // DON'T use — listed as anti-pattern reminder
}
