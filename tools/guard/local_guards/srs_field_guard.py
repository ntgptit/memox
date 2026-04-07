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
        rules = self.project_rules.get('srs_fields', {})
        target_file = rules.get('target_file', '')
        cards_table = self.paths.root_dir / target_file
        missing_target_message = rules.get(
            'missing_target_message',
            'Không tìm thấy configured cards table file để validate SRS fields.',
        )
        missing_target_message_code = rules.get('missing_target_message_code')
        missing_column_message = rules.get(
            'missing_column_message',
            'Cards table thiếu SRS field `{column}`.',
        )
        missing_column_message_code = rules.get('missing_column_message_code')

        if not cards_table.exists():
            return [
                self.create_violation(
                    file_path=target_file,
                    line_number=1,
                    line_content='',
                    message=missing_target_message,
                    message_code=missing_target_message_code,
                    message_args={
                        'file': target_file,
                        'file_path': target_file,
                        'file_name': Path(target_file).name,
                    },
                    violation_code=missing_target_message_code or self.GUARD_ID,
                ),
            ]

        declared_columns = set(self.COLUMN_PATTERN.findall(cards_table.read_text(encoding='utf-8')))
        required_columns = rules.get('cards_table', {}).get('required_columns', [])
        violations: list[Violation] = []

        for column in required_columns:
            if column in declared_columns:
                continue

            violations.append(
                self.create_violation(
                    file_path=self.paths.relative_path(cards_table),
                    line_number=1,
                    line_content='',
                    message=missing_column_message,
                    message_code=missing_column_message_code,
                    message_args={
                        'column': column,
                        'file': self.paths.relative_path(cards_table),
                        'file_path': self.paths.relative_path(cards_table),
                        'file_name': cards_table.name,
                    },
                    violation_code=missing_column_message_code or self.GUARD_ID,
                    symbol=column,
                ),
            )

        return violations
