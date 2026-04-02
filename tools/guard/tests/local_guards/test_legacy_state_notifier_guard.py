from __future__ import annotations

from pathlib import Path
import tempfile
import unittest

from tools.guard.core.path_constants import PathConstants
from tools.guard.local_guards.legacy_state_notifier_guard import LegacyStateNotifierGuard


class LegacyStateNotifierGuardTest(unittest.TestCase):
    def test_reports_state_notifier_usage(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            file_path = root / 'lib/features/folders/presentation/providers/folders_provider.dart'
            file_path.parent.mkdir(parents=True)
            file_path.write_text('class X extends StateNotifier<int> {}', encoding='utf-8')
            guard = self._create_guard(root)

            violations = guard.check_file(file_path, file_path.read_text(encoding='utf-8').splitlines())

            self.assertEqual(1, len(violations))

    def _create_guard(self, root: Path) -> LegacyStateNotifierGuard:
        config = {
            'source_root': 'lib',
            'test_root': 'test',
            'paths': {
                'core_dir': 'lib/core',
                'shared_dir': 'lib/shared',
                'features_dir': 'lib/features',
                'exclude_patterns': [],
            },
            'local_guards': {'legacy_state_notifier': True},
        }
        rules = {
            'legacy_state_notifier': {
                'forbidden_patterns': ['StateNotifier<', 'extends StateNotifier'],
            },
        }
        paths = PathConstants.from_config(root, config)
        return LegacyStateNotifierGuard(config=config, path_constants=paths, project_rules=rules)


if __name__ == '__main__':
    unittest.main()
