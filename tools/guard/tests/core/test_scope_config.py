from __future__ import annotations

import tempfile
import unittest
from pathlib import Path

from tools.guard.core.path_constants import PathConstants, ScopeDefinition


def _make_paths(root: Path, config: dict) -> PathConstants:
    return PathConstants.from_config(root, config)


def _minimal_config(**extra) -> dict:
    base = {
        'source_root': 'lib',
        'test_root': 'test',
        'paths': {
            'core_dir': 'lib/core',
            'shared_dir': 'lib/shared',
            'features_dir': 'lib/features',
            'exclude_patterns': [],
        },
    }
    base.update(extra)
    return base


class ScopeDefinitionParsingTest(unittest.TestCase):
    """PathConstants.from_config correctly builds ScopeDefinition objects."""

    def test_explicit_scan_targets_parsed(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            config = _minimal_config(
                language_extensions=['.dart'],
                scan_targets={
                    'all':   {'roots': ['lib', 'test']},
                    'core':  {'roots': ['lib/core']},
                },
            )
            paths = _make_paths(root, config)

            self.assertIn('all', paths.scope_definitions)
            self.assertIn('core', paths.scope_definitions)
            self.assertEqual(paths.scope_definitions['all'].roots, ('lib', 'test'))
            self.assertEqual(paths.scope_definitions['core'].roots, ('lib/core',))

    def test_scope_inherits_language_extensions(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            config = _minimal_config(
                language_extensions=['.dart', '.yaml'],
                scan_targets={'all': {'roots': ['lib', 'test']}},
            )
            paths = _make_paths(root, config)

            self.assertEqual(paths.scope_definitions['all'].extensions, ('.dart', '.yaml'))

    def test_scope_overrides_extensions(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            config = _minimal_config(
                language_extensions=['.dart'],
                scan_targets={
                    'all': {'roots': ['lib'], 'extensions': ['.dart', '.arb']},
                },
            )
            paths = _make_paths(root, config)

            self.assertEqual(paths.scope_definitions['all'].extensions, ('.dart', '.arb'))

    def test_scope_include_patterns_parsed(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            config = _minimal_config(
                scan_targets={
                    'presentation': {
                        'roots': ['lib/features'],
                        'include': ['**/presentation/**/*.dart'],
                    },
                },
            )
            paths = _make_paths(root, config)

            self.assertEqual(
                paths.scope_definitions['presentation'].include_patterns,
                ('**/presentation/**/*.dart',),
            )

    def test_scope_exclude_patterns_parsed(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            config = _minimal_config(
                scan_targets={
                    'src': {
                        'roots': ['lib'],
                        'exclude': ['**/generated/**'],
                    },
                },
            )
            paths = _make_paths(root, config)

            self.assertEqual(
                paths.scope_definitions['src'].exclude_patterns,
                ('**/generated/**',),
            )

    def test_default_extensions_falls_back_to_dart(self) -> None:
        """No language_extensions in config → default is ('.dart',)."""
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            config = _minimal_config(
                scan_targets={'all': {'roots': ['lib', 'test']}},
            )
            paths = _make_paths(root, config)

            self.assertEqual(paths.default_extensions, ('.dart',))
            self.assertEqual(paths.scope_extensions('all'), ('.dart',))


class BackwardCompatFallbackTest(unittest.TestCase):
    """When scan_targets is absent the five legacy scopes are synthesised from paths.*."""

    def test_legacy_five_scopes_created(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            config = _minimal_config()
            paths = _make_paths(root, config)

            for scope_id in ('all', 'core', 'shared', 'features', 'test'):
                self.assertIn(scope_id, paths.scope_definitions, msg=scope_id)

    def test_legacy_all_scope_contains_lib_and_test(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            config = _minimal_config()
            paths = _make_paths(root, config)

            all_roots = set(paths.scope_definitions['all'].roots)
            self.assertIn('lib', all_roots)
            self.assertIn('test', all_roots)

    def test_legacy_core_scope_root(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            config = _minimal_config()
            paths = _make_paths(root, config)

            self.assertEqual(paths.scope_definitions['core'].roots, ('lib/core',))

    def test_custom_paths_reflected_in_fallback(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            config = {
                'source_root': 'src',
                'test_root': 'tests',
                'paths': {
                    'core_dir': 'src/core',
                    'shared_dir': 'src/shared',
                    'features_dir': 'src/features',
                    'exclude_patterns': [],
                },
            }
            paths = _make_paths(root, config)

            self.assertIn('src', paths.scope_definitions['all'].roots)
            self.assertIn('tests', paths.scope_definitions['all'].roots)
            self.assertEqual(paths.scope_definitions['core'].roots, ('src/core',))


class ScopeRootsTest(unittest.TestCase):
    """scope_roots() returns the correct absolute Path objects."""

    def test_known_scope_returns_absolute_paths(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            config = _minimal_config(
                scan_targets={
                    'core': {'roots': ['lib/core']},
                },
            )
            paths = _make_paths(root, config)

            roots = paths.scope_roots('core')
            self.assertEqual(roots, [root / 'lib/core'])

    def test_unknown_scope_falls_back_to_relative_path(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            config = _minimal_config(scan_targets={'all': {'roots': ['lib']}})
            paths = _make_paths(root, config)

            roots = paths.scope_roots('my/custom/path')
            self.assertEqual(roots, [root / 'my/custom/path'])

    def test_multi_root_scope(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            config = _minimal_config(
                scan_targets={'all': {'roots': ['lib', 'test']}},
            )
            paths = _make_paths(root, config)

            roots = paths.scope_roots('all')
            self.assertEqual(roots, [root / 'lib', root / 'test'])


class ScopeExtensionsTest(unittest.TestCase):
    """scope_extensions() returns the right extension tuple."""

    def test_returns_scope_specific_extensions(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            config = _minimal_config(
                language_extensions=['.dart'],
                scan_targets={
                    'arb': {'roots': ['lib/l10n'], 'extensions': ['.arb']},
                },
            )
            paths = _make_paths(root, config)

            self.assertEqual(paths.scope_extensions('arb'), ('.arb',))

    def test_unknown_scope_uses_default_extensions(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            config = _minimal_config(language_extensions=['.dart'])
            paths = _make_paths(root, config)

            self.assertEqual(paths.scope_extensions('nonexistent'), ('.dart',))


class PathIsWithinScopeTest(unittest.TestCase):
    """path_is_within_scope() correctly filters paths against scope roots."""

    def _paths_with_targets(self, root: Path) -> PathConstants:
        config = _minimal_config(
            scan_targets={
                'all':      {'roots': ['lib', 'test']},
                'core':     {'roots': ['lib/core']},
                'features': {'roots': ['lib/features']},
                'test':     {'roots': ['test']},
            },
        )
        return _make_paths(root, config)

    def test_path_within_scope(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            paths = self._paths_with_targets(root)

            self.assertTrue(paths.path_is_within_scope('lib/core', 'core'))
            self.assertTrue(paths.path_is_within_scope('lib/core/theme', 'core'))
            self.assertTrue(paths.path_is_within_scope('lib/features/cards', 'features'))

    def test_path_outside_scope_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            paths = self._paths_with_targets(root)

            self.assertFalse(paths.path_is_within_scope('lib/core', 'features'))
            self.assertFalse(paths.path_is_within_scope('lib/core', 'test'))
            self.assertFalse(paths.path_is_within_scope('test/helpers', 'core'))

    def test_all_scope_contains_lib_and_test_paths(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            paths = self._paths_with_targets(root)

            self.assertTrue(paths.path_is_within_scope('lib/core', 'all'))
            self.assertTrue(paths.path_is_within_scope('lib/features', 'all'))
            self.assertTrue(paths.path_is_within_scope('test/features', 'all'))

    def test_exact_root_match(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            paths = self._paths_with_targets(root)

            # A path equal to the root itself is considered within scope
            self.assertTrue(paths.path_is_within_scope('lib/features', 'features'))

    def test_partial_prefix_not_matched(self) -> None:
        """lib/features_extra must NOT match a scope whose root is lib/features."""
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            paths = self._paths_with_targets(root)

            self.assertFalse(paths.path_is_within_scope('lib/features_extra', 'features'))


class ValidationTest(unittest.TestCase):
    """_validate_scope raises ValueError for malformed scope entries."""

    def _build(self, scan_targets: dict) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            config = _minimal_config(scan_targets=scan_targets)
            PathConstants.from_config(Path(tmp), config)

    def test_roots_not_a_list(self) -> None:
        with self.assertRaises(ValueError, msg='roots must be a list'):
            self._build({'bad': {'roots': 'lib/core'}})

    def test_roots_empty_list(self) -> None:
        with self.assertRaises(ValueError, msg='roots must be non-empty'):
            self._build({'bad': {'roots': []}})

    def test_root_entry_not_a_string(self) -> None:
        with self.assertRaises(ValueError, msg='root entry must be string'):
            self._build({'bad': {'roots': [42]}})

    def test_extension_not_starting_with_dot(self) -> None:
        with self.assertRaises(ValueError, msg='extension must start with dot'):
            self._build({'bad': {'roots': ['lib'], 'extensions': ['dart']}})

    def test_extensions_not_a_list(self) -> None:
        with self.assertRaises(ValueError, msg='extensions must be a list'):
            self._build({'bad': {'roots': ['lib'], 'extensions': '.dart'}})

    def test_include_not_a_list(self) -> None:
        with self.assertRaises(ValueError, msg='include must be a list'):
            self._build({'bad': {'roots': ['lib'], 'include': '**/*.dart'}})

    def test_exclude_not_a_list(self) -> None:
        with self.assertRaises(ValueError, msg='exclude must be a list'):
            self._build({'bad': {'roots': ['lib'], 'exclude': '**/*.g.dart'}})

    def test_scope_not_a_mapping(self) -> None:
        with self.assertRaises(ValueError, msg='scope value must be a mapping'):
            self._build({'bad': 'lib/core'})

    def test_valid_scope_does_not_raise(self) -> None:
        self._build({
            'custom': {
                'roots': ['lib/custom'],
                'extensions': ['.dart', '.yaml'],
                'include': ['**/screens/**'],
                'exclude': ['**/*.g.dart'],
            },
        })


if __name__ == '__main__':
    unittest.main()
