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


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description='MemoX AI output guard tool')
    parser.add_argument('--config', default='tools/guard/config.yaml')
    parser.add_argument('--rules', default='tools/guard/project_rules.yaml')
    parser.add_argument('--family', choices=('all', 'global', 'local'), default='all')
    parser.add_argument('--guard', help='Comma-separated guard ids')
    parser.add_argument('--scope', default='all')
    parser.add_argument('--json', dest='json_output')
    parser.add_argument('--md', dest='markdown_output')
    parser.add_argument('--quiet', action='store_true')
    parser.add_argument('--fail-on-warnings', action='store_true')
    return parser.parse_args()


def load_yaml(file_path: Path) -> dict:
    data = yaml.safe_load(file_path.read_text(encoding='utf-8'))

    if isinstance(data, dict):
        return data

    return {}


def main() -> int:
    args = parse_args()
    config = load_yaml(REPO_ROOT / args.config)
    config['_runtime'] = {'scope': args.scope}
    project_rules = load_yaml(REPO_ROOT / args.rules)
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
