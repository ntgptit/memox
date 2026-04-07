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

    def check_file(self, file_path: Path, lines: list[str]) -> list[Violation]:
        relative = self.paths.relative_path(file_path)
        rules = self.project_rules.get(self.GUARD_ID, {})
        excluded_paths = tuple(rules.get('excluded_paths', []))

        if any(item in relative for item in excluded_paths):
            return []

        allowed_non_outlined = set(rules.get('allowed_non_outlined', []))
        skip_lines_containing = tuple(rules.get('skip_lines_containing', []))
        message_template = rules.get(
            'message_template',
            'Icons.{icon_name} should use Icons.{icon_name}_outlined when available.',
        )
        message_code = rules.get('message_code')
        violations: list[Violation] = []

        for index, line in enumerate(lines, start=1):
            stripped = line.strip()

            if stripped.startswith('//') or stripped.startswith('///'):
                continue

            if any(token in line for token in skip_lines_containing):
                continue

            for match in self.PATTERN.finditer(line):
                icon_name = match.group(1)

                if icon_name.endswith('_outlined'):
                    continue

                if icon_name.endswith('_outline'):
                    continue

                if icon_name in allowed_non_outlined:
                    continue

                violations.append(
                    self.create_violation(
                        file_path=relative,
                        line_number=index,
                        line_content=line,
                        message=message_template,
                        message_code=message_code,
                        message_args={
                            'icon_name': icon_name,
                            'file': relative,
                            'file_path': relative,
                            'file_name': file_path.name,
                            'line_number': index,
                        },
                        violation_code=message_code or self.GUARD_ID,
                        symbol=icon_name,
                    ),
                )
                break

        return violations
