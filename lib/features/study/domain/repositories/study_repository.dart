import 'package:memox/features/study/domain/entities/study_session.dart';

abstract interface class StudyRepository {
  Stream<List<StudySession>> watchAll();

  Future<StudySession> startSession(String mode);
}
