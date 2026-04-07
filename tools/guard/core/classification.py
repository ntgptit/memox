from __future__ import annotations

from collections.abc import Callable, Mapping
from dataclasses import dataclass
from enum import Enum


class ClassificationError(ValueError):
    """Raised when severity or taxonomy config is invalid."""


class Severity(str, Enum):
    ERROR = 'error'
    WARNING = 'warning'
    INFO = 'info'

    @classmethod
    def values(cls) -> tuple[str, ...]:
        return tuple(item.value for item in cls)

    @classmethod
    def parse(
        cls,
        value: Severity | str,
        *,
        field_name: str = 'severity',
    ) -> 'Severity':
        try:
            return cls(value)
        except ValueError as exc:
            raise ClassificationError(
                f'{field_name} must be one of {sorted(cls.values())}',
            ) from exc


class TaxonomyCategory(str, Enum):
    STYLE = 'style'
    STRUCTURE = 'structure'
    NAMING = 'naming'
    DESIGN_SYSTEM = 'design_system'
    DEPENDENCY = 'dependency'
    STATE_MANAGEMENT = 'state_management'
    DATA_CONTRACT = 'data_contract'
    DATABASE_CONTRACT = 'database_contract'
    I18N = 'i18n'
    TESTING = 'testing'
    PERFORMANCE = 'performance'
    SECURITY = 'security'
    INTERNAL = 'internal'

    @classmethod
    def values(cls) -> tuple[str, ...]:
        return tuple(item.value for item in cls)

    @classmethod
    def parse(
        cls,
        value: TaxonomyCategory | str,
        *,
        field_name: str = 'category',
    ) -> 'TaxonomyCategory':
        try:
            return cls(value)
        except ValueError as exc:
            raise ClassificationError(
                f'{field_name} must be one of {sorted(cls.values())}',
            ) from exc


@dataclass(slots=True, frozen=True)
class ClassificationPolicy:
    severity_overrides: dict[str, Severity]
    category_overrides: dict[str, str]

    @classmethod
    def from_config(cls, config: Mapping[str, object]) -> 'ClassificationPolicy':
        severity_overrides = _parse_override_mapping(
            config.get('severity_overrides'),
            field_name='severity_overrides',
            value_parser=lambda value, field_name: Severity.parse(
                value,
                field_name=field_name,
            ),
        )
        taxonomy_overrides = _parse_override_mapping(
            config.get('taxonomy_overrides'),
            field_name='taxonomy_overrides',
            value_parser=lambda value, field_name: TaxonomyCategory.parse(
                value,
                field_name=field_name,
            ).value,
        )
        category_overrides = _parse_override_mapping(
            config.get('category_overrides'),
            field_name='category_overrides',
            value_parser=lambda value, field_name: TaxonomyCategory.parse(
                value,
                field_name=field_name,
            ).value,
        )
        return cls(
            severity_overrides=severity_overrides,
            category_overrides={
                **taxonomy_overrides,
                **category_overrides,
            },
        )


def get_classification_policy(config: dict) -> ClassificationPolicy:
    runtime = config.setdefault('_runtime_objects', {})
    cached = runtime.get('classification_policy')

    if cached is not None:
        return cached

    policy = ClassificationPolicy.from_config(config)
    runtime['classification_policy'] = policy
    return policy


def normalize_optional_category(
    value: TaxonomyCategory | str | None,
    *,
    field_name: str = 'category',
) -> str | None:
    if value is None:
        return None

    return TaxonomyCategory.parse(value, field_name=field_name).value


def normalize_optional_severity(
    value: Severity | str | None,
    *,
    field_name: str = 'severity',
) -> Severity | None:
    if value is None:
        return None

    return Severity.parse(value, field_name=field_name)


def _parse_override_mapping[T](
    raw: object,
    *,
    field_name: str,
    value_parser: Callable[[object, str], T],
) -> dict[str, T]:
    if raw is None:
        return {}

    if not isinstance(raw, Mapping):
        raise ClassificationError(f'{field_name} must be a mapping')

    parsed: dict[str, T] = {}

    for key, value in raw.items():
        if not isinstance(key, str) or not key.strip():
            raise ClassificationError(f'{field_name} contains an invalid key')

        parsed[key] = value_parser(value, f'{field_name}.{key}')

    return parsed
