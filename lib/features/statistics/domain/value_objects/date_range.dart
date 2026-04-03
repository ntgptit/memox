import 'package:memox/core/utils/date_utils.dart';

enum DateRange { week, month, allTime }

extension DateRangeX on DateRange {
  DateTime? startDate(DateTime now) {
    final today = AppDateUtils.startOfDay(now);

    return switch (this) {
      DateRange.week => today.subtract(const Duration(days: 6)),
      DateRange.month => today.subtract(const Duration(days: 29)),
      DateRange.allTime => null,
    };
  }

  bool includes(DateTime value, DateTime now) {
    final start = startDate(now);

    if (start == null) {
      return true;
    }

    return !AppDateUtils.startOfDay(value).isBefore(start);
  }
}
