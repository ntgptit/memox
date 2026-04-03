import 'package:memox/core/providers/database_providers.dart';
import 'package:memox/core/providers/datasource_providers.dart';
import 'package:memox/core/providers/service_providers.dart';
import 'package:memox/core/providers/storage_providers.dart';
import 'package:memox/features/cards/data/repositories/flashcard_repository_impl.dart';
import 'package:memox/features/cards/domain/repositories/flashcard_repository.dart';
import 'package:memox/features/decks/data/repositories/deck_repository_impl.dart';
import 'package:memox/features/decks/domain/repositories/deck_repository.dart';
import 'package:memox/features/folders/data/repositories/folder_repository_impl.dart';
import 'package:memox/features/folders/domain/repositories/folder_repository.dart';
import 'package:memox/features/settings/data/repositories/settings_data_repository_impl.dart';
import 'package:memox/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:memox/features/settings/domain/repositories/settings_data_repository.dart';
import 'package:memox/features/settings/domain/repositories/settings_repository.dart';
import 'package:memox/features/statistics/data/repositories/statistics_repository_impl.dart';
import 'package:memox/features/statistics/domain/repositories/statistics_repository.dart';
import 'package:memox/features/study/data/repositories/study_repository_impl.dart';
import 'package:memox/features/study/domain/repositories/study_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'repository_providers.g.dart';

@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref ref) => SettingsRepositoryImpl(
    sharedPreferencesLoader: () => ref.read(sharedPreferencesProvider.future),
    logger: ref.watch(appLoggerProvider),
  );

@Riverpod(keepAlive: true)
SettingsDataRepository settingsDataRepository(Ref ref) => SettingsDataRepositoryImpl(
    database: ref.watch(appDatabaseProvider),
    logger: ref.watch(appLoggerProvider),
  );

@Riverpod(keepAlive: true)
FolderRepository folderRepository(Ref ref) => FolderRepositoryImpl(
    database: ref.watch(appDatabaseProvider),
    localDataSource: ref.watch(folderLocalDataSourceProvider),
    deckLocalDataSource: ref.watch(deckLocalDataSourceProvider),
    flashcardLocalDataSource: ref.watch(flashcardLocalDataSourceProvider),
    cardReviewDao: ref.watch(cardReviewDaoProvider),
    logger: ref.watch(appLoggerProvider),
  );

@Riverpod(keepAlive: true)
DeckRepository deckRepository(Ref ref) => DeckRepositoryImpl(
    database: ref.watch(appDatabaseProvider),
    localDataSource: ref.watch(deckLocalDataSourceProvider),
    flashcardLocalDataSource: ref.watch(flashcardLocalDataSourceProvider),
    cardReviewDao: ref.watch(cardReviewDaoProvider),
    logger: ref.watch(appLoggerProvider),
  );

@Riverpod(keepAlive: true)
FlashcardRepository flashcardRepository(Ref ref) => FlashcardRepositoryImpl(
    database: ref.watch(appDatabaseProvider),
    localDataSource: ref.watch(flashcardLocalDataSourceProvider),
    cardReviewDao: ref.watch(cardReviewDaoProvider),
    logger: ref.watch(appLoggerProvider),
  );

@Riverpod(keepAlive: true)
StudyRepository studyRepository(Ref ref) => StudyRepositoryImpl(
    localDataSource: ref.watch(studyLocalDataSourceProvider),
    logger: ref.watch(appLoggerProvider),
  );

@Riverpod(keepAlive: true)
StatisticsRepository statisticsRepository(Ref ref) => StatisticsRepositoryImpl(
    localDataSource: ref.watch(statisticsLocalDataSourceProvider),
    logger: ref.watch(appLoggerProvider),
  );
