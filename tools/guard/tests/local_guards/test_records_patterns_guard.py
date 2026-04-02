from __future__ import annotations

from pathlib import Path
import tempfile
import unittest

from tools.guard.core.path_constants import PathConstants
from tools.guard.local_guards.records_patterns_guard import RecordsPatternsGuard


class RecordsPatternsGuardTest(unittest.TestCase):
    def test_reports_is_plus_as_sequence(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            file_path = root / 'lib/features/study/presentation/widgets/example.dart'
            file_path.parent.mkdir(parents=True)
            file_path.write_text(
                'void call(Object value) {\n'
                '  if (value is String) {\n'
                '    final text = value as String;\n'
                '    print(text);\n'
                '  }\n'
                '}\n',
                encoding='utf-8',
            )
            guard = self._create_guard(root)

            violations = guard.check_file(
                file_path,
                file_path.read_text(encoding='utf-8').splitlines(),
            )

            self.assertEqual(1, len(violations))

    def _create_guard(self, root: Path) -> RecordsPatternsGuard:
        config = {
            'source_root': 'lib',
            'test_root': 'test',
            'paths': {
                'core_dir': 'lib/core',
                'shared_dir': 'lib/shared',
                'features_dir': 'lib/features',
                'exclude_patterns': [],
            },
            'local_guards': {'records_patterns': True},
        }
        rules = {
            'records_patterns': {
                'pair_like_patterns': ['Tuple2', 'Tuple3', 'Pair'],
                'cast_window': 5,
            },
        }
        paths = PathConstants.from_config(root, config)
        return RecordsPatternsGuard(config=config, path_constants=paths, project_rules=rules)


if __name__ == '__main__':
    unittest.main()
