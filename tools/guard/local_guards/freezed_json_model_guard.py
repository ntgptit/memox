from __future__ import annotations

import re
from pathlib import Path, PurePosixPath

from tools.guard.core.base_guard import BaseGuard
from tools.guard.core.guard_result import GuardScope, Severity, Violation


class FreezedJsonModelGuard(BaseGuard):
    GUARD_ID = 'freezed_json_model'
    GUARD_NAME = 'Freezed JSON models'
    DESCRIPTION = 'Model files must use freezed with json_serializable support.'
    DEFAULT_SEVERITY = Severity.ERROR
    SCOPE = GuardScope.LOCAL

    FREEZED_IMPORT = "package:freezed_annotation/freezed_annotation.dart"
    ANNOTATION_PATTERN = re.compile(r'@(?:freezed|Freezed)')
    FROM_JSON_PATTERN = re.compile(
        r'factory\s+\w+\.fromJson\s*\(\s*Map<String,\s*dynamic>\s+json\s*\)',
    )
    RECORD_TYPEDEF_PATTERN = re.compile(r'^\s*typedef\s+\w+\s*=\s*\(\{', re.MULTILINE)

    def check_file(self, file_path: Path, lines: list[str]) -> list[Violation]:
        if not self._is_model_file(file_path):
            return []

        relative = self.paths.relative_path(file_path)
        content = '\n'.join(lines)

        if self._is_record_typedef(content):
            return []

        violations: list[Violation] = []

        if self.FREEZED_IMPORT not in content:
            violations.append(
                self._violation(
                    relative,
                    1,
                    '',
                    'Model file phải import freezed_annotation.',
                ),
            )

        if not self.ANNOTATION_PATTERN.search(content):
            violations.append(
                self._violation(
                    relative,
                    1,
                    '',
                    'Model file phải dùng @freezed hoặc @Freezed.',
                ),
            )

        expected_freezed_part = f"part '{file_path.stem}.freezed.dart';"
        expected_json_part = f"part '{file_path.stem}.g.dart';"

        if expected_freezed_part not in content:
            violations.append(
                self._violation(
                    relative,
                    1,
                    '',
                    f"Model file phải có `{expected_freezed_part}`.",
                ),
            )

        if expected_json_part not in content:
            violations.append(
                self._violation(
                    relative,
                    1,
                    '',
                    f"Model file phải có `{expected_json_part}`.",
                ),
            )

        if not self.FROM_JSON_PATTERN.search(content):
            violations.append(
                self._violation(
                    relative,
                    1,
                    '',
                    'Model file phải khai báo factory fromJson(Map<String, dynamic> json).',
                ),
            )

        return violations

    def _is_model_file(self, file_path: Path) -> bool:
        patterns = self.project_rules.get(self.GUARD_ID, {}).get('model_file_patterns', [])
        source_relative = PurePosixPath(self.paths.source_relative_path(file_path))
        return any(source_relative.match(pattern) for pattern in patterns)

    def _is_record_typedef(self, content: str) -> bool:
        return (
            self.RECORD_TYPEDEF_PATTERN.search(content) is not None
            and 'class ' not in content
        )

    def _violation(
        self,
        file_path: str,
        line_number: int,
        line_content: str,
        message: str,
    ) -> Violation:
        return Violation(
            file_path=file_path,
            line_number=line_number,
            line_content=line_content,
            message=message,
            guard_id=self.GUARD_ID,
            severity=self.severity,
            scope=self.SCOPE,
        )
