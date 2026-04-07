from __future__ import annotations

from pathlib import Path
import unittest

from tools.guard import run


class PolicyLoadingTest(unittest.TestCase):
    def test_load_runtime_reads_memox_policy_and_rules(self) -> None:
        args = run.parse_args(['--policy', 'memox', '--scope', 'features'])
        runtime = run.load_runtime(args)
        definitions = runtime.registry.list_guard_definitions(family='all')
        definition_ids = {definition.guard_id for definition in definitions}

        self.assertEqual(
            runtime.config_path.relative_to(run.REPO_ROOT).as_posix(),
            'tools/guard/policies/memox/policy.yaml',
        )
        self.assertEqual(
            runtime.rules_path.relative_to(run.REPO_ROOT).as_posix(),
            'tools/guard/policies/memox/rules.yaml',
        )
        self.assertEqual(runtime.config['project_name'], 'MemoX')
        self.assertEqual(runtime.config['_runtime']['scope'], 'features')
        self.assertEqual(runtime.path_constants.scope_ids, ('all', 'core', 'shared', 'features', 'test'))
        self.assertIn('no_else', definition_ids)
        self.assertIn('shared_widget', definition_ids)
        self.assertIn('import_direction', definition_ids)

    def test_resolve_policy_paths_accepts_repo_relative_policy_dir(self) -> None:
        args = run.parse_args(['--policy', 'tools/guard/policies/memox'])
        config_path, rules_path = run.resolve_policy_paths(args)

        self.assertEqual(
            config_path,
            run.REPO_ROOT / 'tools/guard/policies/memox/policy.yaml',
        )
        self.assertEqual(
            rules_path,
            run.REPO_ROOT / 'tools/guard/policies/memox/rules.yaml',
        )

    def test_available_policy_names_includes_memox(self) -> None:
        self.assertIn('memox', run._available_policy_names())

    def test_load_runtime_applies_selected_profile_and_exit_policy(self) -> None:
        args = run.parse_args(['--policy', 'memox', '--profile', 'strict'])
        runtime = run.load_runtime(args)

        self.assertEqual(runtime.active_profile, 'strict')
        self.assertEqual(runtime.exit_policy.name, 'strict')
        self.assertEqual(
            {severity.value for severity in runtime.exit_policy.fail_on},
            {'error', 'warning'},
        )
        folder_structure = next(
            rule
            for rule in runtime.registry.executor.rules
            if rule.id == 'folder_structure'
        )
        self.assertEqual(folder_structure.severity, 'warning')


if __name__ == '__main__':
    unittest.main()
