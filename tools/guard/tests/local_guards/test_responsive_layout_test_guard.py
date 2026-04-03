from __future__ import annotations

from pathlib import Path
import tempfile
import unittest

from tools.guard.core.path_constants import PathConstants
from tools.guard.local_guards.responsive_layout_test_guard import (
    ResponsiveLayoutTestGuard,
)


class ResponsiveLayoutTestGuardTest(unittest.TestCase):
    def test_reports_missing_compact_layout_assertions(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            (root / 'lib/features/decks/presentation/screens').mkdir(parents=True)
            (root / 'test/features/decks/presentation/screens').mkdir(
                parents=True
            )
            (root / 'lib/features/decks/presentation/screens/deck_detail_screen.dart').write_text(
                'class DeckDetailScreen {}',
                encoding='utf-8',
            )
            (root / 'test/features/decks/presentation/screens/deck_detail_screen_test.dart').write_text(
                'void main() {}',
                encoding='utf-8',
            )
            guard = self._create_guard(root)

            violations = guard.check_project([])

            self.assertEqual(len(violations), 1)
            self.assertIn('setSurfaceSize(', violations[0].message)
            self.assertIn('takeException()', violations[0].message)

    def test_passes_when_test_contains_compact_viewport_smoke_check(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            (root / 'lib/features/decks/presentation/screens').mkdir(parents=True)
            (root / 'test/features/decks/presentation/screens').mkdir(
                parents=True
            )
            (root / 'lib/features/decks/presentation/screens/deck_detail_screen.dart').write_text(
                'class DeckDetailScreen {}',
                encoding='utf-8',
            )
            (root / 'test/features/decks/presentation/screens/deck_detail_screen_test.dart').write_text(
                '\n'.join(
                    [
                        'void main() {',
                        "  tester.binding.setSurfaceSize(const Size(390, 844));",
                        '  expect(tester.takeException(), isNull);',
                        '}',
                    ]
                ),
                encoding='utf-8',
            )
            guard = self._create_guard(root)

            violations = guard.check_project([])

            self.assertEqual(violations, [])

    def _create_guard(self, root: Path) -> ResponsiveLayoutTestGuard:
        config = {
            'source_root': 'lib',
            'test_root': 'test',
            'paths': {
                'core_dir': 'lib/core',
                'shared_dir': 'lib/shared',
                'features_dir': 'lib/features',
                'exclude_patterns': [],
            },
            'local_guards': {'responsive_layout_test': True},
        }
        rules = {
            'responsive_layout_test': {
                'cases': [
                    {
                        'screen': (
                            'features/decks/presentation/screens/'
                            'deck_detail_screen.dart'
                        ),
                        'test': (
                            'features/decks/presentation/screens/'
                            'deck_detail_screen_test.dart'
                        ),
                        'required_tokens': [
                            'setSurfaceSize(',
                            'takeException()',
                        ],
                    }
                ]
            }
        }
        paths = PathConstants.from_config(root, config)
        return ResponsiveLayoutTestGuard(
            config=config,
            path_constants=paths,
            project_rules=rules,
        )


if __name__ == '__main__':
    unittest.main()
