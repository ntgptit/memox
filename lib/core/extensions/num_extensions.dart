extension NumX on num {
  double get clampedPercent => clamp(0, 1).toDouble();
}
