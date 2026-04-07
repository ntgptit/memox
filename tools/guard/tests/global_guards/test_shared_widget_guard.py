from __future__ import annotations

from pathlib import Path
import tempfile
import unittest

import yaml

from tools.guard.core.path_constants import PathConstants
from tools.guard.core.rule_executor import RuleExecutor

_REPO_ROOT = Path(__file__).resolve().parents[4]
_POLICY_PATH = _REPO_ROOT / 'tools/guard/policies/memox/policy.yaml'


class SharedWidgetGuardTest(unittest.TestCase):
    def test_reports_raw_text_field_outside_shared_widgets(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            file_path = root / 'lib/features/settings/presentation/widgets/sample.dart'
            file_path.parent.mkdir(parents=True)
            file_path.write_text('final field = TextField();', encoding='utf-8')
            guard = self._create_guard(root)

            violations = guard.check_file(
                file_path,
                file_path.read_text(encoding='utf-8').splitlines(),
            )

            self.assertEqual(1, len(violations))
            self.assertIn('AppTextField', violations[0].message)

    def test_reports_raw_list_tile_outside_shared_widgets(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            file_path = root / 'lib/features/settings/presentation/widgets/sample.dart'
            file_path.parent.mkdir(parents=True)
            file_path.write_text('return ListTile(title: Text("x"));', encoding='utf-8')
            guard = self._create_guard(root)

            violations = guard.check_file(
                file_path,
                file_path.read_text(encoding='utf-8').splitlines(),
            )

            self.assertEqual(1, len(violations))
            self.assertIn('AppListTile', violations[0].message)

    def test_reports_raw_popup_menu_outside_shared_widgets(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            file_path = root / 'lib/features/decks/presentation/widgets/sample.dart'
            file_path.parent.mkdir(parents=True)
            file_path.write_text(
                'return PopupMenuButton<int>(itemBuilder: (_) => []);',
                encoding='utf-8',
            )
            guard = self._create_guard(root)

            violations = guard.check_file(
                file_path,
                file_path.read_text(encoding='utf-8').splitlines(),
            )

            self.assertEqual(1, len(violations))
            self.assertIn('AppEditDeleteMenu', violations[0].message)

    def test_reports_raw_ink_well_outside_shared_widgets(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            file_path = root / 'lib/features/study/presentation/widgets/sample.dart'
            file_path.parent.mkdir(parents=True)
            file_path.write_text('return InkWell(onTap: () {});', encoding='utf-8')
            guard = self._create_guard(root)

            violations = guard.check_file(
                file_path,
                file_path.read_text(encoding='utf-8').splitlines(),
            )

            self.assertEqual(1, len(violations))
            self.assertIn('AppPressable', violations[0].message)

    def test_reports_raw_gesture_detector_outside_shared_widgets(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            file_path = root / 'lib/features/statistics/presentation/widgets/sample.dart'
            file_path.parent.mkdir(parents=True)
            file_path.write_text(
                'return GestureDetector(onTap: () {});',
                encoding='utf-8',
            )
            guard = self._create_guard(root)

            violations = guard.check_file(
                file_path,
                file_path.read_text(encoding='utf-8').splitlines(),
            )

            self.assertEqual(1, len(violations))
            self.assertIn('AppTapRegion', violations[0].message)

    def test_skips_shared_widget_implementations(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            file_path = root / 'lib/shared/widgets/inputs/app_text_field.dart'
            file_path.parent.mkdir(parents=True)
            file_path.write_text('final field = TextField();', encoding='utf-8')
            guard = self._create_guard(root)

            violations = guard.check_file(
                file_path,
                file_path.read_text(encoding='utf-8').splitlines(),
            )

            self.assertEqual([], violations)

    def _create_guard(self, root: Path) -> 'ConfiguredRuleHarness':
        rule = _load_rule('shared_widget')
        config = {
            'source_root': 'lib',
            'test_root': 'test',
            'paths': {
                'core_dir': 'lib/core',
                'shared_dir': 'lib/shared',
                'features_dir': 'lib/features',
                'exclude_patterns': [],
            },
            'global_guards': {'shared_widget': True},
            'rules': [rule],
        }
        paths = PathConstants.from_config(root, config)
        executor = RuleExecutor(config=config, paths=paths)
        return ConfiguredRuleHarness(executor)


class ConfiguredRuleHarness:
    def __init__(self, executor: RuleExecutor) -> None:
        self.executor = executor

    def check_file(self, file_path: Path, _: list[str]) -> list:
        results = self.executor.run(files=[file_path], family='global')
        return results[0].violations


def _load_rule(rule_id: str) -> dict:
    config = yaml.safe_load(_POLICY_PATH.read_text(encoding='utf-8'))
    for rule in config.get('rules', []):
        if rule.get('id') == rule_id:
            return rule
    raise AssertionError(f'Rule {rule_id} not found in policy.yaml')


if __name__ == '__main__':
    unittest.main()
