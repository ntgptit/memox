from __future__ import annotations

from pathlib import Path
import tempfile
import unittest

from tools.guard.core.path_constants import PathConstants
from tools.guard.local_guards.refresh_retry_guard import RefreshRetryGuard


class RefreshRetryGuardTest(unittest.TestCase):
    def test_reports_missing_on_retry_for_async_builder_callsite(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            file_path = root / 'lib/features/search/presentation/screens/search_screen.dart'
            file_path.parent.mkdir(parents=True)
            file_path.write_text(
                'Widget build(BuildContext context) => AppAsyncBuilder<int>(value: value, onData: (_) => Text("x"));',
                encoding='utf-8',
            )
            guard = self._create_guard(root)

            violations = guard.check_file(
                file_path,
                file_path.read_text(encoding='utf-8').splitlines(),
            )

            self.assertEqual(1, len(violations))
            self.assertIn('onRetry', violations[0].message)

    def test_reports_missing_refresh_for_configured_list_view(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            file_path = root / 'lib/features/folders/presentation/screens/home_screen.dart'
            file_path.parent.mkdir(parents=True)
            file_path.write_text(
                'Widget build(BuildContext context) => AppScaffold(body: Text("x"));',
                encoding='utf-8',
            )
            guard = self._create_guard(root)

            violations = guard.check_file(
                file_path,
                file_path.read_text(encoding='utf-8').splitlines(),
            )

            self.assertEqual(1, len(violations))
            self.assertIn('pull-to-refresh', violations[0].message)

    def test_allows_wired_retry_and_refresh(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            file_path = root / 'lib/features/folders/presentation/screens/home_screen.dart'
            file_path.parent.mkdir(parents=True)
            file_path.write_text(
                '''
Widget build(BuildContext context) => AppRefreshIndicator(
  onRefresh: refresh,
  child: AppAsyncBuilder<int>(
    value: value,
    onRetry: retry,
    onData: (_) => Text("x"),
  ),
);
''',
                encoding='utf-8',
            )
            guard = self._create_guard(root)

            violations = guard.check_file(
                file_path,
                file_path.read_text(encoding='utf-8').splitlines(),
            )

            self.assertEqual([], violations)

    def _create_guard(self, root: Path) -> RefreshRetryGuard:
        config = {
            'source_root': 'lib',
            'test_root': 'test',
            'paths': {
                'core_dir': 'lib/core',
                'shared_dir': 'lib/shared',
                'features_dir': 'lib/features',
                'exclude_patterns': [],
            },
            'local_guards': {'refresh_retry': True},
        }
        rules = {
            'refresh_retry': {
                'retry_path_patterns': [
                    'features/*/presentation/screens/*_screen.dart',
                    'features/*/presentation/widgets/*_view.dart',
                    'features/*/presentation/widgets/*_card.dart',
                ],
                'refresh_path_patterns': [
                    'features/folders/presentation/screens/home_screen.dart',
                ],
                'refresh_tokens': [
                    'AppRefreshIndicator(',
                    'AppRefreshScrollView(',
                    'onRefresh:',
                ],
            },
        }
        paths = PathConstants.from_config(root, config)
        return RefreshRetryGuard(
            config=config,
            path_constants=paths,
            project_rules=rules,
        )


if __name__ == '__main__':
    unittest.main()
