from __future__ import annotations

import re
from pathlib import Path

from tools.guard.core.base_guard import BaseGuard
from tools.guard.core.guard_result import GuardScope, Severity, Violation


class DriftTableGuard(BaseGuard):
    GUARD_ID = 'drift_table'
    GUARD_NAME = 'Drift table columns'
    DESCRIPTION = 'Drift tables must declare required configured columns.'
    DEFAULT_SEVERITY = Severity.ERROR
    SCOPE = GuardScope.LOCAL

    COLUMN_PATTERN = re.compile(
        r'\b(?:Int|Text|Real|DateTime|Bool|Blob)Column\s+get\s+(\w+)',
    )

    @property
    def is_file_level(self) -> bool:
        return False

    def check_project(self, all_files: list[Path]) -> list[Violation]:
        table_rules = self.project_rules.get('drift_tables', {})
        tables_dir = Path(table_rules.get('tables_dir', ''))
        violations: list[Violation] = []

        for table_name, rule in table_rules.items():
            if table_name == 'tables_dir':
                continue

            relative_path = (tables_dir / f'{table_name}.dart').as_posix()
            file_path = self.paths.root_dir / relative_path

            if not file_path.exists():
                violations.append(
                    self._violation(
                        relative_path,
                        f'Missing drift table file for {table_name}.',
                    ),
                )
                continue

            contents = file_path.read_text(encoding='utf-8')
            declared_columns = set(self.COLUMN_PATTERN.findall(contents))

            for column in rule.get('required_columns', []):
                if column in declared_columns:
                    continue

                violations.append(
                    self._violation(
                        self.paths.relative_path(file_path),
                        f'{table_name} thiếu required column `{column}`.',
                    ),
                )

        return violations

    def _violation(self, file_path: str, message: str) -> Violation:
        return Violation(
            file_path=file_path,
            line_number=1,
            line_content='',
            message=message,
            guard_id=self.GUARD_ID,
            severity=self.severity,
            scope=self.SCOPE,
        )
