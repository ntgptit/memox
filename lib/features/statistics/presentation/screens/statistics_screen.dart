import 'package:flutter/material.dart';
import 'package:memox/features/statistics/presentation/widgets/statistics_content_view.dart';
import 'package:memox/shared/widgets/layout/app_scaffold.dart';
import 'package:memox/shared/widgets/navigation/app_root_bottom_nav.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  static const String routeName = 'statistics';
  static const String routePath = '/statistics';

  @override
  Widget build(BuildContext context) => const AppScaffold(
    bottomNavigationBar: AppRootBottomNav(currentIndex: 2),
    body: StatisticsContentView(),
  );
}
