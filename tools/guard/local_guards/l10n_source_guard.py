from __future__ import annotations

from pathlib import Path, PurePosixPath

from tools.guard.core.base_guard import BaseGuard
from tools.guard.core.guard_result import GuardScope, Severity, Violation


class L10nSourceGuard(BaseGuard):
    GUARD_ID = 'l10n_source'
    GUARD_NAME = 'L10n source enforcement'
    DESCRIPTION = 'UI-facing files must source strings from the configured localization API.'
    DEFAULT_SEVERITY = Severity.ERROR
    SCOPE = GuardScope.LOCAL

    def check_file(self, file_path: Path, lines: list[str]) -> list[Violation]:
        relative = self.paths.relative_path(file_path)

        if relative.startswith('test/'):
            return []

        if not self._matches_rule_path(file_path):
            return []

        rules = self.project_rules.get(self.GUARD_ID, {})
        forbidden_tokens = rules.get('forbidden_tokens', [])
        message = rules.get(
            'message',
            'UI-facing files must use the configured localization source.',
        )
        violations: list[Violation] = []

        for index, line in enumerate(lines, start=1):
            stripped = line.strip()

            if stripped.startswith('//') or stripped.startswith('///'):
                continue

            for token in forbidden_tokens:
                if token not in line:
                    continue

                violations.append(
                    Violation(
                        file_path=relative,
                        line_number=index,
                        line_content=line,
                        message=message,
                        guard_id=self.GUARD_ID,
                        severity=self.severity,
                        scope=self.SCOPE,
                    ),
                )
                break

        return violations

    def _matches_rule_path(self, file_path: Path) -> bool:
        rules = self.project_rules.get(self.GUARD_ID, {})
        patterns = rules.get('path_patterns', [])
        source_relative = PurePosixPath(self.paths.source_relative_path(file_path))
        return any(source_relative.match(pattern) for pattern in patterns)
