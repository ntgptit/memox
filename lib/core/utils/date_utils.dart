mixin AppDateUtils {
  static DateTime startOfDay(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static bool isSameDay(DateTime left, DateTime right) =>
      left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}
