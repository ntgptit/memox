from __future__ import annotations

import re
from pathlib import Path

from tools.guard.core.base_guard import BaseGuard
from tools.guard.core.guard_result import GuardScope, Severity, Violation


class SrsFieldGuard(BaseGuard):
    GUARD_ID = 'srs_field'
    GUARD_NAME = 'SRS field coverage'
    DESCRIPTION = 'Cards table must contain required spaced-repetition fields.'
    DEFAULT_SEVERITY = Severity.ERROR
    SCOPE = GuardScope.LOCAL

    COLUMN_PATTERN = re.compile(
        r'\b(?:Int|Text|Real|DateTime|Bool|Blob)Column\s+get\s+(\w+)',
    )

    @property
    def is_file_level(self) -> bool:
        return False

    def check_project(self, all_files: list[Path]) -> list[Violation]:
        cards_table = self.paths.root_dir / 'lib/core/database/tables/cards_table.dart'

        if not cards_table.exists():
            return [
                Violation(
                    file_path='lib/core/database/tables/cards_table.dart',
                    line_number=1,
                    line_content='',
                    message='Không tìm thấy cards_table.dart để validate SRS fields.',
                    guard_id=self.GUARD_ID,
                    severity=self.severity,
                    scope=self.SCOPE,
                ),
            ]

        declared_columns = set(self.COLUMN_PATTERN.findall(cards_table.read_text(encoding='utf-8')))
        required_columns = (
            self.project_rules.get('srs_fields', {})
            .get('cards_table', {})
            .get('required_columns', [])
        )
        violations: list[Violation] = []

        for column in required_columns:
            if column in declared_columns:
                continue

            violations.append(
                Violation(
                    file_path=self.paths.relative_path(cards_table),
                    line_number=1,
                    line_content='',
                    message=f'Cards table thiếu SRS field `{column}`.',
                    guard_id=self.GUARD_ID,
                    severity=self.severity,
                    scope=self.SCOPE,
                ),
            )

        return violations
