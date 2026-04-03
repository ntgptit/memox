import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/database/app_database.dart';
import 'package:memox/core/design/study_mode.dart';
import 'package:memox/core/logging/logger_impl.dart';
import 'package:memox/features/settings/data/repositories/settings_data_repository_impl.dart';

void main() {
  late AppDatabase database;
  late SettingsDataRepositoryImpl repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = SettingsDataRepositoryImpl(
      database: database,
      logger: const LoggerImpl(),
    );
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'export and import round-trip preserves folders, decks, and cards',
    () async {
      final folderId = await database.folderDao.insertFolder(
        const FoldersTableCompanion(name: Value<String>('Languages')),
      );
      final deckId = await database.deckDao.insertDeck(
        DecksTableCompanion(
          id: const Value<int>(7),
          name: const Value<String>('Korean'),
          folderId: Value<int>(folderId),
        ),
      );
      await database.cardDao.insertCard(
        CardsTableCompanion(
          id: const Value<int>(11),
          deckId: Value<int>(deckId),
          front: const Value<String>('물'),
          back: const Value<String>('water'),
        ),
      );

      final exported = await repository.exportCardsJson();
      final payload = jsonDecode(exported) as Map<String, dynamic>;
      final importedDatabase = AppDatabase(NativeDatabase.memory());
      final importedRepository = SettingsDataRepositoryImpl(
        database: importedDatabase,
        logger: const LoggerImpl(),
      );
      addTearDown(importedDatabase.close);

      final summary = await importedRepository.importCardsJson(exported);
      final folders = await importedDatabase.folderDao.getAll();
      final decks = await importedDatabase.deckDao.getAll();
      final cards = await importedDatabase.cardDao.getAll();

      expect(payload['version'], SettingsDataRepositoryImpl.exportVersion);
      expect(summary.folderCount, 1);
      expect(summary.deckCount, 1);
      expect(summary.cardCount, 1);
      expect(folders.single.name, 'Languages');
      expect(decks.single.name, 'Korean');
      expect(cards.single.front, '물');
      expect(cards.single.back, 'water');
    },
  );

  test('clearStudyHistory keeps cards intact', () async {
    final folderId = await database.folderDao.insertFolder(
      const FoldersTableCompanion(name: Value<String>('Folder')),
    );
    final deckId = await database.deckDao.insertDeck(
      DecksTableCompanion(
        name: const Value<String>('Deck'),
        folderId: Value<int>(folderId),
      ),
    );
    final cardId = await database.cardDao.insertCard(
      CardsTableCompanion(
        deckId: Value<int>(deckId),
        front: const Value<String>('Front'),
        back: const Value<String>('Back'),
      ),
    );
    final sessionId = await database.studySessionDao.insertSession(
      StudySessionsTableCompanion.insert(
        deckId: deckId,
        mode: StudyMode.review,
        startedAt: DateTime(2026, 4, 3, 8),
        completedAt: Value<DateTime?>(DateTime(2026, 4, 3, 8, 5)),
        totalCards: 1,
      ),
    );
    await database.cardReviewDao.insertReview(
      CardReviewsTableCompanion.insert(
        cardId: cardId,
        sessionId: sessionId,
        mode: StudyMode.review,
        isCorrect: true,
        reviewedAt: DateTime(2026, 4, 3, 8, 5),
      ),
    );

    final summary = await repository.clearStudyHistory();

    expect(summary.sessionCount, 1);
    expect(summary.reviewCount, 1);
    expect(await database.studySessionDao.getAll(), isEmpty);
    expect(await database.cardReviewDao.getAll(), isEmpty);
    expect(await database.cardDao.getAll(), hasLength(1));
  });
}
