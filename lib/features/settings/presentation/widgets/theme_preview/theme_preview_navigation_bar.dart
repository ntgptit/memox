import 'package:flutter/material.dart';
import 'package:memox/core/constants/app_strings.dart';

class ThemePreviewNavigationBar extends StatelessWidget {
  const ThemePreviewNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colorScheme.outline)),
      ),
      child: NavigationBar(
        selectedIndex: 1,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: AppStrings.themeNavHome,
          ),
          NavigationDestination(
            icon: Icon(Icons.style_outlined),
            selectedIcon: Icon(Icons.style_rounded),
            label: AppStrings.themeNavStudy,
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart_rounded),
            label: AppStrings.themeNavStats,
          ),
        ],
      ),
    );
  }
}
