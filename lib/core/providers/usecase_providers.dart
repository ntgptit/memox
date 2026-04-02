import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/providers/repository_providers.dart';
import 'package:memox/core/providers/service_providers.dart';
import 'package:memox/features/cards/domain/usecases/get_due_cards.dart';
import 'package:memox/features/cards/domain/usecases/get_flashcards.dart';
import 'package:memox/features/decks/domain/usecases/get_decks.dart';
import 'package:memox/features/folders/domain/usecases/can_create_subfolder.dart';
import 'package:memox/features/folders/domain/usecases/create_folder.dart';
import 'package:memox/features/folders/domain/usecases/delete_folder.dart';
import 'package:memox/features/folders/domain/usecases/get_folders.dart';
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
GetFoldersUseCase getFoldersUseCase(Ref ref) {
  return GetFoldersUseCase(ref.watch(folderRepositoryProvider));
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
CanCreateSubfolderUseCase canCreateSubfolderUseCase(Ref ref) {
  return CanCreateSubfolderUseCase(ref.watch(folderRepositoryProvider));
}

@riverpod
GetDecksUseCase getDecksUseCase(Ref ref) {
  return GetDecksUseCase(ref.watch(deckRepositoryProvider));
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
