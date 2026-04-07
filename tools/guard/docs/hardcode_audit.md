# Guard Hardcode Audit

Date: 2026-04-07

## Goal

Identify remaining MemoX-specific literals inside Python guard code, move the
reusable ones into policy or rule config, and document the intentional
exceptions that still stay in Python.

## Audit Method

Reviewed non-test Python files under `tools/guard/**` for:

- direct repo paths and folder names
- direct widget, class, and symbol names
- provider/file naming assumptions
- project-branded output strings

The target was safe extraction only. Unique behavior stayed in Python when the
underlying rule shape is not yet modeled cleanly.

## Removed Hardcodes

### Migrated out of Python guard logic in this step

These values now live in MemoX policy config instead of runtime code:

- `icon_style_guard.py`
  - excluded paths
  - skip-line tokens
  - allowed non-outlined icon list
  - violation message template
- `import_direction_guard.py`
  - layer list
  - forbidden layer graph
  - excluded paths
  - import regex template
  - violation message template
- `provider_naming_guard.py`
  - path matching rules
  - Riverpod annotation tokens
  - repository/use-case/controller naming cases
- `color_palette_guard.py`
  - target token file path
- `drift_table_guard.py`
  - tables directory path
- `srs_field_guard.py`
  - cards table file path
- `refresh_retry_guard.py`
  - retry trigger tokens
  - retry callback tokens
  - refresh trigger tokens
  - violation messages
- `safe_area_keyboard_guard.py`
  - keyboard-safe violation message

### Previously specialized guards now fully config-driven

The following one-off global guards no longer need Python logic:

- `no_hardcoded_color`
- `no_hardcoded_duration`
- `no_hardcoded_font_size`
- `no_hardcoded_radius`
- `no_hardcoded_size`
- `no_hardcoded_string`
- `shared_widget`

Their rule definitions live in `tools/guard/policies/memox/policy.yaml`, and
their old class files were removed.

### Engine-level decoupling done in this step

- `PathConstants.get_layer()` no longer hardcodes the `features` segment for
  MemoX. Layer detection is now controlled by `paths.layer_detection` in policy
  config, with the default root segment derived from `paths.features_dir`.
- `Reporter` no longer hardcodes `MemoX` in CLI and markdown output. Report
  titles come from `project_name` config.

## Remaining Intentional Hardcodes

### Repo-default policy entrypoint

- `tools/guard/run.py`
  - `_DEFAULT_POLICY = 'tools/guard/policies/memox'`
  - Reason: this repository ships MemoX as its first-party default policy. This
    is a repo-local CLI default, not reusable guard-engine logic.
  - Why deferred: changing the default policy discovery behavior would be a CLI
    behavior change, not just a hardcode extraction.

## Remaining Legacy Python Logic

These guards still require Python behavior today, but the MemoX-specific data
has either already moved to config or the remaining logic is framework-level
rather than MemoX-branded:

- `const_constructor_guard.py`
  - reason: constructor const-eligibility is code-shape analysis
- `freezed_json_model_guard.py`
  - reason: generated-part and typedef heuristics are still specialized
- `records_patterns_guard.py`
  - reason: cast-window heuristic is algorithmic, not declarative
- `responsive_layout_test_guard.py`
  - reason: screen-to-test pairing is relational logic
- `riverpod_syntax_guard.py`
  - reason: Riverpod annotation/import semantics are framework-specific and not
    yet modeled as a safe generic rule type
- `shared_widget_mapping_guard.py`
  - reason: path-scoped required/forbidden widget combinations still use
    specialized branching
- `test_coverage_guard.py`
  - reason: source-to-test pairing is dynamic and multi-path

## Inactive Migration Leftovers

Some migrated class files still exist under `local_guards/`, but the registry
skips them at runtime when the same `GUARD_ID` exists in normalized `policy.yaml`
rules. They remain temporarily to avoid mixing runtime migration with broader
test-file churn in the same step.

Examples:

- `button_usage_guard.py`
- `l10n_source_guard.py`
- `performance_contract_guard.py`
- `responsive_text_scale_guard.py`
- `screen_scaffold_guard.py`
- `text_style_guard.py`
- `touch_target_guard.py`
- `typography_scale_guard.py`
- `folder_structure_guard.py`
- `feature_completeness_guard.py`

These are now effectively migration residue, not active policy runtime.

## Outcome

After this audit, non-test guard Python is no longer carrying MemoX-specific
paths, widget names, provider file names, or project-branded output strings in
active reusable logic. The remaining MemoX-specific literal in runtime code is
the repo-default policy directory in `run.py`, and that is intentional.
