from __future__ import annotations

import re
from pathlib import Path

from tools.guard.core.base_guard import BaseGuard
from tools.guard.core.guard_result import GuardScope, Severity, Violation


class ProviderNamingGuard(BaseGuard):
    GUARD_ID = 'provider_naming'
    GUARD_NAME = 'Provider naming'
    DESCRIPTION = 'Riverpod declarations should match configured provider naming conventions.'
    DEFAULT_SEVERITY = Severity.ERROR
    SCOPE = GuardScope.LOCAL

    FUNCTION_PATTERN = re.compile(r'^\s*(?:[\w<>, ?]+\s+)+(\w+)\s*\(')
    CLASS_PATTERN = re.compile(r'^\s*class\s+(\w+)\s+extends\s+_\$\w+')

    def check_file(self, file_path: Path, lines: list[str]) -> list[Violation]:
        relative = self.paths.relative_path(file_path)
        normalized_relative = relative.replace('\\', '/')
        rules = self.project_rules.get(self.GUARD_ID, {})
        match_paths = tuple(rules.get('match_paths', []))

        if not any(path in normalized_relative for path in match_paths):
            return []

        annotation_tokens = set(rules.get('annotation_tokens', []))
        naming_cases = tuple(rules.get('naming_cases', []))
        violations: list[Violation] = []

        for index, line in enumerate(lines):
            annotation = line.strip()

            if annotation not in annotation_tokens:
                continue

            declaration = self._next_declaration(lines, index + 1)

            if not declaration:
                continue

            matched_case = self._match_case(normalized_relative, naming_cases)

            if matched_case is None:
                continue

            name = declaration
            generated_name = f'{name[0].lower()}{name[1:]}Provider'
            expected_pattern = re.compile(matched_case['generated_name_pattern'])

            if expected_pattern.match(generated_name):
                continue

            violations.append(
                self._violation(
                    relative,
                    index + 1,
                    line,
                    '{name} does not match the {label} naming rule.'.format(
                        name=generated_name,
                        label=matched_case['label'],
                    ),
                ),
            )

        return violations

    @staticmethod
    def _match_case(relative: str, naming_cases: tuple[dict, ...]) -> dict | None:
        for case in naming_cases:
            path_suffix = case.get('path_suffix')
            path_contains = case.get('path_contains')

            if path_suffix and relative.endswith(path_suffix):
                return case

            if path_contains and path_contains in relative:
                return case

        return None

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
