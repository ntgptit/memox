from __future__ import annotations

import re
from pathlib import Path

from tools.guard.core.base_guard import BaseGuard
from tools.guard.core.guard_result import Severity, Violation


class NamingConventionGuard(BaseGuard):
    GUARD_ID = 'naming_convention'
    GUARD_NAME = 'File naming convention'
    DESCRIPTION = 'Dart files should use snake_case names.'
    DEFAULT_SEVERITY = Severity.WARNING

    PATTERN = re.compile(r'^[a-z0-9_]+\.dart$')

    def check_file(self, file_path: Path, lines: list[str]) -> list[Violation]:
        name = file_path.name

        if self.PATTERN.match(name):
            return []

        return [
            Violation(
                file_path=self.paths.relative_path(file_path),
                line_number=1,
                line_content=name,
                message='Tên file phải theo snake_case.',
                guard_id=self.GUARD_ID,
                severity=self.severity,
            ),
        ]
