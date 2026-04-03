from __future__ import annotations

import re
from pathlib import Path, PurePosixPath

from tools.guard.core.base_guard import BaseGuard
from tools.guard.core.guard_result import GuardScope, Severity, Violation


class ScreenScaffoldGuard(BaseGuard):
    GUARD_ID = 'screen_scaffold'
    GUARD_NAME = 'Screen scaffold enforcement'
    DESCRIPTION = 'Feature screens must use AppScaffold or SliverScaffold instead of raw Scaffold.'
    DEFAULT_SEVERITY = Severity.ERROR
    SCOPE = GuardScope.LOCAL

    RAW_SCAFFOLD_PATTERN = re.compile(r'\bScaffold\(')

    def check_file(self, file_path: Path, lines: list[str]) -> list[Violation]:
        relative = self.paths.relative_path(file_path)

        if relative.startswith('test/'):
            return []

        if not self._matches_rule_path(file_path):
            return []

        content = '\n'.join(lines)
        allowed_scaffolds = self.project_rules.get(self.GUARD_ID, {}).get(
            'allowed_scaffolds',
            [],
        )

        if self.RAW_SCAFFOLD_PATTERN.search(content):
            return [self._violation(relative)]

        if any(token in content for token in allowed_scaffolds):
            return []

        return [self._violation(relative)]

    def _matches_rule_path(self, file_path: Path) -> bool:
        rules = self.project_rules.get(self.GUARD_ID, {})
        patterns = rules.get('path_patterns', [])
        source_relative = PurePosixPath(self.paths.source_relative_path(file_path))
        return any(source_relative.match(pattern) for pattern in patterns)

    def _violation(self, relative: str) -> Violation:
        return Violation(
            file_path=relative,
            line_number=1,
            line_content='',
            message='Screen phải dùng AppScaffold hoặc SliverScaffold, không dùng raw Scaffold.',
            guard_id=self.GUARD_ID,
            severity=self.severity,
            scope=self.SCOPE,
        )
