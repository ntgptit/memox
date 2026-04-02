import 'package:flutter/material.dart';
import 'package:memox/core/responsive/responsive_builder.dart';
import 'package:memox/core/responsive/screen_type.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';

class AdaptiveLayout extends StatelessWidget {
  const AdaptiveLayout({
    required this.compactBody,
    this.expandedBody,
    this.breakpoint = ScreenType.expanded,
    this.gap = SpacingTokens.sectionGap,
    super.key,
  });

  final Widget compactBody;
  final Widget? expandedBody;
  final ScreenType breakpoint;
  final double gap;

  @override
  Widget build(BuildContext context) => ResponsiveBuilder(
    builder: (context, screenType) {
      final showExpanded =
          expandedBody != null && screenType.index >= breakpoint.index;

      if (!showExpanded) {
        return compactBody;
      }

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: compactBody),
          SizedBox(width: gap),
          Expanded(child: expandedBody!),
        ],
      );
    },
  );
}
