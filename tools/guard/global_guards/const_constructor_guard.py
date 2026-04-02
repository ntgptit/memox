from __future__ import annotations

import re
from pathlib import Path

from tools.guard.core.base_guard import BaseGuard
from tools.guard.core.guard_result import Severity, Violation


class ConstConstructorGuard(BaseGuard):
    GUARD_ID = 'const_constructor'
    GUARD_NAME = 'Const constructors'
    DESCRIPTION = 'Widgets should expose const constructors when possible.'
    DEFAULT_SEVERITY = Severity.WARNING

    CLASS_PATTERN = re.compile(r'class\s+(\w+)\s+extends\s+(StatelessWidget|StatefulWidget)\b')

    def check_file(self, file_path: Path, lines: list[str]) -> list[Violation]:
        violations: list[Violation] = []
        relative = self.paths.relative_path(file_path)

        for index, line in enumerate(lines):
            match = self.CLASS_PATTERN.search(line)

            if not match:
                continue

            class_name = match.group(1)
            constructor_pattern = re.compile(rf'^\s*(const\s+)?{class_name}\s*\(')
            explicit_constructor_found = False

            for cursor in range(index + 1, min(index + 25, len(lines))):
                constructor_match = constructor_pattern.search(lines[cursor])

                if not constructor_match:
                    continue

                explicit_constructor_found = True

                if constructor_match.group(1):
                    break

                violations.append(
                    Violation(
                        file_path=relative,
                        line_number=cursor + 1,
                        line_content=lines[cursor],
                        message=f'{class_name} thiếu const constructor.',
                        guard_id=self.GUARD_ID,
                        severity=self.severity,
                    ),
                )
                break

            if explicit_constructor_found:
                continue

        return violations
