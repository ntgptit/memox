import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/features/statistics/presentation/providers/statistics_provider.dart';
import 'package:memox/features/statistics/presentation/widgets/statistics_placeholder_view.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  static const String routeName = 'statistics';
  static const String routePath = '/statistics';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = ref.watch(statisticsScreenTitleProvider);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const StatisticsPlaceholderView(),
    );
  }
}
