from __future__ import annotations

import re
from pathlib import Path

from tools.guard.core.base_guard import BaseGuard
from tools.guard.core.guard_result import Severity, Violation


class NoElseGuard(BaseGuard):
    GUARD_ID = 'no_else'
    GUARD_NAME = 'No else'
    DESCRIPTION = 'Use early return, guard clause, or switch expression instead of else.'
    DEFAULT_SEVERITY = Severity.ERROR

    PATTERN = re.compile(r'\belse\b')

    def check_file(self, file_path: Path, lines: list[str]) -> list[Violation]:
        violations: list[Violation] = []

        for index, line in enumerate(lines, start=1):
            stripped = line.strip()

            if stripped.startswith('//') or stripped.startswith('///'):
                continue

            if '"else"' in line or "'else'" in line:
                continue

            if not self.PATTERN.search(line):
                continue

            violations.append(
                Violation(
                    file_path=self.paths.relative_path(file_path),
                    line_number=index,
                    line_content=line,
                    message='Dùng early return, guard clause, hoặc switch expression thay vì else.',
                    guard_id=self.GUARD_ID,
                    severity=self.severity,
                ),
            )

        return violations
