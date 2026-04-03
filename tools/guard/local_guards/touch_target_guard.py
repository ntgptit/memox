from __future__ import annotations

from pathlib import Path, PurePosixPath

from tools.guard.core.base_guard import BaseGuard
from tools.guard.core.guard_result import GuardScope, Severity, Violation


class TouchTargetGuard(BaseGuard):
    GUARD_ID = 'touch_target'
    GUARD_NAME = 'Touch target enforcement'
    DESCRIPTION = 'Button-like custom widgets must preserve a minimum 48dp hit target.'
    DEFAULT_SEVERITY = Severity.ERROR
    SCOPE = GuardScope.LOCAL

    def check_file(self, file_path: Path, lines: list[str]) -> list[Violation]:
        relative = self.paths.relative_path(file_path)

        if relative.startswith('test/'):
            return []

        if not self._matches_path(file_path):
            return []

        content = '\n'.join(lines)
        required_tokens = self.project_rules.get(self.GUARD_ID, {}).get(
            'required_tokens',
            [],
        )

        if any(token in content for token in required_tokens):
            return []

        return [
            Violation(
                file_path=relative,
                line_number=1,
                line_content='',
                message='Custom tappable widget phải bảo đảm hit target 48dp bằng SizeTokens.touchTarget hoặc constraints tương đương.',
                guard_id=self.GUARD_ID,
                severity=self.severity,
                scope=self.SCOPE,
            ),
        ]

    def _matches_path(self, file_path: Path) -> bool:
        patterns = self.project_rules.get(self.GUARD_ID, {}).get(
            'path_patterns',
            [],
        )
        source_relative = PurePosixPath(self.paths.source_relative_path(file_path))
        return any(source_relative.match(pattern) for pattern in patterns)
