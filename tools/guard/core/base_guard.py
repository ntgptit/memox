from __future__ import annotations

from abc import ABC
from pathlib import Path
from typing import ClassVar

from tools.guard.core.guard_result import GuardResult, GuardScope, Severity, Violation


class BaseGuard(ABC):
    GUARD_ID: ClassVar[str] = ''
    GUARD_NAME: ClassVar[str] = ''
    DESCRIPTION: ClassVar[str] = ''
    DEFAULT_SEVERITY: ClassVar[Severity] = Severity.ERROR
    SCOPE: ClassVar[GuardScope] = GuardScope.GLOBAL

    def __init__(
        self,
        config: dict,
        path_constants: 'PathConstants',
        project_rules: dict | None = None,
    ) -> None:
        self.config = config
        self.paths = path_constants
        self.project_rules = project_rules or {}
        self.severity = self._resolve_severity()

    def _resolve_severity(self) -> Severity:
        overrides = self.config.get('severity_overrides', {})
        value = overrides.get(self.GUARD_ID)

        if value:
            return Severity(value)

        return self.DEFAULT_SEVERITY

    @property
    def is_enabled(self) -> bool:
        family_key = 'global_guards'

        if self.SCOPE == GuardScope.LOCAL:
            family_key = 'local_guards'

        return self.config.get(family_key, {}).get(self.GUARD_ID, True)

    def check_file(self, file_path: Path, lines: list[str]) -> list[Violation]:
        return []

    def check_project(self, all_files: list[Path]) -> list[Violation]:
        return []

    @property
    def is_file_level(self) -> bool:
        return True

    def create_result(
        self,
        violations: list[Violation],
        files_scanned: int,
        duration_ms: float,
    ) -> GuardResult:
        return GuardResult(
            guard_id=self.GUARD_ID,
            guard_name=self.GUARD_NAME,
            description=self.DESCRIPTION,
            scope=self.SCOPE,
            violations=violations,
            files_scanned=files_scanned,
            duration_ms=duration_ms,
        )
