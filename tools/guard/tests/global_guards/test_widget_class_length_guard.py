from __future__ import annotations

from pathlib import Path
import tempfile
import unittest

from tools.guard.core.path_constants import PathConstants
from tools.guard.global_guards.widget_class_length_guard import WidgetClassLengthGuard


class WidgetClassLengthGuardTest(unittest.TestCase):
    def test_reports_long_widget_class(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            file_path = root / 'lib/shared/widgets/example/long_widget.dart'
            file_path.parent.mkdir(parents=True)
            body = '\n'.join(['  final value = 0;'] * 81)
            file_path.write_text(
                'import "package:flutter/widgets.dart";\n'
                'class LongWidget extends StatelessWidget {\n'
                f'{body}\n'
                '  @override\n'
                '  Widget build(BuildContext context) => const SizedBox();\n'
                '}\n',
                encoding='utf-8',
            )
            guard = self._create_guard(root)

            violations = guard.check_file(
                file_path,
                file_path.read_text(encoding='utf-8').splitlines(),
            )

            self.assertEqual(1, len(violations))

    def _create_guard(self, root: Path) -> WidgetClassLengthGuard:
        config = {
            'source_root': 'lib',
            'test_root': 'test',
            'thresholds': {'max_widget_lines': 80},
            'paths': {
                'core_dir': 'lib/core',
                'shared_dir': 'lib/shared',
                'features_dir': 'lib/features',
                'exclude_patterns': [],
            },
            'global_guards': {'widget_class_length': True},
        }
        paths = PathConstants.from_config(root, config)
        return WidgetClassLengthGuard(
            config=config,
            path_constants=paths,
            project_rules=None,
        )


if __name__ == '__main__':
    unittest.main()
