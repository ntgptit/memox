from __future__ import annotations

from pathlib import Path
import tempfile
import unittest

from tools.guard.core.path_constants import PathConstants
from tools.guard.local_guards.shared_widget_mapping_guard import SharedWidgetMappingGuard


class SharedWidgetMappingGuardTest(unittest.TestCase):
    def test_reports_missing_required_widget_for_mapped_feature_file(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            file_path = root / 'lib/features/folders/presentation/widgets/folder_tile.dart'
            file_path.parent.mkdir(parents=True)
            file_path.write_text('return AppTileGlyph(icon: Icons.folder);', encoding='utf-8')
            guard = self._create_guard(root)

            violations = guard.check_project([file_path])

            self.assertEqual(2, len(violations))
            messages = [violation.message for violation in violations]
            self.assertTrue(any('AppCardListTile(' in message for message in messages))
            self.assertTrue(any('AppEditDeleteMenu(' in message for message in messages))

    def test_reports_missing_required_any_group(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            file_path = root / 'lib/features/demo/presentation/widgets/sample_tile.dart'
            file_path.parent.mkdir(parents=True)
            file_path.write_text('return const SizedBox.shrink();', encoding='utf-8')
            guard = self._create_guard(
                root,
                project_rules={
                    'shared_widget_mapping': {
                        'tile_widgets': {
                            'path_pattern': 'features/demo/presentation/widgets/*_tile.dart',
                            'required_any_widgets': ['AppListTile(', 'AppCardListTile('],
                        },
                    },
                },
            )

            violations = guard.check_project([file_path])

            self.assertEqual(1, len(violations))
            self.assertIn('AppListTile(', violations[0].message)
            self.assertIn('AppCardListTile(', violations[0].message)

    def test_reports_forbidden_widget_for_mapped_feature_file(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            file_path = root / 'lib/features/decks/presentation/widgets/deck_tile.dart'
            file_path.parent.mkdir(parents=True)
            file_path.write_text(
                '\n'.join(
                    [
                        'return AppCardListTile(',
                        '  leading: AppTileGlyph(icon: Icons.style_outlined, color: Colors.red),',
                        '  trailing: AppEditDeleteMenu(deleteLabel: "Delete"),',
                        '  supporting: PopupMenuButton<int>(itemBuilder: (_) => []),',
                        ');',
                    ],
                ),
                encoding='utf-8',
            )
            guard = self._create_guard(root)

            violations = guard.check_project([file_path])

            self.assertEqual(1, len(violations))
            self.assertIn('PopupMenuButton', violations[0].message)

    def _create_guard(
        self,
        root: Path,
        project_rules: dict | None = None,
    ) -> SharedWidgetMappingGuard:
        config = {
            'source_root': 'lib',
            'test_root': 'test',
            'paths': {
                'core_dir': 'lib/core',
                'shared_dir': 'lib/shared',
                'features_dir': 'lib/features',
                'exclude_patterns': [],
            },
            'local_guards': {'shared_widget_mapping': True},
            '_runtime': {'scope': 'all'},
        }
        paths = PathConstants.from_config(root, config)
        return SharedWidgetMappingGuard(
            config=config,
            path_constants=paths,
            project_rules=project_rules
            or {
                'shared_widget_mapping': {
                    'folder_tile': {
                        'path_pattern': 'features/folders/presentation/widgets/folder_tile.dart',
                        'required_widgets': [
                            'AppCardListTile(',
                            'AppTileGlyph(',
                            'AppEditDeleteMenu(',
                        ],
                    },
                    'deck_tile': {
                        'path_pattern': 'features/decks/presentation/widgets/deck_tile.dart',
                        'required_widgets': [
                            'AppCardListTile(',
                            'AppTileGlyph(',
                            'AppEditDeleteMenu(',
                        ],
                        'forbidden_widgets': ['PopupMenuButton'],
                    },
                },
            },
        )


if __name__ == '__main__':
    unittest.main()
