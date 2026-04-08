import 'package:memox/core/providers/repository_providers.dart';
import 'package:memox/features/decks/domain/entities/deck_entity.dart';
import 'package:memox/features/study/domain/entities/study_session.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recent_study_sessions_provider.g.dart';

typedef RecentStudySessionItem = ({String deckName, StudySession session});

@riverpod
Stream<List<StudySession>> _recentStudySessionsSource(Ref ref) =>
    ref.watch(studyRepositoryProvider).watchAll();

@riverpod
Stream<List<DeckEntity>> _recentStudyDecksSource(Ref ref) =>
    ref.watch(deckRepositoryProvider).watchAll();

@riverpod
AsyncValue<List<RecentStudySessionItem>> recentStudySessions(Ref ref) {
  final sessionsAsync = ref.watch(_recentStudySessionsSourceProvider);
  final decksAsync = ref.watch(_recentStudyDecksSourceProvider);
  final error = sessionsAsync.asError ?? decksAsync.asError;

  if (error != null) {
    return AsyncValue<List<RecentStudySessionItem>>.error(
      error.error,
      error.stackTrace,
    );
  }

  if (sessionsAsync.isLoading || decksAsync.isLoading) {
    return const AsyncValue<List<RecentStudySessionItem>>.loading();
  }

  final deckNames = {
    for (final deck in decksAsync.requireValue) deck.id: deck.name,
  };
  final sessions = sessionsAsync.requireValue
      .where((session) => session.completedAt != null && session.totalCards > 0)
      .take(5)
      .map(
        (session) => (
          deckName: deckNames[session.deckId] ?? '#${session.deckId}',
          session: session,
        ),
      )
      .toList(growable: false);
  return AsyncValue<List<RecentStudySessionItem>>.data(sessions);
}
