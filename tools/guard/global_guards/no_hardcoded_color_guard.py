from __future__ import annotations

import re
from pathlib import Path

from tools.guard.core.base_guard import BaseGuard
from tools.guard.core.guard_result import Severity, Violation


class NoHardcodedColorGuard(BaseGuard):
    GUARD_ID = 'no_hardcoded_color'
    GUARD_NAME = 'No hardcoded colors'
    DESCRIPTION = 'Use context.colors or token classes instead of hardcoded colors.'
    DEFAULT_SEVERITY = Severity.ERROR

    PATTERNS = (
        re.compile(r'Color\(\s*0x[0-9A-Fa-f]+\s*\)'),
        re.compile(r'\bColors\.\w+'),
        re.compile(r'Color\.fromRGBO\('),
        re.compile(r'Color\.fromARGB\('),
        re.compile(r'\.withValues\(\s*alpha:\s*(0\.\d+|1\.0*)\s*\)'),
        re.compile(r'\.withOpacity\(\s*(0\.\d+|1\.0*)\s*\)'),
    )
    WHITELIST = (
        'lib/core/theme/tokens/color_tokens.dart',
        'lib/core/theme/color_schemes/custom_colors.dart',
        'lib/core/theme/color_schemes/app_color_scheme.dart',
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
                    message='Hardcoded color/opacity detected. Dùng context.colors.*, context.customColors.* hoặc OpacityTokens.*',
                    guard_id=self.GUARD_ID,
                    severity=self.severity,
                ),
            )

        return violations
