import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';

class FillDiffText extends StatelessWidget {
  const FillDiffText({
    required this.userAnswer,
    required this.correctAnswer,
    super.key,
  });

  final String userAnswer;
  final String correctAnswer;

  @override
  Widget build(BuildContext context) {
    final answerCharacters = correctAnswer.characters.toList(growable: false);
    final userCharacters = userAnswer.characters.toList(growable: false);
    final baseStyle = context.textTheme.titleSmall;
    return RichText(
      text: TextSpan(
        style: baseStyle,
        children: [
          for (var index = 0; index < answerCharacters.length; index++)
            TextSpan(
              text: answerCharacters[index],
              style: baseStyle?.copyWith(
                color:
                    index < userCharacters.length &&
                        userCharacters[index] == answerCharacters[index]
                    ? context.customColors.ratingGood
                    : context.customColors.ratingAgain,
              ),
            ),
        ],
      ),
    );
  }
}
