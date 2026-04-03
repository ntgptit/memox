from __future__ import annotations

from pathlib import Path
import tempfile
import unittest

from tools.guard.core.path_constants import PathConstants
from tools.guard.global_guards.no_hardcoded_color_guard import NoHardcodedColorGuard


class NoHardcodedColorGuardTest(unittest.TestCase):
    def test_reports_material_colors_usage(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            file_path = root / 'lib/sample.dart'
            file_path.parent.mkdir(parents=True)
            file_path.write_text(
                'final color = Colors.green;',
                encoding='utf-8',
            )
            guard = self._create_guard(root)

            violations = guard.check_file(
                file_path,
                file_path.read_text(encoding='utf-8').splitlines(),
            )

            self.assertEqual(1, len(violations))
            self.assertIn('context.colors.*', violations[0].message)
            self.assertIn('context.customColors.*', violations[0].message)

    def test_allows_context_color_access(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            file_path = root / 'lib/sample.dart'
            file_path.parent.mkdir(parents=True)
            file_path.write_text(
                'final color = context.colors.primary;',
                encoding='utf-8',
            )
            guard = self._create_guard(root)

            violations = guard.check_file(
                file_path,
                file_path.read_text(encoding='utf-8').splitlines(),
            )

            self.assertEqual([], violations)

    def _create_guard(self, root: Path) -> NoHardcodedColorGuard:
        config = {
            'source_root': 'lib',
            'test_root': 'test',
            'paths': {
                'core_dir': 'lib/core',
                'shared_dir': 'lib/shared',
                'features_dir': 'lib/features',
                'exclude_patterns': [],
            },
            'global_guards': {'no_hardcoded_color': True},
        }
        paths = PathConstants.from_config(root, config)
        return NoHardcodedColorGuard(config=config, path_constants=paths)


if __name__ == '__main__':
    unittest.main()
