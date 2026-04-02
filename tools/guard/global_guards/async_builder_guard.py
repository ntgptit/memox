from __future__ import annotations

import re
from pathlib import Path

from tools.guard.core.base_guard import BaseGuard
from tools.guard.core.guard_result import Severity, Violation


class AsyncBuilderGuard(BaseGuard):
    GUARD_ID = 'async_builder'
    GUARD_NAME = 'Async builder enforcement'
    DESCRIPTION = 'Prefer AppAsyncBuilder over raw AsyncValue.when calls.'
    DEFAULT_SEVERITY = Severity.ERROR

    PATTERN = re.compile(r'\.when\s*\(')
    WHITELIST = ('lib/shared/widgets/feedback/app_async_builder.dart', 'test/')

    def check_file(self, file_path: Path, lines: list[str]) -> list[Violation]:
        relative = self.paths.relative_path(file_path)

        if any(item in relative for item in self.WHITELIST):
            return []

        violations: list[Violation] = []

        for index, line in enumerate(lines, start=1):
            if not self.PATTERN.search(line):
                continue

            violations.append(
                Violation(
                    file_path=relative,
                    line_number=index,
                    line_content=line,
                    message='Raw .when() detected. Dùng AppAsyncBuilder widget.',
                    guard_id=self.GUARD_ID,
                    severity=self.severity,
                ),
            )

        return violations
