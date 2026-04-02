import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/providers/database_providers.dart';
import 'package:memox/core/providers/network_providers.dart';
import 'package:memox/features/cards/data/datasources/flashcard_local_datasource.dart';
import 'package:memox/features/decks/data/datasources/deck_local_datasource.dart';
import 'package:memox/features/folders/data/datasources/folder_local_datasource.dart';
import 'package:memox/features/folders/data/datasources/folder_remote_datasource.dart';
import 'package:memox/features/settings/domain/entities/app_setting.dart';
import 'package:memox/features/settings/presentation/providers/settings_provider.dart';
import 'package:memox/features/statistics/data/datasources/statistics_local_datasource.dart';
import 'package:memox/features/study/data/datasources/study_local_datasource.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'datasource_providers.g.dart';

@Riverpod(keepAlive: true)
FolderLocalDataSource folderLocalDataSource(Ref ref) {
  final isar = ref.watch(isarProvider).requireValue;
  return FolderLocalDataSourceImpl(isar);
}

@Riverpod(keepAlive: true)
FolderRemoteDataSource? folderRemoteDataSource(Ref ref) {
  final settings = ref.watch(settingsProvider);
  final syncEnabled = settings.maybeWhen(
    data: (AppSettings value) => value.syncEnabled,
    orElse: () => false,
  );

  if (!syncEnabled) {
    return null;
  }

  return FolderRemoteDataSourceImpl(ref.watch(syncApiProvider));
}

@Riverpod(keepAlive: true)
DeckLocalDataSource deckLocalDataSource(Ref ref) {
  final isar = ref.watch(isarProvider).requireValue;
  return DeckLocalDataSourceImpl(isar);
}

@Riverpod(keepAlive: true)
FlashcardLocalDataSource flashcardLocalDataSource(Ref ref) {
  final isar = ref.watch(isarProvider).requireValue;
  return FlashcardLocalDataSourceImpl(isar);
}

@Riverpod(keepAlive: true)
StudyLocalDataSource studyLocalDataSource(Ref ref) {
  final isar = ref.watch(isarProvider).requireValue;
  return StudyLocalDataSourceImpl(isar);
}

@Riverpod(keepAlive: true)
StatisticsLocalDataSource statisticsLocalDataSource(Ref ref) {
  final isar = ref.watch(isarProvider).requireValue;
  return StatisticsLocalDataSourceImpl(isar);
}
