from __future__ import annotations

from pathlib import Path
import tempfile
import unittest

from tools.guard.core.path_constants import PathConstants
from tools.guard.local_guards.button_usage_guard import ButtonUsageGuard


class ButtonUsageGuardTest(unittest.TestCase):
    def test_reports_raw_material_buttons(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            file_path = root / 'lib/shared/widgets/dialogs/confirm_dialog.dart'
            file_path.parent.mkdir(parents=True)
            file_path.write_text("TextButton(onPressed: () {}, child: Text('x'));", encoding='utf-8')
            guard = self._create_guard(root)

            violations = guard.check_file(file_path, file_path.read_text(encoding='utf-8').splitlines())

            self.assertEqual(1, len(violations))

    def _create_guard(self, root: Path) -> ButtonUsageGuard:
        config = {
            'source_root': 'lib',
            'test_root': 'test',
            'paths': {
                'core_dir': 'lib/core',
                'shared_dir': 'lib/shared',
                'features_dir': 'lib/features',
                'exclude_patterns': [],
            },
            'local_guards': {'button_usage': True},
        }
        rules = {
            'button_usage': {
                'forbidden_buttons': ['TextButton'],
                'whitelist_dirs': ['lib/shared/widgets/buttons/', 'test/'],
            },
        }
        paths = PathConstants.from_config(root, config)
        return ButtonUsageGuard(config=config, path_constants=paths, project_rules=rules)


if __name__ == '__main__':
    unittest.main()
