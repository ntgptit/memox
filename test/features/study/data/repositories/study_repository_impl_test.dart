import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/database/app_database.dart';
import 'package:memox/core/design/study_mode.dart';
import 'package:memox/core/logging/logger_impl.dart';
import 'package:memox/features/study/data/datasources/study_local_datasource.dart';
import 'package:memox/features/study/data/repositories/study_repository_impl.dart';

void main() {
  late AppDatabase database;
  late StudyLocalDataSourceImpl dataSource;
  late StudyRepositoryImpl repository;
  late int deckId;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    dataSource = StudyLocalDataSourceImpl(database.studySessionDao);
    repository = StudyRepositoryImpl(
      localDataSource: dataSource,
      logger: const LoggerImpl(),
    );
    deckId = await _insertDeck(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('startSession persists a mode-first study session row', () async {
    final before = DateTime.now();
    final session = await repository.startSession(
      deckId: deckId,
      mode: StudyMode.match,
    );
    final after = DateTime.now();

    expect(session.id, greaterThan(0));
    expect(session.deckId, deckId);
    expect(session.mode, StudyMode.match);
    expect(session.startedAt, isNotNull);
    expect(session.startedAt!.isBefore(before), isFalse);
    expect(session.startedAt!.isAfter(after), isFalse);
    expect(session.completedAt, isNull);
  });

  test('completeSession persists completion fields for an existing row', () async {
    final started = await repository.startSession(
      deckId: deckId,
      mode: StudyMode.recall,
    );
    final completedAt = DateTime(2026, 4, 3, 11, 5);

    final completed = await repository.completeSession(
      started.copyWith(
        completedAt: completedAt,
        totalCards: 6,
        correctCount: 5,
        wrongCount: 1,
        durationSeconds: 180,
      ),
    );

    expect(completed.id, started.id);
    expect(completed.completedAt, completedAt);
    expect(completed.totalCards, 6);
    expect(completed.correctCount, 5);
    expect(completed.wrongCount, 1);
    expect(completed.durationSeconds, 180);
  });

  test('watchAll maps persisted rows back to entities in DAO order', () async {
    await dataSource.save(
      StudySessionsTableCompanion.insert(
        deckId: deckId,
        mode: StudyMode.review,
        startedAt: DateTime(2026, 4, 3, 7),
        totalCards: 2,
      ),
    );
    await dataSource.save(
      StudySessionsTableCompanion.insert(
        deckId: deckId,
        mode: StudyMode.fill,
        startedAt: DateTime(2026, 4, 3, 9),
        totalCards: 4,
      ),
    );

    final sessions = await repository.watchAll().first;

    expect(sessions.map((session) => session.mode).toList(), [
      StudyMode.fill,
      StudyMode.review,
    ]);
    expect(sessions.map((session) => session.deckId).toSet(), {deckId});
  });
}

Future<int> _insertDeck(AppDatabase database) async {
  final folderId = await database.folderDao.insertFolder(
    const FoldersTableCompanion(name: Value<String>('Study folder')),
  );
  return database.deckDao.insertDeck(
    DecksTableCompanion(
      name: const Value<String>('Study deck'),
      folderId: Value<int>(folderId),
    ),
  );
}
