from __future__ import annotations

from pathlib import Path
import tempfile
import unittest

from tools.guard.core.path_constants import PathConstants
from tools.guard.local_guards.safe_area_keyboard_guard import SafeAreaKeyboardGuard


class SafeAreaKeyboardGuardTest(unittest.TestCase):
    def test_reports_input_screen_without_keyboard_safe_wrapper(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            file_path = root / 'lib/features/cards/presentation/screens/card_create_screen.dart'
            file_path.parent.mkdir(parents=True)
            file_path.write_text(
                'Widget build(BuildContext context) => Column(children: [AppTextField()]);',
                encoding='utf-8',
            )
            guard = self._create_guard(root)

            violations = guard.check_file(
                file_path,
                file_path.read_text(encoding='utf-8').splitlines(),
            )

            self.assertEqual(1, len(violations))
            self.assertIn('keyboard-safe wrapper', violations[0].message)

    def test_allows_input_view_with_scroll_container(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            file_path = root / 'lib/features/cards/presentation/widgets/card_editor_view.dart'
            file_path.parent.mkdir(parents=True)
            file_path.write_text(
                'Widget build(BuildContext context) => ListView(children: [AppTextField()]);',
                encoding='utf-8',
            )
            guard = self._create_guard(root)

            violations = guard.check_file(
                file_path,
                file_path.read_text(encoding='utf-8').splitlines(),
            )

            self.assertEqual([], violations)

    def test_allows_input_dialog_with_app_dialog(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            file_path = root / 'lib/features/decks/presentation/widgets/create_deck_dialog.dart'
            file_path.parent.mkdir(parents=True)
            file_path.write_text(
                'Widget build(BuildContext context) => AppDialog(content: AppTextField());',
                encoding='utf-8',
            )
            guard = self._create_guard(root)

            violations = guard.check_file(
                file_path,
                file_path.read_text(encoding='utf-8').splitlines(),
            )

            self.assertEqual([], violations)

    def test_skips_non_container_input_widget(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            file_path = root / 'lib/features/study/presentation/widgets/fill_answer_input.dart'
            file_path.parent.mkdir(parents=True)
            file_path.write_text(
                'Widget build(BuildContext context) => AppTextField();',
                encoding='utf-8',
            )
            guard = self._create_guard(root)

            violations = guard.check_file(
                file_path,
                file_path.read_text(encoding='utf-8').splitlines(),
            )

            self.assertEqual([], violations)

    def _create_guard(self, root: Path) -> SafeAreaKeyboardGuard:
        config = {
            'source_root': 'lib',
            'test_root': 'test',
            'paths': {
                'core_dir': 'lib/core',
                'shared_dir': 'lib/shared',
                'features_dir': 'lib/features',
                'exclude_patterns': [],
            },
            'local_guards': {'safe_area_keyboard': True},
        }
        rules = {
            'safe_area_keyboard': {
                'path_patterns': [
                    'features/*/presentation/screens/*_screen.dart',
                    'features/*/presentation/widgets/*_dialog.dart',
                    'features/*/presentation/widgets/*_view.dart',
                    'shared/widgets/dialogs/*_dialog.dart',
                ],
                'input_tokens': ['AppTextField(', 'TextField('],
                'keyboard_safe_tokens': [
                    'AppScaffold(',
                    'AppDialog(',
                    'SliverScaffold(',
                    'SingleChildScrollView(',
                    'ListView(',
                    'CustomScrollView(',
                ],
            },
        }
        paths = PathConstants.from_config(root, config)
        return SafeAreaKeyboardGuard(
            config=config,
            path_constants=paths,
            project_rules=rules,
        )


if __name__ == '__main__':
    unittest.main()
