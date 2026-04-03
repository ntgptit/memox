from __future__ import annotations

from pathlib import Path

from tools.guard.core.base_guard import BaseGuard
from tools.guard.core.guard_result import GuardScope, Severity, Violation


class ResponsiveTextScaleGuard(BaseGuard):
    GUARD_ID = 'responsive_text_scale'
    GUARD_NAME = 'Responsive text scaling enforcement'
    DESCRIPTION = (
        'App root and widget test harness must apply '
        'ScreenType.of(context).textScaleFactor via MediaQuery textScaler.'
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
            file_path = self.paths.root_dir / case.get('file', '')

            if not file_path.exists():
                violations.append(
                    self._violation(
                        file_path,
                        f'File bắt buộc `{case.get("file", "")}` đang bị thiếu.',
                    ),
                )
                continue

            content = file_path.read_text(encoding='utf-8')
            required_tokens = case.get('required_tokens', [])
            missing_tokens = [
                token for token in required_tokens if token not in content
            ]

            if not missing_tokens:
                continue

            missing_summary = ', '.join(f'`{token}`' for token in missing_tokens)
            violations.append(
                self._violation(
                    file_path,
                    (
                        f'`{file_path.name}` phải áp responsive text scaling qua '
                        'MediaQuery textScaler. Thiếu '
                        f'{missing_summary}.'
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
