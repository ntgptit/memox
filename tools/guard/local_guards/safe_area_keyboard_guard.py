from __future__ import annotations

from pathlib import Path, PurePosixPath

from tools.guard.core.base_guard import BaseGuard
from tools.guard.core.guard_result import GuardScope, Severity, Violation


class SafeAreaKeyboardGuard(BaseGuard):
    GUARD_ID = 'safe_area_keyboard'
    GUARD_NAME = 'Safe area keyboard enforcement'
    DESCRIPTION = 'Input containers must use an approved keyboard-safe scaffold or scroll wrapper.'
    DEFAULT_SEVERITY = Severity.ERROR
    SCOPE = GuardScope.LOCAL

    def check_file(self, file_path: Path, lines: list[str]) -> list[Violation]:
        relative = self.paths.relative_path(file_path)

        if relative.startswith('test/'):
            return []

        if not self._matches_rule_path(file_path):
            return []

        content = '\n'.join(lines)
        rules = self.project_rules.get(self.GUARD_ID, {})
        input_tokens = rules.get('input_tokens', [])

        if not any(token in content for token in input_tokens):
            return []

        keyboard_safe_tokens = rules.get('keyboard_safe_tokens', [])

        if any(token in content for token in keyboard_safe_tokens):
            return []

        return [
            Violation(
                file_path=relative,
                line_number=1,
                line_content='',
                message=rules.get(
                    'missing_keyboard_safe_message',
                    'File contains input but does not use a configured keyboard-safe wrapper.',
                ),
                guard_id=self.GUARD_ID,
                severity=self.severity,
                scope=self.SCOPE,
            ),
        ]

    def _matches_rule_path(self, file_path: Path) -> bool:
        rules = self.project_rules.get(self.GUARD_ID, {})
        patterns = rules.get('path_patterns', [])
        source_relative = PurePosixPath(self.paths.source_relative_path(file_path))
        return any(source_relative.match(pattern) for pattern in patterns)
