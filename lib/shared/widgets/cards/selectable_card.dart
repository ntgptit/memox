import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';

class SelectableCard extends StatelessWidget {
  const SelectableCard({
    required this.isSelected,
    required this.onTap,
    required this.child,
    super.key,
  });

  final bool isSelected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedScale(
    scale: isSelected ? 1.02 : 1,
    duration: DurationTokens.normal,
    child: AppCard(
      onTap: onTap,
      backgroundColor: isSelected
          ? context.colors.surfaceContainerHighest
          : null,
      borderColor: isSelected
          ? context.colors.primary.withValues(alpha: OpacityTokens.focus)
          : null,
      child: child,
    ),
  );
}
