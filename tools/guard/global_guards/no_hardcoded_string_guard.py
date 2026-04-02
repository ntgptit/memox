from __future__ import annotations

import re
from pathlib import Path

from tools.guard.core.base_guard import BaseGuard
from tools.guard.core.guard_result import Severity, Violation


class NoHardcodedStringGuard(BaseGuard):
    GUARD_ID = 'no_hardcoded_string'
    GUARD_NAME = 'No hardcoded UI strings'
    DESCRIPTION = 'Avoid hardcoded strings in app bars, dialogs, labels, hints, and tooltips.'
    DEFAULT_SEVERITY = Severity.ERROR

    PATTERNS = (
        re.compile(r'title\s*:\s*Text\(\s*[\'"]'),
        re.compile(r'label\s*:\s*(?:Text\()?\s*[\'"]'),
        re.compile(r'hintText\s*:\s*[\'"]'),
        re.compile(r'tooltip\s*:\s*[\'"]'),
        re.compile(r'content\s*:\s*Text\(\s*[\'"]'),
    )
    WHITELIST = ('test/', 'lib/core/constants/', 'l10n/')

    def check_file(self, file_path: Path, lines: list[str]) -> list[Violation]:
        relative = self.paths.relative_path(file_path)

        if any(item in relative for item in self.WHITELIST):
            return []

        violations: list[Violation] = []

        for index, line in enumerate(lines, start=1):
            stripped = line.strip()

            if stripped.startswith('//') or stripped.startswith('///'):
                continue

            if not any(pattern.search(line) for pattern in self.PATTERNS):
                continue

            violations.append(
                Violation(
                    file_path=relative,
                    line_number=index,
                    line_content=line,
                    message='Hardcoded UI string detected. Dùng context.l10n.*',
                    guard_id=self.GUARD_ID,
                    severity=self.severity,
                ),
            )

        return violations
