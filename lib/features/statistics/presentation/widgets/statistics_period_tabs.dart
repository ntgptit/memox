import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/statistics/domain/value_objects/date_range.dart';
import 'package:memox/shared/widgets/buttons/app_pressable.dart';

class StatisticsPeriodTabs extends StatelessWidget {
  const StatisticsPeriodTabs({
    required this.selectedRange,
    required this.onSelected,
    super.key,
  });

  final DateRange selectedRange;
  final ValueChanged<DateRange> onSelected;

  @override
  Widget build(BuildContext context) => Row(
    children: DateRange.values
        .map(
          (range) => Expanded(
            child: _StatisticsPeriodTab(
              label: _label(context, range),
              isSelected: selectedRange == range,
              onTap: () => onSelected(range),
            ),
          ),
        )
        .toList(),
  );

  String _label(BuildContext context, DateRange range) => switch (range) {
    DateRange.week => context.l10n.statisticsPeriodWeek,
    DateRange.month => context.l10n.statisticsPeriodMonth,
    DateRange.allTime => context.l10n.statisticsPeriodAllTime,
  };
}

class _StatisticsPeriodTab extends StatelessWidget {
  const _StatisticsPeriodTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final transparent = context.colors.surface.withValues(alpha: 0);

    return AppPressable(
      color: transparent,
      borderRadius: RadiusTokens.chip,
      onTap: onTap,
      child: SizedBox(
        height: SizeTokens.touchTarget,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: context.textTheme.titleSmall?.copyWith(
                color: isSelected
                    ? context.colors.primary
                    : context.colors.onSurface.withValues(
                        alpha: OpacityTokens.disabled,
                      ),
              ),
            ),
            const SizedBox(height: SpacingTokens.xs),
            AnimatedContainer(
              duration: DurationTokens.normal,
              height: SizeTokens.progressBarHeight,
              width: double.infinity,
              color: isSelected ? context.colors.primary : transparent,
            ),
          ],
        ),
      ),
    );
  }
}
