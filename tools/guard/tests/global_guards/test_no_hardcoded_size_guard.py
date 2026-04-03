from __future__ import annotations

from pathlib import Path
import tempfile
import unittest

from tools.guard.core.path_constants import PathConstants
from tools.guard.global_guards.no_hardcoded_size_guard import NoHardcodedSizeGuard


class NoHardcodedSizeGuardTest(unittest.TestCase):
    def test_reports_numeric_sized_box_spacing(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            file_path = root / 'lib/sample.dart'
            file_path.parent.mkdir(parents=True)
            file_path.write_text(
                'const spacer = SizedBox(height: 8);',
                encoding='utf-8',
            )
            guard = self._create_guard(root)

            violations = guard.check_file(
                file_path,
                file_path.read_text(encoding='utf-8').splitlines(),
            )

            self.assertEqual(1, len(violations))
            self.assertIn('Gap.*', violations[0].message)
            self.assertIn('SpacingTokens.*', violations[0].message)

    def test_reports_numeric_widget_size(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            file_path = root / 'lib/sample.dart'
            file_path.parent.mkdir(parents=True)
            file_path.write_text(
                'const icon = Icon(Icons.add, size: 20);',
                encoding='utf-8',
            )
            guard = self._create_guard(root)

            violations = guard.check_file(
                file_path,
                file_path.read_text(encoding='utf-8').splitlines(),
            )

            self.assertEqual(1, len(violations))
            self.assertIn('SizeTokens.*', violations[0].message)

    def test_allows_tokenized_sized_box_spacing(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            file_path = root / 'lib/sample.dart'
            file_path.parent.mkdir(parents=True)
            file_path.write_text(
                'const spacer = SizedBox(height: SpacingTokens.md);',
                encoding='utf-8',
            )
            guard = self._create_guard(root)

            violations = guard.check_file(
                file_path,
                file_path.read_text(encoding='utf-8').splitlines(),
            )

            self.assertEqual([], violations)

    def _create_guard(self, root: Path) -> NoHardcodedSizeGuard:
        config = {
            'source_root': 'lib',
            'test_root': 'test',
            'paths': {
                'core_dir': 'lib/core',
                'shared_dir': 'lib/shared',
                'features_dir': 'lib/features',
                'exclude_patterns': [],
            },
            'global_guards': {'no_hardcoded_size': True},
        }
        paths = PathConstants.from_config(root, config)
        return NoHardcodedSizeGuard(config=config, path_constants=paths)


if __name__ == '__main__':
    unittest.main()
