from __future__ import annotations

from pathlib import Path

from tools.guard.core.base_guard import BaseGuard
from tools.guard.core.guard_result import GuardScope, Severity, Violation


class SharedWidgetMappingGuard(BaseGuard):
    GUARD_ID = 'shared_widget_mapping'
    GUARD_NAME = 'Shared widget mapping'
    DESCRIPTION = 'Screens must use project-approved shared widgets for specific contexts.'
    DEFAULT_SEVERITY = Severity.ERROR
    SCOPE = GuardScope.LOCAL

    @property
    def is_file_level(self) -> bool:
        return False

    def check_project(self, all_files: list[Path]) -> list[Violation]:
        scope = self.config.get('_runtime', {}).get('scope', 'all')

        if scope not in {'all', 'features'}:
            return []

        mappings = self.project_rules.get('shared_widget_mapping', {})
        violations: list[Violation] = []

        for rule in mappings.values():
            pattern = rule.get('path_pattern')

            if not pattern:
                continue

            matched_files = [file_path for file_path in all_files if self.paths.matches_source_pattern(file_path, pattern)]

            for file_path in matched_files:
                content = file_path.read_text(encoding='utf-8')
                relative = self.paths.relative_path(file_path)

                for widget_name in rule.get('required_widgets', []):
                    if widget_name in content:
                        continue

                    violations.append(
                        self._violation(relative, f'{relative} phải dùng widget `{widget_name}`.'),
                    )

                for forbidden in rule.get('forbidden_widgets', []):
                    if forbidden not in content:
                        continue

                    violations.append(
                        self._violation(relative, f'{relative} chứa forbidden widget usage `{forbidden}`.'),
                    )

                for forbidden in rule.get('forbidden_in_list_context', []):
                    if forbidden not in content:
                        continue

                    violations.append(
                        self._violation(relative, f'{relative} chứa list-context forbidden usage `{forbidden}`.'),
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
