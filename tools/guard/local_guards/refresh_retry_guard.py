from __future__ import annotations

from pathlib import Path, PurePosixPath

from tools.guard.core.base_guard import BaseGuard
from tools.guard.core.guard_result import GuardScope, Severity, Violation


class RefreshRetryGuard(BaseGuard):
    GUARD_ID = 'refresh_retry'
    GUARD_NAME = 'Refresh and retry wiring'
    DESCRIPTION = 'List/content views must wire pull-to-refresh and AppAsyncBuilder retry callbacks.'
    DEFAULT_SEVERITY = Severity.ERROR
    SCOPE = GuardScope.LOCAL

    def check_file(self, file_path: Path, lines: list[str]) -> list[Violation]:
        relative = self.paths.relative_path(file_path)

        if relative.startswith('test/'):
            return []

        content = '\n'.join(lines)
        violations: list[Violation] = []

        if self._matches_pattern(file_path, 'retry_path_patterns'):
            if 'AppAsyncBuilder<' in content and 'onRetry:' not in content:
                violations.append(
                    Violation(
                        file_path=relative,
                        line_number=1,
                        line_content='',
                        message='AppAsyncBuilder call site phải truyền onRetry để Retry hoạt động.',
                        guard_id=self.GUARD_ID,
                        severity=self.severity,
                        scope=self.SCOPE,
                    ),
                )

        if self._matches_pattern(file_path, 'refresh_path_patterns'):
            refresh_tokens = self.project_rules.get(self.GUARD_ID, {}).get(
                'refresh_tokens',
                [],
            )

            if not any(token in content for token in refresh_tokens):
                violations.append(
                    Violation(
                        file_path=relative,
                        line_number=1,
                        line_content='',
                        message='List/content view phải dùng AppRefreshIndicator hoặc AppRefreshScrollView để hỗ trợ pull-to-refresh.',
                        guard_id=self.GUARD_ID,
                        severity=self.severity,
                        scope=self.SCOPE,
                    ),
                )

        return violations

    def _matches_pattern(self, file_path: Path, key: str) -> bool:
        patterns = self.project_rules.get(self.GUARD_ID, {}).get(key, [])
        source_relative = PurePosixPath(self.paths.source_relative_path(file_path))
        return any(source_relative.match(pattern) for pattern in patterns)
