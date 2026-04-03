import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/study/domain/guess/guess_engine.dart';

void main() {
  group('GuessEngine', () {
    test('generateQuestion creates four unique options', () {
      final engine = GuessEngine(random: Random(1));
      final question = engine.generateQuestion(_cards(6).first, _cards(6));
      final optionIds = question.options.map((option) => option.cardId).toSet();

      expect(question.options, hasLength(4));
      expect(optionIds, hasLength(4));
    });

    test('correct answer is always included in options', () {
      final cards = _cards(5);
      final engine = GuessEngine(random: Random(2));
      final question = engine.generateQuestion(cards.first, cards);

      expect(question.options[question.correctIndex].text, cards.first.front);
      expect(question.options.any((option) => option.isCorrect), isTrue);
    });

    test('uses placeholders when the deck has too few cards', () {
      final cards = _cards(2);
      final engine = GuessEngine(random: Random(3));
      final question = engine.generateQuestion(cards.first, cards);

      expect(question.options, hasLength(4));
      expect(
        question.options.where(
          (option) => option.cardId.startsWith('placeholder'),
        ),
        hasLength(2),
      );
    });
  });
}

List<FlashcardEntity> _cards(int count) => List<FlashcardEntity>.generate(
  count,
  (index) => FlashcardEntity(
    id: index + 1,
    deckId: 7,
    front: 'Term ${index + 1}',
    back: 'Definition ${index + 1}',
  ),
);
