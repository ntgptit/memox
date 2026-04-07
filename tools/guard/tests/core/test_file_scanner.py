from __future__ import annotations

from pathlib import Path
import tempfile
import unittest

from tools.guard.core.file_scanner import FileScanner
from tools.guard.core.path_constants import PathConstants


def _make_scanner(root: Path, config: dict) -> tuple[FileScanner, PathConstants]:
    paths = PathConstants.from_config(root, config)
    return FileScanner(paths), paths


def _legacy_config(root: Path) -> dict:
    """Minimal config without scan_targets; exercises the backward-compat path."""
    return {
        'source_root': 'lib',
        'test_root': 'test',
        'paths': {
            'core_dir': 'lib/core',
            'shared_dir': 'lib/shared',
            'features_dir': 'lib/features',
            'exclude_patterns': ['**/*.g.dart'],
        },
    }


class FileScannerExclusionTest(unittest.TestCase):
    def test_scan_excludes_generated_files(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            (root / 'lib').mkdir()
            (root / 'test').mkdir()
            (root / 'lib' / 'feature.dart').write_text('class Feature {}', encoding='utf-8')
            (root / 'lib' / 'feature.g.dart').write_text('// generated', encoding='utf-8')
            (root / 'test' / 'feature_test.dart').write_text('void main() {}', encoding='utf-8')

            scanner, paths = _make_scanner(root, _legacy_config(root))
            results = [paths.relative_path(f) for f in scanner.scan()]

            self.assertIn('lib/feature.dart', results)
            self.assertIn('test/feature_test.dart', results)
            self.assertNotIn('lib/feature.g.dart', results)


class FileScannerExtensionTest(unittest.TestCase):
    def test_scope_extensions_from_config(self) -> None:
        """Files with unexpected extension are excluded when scope defines extensions."""
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            (root / 'lib').mkdir()
            (root / 'lib' / 'widget.dart').write_text('', encoding='utf-8')
            (root / 'lib' / 'translations.arb').write_text('{}', encoding='utf-8')

            config = {
                'source_root': 'lib',
                'test_root': 'test',
                'language_extensions': ['.dart'],
                'paths': {'exclude_patterns': []},
                'scan_targets': {
                    'all': {'roots': ['lib', 'test']},
                },
            }
            scanner, paths = _make_scanner(root, config)
            results = [paths.relative_path(f) for f in scanner.scan(scope='all')]

            self.assertIn('lib/widget.dart', results)
            self.assertNotIn('lib/translations.arb', results)

    def test_scope_specific_extension_override(self) -> None:
        """A scope can declare its own extensions, overriding the project default."""
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            (root / 'lib' / 'l10n').mkdir(parents=True)
            (root / 'lib' / 'l10n' / 'app_en.arb').write_text('{}', encoding='utf-8')
            (root / 'lib' / 'l10n' / 'widget.dart').write_text('', encoding='utf-8')

            config = {
                'source_root': 'lib',
                'test_root': 'test',
                'language_extensions': ['.dart'],
                'paths': {'exclude_patterns': []},
                'scan_targets': {
                    'l10n': {'roots': ['lib/l10n'], 'extensions': ['.arb']},
                },
            }
            scanner, paths = _make_scanner(root, config)
            results = [paths.relative_path(f) for f in scanner.scan(scope='l10n')]

            self.assertIn('lib/l10n/app_en.arb', results)
            self.assertNotIn('lib/l10n/widget.dart', results)

    def test_explicit_extensions_param_overrides_scope(self) -> None:
        """Passing extensions= explicitly still works (backward compatibility)."""
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            (root / 'lib').mkdir()
            (root / 'lib' / 'widget.dart').write_text('', encoding='utf-8')
            (root / 'lib' / 'data.yaml').write_text('', encoding='utf-8')

            config = {
                'source_root': 'lib',
                'test_root': 'test',
                'language_extensions': ['.dart'],
                'paths': {'exclude_patterns': []},
                'scan_targets': {'all': {'roots': ['lib']}},
            }
            scanner, paths = _make_scanner(root, config)
            results = [paths.relative_path(f) for f in scanner.scan(extensions=('.yaml',))]

            self.assertNotIn('lib/widget.dart', results)
            self.assertIn('lib/data.yaml', results)


class FileScannerIncludePatternTest(unittest.TestCase):
    def test_include_pattern_filters_files(self) -> None:
        """Only files matching the include pattern are returned."""
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            (root / 'lib' / 'features' / 'cards' / 'presentation' / 'screens').mkdir(parents=True)
            (root / 'lib' / 'features' / 'cards' / 'domain').mkdir(parents=True)
            screen = root / 'lib/features/cards/presentation/screens/card_screen.dart'
            domain = root / 'lib/features/cards/domain/card_entity.dart'
            screen.write_text('', encoding='utf-8')
            domain.write_text('', encoding='utf-8')

            config = {
                'source_root': 'lib',
                'test_root': 'test',
                'language_extensions': ['.dart'],
                'paths': {'exclude_patterns': []},
                'scan_targets': {
                    'screens': {
                        'roots': ['lib/features'],
                        'include': ['**/screens/*.dart'],
                    },
                },
            }
            scanner, paths = _make_scanner(root, config)
            results = [paths.relative_path(f) for f in scanner.scan(scope='screens')]

            self.assertIn('lib/features/cards/presentation/screens/card_screen.dart', results)
            self.assertNotIn('lib/features/cards/domain/card_entity.dart', results)


class FileScannerScopeExcludePatternTest(unittest.TestCase):
    def test_scope_exclude_applied_in_addition_to_global(self) -> None:
        """Scope-specific exclude patterns reject files that global excludes would keep."""
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            (root / 'lib' / 'features' / 'cards' / 'data').mkdir(parents=True)
            (root / 'lib' / 'features' / 'cards' / 'domain').mkdir(parents=True)
            data_file = root / 'lib/features/cards/data/card_dao.dart'
            domain_file = root / 'lib/features/cards/domain/card_entity.dart'
            data_file.write_text('', encoding='utf-8')
            domain_file.write_text('', encoding='utf-8')

            config = {
                'source_root': 'lib',
                'test_root': 'test',
                'language_extensions': ['.dart'],
                'paths': {'exclude_patterns': []},
                'scan_targets': {
                    'domain_only': {
                        'roots': ['lib/features'],
                        'exclude': ['**/data/**'],
                    },
                },
            }
            scanner, paths = _make_scanner(root, config)
            results = [paths.relative_path(f) for f in scanner.scan(scope='domain_only')]

            self.assertIn('lib/features/cards/domain/card_entity.dart', results)
            self.assertNotIn('lib/features/cards/data/card_dao.dart', results)


class FileScannerScopeRootTest(unittest.TestCase):
    def test_scan_restricted_to_scope_root(self) -> None:
        """Files outside the scope root are not returned."""
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            (root / 'lib' / 'core').mkdir(parents=True)
            (root / 'lib' / 'features').mkdir(parents=True)
            core_file = root / 'lib/core/core.dart'
            feat_file = root / 'lib/features/feat.dart'
            core_file.write_text('', encoding='utf-8')
            feat_file.write_text('', encoding='utf-8')

            config = {
                'source_root': 'lib',
                'test_root': 'test',
                'language_extensions': ['.dart'],
                'paths': {'exclude_patterns': []},
                'scan_targets': {
                    'core': {'roots': ['lib/core']},
                },
            }
            scanner, paths = _make_scanner(root, config)
            results = [paths.relative_path(f) for f in scanner.scan(scope='core')]

            self.assertIn('lib/core/core.dart', results)
            self.assertNotIn('lib/features/feat.dart', results)


if __name__ == '__main__':
    unittest.main()
