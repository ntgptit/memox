from __future__ import annotations

import re
from pathlib import Path

from tools.guard.core.base_guard import BaseGuard
from tools.guard.core.guard_result import GuardScope, Severity, Violation


class ButtonUsageGuard(BaseGuard):
    GUARD_ID = 'button_usage'
    GUARD_NAME = 'Button usage'
    DESCRIPTION = 'Use PrimaryButton/SecondaryButton instead of raw Material button constructors.'
    DEFAULT_SEVERITY = Severity.ERROR
    SCOPE = GuardScope.LOCAL

    def check_file(self, file_path: Path, lines: list[str]) -> list[Violation]:
        relative = self.paths.relative_path(file_path)
        rules = self.project_rules.get(self.GUARD_ID, {})
        whitelist_dirs = tuple(rules.get('whitelist_dirs', []))

        if any(item in relative for item in whitelist_dirs):
            return []

        patterns = [
            re.compile(rf'\b{re.escape(button)}(?:\.\w+)?\(')
            for button in rules.get('forbidden_buttons', [])
        ]
        violations: list[Violation] = []

        for index, line in enumerate(lines, start=1):
            stripped = line.strip()

            if stripped.startswith('//') or stripped.startswith('///'):
                continue

            if not any(pattern.search(line) for pattern in patterns):
                continue

            violations.append(
                Violation(
                    file_path=relative,
                    line_number=index,
                    line_content=line,
                    message='Raw Material button detected. Dùng PrimaryButton/SecondaryButton.',
                    guard_id=self.GUARD_ID,
                    severity=self.severity,
                    scope=self.SCOPE,
                ),
            )

        return violations
