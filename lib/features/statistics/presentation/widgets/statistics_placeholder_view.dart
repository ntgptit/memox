import 'package:flutter/material.dart';
import 'package:memox/core/constants/app_strings.dart';
import 'package:memox/shared/widgets/feedback/empty_state_view.dart';

class StatisticsPlaceholderView extends StatelessWidget {
  const StatisticsPlaceholderView({super.key});

  @override
  Widget build(BuildContext context) => const EmptyStateView(
    icon: Icons.bar_chart_outlined,
    title: AppStrings.statisticsTitle,
    subtitle: AppStrings.statisticsSubtitle,
  );
}
