from __future__ import annotations

import re
from pathlib import Path

from tools.guard.core.base_guard import BaseGuard
from tools.guard.core.guard_result import Severity, Violation


class NoHardcodedSizeGuard(BaseGuard):
    GUARD_ID = 'no_hardcoded_size'
    GUARD_NAME = 'No hardcoded sizes'
    DESCRIPTION = 'Use SizeTokens or SpacingTokens instead of numeric widget sizes.'
    DEFAULT_SEVERITY = Severity.ERROR

    PATTERNS = (
        re.compile(r'SizedBox\([^)]*(height|width)\s*:\s*\d'),
        re.compile(r'\b(size|width|height)\s*:\s*\d+(?:\.\d+)?\b'),
        re.compile(r'EdgeInsets\.(?:all|symmetric|only)\([^)]*\d'),
    )
    WHITELIST = (
        'lib/core/theme/tokens/size_tokens.dart',
        'lib/core/theme/tokens/spacing_tokens.dart',
        'test/',
    )

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
                    message='Hardcoded size detected. Dùng SizeTokens.* hoặc SpacingTokens.*',
                    guard_id=self.GUARD_ID,
                    severity=self.severity,
                ),
            )

        return violations
