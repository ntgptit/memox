import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
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
    destinations: [
      NavigationDestination(
        icon: const Icon(Icons.home_outlined),
        selectedIcon: const Icon(Icons.home_rounded),
        label: context.l10n.navHome,
      ),
      NavigationDestination(
        icon: const Icon(Icons.collections_bookmark_outlined),
        selectedIcon: const Icon(Icons.collections_bookmark_rounded),
        label: context.l10n.navLibrary,
      ),
      NavigationDestination(
        icon: const Icon(Icons.bar_chart_outlined),
        selectedIcon: const Icon(Icons.bar_chart_rounded),
        label: context.l10n.navProgress,
      ),
      NavigationDestination(
        icon: const Icon(Icons.settings_outlined),
        selectedIcon: const Icon(Icons.settings_rounded),
        label: context.l10n.navSettings,
      ),
    ],
  );
}
