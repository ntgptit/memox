import 'package:memox/core/providers/repository_providers.dart';
import 'package:memox/core/providers/usecase_providers.dart';
import 'package:memox/features/decks/domain/entities/deck_entity.dart';
import 'package:memox/features/folders/domain/entities/folder_delete_summary.dart';
import 'package:memox/features/folders/domain/entities/folder_entity.dart';
import 'package:memox/features/folders/domain/entities/folder_recursive_stats.dart';
import 'package:memox/features/folders/presentation/providers/folders_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'folder_detail_provider.g.dart';

enum ContentType { subfolders, decks, empty }

typedef FolderDetailData =
    ({
      FolderEntity folder,
      ContentType contentType,
      int totalCards,
      double masteryPercentage,
      int subfolderCount,
      int deckCount,
      List<FolderEntity> subfolders,
      List<DeckEntity> decks,
    });

@riverpod
AsyncValue<FolderDetailData> folderDetail(Ref ref, int folderId) {
  final folderAsync = ref.watch(folderByIdProvider(folderId));
  final subfoldersAsync = ref.watch(subfolderProvider(folderId));
  final decksAsync = ref.watch(decksByFolderProvider(folderId));
  final statsAsync = ref.watch(folderRecursiveStatsProvider(folderId));
  final error =
      folderAsync.asError ??
      subfoldersAsync.asError ??
      decksAsync.asError ??
      statsAsync.asError;

  if (error != null) {
    return AsyncValue<FolderDetailData>.error(error.error, error.stackTrace);
  }

  if (folderAsync.isLoading ||
      subfoldersAsync.isLoading ||
      decksAsync.isLoading ||
      statsAsync.isLoading) {
    return const AsyncValue<FolderDetailData>.loading();
  }

  final folder = folderAsync.requireValue;

  if (folder == null) {
    return AsyncValue<FolderDetailData>.error(
      StateError('Folder $folderId not found'),
      StackTrace.current,
    );
  }

  final subfolders = subfoldersAsync.requireValue;
  final directDecks = decksAsync.requireValue;
  final stats = statsAsync.requireValue;
  final contentType = switch ((subfolders.isNotEmpty, directDecks.isNotEmpty)) {
    (true, _) => ContentType.subfolders,
    (false, true) => ContentType.decks,
    _ => ContentType.empty,
  };

  return AsyncValue<FolderDetailData>.data(
    (
      folder: folder,
      contentType: contentType,
      totalCards: stats.totalCards,
      masteryPercentage: stats.masteryPercentage,
      subfolderCount: subfolders.length,
      deckCount: directDecks.length,
      subfolders: subfolders,
      decks: directDecks,
    ),
  );
}

@riverpod
Stream<FolderEntity?> folderById(Ref ref, int folderId) =>
    ref.watch(folderRepositoryProvider).watchById(folderId);

@riverpod
Future<List<FolderEntity>> folderBreadcrumb(Ref ref, int folderId) => ref.watch(getFolderBreadcrumbUseCaseProvider).call(folderId);

@riverpod
Future<FolderDeleteSummary> folderDeleteSummary(Ref ref, int folderId) => ref.watch(getFolderDeleteSummaryUseCaseProvider).call(folderId);

@riverpod
bool canCreateSubfolder(Ref ref, int folderId) {
  final detail = _valueOrNull(ref.watch(folderDetailProvider(folderId)));
  return detail?.contentType != ContentType.decks;
}

@riverpod
bool canCreateDeck(Ref ref, int folderId) {
  final detail = _valueOrNull(ref.watch(folderDetailProvider(folderId)));
  return detail?.contentType != ContentType.subfolders;
}

T? _valueOrNull<T>(AsyncValue<T> value) => switch (value) {
    AsyncData<T>(:final value) => value,
    _ => null,
  };
