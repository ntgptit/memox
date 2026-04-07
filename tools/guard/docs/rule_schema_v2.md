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

    # content_contract fields
    messages:
      missing_file: "File bắt buộc `{file}` đang bị thiếu."
      missing_required_token: "`{file_name}` thiếu token `{token}`."
      aggregate_missing_required_tokens: "`{file_name}` thiếu {tokens}."
      missing_required_any_tokens: "`{file_name}` must contain one of {tokens}."
      missing_required_pattern: "`{file_name}` thiếu pattern `{pattern}`."
      forbidden_token: "`{file_name}` chứa token `{token}`."
      forbidden_pattern: "`{file_name}` contains a forbidden pattern."
    cases:
      - file: "lib/app.dart"           # exact repo-relative file
        required_tokens:
          - "MediaQuery("
      - path_patterns:                 # source-path-like globs matched against repo-relative paths
          - "features/*/presentation/screens/*_screen.dart"
        required_any_tokens:
          - "AppScaffold("
          - "SliverScaffold("
        forbidden_patterns:
          - regex: '\bScaffold\('

    # path_requirements fields
    entries:
      - path: "lib/core"              # exact repo-relative path
        path_kind: dir                # any|file|dir
        messages:
          missing_path: "Thư mục bắt buộc bị thiếu: {path}"
      - path_template: "lib/features/{feature}/{layer}"
        path_kind: dir
        variables:
          feature: ["search"]
          layer: ["data", "domain", "presentation"]
        messages:
          missing_path: "{feature}/ thiếu layer {layer}/"
      - path: "lib/features/search/domain/usecases"
        path_kind: dir
        must_exist: false
        contains_glob: "*.dart"
        messages:
          empty_path: "search/domain/usecases đang rỗng."
```

---

## Rule types

| `type` value | Behaviour |
|---|---|
| `forbidden_pattern` | For each scanned file, checks every non-excluded line against one or more regex patterns. Emits one `Violation` per matching line (first matching pattern wins). |
| `file_naming` | For each scanned file, tests the filename against `naming_pattern`. Emits one `Violation` per non-matching filename. |
| `content_contract` | Checks exact files or path-pattern-matched files for required tokens, any-of token presence, required regex matches, and forbidden tokens or patterns. |
| `path_requirements` | Checks exact paths or template-expanded paths for existence, kind (`file`/`dir`), and optional non-empty content via `contains_glob`. |

---

## Target matching

The `targets.include` and `targets.exclude` lists are validated as
`list[str]` and apply consistently to normalized rules:

- `forbidden_pattern`
- `file_naming`
- `content_contract`
- `path_requirements`

The matching behavior supports two modes:

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

See [generic_guard_migration.md](/D:/workspace/memox/tools/guard/docs/generic_guard_migration.md)
for the current migrated guard inventory, behavior clustering, and remaining
legacy guards.

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

Example — enforce a file contract:

```yaml
  - id: app_shell_contract
    type: content_contract
    name: App shell contract
    description: App root must apply text scaling.
    scope: local
    messages:
      aggregate_missing_required_tokens: "`{file_name}` thiếu {tokens}."
    cases:
      - file: "lib/app.dart"
        required_tokens:
          - "MediaQuery("
          - "TextScaler.linear("
```

Example — enforce path structure:

```yaml
  - id: feature_structure
    type: path_requirements
    name: Feature structure
    description: Required feature directories must exist.
    scope: local
    entries:
      - path_template: "lib/features/{feature}/{layer}"
        path_kind: dir
        variables:
          feature: ["search", "study"]
          layer: ["data", "domain", "presentation"]
        messages:
          missing_path: "{feature}/ thiếu layer {layer}/"
```

---

## Engine files

| File | Purpose |
|---|---|
| `core/rule_schema.py` | `RuleType`, `PatternEntry`, `RuleTargets`, `NormalizedRule`, `validate_rule()`, `parse_rules()` |
| `core/rule_executor.py` | `RuleExecutor` — loads and runs normalized rules, returns `GuardResult` list |
| `core/guard_registry.py` | Instantiates `RuleExecutor`; skips legacy guard classes whose `GUARD_ID` is in `executor.rule_ids` |
