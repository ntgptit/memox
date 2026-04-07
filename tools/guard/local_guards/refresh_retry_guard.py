from __future__ import annotations

from pathlib import Path, PurePosixPath

from tools.guard.core.base_guard import BaseGuard
from tools.guard.core.guard_result import GuardScope, Severity, Violation


class RefreshRetryGuard(BaseGuard):
    GUARD_ID = 'refresh_retry'
    GUARD_NAME = 'Refresh and retry wiring'
    DESCRIPTION = 'List/content views must wire pull-to-refresh and configured retry callbacks.'
    DEFAULT_SEVERITY = Severity.ERROR
    SCOPE = GuardScope.LOCAL

    def check_file(self, file_path: Path, lines: list[str]) -> list[Violation]:
        relative = self.paths.relative_path(file_path)

        if relative.startswith('test/'):
            return []

        content = '\n'.join(lines)
        rules = self.project_rules.get(self.GUARD_ID, {})
        violations: list[Violation] = []

        if self._matches_pattern(file_path, 'retry_path_patterns'):
            retry_tokens = rules.get('retry_tokens', [])
            retry_callback_tokens = rules.get('retry_callback_tokens', [])

            if (
                any(token in content for token in retry_tokens)
                and not any(token in content for token in retry_callback_tokens)
            ):
                violations.append(
                    Violation(
                        file_path=relative,
                        line_number=1,
                        line_content='',
                        message=rules.get(
                            'missing_retry_message',
                            'Configured retry-capable async builder must provide a retry callback.',
                        ),
                        guard_id=self.GUARD_ID,
                        severity=self.severity,
                        scope=self.SCOPE,
                    ),
                )

        if self._matches_pattern(file_path, 'refresh_path_patterns'):
            refresh_tokens = rules.get('refresh_tokens', [])

            if not any(token in content for token in refresh_tokens):
                violations.append(
                    Violation(
                        file_path=relative,
                        line_number=1,
                        line_content='',
                        message=rules.get(
                            'missing_refresh_message',
                            'List/content view must use a configured pull-to-refresh wrapper.',
                        ),
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
