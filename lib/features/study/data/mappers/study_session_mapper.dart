import 'package:drift/drift.dart';
import 'package:memox/core/database/app_database.dart';
import 'package:memox/features/study/domain/entities/study_session.dart';

abstract final class StudySessionMapper {
  static StudySession toEntity(StudySessionsTableData row) {
    return StudySession(
      id: row.id,
      mode: row.mode,
      deckId: row.deckId,
      startedAt: row.startedAt,
      completedAt: row.completedAt,
      totalCards: row.totalCards,
      correctCount: row.correctCount,
      wrongCount: row.wrongCount,
      durationSeconds: row.durationSeconds,
    );
  }

  static StudySessionsTableCompanion toCompanion(StudySession entity) {
    final id = entity.id > 0
        ? Value<int>(entity.id)
        : const Value<int>.absent();
    final startedAt = entity.startedAt == null
        ? Value<DateTime>(DateTime.now())
        : Value<DateTime>(entity.startedAt!);
    final completedAt = entity.completedAt == null
        ? const Value<DateTime?>.absent()
        : Value<DateTime?>(entity.completedAt);
    return StudySessionsTableCompanion(
      id: id,
      deckId: Value<int>(entity.deckId),
      mode: Value(entity.mode),
      startedAt: startedAt,
      completedAt: completedAt,
      totalCards: Value<int>(entity.totalCards),
      correctCount: Value<int>(entity.correctCount),
      wrongCount: Value<int>(entity.wrongCount),
      durationSeconds: Value<int>(entity.durationSeconds),
    );
  }
}
