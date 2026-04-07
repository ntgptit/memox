from __future__ import annotations

from pathlib import Path
import tempfile
import unittest

import yaml

from tools.guard.core.path_constants import PathConstants
from tools.guard.core.rule_executor import RuleExecutor

_REPO_ROOT = Path(__file__).resolve().parents[4]
_POLICY_PATH = _REPO_ROOT / 'tools/guard/policies/memox/policy.yaml'


class NoHardcodedColorGuardTest(unittest.TestCase):
    def test_reports_material_colors_usage(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            file_path = root / 'lib/sample.dart'
            file_path.parent.mkdir(parents=True)
            file_path.write_text(
                'final color = Colors.green;',
                encoding='utf-8',
            )
            guard = self._create_guard(root)

            violations = guard.check_file(
                [file_path],
            )

            self.assertEqual(1, len(violations))
            self.assertIn('context.colors.*', violations[0].message)
            self.assertIn('context.customColors.*', violations[0].message)

    def test_allows_context_color_access(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            file_path = root / 'lib/sample.dart'
            file_path.parent.mkdir(parents=True)
            file_path.write_text(
                'final color = context.colors.primary;',
                encoding='utf-8',
            )
            guard = self._create_guard(root)

            violations = guard.check_file(
                [file_path],
            )

            self.assertEqual([], violations)

    def _create_guard(self, root: Path) -> 'ConfiguredRuleHarness':
        rule = _load_rule('no_hardcoded_color')
        config = {
            'source_root': 'lib',
            'test_root': 'test',
            'paths': {
                'core_dir': 'lib/core',
                'shared_dir': 'lib/shared',
                'features_dir': 'lib/features',
                'exclude_patterns': [],
            },
            'global_guards': {'no_hardcoded_color': True},
            'rules': [rule],
        }
        paths = PathConstants.from_config(root, config)
        executor = RuleExecutor(config=config, paths=paths)
        return ConfiguredRuleHarness(executor)


class ConfiguredRuleHarness:
    def __init__(self, executor: RuleExecutor) -> None:
        self.executor = executor

    def check_file(self, files: list[Path]) -> list:
        results = self.executor.run(files=files, family='global')
        return results[0].violations


def _load_rule(rule_id: str) -> dict:
    config = yaml.safe_load(_POLICY_PATH.read_text(encoding='utf-8'))
    for rule in config.get('rules', []):
        if rule.get('id') == rule_id:
            return rule
    raise AssertionError(f'Rule {rule_id} not found in policy.yaml')


if __name__ == '__main__':
    unittest.main()
