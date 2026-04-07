from __future__ import annotations

from collections.abc import Mapping
from dataclasses import dataclass, field
from enum import Enum
from pathlib import Path

from tools.guard.core.classification import (
    ClassificationError,
    Severity,
    TaxonomyCategory,
    normalize_optional_category,
)

VIOLATION_SCHEMA_VERSION = 2
RESULT_SCHEMA_VERSION = 2


class GuardScope(str, Enum):
    GLOBAL = 'global'
    LOCAL = 'local'


class ViolationSource(str, Enum):
    NORMALIZED = 'normalized'
    LEGACY = 'legacy'
    INTERNAL = 'internal'


class ViolationSchemaError(ValueError):
    """Raised when a violation payload cannot be normalized."""


@dataclass(slots=True)
class Violation:
    file_path: str
    line_number: int
    line_content: str
    message: str
    guard_id: str
    severity: Severity
    scope: GuardScope = GuardScope.GLOBAL
    rule_id: str | None = None
    violation_code: str | None = None
    category: str | None = None
    column_number: int | None = None
    end_line_number: int | None = None
    end_column_number: int | None = None
    symbol: str | None = None
    entity: str | None = None
    message_ref: str | None = None
    message_args: dict[str, object] = field(default_factory=dict)
    suggestion: str | None = None
    remediation: dict[str, object] | None = None
    docs_ref: str | None = None
    autofix: dict[str, object] | None = None
    suppression: dict[str, object] | None = None
    source: str = ViolationSource.LEGACY.value
    schema_version: int = VIOLATION_SCHEMA_VERSION

    def __post_init__(self) -> None:
        self.file_path = _coerce_non_empty_text(_coerce_path(self.file_path), 'file_path')
        self.line_number = _coerce_line_number(self.line_number)
        self.line_content = str(self.line_content or '')
        self.message = _coerce_non_empty_text(self.message, 'message')
        self.guard_id = _coerce_non_empty_text(self.guard_id, 'guard_id')
        self.severity = _coerce_severity(self.severity)
        self.scope = GuardScope(self.scope)
        self.rule_id = _coerce_non_empty_text(self.rule_id or self.guard_id, 'rule_id')
        self.violation_code = _coerce_non_empty_text(
            self.violation_code or self.rule_id,
            'violation_code',
        )
        self.category = _coerce_optional_category(self.category)
        self.column_number = _coerce_optional_position(
            self.column_number,
            field_name='column_number',
        )
        self.end_line_number = _coerce_optional_position(
            self.end_line_number,
            field_name='end_line_number',
        )
        self.end_column_number = _coerce_optional_position(
            self.end_column_number,
            field_name='end_column_number',
        )
        self.symbol = _coerce_optional_text(self.symbol)
        self.entity = _coerce_optional_text(self.entity)
        self.message_ref = _coerce_optional_text(self.message_ref)
        self.message_args = _coerce_required_mapping(
            self.message_args,
            field_name='message_args',
        )
        self.suggestion = _coerce_optional_text(self.suggestion)
        self.remediation = _coerce_optional_mapping(
            self.remediation,
            field_name='remediation',
        )
        self.docs_ref = _coerce_optional_text(self.docs_ref)
        self.autofix = _coerce_optional_mapping(self.autofix, field_name='autofix')
        self.suppression = _coerce_optional_mapping(
            self.suppression,
            field_name='suppression',
        )
        self.source = _coerce_source(self.source)
        self.schema_version = _coerce_schema_version(self.schema_version)

    @property
    def location(self) -> str:
        return f'{self.file_path}:{self.line_number}'

    @classmethod
    def create(
        cls,
        *,
        file_path: str | Path,
        message: str,
        guard_id: str | None = None,
        rule_id: str | None = None,
        severity: Severity | str = Severity.ERROR,
        scope: GuardScope | str = GuardScope.GLOBAL,
        line_number: int = 1,
        line_content: str = '',
        violation_code: str | None = None,
        category: TaxonomyCategory | str | None = None,
        column_number: int | None = None,
        end_line_number: int | None = None,
        end_column_number: int | None = None,
        symbol: str | None = None,
        entity: str | None = None,
        message_ref: str | None = None,
        message_args: Mapping[str, object] | None = None,
        suggestion: str | None = None,
        remediation: Mapping[str, object] | None = None,
        docs_ref: str | None = None,
        autofix: Mapping[str, object] | None = None,
        suppression: Mapping[str, object] | None = None,
        source: ViolationSource | str = ViolationSource.LEGACY,
    ) -> Violation:
        resolved_rule_id = rule_id or guard_id

        if resolved_rule_id is None:
            raise ViolationSchemaError('Violation.create requires rule_id or guard_id.')

        return cls(
            file_path=_coerce_path(file_path),
            line_number=line_number,
            line_content=line_content,
            message=message,
            guard_id=guard_id or resolved_rule_id,
            severity=_coerce_severity(severity),
            scope=GuardScope(scope),
            rule_id=resolved_rule_id,
            violation_code=violation_code or resolved_rule_id,
            category=category,
            column_number=column_number,
            end_line_number=end_line_number,
            end_column_number=end_column_number,
            symbol=symbol,
            entity=entity,
            message_ref=message_ref,
            message_args=dict(message_args or {}),
            suggestion=suggestion,
            remediation=dict(remediation) if remediation is not None else None,
            docs_ref=docs_ref,
            autofix=dict(autofix) if autofix is not None else None,
            suppression=dict(suppression) if suppression is not None else None,
            source=_coerce_source(source),
            schema_version=VIOLATION_SCHEMA_VERSION,
        )

    @classmethod
    def from_dict(
        cls,
        raw: Mapping[str, object],
        *,
        default_guard_id: str | None = None,
        default_scope: GuardScope | str | None = None,
        default_category: TaxonomyCategory | str | None = None,
        default_source: ViolationSource | str = ViolationSource.LEGACY,
    ) -> Violation:
        location_path, location_line = _parse_location(raw.get('location'))
        resolved_guard_id = _coerce_optional_text(
            raw.get('guard_id') or raw.get('rule_id') or default_guard_id,
        )
        resolved_scope = raw.get('scope') or default_scope or GuardScope.GLOBAL.value
        line_number = raw.get('line_number', raw.get('line', location_line or 1))
        file_path = raw.get('file_path') or raw.get('path') or location_path

        return cls.create(
            file_path=file_path or '<unknown>',
            line_number=line_number,
            line_content=str(raw.get('line_content', raw.get('content', '')) or ''),
            message=str(raw.get('message', '')),
            guard_id=resolved_guard_id,
            rule_id=_coerce_optional_text(raw.get('rule_id')) or resolved_guard_id,
            severity=raw.get('severity', Severity.ERROR.value),
            scope=resolved_scope,
            violation_code=_coerce_optional_text(
                raw.get('violation_code') or raw.get('code'),
            ),
            category=normalize_optional_category(
                raw.get('category') or raw.get('taxonomy') or default_category,
            ),
            column_number=raw.get('column_number', raw.get('column')),
            end_line_number=raw.get('end_line_number'),
            end_column_number=raw.get('end_column_number'),
            symbol=_coerce_optional_text(raw.get('symbol')),
            entity=_coerce_optional_text(raw.get('entity')),
            message_ref=_coerce_optional_text(
                raw.get('message_ref') or raw.get('message_id'),
            ),
            message_args=_mapping_or_none(raw.get('message_args')),
            suggestion=_coerce_optional_text(raw.get('suggestion')),
            remediation=_mapping_or_none(raw.get('remediation')),
            docs_ref=_coerce_optional_text(raw.get('docs_ref')),
            autofix=_mapping_or_none(raw.get('autofix')),
            suppression=_mapping_or_none(raw.get('suppression')),
            source=raw.get('source', default_source),
        )

    @classmethod
    def ensure(
        cls,
        raw: Violation | Mapping[str, object],
        *,
        default_guard_id: str | None = None,
        default_scope: GuardScope | str | None = None,
        default_category: TaxonomyCategory | str | None = None,
        default_source: ViolationSource | str = ViolationSource.LEGACY,
    ) -> Violation:
        if isinstance(raw, cls):
            if raw.category is not None or default_category is None:
                return raw

            return cls.from_dict(
                raw.to_dict(),
                default_guard_id=default_guard_id,
                default_scope=default_scope,
                default_category=default_category,
                default_source=default_source,
            )

        if isinstance(raw, Mapping):
            return cls.from_dict(
                raw,
                default_guard_id=default_guard_id,
                default_scope=default_scope,
                default_category=default_category,
                default_source=default_source,
            )

        raise ViolationSchemaError(
            f'Unsupported violation payload type: {type(raw).__name__}',
        )

    @classmethod
    def internal_error(
        cls,
        *,
        guard_id: str,
        scope: GuardScope | str,
        error: Exception | str,
    ) -> Violation:
        return cls.create(
            file_path='<internal>',
            line_number=0,
            line_content='',
            message=f'{guard_id} crashed: {error}',
            guard_id=guard_id,
            severity=Severity.ERROR,
            scope=scope,
            violation_code=f'{guard_id}.internal_error',
            category=TaxonomyCategory.INTERNAL,
            source=ViolationSource.INTERNAL,
        )

    def to_dict(self) -> dict[str, object]:
        return {
            'schema_version': self.schema_version,
            'rule_id': self.rule_id,
            'guard_id': self.guard_id,
            'violation_code': self.violation_code,
            'severity': self.severity.value,
            'category': self.category,
            'scope': self.scope.value,
            'file_path': self.file_path,
            'line_number': self.line_number,
            'column_number': self.column_number,
            'end_line_number': self.end_line_number,
            'end_column_number': self.end_column_number,
            'location': self.location,
            'symbol': self.symbol,
            'entity': self.entity,
            'message': self.message,
            'message_ref': self.message_ref,
            'message_args': dict(self.message_args),
            'suggestion': self.suggestion,
            'remediation': dict(self.remediation) if self.remediation else None,
            'docs_ref': self.docs_ref,
            'autofix': dict(self.autofix) if self.autofix else None,
            'suppression': dict(self.suppression) if self.suppression else None,
            'line_content': self.line_content,
            'source': self.source,
        }


@dataclass(slots=True)
class GuardResult:
    guard_id: str
    guard_name: str
    description: str
    scope: GuardScope
    violations: list[Violation] = field(default_factory=list)
    files_scanned: int = 0
    duration_ms: float = 0.0
    result_schema_version: int = RESULT_SCHEMA_VERSION

    def __post_init__(self) -> None:
        self.scope = GuardScope(self.scope)
        self.result_schema_version = _coerce_result_schema_version(
            self.result_schema_version,
        )
        self.violations = [
            Violation.ensure(
                violation,
                default_guard_id=self.guard_id,
                default_scope=self.scope,
            )
            for violation in self.violations
        ]

    @property
    def passed(self) -> bool:
        return self.error_count == 0

    @property
    def error_count(self) -> int:
        return sum(1 for violation in self.violations if violation.severity == Severity.ERROR)

    @property
    def warning_count(self) -> int:
        return sum(1 for violation in self.violations if violation.severity == Severity.WARNING)

    @property
    def info_count(self) -> int:
        return sum(1 for violation in self.violations if violation.severity == Severity.INFO)

    def to_dict(self) -> dict[str, object]:
        return {
            'result_schema_version': self.result_schema_version,
            'guard_id': self.guard_id,
            'guard_name': self.guard_name,
            'description': self.description,
            'scope': self.scope.value,
            'passed': self.passed,
            'files_scanned': self.files_scanned,
            'duration_ms': self.duration_ms,
            'error_count': self.error_count,
            'warning_count': self.warning_count,
            'info_count': self.info_count,
            'violations': [violation.to_dict() for violation in self.violations],
        }


def _coerce_path(value: str | Path) -> str:
    if isinstance(value, Path):
        return value.as_posix()

    return str(value)


def _coerce_non_empty_text(value: object, field_name: str) -> str:
    text = _coerce_optional_text(value)

    if text is None:
        raise ViolationSchemaError(f'Violation {field_name} is required.')

    return text


def _coerce_optional_text(value: object) -> str | None:
    if value is None:
        return None

    text = str(value).strip()
    if text:
        return text

    return None


def _coerce_line_number(value: object) -> int:
    number = _coerce_int(value, 'line_number')

    if number < 0:
        raise ViolationSchemaError('Violation line_number must be >= 0.')

    return number


def _coerce_optional_position(value: object, *, field_name: str) -> int | None:
    if value is None:
        return None

    number = _coerce_int(value, field_name)

    if number < 1:
        raise ViolationSchemaError(f'Violation {field_name} must be >= 1.')

    return number


def _coerce_int(value: object, field_name: str) -> int:
    try:
        return int(value)
    except (TypeError, ValueError) as exc:  # pragma: no cover - defensive
        raise ViolationSchemaError(
            f'Violation {field_name} must be an integer.',
        ) from exc


def _coerce_required_mapping(
    value: Mapping[str, object] | None,
    *,
    field_name: str,
) -> dict[str, object]:
    if value is None:
        return {}

    if isinstance(value, Mapping):
        return dict(value)

    raise ViolationSchemaError(f'Violation {field_name} must be a mapping.')


def _coerce_optional_mapping(
    value: Mapping[str, object] | None,
    *,
    field_name: str,
) -> dict[str, object] | None:
    if value is None:
        return None

    if isinstance(value, Mapping):
        return dict(value)

    raise ViolationSchemaError(f'Violation {field_name} must be a mapping.')


def _coerce_source(value: ViolationSource | str) -> str:
    if value is None:
        return ViolationSource.LEGACY.value

    return ViolationSource(value).value


def _coerce_severity(value: Severity | str) -> Severity:
    try:
        return Severity.parse(value)
    except ClassificationError as exc:
        raise ViolationSchemaError(str(exc)) from exc


def _coerce_optional_category(value: TaxonomyCategory | str | None) -> str | None:
    try:
        return normalize_optional_category(value)
    except ClassificationError as exc:
        raise ViolationSchemaError(str(exc)) from exc


def _coerce_schema_version(value: object) -> int:
    if value is None:
        return VIOLATION_SCHEMA_VERSION

    version = _coerce_int(value, 'schema_version')

    if version not in {1, VIOLATION_SCHEMA_VERSION}:
        raise ViolationSchemaError(
            f'Unsupported violation schema version: {version}',
        )

    return VIOLATION_SCHEMA_VERSION


def _coerce_result_schema_version(value: object) -> int:
    if value is None:
        return RESULT_SCHEMA_VERSION

    version = _coerce_int(value, 'result_schema_version')

    if version not in {1, RESULT_SCHEMA_VERSION}:
        raise ViolationSchemaError(
            f'Unsupported result schema version: {version}',
        )

    return RESULT_SCHEMA_VERSION


def _parse_location(value: object) -> tuple[str | None, int | None]:
    text = _coerce_optional_text(value)

    if text is None or ':' not in text:
        return None, None

    file_path, _, maybe_line = text.rpartition(':')

    try:
        return file_path, int(maybe_line)
    except ValueError:
        return text, None


def _mapping_or_none(value: object) -> Mapping[str, object] | None:
    if value is None:
        return None

    if isinstance(value, Mapping):
        return value

    raise ViolationSchemaError(
        f'Violation mapping field must be a mapping, got {type(value).__name__}.',
    )
