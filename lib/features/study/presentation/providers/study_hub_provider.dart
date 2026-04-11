import 'dart:async';

import 'package:memox/core/providers/repository_providers.dart';
import 'package:memox/features/cards/domain/entities/flashcard_entity.dart';
import 'package:memox/features/decks/domain/entities/deck_entity.dart';
import 'package:memox/features/study/domain/support/study_session_type.dart';
import 'package:memox/features/study/domain/usecases/build_study_deck_recommendation.dart';
import 'package:memox/features/study/presentation/providers/active_study_session_store.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'study_hub_provider.g.dart';

final class StudyHubData {
  const StudyHubData({
    required this.recommendations,
    this.activeDeck,
    this.activeSession,
  });

  final List<StudyDeckRecommendation> recommendations;
  final DeckEntity? activeDeck;
  final ActiveStudySessionSnapshot? activeSession;

  bool get hasRecommendations => recommendations.isNotEmpty;

  StudyDeckRecommendation? get recommended =>
      hasRecommendations ? recommendations.first : null;

  List<StudyDeckRecommendation> get remainingRecommendations =>
      recommendations.skip(1).toList(growable: false);
}

@riverpod
BuildStudyDeckRecommendationUseCase buildStudyDeckRecommendationUseCase(
  Ref ref,
) => BuildStudyDeckRecommendationUseCase();

@riverpod
Stream<List<FlashcardEntity>> _studyHubCards(Ref ref) =>
    ref.watch(flashcardRepositoryProvider).watchAll();

@riverpod
Stream<List<DeckEntity>> _studyHubDecks(Ref ref) =>
    ref.watch(deckRepositoryProvider).watchAll();

@riverpod
Stream<ActiveStudySessionSnapshot?> activeStudySessionSnapshot(Ref ref) async* {
  final store = await ref.watch(activeStudySessionStoreProvider.future);

  await for (final snapshot in store.watch()) {
    if (isActiveStudySessionResumable(snapshot)) {
      yield snapshot;
      continue;
    }

    if (snapshot != null) {
      await store.clearIfMatches(deckId: snapshot.deckId, mode: snapshot.mode);
    }

    yield null;
  }
}

@riverpod
AsyncValue<StudyHubData> studyHub(Ref ref) {
  final decksAsync = ref.watch(_studyHubDecksProvider);
  final cardsAsync = ref.watch(_studyHubCardsProvider);
  final activeSessionAsync = ref.watch(activeStudySessionSnapshotProvider);
  final error =
      decksAsync.asError ?? cardsAsync.asError ?? activeSessionAsync.asError;

  if (error != null) {
    return AsyncValue<StudyHubData>.error(error.error, error.stackTrace);
  }

  if (decksAsync.isLoading ||
      cardsAsync.isLoading ||
      activeSessionAsync.isLoading) {
    return const AsyncValue<StudyHubData>.loading();
  }

  final planner = ref.watch(buildStudyDeckRecommendationUseCaseProvider);
  final cardsByDeck = _groupCardsByDeck(cardsAsync.requireValue);
  final recommendations =
      decksAsync.requireValue
          .map(
            (deck) => planner.call(
              deck: deck,
              cards: cardsByDeck[deck.id] ?? const [],
            ),
          )
          .whereType<StudyDeckRecommendation>()
          .toList(growable: false)
        ..sort(_compareRecommendations);
  final activeSession = activeSessionAsync.requireValue;
  final activeDeck = _findDeck(decksAsync.requireValue, activeSession?.deckId);

  if (activeSession != null && activeDeck == null) {
    unawaited(_clearActiveSessionSnapshot(ref, activeSession));
  }

  final validActiveSession = activeDeck == null ? null : activeSession;

  return AsyncValue<StudyHubData>.data(
    StudyHubData(
      recommendations: recommendations,
      activeDeck: activeDeck,
      activeSession: validActiveSession,
    ),
  );
}

int _compareRecommendations(
  StudyDeckRecommendation left,
  StudyDeckRecommendation right,
) => _recommendationScore(right).compareTo(_recommendationScore(left));

DeckEntity? _findDeck(List<DeckEntity> decks, int? deckId) {
  if (deckId == null) {
    return null;
  }

  for (final deck in decks) {
    if (deck.id == deckId) {
      return deck;
    }
  }

  return null;
}

Map<int, List<FlashcardEntity>> _groupCardsByDeck(List<FlashcardEntity> cards) {
  final grouped = <int, List<FlashcardEntity>>{};

  for (final card in cards) {
    grouped.putIfAbsent(card.deckId, () => <FlashcardEntity>[]).add(card);
  }

  return grouped;
}

int _recommendationScore(StudyDeckRecommendation recommendation) {
  final sessionPriority = switch (recommendation.sessionType) {
    StudySessionType.review => 400000,
    StudySessionType.firstLearning => 300000,
    StudySessionType.reinforcement => 200000,
    StudySessionType.quickDrill => 100000,
  };

  return sessionPriority +
      recommendation.dueCards * 1000 +
      recommendation.newCards * 100 +
      recommendation.activeCards * 10 +
      recommendation.totalCards;
}

Future<void> _clearActiveSessionSnapshot(
  Ref ref,
  ActiveStudySessionSnapshot snapshot,
) async {
  final store = await ref.read(activeStudySessionStoreProvider.future);
  await store.clearIfMatches(deckId: snapshot.deckId, mode: snapshot.mode);
}
