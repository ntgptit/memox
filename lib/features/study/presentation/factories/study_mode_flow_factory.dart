import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/design/study_mode.dart';
import 'package:memox/features/study/presentation/providers/active_study_session_store.dart';
import 'package:memox/features/study/presentation/providers/fill_provider.dart';
import 'package:memox/features/study/presentation/providers/guess_provider.dart';
import 'package:memox/features/study/presentation/providers/match_provider.dart';
import 'package:memox/features/study/presentation/providers/recall_provider.dart';
import 'package:memox/features/study/presentation/providers/review_provider.dart';
import 'package:memox/features/study/presentation/screens/fill_mode_screen.dart';
import 'package:memox/features/study/presentation/screens/guess_mode_screen.dart';
import 'package:memox/features/study/presentation/screens/match_mode_screen.dart';
import 'package:memox/features/study/presentation/screens/recall_mode_screen.dart';
import 'package:memox/features/study/presentation/screens/review_mode_screen.dart';

typedef StudySnapshotProgress = ({int completedCount, int totalCount});

final class StudyModeFlow {
  const StudyModeFlow({
    required this.buildScreen,
    required this.progressFromSnapshot,
    required this.invalidateSession,
    required this.restartSession,
  });

  final Widget Function(int deckId) buildScreen;
  final StudySnapshotProgress Function(ActiveStudySessionSnapshot snapshot)
  progressFromSnapshot;
  final void Function(WidgetRef ref, int deckId) invalidateSession;
  final Future<void> Function(WidgetRef ref, int deckId) restartSession;
}

final class StudyModeFlowFactory {
  const StudyModeFlowFactory();

  StudyModeFlow resolve(StudyMode mode) => switch (mode) {
    StudyMode.review => const StudyModeFlow(
      buildScreen: _buildReviewScreen,
      progressFromSnapshot: _reviewProgress,
      invalidateSession: _invalidateReviewSession,
      restartSession: _restartReviewSession,
    ),
    StudyMode.match => const StudyModeFlow(
      buildScreen: _buildMatchScreen,
      progressFromSnapshot: _matchProgress,
      invalidateSession: _invalidateMatchSession,
      restartSession: _restartMatchSession,
    ),
    StudyMode.guess => const StudyModeFlow(
      buildScreen: _buildGuessScreen,
      progressFromSnapshot: _guessProgress,
      invalidateSession: _invalidateGuessSession,
      restartSession: _restartGuessSession,
    ),
    StudyMode.recall => const StudyModeFlow(
      buildScreen: _buildRecallScreen,
      progressFromSnapshot: _recallProgress,
      invalidateSession: _invalidateRecallSession,
      restartSession: _restartRecallSession,
    ),
    StudyMode.fill => const StudyModeFlow(
      buildScreen: _buildFillScreen,
      progressFromSnapshot: _fillProgress,
      invalidateSession: _invalidateFillSession,
      restartSession: _restartFillSession,
    ),
  };
}

const StudyModeFlowFactory studyModeFlowFactory = StudyModeFlowFactory();

Widget _buildReviewScreen(int deckId) => ReviewModeScreen(deckId: deckId);

Widget _buildMatchScreen(int deckId) => MatchModeScreen(deckId: deckId);

Widget _buildGuessScreen(int deckId) => GuessModeScreen(deckId: deckId);

Widget _buildRecallScreen(int deckId) => RecallModeScreen(deckId: deckId);

Widget _buildFillScreen(int deckId) => FillModeScreen(deckId: deckId);

StudySnapshotProgress _reviewProgress(ActiveStudySessionSnapshot snapshot) =>
    _snapshotProgress(
      snapshot,
      fallback: () => (
        completedCount: _payloadListLength(snapshot.payload, 'results'),
        totalCount: _payloadListLength(snapshot.payload, 'cards'),
      ),
    );

StudySnapshotProgress _guessProgress(ActiveStudySessionSnapshot snapshot) =>
    _snapshotProgress(
      snapshot,
      fallback: () => (
        completedCount: _payloadListLength(snapshot.payload, 'results'),
        totalCount: _payloadListLength(snapshot.payload, 'cards'),
      ),
    );

StudySnapshotProgress _recallProgress(ActiveStudySessionSnapshot snapshot) {
  final progress = snapshot.progress;

  if (progress.hasValues) {
    return (
      completedCount: progress.completedCount,
      totalCount: progress.totalCount,
    );
  }

  final payload = snapshot.payload;
  final completedCount =
      _payloadListLength(payload, 'results') -
      _payloadListLength(payload, 'retryPendingCardIds');
  return (
    completedCount: completedCount < 0 ? 0 : completedCount,
    totalCount: _payloadListLength(payload, 'cards'),
  );
}

StudySnapshotProgress _fillProgress(ActiveStudySessionSnapshot snapshot) =>
    _snapshotProgress(
      snapshot,
      fallback: () => (
        completedCount: _payloadListLength(snapshot.payload, 'results'),
        totalCount: _payloadListLength(snapshot.payload, 'cards'),
      ),
    );

StudySnapshotProgress _matchProgress(ActiveStudySessionSnapshot snapshot) {
  final progress = snapshot.progress;

  if (progress.hasValues) {
    return (
      completedCount: progress.completedCount,
      totalCount: progress.totalCount,
    );
  }

  final payload = snapshot.payload;
  final completedPairCount = _payloadInt(payload, 'completedPairCount');
  return (
    completedCount:
        completedPairCount + _payloadListLength(payload, 'matchedPairIds'),
    totalCount: _payloadListLength(payload, 'cards'),
  );
}

StudySnapshotProgress _snapshotProgress(
  ActiveStudySessionSnapshot snapshot, {
  required StudySnapshotProgress Function() fallback,
}) {
  final progress = snapshot.progress;

  if (!progress.hasValues) {
    return fallback();
  }

  return (
    completedCount: progress.completedCount,
    totalCount: progress.totalCount,
  );
}

int _payloadInt(Map<String, dynamic> payload, String key) {
  final value = payload[key];

  if (value is int) {
    return value;
  }

  return 0;
}

int _payloadListLength(Map<String, dynamic> payload, String key) {
  final value = payload[key];

  if (value is List) {
    return value.length;
  }

  return 0;
}

Future<void> _restartReviewSession(WidgetRef ref, int deckId) =>
    ref.read(reviewSessionProvider(deckId).notifier).startSession();

void _invalidateReviewSession(WidgetRef ref, int deckId) =>
    ref.invalidate(reviewSessionProvider(deckId));

Future<void> _restartMatchSession(WidgetRef ref, int deckId) =>
    ref.read(matchSessionProvider(deckId).notifier).startGame();

void _invalidateMatchSession(WidgetRef ref, int deckId) =>
    ref.invalidate(matchSessionProvider(deckId));

Future<void> _restartGuessSession(WidgetRef ref, int deckId) =>
    ref.read(guessSessionProvider(deckId).notifier).startSession();

void _invalidateGuessSession(WidgetRef ref, int deckId) =>
    ref.invalidate(guessSessionProvider(deckId));

Future<void> _restartRecallSession(WidgetRef ref, int deckId) =>
    ref.read(recallSessionProvider(deckId).notifier).startSession();

void _invalidateRecallSession(WidgetRef ref, int deckId) =>
    ref.invalidate(recallSessionProvider(deckId));

Future<void> _restartFillSession(WidgetRef ref, int deckId) =>
    ref.read(fillSessionProvider(deckId).notifier).startSession();

void _invalidateFillSession(WidgetRef ref, int deckId) =>
    ref.invalidate(fillSessionProvider(deckId));
