import 'package:memox/core/providers/usecase_providers.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cards_by_deck_provider.g.dart';

@riverpod
Stream<List<FlashcardEntity>> cardsByDeck(Ref ref, int deckId) => ref.watch(getCardsByDeckUseCaseProvider).call(deckId);
