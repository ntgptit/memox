import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/statistics/domain/entities/daily_activity.dart';
import 'package:memox/features/statistics/presentation/widgets/weekly_bar_chart_painter.dart';
import 'package:memox/shared/widgets/buttons/app_tap_region.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';

class WeeklyBarChartSection extends StatefulWidget {
  const WeeklyBarChartSection({required this.activities, super.key});

  final List<DailyActivity> activities;

  @override
  State<WeeklyBarChartSection> createState() => _WeeklyBarChartSectionState();
}

class _WeeklyBarChartSectionState extends State<WeeklyBarChartSection> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.statisticsWeeklyActivityTitle,
          style: context.textTheme.titleMedium,
        ),
        const SizedBox(height: SpacingTokens.lg),
        _WeeklyBarChartBody(
          activities: widget.activities,
          selectedIndex: _selectedIndex,
          onBarSelected: (value) => setState(() => _selectedIndex = value),
        ),
      ],
    ),
  );
}

class _WeeklyBarChartBody extends StatelessWidget {
  const _WeeklyBarChartBody({
    required this.activities,
    required this.selectedIndex,
    required this.onBarSelected,
  });

  final List<DailyActivity> activities;
  final int? selectedIndex;
  final ValueChanged<int?> onBarSelected;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => Stack(
      children: [
        AppTapRegion(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) {
            final rawIndex =
                (details.localPosition.dx /
                        (constraints.maxWidth / activities.length))
                    .floor();
            onBarSelected(rawIndex.clamp(0, activities.length - 1));
          },
          child: SizedBox(
            height: SizeTokens.statisticsWeeklyChartHeight,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: DurationTokens.chartDraw,
              builder: (context, value, _) => CustomPaint(
                painter: WeeklyBarChartPainter(
                  activities: activities,
                  today: DateTime.now(),
                  todayColor: context.colors.primary,
                  barColor: context.colors.surfaceContainerHighest,
                  progress: value,
                ),
              ),
            ),
          ),
        ),
        if (selectedIndex != null)
          _WeeklyTooltip(
            activity: activities[selectedIndex!],
            activityCount: activities.length,
            index: selectedIndex!,
            maxWidth: constraints.maxWidth,
          ),
        Positioned.fill(
          child: IgnorePointer(child: _WeekdayLabels(count: activities.length)),
        ),
      ],
    ),
  );
}

class _WeeklyTooltip extends StatelessWidget {
  const _WeeklyTooltip({
    required this.activity,
    required this.activityCount,
    required this.index,
    required this.maxWidth,
  });

  final DailyActivity activity;
  final int activityCount;
  final int index;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final slotWidth = maxWidth / activityCount;
    final left = (slotWidth * index) + (slotWidth / 2) - SpacingTokens.xxl;
    final maxLeft = maxWidth - (SpacingTokens.xxxl * 2);

    return Positioned(
      top: 0,
      left: left.clamp(0, maxLeft).toDouble(),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(RadiusTokens.chip),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.sm,
            vertical: SpacingTokens.xs,
          ),
          child: Text(
            context.l10n.statisticsBarTooltip(activity.cardsStudied),
            style: context.textTheme.labelSmall,
          ),
        ),
      ),
    );
  }
}

class _WeekdayLabels extends StatelessWidget {
  const _WeekdayLabels({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      const SizedBox(height: SpacingTokens.xxl),
      Row(
        children: List<Widget>.generate(
          count,
          (index) => Expanded(
            child: Text(
              _weekdayLabel(context, index),
              textAlign: TextAlign.center,
              style: context.textTheme.labelSmall,
            ),
          ),
        ),
      ),
    ],
  );

  String _weekdayLabel(BuildContext context, int index) => switch (index) {
    0 => context.l10n.statisticsWeekdayMondayShort,
    1 => context.l10n.statisticsWeekdayTuesdayShort,
    2 => context.l10n.statisticsWeekdayWednesdayShort,
    3 => context.l10n.statisticsWeekdayThursdayShort,
    4 => context.l10n.statisticsWeekdayFridayShort,
    5 => context.l10n.statisticsWeekdaySaturdayShort,
    _ => context.l10n.statisticsWeekdaySundayShort,
  };
}
