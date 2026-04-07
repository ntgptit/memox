from __future__ import annotations

from pathlib import Path
import re

from tools.guard.core.base_guard import BaseGuard
from tools.guard.core.guard_result import GuardScope, Severity, Violation


class PerformanceContractGuard(BaseGuard):
    GUARD_ID = 'performance_contract'
    GUARD_NAME = 'Performance contract'
    DESCRIPTION = (
        'Critical routing, provider-scope, and async-transition files must '
        'stay aligned with configured performance contracts.'
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

            for token in case.get('required_tokens', []):
                if token in content:
                    continue

                violations.append(
                    self._violation(
                        file_path,
                        f'`{file_path.name}` thiếu performance token `{token}`.',
                    ),
                )

            for pattern in case.get('required_patterns', []):
                if re.search(pattern, content, re.MULTILINE | re.DOTALL):
                    continue

                violations.append(
                    self._violation(
                        file_path,
                        (
                            f'`{file_path.name}` thiếu performance pattern '
                            f'`{pattern}`.'
                        ),
                    ),
                )

            for token in case.get('forbidden_tokens', []):
                if token not in content:
                    continue

                violations.append(
                    self._violation(
                        file_path,
                        f'`{file_path.name}` chứa forbidden performance token `{token}`.',
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
