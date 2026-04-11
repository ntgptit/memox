import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/shared/widgets/buttons/app_pressable.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLowest.withValues(
          alpha: OpacityTokens.surfaceGlass,
        ),
        border: Border(
          top: BorderSide(
            color: context.colors.outlineVariant.withValues(
              alpha: OpacityTokens.borderSubtle,
            ),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: context.colors.shadow,
            blurRadius: SpacingTokens.xl,
            offset: const Offset(0, -SpacingTokens.xs),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          SpacingTokens.lg,
          SpacingTokens.sm,
          SpacingTokens.lg,
          SpacingTokens.md,
        ),
        child: Row(
          children: List<Widget>.generate(_destinations.length, (index) {
            final destination = _destinations[index];

            return Expanded(
              child: _BottomNavItem(
                destination: destination,
                selected: index == currentIndex,
                onTap: () => onTap(index),
              ),
            );
          }),
        ),
      ),
    ),
  );
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final _BottomNavDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foregroundColor = selected
        ? context.colors.primary
        : context.colors.onSurfaceVariant;
    final backgroundColor = selected
        ? context.colors.primary.withValues(alpha: OpacityTokens.softTint)
        : context.colors.surface.withValues(alpha: 0);

    return AppPressable(
      onTap: onTap,
      borderRadius: RadiusTokens.card,
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xs),
      child: AnimatedContainer(
        duration: DurationTokens.fast,
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.sm,
          vertical: SpacingTokens.xs,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: selected
              ? Border.all(
                  color: context.colors.primary.withValues(
                    alpha: OpacityTokens.borderSubtle,
                  ),
                )
              : null,
          borderRadius: BorderRadius.circular(RadiusTokens.card),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? destination.selectedIcon : destination.icon,
              color: foregroundColor,
              size: SizeTokens.iconMd,
            ),
            const SizedBox(height: SpacingTokens.xs),
            Text(
              destination.label(context),
              style: context.textTheme.labelSmall?.copyWith(
                color: foregroundColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavDestination {
  const _BottomNavDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String Function(BuildContext context) label;
}

const _destinations = <_BottomNavDestination>[
  _BottomNavDestination(
    icon: Icons.home_outlined,
    selectedIcon: Icons.home_rounded,
    label: _homeLabel,
  ),
  _BottomNavDestination(
    icon: Icons.collections_bookmark_outlined,
    selectedIcon: Icons.collections_bookmark_rounded,
    label: _libraryLabel,
  ),
  _BottomNavDestination(
    icon: Icons.bar_chart_outlined,
    selectedIcon: Icons.bar_chart_rounded,
    label: _progressLabel,
  ),
  _BottomNavDestination(
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings_rounded,
    label: _settingsLabel,
  ),
];

String _homeLabel(BuildContext context) => context.l10n.navHome;

String _libraryLabel(BuildContext context) => context.l10n.navLibrary;

String _progressLabel(BuildContext context) => context.l10n.navProgress;

String _settingsLabel(BuildContext context) => context.l10n.navSettings;
