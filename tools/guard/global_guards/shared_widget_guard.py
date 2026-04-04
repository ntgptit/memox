from __future__ import annotations

import re
from pathlib import Path

from tools.guard.core.base_guard import BaseGuard
from tools.guard.core.guard_result import Severity, Violation


class SharedWidgetGuard(BaseGuard):
    GUARD_ID = 'shared_widget'
    GUARD_NAME = 'Shared widget enforcement'
    DESCRIPTION = 'Prefer shared widgets over raw framework widgets.'
    DEFAULT_SEVERITY = Severity.ERROR

    FORBIDDEN_RAW = {
        r'\bCard\(': 'Dùng AppCard thay vì raw Card()',
        r'\.when\s*\(': 'Dùng AppAsyncBuilder thay vì raw .when(...)',
        r'\bElevatedButton\(': 'Dùng PrimaryButton thay vì raw ElevatedButton()',
        r'\bCircularProgressIndicator\(': 'Dùng LoadingIndicator thay vì raw CircularProgressIndicator()',
        r'\bTextField\(': 'Dùng AppTextField thay vì raw TextField()',
        r'\bListTile\(': 'Dùng AppListTile thay vì raw ListTile()',
        r'\bSwitchListTile\(': 'Dùng AppSwitchTile thay vì raw SwitchListTile()',
        r'\bPopupMenuButton(?:<[^>]+>)?\s*\(': 'Dùng AppEditDeleteMenu hoặc shared popup wrapper thay vì raw PopupMenuButton()',
        r'ScaffoldMessenger\.of\(': 'Dùng Toast thay vì raw ScaffoldMessenger',
        r'\bDismissible\(': 'Dùng AppSlidableRow thay vì raw Dismissible()',
    }
    WHITELIST = ('lib/shared/widgets/', 'test/')

    def __init__(self, config: dict, path_constants: 'PathConstants', project_rules: dict | None = None) -> None:
        super().__init__(config, path_constants, project_rules)
        self._patterns = {
            re.compile(pattern): message for pattern, message in self.FORBIDDEN_RAW.items()
        }

    def check_file(self, file_path: Path, lines: list[str]) -> list[Violation]:
        relative = self.paths.relative_path(file_path)

        if any(item in relative for item in self.WHITELIST):
            return []

        violations: list[Violation] = []

        for index, line in enumerate(lines, start=1):
            stripped = line.strip()

            if stripped.startswith('//') or stripped.startswith('///'):
                continue

            for pattern, message in self._patterns.items():
                if not pattern.search(line):
                    continue

                violations.append(
                    Violation(
                        file_path=relative,
                        line_number=index,
                        line_content=line,
                        message=message,
                        guard_id=self.GUARD_ID,
                        severity=self.severity,
                    ),
                )
                break

        return violations
