from __future__ import annotations

import re
from pathlib import Path

from tools.guard.core.base_guard import BaseGuard
from tools.guard.core.guard_result import GuardScope, Severity, Violation


class ColorPaletteGuard(BaseGuard):
    GUARD_ID = 'color_palette'
    GUARD_NAME = 'Color palette'
    DESCRIPTION = 'Configured color token files should only use approved palette values.'
    DEFAULT_SEVERITY = Severity.ERROR
    SCOPE = GuardScope.LOCAL

    HEX_PATTERN = re.compile(r'0x[0-9A-Fa-f]{8}')

    @property
    def is_file_level(self) -> bool:
        return False

    def check_project(self, all_files: list[Path]) -> list[Violation]:
        rules = self.project_rules.get(self.GUARD_ID, {})
        target_file = rules.get('target_file', '')
        token_file = self.paths.root_dir / target_file

        if not token_file.exists():
            return [
                Violation(
                    file_path=target_file,
                    line_number=1,
                    line_content='',
                    message='Không tìm thấy configured color token file để validate palette.',
                    guard_id=self.GUARD_ID,
                    severity=self.severity,
                    scope=self.SCOPE,
                ),
            ]

        allowed = {value.upper() for value in self._flatten_palette(self.project_rules.get('color_palette', {}))}
        violations: list[Violation] = []
        lines = token_file.read_text(encoding='utf-8').splitlines()

        for index, line in enumerate(lines, start=1):
            for match in self.HEX_PATTERN.findall(line):
                if match.upper() in allowed:
                    continue

                violations.append(
                    Violation(
                        file_path=self.paths.relative_path(token_file),
                        line_number=index,
                        line_content=line,
                        message=f'Hex {match} không nằm trong configured palette.',
                        guard_id=self.GUARD_ID,
                        severity=self.severity,
                        scope=self.SCOPE,
                    ),
                )

        return violations

    def _flatten_palette(self, value: object) -> list[str]:
        if isinstance(value, str):
            return [value]

        if isinstance(value, list):
            flattened: list[str] = []

            for item in value:
                flattened.extend(self._flatten_palette(item))

            return flattened

        if isinstance(value, dict):
            flattened: list[str] = []

            for item in value.values():
                flattened.extend(self._flatten_palette(item))

            return flattened

        return []
