import 'package:flutter/material.dart';
import 'package:memox/core/constants/app_strings.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) => NavigationBar(
    height: SizeTokens.bottomNavHeight,
    selectedIndex: currentIndex,
    onDestinationSelected: onTap,
    destinations: const [
      NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home_rounded),
        label: AppStrings.navHome,
      ),
      NavigationDestination(
        icon: Icon(Icons.collections_bookmark_outlined),
        selectedIcon: Icon(Icons.collections_bookmark_rounded),
        label: AppStrings.navLibrary,
      ),
      NavigationDestination(
        icon: Icon(Icons.bar_chart_outlined),
        selectedIcon: Icon(Icons.bar_chart_rounded),
        label: AppStrings.navProgress,
      ),
      NavigationDestination(
        icon: Icon(Icons.settings_outlined),
        selectedIcon: Icon(Icons.settings_rounded),
        label: AppStrings.navSettings,
      ),
    ],
  );
}
