from __future__ import annotations

import re
from pathlib import Path

from tools.guard.core.base_guard import BaseGuard
from tools.guard.core.guard_result import GuardScope, Severity, Violation


class TextStyleGuard(BaseGuard):
    GUARD_ID = 'text_style'
    GUARD_NAME = 'Text style usage'
    DESCRIPTION = 'Use theme text styles instead of raw TextStyle constructors in UI files.'
    DEFAULT_SEVERITY = Severity.ERROR
    SCOPE = GuardScope.LOCAL

    def check_file(self, file_path: Path, lines: list[str]) -> list[Violation]:
        relative = self.paths.relative_path(file_path)
        rules = self.project_rules.get(self.GUARD_ID, {})
        whitelist_dirs = tuple(rules.get('whitelist_dirs', []))

        if any(item in relative for item in whitelist_dirs):
            return []

        if relative.endswith('.g.dart') or relative.endswith('.freezed.dart'):
            return []

        patterns = [
            re.compile(pattern)
            for pattern in rules.get('forbidden_patterns', [])
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
                    message='Raw TextStyle detected. Dùng context.textTheme.* hoặc context.appTextStyles.*',
                    guard_id=self.GUARD_ID,
                    severity=self.severity,
                    scope=self.SCOPE,
                ),
            )

        return violations
