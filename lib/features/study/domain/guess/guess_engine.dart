import 'dart:math';

import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';

typedef CardEntity = FlashcardEntity;
typedef GuessOption = ({String text, String cardId, bool isCorrect});
typedef GuessQuestion = ({
  String definition,
  List<GuessOption> options,
  int correctIndex,
});

final class GuessEngine {
  GuessEngine({Random? random}) : _random = random ?? Random();

  static const int _optionsPerQuestion = 4;
  static const String _placeholderText = '???';

  final Random _random;

  List<CardEntity> shuffleCards(List<CardEntity> cards) =>
      [...cards]..shuffle(_random);

  GuessQuestion generateQuestion(CardEntity target, List<CardEntity> allCards) {
    final options = <GuessOption>[
      (text: target.front, cardId: '${target.id}', isCorrect: true),
      ..._buildDistractors(target, allCards),
    ]..shuffle(_random);
    final correctIndex = options.indexWhere((option) => option.isCorrect);

    return (
      definition: target.back,
      options: options,
      correctIndex: correctIndex,
    );
  }

  List<GuessOption> _buildDistractors(
    CardEntity target,
    List<CardEntity> allCards,
  ) {
    final distractors = <GuessOption>[];
    final usedTexts = <String>{target.front};
    final candidates =
        allCards
            .where(
              (card) => card.deckId == target.deckId && card.id != target.id,
            )
            .toList()
          ..shuffle(_random);

    for (final card in candidates) {
      if (usedTexts.contains(card.front)) {
        continue;
      }

      distractors.add((
        text: card.front,
        cardId: '${card.id}',
        isCorrect: false,
      ));
      usedTexts.add(card.front);

      if (distractors.length == _optionsPerQuestion - 1) {
        return distractors;
      }
    }

    final missingCount = (_optionsPerQuestion - 1) - distractors.length;
    distractors.addAll(
      List<GuessOption>.generate(
        missingCount,
        (index) => (
          text: _placeholderText,
          cardId: 'placeholder-${target.id}-$index',
          isCorrect: false,
        ),
      ),
    );
    return distractors;
  }
}
