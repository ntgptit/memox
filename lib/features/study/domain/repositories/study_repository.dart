import 'package:memox/core/design/study_mode.dart';
import 'package:memox/features/study/domain/entities/study_session.dart';

abstract interface class StudyRepository {
  Stream<List<StudySession>> watchAll();

  Future<StudySession> startSession({
    required int deckId,
    StudyMode mode = StudyMode.review,
  });

  Future<StudySession> completeSession(StudySession session);
}
