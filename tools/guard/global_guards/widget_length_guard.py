from __future__ import annotations

import re
from pathlib import Path

from tools.guard.core.base_guard import BaseGuard
from tools.guard.core.guard_result import Severity, Violation


class WidgetLengthGuard(BaseGuard):
    GUARD_ID = 'widget_length'
    GUARD_NAME = 'Widget build length'
    DESCRIPTION = 'Keep widget build methods short and composable.'
    DEFAULT_SEVERITY = Severity.WARNING

    BUILD_START = re.compile(r'Widget\s+build\s*\(')

    def check_file(self, file_path: Path, lines: list[str]) -> list[Violation]:
        limit = self.config.get('thresholds', {}).get('max_widget_lines', 80)
        violations: list[Violation] = []
        index = 0

        while index < len(lines):
            if not self.BUILD_START.search(lines[index]):
                index += 1
                continue

            start = index
            brace_count = 0
            found_open = False

            for cursor in range(index, len(lines)):
                brace_count += lines[cursor].count('{')
                brace_count -= lines[cursor].count('}')

                if '{' in lines[cursor]:
                    found_open = True

                if not found_open:
                    continue

                if brace_count > 0:
                    continue

                build_length = cursor - start + 1

                if build_length > limit:
                    violations.append(
                        Violation(
                            file_path=self.paths.relative_path(file_path),
                            line_number=start + 1,
                            line_content=lines[start],
                            message=f'build() is {build_length} lines (max {limit}). Tách thành composable widgets.',
                            guard_id=self.GUARD_ID,
                            severity=self.severity,
                        ),
                    )

                index = cursor + 1
                break

            if index == start:
                index += 1

        return violations
