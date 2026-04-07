# Generic Guard Migration

Date: 2026-04-07

## Goal

Move repeated guard behaviors out of one-off MemoX guard classes and into a
small set of reusable generic rule types, without forcing a big-bang rewrite.

The runtime boundary is now:

- generic rule engine in [tools/guard/core/rule_schema.py](/D:/workspace/memox/tools/guard/core/rule_schema.py) and [tools/guard/core/rule_executor.py](/D:/workspace/memox/tools/guard/core/rule_executor.py)
- MemoX rule definitions in [tools/guard/policies/memox/policy.yaml](/D:/workspace/memox/tools/guard/policies/memox/policy.yaml)
- MemoX-only legacy rule data in [tools/guard/policies/memox/rules.yaml](/D:/workspace/memox/tools/guard/policies/memox/rules.yaml)

Legacy guard classes are still present, but any class whose `GUARD_ID` now
exists in normalized policy rules is skipped by the registry at runtime.

## Behavior Clusters

### 1. Line-based token or pattern bans

These are simple per-line scans with optional comment skipping and path
targeting.

- `no_else`
- `l10n`
- `async_builder`
- `legacy_state_notifier`
- `no_hardcoded_color`
- `no_hardcoded_duration`
- `no_hardcoded_font_size`
- `no_hardcoded_radius`
- `no_hardcoded_size`
- `no_hardcoded_string`
- `shared_widget`
- `button_usage`
- `l10n_source`
- `text_style`

Generic type: `forbidden_pattern`

### 2. Whole-file contract checks

These rules assert that a file or a path-matched set of files contains required
tokens, contains at least one token from a set, matches required regex
contracts, or avoids forbidden content.

- `performance_contract`
- `responsive_text_scale`
- `screen_scaffold`
- `touch_target`
- `typography_scale`

Generic type: `content_contract`

### 3. Project path and structure requirements

These rules assert that paths exist, that directory kinds match, and that
selected directories contain at least one file matching a glob.

- `folder_structure`
- `feature_completeness`

Generic type: `path_requirements`

### 4. Naming conventions

- `naming_convention`

Generic type: `file_naming`

### 5. Still too specific for now

These guards still need dedicated Python because they do multi-file correlation,
inspect symbol semantics, or parse project-specific structure in a way that
does not yet fit the normalized schema cleanly.

See the "Remaining Legacy Guards" table below.

## Generic Rule Types

### `forbidden_pattern`

Existing generic type. Best for:

- forbidden token
- forbidden regex
- per-line path-scoped bans

### `file_naming`

Existing generic type. Best for:

- filename naming conventions

### `content_contract`

New generic type. Best for:

- required token presence
- required any-of token presence
- forbidden token presence
- required regex contract presence
- forbidden regex contract presence
- exact-file contract checks
- path-pattern-enforced contract checks

### `path_requirements`

New generic type. Best for:

- file existence or directory existence
- path-kind enforcement (`file` vs `dir`)
- directory non-empty checks via `contains_glob`
- template-expanded path matrices for repeated structure rules

## Migrated Guards

### Migrated before this step

| Guard ID | Generic type |
|---|---|
| `no_else` | `forbidden_pattern` |
| `l10n` | `forbidden_pattern` |
| `async_builder` | `forbidden_pattern` |
| `legacy_state_notifier` | `forbidden_pattern` |
| `naming_convention` | `file_naming` |

### Migrated in this step

| Guard ID | Previous behavior cluster | Generic type | Config source |
|---|---|---|---|
| `button_usage` | line-based token ban | `forbidden_pattern` | `policy.yaml` |
| `l10n_source` | line-based token ban | `forbidden_pattern` | `policy.yaml` |
| `text_style` | line-based pattern ban | `forbidden_pattern` | `policy.yaml` |
| `no_hardcoded_color` | line-based token/pattern ban | `forbidden_pattern` | `policy.yaml` |
| `no_hardcoded_duration` | line-based token/pattern ban | `forbidden_pattern` | `policy.yaml` |
| `no_hardcoded_font_size` | line-based token/pattern ban | `forbidden_pattern` | `policy.yaml` |
| `no_hardcoded_radius` | line-based token/pattern ban | `forbidden_pattern` | `policy.yaml` |
| `no_hardcoded_size` | line-based token/pattern ban | `forbidden_pattern` | `policy.yaml` |
| `no_hardcoded_string` | line-based token/pattern ban | `forbidden_pattern` | `policy.yaml` |
| `shared_widget` | line-based raw-widget ban | `forbidden_pattern` | `policy.yaml` |
| `performance_contract` | whole-file contract | `content_contract` | `policy.yaml` |
| `responsive_text_scale` | whole-file contract | `content_contract` | `policy.yaml` |
| `screen_scaffold` | path-pattern content contract | `content_contract` | `policy.yaml` |
| `touch_target` | any-of token contract | `content_contract` | `policy.yaml` |
| `typography_scale` | exact-file token contract | `content_contract` | `policy.yaml` |
| `folder_structure` | path existence contract | `path_requirements` | `policy.yaml` |
| `feature_completeness` | directory population contract | `path_requirements` | `policy.yaml` |

## Remaining Legacy Guards

| Guard ID | Reason not yet migrated |
|---|---|
| `const_constructor` | computes constructor const-eligibility from code shape instead of simple token checks |
| `icon_style` | icon availability heuristics still depend on symbol-shape inspection; only the exception inventory is config-driven |
| `import_direction` | layer dependency graph logic is structural, not just token-based |
| `widget_length` | uses threshold and file-length logic, not just presence checks |
| `widget_class_length` | uses widget block boundary detection |
| `color_palette` | validates values against the configured palette inventory but still does custom hex scanning |
| `design_token_usage` | resolves project token registry and usage paths |
| `drift_table` | checks table contracts by scanning field declarations |
| `freezed_json_model` | derives expected `part` lines from file stem and supports record typedef exceptions |
| `provider_naming` | derives generated provider names from annotations and declarations |
| `records_patterns` | combines forbidden types with a cast-window heuristic |
| `refresh_retry` | correlates refresh affordances with screen-level patterns |
| `responsive_layout_test` | correlates screen files to paired test files and asserts test content |
| `riverpod_syntax` | path classification plus multiple Riverpod-specific forbidden forms |
| `safe_area_keyboard` | conditional contract: inputs require one of several keyboard-safe containers |
| `shared_widget_mapping` | path-specific widget contracts with list-context exceptions |
| `srs_field` | table-specific schema enforcement |
| `test_coverage` | dynamic source-to-test pairing across feature trees |

## Policy Cleanup Done in This Step

To avoid duplicated sources of truth:

- migrated guard definitions now live in `policy.yaml` under normalized `rules:`
- migrated project-rule payloads were removed from `rules.yaml`
- the `no_hardcoded_*` family and `shared_widget` legacy classes were removed
  because their normalized replacements are complete
- some other migrated Python classes still remain only as fallback implementation
  inventory and are skipped at runtime when the matching normalized rule exists

## Next Migration Candidates

Safest next steps:

1. introduce a paired-path generic rule for `responsive_layout_test` and
   `test_coverage`
2. introduce a conditional content-contract variant for `safe_area_keyboard`
3. evaluate whether `freezed_json_model` should get a stem-aware contract rule
4. decide whether to delete the remaining inactive migrated class files after
   their tests are moved to normalized-rule harnesses
