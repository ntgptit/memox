from __future__ import annotations

import re
from pathlib import Path

from tools.guard.core.base_guard import BaseGuard
from tools.guard.core.guard_result import GuardScope, Severity, Violation


class ProviderNamingGuard(BaseGuard):
    GUARD_ID = 'provider_naming'
    GUARD_NAME = 'Provider naming'
    DESCRIPTION = 'Riverpod declarations should match MemoX provider naming conventions.'
    DEFAULT_SEVERITY = Severity.ERROR
    SCOPE = GuardScope.LOCAL

    FUNCTION_PATTERN = re.compile(r'^\s*(?:[\w<>, ?]+\s+)+(\w+)\s*\(')
    CLASS_PATTERN = re.compile(r'^\s*class\s+(\w+)\s+extends\s+_\$\w+')

    def check_file(self, file_path: Path, lines: list[str]) -> list[Violation]:
        relative = self.paths.relative_path(file_path)

        if '/providers/' not in relative.replace('\\', '/'):
            return []

        rules = self.project_rules.get('provider_naming', {})
        repository_pattern = re.compile(rules.get('repository_pattern', r'^\w+RepositoryProvider$'))
        usecase_pattern = re.compile(rules.get('usecase_pattern', r'^\w+UseCaseProvider$'))
        controller_pattern = re.compile(rules.get('controller_pattern', r'^\w+ControllerProvider$'))
        violations: list[Violation] = []

        for index, line in enumerate(lines):
            annotation = line.strip()

            if annotation not in {'@riverpod', '@Riverpod(keepAlive: true)', '@Riverpod'}:
                continue

            declaration = self._next_declaration(lines, index + 1)

            if not declaration:
                continue

            name = declaration
            generated_name = f'{name[0].lower()}{name[1:]}Provider'

            if relative.endswith('repository_providers.dart') and repository_pattern.match(generated_name):
                continue

            if relative.endswith('usecase_providers.dart') and usecase_pattern.match(generated_name):
                continue

            if '/controllers/' in relative.replace('\\', '/') and controller_pattern.match(generated_name):
                continue

            if relative.endswith('repository_providers.dart'):
                violations.append(
                    self._violation(relative, index + 1, line, f'{generated_name} không match repository naming rule.'),
                )
                continue

            if relative.endswith('usecase_providers.dart'):
                violations.append(
                    self._violation(relative, index + 1, line, f'{generated_name} không match use case naming rule.'),
                )
                continue

            if '/controllers/' not in relative.replace('\\', '/'):
                continue

            violations.append(
                self._violation(relative, index + 1, line, f'{generated_name} không match controller naming rule.'),
            )

        return violations

    def _next_declaration(self, lines: list[str], start: int) -> str | None:
        for cursor in range(start, len(lines)):
            stripped = lines[cursor].strip()

            if not stripped or stripped.startswith('//') or stripped.startswith('///'):
                continue

            class_match = self.CLASS_PATTERN.search(lines[cursor])

            if class_match:
                return class_match.group(1)

            function_match = self.FUNCTION_PATTERN.search(lines[cursor])

            if function_match:
                return function_match.group(1)

            return None

        return None

    def _violation(self, file_path: str, line_number: int, line_content: str, message: str) -> Violation:
        return Violation(
            file_path=file_path,
            line_number=line_number,
            line_content=line_content,
            message=message,
            guard_id=self.GUARD_ID,
            severity=self.severity,
            scope=self.SCOPE,
        )
