from __future__ import annotations

import re
from pathlib import Path

from tools.guard.core.base_guard import BaseGuard
from tools.guard.core.guard_result import Severity, Violation


class WidgetClassLengthGuard(BaseGuard):
    GUARD_ID = 'widget_class_length'
    GUARD_NAME = 'Widget class length'
    DESCRIPTION = 'Keep widget classes short and composable.'
    DEFAULT_SEVERITY = Severity.WARNING

    CLASS_PATTERN = re.compile(
        r'class\s+(\w+)\s+extends\s+'
        r'(?:StatelessWidget|StatefulWidget|ConsumerWidget|ConsumerStatefulWidget)\b',
    )

    def check_file(self, file_path: Path, lines: list[str]) -> list[Violation]:
        relative = self.paths.relative_path(file_path)

        if relative.startswith('test/'):
            return []

        limit = self.config.get('thresholds', {}).get('max_widget_lines', 80)
        violations: list[Violation] = []

        for index, line in enumerate(lines):
            match = self.CLASS_PATTERN.search(line)

            if not match:
                continue

            class_name = match.group(1)
            brace_count = 0
            found_open = False

            for cursor in range(index, len(lines)):
                brace_count += lines[cursor].count('{')
                brace_count -= lines[cursor].count('}')

                if '{' in lines[cursor]:
                    found_open = True

                if not found_open or brace_count != 0:
                    continue

                class_length = cursor - index + 1

                if class_length > limit:
                    violations.append(
                        Violation(
                            file_path=relative,
                            line_number=index + 1,
                            line_content=line,
                            message=(
                                f'Widget class `{class_name}` is {class_length} lines '
                                f'(max {limit}). Tách thành small composable widgets.'
                            ),
                            guard_id=self.GUARD_ID,
                            severity=self.severity,
                        ),
                    )

                break

        return violations
