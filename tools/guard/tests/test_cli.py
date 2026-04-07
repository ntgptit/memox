from __future__ import annotations

from contextlib import redirect_stderr, redirect_stdout
from io import StringIO
from pathlib import Path
import tempfile
import unittest

from tools.guard import run


class GuardCliTest(unittest.TestCase):
    def test_validate_config_accepts_policy_name_shorthand(self) -> None:
        result = run.main(['--policy', 'memox', '--validate-config', '--quiet'])

        self.assertEqual(result, 0)

    def test_unknown_policy_fails_fast_with_clear_error(self) -> None:
        stderr = StringIO()

        with redirect_stderr(stderr):
            result = run.main(['--policy', 'does-not-exist', '--validate-config'])

        self.assertEqual(result, 2)
        self.assertIn("Unknown policy 'does-not-exist'", stderr.getvalue())

    def test_list_alias_prints_guard_inventory(self) -> None:
        stdout = StringIO()

        with redirect_stdout(stdout):
            result = run.main(['--policy', 'memox', '--list', '--family', 'global'])

        self.assertEqual(result, 0)
        self.assertIn('no_else', stdout.getvalue())

    def test_list_profiles_output_matches_expected_snapshot(self) -> None:
        stdout = StringIO()

        with redirect_stdout(stdout):
            result = run.main(['--policy', 'memox', '--list-profiles'])

        self.assertEqual(result, 0)
        self.assertEqual(
            stdout.getvalue(),
            '\n'.join([
                'Available profiles:',
                '- ci: exit_policy=strict CI preset aligned with strict guard enforcement.',
                '- default: exit_policy=default Explicit alias for the current MemoX default behavior.',
                '- legacy_migration: exit_policy=default Reduce style-oriented noise during incremental migrations.',
                '- strict: exit_policy=strict Promote structure drift and fail on warning-tier findings.',
                '',
            ]),
        )

    def test_unknown_scope_fails_fast_with_clear_error(self) -> None:
        stderr = StringIO()

        with redirect_stderr(stderr):
            result = run.main(['--policy', 'memox', '--scope', 'nope', '--validate-config'])

        self.assertEqual(result, 2)
        self.assertIn("Unknown scope 'nope'", stderr.getvalue())

    def test_unknown_profile_fails_fast_with_clear_error(self) -> None:
        stderr = StringIO()

        with redirect_stderr(stderr):
            result = run.main([
                '--policy',
                'memox',
                '--profile',
                'does-not-exist',
                '--validate-config',
            ])

        self.assertEqual(result, 2)
        self.assertIn("Unknown profile 'does-not-exist'", stderr.getvalue())

    def test_unknown_guard_id_fails_fast_with_clear_error(self) -> None:
        stderr = StringIO()

        with redirect_stderr(stderr):
            result = run.main([
                '--policy',
                'memox',
                '--guard',
                'not_a_guard',
                '--validate-config',
            ])

        self.assertEqual(result, 2)
        self.assertIn("Unknown guard id(s)", stderr.getvalue())

    def test_list_scopes_output_matches_expected_snapshot(self) -> None:
        stdout = StringIO()

        with redirect_stdout(stdout):
            result = run.main(['--policy', 'memox', '--list-scopes'])

        self.assertEqual(result, 0)
        self.assertEqual(
            stdout.getvalue(),
            '\n'.join([
                'Available scopes:',
                '- all: roots=[lib, test] extensions=[.dart]',
                '- core: roots=[lib/core] extensions=[.dart]',
                '- shared: roots=[lib/shared] extensions=[.dart]',
                '- features: roots=[lib/features] extensions=[.dart]',
                '- test: roots=[test] extensions=[.dart]',
                '',
            ]),
        )

    def test_repo_relative_scope_directory_still_works_as_compatibility_fallback(self) -> None:
        result = run.main([
            '--policy',
            'memox',
            '--scope',
            'tools/guard',
            '--validate-config',
            '--quiet',
        ])

        self.assertEqual(result, 0)

    def test_invalid_config_yaml_reports_clear_error(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            config_path = root / 'policy.yaml'
            rules_path = root / 'rules.yaml'
            config_path.write_text('scan_targets: [\n', encoding='utf-8')
            rules_path.write_text('{}\n', encoding='utf-8')
            stderr = StringIO()

            with redirect_stderr(stderr):
                result = run.main([
                    '--config',
                    str(config_path),
                    '--rules',
                    str(rules_path),
                    '--validate-config',
                ])

        self.assertEqual(result, 2)
        self.assertIn('Invalid YAML in policy config file', stderr.getvalue())

    def test_non_mapping_rules_file_reports_clear_error(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            config_path = root / 'policy.yaml'
            rules_path = root / 'rules.yaml'
            config_path.write_text(
                '\n'.join([
                    'project_name: TempPolicy',
                    'source_root: lib',
                    'test_root: test',
                    'paths:',
                    '  core_dir: lib/core',
                    '  shared_dir: lib/shared',
                    '  features_dir: lib/features',
                    '  exclude_patterns: []',
                    'scan_targets:',
                    '  all:',
                    '    roots: [lib, test]',
                    'global_guards: {}',
                    'local_guards: {}',
                    'rules: []',
                    '',
                ]),
                encoding='utf-8',
            )
            rules_path.write_text('- invalid\n', encoding='utf-8')
            stderr = StringIO()

            with redirect_stderr(stderr):
                result = run.main([
                    '--config',
                    str(config_path),
                    '--rules',
                    str(rules_path),
                    '--validate-config',
                ])

        self.assertEqual(result, 2)
        self.assertIn(
            'Project rules file must contain a YAML mapping at the top level',
            stderr.getvalue(),
        )

    def test_explicit_config_and_rules_overrides_do_not_require_policy_dir(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            config_path = root / 'policy.yaml'
            rules_path = root / 'rules.yaml'
            config_path.write_text(
                '\n'.join([
                    'project_name: TempPolicy',
                    'source_root: lib',
                    'test_root: test',
                    'paths:',
                    '  core_dir: lib/core',
                    '  shared_dir: lib/shared',
                    '  features_dir: lib/features',
                    '  exclude_patterns: []',
                    'scan_targets:',
                    '  all:',
                    '    roots: [lib, test]',
                    'global_guards: {}',
                    'local_guards: {}',
                    'rules: []',
                    '',
                ]),
                encoding='utf-8',
            )
            rules_path.write_text('{}\n', encoding='utf-8')

            result = run.main([
                '--policy',
                'does-not-exist',
                '--config',
                str(config_path),
                '--rules',
                str(rules_path),
                '--validate-config',
                '--quiet',
            ])

        self.assertEqual(result, 0)

    def test_invalid_rule_schema_reports_clear_error(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            config_path = root / 'policy.yaml'
            rules_path = root / 'rules.yaml'
            config_path.write_text(
                '\n'.join([
                    'project_name: BrokenPolicy',
                    'source_root: lib',
                    'test_root: test',
                    'paths:',
                    '  core_dir: lib/core',
                    '  shared_dir: lib/shared',
                    '  features_dir: lib/features',
                    '  exclude_patterns: []',
                    'scan_targets:',
                    '  all:',
                    '    roots: [lib, test]',
                    'global_guards: {}',
                    'local_guards: {}',
                    'rules:',
                    '  - id: broken',
                    '    type: forbidden_pattern',
                    '    patterns:',
                    '      - regex: "["',
                    '',
                ]),
                encoding='utf-8',
            )
            rules_path.write_text('{}\n', encoding='utf-8')
            stderr = StringIO()

            with redirect_stderr(stderr):
                result = run.main([
                    '--config',
                    str(config_path),
                    '--rules',
                    str(rules_path),
                    '--validate-config',
                ])

        self.assertEqual(result, 2)
        self.assertIn('Invalid normalized rule schema', stderr.getvalue())

    def test_invalid_message_catalog_reports_clear_error(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            config_path = root / 'policy.yaml'
            rules_path = root / 'rules.yaml'
            config_path.write_text(
                '\n'.join([
                    'project_name: BrokenPolicy',
                    'source_root: lib',
                    'test_root: test',
                    'paths:',
                    '  core_dir: lib/core',
                    '  shared_dir: lib/shared',
                    '  features_dir: lib/features',
                    '  exclude_patterns: []',
                    'scan_targets:',
                    '  all:',
                    '    roots: [lib, test]',
                    'global_guards: {}',
                    'local_guards: {}',
                    'message_catalog: []',
                    'rules: []',
                    '',
                ]),
                encoding='utf-8',
            )
            rules_path.write_text('{}\n', encoding='utf-8')
            stderr = StringIO()

            with redirect_stderr(stderr):
                result = run.main([
                    '--config',
                    str(config_path),
                    '--rules',
                    str(rules_path),
                    '--validate-config',
                ])

        self.assertEqual(result, 2)
        self.assertIn('Invalid message/remediation catalog', stderr.getvalue())

    def test_invalid_exit_policy_reports_clear_error(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            config_path = root / 'policy.yaml'
            rules_path = root / 'rules.yaml'
            config_path.write_text(
                '\n'.join([
                    'project_name: BrokenPolicy',
                    'source_root: lib',
                    'test_root: test',
                    'paths:',
                    '  core_dir: lib/core',
                    '  shared_dir: lib/shared',
                    '  features_dir: lib/features',
                    '  exclude_patterns: []',
                    'scan_targets:',
                    '  all:',
                    '    roots: [lib, test]',
                    'global_guards: {}',
                    'local_guards: {}',
                    'exit_policy:',
                    '  strict:',
                    '    fail_on: critical',
                    'rules: []',
                    '',
                ]),
                encoding='utf-8',
            )
            rules_path.write_text('{}\n', encoding='utf-8')
            stderr = StringIO()

            with redirect_stderr(stderr):
                result = run.main([
                    '--config',
                    str(config_path),
                    '--rules',
                    str(rules_path),
                    '--validate-config',
                ])

        self.assertEqual(result, 2)
        self.assertIn('Invalid exit policy configuration', stderr.getvalue())

    def test_invalid_category_override_reports_clear_error(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            config_path = root / 'policy.yaml'
            rules_path = root / 'rules.yaml'
            config_path.write_text(
                '\n'.join([
                    'project_name: BrokenPolicy',
                    'source_root: lib',
                    'test_root: test',
                    'paths:',
                    '  core_dir: lib/core',
                    '  shared_dir: lib/shared',
                    '  features_dir: lib/features',
                    '  exclude_patterns: []',
                    'scan_targets:',
                    '  all:',
                    '    roots: [lib, test]',
                    'global_guards: {}',
                    'local_guards: {}',
                    'category_overrides:',
                    '  no_else: forbidden_pattern',
                    'rules: []',
                    '',
                ]),
                encoding='utf-8',
            )
            rules_path.write_text('{}\n', encoding='utf-8')
            stderr = StringIO()

            with redirect_stderr(stderr):
                result = run.main([
                    '--config',
                    str(config_path),
                    '--rules',
                    str(rules_path),
                    '--validate-config',
                ])

        self.assertEqual(result, 2)
        self.assertIn('Invalid severity/category configuration', stderr.getvalue())

    def test_selected_profile_can_disable_guard_without_code_changes(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            config_path = root / 'policy.yaml'
            rules_path = root / 'rules.yaml'
            config_path.write_text(
                '\n'.join([
                    'project_name: TempPolicy',
                    'source_root: lib',
                    'test_root: test',
                    'paths:',
                    '  core_dir: lib/core',
                    '  shared_dir: lib/shared',
                    '  features_dir: lib/features',
                    '  exclude_patterns: []',
                    'scan_targets:',
                    '  all:',
                    '    roots: [lib, test]',
                    'global_guards:',
                    '  no_else: true',
                    'local_guards: {}',
                    'rule_profiles:',
                    '  migration:',
                    '    global_guards:',
                    '      no_else: false',
                    'rules:',
                    '  - id: no_else',
                    '    type: forbidden_pattern',
                    '    scope: global',
                    '    patterns:',
                    '      - regex: "\\\\belse\\\\b"',
                    '        message: "No else."',
                    '',
                ]),
                encoding='utf-8',
            )
            rules_path.write_text('{}\n', encoding='utf-8')
            args = run.parse_args([
                '--config',
                str(config_path),
                '--rules',
                str(rules_path),
                '--profile',
                'migration',
                '--validate-config',
            ])
            runtime = run.load_runtime(args)

        definitions = runtime.registry.list_guard_definitions(family='global')
        no_else = next(definition for definition in definitions if definition.guard_id == 'no_else')
        self.assertFalse(no_else.enabled)


if __name__ == '__main__':
    unittest.main()
