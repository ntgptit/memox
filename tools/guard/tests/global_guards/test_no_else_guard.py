from __future__ import annotations

from pathlib import Path
import tempfile
import unittest

from tools.guard.core.path_constants import PathConstants
from tools.guard.global_guards.no_else_guard import NoElseGuard


class NoElseGuardTest(unittest.TestCase):
    def test_detects_else_but_skips_comments(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            (root / 'lib').mkdir()
            config = {
                'source_root': 'lib',
                'test_root': 'test',
                'paths': {
                    'core_dir': 'lib/core',
                    'shared_dir': 'lib/shared',
                    'features_dir': 'lib/features',
                    'exclude_patterns': [],
                },
            }
            paths = PathConstants.from_config(root, config)
            guard = NoElseGuard(config=config, path_constants=paths)
            file_path = root / 'lib/sample.dart'
            lines = [
                'if (condition) {',
                '} else {',
                '// else should be ignored here',
            ]

            violations = guard.check_file(file_path, lines)

            self.assertEqual(1, len(violations))
            self.assertEqual(2, violations[0].line_number)


if __name__ == '__main__':
    unittest.main()
