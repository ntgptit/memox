import 'package:memox/core/providers/database_providers.dart';
import 'package:memox/features/cards/data/datasources/flashcard_local_datasource.dart';
import 'package:memox/features/decks/data/datasources/deck_local_datasource.dart';
import 'package:memox/features/folders/data/datasources/folder_local_datasource.dart';
import 'package:memox/features/statistics/data/datasources/statistics_local_datasource.dart';
import 'package:memox/features/study/data/datasources/study_local_datasource.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'datasource_providers.g.dart';

@Riverpod(keepAlive: true)
FolderLocalDataSource folderLocalDataSource(Ref ref) {
  return FolderLocalDataSourceImpl(ref.watch(folderDaoProvider));
}

@Riverpod(keepAlive: true)
DeckLocalDataSource deckLocalDataSource(Ref ref) {
  return DeckLocalDataSourceImpl(ref.watch(deckDaoProvider));
}

@Riverpod(keepAlive: true)
FlashcardLocalDataSource flashcardLocalDataSource(Ref ref) {
  return FlashcardLocalDataSourceImpl(ref.watch(cardDaoProvider));
}

@Riverpod(keepAlive: true)
StudyLocalDataSource studyLocalDataSource(Ref ref) {
  return StudyLocalDataSourceImpl(ref.watch(studySessionDaoProvider));
}

@Riverpod(keepAlive: true)
StatisticsLocalDataSource statisticsLocalDataSource(Ref ref) {
  return StatisticsLocalDataSourceImpl(
    () => ref.watch(cardReviewDaoProvider).watchTotalReviews(),
  );
}
