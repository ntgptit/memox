extension DurationX on Duration {
  bool get isZeroOrNegative => inMicroseconds <= 0;

  Duration scale(double factor) =>
      Duration(microseconds: (inMicroseconds * factor).round());
}
