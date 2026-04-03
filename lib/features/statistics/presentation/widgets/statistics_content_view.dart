import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/statistics/presentation/providers/statistics_date_range_provider.dart';
import 'package:memox/features/statistics/presentation/providers/study_stats_provider.dart';
import 'package:memox/features/statistics/presentation/widgets/difficult_cards_section.dart';
import 'package:memox/features/statistics/presentation/widgets/mastery_donut_chart_section.dart';
import 'package:memox/features/statistics/presentation/widgets/mode_usage_chart.dart';
import 'package:memox/features/statistics/presentation/widgets/statistics_empty_view.dart';
import 'package:memox/features/statistics/presentation/widgets/statistics_header.dart';
import 'package:memox/features/statistics/presentation/widgets/statistics_practice_action.dart';
import 'package:memox/features/statistics/presentation/widgets/streak_hero_card.dart';
import 'package:memox/features/statistics/presentation/widgets/weekly_bar_chart_section.dart';
import 'package:memox/shared/widgets/feedback/app_async_builder.dart';
import 'package:memox/shared/widgets/layout/spacing.dart';

class StatisticsContentView extends ConsumerWidget {
  const StatisticsContentView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final range = ref.watch(statisticsDateRangeSelectionProvider);
    final statsAsync = ref.watch(statisticsScreenDataProvider(range));

    return AppAsyncBuilder<StatisticsScreenData>(
      value: statsAsync,
      onData: (data) {
        if (!data.hasHistory) {
          return const StatisticsEmptyView();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.only(
            top: SpacingTokens.xl,
            bottom: SpacingTokens.xxxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StatisticsHeader(
                selectedRange: range,
                onRangeSelected: (value) {
                  ref
                          .read(statisticsDateRangeSelectionProvider.notifier)
                          .selectedRange =
                      value;
                },
              ),
              const Gap.section(),
              StreakHeroCard(stats: data.stats),
              const Gap.section(),
              WeeklyBarChartSection(activities: data.stats.weeklyActivity),
              const Gap.section(),
              MasteryDonutChartSection(mastery: data.stats.mastery),
              const Gap.section(),
              ModeUsageChart(modeUsage: data.stats.modeUsage),
              const Gap.section(),
              DifficultCardsSection(
                cards: data.stats.difficultCards,
                onPractice: () => showStatisticsPracticeFlow(
                  context,
                  data.stats.difficultCards,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
