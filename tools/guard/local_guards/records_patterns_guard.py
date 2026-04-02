from __future__ import annotations

import re
from pathlib import Path

from tools.guard.core.base_guard import BaseGuard
from tools.guard.core.guard_result import GuardScope, Severity, Violation


class RecordsPatternsGuard(BaseGuard):
    GUARD_ID = 'records_patterns'
    GUARD_NAME = 'Dart records and patterns'
    DESCRIPTION = 'Prefer Dart 3 records and patterns over older pair-like or cast-heavy syntax.'
    DEFAULT_SEVERITY = Severity.WARNING
    SCOPE = GuardScope.LOCAL

    TYPE_CHECK_PATTERN = re.compile(r'if\s*\(\s*([\w.]+)\s+is\s+(\w+)\s*\)')

    def check_file(self, file_path: Path, lines: list[str]) -> list[Violation]:
        relative = self.paths.relative_path(file_path)

        if relative.startswith('test/'):
            return []

        if relative.endswith('.g.dart') or relative.endswith('.freezed.dart'):
            return []

        violations = self._collect_pair_like_violations(relative, lines)
        violations.extend(self._collect_type_pattern_violations(relative, lines))
        return violations

    def _collect_pair_like_violations(self, relative: str, lines: list[str]) -> list[Violation]:
        pair_like_patterns = self.project_rules.get(self.GUARD_ID, {}).get('pair_like_patterns', [])
        violations: list[Violation] = []

        for index, line in enumerate(lines, start=1):
            stripped = line.strip()

            if stripped.startswith('//') or stripped.startswith('///'):
                continue

            if 'runtimeType' in line:
                violations.append(
                    self._violation(
                        relative,
                        index,
                        line,
                        'Dùng pattern matching hoặc sealed switch thay vì runtimeType checks.',
                    ),
                )
                continue

            if not any(pattern in line for pattern in pair_like_patterns):
                continue

            violations.append(
                self._violation(
                    relative,
                    index,
                    line,
                    'Dùng Dart records thay vì pair/tuple helper types.',
                ),
            )

        return violations

    def _collect_type_pattern_violations(self, relative: str, lines: list[str]) -> list[Violation]:
        window = self.project_rules.get(self.GUARD_ID, {}).get('cast_window', 5)
        violations: list[Violation] = []

        for index, line in enumerate(lines):
            match = self.TYPE_CHECK_PATTERN.search(line)

            if not match:
                continue

            expression = re.escape(match.group(1))
            type_name = re.escape(match.group(2))
            cast_pattern = re.compile(
                rf'(?:final\s+\w+\s*=|[\w<>?]+\s+\w+\s*=)\s*{expression}\s+as\s+{type_name}\b',
            )

            for cursor in range(index + 1, min(index + window + 1, len(lines))):
                if not cast_pattern.search(lines[cursor]):
                    continue

                violations.append(
                    self._violation(
                        relative,
                        index + 1,
                        line,
                        'Có thể dùng type pattern để bỏ cặp `is` + `as` thủ công.',
                    ),
                )
                break

        return violations

    def _violation(
        self,
        relative: str,
        line_number: int,
        line_content: str,
        message: str,
    ) -> Violation:
        return Violation(
            file_path=relative,
            line_number=line_number,
            line_content=line_content,
            message=message,
            guard_id=self.GUARD_ID,
            severity=self.severity,
            scope=self.SCOPE,
        )
