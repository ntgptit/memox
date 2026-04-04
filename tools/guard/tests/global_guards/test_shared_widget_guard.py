from __future__ import annotations

from pathlib import Path
import tempfile
import unittest

from tools.guard.core.path_constants import PathConstants
from tools.guard.global_guards.shared_widget_guard import SharedWidgetGuard


class SharedWidgetGuardTest(unittest.TestCase):
    def test_reports_raw_text_field_outside_shared_widgets(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            file_path = root / 'lib/features/settings/presentation/widgets/sample.dart'
            file_path.parent.mkdir(parents=True)
            file_path.write_text('final field = TextField();', encoding='utf-8')
            guard = self._create_guard(root)

            violations = guard.check_file(
                file_path,
                file_path.read_text(encoding='utf-8').splitlines(),
            )

            self.assertEqual(1, len(violations))
            self.assertIn('AppTextField', violations[0].message)

    def test_reports_raw_list_tile_outside_shared_widgets(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            file_path = root / 'lib/features/settings/presentation/widgets/sample.dart'
            file_path.parent.mkdir(parents=True)
            file_path.write_text('return ListTile(title: Text("x"));', encoding='utf-8')
            guard = self._create_guard(root)

            violations = guard.check_file(
                file_path,
                file_path.read_text(encoding='utf-8').splitlines(),
            )

            self.assertEqual(1, len(violations))
            self.assertIn('AppListTile', violations[0].message)

    def test_reports_raw_popup_menu_outside_shared_widgets(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            file_path = root / 'lib/features/decks/presentation/widgets/sample.dart'
            file_path.parent.mkdir(parents=True)
            file_path.write_text(
                'return PopupMenuButton<int>(itemBuilder: (_) => []);',
                encoding='utf-8',
            )
            guard = self._create_guard(root)

            violations = guard.check_file(
                file_path,
                file_path.read_text(encoding='utf-8').splitlines(),
            )

            self.assertEqual(1, len(violations))
            self.assertIn('AppEditDeleteMenu', violations[0].message)

    def test_reports_raw_ink_well_outside_shared_widgets(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            file_path = root / 'lib/features/study/presentation/widgets/sample.dart'
            file_path.parent.mkdir(parents=True)
            file_path.write_text('return InkWell(onTap: () {});', encoding='utf-8')
            guard = self._create_guard(root)

            violations = guard.check_file(
                file_path,
                file_path.read_text(encoding='utf-8').splitlines(),
            )

            self.assertEqual(1, len(violations))
            self.assertIn('AppPressable', violations[0].message)

    def test_reports_raw_gesture_detector_outside_shared_widgets(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            file_path = root / 'lib/features/statistics/presentation/widgets/sample.dart'
            file_path.parent.mkdir(parents=True)
            file_path.write_text(
                'return GestureDetector(onTap: () {});',
                encoding='utf-8',
            )
            guard = self._create_guard(root)

            violations = guard.check_file(
                file_path,
                file_path.read_text(encoding='utf-8').splitlines(),
            )

            self.assertEqual(1, len(violations))
            self.assertIn('AppTapRegion', violations[0].message)

    def test_skips_shared_widget_implementations(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            file_path = root / 'lib/shared/widgets/inputs/app_text_field.dart'
            file_path.parent.mkdir(parents=True)
            file_path.write_text('final field = TextField();', encoding='utf-8')
            guard = self._create_guard(root)

            violations = guard.check_file(
                file_path,
                file_path.read_text(encoding='utf-8').splitlines(),
            )

            self.assertEqual([], violations)

    def _create_guard(self, root: Path) -> SharedWidgetGuard:
        config = {
            'source_root': 'lib',
            'test_root': 'test',
            'paths': {
                'core_dir': 'lib/core',
                'shared_dir': 'lib/shared',
                'features_dir': 'lib/features',
                'exclude_patterns': [],
            },
            'global_guards': {'shared_widget': True},
        }
        paths = PathConstants.from_config(root, config)
        return SharedWidgetGuard(config=config, path_constants=paths)


if __name__ == '__main__':
    unittest.main()
