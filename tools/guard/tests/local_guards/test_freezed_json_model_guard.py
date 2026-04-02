from __future__ import annotations

from pathlib import Path
import tempfile
import unittest

from tools.guard.core.path_constants import PathConstants
from tools.guard.local_guards.freezed_json_model_guard import FreezedJsonModelGuard


class FreezedJsonModelGuardTest(unittest.TestCase):
    def test_reports_plain_entity_without_freezed_contract(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            file_path = root / 'lib/features/folders/domain/entities/folder_entity.dart'
            file_path.parent.mkdir(parents=True)
            file_path.write_text('class FolderEntity {}', encoding='utf-8')
            guard = self._create_guard(root)

            violations = guard.check_file(file_path, file_path.read_text(encoding='utf-8').splitlines())

            self.assertGreaterEqual(len(violations), 4)

    def _create_guard(self, root: Path) -> FreezedJsonModelGuard:
        config = {
            'source_root': 'lib',
            'test_root': 'test',
            'paths': {
                'core_dir': 'lib/core',
                'shared_dir': 'lib/shared',
                'features_dir': 'lib/features',
                'exclude_patterns': [],
            },
            'local_guards': {'freezed_json_model': True},
        }
        rules = {
            'freezed_json_model': {
                'model_file_patterns': ['features/*/domain/entities/*.dart'],
            },
        }
        paths = PathConstants.from_config(root, config)
        return FreezedJsonModelGuard(config=config, path_constants=paths, project_rules=rules)


if __name__ == '__main__':
    unittest.main()
