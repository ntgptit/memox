import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/core/design/study_mode.dart';
import 'package:memox/core/router/route_transitions.dart';
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
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => navigationShell,
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: HomeScreen.routePath,
              name: HomeScreen.routeName,
              pageBuilder: (_, s) =>
                  fadeThroughPage(state: s, child: const HomeScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: DecksScreen.routePath,
              name: DecksScreen.routeName,
              pageBuilder: (_, s) =>
                  fadeThroughPage(state: s, child: const DecksScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: StatisticsScreen.routePath,
              name: StatisticsScreen.routeName,
              pageBuilder: (_, s) =>
                  fadeThroughPage(state: s, child: const StatisticsScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: SettingsScreen.routePath,
              name: SettingsScreen.routeName,
              pageBuilder: (_, s) =>
                  fadeThroughPage(state: s, child: const SettingsScreen()),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: DeckDetailScreen.routePath,
      name: DeckDetailScreen.routeName,
      pageBuilder: (_, s) => sharedAxisZPage(
        state: s,
        child: DeckDetailScreen(deckId: int.parse(s.pathParameters['deckId']!)),
      ),
    ),
    GoRoute(
      path: CardCreateScreen.routePath,
      name: CardCreateScreen.routeName,
      pageBuilder: (_, s) => MaterialPage<void>(
        key: s.pageKey,
        fullscreenDialog: true,
        child: CardCreateScreen(
          deckId: int.parse(s.pathParameters['deckId']!),
          initialMode: _editorModeFromName(s.uri.queryParameters['mode']),
        ),
      ),
    ),
    GoRoute(
      path: CardEditScreen.routePath,
      name: CardEditScreen.routeName,
      pageBuilder: (_, s) => MaterialPage<void>(
        key: s.pageKey,
        fullscreenDialog: true,
        child: CardEditScreen(
          deckId: int.parse(s.pathParameters['deckId']!),
          cardId: int.parse(s.pathParameters['cardId']!),
        ),
      ),
    ),
    GoRoute(
      path: FolderDetailScreen.routePath,
      name: FolderDetailScreen.routeName,
      pageBuilder: (_, s) => sharedAxisZPage(
        state: s,
        child: FolderDetailScreen(
          folderId: int.parse(s.pathParameters['folderId']!),
          focusDeckId: int.tryParse(s.uri.queryParameters['deck'] ?? ''),
        ),
      ),
    ),
    GoRoute(
      path: SearchScreen.routePath,
      name: SearchScreen.routeName,
      pageBuilder: (_, s) =>
          fadeThroughPage(state: s, child: const SearchScreen()),
    ),
    GoRoute(
      path: CardsScreen.routePath,
      name: CardsScreen.routeName,
      pageBuilder: (_, s) =>
          fadeThroughPage(state: s, child: const CardsScreen()),
    ),
    GoRoute(
      path: StudyScreen.routePath,
      name: StudyScreen.routeName,
      pageBuilder: (_, s) =>
          fadeThroughPage(state: s, child: const StudyScreen()),
    ),
    GoRoute(
      path: StudyScreen.deckRoutePath,
      name: 'deck-study',
      pageBuilder: (_, s) => sharedAxisZPage(
        state: s,
        child: StudyScreen(
          deckId: int.parse(s.pathParameters['deckId']!),
          mode: _studyModeFromName(s.pathParameters['mode']),
        ),
      ),
    ),
    GoRoute(
      path: ThemePreviewScreen.routePath,
      name: ThemePreviewScreen.routeName,
      pageBuilder: (_, s) =>
          sharedAxisZPage(state: s, child: const ThemePreviewScreen()),
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
