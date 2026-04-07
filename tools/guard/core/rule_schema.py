from __future__ import annotations

import re
from dataclasses import dataclass, field
from enum import Enum
from typing import ClassVar


class RuleType(str, Enum):
    FORBIDDEN_PATTERN = 'forbidden_pattern'
    FILE_NAMING = 'file_naming'


@dataclass(slots=True, frozen=True)
class PatternEntry:
    regex_str: str
    message: str
    compiled: re.Pattern = field(compare=False)

    @classmethod
    def from_dict(cls, raw: dict) -> 'PatternEntry':
        regex_str = raw.get('regex', '')
        message = raw.get('message', f'Pattern matched: {regex_str}')
        try:
            compiled = re.compile(regex_str)
        except re.error as exc:
            raise ValueError(f'Invalid regex {regex_str!r}: {exc}') from exc
        return cls(regex_str=regex_str, message=message, compiled=compiled)


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
class NormalizedRule:
    id: str
    rule_type: RuleType
    name: str
    description: str
    severity: str                      # 'error' | 'warning' | 'info'
    scope: str                         # 'global' | 'local'
    enabled: bool
    targets: RuleTargets
    # forbidden_pattern fields
    patterns: tuple[PatternEntry, ...]
    skip_comments: bool
    literal_skip: tuple[str, ...]      # skip lines that contain any of these literal strings
    # file_naming fields
    naming_pattern: re.Pattern | None
    naming_message: str


# ---------------------------------------------------------------------------
# Validation helpers
# ---------------------------------------------------------------------------

_VALID_RULE_TYPES = {t.value for t in RuleType}
_VALID_SEVERITIES = {'error', 'warning', 'info'}
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

    scope = raw.get('scope', 'global')
    if scope not in _VALID_SCOPES:
        errors.append(
            f'{rule_id}: unknown scope {scope!r}. '
            f'Valid values: {sorted(_VALID_SCOPES)}'
        )

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

    if rule_type == RuleType.FILE_NAMING.value:
        naming_pattern = raw.get('naming_pattern')
        if not naming_pattern:
            errors.append(f'{rule_id}: file_naming rule missing required field: naming_pattern')
        else:
            try:
                re.compile(naming_pattern)
            except re.error as exc:
                errors.append(f'{rule_id}: invalid naming_pattern regex: {exc}')

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

        patterns: tuple[PatternEntry, ...] = ()
        naming_pattern: re.Pattern | None = None
        naming_message = ''

        if rule_type == RuleType.FORBIDDEN_PATTERN:
            patterns = tuple(PatternEntry.from_dict(p) for p in raw.get('patterns', []))

        if rule_type == RuleType.FILE_NAMING:
            naming_pattern = re.compile(raw['naming_pattern'])
            naming_message = raw.get('naming_message', 'File name does not match required pattern.')

        rules.append(NormalizedRule(
            id=raw['id'],
            rule_type=rule_type,
            name=raw.get('name', raw['id']),
            description=raw.get('description', ''),
            severity=raw.get('severity', 'error'),
            scope=raw.get('scope', 'global'),
            enabled=raw.get('enabled', True),
            targets=targets,
            patterns=patterns,
            skip_comments=raw.get('skip_comments', True),
            literal_skip=tuple(raw.get('literal_skip', [])),
            naming_pattern=naming_pattern,
            naming_message=naming_message,
        ))

    return rules
