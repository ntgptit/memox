from __future__ import annotations

import argparse
from pathlib import Path
import sys

REPO_ROOT = Path(__file__).resolve().parents[2]

if str(REPO_ROOT) not in sys.path:
    sys.path.insert(0, str(REPO_ROOT))

try:
    import yaml
except ImportError as exc:  # pragma: no cover - runtime dependency
    raise SystemExit(
        'PyYAML is required. Run `pip install -r tools/guard/requirements.txt`.',
    ) from exc

from tools.guard.core.guard_registry import GuardRegistry
from tools.guard.core.path_constants import PathConstants
from tools.guard.core.reporter import Reporter

_DEFAULT_POLICY = 'tools/guard/policies/memox'


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            'Code guard tool. '
            'Select a policy with --policy to load project-specific configuration and rules.'
        ),
    )
    parser.add_argument(
        '--policy',
        default=_DEFAULT_POLICY,
        metavar='DIR',
        help=(
            'Policy directory containing policy.yaml and rules.yaml. '
            f'Default: {_DEFAULT_POLICY}'
        ),
    )
    parser.add_argument(
        '--config',
        default=None,
        metavar='FILE',
        help=(
            'Override: explicit path to a policy config YAML. '
            'Takes precedence over <--policy>/policy.yaml when provided.'
        ),
    )
    parser.add_argument(
        '--rules',
        default=None,
        metavar='FILE',
        help=(
            'Override: explicit path to a rules YAML. '
            'Takes precedence over <--policy>/rules.yaml when provided.'
        ),
    )
    parser.add_argument('--family', choices=('all', 'global', 'local'), default='all')
    parser.add_argument('--guard', help='Comma-separated guard ids')
    parser.add_argument('--scope', default='all')
    parser.add_argument('--json', dest='json_output')
    parser.add_argument('--md', dest='markdown_output')
    parser.add_argument('--quiet', action='store_true')
    parser.add_argument('--fail-on-warnings', action='store_true')
    return parser.parse_args()


def resolve_policy_paths(args: argparse.Namespace) -> tuple[Path, Path]:
    """Return (config_path, rules_path) resolved against the repo root.

    Explicit ``--config`` / ``--rules`` take precedence over the policy
    directory; the policy directory is the fallback for each path individually.
    """
    policy_dir = REPO_ROOT / args.policy
    config_path = REPO_ROOT / args.config if args.config else policy_dir / 'policy.yaml'
    rules_path  = REPO_ROOT / args.rules  if args.rules  else policy_dir / 'rules.yaml'
    return config_path, rules_path


def load_yaml(file_path: Path) -> dict:
    data = yaml.safe_load(file_path.read_text(encoding='utf-8'))

    if isinstance(data, dict):
        return data

    return {}


def main() -> int:
    args = parse_args()
    config_path, rules_path = resolve_policy_paths(args)
    config = load_yaml(config_path)
    config['_runtime'] = {'scope': args.scope}
    project_rules = load_yaml(rules_path)
    path_constants = PathConstants.from_config(REPO_ROOT, config)
    registry = GuardRegistry(config=config, path_constants=path_constants, project_rules=project_rules)
    guard_ids = None

    if args.guard:
        guard_ids = {guard_id.strip() for guard_id in args.guard.split(',') if guard_id.strip()}

    results = registry.run(family=args.family, guard_ids=guard_ids, scope=args.scope)
    reporter = Reporter()

    if not args.quiet:
        reporter.render_terminal(results)

    if args.json_output:
        reporter.write_json(results, REPO_ROOT / args.json_output)

    if args.markdown_output:
        reporter.write_markdown(results, REPO_ROOT / args.markdown_output)

    if Reporter.has_errors(results):
        return 1

    if args.fail_on_warnings and Reporter.has_warnings(results):
        return 1

    return 0


if __name__ == '__main__':
    raise SystemExit(main())
