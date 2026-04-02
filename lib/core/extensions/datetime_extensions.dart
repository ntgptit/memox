import 'package:memox/core/utils/date_utils.dart';

extension DateTimeX on DateTime {
  bool get isToday => AppDateUtils.isSameDay(this, DateTime.now());

  DateTime get startOfDay => AppDateUtils.startOfDay(this);
}
