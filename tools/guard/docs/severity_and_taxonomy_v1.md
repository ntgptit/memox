# Severity And Taxonomy v1

Date: 2026-04-07

This document defines the normalized severity model and taxonomy model for
`tools/guard`.

The goal of this step is narrow:

- keep the existing `error|warning|info` severity contract stable
- make taxonomy/category values finite and validated
- let policy config classify findings without hardcoding MemoX semantics in the
  reusable engine
- preserve compatibility for legacy guards during migration

## Severity model

Severity remains a finite enum:

- `error`
- `warning`
- `info`

There are no new severity levels in v1.

### Sources of severity

Severity can come from:

1. normalized rule `severity`
2. legacy guard `DEFAULT_SEVERITY`
3. top-level `severity_overrides` in `policy.yaml`

Override precedence is unchanged:

- `severity_overrides.<guard_or_rule_id>` wins
- otherwise the rule or guard default is used

## Taxonomy model

`Violation.category` is now a validated taxonomy value.

Allowed values in v1:

- `style`
- `structure`
- `naming`
- `design_system`
- `dependency`
- `state_management`
- `data_contract`
- `database_contract`
- `i18n`
- `testing`
- `performance`
- `security`
- `internal`

Notes:

- `internal` is reserved for tool/runtime guard failures surfaced as synthetic
  violations for compatibility.
- `category` is the preferred field name.
- `taxonomy` is accepted as a compatibility alias in rule config and violation
  input payloads.

## Policy config

Top-level policy overrides can classify both normalized rules and legacy guard
IDs:

```yaml
category_overrides:
  no_else: style
  naming_convention: naming
  import_direction: dependency
  riverpod_syntax: state_management
  drift_table: database_contract
```

`taxonomy_overrides` is also accepted as an alias. If both are present,
`category_overrides` takes precedence for duplicate IDs.

Invalid values fail fast during CLI/runtime loading.

## Normalized rule config

Normalized rules may classify themselves directly:

```yaml
rules:
  - id: naming_convention
    type: file_naming
    severity: warning
    category: naming
```

Compatibility alias:

```yaml
rules:
  - id: naming_convention
    type: file_naming
    taxonomy: naming
```

If both `category` and `taxonomy` are provided, they must match.

## Effective category precedence

The effective violation category is resolved in this order:

1. top-level `category_overrides` / `taxonomy_overrides`
2. normalized rule `category` / `taxonomy`
3. legacy guard `CATEGORY` class var if provided
4. `None` when no classification is available

MemoX policy now classifies its active rules and guards through
`category_overrides`, so default MemoX findings should carry a normalized
category consistently.

## Legacy guard compatibility

Many legacy guards still construct `Violation(...)` directly.

To avoid a risky rewrite, `BaseGuard.create_result(...)` now backfills the
configured default category onto any legacy violation that did not set one
explicitly.

That means:

- migrated legacy guards can emit `category` directly
- untouched legacy guards still inherit policy classification safely

## Violation schema impact

`Violation.severity` remains unchanged.

`Violation.category` is now validated against the finite taxonomy set above.

Examples:

```python
Violation.create(
    file_path='lib/foo.dart',
    message='Use early return instead of else.',
    guard_id='no_else',
    severity='error',
    category='style',
)
```

```python
Violation.internal_error(
    guard_id='no_else',
    scope='global',
    error='boom',
)
```

The internal error example emits:

- `severity = error`
- `category = internal`
- `violation_code = <guard_id>.internal_error`

## Validation behavior

These now fail fast:

- invalid normalized rule `severity`
- invalid normalized rule `category` / `taxonomy`
- invalid `severity_overrides`
- invalid `category_overrides` / `taxonomy_overrides`
- invalid `Violation.category`

CLI-facing config errors are surfaced as:

- `Invalid normalized rule schema ...`
- `Invalid severity/category configuration ...`

## MemoX classification baseline

MemoX policy currently classifies guards into repo-relevant concern groups such
as:

- `design_system`
- `i18n`
- `dependency`
- `state_management`
- `database_contract`
- `testing`
- `performance`
- `structure`
- `naming`
- `style`

This is intentionally conservative. It standardizes current findings without
reclassifying the broader platform beyond what MemoX already uses.

## Intentionally deferred

This step does not introduce:

- new severity levels beyond `error|warning|info`
- confidence scoring
- impact scoring
- exit-policy changes
- reporting/dashboard redesign
- a broad audit-driven reclassification of every possible future rule

Those remain later phase-2 work if the current taxonomy proves insufficient.
