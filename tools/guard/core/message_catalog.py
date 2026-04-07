from __future__ import annotations

from collections.abc import Mapping
from dataclasses import dataclass


class MessageCatalogError(ValueError):
    """Raised when the configured message or remediation catalog is invalid."""


@dataclass(slots=True, frozen=True)
class RemediationEntry:
    id: str
    title: str | None
    summary: str | None
    manual_steps: tuple[str, ...]
    suggestion: str | None

    @classmethod
    def from_dict(cls, remediation_id: str, raw: object) -> 'RemediationEntry':
        if not isinstance(raw, Mapping):
            raise MessageCatalogError(
                f'remediation_catalog.{remediation_id} must be a mapping',
            )

        title = _optional_string(
            raw.get('title'),
            field_name=f'remediation_catalog.{remediation_id}.title',
        )
        summary = _optional_string(
            raw.get('summary'),
            field_name=f'remediation_catalog.{remediation_id}.summary',
        )
        suggestion = _optional_string(
            raw.get('suggestion'),
            field_name=f'remediation_catalog.{remediation_id}.suggestion',
        )
        manual_steps = _string_list(
            raw.get('manual_steps', []),
            field_name=f'remediation_catalog.{remediation_id}.manual_steps',
        )

        if title is None and summary is None and not manual_steps and suggestion is None:
            raise MessageCatalogError(
                f'remediation_catalog.{remediation_id} must define at least one '
                'of title, summary, suggestion, or manual_steps',
            )

        return cls(
            id=remediation_id,
            title=title,
            summary=summary,
            manual_steps=tuple(manual_steps),
            suggestion=suggestion,
        )


@dataclass(slots=True, frozen=True)
class MessageEntry:
    code: str
    template: str
    suggestion: str | None
    remediation_id: str | None
    docs_ref: str | None

    @classmethod
    def from_dict(cls, code: str, raw: object) -> 'MessageEntry':
        if not isinstance(raw, Mapping):
            raise MessageCatalogError(f'message_catalog.{code} must be a mapping')

        template = _required_string(
            raw.get('template'),
            field_name=f'message_catalog.{code}.template',
        )
        suggestion = _optional_string(
            raw.get('suggestion'),
            field_name=f'message_catalog.{code}.suggestion',
        )
        remediation_id = _optional_string(
            raw.get('remediation_id'),
            field_name=f'message_catalog.{code}.remediation_id',
        )
        docs_ref = _optional_string(
            raw.get('docs_ref'),
            field_name=f'message_catalog.{code}.docs_ref',
        )
        return cls(
            code=code,
            template=template,
            suggestion=suggestion,
            remediation_id=remediation_id,
            docs_ref=docs_ref,
        )


@dataclass(slots=True, frozen=True)
class ResolvedCatalogMessage:
    code: str | None
    message: str
    params: dict[str, object]
    suggestion: str | None
    remediation: dict[str, object] | None
    docs_ref: str | None


class MessageCatalog:
    def __init__(
        self,
        entries: dict[str, MessageEntry],
        remediations: dict[str, RemediationEntry],
    ) -> None:
        self.entries = entries
        self.remediations = remediations

    @classmethod
    def from_config(cls, config: Mapping[str, object]) -> 'MessageCatalog':
        raw_entries = config.get('message_catalog', {})
        raw_remediations = config.get('remediation_catalog', {})

        if raw_entries is None:
            raw_entries = {}

        if raw_remediations is None:
            raw_remediations = {}

        if not isinstance(raw_entries, Mapping):
            raise MessageCatalogError('message_catalog must be a mapping')

        if not isinstance(raw_remediations, Mapping):
            raise MessageCatalogError('remediation_catalog must be a mapping')

        remediations = {
            remediation_id: RemediationEntry.from_dict(remediation_id, raw)
            for remediation_id, raw in raw_remediations.items()
        }
        entries = {
            code: MessageEntry.from_dict(code, raw)
            for code, raw in raw_entries.items()
        }

        for entry in entries.values():
            if entry.remediation_id and entry.remediation_id not in remediations:
                raise MessageCatalogError(
                    f'message_catalog.{entry.code}.remediation_id references '
                    f'unknown remediation_catalog entry {entry.remediation_id!r}',
                )

        return cls(entries=entries, remediations=remediations)

    def resolve(
        self,
        *,
        code: str | None,
        params: Mapping[str, object] | None = None,
        fallback_message: str | None = None,
        fallback_suggestion: str | None = None,
        fallback_remediation: Mapping[str, object] | None = None,
        fallback_docs_ref: str | None = None,
    ) -> ResolvedCatalogMessage:
        resolved_params = dict(params or {})
        entry = self.entries.get(code) if code else None

        if entry is not None:
            message = _format_text(entry.template, resolved_params)
            suggestion = fallback_suggestion or _format_optional(
                entry.suggestion,
                resolved_params,
            )
            docs_ref = fallback_docs_ref or entry.docs_ref
            remediation = _resolved_remediation(
                entry=entry,
                remediations=self.remediations,
                params=resolved_params,
            )

            if fallback_remediation and remediation is None:
                remediation = dict(fallback_remediation)

            return ResolvedCatalogMessage(
                code=entry.code,
                message=message,
                params=resolved_params,
                suggestion=suggestion,
                remediation=remediation,
                docs_ref=docs_ref,
            )

        if fallback_message is not None:
            return ResolvedCatalogMessage(
                code=code,
                message=_format_text(fallback_message, resolved_params),
                params=resolved_params,
                suggestion=fallback_suggestion,
                remediation=dict(fallback_remediation) if fallback_remediation else None,
                docs_ref=fallback_docs_ref,
            )

        if code is None:
            raise MessageCatalogError(
                'Cannot resolve a message without a message code or fallback message.',
            )

        return ResolvedCatalogMessage(
            code=code,
            message=f'Missing message catalog entry: {code}',
            params=resolved_params,
            suggestion=fallback_suggestion,
            remediation=dict(fallback_remediation) if fallback_remediation else None,
            docs_ref=fallback_docs_ref,
        )


def get_message_catalog(config: dict) -> MessageCatalog:
    runtime = config.setdefault('_runtime_objects', {})
    cached = runtime.get('message_catalog')

    if cached is not None:
        return cached

    catalog = MessageCatalog.from_config(config)
    runtime['message_catalog'] = catalog
    return catalog


def _resolved_remediation(
    *,
    entry: MessageEntry,
    remediations: Mapping[str, RemediationEntry],
    params: Mapping[str, object],
) -> dict[str, object] | None:
    if entry.remediation_id is None:
        return None

    remediation = remediations[entry.remediation_id]
    return {
        'id': remediation.id,
        'title': _format_optional(remediation.title, params),
        'summary': _format_optional(remediation.summary, params),
        'suggestion': _format_optional(remediation.suggestion, params),
        'manual_steps': [
            _format_text(step, params)
            for step in remediation.manual_steps
        ],
    }


def _required_string(value: object, *, field_name: str) -> str:
    text = _optional_string(value, field_name=field_name)

    if text is None:
        raise MessageCatalogError(f'{field_name} must be a non-empty string')

    return text


def _optional_string(value: object, *, field_name: str) -> str | None:
    if value is None:
        return None

    if not isinstance(value, str):
        raise MessageCatalogError(f'{field_name} must be a string')

    text = value.strip()
    if not text:
        raise MessageCatalogError(f'{field_name} must be a non-empty string')

    return text


def _string_list(value: object, *, field_name: str) -> list[str]:
    if value is None:
        return []

    if not isinstance(value, list):
        raise MessageCatalogError(f'{field_name} must be a list of strings')

    items: list[str] = []
    for index, item in enumerate(value):
        items.append(
            _required_string(item, field_name=f'{field_name}[{index}]'),
        )
    return items


def _format_text(template: str, params: Mapping[str, object]) -> str:
    return template.format_map(_FormatDict(params))


def _format_optional(
    template: str | None,
    params: Mapping[str, object],
) -> str | None:
    if template is None:
        return None
    return _format_text(template, params)


class _FormatDict(dict[str, object]):
    def __missing__(self, key: str) -> str:
        return '{' + key + '}'
