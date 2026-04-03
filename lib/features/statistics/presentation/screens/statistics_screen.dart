import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/features/statistics/presentation/widgets/statistics_placeholder_view.dart';
import 'package:memox/shared/widgets/layout/app_scaffold.dart';
import 'package:memox/shared/widgets/navigation/app_root_bottom_nav.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  static const String routeName = 'statistics';
  static const String routePath = '/statistics';

  @override
  Widget build(BuildContext context) => AppScaffold(
    appBar: AppBar(title: Text(context.l10n.statisticsTitle)),
    bottomNavigationBar: const AppRootBottomNav(currentIndex: 2),
    body: const StatisticsPlaceholderView(),
  );
}
