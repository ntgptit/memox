import 'package:memox/features/statistics/domain/value_objects/date_range.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'statistics_date_range_provider.g.dart';

@riverpod
class StatisticsDateRangeSelection extends _$StatisticsDateRangeSelection {
  @override
  DateRange build() => DateRange.week;

  DateRange get selectedRange => state;

  set selectedRange(DateRange range) => state = range;
}
