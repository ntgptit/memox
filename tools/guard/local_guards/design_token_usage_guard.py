from __future__ import annotations

import re
from pathlib import Path

from tools.guard.core.base_guard import BaseGuard
from tools.guard.core.guard_result import GuardScope, Severity, Violation


class DesignTokenUsageGuard(BaseGuard):
    GUARD_ID = 'design_token_usage'
    GUARD_NAME = 'Design token mapping'
    DESCRIPTION = 'Design token classes must live in the expected files.'
    DEFAULT_SEVERITY = Severity.ERROR
    SCOPE = GuardScope.LOCAL

    CLASS_PATTERN = re.compile(r'\b(?:class|abstract\s+final\s+class|abstract\s+class)\s+(\w+)')

    @property
    def is_file_level(self) -> bool:
        return False

    def check_project(self, all_files: list[Path]) -> list[Violation]:
        mappings = self.project_rules.get('design_tokens', {})
        violations: list[Violation] = []
        definitions: dict[str, list[str]] = {}

        for file_path in self.paths.core_dir.rglob('*.dart'):
            if self.paths.is_excluded(file_path):
                continue

            relative = self.paths.relative_path(file_path)

            for match in self.CLASS_PATTERN.finditer(file_path.read_text(encoding='utf-8')):
                definitions.setdefault(match.group(1), []).append(relative)

        for class_name, expected_file in mappings.items():
            target = self.paths.root_dir / expected_file

            if not target.exists():
                violations.append(
                    self._violation(expected_file, f'Missing token file for {class_name}: {expected_file}'),
                )
                continue

            contents = target.read_text(encoding='utf-8')

            if re.search(rf'\b{class_name}\b', contents):
                pass
            if not re.search(rf'\b(?:class|abstract\s+final\s+class|abstract\s+class)\s+{class_name}\b', contents):
                violations.append(
                    self._violation(
                        expected_file,
                        f'{class_name} phải được định nghĩa trong {expected_file}',
                    ),
                )

            for actual_file in definitions.get(class_name, []):
                if actual_file == expected_file:
                    continue

                violations.append(
                    self._violation(
                        actual_file,
                        f'{class_name} xuất hiện sai file. Expected: {expected_file}',
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
