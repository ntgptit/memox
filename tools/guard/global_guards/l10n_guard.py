from __future__ import annotations

import re
from pathlib import Path

from tools.guard.core.base_guard import BaseGuard
from tools.guard.core.guard_result import Severity, Violation


class L10nGuard(BaseGuard):
    GUARD_ID = 'l10n'
    GUARD_NAME = 'L10n usage'
    DESCRIPTION = 'User-facing strings should come from localization.'
    DEFAULT_SEVERITY = Severity.WARNING

    PATTERN = re.compile(r'Text\(\s*[\'"]')
    WHITELIST = ('test/', 'lib/core/constants/')

    def check_file(self, file_path: Path, lines: list[str]) -> list[Violation]:
        relative = self.paths.relative_path(file_path)

        if any(item in relative for item in self.WHITELIST):
            return []

        violations: list[Violation] = []

        for index, line in enumerate(lines, start=1):
            stripped = line.strip()

            if stripped.startswith('//') or stripped.startswith('///'):
                continue

            if not self.PATTERN.search(line):
                continue

            violations.append(
                Violation(
                    file_path=relative,
                    line_number=index,
                    line_content=line,
                    message='Hardcoded string trong Text(). Dùng context.l10n.*',
                    guard_id=self.GUARD_ID,
                    severity=self.severity,
                ),
            )

        return violations
