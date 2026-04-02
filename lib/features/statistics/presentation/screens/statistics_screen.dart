import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/features/statistics/presentation/widgets/statistics_placeholder_view.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  static const String routeName = 'statistics';
  static const String routePath = '/statistics';

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.statisticsTitle)),
    body: const StatisticsPlaceholderView(),
  );
}
