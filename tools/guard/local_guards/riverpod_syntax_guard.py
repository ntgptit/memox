from __future__ import annotations

import re
from pathlib import Path, PurePosixPath

from tools.guard.core.base_guard import BaseGuard
from tools.guard.core.guard_result import GuardScope, Severity, Violation


class RiverpodSyntaxGuard(BaseGuard):
    GUARD_ID = 'riverpod_syntax'
    GUARD_NAME = 'Riverpod 3 syntax'
    DESCRIPTION = 'Providers must use Riverpod 3 annotation syntax and code generation.'
    DEFAULT_SEVERITY = Severity.ERROR
    SCOPE = GuardScope.LOCAL

    LEGACY_PATTERN_TEMPLATE = r'\b{provider}(?:<[^;=]+>)?(?:\.\w+)?\s*\('
    ANNOTATION_PATTERN = re.compile(r'^\s*@(?:riverpod|Riverpod(?:\([^)]*\))?)\s*$')
    ANNOTATION_IMPORT = "package:riverpod_annotation/riverpod_annotation.dart"
    FLUTTER_RIVERPOD_IMPORT = "package:flutter_riverpod/flutter_riverpod.dart"

    def check_file(self, file_path: Path, lines: list[str]) -> list[Violation]:
        relative = self.paths.relative_path(file_path)

        if relative.startswith('test/'):
            return []

        rules = self.project_rules.get(self.GUARD_ID, {})

        if not self._is_provider_file(file_path, rules):
            return []

        violations = self._collect_legacy_syntax_violations(relative, lines, rules)

        if not any(self.ANNOTATION_PATTERN.match(line.strip()) for line in lines):
            violations.append(
                self._violation(
                    relative,
                    1,
                    '',
                    'Provider file phải khai báo @riverpod hoặc @Riverpod(...) theo Riverpod 3.',
                ),
            )

        if not any(self.ANNOTATION_IMPORT in line for line in lines):
            violations.append(
                self._violation(
                    relative,
                    1,
                    '',
                    'Provider file phải import riverpod_annotation thay vì constructor-based syntax.',
                ),
            )

        if any(self.FLUTTER_RIVERPOD_IMPORT in line for line in lines):
            violations.append(
                self._violation(
                    relative,
                    1,
                    '',
                    'Provider declaration file không dùng flutter_riverpod import. Dùng riverpod_annotation + generated provider.',
                ),
            )

        expected_part = f"part '{file_path.stem}.g.dart';"

        if not any(expected_part in line for line in lines):
            violations.append(
                self._violation(
                    relative,
                    1,
                    '',
                    f"Provider file phải có `{expected_part}` để Riverpod generator tạo provider.",
                ),
            )

        if self._requires_keep_alive(file_path, rules):
            violations.extend(self._collect_keep_alive_violations(relative, lines))

        return violations

    def _collect_legacy_syntax_violations(
        self,
        relative: str,
        lines: list[str],
        rules: dict,
    ) -> list[Violation]:
        violations: list[Violation] = []
        forbidden = rules.get('forbidden_legacy_providers', [])
        patterns = [
            re.compile(self.LEGACY_PATTERN_TEMPLATE.format(provider=re.escape(provider)))
            for provider in forbidden
        ]

        for index, line in enumerate(lines, start=1):
            stripped = line.strip()

            if stripped.startswith('//') or stripped.startswith('///'):
                continue

            for pattern in patterns:
                if not pattern.search(line):
                    continue

                violations.append(
                    self._violation(
                        relative,
                        index,
                        line,
                        'Legacy Riverpod provider syntax detected. Dùng @riverpod/@Riverpod + build_runner.',
                    ),
                )
                break

        return violations

    def _collect_keep_alive_violations(
        self,
        relative: str,
        lines: list[str],
    ) -> list[Violation]:
        violations: list[Violation] = []

        for index, line in enumerate(lines, start=1):
            stripped = line.strip()

            if not stripped.startswith('@'):
                continue

            if stripped == '@Riverpod(keepAlive: true)':
                continue

            if self.ANNOTATION_PATTERN.match(stripped):
                violations.append(
                    self._violation(
                        relative,
                        index,
                        line,
                        'Infrastructure provider phải dùng @Riverpod(keepAlive: true).',
                    ),
                )

        return violations

    def _is_provider_file(self, file_path: Path, rules: dict) -> bool:
        patterns = rules.get('provider_file_patterns', [])
        source_relative = PurePosixPath(self.paths.source_relative_path(file_path))
        return any(source_relative.match(pattern) for pattern in patterns)

    def _requires_keep_alive(self, file_path: Path, rules: dict) -> bool:
        required_files = {
            PurePosixPath(path)
            for path in rules.get('infrastructure_provider_files', [])
        }
        source_relative = PurePosixPath(self.paths.source_relative_path(file_path))
        return source_relative in required_files

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
