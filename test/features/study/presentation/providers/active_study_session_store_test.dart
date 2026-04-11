import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/design/study_mode.dart';
import 'package:memox/features/study/presentation/providers/active_study_session_store.dart';
import 'package:memox/features/study/presentation/providers/study_hub_provider.dart';
import 'package:memox/features/study/presentation/providers/study_session_active_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
  });

  test(
    'load clears an invalid stored study mode instead of throwing',
    () async {
      SharedPreferences.setMockInitialValues({
        'active_study_session_v1': '{"deckId":1,"mode":"broken","payload":{}}',
      });
      final preferences = await SharedPreferences.getInstance();
      final store = ActiveStudySessionStore.shared(preferences);

      final snapshot = store.load();
      await Future<void>.delayed(Duration.zero);

      expect(snapshot, isNull);
      expect(preferences.getString('active_study_session_v1'), isNull);
    },
  );

  test(
    'save and load preserve the generic study session contract fields',
    () async {
      final preferences = await SharedPreferences.getInstance();
      final store = ActiveStudySessionStore.shared(preferences);
      const snapshot = ActiveStudySessionSnapshot(
        deckId: 7,
        mode: StudyMode.recall,
        modePlan: <StudyMode>[StudyMode.review, StudyMode.recall],
        modeState: StudySessionModeState.waitingFeedback,
        allowedActions: <StudySessionAllowedAction>[
          StudySessionAllowedAction.markRemembered,
          StudySessionAllowedAction.retryItem,
        ],
        currentItem: ActiveStudySessionCurrentItem(cardId: 11, position: 2),
        progress: ActiveStudySessionProgress(completedCount: 1, totalCount: 3),
        payload: <String, dynamic>{'cards': <Map<String, dynamic>>[]},
      );

      await store.save(snapshot);
      final loaded = store.load();

      expect(loaded?.deckId, 7);
      expect(loaded?.mode, StudyMode.recall);
      expect(loaded?.modePlan, <StudyMode>[StudyMode.review, StudyMode.recall]);
      expect(loaded?.modeState, StudySessionModeState.waitingFeedback);
      expect(loaded?.allowedActions, <StudySessionAllowedAction>[
        StudySessionAllowedAction.markRemembered,
        StudySessionAllowedAction.retryItem,
      ]);
      expect(loaded?.currentItem?.cardId, 11);
      expect(loaded?.currentItem?.position, 2);
      expect(loaded?.progress.completedCount, 1);
      expect(loaded?.progress.totalCount, 3);
      expect(loaded?.sessionCompleted, isFalse);
    },
  );

  test('active snapshot stream emits when saved and cleared', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    late final ProviderSubscription<AsyncValue<ActiveStudySessionSnapshot?>>
    subscription;

    subscription = container.listen(
      activeStudySessionSnapshotProvider,
      (previous, next) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);
    expect(
      await container.read(activeStudySessionSnapshotProvider.future),
      isNull,
    );
    final store = await container.read(activeStudySessionStoreProvider.future);
    const snapshot = ActiveStudySessionSnapshot(
      deckId: 9,
      mode: StudyMode.review,
      payload: <String, dynamic>{'cards': <Map<String, dynamic>>[]},
    );

    await store.save(snapshot);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    expect(container.read(activeStudySessionSnapshotProvider).value?.deckId, 9);
    expect(
      container.read(activeStudySessionSnapshotProvider).value?.mode,
      StudyMode.review,
    );

    await store.clear();
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    expect(container.read(activeStudySessionSnapshotProvider).value, isNull);
  });

  test('studySessionActive follows snapshot save and clear updates', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    late final ProviderSubscription<AsyncValue<bool>> subscription;

    subscription = container.listen(
      studySessionActiveProvider,
      (previous, next) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    expect(await container.read(studySessionActiveProvider.future), isFalse);
    final store = await container.read(activeStudySessionStoreProvider.future);

    await store.save(
      const ActiveStudySessionSnapshot(
        deckId: 4,
        mode: StudyMode.guess,
        payload: <String, dynamic>{'cards': <Map<String, dynamic>>[]},
      ),
    );
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    expect(container.read(studySessionActiveProvider).value, isTrue);

    await store.clear();
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    expect(container.read(studySessionActiveProvider).value, isFalse);
  });
}
