import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/study/domain/match/match_engine.dart';

void main() {
  group('MatchEngine', () {
    test('generateGame creates valid term-definition pairs', () {
      final engine = MatchEngine(random: Random(1));
      final game = engine.generateGame(_cards(6));

      expect(game.terms.length, 5);
      expect(game.definitions.length, 5);
      expect(game.correctPairs.length, 5);
      expect(
        game.terms.every((item) => item.type == MatchItemType.term),
        isTrue,
      );
      expect(
        game.definitions.every((item) => item.type == MatchItemType.definition),
        isTrue,
      );

      for (final term in game.terms) {
        final definitionId = game.correctPairs[term.id];
        expect(definitionId, isNotNull);
        expect(game.definitions.any((item) => item.id == definitionId), isTrue);
      }
    });

    test('checkMatch returns true only for a valid pair', () {
      final engine = MatchEngine(random: Random(2));
      final game = engine.generateGame(_cards(2), pairsPerRound: 2);
      final term = game.terms.first;
      final correctDefinitionId = game.correctPairs[term.id]!;
      final wrongDefinitionId = game.definitions
          .firstWhere((item) => item.id != correctDefinitionId)
          .id;

      expect(engine.checkMatch(term.id, correctDefinitionId), isTrue);
      expect(engine.checkMatch(term.id, wrongDefinitionId), isFalse);
    });
  });
}

List<FlashcardEntity> _cards(int count) => List<FlashcardEntity>.generate(
  count,
  (index) => FlashcardEntity(
    id: index + 1,
    deckId: 9,
    front: 'Term ${index + 1}',
    back: 'Definition ${index + 1}',
  ),
);
