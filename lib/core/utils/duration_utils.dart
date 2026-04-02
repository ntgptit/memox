mixin AppDurationUtils {
  static String humanize(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h';
    }

    if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    }

    return '${duration.inSeconds}s';
  }

  static Duration scale(Duration duration, double factor) => Duration(
    microseconds: (duration.inMicroseconds * factor).round(),
  );
}
