# Guard tool — normalized rule schema (v2)

This document describes the config-driven rule schema introduced in Phase 4 of
the guard tool refactor.  Guards migrated to this schema no longer require a
Python class file — their entire logic is driven by a YAML entry in the policy's
`rules:` list.

---

## Why

Before this change each guard was an independent Python class that hardcoded its
own patterns, whitelists, and severity.  Moving those values into YAML means:

- Adding a new simple rule requires **no Python code**.
- Changing a pattern, severity, or target path is a single-line YAML edit.
- Policy authors can see all rule data in one place.

Complex guards that require multi-file analysis or stateful logic continue to
live as Python classes (see *Still legacy* section below).

---

## Schema reference

Rules are declared under the top-level `rules:` key in `policy.yaml`.

```yaml
rules:
  - id: <string>              # unique, matches GUARD_ID convention
    type: <rule_type>         # see RuleType enum below
    name: <string>            # human-readable label
    description: <string>     # one-sentence description
    severity: error|warning|info   # default: error
    scope: global|local            # default: global
    enabled: true|false            # default: true

    # forbidden_pattern fields
    skip_comments: true|false      # default: true — skip // and /// lines
    literal_skip:                  # skip lines containing any of these strings verbatim
      - '"else"'
    targets:
      include:                     # if non-empty, only files matching any entry are checked
        - "features/**/screens/*.dart"
      exclude:                     # files matching any entry are skipped
        - "test/"
        - "*.g.dart"
    patterns:
      - regex: '\belse\b'
        message: "Use early return instead of else."

    # file_naming fields
    naming_pattern: '^[a-z0-9_]+\.dart$'
    naming_message: "File name must follow snake_case."
```

---

## Rule types

| `type` value | Behaviour |
|---|---|
| `forbidden_pattern` | For each scanned file, checks every non-excluded line against one or more regex patterns. Emits one `Violation` per matching line (first matching pattern wins). |
| `file_naming` | For each scanned file, tests the filename against `naming_pattern`. Emits one `Violation` per non-matching filename. |

---

## Target matching

The `targets.include` and `targets.exclude` lists support two matching modes:

| Pattern shape | How it matches |
|---|---|
| Contains `*` or `?` | Glob match via `PurePosixPath.match()` against the repo-relative path |
| No glob chars | Substring match (`pattern in relative_path`) |

Examples:

```yaml
targets:
  exclude:
    - "test/"            # substring — matches any path containing "test/"
    - "*.g.dart"         # glob     — matches any file ending in .g.dart
    - "*.freezed.dart"   # glob
  include:
    - "features/**/screens/*.dart"   # glob — only screen files in any feature
```

---

## Severity overrides

Severity can be overridden globally via the `severity_overrides` map in
`policy.yaml`, which takes precedence over the rule's `severity` field:

```yaml
severity_overrides:
  no_else: warning   # downgrade from error to warning for this project
```

---

## Migration status

### Fully migrated (Python class removed)

| Guard ID | Type | Scope | Notes |
|---|---|---|---|
| `no_else` | `forbidden_pattern` | global | `literal_skip` prevents false positives on string literals `"else"` / `'else'` |
| `l10n` | `forbidden_pattern` | global | Excludes `test/` and `lib/core/constants/` |
| `async_builder` | `forbidden_pattern` | global | Excludes `app_async_builder.dart` and `test/` |
| `legacy_state_notifier` | `forbidden_pattern` | local | 3 patterns; excludes `test/`, `*.g.dart`, `*.freezed.dart`. Data removed from `rules.yaml`. |
| `naming_convention` | `file_naming` | global | |

### Still legacy (Python class)

All remaining guards in `global_guards/` and `local_guards/` continue to run as
Python classes.  These guards involve logic that cannot be expressed by the
current two rule types — multi-file analysis, threshold comparisons, structural
inspection, or config-key lookups into `rules.yaml`.

Representative examples:

| Guard | Reason for keeping as Python |
|---|---|
| `folder_structure_guard` | Checks directory existence, not file content |
| `design_token_usage_guard` | Whitelist of class names read from `rules.yaml` |
| `performance_contract_guard` | Per-file required/forbidden token lists from `rules.yaml` |
| `drift_table_guard` | Column presence check across multiple files |
| `color_palette_guard` | Validates hex literals against an approved palette |

---

## How to add a new config-driven rule

1. Add an entry to the `rules:` list in `policies/memox/policy.yaml`.
2. Run the guard tool — the rule is active immediately.
3. No Python file is needed.

Example — forbid `print(` statements outside tests:

```yaml
  - id: no_print
    type: forbidden_pattern
    name: No print statements
    description: Use a logger instead of print().
    severity: warning
    scope: global
    enabled: true
    skip_comments: true
    targets:
      exclude:
        - "test/"
    patterns:
      - regex: '\bprint\('
        message: "Use a logger instead of print()."
```

---

## Engine files

| File | Purpose |
|---|---|
| `core/rule_schema.py` | `RuleType`, `PatternEntry`, `RuleTargets`, `NormalizedRule`, `validate_rule()`, `parse_rules()` |
| `core/rule_executor.py` | `RuleExecutor` — loads and runs normalized rules, returns `GuardResult` list |
| `core/guard_registry.py` | Instantiates `RuleExecutor`; skips legacy guard classes whose `GUARD_ID` is in `executor.rule_ids` |
