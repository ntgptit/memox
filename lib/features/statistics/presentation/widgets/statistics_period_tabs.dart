import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
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
  Widget build(BuildContext context) => Wrap(
    spacing: SpacingTokens.sm,
    runSpacing: SpacingTokens.sm,
    children: DateRange.values
        .map(
          (range) => _StatisticsPeriodTab(
            label: _label(context, range),
            isSelected: selectedRange == range,
            onTap: () => onSelected(range),
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
    final borderColor = isSelected
        ? context.colors.primary.withValues(alpha: OpacityTokens.focus)
        : context.colors.outline;

    return AppPressable(
      color: transparent,
      borderRadius: RadiusTokens.chip,
      onTap: onTap,
      child: AnimatedContainer(
        duration: DurationTokens.normal,
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.lg,
          vertical: SpacingTokens.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? context.colors.surfaceContainerHighest
              : transparent,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(RadiusTokens.chip),
        ),
        child: Center(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: context.textTheme.labelLarge?.copyWith(
              color: isSelected
                  ? context.colors.primary
                  : context.colors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
