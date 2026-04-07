# Guard Commonization Audit — Phase 1

Date: 2026-04-07

## Goal

Confirm whether the current `tools/guard` refactor achieved the original phase-1
goal:

- commonize scope, path, rule, and policy handling
- reduce MemoX-specific coupling in reusable engine code
- keep backward compatibility and legacy guards where needed
- avoid drifting into adjacent platform work

This is a close-out audit, not a redesign plan.

## Phase 1 Verdict

Phase 1 is complete.

The repo now has a stable commonization baseline:

- scope and scan-path behavior are policy-driven
- policy data is meaningfully separated from engine code
- normalized rules exist and cover a meaningful subset of guards
- generic rule types replace duplicated one-off Python guards where the pattern
  was already clear
- legacy guards still run for the behaviors that remain too specialized

One small blocker surfaced during this audit and was fixed immediately:

- normalized `targets.include` / `targets.exclude` are now validated by the rule
  schema
- normalized targets now apply consistently across `forbidden_pattern`,
  `file_naming`, `content_contract`, and `path_requirements`

## Done

### 1. Scope is config-driven

- `scan_targets` defines named scopes in policy config
- scope roots, per-scope includes, excludes, and extensions are loaded from
  config rather than hardcoded `if/elif` logic
- `PathConstants.path_is_within_scope()` gives guards a generic scope helper

Status: done

### 2. Paths are config-driven

- project roots live in policy config (`source_root`, `test_root`, `paths.*`)
- global excludes live in `paths.exclude_patterns`
- per-scope include/exclude/extension controls live in `scan_targets`
- layer detection for import analysis is policy-driven

Status: done

### 3. Policy is meaningfully separated from the engine

- engine code lives under `tools/guard/core/`
- MemoX runtime policy lives in `tools/guard/policies/memox/policy.yaml`
- MemoX project-specific legacy rule data lives in
  `tools/guard/policies/memox/rules.yaml`
- CLI resolves policies without requiring engine changes

Status: done

### 4. Normalized rule schema exists for new and migrated rules

- normalized rules are declared in policy config under `rules:`
- schema parsing and validation live in `core/rule_schema.py`
- execution lives in `core/rule_executor.py`
- schema now validates `targets` clearly instead of allowing malformed values to
  slip through

Status: done

### 5. Generic guard types are in real use

Current generic types:

- `forbidden_pattern`
- `file_naming`
- `content_contract`
- `path_requirements`

These now cover a meaningful subset of current guards, including:

- token or regex bans
- naming conventions
- whole-file or path-pattern content contracts
- project structure and path existence requirements

Status: done

### 6. MemoX-specific literals were removed from reusable engine code as far as
phase 1 safely allows

For active reusable runtime paths:

- MemoX-specific scan roots are policy-driven
- MemoX-specific layer detection is policy-driven
- MemoX-specific rule patterns and required tokens are policy-driven
- report branding comes from `project_name`

The remaining repo-default MemoX policy path in `run.py` is a repo CLI default,
not an engine-coupling problem.

Status: done for reusable engine/runtime

### 7. Backward compatibility is acceptable

Compatibility retained:

- default MemoX invocation still works
- legacy `--config` / `--rules` overrides still work
- legacy five-scope synthesis still works when `scan_targets` is absent
- repo-relative directory scopes still work as a compatibility fallback
- legacy guard classes continue running when no normalized rule replaced them

Status: done

## Partially Done

### 1. Legacy family structure remains

The runtime still has `global_guards/` and `local_guards/` discovery as the
legacy Python guard library shape.

This is acceptable for phase 1 because:

- it does not block config-driven scopes, paths, policies, or normalized rules
- it preserves current behavior safely
- changing guard-family discovery would be a separate extensibility step

Status: partially done, intentionally acceptable for phase 1

### 2. Some compatibility bridge fields remain in `PathConstants`

Named path aliases such as `core_dir`, `shared_dir`, and `features_dir` still
exist because active legacy guards rely on them.

This is acceptable for phase 1 because the values are now loaded from policy
instead of being embedded in guard logic.

Status: partially done, intentionally acceptable for phase 1

### 3. Top-level legacy spec remains as historical background

`docs/memox-guard-spec.md` still contains historical sections from the
pre-commonization layout. A redirect note now points readers to the v2 docs, but
the old narrative has not been fully rewritten.

This is not a blocker because the current source-of-truth docs are explicit, but
it is still historical material rather than clean final architecture prose.

Status: partially done, not a phase-1 blocker

## Intentionally Deferred

The following were explicitly kept out of phase 1:

- message catalog redesign
- severity platform redesign
- autofix platform
- suppression platform
- reporting overhaul
- new relational or semantic rule engines for guards that still need specialized
  Python logic

Also intentionally deferred:

- deleting the inactive migrated guard class files immediately
- redesigning guard-family discovery beyond `global` and `local`
- forcing every remaining legacy guard into config before a safe generic model
  exists

## Remaining Legacy Guards

These still require dedicated Python because the current normalized rule types do
not safely model their behavior yet:

- `const_constructor`
- `icon_style`
- `import_direction`
- `widget_length`
- `widget_class_length`
- `color_palette`
- `design_token_usage`
- `drift_table`
- `freezed_json_model`
- `provider_naming`
- `records_patterns`
- `refresh_retry`
- `responsive_layout_test`
- `riverpod_syntax`
- `safe_area_keyboard`
- `shared_widget_mapping`
- `srs_field`
- `test_coverage`

This is acceptable for phase 1 because the goal was gradual commonization, not a
big-bang rewrite.

## Documentation Status

Current source-of-truth docs for the refactored system:

- `tools/guard/docs/cli_usage_v2.md`
- `tools/guard/docs/config_scopes_paths.md`
- `tools/guard/docs/rule_schema_v2.md`
- `tools/guard/docs/generic_guard_migration.md`
- `tools/guard/docs/hardcode_audit.md`
- `tools/guard/docs/testing_v2.md`
- this file

This is sufficient for future migration work.

## Next Recommended Phase

Keep the next step narrow:

1. add one or two new generic rule shapes only for still-repeated legacy
   patterns, not a platform redesign
2. likely candidates:
   - paired source-to-test coverage rules
   - conditional content contracts for cases like keyboard-safe wrappers
3. remove inactive migrated class files only after their tests are either
   retired or rewritten around normalized-rule execution
4. optionally rewrite the historical sections of `docs/memox-guard-spec.md`
   after phase-1 close-out, but treat that as documentation cleanup rather than
   architecture work

## Final Conclusion

The refactor achieved the original phase-1 target.

`tools/guard` is now materially less coupled to MemoX internals in its reusable
engine path, while still preserving MemoX behavior through policy config and a
documented legacy compatibility layer. No broader platform expansion is required
to call this phase complete.
