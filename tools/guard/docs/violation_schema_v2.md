# Violation Schema v2

Date: 2026-04-07

## Purpose

`tools/guard/core/guard_result.py` now defines the canonical finding model for
guard output.

Phase 2 starts by making `Violation` the normalized schema used by:

- normalized rules
- legacy guard compatibility paths
- `GuardResult`
- JSON, Markdown, and terminal reporting

This is an additive migration. Existing MemoX guard behavior stays intact while
the result model grows enough to support later phase-2 work.

## Canonical objects

### `Violation`

`Violation` is the canonical schema for a single guard finding.

Required legacy-stable fields:

- `file_path`
- `line_number`
- `line_content`
- `message`
- `guard_id`
- `severity`
- `scope`

New normalized v2 fields:

- `schema_version`
- `rule_id`
- `violation_code`
- `category`
- `column_number`
- `end_line_number`
- `end_column_number`
- `symbol`
- `entity`
- `message_ref`
- `message_args`
- `suggestion`
- `remediation`
- `docs_ref`
- `autofix`
- `suppression`
- `source`

### `GuardResult`

`GuardResult` remains the per-guard result envelope and now carries:

- `result_schema_version`
- normalized `Violation` instances in `violations`

## Field reference

| Field | Type | Required | Notes |
|---|---|---|---|
| `schema_version` | `int` | yes | Canonical violation schema version. Current value: `2`. |
| `rule_id` | `str` | yes | Canonical rule identifier. Defaults to `guard_id` during compatibility adaptation. |
| `guard_id` | `str` | yes | Legacy-stable identifier kept for compatibility. |
| `violation_code` | `str` | yes | Machine-readable code for the specific violation. Defaults to `rule_id`. |
| `severity` | `error|warning|info` | yes | Existing enum values are unchanged in this step. |
| `category` | `str \| None` | no | Taxonomy placeholder. Normalized rules currently use the normalized rule type. |
| `scope` | `global|local` | yes | Existing scope model, unchanged. |
| `file_path` | `str` | yes | Repo-relative or synthetic path such as `<internal>`. |
| `line_number` | `int` | yes | `0` is allowed for synthetic internal runtime failures. |
| `column_number` | `int \| None` | no | Start column when known. |
| `end_line_number` | `int \| None` | no | End line when known. |
| `end_column_number` | `int \| None` | no | End column when known. |
| `symbol` | `str \| None` | no | Optional symbol or identifier involved in the finding. |
| `entity` | `str \| None` | no | Optional higher-level entity name. |
| `message` | `str` | yes | Rendered user-facing message. Remains mandatory in phase 2. |
| `message_ref` | `str \| None` | no | Placeholder for future message-catalog ids. |
| `message_args` | `dict[str, object]` | yes | Placeholder for future catalog interpolation. Defaults to `{}`. |
| `suggestion` | `str \| None` | no | Short rendered guidance placeholder. |
| `remediation` | `dict[str, object] \| None` | no | Placeholder for future remediation catalog metadata. |
| `docs_ref` | `str \| None` | no | Placeholder for docs mapping. |
| `autofix` | `dict[str, object] \| None` | no | Placeholder for future autofix contract metadata. |
| `suppression` | `dict[str, object] \| None` | no | Placeholder for future suppression metadata. |
| `source` | `normalized|legacy|internal` | yes | Indicates where the finding came from. |

## Canonical construction paths

Use these helpers instead of building ad hoc result shapes:

- `Violation.create(...)`
  - primary constructor for new code
- `Violation.from_dict(...)`
  - parses legacy or normalized mapping payloads
- `Violation.ensure(...)`
  - accepts either a `Violation` or a mapping and returns a normalized
    `Violation`
- `Violation.internal_error(...)`
  - canonical synthetic finding for guard runtime failures

`GuardResult` normalizes every item in `violations` through
`Violation.ensure(...)` during initialization.

## Compatibility rules

### Legacy guards

Legacy guards can keep returning direct `Violation(...)` instances.

Compatibility behavior:

- missing `rule_id` is normalized to `guard_id`
- missing `violation_code` is normalized to `rule_id`
- missing `source` defaults to `legacy`
- existing fields and `location` keep working

### Normalized rules

Normalized rule execution now uses `Violation.create(...)` and sets:

- `source = normalized`
- `rule_id = <rule id>`
- `violation_code = <rule id>`
- `category = <normalized rule type>`

### Internal runtime failures

Guard crashes are still surfaced as findings for compatibility, but they now go
through `Violation.internal_error(...)` and are marked with:

- `source = internal`
- `category = internal_error`
- `violation_code = <guard_id>.internal_error`

## JSON shape

`Violation.to_dict()` keeps the legacy keys and adds the new v2 fields.

Example:

```json
{
  "schema_version": 2,
  "rule_id": "no_else",
  "guard_id": "no_else",
  "violation_code": "no_else",
  "severity": "error",
  "category": "forbidden_pattern",
  "scope": "global",
  "file_path": "lib/foo.dart",
  "line_number": 3,
  "column_number": null,
  "end_line_number": null,
  "end_column_number": null,
  "location": "lib/foo.dart:3",
  "symbol": null,
  "entity": null,
  "message": "Use early return instead of else.",
  "message_ref": null,
  "message_args": {},
  "suggestion": null,
  "remediation": null,
  "docs_ref": null,
  "autofix": null,
  "suppression": null,
  "line_content": "} else {",
  "source": "normalized"
}
```

## Intentionally deferred

This step does **not** implement:

- message catalog lookup
- severity-policy redesign beyond the current enum
- autofix execution
- suppression behavior
- baseline behavior
- formatter redesign beyond consuming the normalized schema

Those remain later phase-2 slices.
