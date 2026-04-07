from __future__ import annotations

from pathlib import Path
import tempfile
import unittest

import yaml

from tools.guard.core.guard_registry import GuardRegistry
from tools.guard.core.path_constants import PathConstants
from tools.guard.core.guard_result import GuardScope

# Canonical policy location for MemoX (mirrors the default in run.py).
_REPO_ROOT = Path(__file__).resolve().parents[4]
_POLICY_DIR = _REPO_ROOT / 'tools/guard/policies/memox'


class GuardRegistryTest(unittest.TestCase):
    def test_registry_discovers_global_and_local_families(self) -> None:
        config = yaml.safe_load((_POLICY_DIR / 'policy.yaml').read_text(encoding='utf-8'))
        rules  = yaml.safe_load((_POLICY_DIR / 'rules.yaml').read_text(encoding='utf-8'))
        paths  = PathConstants.from_config(_REPO_ROOT, config)
        registry = GuardRegistry(config=config, path_constants=paths, project_rules=rules)

        global_guards = registry.create_guards(family='global')
        local_guards  = registry.create_guards(family='local')

        self.assertTrue(global_guards)
        self.assertTrue(local_guards)
        self.assertTrue(all(guard.SCOPE == GuardScope.GLOBAL for guard in global_guards))
        self.assertTrue(all(guard.SCOPE == GuardScope.LOCAL  for guard in local_guards))

    def test_normalized_rule_skips_legacy_guard_execution(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            file_path = root / 'lib' / 'feature.dart'
            file_path.parent.mkdir(parents=True)
            file_path.write_text('ElevatedButton(onPressed: callback)\n', encoding='utf-8')

            config = {
                'source_root': 'lib',
                'test_root': 'test',
                'language_extensions': ['.dart'],
                'paths': {
                    'core_dir': 'lib/core',
                    'shared_dir': 'lib/shared',
                    'features_dir': 'lib/features',
                    'exclude_patterns': [],
                },
                'local_guards': {'button_usage': True},
                'rules': [
                    {
                        'id': 'button_usage',
                        'type': 'forbidden_pattern',
                        'scope': 'local',
                        'patterns': [
                            {
                                'regex': r'\bElevatedButton(?:\.\w+)?\(',
                                'message': 'Raw Material button detected.',
                            },
                        ],
                    },
                ],
            }
            paths = PathConstants.from_config(root, config)
            registry = GuardRegistry(config=config, path_constants=paths, project_rules={})

            results = registry.run(family='local', guard_ids={'button_usage'}, scope='all')

            self.assertEqual(len(results), 1)
            self.assertEqual(results[0].guard_id, 'button_usage')
            self.assertEqual(len(results[0].violations), 1)

    def test_list_guard_definitions_prefers_normalized_runtime_entries(self) -> None:
        config = yaml.safe_load((_POLICY_DIR / 'policy.yaml').read_text(encoding='utf-8'))
        rules = yaml.safe_load((_POLICY_DIR / 'rules.yaml').read_text(encoding='utf-8'))
        paths = PathConstants.from_config(_REPO_ROOT, config)
        registry = GuardRegistry(config=config, path_constants=paths, project_rules=rules)

        definitions = registry.list_guard_definitions(family='all')
        by_id = {definition.guard_id: definition for definition in definitions}

        self.assertEqual(by_id['button_usage'].source, 'normalized')
        self.assertEqual(by_id['shared_widget'].source, 'normalized')
        self.assertEqual(by_id['import_direction'].source, 'legacy')


if __name__ == '__main__':
    unittest.main()
