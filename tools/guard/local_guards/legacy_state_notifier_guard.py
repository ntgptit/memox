from __future__ import annotations

from pathlib import Path

from tools.guard.core.base_guard import BaseGuard
from tools.guard.core.guard_result import GuardScope, Severity, Violation


class LegacyStateNotifierGuard(BaseGuard):
    GUARD_ID = 'legacy_state_notifier'
    GUARD_NAME = 'Legacy StateNotifier'
    DESCRIPTION = 'Do not use StateNotifier or StateNotifierProvider in Riverpod 3 code.'
    DEFAULT_SEVERITY = Severity.ERROR
    SCOPE = GuardScope.LOCAL

    def check_file(self, file_path: Path, lines: list[str]) -> list[Violation]:
        relative = self.paths.relative_path(file_path)

        if relative.startswith('test/'):
            return []

        if relative.endswith('.g.dart') or relative.endswith('.freezed.dart'):
            return []

        forbidden_patterns = self.project_rules.get(self.GUARD_ID, {}).get('forbidden_patterns', [])
        violations: list[Violation] = []

        for index, line in enumerate(lines, start=1):
            stripped = line.strip()

            if stripped.startswith('//') or stripped.startswith('///'):
                continue

            if not any(pattern in line for pattern in forbidden_patterns):
                continue

            violations.append(
                Violation(
                    file_path=relative,
                    line_number=index,
                    line_content=line,
                    message='Legacy StateNotifier syntax detected. Dùng @riverpod/@Riverpod của Riverpod 3.',
                    guard_id=self.GUARD_ID,
                    severity=self.severity,
                    scope=self.SCOPE,
                ),
            )

        return violations
