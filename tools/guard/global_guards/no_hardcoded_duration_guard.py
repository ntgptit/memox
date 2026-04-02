from __future__ import annotations

import re
from pathlib import Path

from tools.guard.core.base_guard import BaseGuard
from tools.guard.core.guard_result import Severity, Violation


class NoHardcodedDurationGuard(BaseGuard):
    GUARD_ID = 'no_hardcoded_duration'
    GUARD_NAME = 'No hardcoded durations'
    DESCRIPTION = 'Use DurationTokens instead of literal Duration values.'
    DEFAULT_SEVERITY = Severity.ERROR

    PATTERN = re.compile(r'Duration\(\s*(milliseconds|seconds|minutes)\s*:\s*\d+\s*\)')
    WHITELIST = ('lib/core/theme/tokens/duration_tokens.dart', 'test/')

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
                    message='Hardcoded duration. Dùng DurationTokens.*',
                    guard_id=self.GUARD_ID,
                    severity=self.severity,
                ),
            )

        return violations
