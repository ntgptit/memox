import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';

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
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: context.l10n.themeNavHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.style_outlined),
            selectedIcon: const Icon(Icons.style_rounded),
            label: context.l10n.themeNavStudy,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart_outlined),
            selectedIcon: const Icon(Icons.bar_chart_rounded),
            label: context.l10n.themeNavStats,
          ),
        ],
      ),
    );
  }
}
