from __future__ import annotations

import re
from dataclasses import dataclass, field
from enum import Enum
from itertools import product
from typing import ClassVar

from tools.guard.core.classification import Severity, TaxonomyCategory, normalize_optional_category


class RuleType(str, Enum):
    FORBIDDEN_PATTERN = 'forbidden_pattern'
    FILE_NAMING = 'file_naming'
    CONTENT_CONTRACT = 'content_contract'
    PATH_REQUIREMENTS = 'path_requirements'


@dataclass(slots=True, frozen=True)
class PatternEntry:
    regex_str: str
    message: str
    message_code: str | None
    compiled: re.Pattern = field(compare=False)

    @classmethod
    def from_dict(cls, raw: dict) -> 'PatternEntry':
        regex_str = raw.get('regex', '')
        message = raw.get('message', f'Pattern matched: {regex_str}')
        message_code = raw.get('message_code')
        try:
            compiled = re.compile(regex_str)
        except re.error as exc:
            raise ValueError(f'Invalid regex {regex_str!r}: {exc}') from exc
        return cls(
            regex_str=regex_str,
            message=message,
            message_code=message_code,
            compiled=compiled,
        )


@dataclass(slots=True, frozen=True)
class RuleTargets:
    """File targeting: include patterns narrow scope, exclude patterns skip files."""
    include: tuple[str, ...] = ()
    exclude: tuple[str, ...] = ()

    _EMPTY: ClassVar['RuleTargets']

    @classmethod
    def from_dict(cls, raw: dict | None) -> 'RuleTargets':
        if not raw:
            return cls()
        return cls(
            include=tuple(raw.get('include', [])),
            exclude=tuple(raw.get('exclude', [])),
        )


RuleTargets._EMPTY = RuleTargets()


@dataclass(slots=True, frozen=True)
class RuleMessages:
    missing_file: str | None = None
    missing_file_code: str | None = None
    missing_required_token: str | None = None
    missing_required_token_code: str | None = None
    aggregate_missing_required_tokens: str | None = None
    aggregate_missing_required_tokens_code: str | None = None
    missing_required_any_tokens: str | None = None
    missing_required_any_tokens_code: str | None = None
    missing_required_pattern: str | None = None
    missing_required_pattern_code: str | None = None
    forbidden_token: str | None = None
    forbidden_token_code: str | None = None
    forbidden_pattern: str | None = None
    forbidden_pattern_code: str | None = None
    missing_path: str | None = None
    missing_path_code: str | None = None
    empty_path: str | None = None
    empty_path_code: str | None = None

    @classmethod
    def from_dict(cls, raw: dict | None) -> 'RuleMessages':
        if not raw:
            return cls()
        return cls(
            missing_file=raw.get('missing_file'),
            missing_file_code=raw.get('missing_file_code'),
            missing_required_token=raw.get('missing_required_token'),
            missing_required_token_code=raw.get('missing_required_token_code'),
            aggregate_missing_required_tokens=raw.get('aggregate_missing_required_tokens'),
            aggregate_missing_required_tokens_code=raw.get(
                'aggregate_missing_required_tokens_code',
            ),
            missing_required_any_tokens=raw.get('missing_required_any_tokens'),
            missing_required_any_tokens_code=raw.get(
                'missing_required_any_tokens_code',
            ),
            missing_required_pattern=raw.get('missing_required_pattern'),
            missing_required_pattern_code=raw.get('missing_required_pattern_code'),
            forbidden_token=raw.get('forbidden_token'),
            forbidden_token_code=raw.get('forbidden_token_code'),
            forbidden_pattern=raw.get('forbidden_pattern'),
            forbidden_pattern_code=raw.get('forbidden_pattern_code'),
            missing_path=raw.get('missing_path'),
            missing_path_code=raw.get('missing_path_code'),
            empty_path=raw.get('empty_path'),
            empty_path_code=raw.get('empty_path_code'),
        )

    def merge(self, override: 'RuleMessages') -> 'RuleMessages':
        return RuleMessages(
            missing_file=override.missing_file or self.missing_file,
            missing_file_code=override.missing_file_code or self.missing_file_code,
            missing_required_token=(
                override.missing_required_token or self.missing_required_token
            ),
            missing_required_token_code=(
                override.missing_required_token_code
                or self.missing_required_token_code
            ),
            aggregate_missing_required_tokens=(
                override.aggregate_missing_required_tokens
                or self.aggregate_missing_required_tokens
            ),
            aggregate_missing_required_tokens_code=(
                override.aggregate_missing_required_tokens_code
                or self.aggregate_missing_required_tokens_code
            ),
            missing_required_any_tokens=(
                override.missing_required_any_tokens
                or self.missing_required_any_tokens
            ),
            missing_required_any_tokens_code=(
                override.missing_required_any_tokens_code
                or self.missing_required_any_tokens_code
            ),
            missing_required_pattern=(
                override.missing_required_pattern or self.missing_required_pattern
            ),
            missing_required_pattern_code=(
                override.missing_required_pattern_code
                or self.missing_required_pattern_code
            ),
            forbidden_token=override.forbidden_token or self.forbidden_token,
            forbidden_token_code=override.forbidden_token_code or self.forbidden_token_code,
            forbidden_pattern=override.forbidden_pattern or self.forbidden_pattern,
            forbidden_pattern_code=(
                override.forbidden_pattern_code or self.forbidden_pattern_code
            ),
            missing_path=override.missing_path or self.missing_path,
            missing_path_code=override.missing_path_code or self.missing_path_code,
            empty_path=override.empty_path or self.empty_path,
            empty_path_code=override.empty_path_code or self.empty_path_code,
        )

    def render(self, context: dict[str, str]) -> 'RuleMessages':
        return RuleMessages(
            missing_file=_format_optional(self.missing_file, context),
            missing_file_code=self.missing_file_code,
            missing_required_token=_format_optional(self.missing_required_token, context),
            missing_required_token_code=self.missing_required_token_code,
            aggregate_missing_required_tokens=_format_optional(
                self.aggregate_missing_required_tokens,
                context,
            ),
            aggregate_missing_required_tokens_code=(
                self.aggregate_missing_required_tokens_code
            ),
            missing_required_any_tokens=_format_optional(
                self.missing_required_any_tokens,
                context,
            ),
            missing_required_any_tokens_code=self.missing_required_any_tokens_code,
            missing_required_pattern=_format_optional(
                self.missing_required_pattern,
                context,
            ),
            missing_required_pattern_code=self.missing_required_pattern_code,
            forbidden_token=_format_optional(self.forbidden_token, context),
            forbidden_token_code=self.forbidden_token_code,
            forbidden_pattern=_format_optional(self.forbidden_pattern, context),
            forbidden_pattern_code=self.forbidden_pattern_code,
            missing_path=_format_optional(self.missing_path, context),
            missing_path_code=self.missing_path_code,
            empty_path=_format_optional(self.empty_path, context),
            empty_path_code=self.empty_path_code,
        )


@dataclass(slots=True, frozen=True)
class ForbiddenPatternData:
    patterns: tuple[PatternEntry, ...]
    skip_comments: bool
    literal_skip: tuple[str, ...]


@dataclass(slots=True, frozen=True)
class FileNamingData:
    naming_pattern: re.Pattern
    naming_message: str
    naming_message_code: str | None


@dataclass(slots=True, frozen=True)
class ContentContractCase:
    file: str | None
    path_patterns: tuple[str, ...]
    must_exist: bool
    required_tokens: tuple[str, ...]
    required_any_tokens: tuple[str, ...]
    forbidden_tokens: tuple[str, ...]
    required_patterns: tuple[PatternEntry, ...]
    forbidden_patterns: tuple[PatternEntry, ...]
    aggregate_required_tokens: bool
    messages: RuleMessages


@dataclass(slots=True, frozen=True)
class ContentContractData:
    cases: tuple[ContentContractCase, ...]


@dataclass(slots=True, frozen=True)
class PathRequirementEntry:
    path: str
    path_kind: str
    must_exist: bool
    contains_glob: str | None
    messages: RuleMessages


@dataclass(slots=True, frozen=True)
class PathRequirementsData:
    entries: tuple[PathRequirementEntry, ...]


@dataclass(slots=True, frozen=True)
class NormalizedRule:
    id: str
    rule_type: RuleType
    name: str
    description: str
    severity: str
    category: str | None
    scope: str
    enabled: bool
    targets: RuleTargets
    data: object


# ---------------------------------------------------------------------------
# Validation helpers
# ---------------------------------------------------------------------------

_VALID_RULE_TYPES = {t.value for t in RuleType}
_VALID_SEVERITIES = set(Severity.values())
_VALID_CATEGORIES = set(TaxonomyCategory.values())
_VALID_SCOPES = {'global', 'local'}


def validate_rule(raw: dict) -> list[str]:
    """Return a list of error strings for a raw rule dict.  Empty = valid."""
    errors: list[str] = []
    rule_id = raw.get('id', '<no id>')

    if not raw.get('id'):
        errors.append('Rule is missing required field: id')

    rule_type = raw.get('type')
    if not rule_type:
        errors.append(f'{rule_id}: missing required field: type')
    elif rule_type not in _VALID_RULE_TYPES:
        errors.append(
            f'{rule_id}: unknown type {rule_type!r}. '
            f'Valid types: {sorted(_VALID_RULE_TYPES)}'
        )

    severity = raw.get('severity', 'error')
    if severity not in _VALID_SEVERITIES:
        errors.append(
            f'{rule_id}: unknown severity {severity!r}. '
            f'Valid values: {sorted(_VALID_SEVERITIES)}'
        )

    category = _raw_category(raw)
    if raw.get('category') and raw.get('taxonomy') and raw.get('category') != raw.get('taxonomy'):
        errors.append(
            f'{rule_id}: category and taxonomy must match when both are provided',
        )
    if category is not None and category not in _VALID_CATEGORIES:
        errors.append(
            f'{rule_id}: unknown category {category!r}. '
            f'Valid values: {sorted(_VALID_CATEGORIES)}'
        )

    scope = raw.get('scope', 'global')
    if scope not in _VALID_SCOPES:
        errors.append(
            f'{rule_id}: unknown scope {scope!r}. '
            f'Valid values: {sorted(_VALID_SCOPES)}'
        )

    errors.extend(_validate_targets(raw.get('targets'), rule_id))

    if rule_type == RuleType.FORBIDDEN_PATTERN.value:
        patterns = raw.get('patterns', [])
        if not isinstance(patterns, list):
            errors.append(f'{rule_id}: patterns must be a list')
        else:
            for i, entry in enumerate(patterns):
                if not isinstance(entry, dict):
                    errors.append(f'{rule_id}: patterns[{i}] must be a mapping')
                    continue
                if not entry.get('regex'):
                    errors.append(f'{rule_id}: patterns[{i}] missing required field: regex')
                else:
                    try:
                        re.compile(entry['regex'])
                    except re.error as exc:
                        errors.append(f'{rule_id}: patterns[{i}] invalid regex: {exc}')
                for field_name in ('message', 'message_code'):
                    value = entry.get(field_name)
                    if value is None:
                        continue
                    if not isinstance(value, str) or not value.strip():
                        errors.append(
                            f'{rule_id}: patterns[{i}].{field_name} must be a non-empty string',
                        )

    if rule_type == RuleType.FILE_NAMING.value:
        naming_pattern = raw.get('naming_pattern')
        if not naming_pattern:
            errors.append(f'{rule_id}: file_naming rule missing required field: naming_pattern')
        else:
            try:
                re.compile(naming_pattern)
            except re.error as exc:
                errors.append(f'{rule_id}: invalid naming_pattern regex: {exc}')
        naming_message_code = raw.get('naming_message_code')
        if naming_message_code is not None and (
            not isinstance(naming_message_code, str) or not naming_message_code.strip()
        ):
            errors.append(
                f'{rule_id}: naming_message_code must be a non-empty string',
            )

    if rule_type == RuleType.CONTENT_CONTRACT.value:
        errors.extend(_validate_content_contract(raw, rule_id))

    if rule_type == RuleType.PATH_REQUIREMENTS.value:
        errors.extend(_validate_path_requirements(raw, rule_id))

    return errors


def parse_rules(raw_rules: list[dict]) -> list[NormalizedRule]:
    """Parse and validate a list of raw rule dicts into NormalizedRule objects.

    Raises ValueError if any rule fails validation.
    """
    all_errors: list[str] = []
    for raw in raw_rules:
        all_errors.extend(validate_rule(raw))

    if all_errors:
        joined = '\n  '.join(all_errors)
        raise ValueError(f'Rule schema validation errors:\n  {joined}')

    rules: list[NormalizedRule] = []
    for raw in raw_rules:
        rule_type = RuleType(raw['type'])
        targets = RuleTargets.from_dict(raw.get('targets'))
        data: object

        if rule_type == RuleType.FORBIDDEN_PATTERN:
            data = ForbiddenPatternData(
                patterns=tuple(PatternEntry.from_dict(p) for p in raw.get('patterns', [])),
                skip_comments=raw.get('skip_comments', True),
                literal_skip=tuple(raw.get('literal_skip', [])),
            )
        elif rule_type == RuleType.FILE_NAMING:
            data = FileNamingData(
                naming_pattern=re.compile(raw['naming_pattern']),
                naming_message=raw.get(
                    'naming_message',
                    'File name does not match required pattern.',
                ),
                naming_message_code=raw.get('naming_message_code'),
            )
        elif rule_type == RuleType.CONTENT_CONTRACT:
            default_messages = RuleMessages.from_dict(raw.get('messages'))
            cases = tuple(
                _parse_content_contract_case(case, default_messages)
                for case in raw.get('cases', [])
            )
            data = ContentContractData(cases=cases)
        else:
            default_messages = RuleMessages.from_dict(raw.get('messages'))
            data = PathRequirementsData(
                entries=tuple(
                    _parse_path_requirement_entries(
                        raw.get('entries', []),
                        default_messages,
                    ),
                ),
            )

        rules.append(NormalizedRule(
            id=raw['id'],
            rule_type=rule_type,
            name=raw.get('name', raw['id']),
            description=raw.get('description', ''),
            severity=raw.get('severity', 'error'),
            category=normalize_optional_category(_raw_category(raw)),
            scope=raw.get('scope', 'global'),
            enabled=raw.get('enabled', True),
            targets=targets,
            data=data,
        ))

    return rules


def _validate_messages(raw: object, rule_id: str, field_name: str) -> list[str]:
    if raw is None:
        return []
    if not isinstance(raw, dict):
        return [f'{rule_id}: {field_name} must be a mapping']

    errors: list[str] = []
    for key, value in raw.items():
        if not isinstance(key, str) or not key:
            errors.append(f'{rule_id}: {field_name} contains an invalid key')
            continue
        if not isinstance(value, str) or not value.strip():
            errors.append(
                f'{rule_id}: {field_name}.{key} must be a non-empty string',
            )

    return errors


def _validate_targets(raw: object, rule_id: str) -> list[str]:
    if raw is None:
        return []

    if not isinstance(raw, dict):
        return [f'{rule_id}: targets must be a mapping']

    errors: list[str] = []

    for field_name in ('include', 'exclude'):
        value = raw.get(field_name)
        if value is None:
            continue
        if not isinstance(value, list):
            errors.append(f'{rule_id}: targets.{field_name} must be a list')
            continue
        for index, item in enumerate(value):
            if not isinstance(item, str) or not item.strip():
                errors.append(
                    f'{rule_id}: targets.{field_name}[{index}] must be a non-empty string',
                )

    return errors


def _validate_content_contract(raw: dict, rule_id: str) -> list[str]:
    errors = _validate_messages(raw.get('messages'), rule_id, 'messages')
    cases = raw.get('cases')

    if not isinstance(cases, list) or not cases:
        errors.append(f'{rule_id}: content_contract rule requires a non-empty cases list')
        return errors

    for index, case in enumerate(cases):
        prefix = f'{rule_id}: cases[{index}]'

        if not isinstance(case, dict):
            errors.append(f'{prefix} must be a mapping')
            continue

        errors.extend(_validate_messages(case.get('messages'), rule_id, f'cases[{index}].messages'))

        file_path = case.get('file')
        path_patterns = case.get('path_patterns')

        has_file = isinstance(file_path, str) and bool(file_path.strip())
        has_patterns = isinstance(path_patterns, list) and bool(path_patterns)

        if not has_file and not has_patterns:
            errors.append(f'{prefix} must define file or path_patterns')

        if path_patterns is not None:
            if not isinstance(path_patterns, list):
                errors.append(f'{prefix}.path_patterns must be a list')
            else:
                for pattern_index, pattern in enumerate(path_patterns):
                    if not isinstance(pattern, str) or not pattern.strip():
                        errors.append(
                            f'{prefix}.path_patterns[{pattern_index}] must be a non-empty string',
                        )

        for field_name in (
            'required_tokens',
            'required_any_tokens',
            'forbidden_tokens',
        ):
            value = case.get(field_name)
            if value is None:
                continue
            if not isinstance(value, list):
                errors.append(f'{prefix}.{field_name} must be a list')
                continue
            for token_index, token in enumerate(value):
                if not isinstance(token, str) or not token.strip():
                    errors.append(
                        f'{prefix}.{field_name}[{token_index}] must be a non-empty string',
                    )

        errors.extend(
            _validate_pattern_entries(
                case.get('required_patterns'),
                rule_id,
                f'cases[{index}].required_patterns',
            ),
        )
        errors.extend(
            _validate_pattern_entries(
                case.get('forbidden_patterns'),
                rule_id,
                f'cases[{index}].forbidden_patterns',
            ),
        )

    return errors


def _validate_pattern_entries(
    raw_entries: object,
    rule_id: str,
    field_name: str,
) -> list[str]:
    if raw_entries is None:
        return []

    if not isinstance(raw_entries, list):
        return [f'{rule_id}: {field_name} must be a list']

    errors: list[str] = []
    for index, entry in enumerate(raw_entries):
        prefix = f'{rule_id}: {field_name}[{index}]'
        if not isinstance(entry, dict):
            errors.append(f'{prefix} must be a mapping')
            continue
        regex_str = entry.get('regex')
        if not isinstance(regex_str, str) or not regex_str:
            errors.append(f'{prefix} missing required field: regex')
            continue
        try:
            re.compile(regex_str)
        except re.error as exc:
            errors.append(f'{prefix} invalid regex: {exc}')

    return errors


def _validate_path_requirements(raw: dict, rule_id: str) -> list[str]:
    errors = _validate_messages(raw.get('messages'), rule_id, 'messages')
    entries = raw.get('entries')

    if not isinstance(entries, list) or not entries:
        errors.append(f'{rule_id}: path_requirements rule requires a non-empty entries list')
        return errors

    for index, entry in enumerate(entries):
        prefix = f'{rule_id}: entries[{index}]'

        if not isinstance(entry, dict):
            errors.append(f'{prefix} must be a mapping')
            continue

        errors.extend(_validate_messages(entry.get('messages'), rule_id, f'entries[{index}].messages'))

        raw_path = entry.get('path')
        raw_template = entry.get('path_template')
        has_path = isinstance(raw_path, str) and bool(raw_path.strip())
        has_template = isinstance(raw_template, str) and bool(raw_template.strip())

        if has_path == has_template:
            errors.append(f'{prefix} must define exactly one of path or path_template')

        path_kind = entry.get('path_kind', 'any')
        if path_kind not in {'any', 'file', 'dir'}:
            errors.append(
                f'{prefix}.path_kind must be one of [\"any\", \"file\", \"dir\"]',
            )

        contains_glob = entry.get('contains_glob')
        if contains_glob is not None and (
            not isinstance(contains_glob, str) or not contains_glob.strip()
        ):
            errors.append(f'{prefix}.contains_glob must be a non-empty string')

        if not has_template:
            continue

        variables = entry.get('variables')
        if not isinstance(variables, dict) or not variables:
            errors.append(f'{prefix}.variables must be a non-empty mapping')
            continue

        for variable_name, values in variables.items():
            if not isinstance(variable_name, str) or not variable_name.strip():
                errors.append(f'{prefix}.variables has an invalid key')
            if not isinstance(values, list) or not values:
                errors.append(
                    f'{prefix}.variables.{variable_name} must be a non-empty list',
                )
                continue
            for value_index, value in enumerate(values):
                if not isinstance(value, str) or not value.strip():
                    errors.append(
                        f'{prefix}.variables.{variable_name}[{value_index}] must be a non-empty string',
                    )

    return errors


def _parse_content_contract_case(
    raw: dict,
    default_messages: RuleMessages,
) -> ContentContractCase:
    case_messages = default_messages.merge(
        RuleMessages.from_dict(raw.get('messages')),
    )
    aggregate_required_tokens = raw.get(
        'aggregate_required_tokens',
        bool(case_messages.aggregate_missing_required_tokens),
    )
    return ContentContractCase(
        file=raw.get('file'),
        path_patterns=tuple(raw.get('path_patterns', [])),
        must_exist=raw.get('must_exist', True),
        required_tokens=tuple(raw.get('required_tokens', [])),
        required_any_tokens=tuple(raw.get('required_any_tokens', [])),
        forbidden_tokens=tuple(raw.get('forbidden_tokens', [])),
        required_patterns=tuple(
            PatternEntry.from_dict(pattern)
            for pattern in raw.get('required_patterns', [])
        ),
        forbidden_patterns=tuple(
            PatternEntry.from_dict(pattern)
            for pattern in raw.get('forbidden_patterns', [])
        ),
        aggregate_required_tokens=aggregate_required_tokens,
        messages=case_messages,
    )


def _parse_path_requirement_entries(
    raw_entries: list[dict],
    default_messages: RuleMessages,
) -> list[PathRequirementEntry]:
    entries: list[PathRequirementEntry] = []

    for raw in raw_entries:
        entry_messages = default_messages.merge(
            RuleMessages.from_dict(raw.get('messages')),
        )

        if raw.get('path'):
            entries.append(PathRequirementEntry(
                path=raw['path'],
                path_kind=raw.get('path_kind', 'any'),
                must_exist=raw.get('must_exist', True),
                contains_glob=raw.get('contains_glob'),
                messages=entry_messages,
            ))
            continue

        template = raw['path_template']
        variables: dict[str, list[str]] = raw.get('variables', {})
        variable_names = list(variables.keys())
        variable_values = [variables[name] for name in variable_names]

        for combination in product(*variable_values):
            context = dict(zip(variable_names, combination))
            entries.append(PathRequirementEntry(
                path=template.format(**context),
                path_kind=raw.get('path_kind', 'any'),
                must_exist=raw.get('must_exist', True),
                contains_glob=raw.get('contains_glob'),
                messages=entry_messages.render(context),
            ))

    return entries


def _format_optional(value: str | None, context: dict[str, str]) -> str | None:
    if value is None:
        return None
    return value.format_map(_FormatDict(context))


class _FormatDict(dict[str, str]):
    def __missing__(self, key: str) -> str:
        return '{' + key + '}'


def _raw_category(raw: dict) -> object:
    return raw.get('category', raw.get('taxonomy'))
