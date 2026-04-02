from __future__ import annotations

from pathlib import Path
import tempfile
import unittest

from tools.guard.core.path_constants import PathConstants
from tools.guard.local_guards.l10n_source_guard import L10nSourceGuard


class L10nSourceGuardTest(unittest.TestCase):
    def test_reports_app_strings_usage_in_presentation_widget(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            file_path = root / 'lib/features/folders/presentation/widgets/folder_tile.dart'
            file_path.parent.mkdir(parents=True)
            file_path.write_text(
                "import 'package:memox/core/constants/app_strings.dart';\n"
                "Text(AppStrings.foldersTitle);\n",
                encoding='utf-8',
            )
            guard = self._create_guard(root)

            violations = guard.check_file(
                file_path,
                file_path.read_text(encoding='utf-8').splitlines(),
            )

            self.assertEqual(2, len(violations))

    def _create_guard(self, root: Path) -> L10nSourceGuard:
        config = {
            'source_root': 'lib',
            'test_root': 'test',
            'paths': {
                'core_dir': 'lib/core',
                'shared_dir': 'lib/shared',
                'features_dir': 'lib/features',
                'exclude_patterns': [],
            },
            'local_guards': {'l10n_source': True},
        }
        rules = {
            'l10n_source': {
                'path_patterns': [
                    'features/*/presentation/**/*.dart',
                    'shared/widgets/**/*.dart',
                    'app.dart',
                ],
                'forbidden_tokens': [
                    'AppStrings.',
                    'core/constants/app_strings.dart',
                ],
            },
        }
        paths = PathConstants.from_config(root, config)
        return L10nSourceGuard(config=config, path_constants=paths, project_rules=rules)


if __name__ == '__main__':
    unittest.main()
