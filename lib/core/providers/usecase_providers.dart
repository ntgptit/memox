import 'package:memox/core/providers/repository_providers.dart';
import 'package:memox/core/providers/service_providers.dart';
import 'package:memox/features/decks/domain/usecases/create_deck.dart';
import 'package:memox/features/cards/domain/usecases/get_due_cards.dart';
import 'package:memox/features/cards/domain/usecases/get_flashcards.dart';
import 'package:memox/features/decks/domain/usecases/get_decks.dart';
import 'package:memox/features/decks/domain/usecases/reorder_decks.dart';
import 'package:memox/features/folders/domain/usecases/can_create_deck.dart';
import 'package:memox/features/folders/domain/usecases/can_create_subfolder.dart';
import 'package:memox/features/folders/domain/usecases/create_folder.dart';
import 'package:memox/features/folders/domain/usecases/delete_folder.dart';
import 'package:memox/features/folders/domain/usecases/get_folder_breadcrumb.dart';
import 'package:memox/features/folders/domain/usecases/get_folder_delete_summary.dart';
import 'package:memox/features/folders/domain/usecases/get_root_folders.dart';
import 'package:memox/features/folders/domain/usecases/get_subfolders.dart';
import 'package:memox/features/folders/domain/usecases/reorder_folders.dart';
import 'package:memox/features/folders/domain/usecases/update_folder.dart';
import 'package:memox/features/settings/domain/usecases/get_settings.dart';
import 'package:memox/features/settings/domain/usecases/update_locale.dart';
import 'package:memox/features/settings/domain/usecases/update_seed_color.dart';
import 'package:memox/features/settings/domain/usecases/update_theme_mode.dart';
import 'package:memox/features/statistics/domain/usecases/get_statistics_overview.dart';
import 'package:memox/features/study/domain/usecases/start_study_session.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'usecase_providers.g.dart';

@riverpod
GetSettingsUseCase getSettingsUseCase(Ref ref) {
  return GetSettingsUseCase(ref.watch(settingsRepositoryProvider));
}

@riverpod
UpdateThemeModeUseCase updateThemeModeUseCase(Ref ref) {
  return UpdateThemeModeUseCase(ref.watch(settingsRepositoryProvider));
}

@riverpod
UpdateSeedColorUseCase updateSeedColorUseCase(Ref ref) {
  return UpdateSeedColorUseCase(ref.watch(settingsRepositoryProvider));
}

@riverpod
UpdateLocaleUseCase updateLocaleUseCase(Ref ref) {
  return UpdateLocaleUseCase(ref.watch(settingsRepositoryProvider));
}

@riverpod
GetRootFoldersUseCase getRootFoldersUseCase(Ref ref) {
  return GetRootFoldersUseCase(ref.watch(folderRepositoryProvider));
}

@riverpod
GetSubfoldersUseCase getSubfoldersUseCase(Ref ref) {
  return GetSubfoldersUseCase(ref.watch(folderRepositoryProvider));
}

@riverpod
CreateFolderUseCase createFolderUseCase(Ref ref) {
  return CreateFolderUseCase(
    folderRepo: ref.watch(folderRepositoryProvider),
    logger: ref.watch(appLoggerProvider),
  );
}

@riverpod
DeleteFolderUseCase deleteFolderUseCase(Ref ref) {
  return DeleteFolderUseCase(
    folderRepo: ref.watch(folderRepositoryProvider),
    logger: ref.watch(appLoggerProvider),
  );
}

@riverpod
UpdateFolderUseCase updateFolderUseCase(Ref ref) => UpdateFolderUseCase(
  folderRepo: ref.watch(folderRepositoryProvider),
  logger: ref.watch(appLoggerProvider),
);

@riverpod
CanCreateSubfolderUseCase canCreateSubfolderUseCase(Ref ref) {
  return CanCreateSubfolderUseCase(ref.watch(folderRepositoryProvider));
}

@riverpod
CanCreateDeckUseCase canCreateDeckUseCase(Ref ref) {
  return CanCreateDeckUseCase(ref.watch(folderRepositoryProvider));
}

@riverpod
GetFolderBreadcrumbUseCase getFolderBreadcrumbUseCase(Ref ref) {
  return GetFolderBreadcrumbUseCase(ref.watch(folderRepositoryProvider));
}

@riverpod
GetFolderDeleteSummaryUseCase getFolderDeleteSummaryUseCase(Ref ref) {
  return GetFolderDeleteSummaryUseCase(ref.watch(folderRepositoryProvider));
}

@riverpod
ReorderFoldersUseCase reorderFoldersUseCase(Ref ref) {
  return ReorderFoldersUseCase(ref.watch(folderRepositoryProvider));
}

@riverpod
GetDecksUseCase getDecksUseCase(Ref ref) {
  return GetDecksUseCase(ref.watch(deckRepositoryProvider));
}

@riverpod
CreateDeckUseCase createDeckUseCase(Ref ref) {
  return CreateDeckUseCase(ref.watch(deckRepositoryProvider));
}

@riverpod
ReorderDecksUseCase reorderDecksUseCase(Ref ref) {
  return ReorderDecksUseCase(ref.watch(deckRepositoryProvider));
}

@riverpod
GetFlashcardsUseCase getFlashcardsUseCase(Ref ref) {
  return GetFlashcardsUseCase(ref.watch(flashcardRepositoryProvider));
}

@riverpod
GetDueCardsUseCase getDueCardsUseCase(Ref ref) {
  return GetDueCardsUseCase(ref.watch(flashcardRepositoryProvider));
}

@riverpod
StartStudySessionUseCase startStudySessionUseCase(Ref ref) {
  return StartStudySessionUseCase(ref.watch(studyRepositoryProvider));
}

@riverpod
GetStatisticsOverviewUseCase getStatisticsOverviewUseCase(Ref ref) {
  return GetStatisticsOverviewUseCase(ref.watch(statisticsRepositoryProvider));
}
