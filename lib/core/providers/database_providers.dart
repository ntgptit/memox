import 'package:memox/core/database/app_database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'database_providers.g.dart';

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
}

@Riverpod(keepAlive: true)
FolderDao folderDao(Ref ref) => ref.watch(appDatabaseProvider).folderDao;

@Riverpod(keepAlive: true)
DeckDao deckDao(Ref ref) => ref.watch(appDatabaseProvider).deckDao;

@Riverpod(keepAlive: true)
CardDao cardDao(Ref ref) => ref.watch(appDatabaseProvider).cardDao;

@Riverpod(keepAlive: true)
StudySessionDao studySessionDao(Ref ref) => ref.watch(appDatabaseProvider).studySessionDao;

@Riverpod(keepAlive: true)
CardReviewDao cardReviewDao(Ref ref) => ref.watch(appDatabaseProvider).cardReviewDao;

@Riverpod(keepAlive: true)
SearchDao searchDao(Ref ref) => ref.watch(appDatabaseProvider).searchDao;
