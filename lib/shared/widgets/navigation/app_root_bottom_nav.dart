import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/features/decks/presentation/screens/decks_screen.dart';
import 'package:memox/features/folders/presentation/screens/home_screen.dart';
import 'package:memox/features/settings/presentation/screens/settings_screen.dart';
import 'package:memox/features/statistics/presentation/screens/statistics_screen.dart';
import 'package:memox/shared/widgets/navigation/app_bottom_nav.dart';

class AppRootBottomNav extends StatelessWidget {
  const AppRootBottomNav({required this.currentIndex, super.key});

  final int currentIndex;

  @override
  Widget build(BuildContext context) => AppBottomNav(
    currentIndex: currentIndex,
    onTap: (index) => _navigate(context, index),
  );

  void _navigate(BuildContext context, int index) {
    final shellState = StatefulNavigationShell.maybeOf(context);

    if (shellState != null) {
      shellState.goBranch(index, initialLocation: index == currentIndex);
      return;
    }

    final route = switch (index) {
      0 => HomeScreen.routePath,
      1 => DecksScreen.routePath,
      2 => StatisticsScreen.routePath,
      _ => SettingsScreen.routePath,
    };

    context.go(route);
  }
}
