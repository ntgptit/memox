# Guard Testing v2

Date: 2026-04-07

## Purpose

The `tools/guard/tests/` suite is the regression safety net for the refactored
guard system. It covers only guard-tool behavior:

- config and policy loading
- scope and path resolution
- normalized rule parsing and execution
- legacy guard compatibility that still remains active
- CLI failure modes
- output rendering

It does not test Flutter or app behavior.

## Test Areas

### `tools/guard/tests/core/`

Engine-layer tests:

- `test_scope_config.py`
  - config-driven scope parsing
  - fallback scope synthesis
  - layer detection config
  - invalid scope config rejection
- `test_file_scanner.py`
  - include/exclude handling
  - extension filtering
  - scope root filtering
- `test_rule_executor.py`
  - normalized rule schema validation
  - generic rule execution for `forbidden_pattern`, `file_naming`,
    `content_contract`, and `path_requirements`
- `test_guard_registry.py`
  - normalized vs legacy runtime dispatch
  - guard inventory behavior
- `test_reporter.py`
  - golden-style snapshots for JSON, Markdown, and plain terminal output

### `tools/guard/tests/global_guards/`

Focused regression coverage for still-supported global behavior and normalized
replacements that used to be one-off guards.

### `tools/guard/tests/local_guards/`

Focused regression coverage for MemoX policy behavior and remaining legacy local
guards.

### Top-level tests

- `test_cli.py`
  - policy selection
  - scope and guard selection errors
  - config/rules override behavior
  - invalid YAML and invalid schema failures
  - CLI output snapshots where useful
- `test_policy_loading.py`
  - loading the real MemoX policy and project rules

## Running the Suite

Run the whole guard suite:

```bash
python -m pytest tools/guard/tests
```

Run a focused subset while iterating:

```bash
python -m pytest tools/guard/tests/test_cli.py
python -m pytest tools/guard/tests/core/test_rule_executor.py
python -m pytest tools/guard/tests/core/test_reporter.py
```

Run the actual guard CLI after test changes:

```bash
python tools/guard/run.py --scope all --quiet
```

## Golden-Style Tests

Golden-style expected-result tests live in:

- `tools/guard/tests/core/test_reporter.py`
- selected CLI snapshot assertions in `tools/guard/tests/test_cli.py`

Keep these snapshots:

- small
- deterministic
- based on fixed in-memory results or stable policy output

Avoid large repository-dependent snapshots.

## Adding New Tests

When changing the guard system:

1. add engine tests for generic behavior changes
2. add CLI tests for new flags or failure paths
3. add policy regression tests if MemoX defaults are affected
4. add or update output snapshots only when the output contract changed

Prefer small temp-directory fixtures over large on-disk setups.

## Minimum Regression Checks

For refactor work in `tools/guard`, the baseline validation is:

```bash
python -m pytest tools/guard/tests
python tools/guard/run.py --scope all --quiet
```

If repo rules require broader verification, run those after the guard-specific
checks and report any unrelated pre-existing failures separately.
