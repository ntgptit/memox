from __future__ import annotations

from collections.abc import Mapping
from dataclasses import dataclass

from tools.guard.core.classification import ClassificationError, Severity
from tools.guard.core.guard_result import GuardResult


class ExitPolicyConfigError(ValueError):
    """Raised when exit policy configuration is invalid."""


@dataclass(slots=True, frozen=True)
class ExitDecision:
    should_fail: bool
    failed_severities: tuple[str, ...]
    counts: dict[str, int]


@dataclass(slots=True, frozen=True)
class ExitPolicy:
    name: str
    description: str | None
    fail_on: frozenset[Severity]

    @classmethod
    def from_dict(cls, policy_name: str, raw: object) -> 'ExitPolicy':
        if not isinstance(raw, Mapping):
            raise ExitPolicyConfigError(f'exit_policy.{policy_name} must be a mapping')

        description = _optional_string(
            raw.get('description'),
            field_name=f'exit_policy.{policy_name}.description',
        )
        fail_on = _severity_list(
            raw.get('fail_on', [Severity.ERROR.value]),
            field_name=f'exit_policy.{policy_name}.fail_on',
        )
        return cls(
            name=policy_name,
            description=description,
            fail_on=frozenset(fail_on),
        )

    def with_additional_fail_on(self, *severities: Severity) -> 'ExitPolicy':
        return ExitPolicy(
            name=self.name,
            description=self.description,
            fail_on=frozenset({*self.fail_on, *severities}),
        )

    def evaluate(self, results: list[GuardResult]) -> ExitDecision:
        counts = {
            Severity.ERROR.value: sum(result.error_count for result in results),
            Severity.WARNING.value: sum(result.warning_count for result in results),
            Severity.INFO.value: sum(result.info_count for result in results),
        }
        failed_severities = tuple(
            severity.value
            for severity in Severity
            if severity in self.fail_on and counts[severity.value] > 0
        )
        return ExitDecision(
            should_fail=bool(failed_severities),
            failed_severities=failed_severities,
            counts=counts,
        )


class ExitPolicyRegistry:
    def __init__(self, policies: dict[str, ExitPolicy]) -> None:
        self.policies = policies

    @classmethod
    def from_config(cls, config: Mapping[str, object]) -> 'ExitPolicyRegistry':
        raw_policies = config.get('exit_policy')

        if raw_policies is None:
            return cls({'default': _legacy_default_exit_policy()})

        if not isinstance(raw_policies, Mapping):
            raise ExitPolicyConfigError('exit_policy must be a mapping')

        policies = {
            policy_name: ExitPolicy.from_dict(policy_name, raw)
            for policy_name, raw in raw_policies.items()
        }

        if 'default' not in policies:
            policies['default'] = _legacy_default_exit_policy()

        return cls(policies)

    @property
    def available_policy_names(self) -> tuple[str, ...]:
        return tuple(sorted(self.policies.keys()))

    def resolve(self, policy_name: str | None) -> ExitPolicy:
        if policy_name is None:
            return _legacy_default_exit_policy()

        if policy_name not in self.policies:
            available = ', '.join(self.available_policy_names)
            raise ExitPolicyConfigError(
                f"Unknown exit policy '{policy_name}'. Available policies: {available}",
            )

        return self.policies[policy_name]


def get_exit_policy_registry(config: dict) -> ExitPolicyRegistry:
    runtime = config.setdefault('_runtime_objects', {})
    cached = runtime.get('exit_policy_registry')

    if cached is not None:
        return cached

    registry = ExitPolicyRegistry.from_config(config)
    runtime['exit_policy_registry'] = registry
    return registry


def resolve_active_exit_policy(
    config: dict,
    *,
    fail_on_warnings: bool = False,
) -> ExitPolicy:
    registry = get_exit_policy_registry(config)
    configured_name = config.get('_runtime', {}).get('exit_policy')
    policy = registry.resolve(configured_name)

    if fail_on_warnings:
        return policy.with_additional_fail_on(Severity.WARNING)

    return policy


def _legacy_default_exit_policy() -> ExitPolicy:
    return ExitPolicy(
        name='default',
        description='Compatibility default: fail on errors only.',
        fail_on=frozenset({Severity.ERROR}),
    )


def _optional_string(value: object, *, field_name: str) -> str | None:
    if value is None:
        return None

    if not isinstance(value, str):
        raise ExitPolicyConfigError(f'{field_name} must be a string')

    text = value.strip()
    if not text:
        raise ExitPolicyConfigError(f'{field_name} must be a non-empty string')

    return text


def _severity_list(value: object, *, field_name: str) -> tuple[Severity, ...]:
    if not isinstance(value, list):
        raise ExitPolicyConfigError(f'{field_name} must be a list')

    severities: list[Severity] = []

    for index, item in enumerate(value):
        try:
            severities.append(
                Severity.parse(item, field_name=f'{field_name}[{index}]'),
            )
        except ClassificationError as exc:
            raise ExitPolicyConfigError(str(exc)) from exc

    return tuple(severities)
