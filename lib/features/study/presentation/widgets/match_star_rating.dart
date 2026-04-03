import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';

class MatchStarRating extends StatelessWidget {
  const MatchStarRating({required this.starCount, super.key});

  final int starCount;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      for (var index = 0; index < 3; index++) ...[
        Icon(
          Icons.grade_outlined,
          size: SizeTokens.iconLg,
          color: index < starCount
              ? context.customColors.warning
              : context.colors.outline,
        ),
        if (index < 2) const SizedBox(width: SpacingTokens.xs),
      ],
    ],
  );
}
