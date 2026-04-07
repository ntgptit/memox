# Message Catalog v1

Date: 2026-04-07

## Purpose

Phase 2 introduces a config-driven message and remediation catalog for
`tools/guard`.

The goal is to move user-facing finding text out of Python guard logic where the
pattern is reusable, while keeping existing literal-message guards working
during migration.

## Top-level policy schema

Catalogs live in `policy.yaml`.

```yaml
message_catalog:
  no_else.forbidden_else:
    template: "Use early return, guard clause, or switch expression instead of else."
    suggestion: "Return from the exceptional branch first."
    remediation_id: "use_early_return"
    docs_ref: "rules/no_else"

remediation_catalog:
  use_early_return:
    title: "Remove else branch"
    summary: "Prefer a guard clause or early return over an else branch."
    manual_steps:
      - "Return from the exceptional branch first."
      - "Keep the main path at the base indentation level."
```

## Catalog entry shape

### `message_catalog`

Each message entry is keyed by a message code.

Required:

- `template`

Optional:

- `suggestion`
- `remediation_id`
- `docs_ref`

### `remediation_catalog`

Each remediation entry is keyed by a remediation id.

At least one of these must be present:

- `title`
- `summary`
- `suggestion`
- `manual_steps`

## Rule-level message codes

Normalized rules now support additive message-code fields while keeping the
existing literal-message fields as fallbacks.

### `forbidden_pattern`

```yaml
patterns:
  - regex: '\belse\b'
    message_code: "no_else.forbidden_else"
    message: "Use early return, guard clause, or switch expression instead of else."
```

### `file_naming`

```yaml
naming_message_code: "naming_convention.invalid_file_name"
naming_message: "File name must follow snake_case."
```

### `content_contract` and `path_requirements`

Message maps support parallel `*_code` keys:

```yaml
messages:
  missing_required_any_tokens_code: "screen_scaffold.required_shared_scaffold"
  missing_required_any_tokens: "Screen phải dùng AppScaffold hoặc SliverScaffold, không dùng raw Scaffold."
```

Supported code keys:

- `missing_file_code`
- `missing_required_token_code`
- `aggregate_missing_required_tokens_code`
- `missing_required_any_tokens_code`
- `missing_required_pattern_code`
- `forbidden_token_code`
- `forbidden_pattern_code`
- `missing_path_code`
- `empty_path_code`

## Legacy guard migration path

Legacy guards can migrate incrementally through `BaseGuard.create_violation(...)`.

New preferred pattern:

```python
self.create_violation(
    file_path=relative,
    line_number=index,
    line_content=line,
    message_code='icon_style.prefer_outlined',
    message='Icons.{icon_name} → dùng Icons.{icon_name}_outlined nếu có.',
    message_args={'icon_name': icon_name},
)
```

That keeps:

- rendered `Violation.message`
- `Violation.message_ref`
- `Violation.message_args`
- `Violation.suggestion`
- `Violation.remediation`
- `Violation.docs_ref`

## Resolution behavior

Resolution order is:

1. look up `message_code` in `message_catalog`
2. render `template` with `message_args`
3. attach optional suggestion, remediation, and docs metadata
4. if the code is missing and a literal fallback message exists, use the literal
   fallback
5. if the code is missing and no fallback exists, emit a clear placeholder
   message

This means missing catalog entries degrade gracefully at runtime, while invalid
catalog structure fails during config loading.

## Validation behavior

Config loading now fails clearly when:

- `message_catalog` is not a mapping
- `remediation_catalog` is not a mapping
- a message entry is missing `template`
- a remediation entry is empty
- a message entry references an unknown remediation id

## Representative migrated guards

This step migrates a representative subset:

- normalized rules:
  - `no_else`
  - `naming_convention`
  - `button_usage`
  - `l10n_source`
  - `screen_scaffold`
  - `touch_target`
- legacy guards:
  - `icon_style`
  - `import_direction`
  - `srs_field`

Other guards may continue emitting literal messages until they are migrated.

## Intentionally deferred

This step does **not** add:

- multi-language message catalogs
- formatter-specific rendering of remediation blocks
- autofix execution
- suppression behavior
- baseline behavior
- broad report redesign
