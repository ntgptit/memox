from __future__ import annotations

from pathlib import Path
import tempfile
import unittest

from tools.guard.core.path_constants import PathConstants
from tools.guard.local_guards.responsive_text_scale_guard import (
    ResponsiveTextScaleGuard,
)


class ResponsiveTextScaleGuardTest(unittest.TestCase):
    def test_reports_missing_required_text_scale_tokens(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            (root / 'lib').mkdir(parents=True)
            (root / 'test/test_helpers').mkdir(parents=True)
            (root / 'lib/app.dart').write_text(
                'class MemoxApp {}',
                encoding='utf-8',
            )
            (root / 'test/test_helpers/test_app.dart').write_text(
                'MaterialApp(home: home)',
                encoding='utf-8',
            )
            guard = self._create_guard(root)

            violations = guard.check_project([])

            self.assertEqual(len(violations), 2)
            self.assertTrue(
                any('textScaleFactor' in violation.message for violation in violations)
            )

    def test_passes_when_required_files_apply_text_scaler(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            (root / 'lib').mkdir(parents=True)
            (root / 'test/test_helpers').mkdir(parents=True)
            content = '\n'.join(
                [
                    'builder: (context, child) => MediaQuery(',
                    '  data: MediaQuery.of(context).copyWith(',
                    '    textScaler: TextScaler.linear(',
                    '      ScreenType.of(context).textScaleFactor,',
                    '    ),',
                    '  ),',
                    ')',
                ]
            )
            (root / 'lib/app.dart').write_text(content, encoding='utf-8')
            (root / 'test/test_helpers/test_app.dart').write_text(
                content,
                encoding='utf-8',
            )
            guard = self._create_guard(root)

            violations = guard.check_project([])

            self.assertEqual(violations, [])

    def _create_guard(self, root: Path) -> ResponsiveTextScaleGuard:
        config = {
            'source_root': 'lib',
            'test_root': 'test',
            'paths': {
                'core_dir': 'lib/core',
                'shared_dir': 'lib/shared',
                'features_dir': 'lib/features',
                'exclude_patterns': [],
            },
            'local_guards': {'responsive_text_scale': True},
        }
        rules = {
            'responsive_text_scale': {
                'cases': [
                    {
                        'file': 'lib/app.dart',
                        'required_tokens': [
                            'MediaQuery(',
                            'textScaler:',
                            'TextScaler.linear(',
                            'ScreenType.of(context).textScaleFactor',
                        ],
                    },
                    {
                        'file': 'test/test_helpers/test_app.dart',
                        'required_tokens': [
                            'MediaQuery(',
                            'textScaler:',
                            'TextScaler.linear(',
                            'ScreenType.of(context).textScaleFactor',
                        ],
                    },
                ]
            }
        }
        paths = PathConstants.from_config(root, config)
        return ResponsiveTextScaleGuard(
            config=config,
            path_constants=paths,
            project_rules=rules,
        )


if __name__ == '__main__':
    unittest.main()
