import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/core/design/study_mode.dart';
import 'package:memox/features/cards/presentation/screens/card_create_screen.dart';
import 'package:memox/features/cards/presentation/screens/card_edit_screen.dart';
import 'package:memox/features/cards/presentation/screens/cards_screen.dart';
import 'package:memox/features/cards/presentation/widgets/card_editor_view.dart';
import 'package:memox/features/decks/presentation/screens/deck_detail_screen.dart';
import 'package:memox/features/decks/presentation/screens/decks_screen.dart';
import 'package:memox/features/folders/presentation/screens/folder_detail_screen.dart';
import 'package:memox/features/folders/presentation/screens/home_screen.dart';
import 'package:memox/features/search/presentation/screens/search_screen.dart';
import 'package:memox/features/settings/presentation/screens/settings_screen.dart';
import 'package:memox/features/settings/presentation/screens/theme_preview_screen.dart';
import 'package:memox/features/statistics/presentation/screens/statistics_screen.dart';
import 'package:memox/features/study/presentation/screens/study_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) => GoRouter(
  initialLocation: HomeScreen.routePath,
  routes: [
    GoRoute(
      path: HomeScreen.routePath,
      name: HomeScreen.routeName,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: DecksScreen.routePath,
      name: DecksScreen.routeName,
      builder: (context, state) => const DecksScreen(),
    ),
    GoRoute(
      path: DeckDetailScreen.routePath,
      name: DeckDetailScreen.routeName,
      builder: (context, state) =>
          DeckDetailScreen(deckId: int.parse(state.pathParameters['deckId']!)),
    ),
    GoRoute(
      path: CardCreateScreen.routePath,
      name: CardCreateScreen.routeName,
      pageBuilder: (context, state) => MaterialPage<void>(
        fullscreenDialog: true,
        child: CardCreateScreen(
          deckId: int.parse(state.pathParameters['deckId']!),
          initialMode: _editorModeFromName(state.uri.queryParameters['mode']),
        ),
      ),
    ),
    GoRoute(
      path: CardEditScreen.routePath,
      name: CardEditScreen.routeName,
      pageBuilder: (context, state) => MaterialPage<void>(
        fullscreenDialog: true,
        child: CardEditScreen(
          deckId: int.parse(state.pathParameters['deckId']!),
          cardId: int.parse(state.pathParameters['cardId']!),
        ),
      ),
    ),
    GoRoute(
      path: StatisticsScreen.routePath,
      name: StatisticsScreen.routeName,
      builder: (context, state) => const StatisticsScreen(),
    ),
    GoRoute(
      path: SettingsScreen.routePath,
      name: SettingsScreen.routeName,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: FolderDetailScreen.routePath,
      name: FolderDetailScreen.routeName,
      builder: (context, state) => FolderDetailScreen(
        folderId: int.parse(state.pathParameters['folderId']!),
        focusDeckId: int.tryParse(state.uri.queryParameters['deck'] ?? ''),
      ),
    ),
    GoRoute(
      path: SearchScreen.routePath,
      name: SearchScreen.routeName,
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: CardsScreen.routePath,
      name: CardsScreen.routeName,
      builder: (context, state) => const CardsScreen(),
    ),
    GoRoute(
      path: StudyScreen.routePath,
      name: StudyScreen.routeName,
      builder: (context, state) => const StudyScreen(),
    ),
    GoRoute(
      path: StudyScreen.deckRoutePath,
      name: 'deck-study',
      builder: (context, state) => StudyScreen(
        deckId: int.parse(state.pathParameters['deckId']!),
        mode: _studyModeFromName(state.pathParameters['mode']),
      ),
    ),
    GoRoute(
      path: ThemePreviewScreen.routePath,
      name: ThemePreviewScreen.routeName,
      builder: (context, state) => const ThemePreviewScreen(),
    ),
  ],
);

StudyMode? _studyModeFromName(String? value) {
  for (final mode in StudyMode.values) {
    if (mode.name == value) {
      return mode;
    }
  }

  return null;
}

CardEditorMode _editorModeFromName(String? value) {
  for (final mode in CardEditorMode.values) {
    if (mode.name == value) {
      return mode;
    }
  }

  return CardEditorMode.single;
}
