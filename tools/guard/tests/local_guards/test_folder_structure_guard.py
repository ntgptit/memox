from __future__ import annotations

from pathlib import Path
import tempfile
import unittest

from tools.guard.core.path_constants import PathConstants
from tools.guard.local_guards.folder_structure_guard import FolderStructureGuard


class FolderStructureGuardTest(unittest.TestCase):
    def test_reports_missing_feature_layers(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            (root / 'lib/features/folders').mkdir(parents=True)
            config = {
                'source_root': 'lib',
                'test_root': 'test',
                'paths': {
                    'core_dir': 'lib/core',
                    'shared_dir': 'lib/shared',
                    'features_dir': 'lib/features',
                    'exclude_patterns': [],
                },
                '_runtime': {'scope': 'features'},
                'severity_overrides': {'folder_structure': 'info'},
            }
            rules = {
                'folder_structure': {
                    'required_root_dirs': ['lib/features'],
                    'required_features': ['folders'],
                    'feature_layers': ['data', 'domain', 'presentation'],
                    'data_subdirs': ['repositories'],
                    'domain_subdirs': ['usecases'],
                    'presentation_subdirs': ['screens'],
                },
            }
            paths = PathConstants.from_config(root, config)
            guard = FolderStructureGuard(config=config, path_constants=paths, project_rules=rules)

            violations = guard.check_project([])

            messages = [violation.message for violation in violations]
            self.assertIn('folders/ thiếu layer data/', messages)
            self.assertIn('folders/ thiếu layer domain/', messages)
            self.assertIn('folders/ thiếu layer presentation/', messages)


if __name__ == '__main__':
    unittest.main()
