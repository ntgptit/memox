import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/features/statistics/domain/value_objects/date_range.dart';
import 'package:memox/features/statistics/presentation/widgets/statistics_period_tabs.dart';
import 'package:memox/shared/widgets/layout/spacing.dart';

class StatisticsHeader extends StatelessWidget {
  const StatisticsHeader({
    required this.selectedRange,
    required this.onRangeSelected,
    super.key,
  });

  final DateRange selectedRange;
  final ValueChanged<DateRange> onRangeSelected;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        context.l10n.progressHeaderTitle,
        style: context.textTheme.headlineSmall,
      ),
      const Gap.md(),
      StatisticsPeriodTabs(
        selectedRange: selectedRange,
        onSelected: onRangeSelected,
      ),
    ],
  );
}
