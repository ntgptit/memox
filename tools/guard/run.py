from __future__ import annotations

import argparse
from dataclasses import dataclass
from pathlib import Path
import sys

REPO_ROOT = Path(__file__).resolve().parents[2]
POLICIES_ROOT = REPO_ROOT / 'tools' / 'guard' / 'policies'

if str(REPO_ROOT) not in sys.path:
    sys.path.insert(0, str(REPO_ROOT))

try:
    import yaml
except ImportError as exc:  # pragma: no cover - runtime dependency
    raise SystemExit(
        'PyYAML is required. Run `pip install -r tools/guard/requirements.txt`.',
    ) from exc

from tools.guard.core.guard_registry import GuardDefinition, GuardRegistry
from tools.guard.core.classification import ClassificationError
from tools.guard.core.exit_policy import (
    ExitPolicy,
    ExitPolicyConfigError,
    get_exit_policy_registry,
    resolve_active_exit_policy,
)
from tools.guard.core.message_catalog import MessageCatalogError
from tools.guard.core.path_constants import PathConstants
from tools.guard.core.profile_resolver import ProfileConfigError, get_profile_resolver
from tools.guard.core.reporter import Reporter

_DEFAULT_POLICY = 'tools/guard/policies/memox'


class GuardCliError(RuntimeError):
    """Raised when CLI input or policy configuration is invalid."""


@dataclass(slots=True, frozen=True)
class LoadedRuntime:
    config_path: Path
    rules_path: Path
    config: dict
    project_rules: dict
    path_constants: PathConstants
    registry: GuardRegistry
    active_profile: str | None
    available_profiles: tuple[str, ...]
    exit_policy: ExitPolicy


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description=(
            'Run the guard tool with a selected policy, scope, guard family, '
            'or guard id subset.'
        ),
    )
    parser.add_argument(
        '--policy',
        default=_DEFAULT_POLICY,
        metavar='DIR_OR_NAME',
        help=(
            'Policy directory path or installed policy name. '
            f'Default: {_DEFAULT_POLICY}'
        ),
    )
    parser.add_argument(
        '--config',
        default=None,
        metavar='FILE',
        help=(
            'Compatibility override for the policy config YAML. '
            'Takes precedence over <policy>/policy.yaml when provided.'
        ),
    )
    parser.add_argument(
        '--rules',
        default=None,
        metavar='FILE',
        help=(
            'Compatibility override for the project rules YAML. '
            'Takes precedence over <policy>/rules.yaml when provided.'
        ),
    )
    parser.add_argument(
        '--profile',
        default=None,
        metavar='NAME',
        help='Optional rule profile/preset name defined in policy.yaml.',
    )
    parser.add_argument(
        '--scope',
        default='all',
        metavar='SCOPE',
        help=(
            'Named scan scope from policy scan_targets. For compatibility, an '
            'existing repo-relative directory may also be used.'
        ),
    )
    parser.add_argument(
        '--family',
        choices=('all', 'global', 'local'),
        default='all',
        help='Run all guards, only global guards, or only local guards.',
    )
    parser.add_argument(
        '--guard',
        metavar='IDS',
        help='Comma-separated guard ids to run.',
    )
    parser.add_argument(
        '--validate-config',
        action='store_true',
        help='Validate policy/config/rules loading and exit without scanning files.',
    )
    parser.add_argument(
        '--list',
        '--list-guards',
        dest='list_guards',
        action='store_true',
        help='List available guard ids for the selected family and exit.',
    )
    parser.add_argument(
        '--list-profiles',
        action='store_true',
        help='List available rule profiles from the selected policy and exit.',
    )
    parser.add_argument(
        '--list-scopes',
        action='store_true',
        help='List named scan scopes from the selected policy and exit.',
    )
    parser.add_argument(
        '-v',
        '--verbose',
        action='store_true',
        help='Compatibility flag. Terminal output is already verbose unless --quiet is set.',
    )
    parser.add_argument('--json', dest='json_output', metavar='FILE')
    parser.add_argument('--md', dest='markdown_output', metavar='FILE')
    parser.add_argument('--quiet', action='store_true')
    parser.add_argument('--fail-on-warnings', action='store_true')
    return parser


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    return build_parser().parse_args(argv)


def resolve_policy_paths(args: argparse.Namespace) -> tuple[Path, Path]:
    config_override = _resolve_optional_file(args.config, 'config override')
    rules_override = _resolve_optional_file(args.rules, 'rules override')

    if config_override and rules_override:
        return config_override, rules_override

    policy_dir = _resolve_policy_dir(args.policy)
    config_path = config_override or policy_dir / 'policy.yaml'
    rules_path = rules_override or policy_dir / 'rules.yaml'
    _require_existing_file(config_path, 'policy config')
    _require_existing_file(rules_path, 'project rules')
    return config_path, rules_path


def load_yaml_mapping(file_path: Path, label: str) -> dict:
    try:
        raw = file_path.read_text(encoding='utf-8')
    except OSError as exc:
        raise GuardCliError(f'Unable to read {label} file: {file_path}') from exc

    try:
        data = yaml.safe_load(raw)
    except yaml.YAMLError as exc:
        raise GuardCliError(f'Invalid YAML in {label} file {file_path}: {exc}') from exc

    if data is None:
        return {}

    if isinstance(data, dict):
        return data

    raise GuardCliError(
        f'{label.capitalize()} file must contain a YAML mapping at the top level: {file_path}',
    )


def load_runtime(args: argparse.Namespace) -> LoadedRuntime:
    config_path, rules_path = resolve_policy_paths(args)
    raw_config = load_yaml_mapping(config_path, 'policy config')
    project_rules = load_yaml_mapping(rules_path, 'project rules')
    raw_config['_runtime'] = {'scope': args.scope}

    try:
        profile_resolver = get_profile_resolver(raw_config)
        exit_policy_registry = get_exit_policy_registry(raw_config)
        _validate_profile_exit_policy_refs(profile_resolver, exit_policy_registry)
        config, active_profile = profile_resolver.apply_to_config(raw_config, args.profile)
        exit_policy = resolve_active_exit_policy(
            config,
            fail_on_warnings=args.fail_on_warnings,
        )
        config.setdefault('_runtime', {})['exit_policy'] = exit_policy.name
    except ProfileConfigError as exc:
        raise GuardCliError(
            f'Invalid rule profile configuration in {config_path}: {exc}',
        ) from exc
    except ExitPolicyConfigError as exc:
        raise GuardCliError(
            f'Invalid exit policy configuration in {config_path}: {exc}',
        ) from exc

    try:
        path_constants = PathConstants.from_config(REPO_ROOT, config)
    except ValueError as exc:
        raise GuardCliError(
            f'Invalid policy config in {config_path}: {exc}',
        ) from exc

    try:
        registry = GuardRegistry(
            config=config,
            path_constants=path_constants,
            project_rules=project_rules,
        )
    except ClassificationError as exc:
        raise GuardCliError(
            f'Invalid severity/category configuration in {config_path}: {exc}',
        ) from exc
    except MessageCatalogError as exc:
        raise GuardCliError(
            f'Invalid message/remediation catalog in {config_path}: {exc}',
        ) from exc
    except ValueError as exc:
        raise GuardCliError(
            f'Invalid normalized rule schema in {config_path}: {exc}',
        ) from exc

    return LoadedRuntime(
        config_path=config_path,
        rules_path=rules_path,
        config=config,
        project_rules=project_rules,
        path_constants=path_constants,
        registry=registry,
        active_profile=active_profile.name if active_profile else None,
        available_profiles=profile_resolver.available_profile_names,
        exit_policy=exit_policy,
    )


def validate_scope(scope: str, paths: PathConstants) -> str | None:
    if scope in paths.scope_ids:
        return None

    scope_path = REPO_ROOT / scope

    if scope_path.exists() and scope_path.is_dir():
        return (
            f"Scope '{scope}' is not a named scan target; using repo-relative "
            'directory compatibility fallback. Prefer adding it to scan_targets.'
        )

    available_scopes = ', '.join(paths.scope_ids)
    raise GuardCliError(
        f"Unknown scope '{scope}'. Available scopes: {available_scopes}. "
        'For compatibility, you may also pass an existing repo-relative directory.',
    )


def parse_guard_ids(raw_value: str | None) -> set[str] | None:
    if raw_value is None:
        return None

    guard_ids = {
        guard_id.strip()
        for guard_id in raw_value.split(',')
        if guard_id.strip()
    }

    if guard_ids:
        return guard_ids

    raise GuardCliError('--guard requires at least one non-empty guard id.')


def validate_guard_ids(
    guard_ids: set[str] | None,
    registry: GuardRegistry,
    family: str,
) -> None:
    if guard_ids is None:
        return

    definitions = registry.list_guard_definitions(family=family)
    known_ids = {definition.guard_id for definition in definitions}
    unknown_ids = sorted(guard_ids - known_ids)

    if unknown_ids:
        available_ids = ', '.join(sorted(known_ids))
        raise GuardCliError(
            f"Unknown guard id(s) for family '{family}': {', '.join(unknown_ids)}. "
            f'Available ids: {available_ids}',
        )

    disabled_ids = sorted(
        definition.guard_id
        for definition in definitions
        if definition.guard_id in guard_ids and not definition.enabled
    )

    if disabled_ids:
        raise GuardCliError(
            'Requested guard id(s) are disabled by the selected policy: '
            + ', '.join(disabled_ids),
        )


def print_scope_list(paths: PathConstants) -> None:
    print('Available scopes:')

    for scope_id in paths.scope_ids:
        definition = paths.get_scope_definition(scope_id)
        roots = ', '.join(definition.roots) if definition else '<unknown>'
        extensions = ', '.join(definition.extensions) if definition else '<unknown>'
        print(f'- {scope_id}: roots=[{roots}] extensions=[{extensions}]')


def print_profile_list(runtime: LoadedRuntime) -> None:
    print('Available profiles:')

    if not runtime.available_profiles:
        print('- <none>')
        return

    resolver = get_profile_resolver(runtime.config)

    for profile_name in runtime.available_profiles:
        profile = resolver.resolve(profile_name)
        exit_policy_name = profile.exit_policy or 'default'
        description = f' {profile.description}' if profile.description else ''
        print(f'- {profile_name}: exit_policy={exit_policy_name}{description}')


def print_guard_list(definitions: list[GuardDefinition], family: str) -> None:
    print(f"Available guards for family '{family}':")

    for definition in definitions:
        status = 'enabled' if definition.enabled else 'disabled'
        print(
            f'- {definition.guard_id} '
            f'[{definition.scope.value}, {definition.source}, {status}] '
            f'{definition.guard_name}',
        )


def print_validation_summary(runtime: LoadedRuntime, family: str) -> None:
    definitions = runtime.registry.list_guard_definitions(family=family)
    normalized_count = sum(1 for item in definitions if item.source == 'normalized')
    legacy_count = sum(1 for item in definitions if item.source == 'legacy')
    enabled_count = sum(1 for item in definitions if item.enabled)

    print('Guard CLI configuration is valid.')
    print(f'- Policy config: {_display_path(runtime.config_path)}')
    print(f'- Project rules: {_display_path(runtime.rules_path)}')
    print(f"- Project name: {runtime.config.get('project_name', '<unset>')}")
    print(f"- Active profile: {runtime.active_profile or '<base>'}")
    print(f'- Exit policy: {runtime.exit_policy.name}')
    print(f"- Scopes: {', '.join(runtime.path_constants.scope_ids)}")
    print(
        f'- Guards: {len(definitions)} total '
        f'({enabled_count} enabled, {normalized_count} normalized, {legacy_count} legacy)',
    )


def run_cli(args: argparse.Namespace) -> int:
    runtime = load_runtime(args)
    scope_note = validate_scope(args.scope, runtime.path_constants)
    guard_ids = parse_guard_ids(args.guard)
    validate_guard_ids(guard_ids, runtime.registry, args.family)

    if scope_note and not args.quiet:
        print(scope_note, file=sys.stderr)

    if args.list_scopes:
        print_scope_list(runtime.path_constants)

    if args.list_profiles:
        print_profile_list(runtime)

    if args.list_guards:
        print_guard_list(
            runtime.registry.list_guard_definitions(family=args.family),
            args.family,
        )

    if args.validate_config:
        if args.quiet:
            return 0

        print_validation_summary(runtime, args.family)
        return 0

    if args.list_scopes or args.list_profiles or args.list_guards:
        return 0

    results = runtime.registry.run(
        family=args.family,
        guard_ids=guard_ids,
        scope=args.scope,
    )
    reporter = Reporter(project_name=runtime.config.get('project_name'))

    if not args.quiet:
        reporter.render_terminal(results)

    if args.json_output:
        reporter.write_json(results, _resolve_output_path(args.json_output))

    if args.markdown_output:
        reporter.write_markdown(results, _resolve_output_path(args.markdown_output))

    decision = runtime.exit_policy.evaluate(results)
    if decision.should_fail:
        return 1

    return 0


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv)

    try:
        return run_cli(args)
    except GuardCliError as exc:
        print(f'error: {exc}', file=sys.stderr)
        return 2


def _resolve_policy_dir(raw_value: str) -> Path:
    if Path(raw_value).is_absolute():
        policy_dir = Path(raw_value)
        _require_existing_dir(policy_dir, 'policy')
        return policy_dir

    repo_candidate = REPO_ROOT / raw_value

    if repo_candidate.is_dir():
        return repo_candidate

    named_candidate = POLICIES_ROOT / raw_value

    if named_candidate.is_dir():
        return named_candidate

    available = ', '.join(_available_policy_names())
    raise GuardCliError(
        f"Unknown policy '{raw_value}'. Available policies: {available}",
    )


def _available_policy_names() -> list[str]:
    if not POLICIES_ROOT.exists():
        return []

    return sorted(
        entry.name
        for entry in POLICIES_ROOT.iterdir()
        if entry.is_dir()
    )


def _resolve_optional_file(raw_value: str | None, label: str) -> Path | None:
    if raw_value is None:
        return None

    file_path = _resolve_repo_relative_path(raw_value)
    _require_existing_file(file_path, label)
    return file_path


def _resolve_output_path(raw_value: str) -> Path:
    return _resolve_repo_relative_path(raw_value)


def _resolve_repo_relative_path(raw_value: str) -> Path:
    candidate = Path(raw_value)

    if candidate.is_absolute():
        return candidate

    return REPO_ROOT / raw_value


def _display_path(path: Path) -> str:
    try:
        return path.relative_to(REPO_ROOT).as_posix()
    except ValueError:
        return str(path)


def _require_existing_file(file_path: Path, label: str) -> None:
    if file_path.exists() and file_path.is_file():
        return

    raise GuardCliError(f'Unable to find {label} file: {file_path}')


def _require_existing_dir(dir_path: Path, label: str) -> None:
    if dir_path.exists() and dir_path.is_dir():
        return

    raise GuardCliError(f'Unable to find {label} directory: {dir_path}')


def _validate_profile_exit_policy_refs(profile_resolver, exit_policy_registry) -> None:
    for profile_name in profile_resolver.available_profile_names:
        profile = profile_resolver.resolve(profile_name)

        if profile is None or profile.exit_policy is None:
            continue

        exit_policy_registry.resolve(profile.exit_policy)


if __name__ == '__main__':
    raise SystemExit(main())
