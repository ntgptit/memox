mixin AppNumberUtils {
  static double clampPercent(num value) => value.clamp(0, 1).toDouble();

  static bool isWithinRange(num value, num min, num max) =>
      value >= min && value <= max;
}
