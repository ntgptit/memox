from __future__ import annotations

from pathlib import Path

from tools.guard.core.base_guard import BaseGuard
from tools.guard.core.guard_result import GuardScope, Severity, Violation


class TestCoverageGuard(BaseGuard):
    GUARD_ID = 'test_coverage'
    GUARD_NAME = 'Feature test coverage'
    DESCRIPTION = 'Features with usecases/screens must include domain and screen tests.'
    DEFAULT_SEVERITY = Severity.ERROR
    SCOPE = GuardScope.LOCAL

    @property
    def is_file_level(self) -> bool:
        return False

    def check_project(self, all_files: list[Path]) -> list[Violation]:
        rules = self.project_rules.get(self.GUARD_ID, {})
        usecase_glob = rules.get('usecase_file_glob', 'domain/usecases/*.dart')
        usecase_test_glob = rules.get('usecase_test_glob', 'domain/usecases/*_test.dart')
        screen_glob = rules.get('screen_file_glob', 'presentation/screens/*_screen.dart')
        screen_test_glob = rules.get('screen_test_glob', 'presentation/screens/*_test.dart')
        violations: list[Violation] = []

        for feature_dir in self.paths.features_dir.iterdir():
            if not feature_dir.is_dir():
                continue

            feature_name = feature_dir.name
            feature_tests_dir = self.paths.test_root / 'features' / feature_name

            for usecase_file in feature_dir.glob(usecase_glob):
                expected_test = feature_tests_dir / 'domain' / 'usecases' / f'{usecase_file.stem}_test.dart'

                if expected_test.exists():
                    continue

                violations.append(
                    self._violation(
                        self.paths.relative_path(expected_test),
                        f'{feature_name} thiếu unit test cho `{usecase_file.name}`.',
                    ),
                )

            for screen_file in feature_dir.glob(screen_glob):
                expected_test = feature_tests_dir / 'presentation' / 'screens' / f'{screen_file.stem}_test.dart'

                if expected_test.exists():
                    continue

                violations.append(
                    self._violation(
                        self.paths.relative_path(expected_test),
                        f'{feature_name} thiếu widget test cho `{screen_file.name}`.',
                    ),
                )

        return violations

    def _violation(self, file_path: str, message: str) -> Violation:
        return Violation(
            file_path=file_path,
            line_number=1,
            line_content='',
            message=message,
            guard_id=self.GUARD_ID,
            severity=self.severity,
            scope=self.SCOPE,
        )
