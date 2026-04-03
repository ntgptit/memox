import 'package:memox/core/design/card_status.dart';
import 'package:memox/core/providers/usecase_providers.dart';
import 'package:memox/features/decks/domain/entities/deck_entity.dart';
import 'package:memox/features/folders/domain/entities/folder_delete_summary.dart';
import 'package:memox/features/folders/domain/entities/folder_entity.dart';
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
  final foldersAsync = ref.watch(allFoldersProvider);
  final decksAsync = ref.watch(allDecksProvider);
  final cardsAsync = ref.watch(allFlashcardsProvider);
  final error = foldersAsync.asError ?? decksAsync.asError ?? cardsAsync.asError;

  if (error != null) {
    return AsyncValue<FolderDetailData>.error(error.error, error.stackTrace);
  }

  if (foldersAsync.isLoading || decksAsync.isLoading || cardsAsync.isLoading) {
    return const AsyncValue<FolderDetailData>.loading();
  }

  final folders = foldersAsync.requireValue;
  final folder = _folderById(folders, folderId);

  if (folder == null) {
    return AsyncValue<FolderDetailData>.error(
      StateError('Folder $folderId not found'),
      StackTrace.current,
    );
  }

  final decks = decksAsync.requireValue;
  final subfolders = _subfoldersFor(folders, folderId);
  final directDecks = decks.where((DeckEntity deck) => deck.folderId == folderId).toList();
  final descendantIds = _descendantIds(folders, folderId);
  final folderIdsInTree = <int>{folderId, ...descendantIds};
  final deckIdsInTree = decks
      .where((DeckEntity deck) => folderIdsInTree.contains(deck.folderId))
      .map((DeckEntity deck) => deck.id)
      .toSet();
  final cards = cardsAsync.requireValue.where((card) => deckIdsInTree.contains(card.deckId)).toList();
  final masteredCards = cards.where((card) => card.status == CardStatus.mastered).length;
  final contentType = switch ((subfolders.isNotEmpty, directDecks.isNotEmpty)) {
    (true, _) => ContentType.subfolders,
    (false, true) => ContentType.decks,
    _ => ContentType.empty,
  };

  return AsyncValue<FolderDetailData>.data(
    (
      folder: folder,
      contentType: contentType,
      totalCards: cards.length,
      masteryPercentage: cards.isEmpty ? 0 : masteredCards / cards.length,
      subfolderCount: subfolders.length,
      deckCount: directDecks.length,
      subfolders: subfolders,
      decks: directDecks,
    ),
  );
}

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

List<int> _descendantIds(List<FolderEntity> folders, int folderId) {
  final descendantIds = <int>[];
  final queue = <int>[folderId];

  while (queue.isNotEmpty) {
    final currentId = queue.removeAt(0);
    final children = _subfoldersFor(folders, currentId);
    for (final child in children) {
      descendantIds.add(child.id);
      queue.add(child.id);
    }
  }

  return descendantIds;
}

FolderEntity? _folderById(List<FolderEntity> folders, int folderId) {
  for (final folder in folders) {
    if (folder.id == folderId) {
      return folder;
    }
  }

  return null;
}

List<FolderEntity> _subfoldersFor(List<FolderEntity> folders, int folderId) => folders.where((FolderEntity folder) => folder.parentId == folderId).toList();
