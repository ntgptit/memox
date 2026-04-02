from __future__ import annotations

from pathlib import Path
import tempfile
import unittest

from tools.guard.core.file_scanner import FileScanner
from tools.guard.core.path_constants import PathConstants


class FileScannerTest(unittest.TestCase):
    def test_scan_excludes_generated_files(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            (root / 'lib').mkdir()
            (root / 'test').mkdir()
            (root / 'lib' / 'feature.dart').write_text('class Feature {}', encoding='utf-8')
            (root / 'lib' / 'feature.g.dart').write_text('// generated', encoding='utf-8')
            (root / 'test' / 'feature_test.dart').write_text('void main() {}', encoding='utf-8')
            config = {
                'source_root': 'lib',
                'test_root': 'test',
                'paths': {
                    'core_dir': 'lib/core',
                    'shared_dir': 'lib/shared',
                    'features_dir': 'lib/features',
                    'exclude_patterns': ['**/*.g.dart'],
                },
            }
            paths = PathConstants.from_config(root, config)
            scanner = FileScanner(paths)

            results = [paths.relative_path(file_path) for file_path in scanner.scan()]

            self.assertIn('lib/feature.dart', results)
            self.assertIn('test/feature_test.dart', results)
            self.assertNotIn('lib/feature.g.dart', results)


if __name__ == '__main__':
    unittest.main()
