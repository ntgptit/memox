import 'package:memox/core/providers/datasource_providers.dart';
import 'package:memox/core/providers/service_providers.dart';
import 'package:memox/core/providers/storage_providers.dart';
import 'package:memox/features/cards/data/repositories/flashcard_repository_impl.dart';
import 'package:memox/features/cards/domain/repositories/flashcard_repository.dart';
import 'package:memox/features/decks/data/repositories/deck_repository_impl.dart';
import 'package:memox/features/decks/domain/repositories/deck_repository.dart';
import 'package:memox/features/folders/data/repositories/folder_repository_impl.dart';
import 'package:memox/features/folders/domain/repositories/folder_repository.dart';
import 'package:memox/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:memox/features/settings/domain/repositories/settings_repository.dart';
import 'package:memox/features/statistics/data/repositories/statistics_repository_impl.dart';
import 'package:memox/features/statistics/domain/repositories/statistics_repository.dart';
import 'package:memox/features/study/data/repositories/study_repository_impl.dart';
import 'package:memox/features/study/domain/repositories/study_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'repository_providers.g.dart';

@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref ref) {
  return SettingsRepositoryImpl(
    sharedPreferencesLoader: () => ref.read(sharedPreferencesProvider.future),
    logger: ref.watch(appLoggerProvider),
  );
}

@Riverpod(keepAlive: true)
FolderRepository folderRepository(Ref ref) {
  return FolderRepositoryImpl(
    localDataSource: ref.watch(folderLocalDataSourceProvider),
    logger: ref.watch(appLoggerProvider),
  );
}

@Riverpod(keepAlive: true)
DeckRepository deckRepository(Ref ref) {
  return DeckRepositoryImpl(
    localDataSource: ref.watch(deckLocalDataSourceProvider),
    logger: ref.watch(appLoggerProvider),
  );
}

@Riverpod(keepAlive: true)
FlashcardRepository flashcardRepository(Ref ref) {
  return FlashcardRepositoryImpl(
    localDataSource: ref.watch(flashcardLocalDataSourceProvider),
    logger: ref.watch(appLoggerProvider),
  );
}

@Riverpod(keepAlive: true)
StudyRepository studyRepository(Ref ref) {
  return StudyRepositoryImpl(
    localDataSource: ref.watch(studyLocalDataSourceProvider),
    logger: ref.watch(appLoggerProvider),
  );
}

@Riverpod(keepAlive: true)
StatisticsRepository statisticsRepository(Ref ref) {
  return StatisticsRepositoryImpl(
    localDataSource: ref.watch(statisticsLocalDataSourceProvider),
    logger: ref.watch(appLoggerProvider),
  );
}
