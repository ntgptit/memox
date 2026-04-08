import 'package:drift/drift.dart';
import 'package:memox/core/database/app_database.dart';
import 'package:memox/features/study/domain/entities/study_session.dart';

extension StudySessionRowMapper on StudySessionsTableData {
  StudySession toEntity() => StudySession(
    id: id,
    mode: mode,
    deckId: deckId,
    startedAt: startedAt,
    completedAt: completedAt,
    totalCards: totalCards,
    correctCount: correctCount,
    wrongCount: wrongCount,
    durationSeconds: durationSeconds,
  );
}

extension StudySessionEntityMapper on StudySession {
  StudySessionsTableCompanion toCompanion() {
    final id = this.id > 0 ? Value<int>(this.id) : const Value<int>.absent();
    final startedAt = this.startedAt == null
        ? Value<DateTime>(DateTime.now())
        : Value<DateTime>(this.startedAt!);
    return StudySessionsTableCompanion(
      id: id,
      deckId: Value<int>(deckId),
      mode: Value(mode),
      startedAt: startedAt,
      completedAt: Value<DateTime?>(completedAt),
      totalCards: Value<int>(totalCards),
      correctCount: Value<int>(correctCount),
      wrongCount: Value<int>(wrongCount),
      durationSeconds: Value<int>(durationSeconds),
    );
  }
}
