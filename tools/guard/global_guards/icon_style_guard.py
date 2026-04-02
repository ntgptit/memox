from __future__ import annotations

import re
from pathlib import Path

from tools.guard.core.base_guard import BaseGuard
from tools.guard.core.guard_result import Severity, Violation


class IconStyleGuard(BaseGuard):
    GUARD_ID = 'icon_style'
    GUARD_NAME = 'Outlined icon preference'
    DESCRIPTION = 'Prefer outlined icons for consistency.'
    DEFAULT_SEVERITY = Severity.WARNING

    PATTERN = re.compile(r'Icons\.(\w+)')
    EXCEPTIONS = {
        'close',
        'add',
        'check',
        'remove',
        'arrow_back',
        'arrow_forward',
        'chevron_right',
        'drag_handle',
        'expand_more',
        'more_vert',
        'more_horiz',
    }

    def check_file(self, file_path: Path, lines: list[str]) -> list[Violation]:
        relative = self.paths.relative_path(file_path)

        if relative.startswith('test/'):
            return []

        violations: list[Violation] = []

        for index, line in enumerate(lines, start=1):
            stripped = line.strip()

            if stripped.startswith('//') or stripped.startswith('///'):
                continue

            if 'selectedIcon:' in line:
                continue

            for match in self.PATTERN.finditer(line):
                icon_name = match.group(1)

                if icon_name.endswith('_outlined'):
                    continue

                if icon_name.endswith('_outline'):
                    continue

                if icon_name in self.EXCEPTIONS:
                    continue

                violations.append(
                    Violation(
                        file_path=relative,
                        line_number=index,
                        line_content=line,
                        message=f'Icons.{icon_name} → dùng Icons.{icon_name}_outlined nếu có.',
                        guard_id=self.GUARD_ID,
                        severity=self.severity,
                    ),
                )
                break

        return violations
