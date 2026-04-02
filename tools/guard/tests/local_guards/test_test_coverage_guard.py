from __future__ import annotations

from pathlib import Path
import tempfile
import unittest

from tools.guard.core.path_constants import PathConstants
from tools.guard.local_guards.test_coverage_guard import TestCoverageGuard


class TestCoverageGuardTest(unittest.TestCase):
    def test_reports_missing_1_to_1_usecase_and_screen_tests(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            (root / 'lib/features/search/domain/usecases').mkdir(parents=True)
            (root / 'lib/features/search/presentation/screens').mkdir(parents=True)
            (root / 'lib/features/search/domain/usecases/search_items.dart').write_text('void x() {}', encoding='utf-8')
            (root / 'lib/features/search/presentation/screens/search_screen.dart').write_text('class X {}', encoding='utf-8')
            guard = self._create_guard(root)

            violations = guard.check_project([])

            messages = [violation.message for violation in violations]
            self.assertIn('search thiếu unit test cho `search_items.dart`.', messages)
            self.assertIn('search thiếu widget test cho `search_screen.dart`.', messages)

    def _create_guard(self, root: Path) -> TestCoverageGuard:
        config = {
            'source_root': 'lib',
            'test_root': 'test',
            'paths': {
                'core_dir': 'lib/core',
                'shared_dir': 'lib/shared',
                'features_dir': 'lib/features',
                'exclude_patterns': [],
            },
            'local_guards': {'test_coverage': True},
        }
        rules = {
            'test_coverage': {
                'screen_file_glob': 'presentation/screens/*_screen.dart',
                'screen_test_glob': 'presentation/screens/*_test.dart',
                'usecase_file_glob': 'domain/usecases/*.dart',
                'usecase_test_glob': 'domain/usecases/*_test.dart',
            },
        }
        paths = PathConstants.from_config(root, config)
        return TestCoverageGuard(config=config, path_constants=paths, project_rules=rules)


if __name__ == '__main__':
    unittest.main()
