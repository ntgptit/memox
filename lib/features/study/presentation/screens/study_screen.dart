import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/design/study_mode.dart';
import 'package:memox/core/extensions/context_extensions.dart';
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
import 'package:memox/features/study/presentation/widgets/study_placeholder_view.dart';
import 'package:memox/features/study/presentation/widgets/study_resume_dialog.dart';
import 'package:memox/shared/widgets/layout/app_scaffold.dart';

class StudyScreen extends ConsumerStatefulWidget {
  const StudyScreen({this.deckId, this.mode, super.key});

  static const String routeName = 'study';
  static const String routePath = '/study';
  static const String deckRoutePath = '/deck/:deckId/study/:mode';

  final int? deckId;
  final StudyMode? mode;

  static String routeLocation(int deckId, String mode) =>
      '/deck/$deckId/study/$mode';

  @override
  ConsumerState<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends ConsumerState<StudyScreen> {
  var _checkedResume = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scheduleResumeCheck();
  }

  @override
  Widget build(BuildContext context) =>
      _buildStudyBody(widget.deckId, widget.mode, context);

  void _scheduleResumeCheck() {
    if (_checkedResume || widget.deckId == null || widget.mode == null) {
      return;
    }

    _checkedResume = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_checkResumePrompt());
    });
  }

  Future<void> _checkResumePrompt() async {
    final deckId = widget.deckId;
    final mode = widget.mode;

    if (!mounted || deckId == null || mode == null) {
      return;
    }

    final store = await ref.read(activeStudySessionStoreProvider.future);
    final snapshot = store.load();

    if (!_matchesSnapshot(snapshot, deckId, mode) || !mounted) {
      return;
    }

    final progress = _progressForSnapshot(snapshot!);
    final shouldStartOver = await showDialog<bool>(
      context: context,
      builder: (_) => StudyResumeDialog(
        modeLabel: mode.label(context.l10n),
        completedCount: progress.$1,
        totalCount: progress.$2,
      ),
    );

    if (shouldStartOver != true) {
      return;
    }

    await store.clearIfMatches(deckId: deckId, mode: mode);

    if (!mounted) {
      return;
    }

    await _restartModeSession(ref, deckId, mode);
  }
}

Widget _buildStudyBody(int? deckId, StudyMode? mode, BuildContext context) {
  if (mode == StudyMode.review && deckId != null) {
    return ReviewModeScreen(deckId: deckId);
  }

  if (mode == StudyMode.match && deckId != null) {
    return MatchModeScreen(deckId: deckId);
  }

  if (mode == StudyMode.guess && deckId != null) {
    return GuessModeScreen(deckId: deckId);
  }

  if (mode == StudyMode.recall && deckId != null) {
    return RecallModeScreen(deckId: deckId);
  }

  if (mode == StudyMode.fill && deckId != null) {
    return FillModeScreen(deckId: deckId);
  }

  return AppScaffold(
    appBar: AppBar(
      title: Text(mode?.label(context.l10n) ?? context.l10n.studyTitle),
    ),
    body: const StudyPlaceholderView(),
  );
}

bool _matchesSnapshot(
  ActiveStudySessionSnapshot? snapshot,
  int deckId,
  StudyMode mode,
) => snapshot != null && snapshot.deckId == deckId && snapshot.mode == mode;

(int, int) _progressForSnapshot(
  ActiveStudySessionSnapshot snapshot,
) => switch (snapshot.mode) {
  StudyMode.review => (
    (snapshot.payload['results'] as List?)?.length ?? 0,
    (snapshot.payload['cards'] as List?)?.length ?? 0,
  ),
  StudyMode.guess => (
    (snapshot.payload['results'] as List?)?.length ?? 0,
    (snapshot.payload['cards'] as List?)?.length ?? 0,
  ),
  StudyMode.recall => (
    (snapshot.payload['results'] as List?)?.length ?? 0,
    (snapshot.payload['cards'] as List?)?.length ?? 0,
  ),
  StudyMode.fill => (
    (snapshot.payload['results'] as List?)?.length ?? 0,
    (snapshot.payload['cards'] as List?)?.length ?? 0,
  ),
  StudyMode.match => (
    (snapshot.payload['matchedPairIds'] as List?)?.length ?? 0,
    (snapshot.payload['game'] as Map?)?['correctPairs'] is Map
        ? (((snapshot.payload['game'] as Map)['correctPairs']) as Map).length
        : 0,
  ),
};

Future<void> _restartModeSession(WidgetRef ref, int deckId, StudyMode mode) =>
    switch (mode) {
      StudyMode.review =>
        ref.read(reviewSessionProvider(deckId).notifier).startSession(),
      StudyMode.match =>
        ref.read(matchSessionProvider(deckId).notifier).startGame(),
      StudyMode.guess =>
        ref.read(guessSessionProvider(deckId).notifier).startSession(),
      StudyMode.recall =>
        ref.read(recallSessionProvider(deckId).notifier).startSession(),
      StudyMode.fill =>
        ref.read(fillSessionProvider(deckId).notifier).startSession(),
    };
