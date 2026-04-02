from __future__ import annotations

import re
from pathlib import Path

from tools.guard.core.base_guard import BaseGuard
from tools.guard.core.guard_result import Severity, Violation


class NoHardcodedFontSizeGuard(BaseGuard):
    GUARD_ID = 'no_hardcoded_font_size'
    GUARD_NAME = 'No hardcoded font size'
    DESCRIPTION = 'Use typography tokens or text themes instead of literal font sizes.'
    DEFAULT_SEVERITY = Severity.ERROR

    PATTERN = re.compile(r'fontSize\s*:\s*\d+(?:\.\d+)?')
    WHITELIST = ('lib/core/theme/tokens/typography_tokens.dart', 'test/')

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
                    message='Hardcoded fontSize detected. Dùng context.textTheme hoặc TypographyTokens.*',
                    guard_id=self.GUARD_ID,
                    severity=self.severity,
                ),
            )

        return violations
