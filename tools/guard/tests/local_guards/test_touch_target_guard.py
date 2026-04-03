from __future__ import annotations

from pathlib import Path
import tempfile
import unittest

from tools.guard.core.path_constants import PathConstants
from tools.guard.local_guards.touch_target_guard import TouchTargetGuard


class TouchTargetGuardTest(unittest.TestCase):
    def test_reports_missing_touch_target_token(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            file_path = root / 'lib/shared/widgets/buttons/text_link_button.dart'
            file_path.parent.mkdir(parents=True)
            file_path.write_text(
                'Widget build(BuildContext context) => InkWell(child: Text("x"));',
                encoding='utf-8',
            )
            guard = self._create_guard(root)

            violations = guard.check_file(
                file_path,
                file_path.read_text(encoding='utf-8').splitlines(),
            )

            self.assertEqual(1, len(violations))
            self.assertIn('48dp', violations[0].message)

    def test_allows_touch_target_token(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            file_path = root / 'lib/shared/widgets/buttons/text_link_button.dart'
            file_path.parent.mkdir(parents=True)
            file_path.write_text(
                'const BoxConstraints(minHeight: SizeTokens.touchTarget);',
                encoding='utf-8',
            )
            guard = self._create_guard(root)

            violations = guard.check_file(
                file_path,
                file_path.read_text(encoding='utf-8').splitlines(),
            )

            self.assertEqual([], violations)

    def _create_guard(self, root: Path) -> TouchTargetGuard:
        config = {
            'source_root': 'lib',
            'test_root': 'test',
            'paths': {
                'core_dir': 'lib/core',
                'shared_dir': 'lib/shared',
                'features_dir': 'lib/features',
                'exclude_patterns': [],
            },
            'local_guards': {'touch_target': True},
        }
        rules = {
            'touch_target': {
                'path_patterns': ['shared/widgets/buttons/text_link_button.dart'],
                'required_tokens': [
                    'SizeTokens.touchTarget',
                    'minimumSize:',
                    'minHeight:',
                    'SizeTokens.buttonHeight',
                    'SizeTokens.inputHeight',
                    'SizeTokens.listItemHeight',
                    'SizeTokens.listItemTall',
                ],
            },
        }
        paths = PathConstants.from_config(root, config)
        return TouchTargetGuard(
            config=config,
            path_constants=paths,
            project_rules=rules,
        )


if __name__ == '__main__':
    unittest.main()
