import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/shared/widgets/feedback/empty_state_view.dart';

class StatisticsEmptyView extends StatelessWidget {
  const StatisticsEmptyView({super.key});

  @override
  Widget build(BuildContext context) => EmptyStateView(
    icon: Icons.bar_chart_outlined,
    title: context.l10n.statisticsNoHistoryTitle,
    subtitle: context.l10n.statisticsNoHistorySubtitle,
  );
}
