from __future__ import annotations

from pathlib import Path
import tempfile
import unittest

from tools.guard.core.path_constants import PathConstants
from tools.guard.local_guards.text_style_guard import TextStyleGuard


class TextStyleGuardTest(unittest.TestCase):
    def test_reports_raw_text_style_constructor(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            file_path = root / 'lib/features/folders/presentation/widgets/folder_tile.dart'
            file_path.parent.mkdir(parents=True)
            file_path.write_text("final style = TextStyle(fontSize: 12);", encoding='utf-8')
            guard = self._create_guard(root)

            violations = guard.check_file(file_path, file_path.read_text(encoding='utf-8').splitlines())

            self.assertEqual(1, len(violations))

    def test_reports_raw_font_weight_override(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            file_path = root / 'lib/features/folders/presentation/widgets/folder_tile.dart'
            file_path.parent.mkdir(parents=True)
            file_path.write_text(
                'final style = theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold);',
                encoding='utf-8',
            )
            guard = self._create_guard(root)

            violations = guard.check_file(file_path, file_path.read_text(encoding='utf-8').splitlines())

            self.assertEqual(1, len(violations))

    def _create_guard(self, root: Path) -> TextStyleGuard:
        config = {
            'source_root': 'lib',
            'test_root': 'test',
            'paths': {
                'core_dir': 'lib/core',
                'shared_dir': 'lib/shared',
                'features_dir': 'lib/features',
                'exclude_patterns': [],
            },
            'local_guards': {'text_style': True},
        }
        rules = {
            'text_style': {
                'forbidden_patterns': [
                    r'TextStyle\(',
                    r'fontWeight\s*:\s*FontWeight\.',
                ],
                'whitelist_dirs': ['lib/core/theme/', 'test/'],
            },
        }
        paths = PathConstants.from_config(root, config)
        return TextStyleGuard(config=config, path_constants=paths, project_rules=rules)


if __name__ == '__main__':
    unittest.main()
