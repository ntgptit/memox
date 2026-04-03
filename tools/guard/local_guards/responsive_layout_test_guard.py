from __future__ import annotations

from pathlib import Path

from tools.guard.core.base_guard import BaseGuard
from tools.guard.core.guard_result import GuardScope, Severity, Violation


class ResponsiveLayoutTestGuard(BaseGuard):
    GUARD_ID = 'responsive_layout_test'
    GUARD_NAME = 'Responsive layout regression coverage'
    DESCRIPTION = (
        'Screens with custom responsive headers must have compact viewport '
        'widget tests that assert no Flutter exception is thrown.'
    )
    DEFAULT_SEVERITY = Severity.ERROR
    SCOPE = GuardScope.LOCAL

    @property
    def is_file_level(self) -> bool:
        return False

    def check_project(self, all_files: list[Path]) -> list[Violation]:
        cases = self.project_rules.get(self.GUARD_ID, {}).get('cases', [])
        violations: list[Violation] = []

        for case in cases:
            screen_path = self.paths.source_root / case.get('screen', '')

            if not screen_path.exists():
                continue

            test_path = self.paths.test_root / case.get('test', '')

            if not test_path.exists():
                violations.append(
                    self._violation(
                        test_path,
                        (
                            f'`{screen_path.name}` phải có responsive widget test '
                            'để khóa layout ở compact viewport.'
                        ),
                    ),
                )
                continue

            content = test_path.read_text(encoding='utf-8')
            required_tokens = case.get('required_tokens', [])
            missing_tokens = [
                token for token in required_tokens if token not in content
            ]

            if not missing_tokens:
                continue

            missing_summary = ', '.join(f'`{token}`' for token in missing_tokens)
            violations.append(
                self._violation(
                    test_path,
                    (
                        f'`{test_path.name}` phải chứa {missing_summary} để '
                        f'bắt regression layout của `{screen_path.name}`.'
                    ),
                ),
            )

        return violations

    def _violation(self, file_path: Path, message: str) -> Violation:
        return Violation(
            file_path=self.paths.relative_path(file_path),
            line_number=1,
            line_content='',
            message=message,
            guard_id=self.GUARD_ID,
            severity=self.severity,
            scope=self.SCOPE,
        )
