import 'package:memox/features/study/presentation/providers/active_study_session_store.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'study_session_active_provider.g.dart';

@riverpod
Stream<bool> studySessionActive(Ref ref) async* {
  final store = await ref.watch(activeStudySessionStoreProvider.future);
  await for (final snapshot in store.watch()) {
    yield snapshot != null;
  }
}
