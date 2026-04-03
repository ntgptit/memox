from __future__ import annotations

import re
from pathlib import Path

from tools.guard.core.base_guard import BaseGuard
from tools.guard.core.guard_result import Severity, Violation


class NoHardcodedRadiusGuard(BaseGuard):
    GUARD_ID = 'no_hardcoded_radius'
    GUARD_NAME = 'No hardcoded radius'
    DESCRIPTION = 'Use RadiusTokens instead of BorderRadius.circular literals.'
    DEFAULT_SEVERITY = Severity.ERROR

    PATTERN = re.compile(r'BorderRadius\.(?:all|circular)\(\s*[^)]*\d')
    WRONG_TOKEN_PATTERN = re.compile(
        r'BorderRadius\.(?:all|circular)\(\s*[^)]*(?:SpacingTokens|SizeTokens|DurationTokens|OpacityTokens|ColorTokens)\.',
    )
    WHITELIST = ('lib/core/theme/tokens/radius_tokens.dart', 'test/')

    def check_file(self, file_path: Path, lines: list[str]) -> list[Violation]:
        relative = self.paths.relative_path(file_path)

        if any(item in relative for item in self.WHITELIST):
            return []

        violations: list[Violation] = []

        for index, line in enumerate(lines, start=1):
            stripped = line.strip()

            if stripped.startswith('//') or stripped.startswith('///'):
                continue

            if not self.PATTERN.search(line) and not self.WRONG_TOKEN_PATTERN.search(line):
                continue

            violations.append(
                Violation(
                    file_path=relative,
                    line_number=index,
                    line_content=line,
                    message='Radius phải dùng BorderRadius.circular(RadiusTokens.*)',
                    guard_id=self.GUARD_ID,
                    severity=self.severity,
                ),
            )

        return violations
