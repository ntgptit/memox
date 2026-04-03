import 'package:flutter/material.dart';
import 'package:memox/core/design/card_status.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';

class CardStatusDot extends StatelessWidget {
  const CardStatusDot({required this.status, super.key});

  final CardStatus status;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(color: _color(context), shape: BoxShape.circle),
    child: const SizedBox.square(dimension: SizeTokens.statusDotSizeLg),
  );

  Color _color(BuildContext context) => switch (status) {
    CardStatus.newCard => context.customColors.statusNew,
    CardStatus.learning => context.customColors.statusLearning,
    CardStatus.reviewing => context.customColors.statusReviewing,
    CardStatus.mastered => context.customColors.statusMastered,
  };
}
