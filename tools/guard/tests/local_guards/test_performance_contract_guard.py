from __future__ import annotations

from pathlib import Path
import tempfile
import unittest

from tools.guard.core.path_constants import PathConstants
from tools.guard.local_guards.performance_contract_guard import (
    PerformanceContractGuard,
)


class PerformanceContractGuardTest(unittest.TestCase):
    def test_reports_missing_required_tokens_and_patterns(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            (root / 'lib/core/router').mkdir(parents=True)
            (root / 'lib/shared/widgets/navigation').mkdir(parents=True)
            (root / 'lib/features/folders/presentation/providers').mkdir(
                parents=True,
            )
            (root / 'lib/core/router/app_router.dart').write_text(
                'GoRouter appRouter(Ref ref) => GoRouter(routes: []);',
                encoding='utf-8',
            )
            (root / 'lib/shared/widgets/navigation/app_root_bottom_nav.dart').write_text(
                'void navigate(BuildContext context) => context.go("/");',
                encoding='utf-8',
            )
            (root / 'lib/features/folders/presentation/providers/folders_provider.dart').write_text(
                '@riverpod\nStream<List<FolderEntity>> folders(Ref ref) => const Stream.empty();',
                encoding='utf-8',
            )
            guard = self._create_guard(root)

            violations = guard.check_project([])

            self.assertEqual(13, len(violations))
            self.assertTrue(
                any(
                    'StatefulShellRoute.indexedStack(' in violation.message
                    for violation in violations
                ),
            )
            self.assertTrue(
                any(
                    'shellState.goBranch(' in violation.message
                    for violation in violations
                ),
            )
            self.assertTrue(
                any(
                    '@Riverpod\\(keepAlive: true\\)' in violation.message
                    for violation in violations
                ),
            )

    def test_passes_when_files_match_performance_contract(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            (root / 'lib/core/router').mkdir(parents=True)
            (root / 'lib/shared/widgets/navigation').mkdir(parents=True)
            (root / 'lib/features/folders/presentation/providers').mkdir(
                parents=True,
            )
            (root / 'lib/features/decks/presentation/providers').mkdir(
                parents=True,
            )
            (root / 'lib/shared/widgets/feedback').mkdir(parents=True)
            (root / 'lib/shared/widgets/animations').mkdir(parents=True)
            (root / 'lib/core/router/app_router.dart').write_text(
                '\n'.join(
                    [
                        'StatefulShellRoute.indexedStack(',
                        '  branches: [StatefulShellBranch(routes: [])],',
                        ');',
                    ],
                ),
                encoding='utf-8',
            )
            (root / 'lib/shared/widgets/navigation/app_root_bottom_nav.dart').write_text(
                '\n'.join(
                    [
                        'final shellState = StatefulNavigationShell.maybeOf(context);',
                        'shellState.goBranch(1);',
                    ],
                ),
                encoding='utf-8',
            )
            (root / 'lib/features/folders/presentation/providers/folders_provider.dart').write_text(
                '\n'.join(
                    [
                        '@Riverpod(keepAlive: true)',
                        'Stream<List<FolderEntity>> folders(Ref ref) => const Stream.empty();',
                        '@Riverpod(keepAlive: true)',
                        'Stream<List<FolderEntity>> allFolders(Ref ref) => const Stream.empty();',
                        '@Riverpod(keepAlive: true)',
                        'Stream<List<DeckEntity>> allDecks(Ref ref) => const Stream.empty();',
                        '@Riverpod(keepAlive: true)',
                        'Stream<List<FlashcardEntity>> allFlashcards(Ref ref) => const Stream.empty();',
                        '@Riverpod(keepAlive: true)',
                        'AsyncValue<HomeDueSummary> homeDueSummary(Ref ref) => const AsyncValue.loading();',
                    ],
                ),
                encoding='utf-8',
            )
            (root / 'lib/features/folders/presentation/providers/folder_detail_provider.dart').write_text(
                '\n'.join(
                    [
                        'folderByIdProvider(folderId);',
                        'subfolderProvider(folderId);',
                        'decksByFolderProvider(folderId);',
                        'folderRecursiveStatsProvider(folderId);',
                    ],
                ),
                encoding='utf-8',
            )
            (root / 'lib/features/decks/presentation/providers/deck_detail_provider.dart').write_text(
                '\n'.join(
                    [
                        'deckByIdProvider(deckId);',
                        'cardsByDeckProvider(deckId);',
                        'folderBreadcrumbProvider(folderId);',
                        '_deckStats(cards);',
                    ],
                ),
                encoding='utf-8',
            )
            (root / 'lib/shared/widgets/feedback/app_async_builder.dart').write_text(
                'const AppAsyncBuilder({this.animate = false, super.key});',
                encoding='utf-8',
            )
            (root / 'lib/shared/widgets/animations/fade_in_widget.dart').write_text(
                'const FadeInWidget({this.duration = DurationTokens.fast, super.key});',
                encoding='utf-8',
            )
            guard = self._create_guard(root)

            violations = guard.check_project([])

            self.assertEqual([], violations)

    def _create_guard(self, root: Path) -> PerformanceContractGuard:
        config = {
            'source_root': 'lib',
            'test_root': 'test',
            'paths': {
                'core_dir': 'lib/core',
                'shared_dir': 'lib/shared',
                'features_dir': 'lib/features',
                'exclude_patterns': [],
            },
            'local_guards': {'performance_contract': True},
        }
        rules = {
            'performance_contract': {
                'cases': [
                    {
                        'file': 'lib/core/router/app_router.dart',
                        'required_tokens': [
                            'StatefulShellRoute.indexedStack(',
                            'StatefulShellBranch(',
                        ],
                    },
                    {
                        'file': 'lib/shared/widgets/navigation/app_root_bottom_nav.dart',
                        'required_tokens': [
                            'StatefulNavigationShell.maybeOf(context)',
                            'shellState.goBranch(',
                        ],
                    },
                    {
                        'file': 'lib/features/folders/presentation/providers/folders_provider.dart',
                        'required_patterns': [
                            '@Riverpod\\(keepAlive: true\\)\\s+Stream<List<FolderEntity>> folders\\(Ref ref\\)',
                            '@Riverpod\\(keepAlive: true\\)\\s+Stream<List<FolderEntity>> allFolders\\(Ref ref\\)',
                            '@Riverpod\\(keepAlive: true\\)\\s+Stream<List<DeckEntity>> allDecks\\(Ref ref\\)',
                            '@Riverpod\\(keepAlive: true\\)\\s+Stream<List<FlashcardEntity>> allFlashcards\\(Ref ref\\)',
                            '@Riverpod\\(keepAlive: true\\)\\s+AsyncValue<HomeDueSummary> homeDueSummary\\(Ref ref\\)',
                        ],
                    },
                    {
                        'file': 'lib/features/folders/presentation/providers/folder_detail_provider.dart',
                        'required_tokens': [
                            'folderByIdProvider(',
                            'subfolderProvider(',
                            'decksByFolderProvider(',
                            'folderRecursiveStatsProvider(',
                        ],
                        'forbidden_tokens': [
                            'allFoldersProvider',
                            'allDecksProvider',
                            'allFlashcardsProvider',
                        ],
                    },
                    {
                        'file': 'lib/features/decks/presentation/providers/deck_detail_provider.dart',
                        'required_tokens': [
                            'deckByIdProvider(',
                            'cardsByDeckProvider(',
                            'folderBreadcrumbProvider(',
                            '_deckStats(cards)',
                        ],
                        'forbidden_tokens': [
                            'allDecksProvider',
                            'deckStatsProvider(',
                        ],
                    },
                    {
                        'file': 'lib/shared/widgets/feedback/app_async_builder.dart',
                        'required_tokens': ['this.animate = false,'],
                    },
                    {
                        'file': 'lib/shared/widgets/animations/fade_in_widget.dart',
                        'required_tokens': ['this.duration = DurationTokens.fast,'],
                    },
                ],
            },
        }
        paths = PathConstants.from_config(root, config)
        return PerformanceContractGuard(
            config=config,
            path_constants=paths,
            project_rules=rules,
        )


if __name__ == '__main__':
    unittest.main()
