from __future__ import annotations

import tempfile
import unittest
from pathlib import Path

from tools.guard.core.guard_result import GuardScope, Severity
from tools.guard.core.path_constants import PathConstants
from tools.guard.core.rule_executor import RuleExecutor
from tools.guard.core.rule_schema import parse_rules, validate_rule


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _make_paths(root: Path) -> PathConstants:
    config = {
        'source_root': 'lib',
        'test_root': 'test',
        'paths': {
            'core_dir': 'lib/core',
            'shared_dir': 'lib/shared',
            'features_dir': 'lib/features',
            'exclude_patterns': [],
        },
        'language_extensions': ['.dart'],
    }
    return PathConstants.from_config(root, config)


def _make_dart_file(root: Path, rel_path: str, content: str) -> Path:
    full = root / rel_path
    full.parent.mkdir(parents=True, exist_ok=True)
    full.write_text(content, encoding='utf-8')
    return full


def _executor_with_rules(root: Path, rules: list[dict], overrides: dict | None = None) -> tuple[RuleExecutor, PathConstants]:
    paths = _make_paths(root)
    config: dict = {'rules': rules}
    if overrides:
        config['severity_overrides'] = overrides
    executor = RuleExecutor(config=config, paths=paths)
    return executor, paths


# ---------------------------------------------------------------------------
# Schema validation tests
# ---------------------------------------------------------------------------

class ValidateRuleTest(unittest.TestCase):
    def test_valid_forbidden_pattern(self) -> None:
        errors = validate_rule({
            'id': 'test',
            'type': 'forbidden_pattern',
            'patterns': [{'regex': r'\belse\b', 'message': 'no else'}],
        })
        self.assertEqual(errors, [])

    def test_valid_file_naming(self) -> None:
        errors = validate_rule({
            'id': 'naming',
            'type': 'file_naming',
            'naming_pattern': r'^[a-z0-9_]+\.dart$',
        })
        self.assertEqual(errors, [])

    def test_valid_content_contract(self) -> None:
        errors = validate_rule({
            'id': 'contract',
            'type': 'content_contract',
            'cases': [
                {
                    'file': 'lib/app.dart',
                    'required_tokens': ['MediaQuery('],
                },
            ],
        })
        self.assertEqual(errors, [])

    def test_valid_path_requirements(self) -> None:
        errors = validate_rule({
            'id': 'paths',
            'type': 'path_requirements',
            'entries': [
                {
                    'path_template': 'lib/features/{feature}/{layer}',
                    'path_kind': 'dir',
                    'variables': {
                        'feature': ['search'],
                        'layer': ['data'],
                    },
                },
            ],
        })
        self.assertEqual(errors, [])

    def test_missing_id(self) -> None:
        errors = validate_rule({'type': 'forbidden_pattern'})
        self.assertTrue(any('missing required field: id' in e for e in errors))

    def test_missing_type(self) -> None:
        errors = validate_rule({'id': 'x'})
        self.assertTrue(any('missing required field: type' in e for e in errors))

    def test_unknown_type(self) -> None:
        errors = validate_rule({'id': 'x', 'type': 'magic_type'})
        self.assertTrue(any('unknown type' in e for e in errors))

    def test_unknown_severity(self) -> None:
        errors = validate_rule({'id': 'x', 'type': 'forbidden_pattern', 'severity': 'critical'})
        self.assertTrue(any('unknown severity' in e for e in errors))

    def test_unknown_category(self) -> None:
        errors = validate_rule({'id': 'x', 'type': 'forbidden_pattern', 'category': 'forbidden_pattern'})
        self.assertTrue(any('unknown category' in e for e in errors))

    def test_unknown_scope(self) -> None:
        errors = validate_rule({'id': 'x', 'type': 'forbidden_pattern', 'scope': 'galaxy'})
        self.assertTrue(any('unknown scope' in e for e in errors))

    def test_forbidden_pattern_missing_regex(self) -> None:
        errors = validate_rule({
            'id': 'x',
            'type': 'forbidden_pattern',
            'patterns': [{'message': 'oops'}],
        })
        self.assertTrue(any('missing required field: regex' in e for e in errors))

    def test_forbidden_pattern_invalid_regex(self) -> None:
        errors = validate_rule({
            'id': 'x',
            'type': 'forbidden_pattern',
            'patterns': [{'regex': r'[invalid', 'message': 'bad'}],
        })
        self.assertTrue(any('invalid regex' in e for e in errors))

    def test_file_naming_missing_pattern(self) -> None:
        errors = validate_rule({'id': 'x', 'type': 'file_naming'})
        self.assertTrue(any('naming_pattern' in e for e in errors))

    def test_parse_rules_raises_on_invalid(self) -> None:
        with self.assertRaises(ValueError) as ctx:
            parse_rules([{'id': 'bad', 'type': 'unknown_type'}])
        self.assertIn('Rule schema validation errors', str(ctx.exception))

    def test_targets_must_be_a_mapping(self) -> None:
        errors = validate_rule({
            'id': 'x',
            'type': 'forbidden_pattern',
            'targets': ['test/'],
            'patterns': [{'regex': r'\belse\b', 'message': 'No else.'}],
        })
        self.assertTrue(any('targets must be a mapping' in e for e in errors))

    def test_targets_include_must_be_a_list(self) -> None:
        errors = validate_rule({
            'id': 'x',
            'type': 'content_contract',
            'targets': {'include': 'lib/'},
            'cases': [{'file': 'lib/app.dart', 'required_tokens': ['MediaQuery(']}],
        })
        self.assertTrue(any('targets.include must be a list' in e for e in errors))


# ---------------------------------------------------------------------------
# RuleExecutor — forbidden_pattern
# ---------------------------------------------------------------------------

class ForbiddenPatternTest(unittest.TestCase):
    def _run(self, root: Path, rule: dict, files: list[Path]) -> list:
        executor, _ = _executor_with_rules(root, [rule])
        return executor.run(files=files)

    def test_detects_pattern(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            f = _make_dart_file(root, 'lib/foo.dart', 'void bar() {\n  if (x) {\n  } else {\n  }\n}\n')
            rule = {
                'id': 'no_else',
                'type': 'forbidden_pattern',
                'patterns': [{'regex': r'\belse\b', 'message': 'No else.'}],
            }
            results = self._run(root, rule, [f])
            self.assertEqual(len(results), 1)
            self.assertEqual(len(results[0].violations), 1)
            self.assertEqual(results[0].violations[0].line_number, 3)

    def test_skip_comment_lines(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            f = _make_dart_file(root, 'lib/foo.dart', '// else should be ignored\n')
            rule = {
                'id': 'no_else',
                'type': 'forbidden_pattern',
                'skip_comments': True,
                'patterns': [{'regex': r'\belse\b', 'message': 'No else.'}],
            }
            results = self._run(root, rule, [f])
            self.assertEqual(results[0].violations, [])

    def test_skip_comments_false_does_not_skip(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            f = _make_dart_file(root, 'lib/foo.dart', '// .when(\n')
            rule = {
                'id': 'async_builder',
                'type': 'forbidden_pattern',
                'skip_comments': False,
                'patterns': [{'regex': r'\.when\s*\(', 'message': 'Use AppAsyncBuilder.'}],
            }
            results = self._run(root, rule, [f])
            self.assertEqual(len(results[0].violations), 1)

    def test_literal_skip(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            f = _make_dart_file(root, 'lib/foo.dart', 'String s = "else";\n')
            rule = {
                'id': 'no_else',
                'type': 'forbidden_pattern',
                'literal_skip': ['"else"'],
                'patterns': [{'regex': r'\belse\b', 'message': 'No else.'}],
            }
            results = self._run(root, rule, [f])
            self.assertEqual(results[0].violations, [])

    def test_exclude_substring(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            f = _make_dart_file(root, 'test/widget_test.dart', 'else {\n')
            rule = {
                'id': 'no_else',
                'type': 'forbidden_pattern',
                'targets': {'exclude': ['test/']},
                'patterns': [{'regex': r'\belse\b', 'message': 'No else.'}],
            }
            results = self._run(root, rule, [f])
            self.assertEqual(results[0].violations, [])

    def test_exclude_glob(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            f = _make_dart_file(root, 'lib/foo.g.dart', 'else {\n')
            rule = {
                'id': 'no_else',
                'type': 'forbidden_pattern',
                'targets': {'exclude': ['*.g.dart']},
                'patterns': [{'regex': r'\belse\b', 'message': 'No else.'}],
            }
            results = self._run(root, rule, [f])
            self.assertEqual(results[0].violations, [])

    def test_include_filter(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            f_in  = _make_dart_file(root, 'lib/features/home/presentation/screens/home_screen.dart', 'else {\n')
            f_out = _make_dart_file(root, 'lib/core/utils/helper.dart', 'else {\n')
            rule = {
                'id': 'no_else',
                'type': 'forbidden_pattern',
                'targets': {'include': ['features/**/screens/*.dart']},
                'patterns': [{'regex': r'\belse\b', 'message': 'No else.'}],
            }
            results = self._run(root, rule, [f_in, f_out])
            # Only the screen file should produce a violation
            self.assertEqual(len(results[0].violations), 1)
            self.assertIn('home_screen.dart', results[0].violations[0].file_path)

    def test_multiple_patterns_one_violation_per_line(self) -> None:
        """When multiple patterns could match the same line, only one violation is emitted."""
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            f = _make_dart_file(root, 'lib/foo.dart', 'StateNotifierProvider\n')
            rule = {
                'id': 'legacy',
                'type': 'forbidden_pattern',
                'patterns': [
                    {'regex': 'StateNotifierProvider', 'message': 'A'},
                    {'regex': 'StateNotifier', 'message': 'B'},
                ],
            }
            results = self._run(root, rule, [f])
            self.assertEqual(len(results[0].violations), 1)
            self.assertEqual(results[0].violations[0].message, 'A')


# ---------------------------------------------------------------------------
# RuleExecutor — file_naming
# ---------------------------------------------------------------------------

class FileNamingTest(unittest.TestCase):
    def _run_naming(self, root: Path, files: list[Path]) -> list:
        rule = {
            'id': 'naming_convention',
            'type': 'file_naming',
            'naming_pattern': r'^[a-z0-9_]+\.dart$',
            'naming_message': 'File name must be snake_case.',
        }
        executor, _ = _executor_with_rules(root, [rule])
        return executor.run(files=files)

    def test_valid_name_no_violation(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            f = _make_dart_file(root, 'lib/foo_bar.dart', '')
            results = self._run_naming(root, [f])
            self.assertEqual(results[0].violations, [])

    def test_invalid_name_produces_violation(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            f = _make_dart_file(root, 'lib/FooBar.dart', '')
            results = self._run_naming(root, [f])
            self.assertEqual(len(results[0].violations), 1)
            self.assertIn('snake_case', results[0].violations[0].message)

    def test_g_dart_excluded_by_target(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            f = _make_dart_file(root, 'lib/FooBar.g.dart', '')
            rule = {
                'id': 'naming_convention',
                'type': 'file_naming',
                'naming_pattern': r'^[a-z0-9_]+\.dart$',
                'naming_message': 'File name must be snake_case.',
                'targets': {'exclude': ['*.g.dart', '*.freezed.dart']},
            }
            executor, _ = _executor_with_rules(root, [rule])
            results = executor.run(files=[f])
            self.assertEqual(results[0].violations, [])


# ---------------------------------------------------------------------------
# RuleExecutor — content_contract
# ---------------------------------------------------------------------------

class ContentContractTest(unittest.TestCase):
    def test_exact_file_aggregates_missing_required_tokens(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            _make_dart_file(root, 'lib/app.dart', 'MaterialApp(home: child)\n')
            rule = {
                'id': 'responsive_text_scale',
                'type': 'content_contract',
                'messages': {
                    'aggregate_missing_required_tokens': (
                        '`{file_name}` thiếu {tokens}.'
                    ),
                },
                'cases': [
                    {
                        'file': 'lib/app.dart',
                        'required_tokens': ['MediaQuery(', 'TextScaler.linear('],
                    },
                ],
            }
            executor, _ = _executor_with_rules(root, [rule])
            results = executor.run(files=[])
            self.assertEqual(len(results[0].violations), 1)
            self.assertIn('MediaQuery(', results[0].violations[0].message)
            self.assertIn('TextScaler.linear(', results[0].violations[0].message)

    def test_path_pattern_requires_any_of_tokens(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            file_path = _make_dart_file(
                root,
                'lib/features/search/presentation/screens/search_screen.dart',
                'Widget build(BuildContext context) => SearchPlaceholderView();\n',
            )
            rule = {
                'id': 'screen_scaffold',
                'type': 'content_contract',
                'messages': {
                    'missing_required_any_tokens': 'Missing scaffold contract.',
                },
                'cases': [
                    {
                        'path_patterns': ['features/*/presentation/screens/*_screen.dart'],
                        'required_any_tokens': ['AppScaffold(', 'SliverScaffold('],
                    },
                ],
            }
            executor, _ = _executor_with_rules(root, [rule])
            results = executor.run(files=[file_path])
            self.assertEqual(len(results[0].violations), 1)
            self.assertEqual(results[0].violations[0].message, 'Missing scaffold contract.')

    def test_forbidden_patterns_detected_in_content_contract(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            file_path = _make_dart_file(
                root,
                'lib/features/search/presentation/screens/search_screen.dart',
                'Widget build(BuildContext context) => Scaffold(body: child);\n',
            )
            rule = {
                'id': 'screen_scaffold',
                'type': 'content_contract',
                'messages': {
                    'forbidden_pattern': 'Raw Scaffold forbidden.',
                },
                'cases': [
                    {
                        'path_patterns': ['features/*/presentation/screens/*_screen.dart'],
                        'forbidden_patterns': [{'regex': r'\bScaffold\('}],
                    },
                ],
            }
            executor, _ = _executor_with_rules(root, [rule])
            results = executor.run(files=[file_path])
            self.assertEqual(len(results[0].violations), 1)
            self.assertEqual(results[0].violations[0].message, 'Raw Scaffold forbidden.')

    def test_content_contract_targets_exclude_prevents_exact_file_check(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            _make_dart_file(root, 'lib/app.dart', 'MaterialApp(home: child)\n')
            rule = {
                'id': 'responsive_text_scale',
                'type': 'content_contract',
                'targets': {'exclude': ['lib/app.dart']},
                'cases': [
                    {
                        'file': 'lib/app.dart',
                        'required_tokens': ['MediaQuery('],
                    },
                ],
            }
            executor, _ = _executor_with_rules(root, [rule])
            results = executor.run(files=[])
            self.assertEqual(results[0].violations, [])

    def test_content_contract_targets_include_filters_path_pattern_files(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            allowed = _make_dart_file(
                root,
                'lib/features/search/presentation/screens/search_screen.dart',
                'Widget build(BuildContext context) => SearchPlaceholderView();\n',
            )
            blocked = _make_dart_file(
                root,
                'lib/features/search/presentation/widgets/search_view.dart',
                'Widget build(BuildContext context) => SearchPlaceholderView();\n',
            )
            rule = {
                'id': 'screen_scaffold',
                'type': 'content_contract',
                'targets': {'include': ['features/**/screens/*.dart']},
                'messages': {
                    'missing_required_any_tokens': 'Missing scaffold contract.',
                },
                'cases': [
                    {
                        'path_patterns': ['features/*/presentation/**/*.dart'],
                        'required_any_tokens': ['AppScaffold(', 'SliverScaffold('],
                    },
                ],
            }
            executor, _ = _executor_with_rules(root, [rule])
            results = executor.run(files=[allowed, blocked])
            self.assertEqual(len(results[0].violations), 1)
            self.assertIn('search_screen.dart', results[0].violations[0].file_path)


# ---------------------------------------------------------------------------
# RuleExecutor — path_requirements
# ---------------------------------------------------------------------------

class PathRequirementsTest(unittest.TestCase):
    def test_reports_missing_template_expanded_directories(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            (root / 'lib/features/search').mkdir(parents=True)
            rule = {
                'id': 'folder_structure',
                'type': 'path_requirements',
                'scope': 'local',
                'entries': [
                    {
                        'path_template': 'lib/features/{feature}/{layer}',
                        'path_kind': 'dir',
                        'variables': {
                            'feature': ['search'],
                            'layer': ['data', 'domain'],
                        },
                        'messages': {
                            'missing_path': '{feature}/ thiếu layer {layer}/',
                        },
                    },
                ],
            }
            executor, _ = _executor_with_rules(root, [rule])
            executor.config['_runtime'] = {'scope': 'features'}
            results = executor.run(files=[])
            messages = [violation.message for violation in results[0].violations]
            self.assertIn('search/ thiếu layer data/', messages)
            self.assertIn('search/ thiếu layer domain/', messages)

    def test_reports_empty_directory_when_contains_glob_missing(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            (root / 'lib/features/search/data/repositories').mkdir(parents=True)
            rule = {
                'id': 'feature_completeness',
                'type': 'path_requirements',
                'scope': 'local',
                'entries': [
                    {
                        'path': 'lib/features/search/data/repositories',
                        'path_kind': 'dir',
                        'must_exist': False,
                        'contains_glob': '*.dart',
                        'messages': {
                            'empty_path': 'search/data/repositories đang rỗng.',
                        },
                    },
                ],
            }
            executor, _ = _executor_with_rules(root, [rule])
            executor.config['_runtime'] = {'scope': 'features'}
            results = executor.run(files=[])
            self.assertEqual(len(results[0].violations), 1)
            self.assertEqual(
                results[0].violations[0].message,
                'search/data/repositories đang rỗng.',
            )

    def test_path_requirements_targets_exclude_skips_matching_entries(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            rule = {
                'id': 'folder_structure',
                'type': 'path_requirements',
                'scope': 'local',
                'targets': {'exclude': ['lib/features/**']},
                'entries': [
                    {
                        'path': 'lib/features/search/data',
                        'path_kind': 'dir',
                        'messages': {
                            'missing_path': 'missing features data dir',
                        },
                    },
                ],
            }
            executor, _ = _executor_with_rules(root, [rule])
            executor.config['_runtime'] = {'scope': 'features'}
            results = executor.run(files=[])
            self.assertEqual(results[0].violations, [])


# ---------------------------------------------------------------------------
# RuleExecutor — severity / disabled / family / guard_ids
# ---------------------------------------------------------------------------

class ExecutorFilteringTest(unittest.TestCase):
    def _base_rule(self, **overrides) -> dict:
        rule = {
            'id': 'no_else',
            'type': 'forbidden_pattern',
            'severity': 'error',
            'scope': 'global',
            'enabled': True,
            'patterns': [{'regex': r'\belse\b', 'message': 'No else.'}],
        }
        rule.update(overrides)
        return rule

    def test_severity_override_applied(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            f = _make_dart_file(root, 'lib/foo.dart', 'else {\n')
            executor, _ = _executor_with_rules(root, [self._base_rule()], overrides={'no_else': 'warning'})
            results = executor.run(files=[f])
            self.assertEqual(results[0].violations[0].severity, Severity.WARNING)

    def test_category_override_applied(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            f = _make_dart_file(root, 'lib/foo.dart', 'else {\n')
            paths = _make_paths(root)
            config = {
                'rules': [self._base_rule()],
                'category_overrides': {'no_else': 'style'},
            }
            executor = RuleExecutor(config=config, paths=paths)
            results = executor.run(files=[f])
            self.assertEqual(results[0].violations[0].category, 'style')

    def test_disabled_rule_produces_no_result(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            f = _make_dart_file(root, 'lib/foo.dart', 'else {\n')
            executor, _ = _executor_with_rules(root, [self._base_rule(enabled=False)])
            results = executor.run(files=[f])
            self.assertEqual(results, [])

    def test_guard_enable_map_can_disable_normalized_rule(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            f = _make_dart_file(root, 'lib/foo.dart', 'else {\n')
            executor, _ = _executor_with_rules(root, [self._base_rule()])
            executor.config['global_guards'] = {'no_else': False}
            results = executor.run(files=[f])
            self.assertEqual(results, [])

    def test_family_global_excludes_local_rules(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            f = _make_dart_file(root, 'lib/foo.dart', 'StateNotifierProvider\n')
            local_rule = self._base_rule(
                id='legacy', scope='local',
                patterns=[{'regex': 'StateNotifierProvider', 'message': 'x'}],
            )
            executor, _ = _executor_with_rules(root, [local_rule])
            results = executor.run(files=[f], family='global')
            self.assertEqual(results, [])

    def test_family_local_excludes_global_rules(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            f = _make_dart_file(root, 'lib/foo.dart', 'else {\n')
            executor, _ = _executor_with_rules(root, [self._base_rule(scope='global')])
            results = executor.run(files=[f], family='local')
            self.assertEqual(results, [])

    def test_guard_ids_filter(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            f = _make_dart_file(root, 'lib/foo.dart', 'else {\n')
            executor, _ = _executor_with_rules(root, [self._base_rule()])
            results = executor.run(files=[f], guard_ids={'other_guard'})
            self.assertEqual(results, [])

    def test_rule_ids_property(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            executor, _ = _executor_with_rules(root, [self._base_rule()])
            self.assertIn('no_else', executor.rule_ids)


# ---------------------------------------------------------------------------
# RuleExecutor — scope propagation to Violation
# ---------------------------------------------------------------------------

class ScopePropagationTest(unittest.TestCase):
    def test_local_scope_propagated(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            f = _make_dart_file(root, 'lib/foo.dart', 'StateNotifierProvider\n')
            rule = {
                'id': 'legacy',
                'type': 'forbidden_pattern',
                'scope': 'local',
                'patterns': [{'regex': 'StateNotifierProvider', 'message': 'x'}],
            }
            executor, _ = _executor_with_rules(root, [rule])
            results = executor.run(files=[f])
            self.assertEqual(results[0].scope, GuardScope.LOCAL)
            self.assertEqual(results[0].violations[0].scope, GuardScope.LOCAL)

    def test_normalized_rules_emit_normalized_violation_metadata(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            f = _make_dart_file(root, 'lib/foo.dart', 'else {\n')
            rule = {
                'id': 'no_else',
                'type': 'forbidden_pattern',
                'scope': 'global',
                'category': 'style',
                'patterns': [{'regex': r'\belse\b', 'message': 'No else.'}],
            }
            executor, _ = _executor_with_rules(root, [rule])
            results = executor.run(files=[f])
            violation = results[0].violations[0]
            self.assertEqual(violation.rule_id, 'no_else')
            self.assertEqual(violation.violation_code, 'no_else')
            self.assertEqual(violation.category, 'style')
            self.assertEqual(violation.source, 'normalized')

    def test_catalog_backed_messages_populate_violation_metadata(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            f = _make_dart_file(root, 'lib/foo.dart', 'else {\n')
            paths = _make_paths(root)
            config = {
                'message_catalog': {
                    'no_else.forbidden_else': {
                        'template': 'Use early return in {file_name}.',
                        'suggestion': 'Remove else from {file_name}.',
                        'remediation_id': 'use_early_return',
                        'docs_ref': 'rules/no_else',
                    },
                },
                'remediation_catalog': {
                    'use_early_return': {
                        'title': 'Remove else branch',
                        'summary': 'Replace else with an early return in {file_name}.',
                        'manual_steps': ['Return from the exceptional branch.'],
                    },
                },
                'rules': [
                    {
                        'id': 'no_else',
                        'type': 'forbidden_pattern',
                        'scope': 'global',
                        'patterns': [
                            {
                                'regex': r'\belse\b',
                                'message_code': 'no_else.forbidden_else',
                                'message': 'Use early return.',
                            },
                        ],
                    },
                ],
            }
            executor = RuleExecutor(config=config, paths=paths)
            results = executor.run(files=[f])
            violation = results[0].violations[0]
            self.assertEqual(violation.violation_code, 'no_else.forbidden_else')
            self.assertEqual(violation.message_ref, 'no_else.forbidden_else')
            self.assertEqual(violation.message, 'Use early return in foo.dart.')
            self.assertEqual(violation.suggestion, 'Remove else from foo.dart.')
            self.assertEqual(violation.docs_ref, 'rules/no_else')
            self.assertEqual(violation.remediation['title'], 'Remove else branch')


if __name__ == '__main__':
    unittest.main()
