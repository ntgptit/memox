import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/shared/widgets/navigation/top_bar_icon_button.dart';
class TopBarBackButton extends StatelessWidget {
  const TopBarBackButton({
    required this.onPressed,
    this.startPadding = 0,
    this.slotWidth = SizeTokens.touchTarget,
    super.key,
  });

  static const double balancedSlotWidth = TopBarIconButton.balancedSlotWidth;

  final VoidCallback onPressed;
  final double startPadding;
  final double slotWidth;

  @override
  Widget build(BuildContext context) {
    // Bắt chước thuật toán căn phải của TopBarActionRow (Trừ đi SpacingTokens.sm)
    // để lề hai bên đối xứng hoàn hảo bằng mắt thường.
    final effectivePadding = startPadding > 0
        ? math.max(0.0, startPadding - SpacingTokens.sm)
        : startPadding;

    return Padding(
      padding: EdgeInsets.only(left: effectivePadding),
      child: TopBarIconButton(
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        onPressed: onPressed,
        icon: Icons.arrow_back_outlined,
        alignment: Alignment.centerLeft,
        slotWidth: slotWidth,
      ),
    );
  }
}

