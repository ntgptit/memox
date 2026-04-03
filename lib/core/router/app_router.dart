import 'package:go_router/go_router.dart';
import 'package:memox/features/cards/presentation/screens/cards_screen.dart';
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
      path: ThemePreviewScreen.routePath,
      name: ThemePreviewScreen.routeName,
      builder: (context, state) => const ThemePreviewScreen(),
    ),
  ],
);
