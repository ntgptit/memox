import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/database/app_database.dart';
import 'package:memox/core/design/study_mode.dart';
import 'package:memox/features/study/data/datasources/study_local_datasource.dart';

void main() {
  late AppDatabase database;
  late StudyLocalDataSourceImpl dataSource;
  late int deckId;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    dataSource = StudyLocalDataSourceImpl(database.studySessionDao);
    deckId = await _insertDeck(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('save inserts a study session row and reloads it', () async {
    final saved = await dataSource.save(
      StudySessionsTableCompanion.insert(
        deckId: deckId,
        mode: StudyMode.review,
        startedAt: DateTime(2026, 4, 3, 8),
        totalCards: 4,
      ),
    );

    expect(saved.id, greaterThan(0));
    expect(saved.deckId, deckId);
    expect(saved.mode, StudyMode.review);
    expect(saved.totalCards, 4);
    expect(saved.correctCount, 0);
    expect(saved.wrongCount, 0);
  });

  test('save replaces an existing study session when id is present', () async {
    final inserted = await dataSource.save(
      StudySessionsTableCompanion.insert(
        deckId: deckId,
        mode: StudyMode.guess,
        startedAt: DateTime(2026, 4, 3, 8),
        totalCards: 3,
      ),
    );

    final replaced = await dataSource.save(
      StudySessionsTableCompanion(
        id: Value<int>(inserted.id),
        deckId: Value<int>(deckId),
        mode: const Value<StudyMode>(StudyMode.guess),
        startedAt: Value<DateTime>(inserted.startedAt),
        completedAt: Value<DateTime?>(DateTime(2026, 4, 3, 8, 4)),
        totalCards: const Value<int>(3),
        correctCount: const Value<int>(2),
        wrongCount: const Value<int>(1),
        durationSeconds: const Value<int>(240),
      ),
    );

    expect(replaced.id, inserted.id);
    expect(replaced.completedAt, DateTime(2026, 4, 3, 8, 4));
    expect(replaced.correctCount, 2);
    expect(replaced.wrongCount, 1);
    expect(replaced.durationSeconds, 240);
  });

  test('watchAll returns rows in descending startedAt order', () async {
    final older = await dataSource.save(
      StudySessionsTableCompanion.insert(
        deckId: deckId,
        mode: StudyMode.review,
        startedAt: DateTime(2026, 4, 3, 7),
        totalCards: 2,
      ),
    );
    final newer = await dataSource.save(
      StudySessionsTableCompanion.insert(
        deckId: deckId,
        mode: StudyMode.fill,
        startedAt: DateTime(2026, 4, 3, 9),
        totalCards: 5,
      ),
    );

    final rows = await dataSource.watchAll().first;

    expect(rows.map((row) => row.id).toList(), [newer.id, older.id]);
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
