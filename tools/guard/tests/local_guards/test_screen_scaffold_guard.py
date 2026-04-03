from __future__ import annotations

from pathlib import Path
import tempfile
import unittest

from tools.guard.core.path_constants import PathConstants
from tools.guard.local_guards.screen_scaffold_guard import ScreenScaffoldGuard


class ScreenScaffoldGuardTest(unittest.TestCase):
    def test_reports_raw_scaffold_in_feature_screen(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            file_path = root / 'lib/features/search/presentation/screens/search_screen.dart'
            file_path.parent.mkdir(parents=True)
            file_path.write_text(
                'Widget build(BuildContext context) => Scaffold(body: Text("x"));',
                encoding='utf-8',
            )
            guard = self._create_guard(root)

            violations = guard.check_file(
                file_path,
                file_path.read_text(encoding='utf-8').splitlines(),
            )

            self.assertEqual(1, len(violations))

    def test_reports_feature_screen_without_shared_scaffold(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            file_path = root / 'lib/features/search/presentation/screens/search_screen.dart'
            file_path.parent.mkdir(parents=True)
            file_path.write_text(
                'Widget build(BuildContext context) => SearchPlaceholderView();',
                encoding='utf-8',
            )
            guard = self._create_guard(root)

            violations = guard.check_file(
                file_path,
                file_path.read_text(encoding='utf-8').splitlines(),
            )

            self.assertEqual(1, len(violations))

    def test_allows_app_scaffold_in_feature_screen(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            file_path = root / 'lib/features/search/presentation/screens/search_screen.dart'
            file_path.parent.mkdir(parents=True)
            file_path.write_text(
                'Widget build(BuildContext context) => AppScaffold(body: Text("x"));',
                encoding='utf-8',
            )
            guard = self._create_guard(root)

            violations = guard.check_file(
                file_path,
                file_path.read_text(encoding='utf-8').splitlines(),
            )

            self.assertEqual([], violations)

    def _create_guard(self, root: Path) -> ScreenScaffoldGuard:
        config = {
            'source_root': 'lib',
            'test_root': 'test',
            'paths': {
                'core_dir': 'lib/core',
                'shared_dir': 'lib/shared',
                'features_dir': 'lib/features',
                'exclude_patterns': [],
            },
            'local_guards': {'screen_scaffold': True},
        }
        rules = {
            'screen_scaffold': {
                'path_patterns': ['features/*/presentation/screens/*_screen.dart'],
                'allowed_scaffolds': ['AppScaffold(', 'SliverScaffold('],
            },
        }
        paths = PathConstants.from_config(root, config)
        return ScreenScaffoldGuard(
            config=config,
            path_constants=paths,
            project_rules=rules,
        )


if __name__ == '__main__':
    unittest.main()
