from __future__ import annotations

import re
from pathlib import Path

from tools.guard.core.base_guard import BaseGuard
from tools.guard.core.guard_result import Severity, Violation


class ImportDirectionGuard(BaseGuard):
    GUARD_ID = 'import_direction'
    GUARD_NAME = 'Import direction'
    DESCRIPTION = 'Presentation cannot import data. Domain cannot import data or presentation.'
    DEFAULT_SEVERITY = Severity.ERROR

    IMPORT_PATTERN = re.compile(r"import\s+'package:[^']+/features/\w+/(data|domain|presentation)/")

    def check_file(self, file_path: Path, lines: list[str]) -> list[Violation]:
        relative = self.paths.relative_path(file_path)

        if relative.startswith('test/'):
            return []

        current_layer = self.paths.get_layer(file_path)

        if not current_layer:
            return []

        violations: list[Violation] = []

        for index, line in enumerate(lines, start=1):
            match = self.IMPORT_PATTERN.search(line)

            if not match:
                continue

            imported_layer = match.group(1)

            if current_layer == 'domain' and imported_layer in {'data', 'presentation'}:
                violations.append(
                    Violation(
                        file_path=relative,
                        line_number=index,
                        line_content=line,
                        message=f'{current_layer}/ không được import {imported_layer}/. Vi phạm Dependency Inversion.',
                        guard_id=self.GUARD_ID,
                        severity=self.severity,
                    ),
                )
                continue

            if current_layer != 'presentation' or imported_layer != 'data':
                continue

            violations.append(
                Violation(
                    file_path=relative,
                    line_number=index,
                    line_content=line,
                    message=f'{current_layer}/ không được import {imported_layer}/. Vi phạm Dependency Inversion.',
                    guard_id=self.GUARD_ID,
                    severity=self.severity,
                ),
            )

        return violations
