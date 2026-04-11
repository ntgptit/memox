import 'dart:math';

import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';

typedef CardEntity = FlashcardEntity;

enum MatchItemType { term, definition }

final class MatchEngine {
  MatchEngine({Random? random}) : _random = random ?? Random();

  static const int defaultPairsPerRound = 5;

  final Random _random;

  ({
    List<({String id, String text, MatchItemType type})> terms,
    List<({String id, String text, MatchItemType type})> definitions,
    Map<String, String> correctPairs,
  })
  generateGame(
    List<CardEntity> cards, {
    int pairsPerRound = defaultPairsPerRound,
  }) {
    if (cards.isEmpty) {
      return const (
        terms: <({String id, String text, MatchItemType type})>[],
        definitions: <({String id, String text, MatchItemType type})>[],
        correctPairs: <String, String>{},
      );
    }

    final selectedCards = [...cards]..shuffle(_random);
    final roundCards = selectedCards.take(min(pairsPerRound, cards.length));
    final terms = <({String id, String text, MatchItemType type})>[];
    final definitions = <({String id, String text, MatchItemType type})>[];
    final correctPairs = <String, String>{};

    for (final card in roundCards) {
      final termId = 'term-${card.id}';
      final definitionId = 'definition-${card.id}';
      terms.add((id: termId, text: card.front, type: MatchItemType.term));
      definitions.add((
        id: definitionId,
        text: card.back,
        type: MatchItemType.definition,
      ));
      correctPairs[termId] = definitionId;
    }

    terms.shuffle(_random);
    definitions.shuffle(_random);
    return (terms: terms, definitions: definitions, correctPairs: correctPairs);
  }

  List<CardEntity> shuffleCards(List<CardEntity> cards) {
    final shuffled = [...cards]..shuffle(_random);
    return shuffled;
  }

  bool checkMatch(
    Map<String, String> correctPairs,
    String termId,
    String definitionId,
  ) => correctPairs[termId] == definitionId;
}
