# Guard CLI Usage v2

Date: 2026-04-07

## Purpose

`tools/guard/run.py` is the entrypoint for the refactored guard system:

- policy-driven config and project rules
- config-driven scan scopes and paths
- normalized rule execution for migrated guards
- legacy Python guards for behaviors that still need custom logic

The CLI keeps the default MemoX workflow intact while making policy selection,
scope selection, and config validation explicit.

## Quick Start

Run the default MemoX policy across all configured scopes:

```bash
python tools/guard/run.py
python tools/guard/run.py --scope all
```

Run one family only:

```bash
python tools/guard/run.py --family global
python tools/guard/run.py --family local
```

Run a subset of guards:

```bash
python tools/guard/run.py --guard no_else,shared_widget
python tools/guard/run.py --family local --guard refresh_retry,safe_area_keyboard
```

Validate policy/config loading without scanning files:

```bash
python tools/guard/run.py --validate-config
python tools/guard/run.py --policy memox --validate-config
```

## Policy Selection

The CLI accepts either:

1. a policy directory path
2. an installed policy name under `tools/guard/policies/`

Examples:

```bash
python tools/guard/run.py --policy tools/guard/policies/memox
python tools/guard/run.py --policy memox
```

Compatibility overrides for explicit file-based usage still work:

```bash
python tools/guard/run.py \
  --config tools/guard/policies/memox/policy.yaml \
  --rules tools/guard/policies/memox/rules.yaml
```

If both `--config` and `--rules` are provided, they take precedence over
`--policy`.

## Scope Selection

Preferred usage is a named scope from `scan_targets` in `policy.yaml`:

```bash
python tools/guard/run.py --scope core
python tools/guard/run.py --scope shared
python tools/guard/run.py --scope features
python tools/guard/run.py --scope test
```

List the available named scopes:

```bash
python tools/guard/run.py --list-scopes
```

Compatibility fallback: `--scope` may still point at an existing repo-relative
directory. The CLI will allow it and print a note telling you to prefer a named
`scan_targets` scope.

Invalid scope values fail fast with a clear error and the list of known scopes.

## Guard Selection

List available guards:

```bash
python tools/guard/run.py --list-guards
python tools/guard/run.py --family global --list-guards
python tools/guard/run.py --family local --list-guards
```

Compatibility alias:

```bash
python tools/guard/run.py --list
```

Each listed entry shows:

- guard id
- scope
- implementation source (`normalized` or `legacy`)
- enabled/disabled status

When `--guard` is used:

- unknown guard ids fail fast
- disabled guard ids fail fast
- family filtering still applies

## Output Options

Terminal output:

```bash
python tools/guard/run.py
python tools/guard/run.py --quiet
```

Machine-readable reports:

```bash
python tools/guard/run.py --json reports/guard.json
python tools/guard/run.py --md reports/guard.md
```

Parent directories for `--json` and `--md` outputs are created automatically.

Warnings as failure:

```bash
python tools/guard/run.py --fail-on-warnings
```

## Help

```bash
python tools/guard/run.py --help
```

Important flags:

- `--policy`
- `--config`
- `--rules`
- `--scope`
- `--family`
- `--guard`
- `--validate-config`
- `--list-guards` / `--list`
- `--list-scopes`
- `--json`
- `--md`
- `--quiet`
- `--fail-on-warnings`

`-v` / `--verbose` is accepted as a compatibility flag, but the CLI is already
verbose by default unless `--quiet` is set.

## Failure Modes

The CLI now fails fast with explicit messages for:

- unknown policy names or missing policy directories
- missing `policy.yaml` or `rules.yaml`
- invalid YAML in either file
- invalid top-level YAML shapes
- invalid normalized rule schema
- invalid scope selections
- invalid or disabled guard selections

Exit codes:

- `0` — success
- `1` — guard execution found errors, or warnings when `--fail-on-warnings` is set
- `2` — CLI/configuration/selection error

## Migration Notes

### Still supported

Old MemoX default usage still works:

```bash
python tools/guard/run.py --scope all
python tools/guard/run.py --family local
python tools/guard/run.py --guard no_else
```

Old explicit-file override usage still works:

```bash
python tools/guard/run.py --config <policy.yaml> --rules <rules.yaml>
```

`--list` now works as a compatibility alias for `--list-guards`.

### Changed / clarified

- Policy selection is now a first-class concept. Prefer `--policy memox` or a
  policy directory over ad hoc file flags.
- Named scopes come from `scan_targets` in policy config. Ad hoc path scopes are
  now treated as compatibility behavior, not the primary interface.
- Invalid config and invalid rule schema errors are reported before any scan
  work starts.

## Related Docs

- `tools/guard/docs/config_scopes_paths.md`
- `tools/guard/docs/rule_schema_v2.md`
- `tools/guard/docs/policy_separation.md`
- `tools/guard/docs/generic_guard_migration.md`
