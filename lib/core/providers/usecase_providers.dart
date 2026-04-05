import 'package:memox/core/providers/repository_providers.dart';
import 'package:memox/core/providers/service_providers.dart';
import 'package:memox/features/cards/domain/usecases/create_card.dart';
import 'package:memox/features/cards/domain/usecases/create_cards_batch.dart';
import 'package:memox/features/cards/domain/usecases/delete_card.dart';
import 'package:memox/features/cards/domain/usecases/get_cards_by_deck.dart';
import 'package:memox/features/cards/domain/usecases/get_due_cards.dart';
import 'package:memox/features/cards/domain/usecases/get_flashcards.dart';
import 'package:memox/features/cards/domain/usecases/update_card.dart';
import 'package:memox/features/decks/domain/usecases/create_deck.dart';
import 'package:memox/features/decks/domain/usecases/delete_deck.dart';
import 'package:memox/features/decks/domain/usecases/get_deck_stats.dart';
import 'package:memox/features/decks/domain/usecases/get_decks.dart';
import 'package:memox/features/decks/domain/usecases/get_decks_by_folder.dart';
import 'package:memox/features/decks/domain/usecases/reorder_decks.dart';
import 'package:memox/features/decks/domain/usecases/update_deck.dart';
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
import 'package:memox/features/search/domain/usecases/search_items.dart';
import 'package:memox/features/settings/domain/usecases/get_settings.dart';
import 'package:memox/features/settings/domain/usecases/update_locale.dart';
import 'package:memox/features/settings/domain/usecases/update_seed_color.dart';
import 'package:memox/features/settings/domain/usecases/update_theme_mode.dart';
import 'package:memox/features/statistics/domain/usecases/get_difficult_cards.dart';
import 'package:memox/features/statistics/domain/usecases/get_mastery_breakdown.dart';
import 'package:memox/features/statistics/domain/usecases/get_streak.dart';
import 'package:memox/features/statistics/domain/usecases/get_study_stats.dart';
import 'package:memox/features/statistics/domain/usecases/get_weekly_activity.dart';
import 'package:memox/features/study/domain/usecases/complete_study_session.dart';
import 'package:memox/features/study/domain/usecases/start_study_session.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'usecase_providers.g.dart';

@riverpod
GetSettingsUseCase getSettingsUseCase(Ref ref) =>
    GetSettingsUseCase(ref.watch(settingsRepositoryProvider));

@riverpod
UpdateThemeModeUseCase updateThemeModeUseCase(Ref ref) =>
    UpdateThemeModeUseCase(ref.watch(settingsRepositoryProvider));

@riverpod
UpdateSeedColorUseCase updateSeedColorUseCase(Ref ref) =>
    UpdateSeedColorUseCase(ref.watch(settingsRepositoryProvider));

@riverpod
UpdateLocaleUseCase updateLocaleUseCase(Ref ref) =>
    UpdateLocaleUseCase(ref.watch(settingsRepositoryProvider));

@riverpod
GetRootFoldersUseCase getRootFoldersUseCase(Ref ref) =>
    GetRootFoldersUseCase(ref.watch(folderRepositoryProvider));

@riverpod
GetSubfoldersUseCase getSubfoldersUseCase(Ref ref) =>
    GetSubfoldersUseCase(ref.watch(folderRepositoryProvider));

@riverpod
CreateFolderUseCase createFolderUseCase(Ref ref) => CreateFolderUseCase(
  folderRepo: ref.watch(folderRepositoryProvider),
  logger: ref.watch(appLoggerProvider),
);

@riverpod
DeleteFolderUseCase deleteFolderUseCase(Ref ref) => DeleteFolderUseCase(
  folderRepo: ref.watch(folderRepositoryProvider),
  logger: ref.watch(appLoggerProvider),
);

@riverpod
UpdateFolderUseCase updateFolderUseCase(Ref ref) => UpdateFolderUseCase(
  folderRepo: ref.watch(folderRepositoryProvider),
  logger: ref.watch(appLoggerProvider),
);

@riverpod
CanCreateSubfolderUseCase canCreateSubfolderUseCase(Ref ref) =>
    CanCreateSubfolderUseCase(ref.watch(folderRepositoryProvider));

@riverpod
CanCreateDeckUseCase canCreateDeckUseCase(Ref ref) =>
    CanCreateDeckUseCase(ref.watch(folderRepositoryProvider));

@riverpod
GetFolderBreadcrumbUseCase getFolderBreadcrumbUseCase(Ref ref) =>
    GetFolderBreadcrumbUseCase(ref.watch(folderRepositoryProvider));

@riverpod
GetFolderDeleteSummaryUseCase getFolderDeleteSummaryUseCase(Ref ref) =>
    GetFolderDeleteSummaryUseCase(ref.watch(folderRepositoryProvider));

@riverpod
ReorderFoldersUseCase reorderFoldersUseCase(Ref ref) =>
    ReorderFoldersUseCase(ref.watch(folderRepositoryProvider));

@riverpod
GetDecksUseCase getDecksUseCase(Ref ref) =>
    GetDecksUseCase(ref.watch(deckRepositoryProvider));

@riverpod
CreateDeckUseCase createDeckUseCase(Ref ref) => CreateDeckUseCase(
  repository: ref.watch(deckRepositoryProvider),
  canCreateDeckUseCase: ref.watch(canCreateDeckUseCaseProvider),
);

@riverpod
UpdateDeckUseCase updateDeckUseCase(Ref ref) => UpdateDeckUseCase(
  repository: ref.watch(deckRepositoryProvider),
  logger: ref.watch(appLoggerProvider),
);

@riverpod
ReorderDecksUseCase reorderDecksUseCase(Ref ref) =>
    ReorderDecksUseCase(ref.watch(deckRepositoryProvider));

@riverpod
GetDecksByFolderUseCase getDecksByFolderUseCase(Ref ref) =>
    GetDecksByFolderUseCase(ref.watch(deckRepositoryProvider));

@riverpod
DeleteDeckUseCase deleteDeckUseCase(Ref ref) =>
    DeleteDeckUseCase(ref.watch(deckRepositoryProvider));

@riverpod
GetDeckStatsUseCase getDeckStatsUseCase(Ref ref) =>
    GetDeckStatsUseCase(ref.watch(flashcardRepositoryProvider));

@riverpod
GetFlashcardsUseCase getFlashcardsUseCase(Ref ref) =>
    GetFlashcardsUseCase(ref.watch(flashcardRepositoryProvider));

@riverpod
GetDueCardsUseCase getDueCardsUseCase(Ref ref) =>
    GetDueCardsUseCase(ref.watch(flashcardRepositoryProvider));

@riverpod
GetCardsByDeckUseCase getCardsByDeckUseCase(Ref ref) =>
    GetCardsByDeckUseCase(ref.watch(flashcardRepositoryProvider));

@riverpod
CreateCardUseCase createCardUseCase(Ref ref) =>
    CreateCardUseCase(ref.watch(flashcardRepositoryProvider));

@riverpod
CreateCardsBatchUseCase createCardsBatchUseCase(Ref ref) =>
    CreateCardsBatchUseCase(ref.watch(flashcardRepositoryProvider));

@riverpod
UpdateCardUseCase updateCardUseCase(Ref ref) =>
    UpdateCardUseCase(ref.watch(flashcardRepositoryProvider));

@riverpod
DeleteCardUseCase deleteCardUseCase(Ref ref) =>
    DeleteCardUseCase(ref.watch(flashcardRepositoryProvider));

@riverpod
CompleteStudySessionUseCase completeStudySessionUseCase(Ref ref) =>
    CompleteStudySessionUseCase(ref.watch(studyRepositoryProvider));

@riverpod
StartStudySessionUseCase startStudySessionUseCase(Ref ref) =>
    StartStudySessionUseCase(ref.watch(studyRepositoryProvider));

@riverpod
GetStreakUseCase getStreakUseCase(Ref ref) =>
    GetStreakUseCase(ref.watch(statisticsRepositoryProvider));

@riverpod
GetWeeklyActivityUseCase getWeeklyActivityUseCase(Ref ref) =>
    GetWeeklyActivityUseCase(ref.watch(statisticsRepositoryProvider));

@riverpod
GetMasteryBreakdownUseCase getMasteryBreakdownUseCase(Ref ref) =>
    GetMasteryBreakdownUseCase(ref.watch(statisticsRepositoryProvider));

@riverpod
GetDifficultCardsUseCase getDifficultCardsUseCase(Ref ref) =>
    GetDifficultCardsUseCase(ref.watch(statisticsRepositoryProvider));

@riverpod
GetStudyStatsUseCase getStudyStatsUseCase(Ref ref) => GetStudyStatsUseCase(
  repository: ref.watch(statisticsRepositoryProvider),
  getStreakUseCase: ref.watch(getStreakUseCaseProvider),
  getWeeklyActivityUseCase: ref.watch(getWeeklyActivityUseCaseProvider),
  getMasteryBreakdownUseCase: ref.watch(getMasteryBreakdownUseCaseProvider),
  getDifficultCardsUseCase: ref.watch(getDifficultCardsUseCaseProvider),
);

@riverpod
SearchItemsUseCase searchItemsUseCase(Ref ref) =>
    SearchItemsUseCase(ref.watch(searchRepositoryProvider));
