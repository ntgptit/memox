import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/core/design/study_mode.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/providers/repository_providers.dart';
import 'package:memox/features/study/presentation/factories/study_mode_flow_factory.dart';
import 'package:memox/features/study/presentation/providers/active_study_session_store.dart';
import 'package:memox/features/study/presentation/providers/study_entry_provider.dart';
import 'package:memox/features/study/presentation/providers/study_hub_provider.dart';
import 'package:memox/features/study/presentation/widgets/study_entry_conflict_view.dart';
import 'package:memox/features/study/presentation/widgets/study_hub_content.dart';
import 'package:memox/features/study/presentation/widgets/study_resume_dialog.dart';
import 'package:memox/shared/widgets/feedback/app_async_builder.dart';
import 'package:memox/shared/widgets/feedback/empty_state_view.dart';
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
  void didUpdateWidget(covariant StudyScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.deckId == widget.deckId && oldWidget.mode == widget.mode) {
      return;
    }

    _checkedResume = false;
    _scheduleResumeCheck();
  }

  @override
  Widget build(BuildContext context) => _buildStudyBody(context);

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

    final deckExists = await _requestedDeckExists(deckId);

    if (!deckExists || !mounted) {
      return;
    }

    final store = await ref.read(activeStudySessionStoreProvider.future);
    final snapshot = store.load();

    if (!isActiveStudySessionResumable(snapshot)) {
      if (snapshot != null) {
        await store.clearIfMatches(
          deckId: snapshot.deckId,
          mode: snapshot.mode,
        );
      }

      return;
    }

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

    ref.invalidate(studyEntryProvider((deckId: deckId, mode: mode)));
    await studyModeFlowFactory.resolve(mode).restartSession(ref, deckId);
  }

  Future<bool> _requestedDeckExists(int deckId) async {
    try {
      final deck = await ref.read(deckRepositoryProvider).getById(deckId);
      return deck != null;
    } catch (_) {
      return false;
    }
  }

  Widget _buildStudyBody(BuildContext context) {
    final deckId = widget.deckId;
    final mode = widget.mode;

    if (mode != null && deckId != null) {
      final entryAsync = ref.watch(
        studyEntryProvider((deckId: deckId, mode: mode)),
      );
      return AppAsyncBuilder<StudyEntryResolution>(
        value: entryAsync,
        onRetry: () =>
            ref.invalidate(studyEntryProvider((deckId: deckId, mode: mode))),
        onData: (resolution) => _buildDirectEntryBody(
          context: context,
          resolution: resolution,
          deckId: deckId,
          mode: mode,
        ),
      );
    }

    final hubAsync = ref.watch(studyHubProvider);

    return AppScaffold(
      appBar: AppBar(title: Text(context.l10n.studyTitle)),
      body: AppAsyncBuilder<StudyHubData>(
        value: hubAsync,
        onRetry: () => ref.invalidate(studyHubProvider),
        onData: (data) => StudyHubContent(data: data),
      ),
    );
  }

  Widget _buildDirectEntryBody({
    required BuildContext context,
    required StudyEntryResolution resolution,
    required int deckId,
    required StudyMode mode,
  }) => switch (resolution.status) {
    StudyEntryStatus.ready =>
      studyModeFlowFactory.resolve(mode).buildScreen(deckId),
    StudyEntryStatus.activeSessionConflict => AppScaffold(
      appBar: AppBar(title: Text(mode.label(context.l10n))),
      body: StudyEntryConflictView(
        modeLabel: resolution.activeSession!.mode.label(context.l10n),
        deckName: resolution.activeDeckName!,
        onBackToHub: () => context.go(StudyScreen.routePath),
        onDiscardAndStart: () => unawaited(
          _discardConflictingSessionAndContinue(
            activeSession: resolution.activeSession!,
            deckId: deckId,
            mode: mode,
          ),
        ),
      ),
    ),
    StudyEntryStatus.containerNotFound => _buildEntryRefusal(
      context: context,
      mode: mode,
      status: resolution.status,
    ),
    StudyEntryStatus.nothingToStudy => _buildEntryRefusal(
      context: context,
      mode: mode,
      status: resolution.status,
    ),
  };

  Widget _buildEntryRefusal({
    required BuildContext context,
    required StudyMode mode,
    required StudyEntryStatus status,
  }) => AppScaffold(
    appBar: AppBar(title: Text(mode.label(context.l10n))),
    body: EmptyStateView(
      icon: status == StudyEntryStatus.containerNotFound
          ? Icons.inbox_outlined
          : Icons.play_circle_outline,
      title: status == StudyEntryStatus.containerNotFound
          ? context.l10n.studyContainerMissingTitle
          : mode.label(context.l10n),
      subtitle: status == StudyEntryStatus.containerNotFound
          ? context.l10n.studyContainerMissingSubtitle
          : studyEntryEmptySubtitle(context, mode),
    ),
  );

  Future<void> _discardConflictingSessionAndContinue({
    required ActiveStudySessionSnapshot activeSession,
    required int deckId,
    required StudyMode mode,
  }) async {
    final store = await ref.read(activeStudySessionStoreProvider.future);
    await store.clearIfMatches(
      deckId: activeSession.deckId,
      mode: activeSession.mode,
    );
    ref
      ..invalidate(activeStudySessionSnapshotProvider)
      ..invalidate(studyHubProvider)
      ..invalidate(studyEntryProvider((deckId: deckId, mode: mode)));
  }
}

bool _matchesSnapshot(
  ActiveStudySessionSnapshot? snapshot,
  int deckId,
  StudyMode mode,
) => snapshot != null && snapshot.deckId == deckId && snapshot.mode == mode;

(int, int) _progressForSnapshot(ActiveStudySessionSnapshot snapshot) {
  final progress = studyModeFlowFactory
      .resolve(snapshot.mode)
      .progressFromSnapshot(snapshot);
  return (progress.completedCount, progress.totalCount);
}
