from __future__ import annotations

from pathlib import Path
import tempfile
import unittest

from tools.guard.core.path_constants import PathConstants
from tools.guard.local_guards.riverpod_syntax_guard import RiverpodSyntaxGuard


class RiverpodSyntaxGuardTest(unittest.TestCase):
    def test_reports_legacy_provider_constructor(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            file_path = root / 'lib/shared/providers/theme_mode_provider.dart'
            file_path.parent.mkdir(parents=True)
            file_path.write_text(
                "import 'package:flutter/material.dart';\n"
                "import 'package:flutter_riverpod/flutter_riverpod.dart';\n"
                "final Provider<ThemeMode> themeModeProvider = Provider<ThemeMode>((ref) => ThemeMode.system);\n",
                encoding='utf-8',
            )
            guard = self._create_guard(root)

            violations = guard.check_file(
                file_path,
                file_path.read_text(encoding='utf-8').splitlines(),
            )

            messages = [violation.message for violation in violations]
            self.assertIn(
                'Legacy Riverpod provider syntax detected. Dùng @riverpod/@Riverpod + build_runner.',
                messages,
            )
            self.assertIn(
                'Provider declaration file không dùng flutter_riverpod import. Dùng riverpod_annotation + generated provider.',
                messages,
            )

    def test_reports_missing_keep_alive_for_infrastructure_provider(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            file_path = root / 'lib/core/providers/database_providers.dart'
            file_path.parent.mkdir(parents=True)
            file_path.write_text(
                "import 'package:riverpod_annotation/riverpod_annotation.dart';\n"
                "part 'database_providers.g.dart';\n"
                "@riverpod\n"
                "String database(Ref ref) => 'db';\n",
                encoding='utf-8',
            )
            guard = self._create_guard(root)

            violations = guard.check_file(
                file_path,
                file_path.read_text(encoding='utf-8').splitlines(),
            )

            messages = [violation.message for violation in violations]
            self.assertIn(
                'Infrastructure provider phải dùng @Riverpod(keepAlive: true).',
                messages,
            )

    def test_accepts_annotation_based_riverpod_provider(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            file_path = root / 'lib/features/folders/presentation/providers/folders_provider.dart'
            file_path.parent.mkdir(parents=True)
            file_path.write_text(
                "import 'package:riverpod_annotation/riverpod_annotation.dart';\n"
                "part 'folders_provider.g.dart';\n"
                "@riverpod\n"
                "String foldersTitle(Ref ref) => 'Folders';\n",
                encoding='utf-8',
            )
            guard = self._create_guard(root)

            violations = guard.check_file(
                file_path,
                file_path.read_text(encoding='utf-8').splitlines(),
            )

            self.assertEqual([], violations)

    def test_ignores_non_provider_router_helper(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            file_path = root / 'lib/core/router/app_page_transition.dart'
            file_path.parent.mkdir(parents=True)
            file_path.write_text(
                "import 'package:flutter/material.dart';\n"
                "Widget buildPage() => const SizedBox.shrink();\n",
                encoding='utf-8',
            )
            guard = self._create_guard(root)

            violations = guard.check_file(
                file_path,
                file_path.read_text(encoding='utf-8').splitlines(),
            )

            self.assertEqual([], violations)

    def _create_guard(self, root: Path) -> RiverpodSyntaxGuard:
        config = {
            'source_root': 'lib',
            'test_root': 'test',
            'paths': {
                'core_dir': 'lib/core',
                'shared_dir': 'lib/shared',
                'features_dir': 'lib/features',
                'exclude_patterns': [],
            },
            'local_guards': {'riverpod_syntax': True},
        }
        rules = {
            'riverpod_syntax': {
                'provider_file_patterns': [
                    'core/providers/*.dart',
                    'core/router/app_router.dart',
                    'shared/providers/*.dart',
                    'features/*/presentation/providers/*.dart',
                ],
                'infrastructure_provider_files': [
                    'core/providers/database_providers.dart',
                ],
                'forbidden_legacy_providers': [
                    'Provider',
                    'StateProvider',
                ],
            },
        }
        paths = PathConstants.from_config(root, config)
        return RiverpodSyntaxGuard(
            config=config,
            path_constants=paths,
            project_rules=rules,
        )


if __name__ == '__main__':
    unittest.main()
