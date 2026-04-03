import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:memox/core/database/app_database.dart';
import 'package:memox/core/design/card_status.dart';
import 'package:memox/core/design/study_mode.dart';
import 'package:memox/core/logging/logger_impl.dart';
import 'package:memox/features/statistics/data/datasources/statistics_local_datasource.dart';
import 'package:memox/features/statistics/data/repositories/statistics_repository_impl.dart';
import 'package:memox/features/statistics/domain/repositories/statistics_repository.dart';

final class StatisticsTestHarness {
  StatisticsTestHarness(this.now)
    : database = AppDatabase(NativeDatabase.memory());

  final DateTime now;
  final AppDatabase database;
  late final int folderId;
  late final int primaryDeckId;
  late final int secondaryDeckId;

  StatisticsRepository createRepository() => StatisticsRepositoryImpl(
    localDataSource: StatisticsLocalDataSourceImpl(
      cardDao: database.cardDao,
      cardReviewDao: database.cardReviewDao,
      deckDao: database.deckDao,
      studySessionDao: database.studySessionDao,
    ),
    logger: const LoggerImpl(),
    now: () => now,
  );

  Future<void> seedBase() async {
    folderId = await database.folderDao.insertFolder(
      const FoldersTableCompanion(name: Value<String>('Folder')),
    );
    primaryDeckId = await database.deckDao.insertDeck(
      DecksTableCompanion(
        name: const Value<String>('Core'),
        folderId: Value<int>(folderId),
      ),
    );
    secondaryDeckId = await database.deckDao.insertDeck(
      DecksTableCompanion(
        name: const Value<String>('Hard'),
        folderId: Value<int>(folderId),
      ),
    );
  }

  Future<int> insertCard({
    required int deckId,
    required String front,
    required String back,
    CardStatus status = CardStatus.newCard,
  }) => database.cardDao.insertCard(
    CardsTableCompanion(
      deckId: Value<int>(deckId),
      front: Value<String>(front),
      back: Value<String>(back),
      status: Value<CardStatus>(status),
    ),
  );

  Future<int> insertSession({
    required int deckId,
    required StudyMode mode,
    required DateTime completedAt,
    required int totalCards,
    required int durationSeconds,
    int correctCount = 0,
    int wrongCount = 0,
  }) => database.studySessionDao.insertSession(
    StudySessionsTableCompanion.insert(
      deckId: deckId,
      mode: mode,
      startedAt: completedAt.subtract(const Duration(minutes: 5)),
      completedAt: Value<DateTime?>(completedAt),
      totalCards: totalCards,
      correctCount: Value<int>(correctCount),
      wrongCount: Value<int>(wrongCount),
      durationSeconds: Value<int>(durationSeconds),
    ),
  );

  Future<void> insertReview({
    required int cardId,
    required int sessionId,
    required StudyMode mode,
    required bool isCorrect,
    int? rating,
    DateTime? reviewedAt,
  }) => database.cardReviewDao.insertReview(
    CardReviewsTableCompanion.insert(
      cardId: cardId,
      sessionId: sessionId,
      mode: mode,
      rating: Value<int?>(rating),
      isCorrect: isCorrect,
      reviewedAt: reviewedAt ?? now,
    ),
  );

  Future<void> dispose() => database.close();
}
