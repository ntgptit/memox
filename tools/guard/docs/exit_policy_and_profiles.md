# Exit Policy And Profiles

Date: 2026-04-07

This document defines the phase-2 exit-policy and rule-profile model for
`tools/guard`.

The goal of this step is narrow:

- make exit behavior policy-driven
- make profile overlays explicit and config-based
- preserve current MemoX default behavior when no profile is selected
- keep `--fail-on-warnings` as a compatibility override

## Design summary

Execution now has two separate policy layers:

1. rule profile overlay
2. exit policy evaluation

Rule profiles change configuration before guards run.

Exit policy evaluates normalized `GuardResult` output after guards run.

That separation keeps:

- rule selection and severity tuning in profile config
- process exit behavior in exit policy config

## Exit policy model

Exit policies live under the top-level `exit_policy` block in `policy.yaml`.

Example:

```yaml
exit_policy:
  default:
    description: "Compatibility default: fail on errors only."
    fail_on:
      - error
  strict:
    description: "Strict mode: fail on both errors and warnings."
    fail_on:
      - error
      - warning
```

### Allowed fields

Each exit policy entry currently supports:

- `description`
- `fail_on`

`fail_on` must be a list containing only:

- `error`
- `warning`
- `info`

Empty lists are allowed and mean the policy never fails on findings.

### Compatibility default

If no profile is selected, runtime uses the legacy-compatible default behavior:

- fail on `error`
- do not fail on `warning`
- do not fail on `info`

That remains true even if `policy.yaml` defines named exit policies, unless an
explicit profile selects one.

## Rule profile model

Rule profiles live under the top-level `rule_profiles` block in `policy.yaml`.

Example:

```yaml
rule_profiles:
  default:
    description: "Explicit alias for the current MemoX default behavior."
    exit_policy: default

  strict:
    description: "Promote structure drift and fail on warning-tier findings."
    exit_policy: strict
    severity_overrides:
      folder_structure: warning

  ci:
    description: "CI preset aligned with strict guard enforcement."
    extends: strict

  legacy_migration:
    description: "Reduce style-oriented noise during incremental migrations."
    exit_policy: default
    global_guards:
      icon_style: false
    local_guards:
      feature_completeness: false
```

### Supported profile fields

Profiles can currently override:

- `description`
- `extends`
- `exit_policy`
- `global_guards`
- `local_guards`
- `severity_overrides`
- `category_overrides`
- `taxonomy_overrides`

### Merge behavior

Profiles merge parent-to-child when `extends` is used.

Current merge rules:

- child scalar values override parent scalar values
- child maps overlay parent maps
- child `exit_policy` overrides parent `exit_policy`

### Validation

Config validation now fails fast for:

- unknown selected profile
- profile inheritance cycles
- invalid profile severity/category override values
- invalid exit policy definitions
- profile references to unknown exit policies

## CLI behavior

### `--profile`

Selects a named rule profile:

```bash
python tools/guard/run.py --policy memox --profile strict --scope all
```

### `--list-profiles`

Lists profiles defined by the selected policy:

```bash
python tools/guard/run.py --policy memox --list-profiles
```

### `--fail-on-warnings`

This remains a compatibility flag.

It now acts as a runtime override on top of the resolved exit policy by adding
`warning` to the policy's `fail_on` set.

That means:

- existing usage still works
- exit behavior is still centralized in one exit-policy evaluator

## MemoX profiles

MemoX currently defines these explicit profiles:

- `default`
  - explicit alias for current behavior
- `strict`
  - uses strict exit policy
  - promotes `folder_structure` from `info` to `warning`
- `ci`
  - extends `strict`
  - intended for repository CI enforcement
- `legacy_migration`
  - keeps default exit behavior
  - disables selected non-critical style/noise checks during migrations

MemoX does **not** currently define a separate `release` profile because there
is no distinct release-only enforcement contract in the current repo.

## Runtime flow

The current runtime order is:

1. load `policy.yaml`
2. parse and validate all rule profiles
3. parse and validate all exit policies
4. validate profile exit-policy references
5. apply the selected profile overlay, if any
6. construct registry and run guards
7. evaluate the resolved exit policy against normalized results

This keeps exit behavior separate from formatter and execution internals.

## Intentional limits

This step does not implement:

- suppression-aware exit policy
- baseline-aware exit policy
- direct `--exit-policy` CLI override
- autofix-aware policy decisions
- release-channel-specific logic outside explicit profiles

Those remain later extensions if the repo actually needs them.
