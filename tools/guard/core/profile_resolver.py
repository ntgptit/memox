from __future__ import annotations

from collections.abc import Mapping
from copy import deepcopy
from dataclasses import dataclass

from tools.guard.core.classification import ClassificationError, Severity, TaxonomyCategory


class ProfileConfigError(ValueError):
    """Raised when rule profile configuration is invalid."""


@dataclass(slots=True, frozen=True)
class RuleProfile:
    name: str
    description: str | None
    extends: str | None
    global_guards: dict[str, bool]
    local_guards: dict[str, bool]
    severity_overrides: dict[str, str]
    category_overrides: dict[str, str]
    exit_policy: str | None

    @classmethod
    def from_dict(cls, profile_name: str, raw: object) -> 'RuleProfile':
        if not isinstance(raw, Mapping):
            raise ProfileConfigError(f'rule_profiles.{profile_name} must be a mapping')

        return cls(
            name=profile_name,
            description=_optional_string(
                raw.get('description'),
                field_name=f'rule_profiles.{profile_name}.description',
            ),
            extends=_optional_string(
                raw.get('extends'),
                field_name=f'rule_profiles.{profile_name}.extends',
            ),
            global_guards=_bool_mapping(
                raw.get('global_guards'),
                field_name=f'rule_profiles.{profile_name}.global_guards',
            ),
            local_guards=_bool_mapping(
                raw.get('local_guards'),
                field_name=f'rule_profiles.{profile_name}.local_guards',
            ),
            severity_overrides=_severity_mapping(
                raw.get('severity_overrides'),
                field_name=f'rule_profiles.{profile_name}.severity_overrides',
            ),
            category_overrides=_category_mapping(
                raw.get('category_overrides'),
                taxonomy_raw=raw.get('taxonomy_overrides'),
                field_name=f'rule_profiles.{profile_name}',
            ),
            exit_policy=_optional_string(
                raw.get('exit_policy'),
                field_name=f'rule_profiles.{profile_name}.exit_policy',
            ),
        )


class ProfileResolver:
    def __init__(self, profiles: dict[str, RuleProfile]) -> None:
        self.profiles = profiles
        self._resolved_cache: dict[str, RuleProfile] = {}

    @classmethod
    def from_config(cls, config: Mapping[str, object]) -> 'ProfileResolver':
        raw_profiles = config.get('rule_profiles')

        if raw_profiles is None:
            return cls({})

        if not isinstance(raw_profiles, Mapping):
            raise ProfileConfigError('rule_profiles must be a mapping')

        profiles = {
            profile_name: RuleProfile.from_dict(profile_name, raw)
            for profile_name, raw in raw_profiles.items()
        }
        resolver = cls(profiles)

        for profile_name in profiles:
            resolver.resolve(profile_name)

        return resolver

    @property
    def available_profile_names(self) -> tuple[str, ...]:
        return tuple(sorted(self.profiles.keys()))

    def resolve(self, profile_name: str | None) -> RuleProfile | None:
        if profile_name is None:
            return None

        if profile_name not in self.profiles:
            available = ', '.join(self.available_profile_names)
            raise ProfileConfigError(
                f"Unknown profile '{profile_name}'. Available profiles: {available}",
            )

        return self._resolve(profile_name, stack=())

    def apply_to_config(
        self,
        config: dict,
        profile_name: str | None,
    ) -> tuple[dict, RuleProfile | None]:
        resolved_profile = self.resolve(profile_name)
        merged = deepcopy(config)
        runtime = dict(merged.get('_runtime', {}))
        runtime['profile'] = resolved_profile.name if resolved_profile else None

        if resolved_profile is None:
            merged['_runtime'] = runtime
            return merged, None

        if resolved_profile.global_guards:
            merged['global_guards'] = {
                **dict(merged.get('global_guards', {})),
                **resolved_profile.global_guards,
            }

        if resolved_profile.local_guards:
            merged['local_guards'] = {
                **dict(merged.get('local_guards', {})),
                **resolved_profile.local_guards,
            }

        if resolved_profile.severity_overrides:
            merged['severity_overrides'] = {
                **dict(merged.get('severity_overrides', {})),
                **resolved_profile.severity_overrides,
            }

        if resolved_profile.category_overrides:
            merged['category_overrides'] = {
                **dict(merged.get('category_overrides', {})),
                **resolved_profile.category_overrides,
            }

        if resolved_profile.exit_policy is not None:
            runtime['exit_policy'] = resolved_profile.exit_policy

        merged['_runtime'] = runtime
        return merged, resolved_profile

    def _resolve(self, profile_name: str, *, stack: tuple[str, ...]) -> RuleProfile:
        cached = self._resolved_cache.get(profile_name)

        if cached is not None:
            return cached

        if profile_name in stack:
            cycle = ' -> '.join((*stack, profile_name))
            raise ProfileConfigError(f'rule_profiles inheritance cycle detected: {cycle}')

        profile = self.profiles[profile_name]

        if profile.extends is None:
            self._resolved_cache[profile_name] = profile
            return profile

        if profile.extends not in self.profiles:
            raise ProfileConfigError(
                f"rule_profiles.{profile_name}.extends references unknown profile "
                f"'{profile.extends}'",
            )

        parent = self._resolve(profile.extends, stack=(*stack, profile_name))
        merged = RuleProfile(
            name=profile.name,
            description=profile.description or parent.description,
            extends=None,
            global_guards={**parent.global_guards, **profile.global_guards},
            local_guards={**parent.local_guards, **profile.local_guards},
            severity_overrides={
                **parent.severity_overrides,
                **profile.severity_overrides,
            },
            category_overrides={
                **parent.category_overrides,
                **profile.category_overrides,
            },
            exit_policy=profile.exit_policy or parent.exit_policy,
        )
        self._resolved_cache[profile_name] = merged
        return merged


def get_profile_resolver(config: dict) -> ProfileResolver:
    runtime = config.setdefault('_runtime_objects', {})
    cached = runtime.get('profile_resolver')

    if cached is not None:
        return cached

    resolver = ProfileResolver.from_config(config)
    runtime['profile_resolver'] = resolver
    return resolver


def _optional_string(value: object, *, field_name: str) -> str | None:
    if value is None:
        return None

    if not isinstance(value, str):
        raise ProfileConfigError(f'{field_name} must be a string')

    text = value.strip()
    if not text:
        raise ProfileConfigError(f'{field_name} must be a non-empty string')

    return text


def _bool_mapping(value: object, *, field_name: str) -> dict[str, bool]:
    if value is None:
        return {}

    if not isinstance(value, Mapping):
        raise ProfileConfigError(f'{field_name} must be a mapping')

    parsed: dict[str, bool] = {}

    for key, item in value.items():
        if not isinstance(key, str) or not key.strip():
            raise ProfileConfigError(f'{field_name} contains an invalid key')
        if not isinstance(item, bool):
            raise ProfileConfigError(f'{field_name}.{key} must be a boolean')

        parsed[key] = item

    return parsed


def _severity_mapping(value: object, *, field_name: str) -> dict[str, str]:
    if value is None:
        return {}

    if not isinstance(value, Mapping):
        raise ProfileConfigError(f'{field_name} must be a mapping')

    parsed: dict[str, str] = {}

    for key, item in value.items():
        if not isinstance(key, str) or not key.strip():
            raise ProfileConfigError(f'{field_name} contains an invalid key')

        try:
            parsed[key] = Severity.parse(
                item,
                field_name=f'{field_name}.{key}',
            ).value
        except ClassificationError as exc:
            raise ProfileConfigError(str(exc)) from exc

    return parsed


def _category_mapping(
    category_raw: object,
    *,
    taxonomy_raw: object,
    field_name: str,
) -> dict[str, str]:
    category_overrides = _taxonomy_mapping(
        category_raw,
        field_name=f'{field_name}.category_overrides',
    )
    taxonomy_overrides = _taxonomy_mapping(
        taxonomy_raw,
        field_name=f'{field_name}.taxonomy_overrides',
    )
    return {
        **taxonomy_overrides,
        **category_overrides,
    }


def _taxonomy_mapping(value: object, *, field_name: str) -> dict[str, str]:
    if value is None:
        return {}

    if not isinstance(value, Mapping):
        raise ProfileConfigError(f'{field_name} must be a mapping')

    parsed: dict[str, str] = {}

    for key, item in value.items():
        if not isinstance(key, str) or not key.strip():
            raise ProfileConfigError(f'{field_name} contains an invalid key')

        try:
            parsed[key] = TaxonomyCategory.parse(
                item,
                field_name=f'{field_name}.{key}',
            ).value
        except ClassificationError as exc:
            raise ProfileConfigError(str(exc)) from exc

    return parsed
