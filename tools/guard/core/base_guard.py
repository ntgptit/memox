from __future__ import annotations

from abc import ABC
from pathlib import Path
from typing import ClassVar

from tools.guard.core.classification import (
    Severity,
    get_classification_policy,
    normalize_optional_category,
)
from tools.guard.core.guard_result import (
    GuardResult,
    GuardScope,
    Violation,
    ViolationSource,
)
from tools.guard.core.message_catalog import get_message_catalog


class BaseGuard(ABC):
    GUARD_ID: ClassVar[str] = ''
    GUARD_NAME: ClassVar[str] = ''
    DESCRIPTION: ClassVar[str] = ''
    DEFAULT_SEVERITY: ClassVar[Severity] = Severity.ERROR
    CATEGORY: ClassVar[str | None] = None
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
        self.classification = get_classification_policy(config)
        self.message_catalog = get_message_catalog(config)
        self.severity = self._resolve_severity()
        self.category = self._resolve_category()

    def _resolve_severity(self) -> Severity:
        value = self.classification.severity_overrides.get(self.GUARD_ID)

        if value:
            return value

        return self.DEFAULT_SEVERITY

    def _resolve_category(self) -> str | None:
        value = self.classification.category_overrides.get(self.GUARD_ID)

        if value is not None:
            return value

        return normalize_optional_category(self.CATEGORY)

    @property
    def is_enabled(self) -> bool:
        # Derive the config key from the scope value so this method stays
        # policy-agnostic: GuardScope.GLOBAL → 'global_guards',
        # GuardScope.LOCAL → 'local_guards', etc.
        family_key = f'{self.SCOPE.value}_guards'
        return self.config.get(family_key, {}).get(self.GUARD_ID, True)

    def check_file(self, file_path: Path, lines: list[str]) -> list[Violation]:
        return []

    def check_project(self, all_files: list[Path]) -> list[Violation]:
        return []

    @property
    def is_file_level(self) -> bool:
        return True

    def create_violation(
        self,
        *,
        file_path: str,
        message: str | None = None,
        message_code: str | None = None,
        line_number: int = 1,
        line_content: str = '',
        violation_code: str | None = None,
        category: str | None = None,
        column_number: int | None = None,
        end_line_number: int | None = None,
        end_column_number: int | None = None,
        symbol: str | None = None,
        entity: str | None = None,
        message_ref: str | None = None,
        message_args: dict[str, object] | None = None,
        suggestion: str | None = None,
        remediation: dict[str, object] | None = None,
        docs_ref: str | None = None,
        autofix: dict[str, object] | None = None,
        suppression: dict[str, object] | None = None,
    ) -> Violation:
        resolved = self.message_catalog.resolve(
            code=message_code,
            params=message_args,
            fallback_message=message,
            fallback_suggestion=suggestion,
            fallback_remediation=remediation,
            fallback_docs_ref=docs_ref,
        )

        return Violation.create(
            file_path=file_path,
            line_number=line_number,
            line_content=line_content,
            message=resolved.message,
            guard_id=self.GUARD_ID,
            severity=self.severity,
            scope=self.SCOPE,
            violation_code=violation_code or message_code or self.GUARD_ID,
            category=category or self.category,
            column_number=column_number,
            end_line_number=end_line_number,
            end_column_number=end_column_number,
            symbol=symbol,
            entity=entity,
            message_ref=message_ref or resolved.code,
            message_args=resolved.params,
            suggestion=resolved.suggestion,
            remediation=resolved.remediation,
            docs_ref=resolved.docs_ref,
            autofix=autofix,
            suppression=suppression,
            source=ViolationSource.LEGACY,
        )

    def create_result(
        self,
        violations: list[Violation],
        files_scanned: int,
        duration_ms: float,
    ) -> GuardResult:
        normalized_violations = [
            Violation.ensure(
                violation,
                default_guard_id=self.GUARD_ID,
                default_scope=self.SCOPE,
                default_category=self.category,
                default_source=ViolationSource.LEGACY,
            )
            for violation in violations
        ]
        return GuardResult(
            guard_id=self.GUARD_ID,
            guard_name=self.GUARD_NAME,
            description=self.DESCRIPTION,
            scope=self.SCOPE,
            violations=normalized_violations,
            files_scanned=files_scanned,
            duration_ms=duration_ms,
        )
