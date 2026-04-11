import 'package:flutter/material.dart';
import 'package:memox/core/design/card_status.dart';
import 'package:memox/core/design/study_mode.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/providers/repository_providers.dart';
import 'package:memox/features/study/presentation/providers/active_study_session_store.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'study_entry_provider.g.dart';

enum StudyEntryStatus {
  ready,
  nothingToStudy,
  containerNotFound,
  activeSessionConflict,
}

final class StudyEntryResolution {
  const StudyEntryResolution._({
    required this.status,
    required this.deckId,
    required this.mode,
    this.activeSession,
    this.activeDeckName,
  });

  const StudyEntryResolution.ready({
    required int deckId,
    required StudyMode mode,
  }) : this._(status: StudyEntryStatus.ready, deckId: deckId, mode: mode);

  const StudyEntryResolution.nothingToStudy({
    required int deckId,
    required StudyMode mode,
  }) : this._(
         status: StudyEntryStatus.nothingToStudy,
         deckId: deckId,
         mode: mode,
       );

  const StudyEntryResolution.containerNotFound({
    required int deckId,
    required StudyMode mode,
  }) : this._(
         status: StudyEntryStatus.containerNotFound,
         deckId: deckId,
         mode: mode,
       );

  const StudyEntryResolution.activeSessionConflict({
    required int deckId,
    required StudyMode mode,
    required ActiveStudySessionSnapshot activeSession,
    required String activeDeckName,
  }) : this._(
         status: StudyEntryStatus.activeSessionConflict,
         deckId: deckId,
         mode: mode,
         activeSession: activeSession,
         activeDeckName: activeDeckName,
       );

  final StudyEntryStatus status;
  final int deckId;
  final StudyMode mode;
  final ActiveStudySessionSnapshot? activeSession;
  final String? activeDeckName;

  bool get isReady => status == StudyEntryStatus.ready;
}

@riverpod
Future<StudyEntryResolution> studyEntry(
  Ref ref,
  ({int deckId, StudyMode mode}) request,
) async {
  final deckRepository = ref.read(deckRepositoryProvider);
  final deck = await deckRepository.getById(request.deckId);
  final store = await ref.read(activeStudySessionStoreProvider.future);
  var snapshot = store.load();

  if (deck == null) {
    if (_matchesSnapshot(snapshot, request.deckId, request.mode)) {
      await store.clearIfMatches(deckId: request.deckId, mode: request.mode);
    }

    return StudyEntryResolution.containerNotFound(
      deckId: request.deckId,
      mode: request.mode,
    );
  }

  if (!isActiveStudySessionResumable(snapshot)) {
    if (snapshot != null) {
      await store.clearIfMatches(deckId: snapshot.deckId, mode: snapshot.mode);
    }

    snapshot = null;
  }

  if (snapshot != null) {
    if (_matchesSnapshot(snapshot, request.deckId, request.mode)) {
      return StudyEntryResolution.ready(
        deckId: request.deckId,
        mode: request.mode,
      );
    }

    final activeDeck = await deckRepository.getById(snapshot.deckId);

    if (activeDeck == null) {
      await store.clearIfMatches(deckId: snapshot.deckId, mode: snapshot.mode);
    }

    if (activeDeck != null) {
      return StudyEntryResolution.activeSessionConflict(
        deckId: request.deckId,
        mode: request.mode,
        activeSession: snapshot,
        activeDeckName: activeDeck.name,
      );
    }
  }

  final flashcardRepository = ref.read(flashcardRepositoryProvider);
  final hasEligibleCards = switch (request.mode) {
    StudyMode.review => (await flashcardRepository.getDueCards(
      deckId: request.deckId,
      limit: 1,
    )).isNotEmpty,
    _ => (await flashcardRepository.getByDeck(
      request.deckId,
    )).any((card) => card.status != CardStatus.mastered),
  };

  if (!hasEligibleCards) {
    return StudyEntryResolution.nothingToStudy(
      deckId: request.deckId,
      mode: request.mode,
    );
  }

  return StudyEntryResolution.ready(deckId: request.deckId, mode: request.mode);
}

String studyEntryEmptySubtitle(BuildContext context, StudyMode mode) =>
    switch (mode) {
      StudyMode.review => context.l10n.reviewEmptySubtitle,
      StudyMode.match => context.l10n.matchEmptySubtitle,
      StudyMode.guess => context.l10n.guessEmptySubtitle,
      StudyMode.recall => context.l10n.recallEmptySubtitle,
      StudyMode.fill => context.l10n.fillEmptySubtitle,
    };

bool _matchesSnapshot(
  ActiveStudySessionSnapshot? snapshot,
  int deckId,
  StudyMode mode,
) => snapshot != null && snapshot.deckId == deckId && snapshot.mode == mode;
