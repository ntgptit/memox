import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/database/app_database.dart';
import 'package:memox/core/design/study_mode.dart';
import 'package:memox/features/study/data/mappers/study_session_mapper.dart';
import 'package:memox/features/study/domain/entities/study_session.dart';

void main() {
  test('toEntity maps persisted study session fields', () {
    final row = StudySessionsTableData(
      id: 7,
      deckId: 3,
      mode: StudyMode.fill,
      startedAt: DateTime(2026, 4, 3, 9),
      completedAt: DateTime(2026, 4, 3, 9, 5),
      totalCards: 6,
      correctCount: 4,
      wrongCount: 2,
      durationSeconds: 300,
    );

    expect(
      row.toEntity(),
      StudySession(
        id: 7,
        deckId: 3,
        mode: StudyMode.fill,
        startedAt: DateTime(2026, 4, 3, 9),
        completedAt: DateTime(2026, 4, 3, 9, 5),
        totalCards: 6,
        correctCount: 4,
        wrongCount: 2,
        durationSeconds: 300,
      ),
    );
  });

  test('toCompanion preserves explicit identifiers and timestamps', () {
    final session = StudySession(
      id: 11,
      deckId: 5,
      mode: StudyMode.match,
      startedAt: DateTime(2026, 4, 3, 10),
      completedAt: DateTime(2026, 4, 3, 10, 7),
      totalCards: 8,
      correctCount: 6,
      wrongCount: 2,
      durationSeconds: 420,
    );
    final companion = session.toCompanion();

    expect(companion.id, const Value<int>(11));
    expect(companion.deckId, const Value<int>(5));
    expect(companion.mode, const Value<StudyMode>(StudyMode.match));
    expect(companion.startedAt, Value<DateTime>(DateTime(2026, 4, 3, 10)));
    expect(
      companion.completedAt,
      Value<DateTime?>(DateTime(2026, 4, 3, 10, 7)),
    );
    expect(companion.totalCards, const Value<int>(8));
    expect(companion.correctCount, const Value<int>(6));
    expect(companion.wrongCount, const Value<int>(2));
    expect(companion.durationSeconds, const Value<int>(420));
  });

  test('toCompanion omits zero id and backfills missing startedAt', () {
    final before = DateTime.now();
    final companion = const StudySession(
      id: 0,
      deckId: 9,
      mode: StudyMode.recall,
      totalCards: 3,
    ).toCompanion();
    final after = DateTime.now();

    expect(companion.id.present, isFalse);
    expect(companion.deckId, const Value<int>(9));
    expect(companion.mode, const Value<StudyMode>(StudyMode.recall));
    expect(companion.startedAt.present, isTrue);
    expect(companion.startedAt.value.isBefore(before), isFalse);
    expect(companion.startedAt.value.isAfter(after), isFalse);
  });
}
