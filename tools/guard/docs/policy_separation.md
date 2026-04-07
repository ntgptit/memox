# Guard tool — engine / policy separation

This document explains the structural split between the reusable guard engine and
MemoX-specific policy that was introduced in this refactor step.

---

## Why

The guard tool started as a MemoX-specific framework.  Project-specific decisions
(which rules are enabled, what the folder structure must look like, which design
tokens are allowed) were baked into the tool's root config files and, partially,
into engine code.

The goal of this refactor is to make the engine reusable: a second project should
be able to define its own policy directory and run the same engine against a
completely different codebase without modifying any Python code.

---

## Directory layout (after refactor)

```
tools/guard/
├── run.py                         # CLI entry point — policy-agnostic
├── requirements.txt
│
├── core/                          # Reusable engine
│   ├── base_guard.py
│   ├── guard_family.py
│   ├── guard_registry.py
│   ├── guard_result.py
│   ├── path_constants.py          # ScopeDefinition + config-driven path resolution
│   ├── file_scanner.py
│   └── reporter.py
│
├── global_guards/                 # Guard library — Dart/Flutter conventions
│   ├── family.py
│   └── *.py
│
├── local_guards/                  # Guard library — MemoX project conventions
│   ├── family.py
│   └── *.py
│
├── policies/                      # Project-specific data (no engine code here)
│   └── memox/
│       ├── policy.yaml            # ← was tools/guard/config.yaml
│       └── rules.yaml             # ← was tools/guard/project_rules.yaml
│
├── docs/
│   ├── policy_separation.md       # this file
│   ├── config_scopes_paths.md
│   └── refactor_plan_v2.md
│
└── tests/
    ├── core/
    ├── global_guards/
    └── local_guards/
```

---

## What "engine" means

The engine is everything under `core/`.  It knows how to:

- Parse a config dict into `PathConstants` (including scope definitions).
- Discover and instantiate guard classes via `GuardFamily`.
- Run guards against a scanned file list via `GuardRegistry`.
- Format and output results via `Reporter`.

The engine has **no knowledge of MemoX**, Dart, Flutter, or any project's folder
conventions.  The only external assumption that remains is the `'.dart'` fallback
in `language_extensions` — this is a documentation-level default, overridden by
every policy file.

---

## What "policy" means

A policy is a directory containing exactly two YAML files:

| File | Purpose |
|------|---------|
| `policy.yaml` | Runtime configuration: paths, scopes, extensions, guard enable/disable map, severity overrides, thresholds. |
| `rules.yaml` | Domain rules: required structures, forbidden patterns, design-system contracts, widget mappings, database schemas. |

Guards read from both files through `self.config` (from `policy.yaml`) and
`self.project_rules` (from `rules.yaml`).

---

## What changed in engine code

### `run.py`

- Added `--policy DIR` argument (default: `tools/guard/policies/memox`).
- The loader resolves `policy.yaml` and `rules.yaml` from the policy directory.
- `--config FILE` and `--rules FILE` remain as explicit per-file overrides that
  take precedence over the policy directory.
- The description string no longer says "MemoX".

### `core/base_guard.py`

The `is_enabled` property previously contained hardcoded `'global_guards'` and
`'local_guards'` string literals.  These are now derived from the guard's own
`SCOPE` enum value:

```python
# before
family_key = 'global_guards'
if self.SCOPE == GuardScope.LOCAL:
    family_key = 'local_guards'

# after
family_key = f'{self.SCOPE.value}_guards'
```

`GuardScope.GLOBAL.value == 'global'` → key `'global_guards'`
`GuardScope.LOCAL.value  == 'local'`  → key `'local_guards'`

The enablement lookup is now driven entirely by the policy file's guard maps,
with no string literals in engine code.

---

## CLI usage

### Default (MemoX)

```bash
python tools/guard/run.py --scope all
python tools/guard/run.py --scope core
python tools/guard/run.py --scope features
```

These work unchanged — the default `--policy` points to `tools/guard/policies/memox`.

### Explicit policy

```bash
python tools/guard/run.py --policy tools/guard/policies/memox --scope all
```

### File-level overrides

```bash
# Use a custom config but the standard MemoX rules
python tools/guard/run.py --config my_config.yaml

# Use a different policy directory entirely
python tools/guard/run.py --policy tools/guard/policies/other_project --scope all
```

### Migration from old explicit --config / --rules flags

| Old command | New equivalent |
|---|---|
| `--config tools/guard/config.yaml` | (drop the flag; default policy covers it) |
| `--rules tools/guard/project_rules.yaml` | (drop the flag; default policy covers it) |
| `--config tools/guard/config.yaml --rules tools/guard/project_rules.yaml` | (drop both; or `--policy tools/guard/policies/memox`) |

---

## Adding a second policy

To run the guard engine on a different project:

1. Create `tools/guard/policies/<your-project>/` directory.
2. Copy `tools/guard/policies/memox/policy.yaml` and adjust paths, scopes, guard
   enablement, and thresholds for your project.
3. Copy `tools/guard/policies/memox/rules.yaml` and replace the MemoX-specific
   domain rules with your project's rules.
4. Run:

   ```bash
   python tools/guard/run.py --policy tools/guard/policies/<your-project> --scope all
   ```

No Python code changes are required.  The guard implementations in `global_guards/`
and `local_guards/` will run as-is; guards that rely on MemoX-specific rule keys
will simply find empty data and produce no violations for a project that doesn't
populate those keys.

---

## Remaining limitations (next refactor steps)

The guard *implementations* in `global_guards/` and `local_guards/` still contain
MemoX-specific assumptions:

- Hardcoded whitelist paths (e.g. `lib/shared/widgets/`, `lib/core/theme/`)
- Hardcoded widget/class names (e.g. `AppCard`, `AppScaffold`)
- Hardcoded token class names (e.g. `ColorTokens`, `SpacingTokens`)

These are tracked in `docs/refactor_plan_v2.md` Phase 1 and would be addressed in
the next refactor step by moving those constants into `policy.yaml` and having
guards read from `self.project_rules` / `self.config` instead.

The guard discovery mechanism in `core/guard_family.py` is also currently locked
to `global_guards/` and `local_guards/` as sibling directories of `core/`.  A
future extension could allow a policy to declare additional guard directories,
enabling policy-specific guard implementations without modifying the engine.
