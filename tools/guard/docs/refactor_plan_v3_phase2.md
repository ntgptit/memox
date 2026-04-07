# Guard Refactor Plan v3 — Phase 2

Date: 2026-04-07

## Scope

This plan covers only `tools/guard` Python code, YAML/config, and guard docs.

It assumes phase 1 is already complete:

- config-driven scope/path handling exists
- policy/engine separation exists
- normalized rules exist
- generic rule execution exists
- MemoX remains the default policy

This plan does **not** implement the changes. It defines the safest rollout order
for phase 2.

## Non-goals

This phase plan does not include:

- Flutter or Dart app refactors
- app architecture changes outside `tools/guard`
- CI platform redesign
- semantic similarity or fuzzy matching engines
- broad domain-rule rewrites
- compatibility removals without a migration path
- an autofix execution engine

## Current Repo Baseline

The current post-phase-1 architecture is:

- `run.py`
  - loads `policy.yaml` and `rules.yaml`
  - resolves policy, scope, family, guard filters
  - returns `0`, `1`, or `2`
- `core/guard_result.py`
  - defines `Severity`, `GuardScope`, `Violation`, and `GuardResult`
  - result model is still intentionally small
- `core/rule_schema.py`
  - parses normalized rules
  - supports `forbidden_pattern`, `file_naming`, `content_contract`,
    `path_requirements`
- `core/rule_executor.py`
  - runs normalized rules
- `core/reporter.py`
  - formats terminal, JSON, and Markdown directly
- `core/guard_registry.py`
  - runs normalized rules first, then legacy guards
  - legacy runtime remains the compatibility bridge

That gives phase 2 a stable base, but also reveals the current gaps:

- messages are mostly inline strings
- severity is only a flat enum plus per-rule override
- violations have no structured identity beyond message text and location
- guard crashes are flattened into synthetic violations
- output formatting is still bundled into one `Reporter`
- exit behavior is hardcoded to errors and optional warnings
- suppressions, baselines, remediation metadata, profiles, and versioning do not
  exist yet as first-class concepts

## Phase 2 Design Rules

1. Preserve MemoX default behavior unless a feature is explicitly opt-in.
2. Keep `policy.yaml` and `rules.yaml` as the only mandatory policy files.
3. Introduce metadata before introducing behavior.
4. Add fields before changing defaults.
5. Keep `Severity` values as `error|warning|info` through phase 2.
6. Keep `Violation.message` and current JSON/Markdown flags working throughout.
7. Make suppression and baseline support opt-in and additive first.
8. Treat autofix as metadata-only in phase 2.

## Requested Areas — Change Classification

| Area | Safe metadata first | Schema change required | Result model change required | CLI/output change required | Notes |
|---|---|---|---|---|---|
| 1. Message catalog | yes | yes | later | later | add ids/templates first, keep rendered message fallback |
| 2. Severity model | partial | yes | yes | later | keep current enum, add source/policy metadata |
| 3. Violation schema | no | no | yes | yes | additive fields only |
| 4. Suggestion/remediation catalog | yes | yes | yes | yes | ids first, rendered suggestions later |
| 5. Error taxonomy | partial | no | yes | yes | separate tool/config/runtime errors from findings |
| 6. Output formatter abstraction | no | no | yes | yes | should follow stable result envelope |
| 7. Exit policy | yes | yes | yes | yes | keep current 0/1/2 as default policy |
| 8. Rule capability metadata | yes | yes | no | optional | ideal first-wave metadata |
| 9. Autofix contract | yes | yes | yes | optional | metadata only, no apply engine |
| 10. Suppression mechanism | no | yes | yes | yes | must follow stable finding identity |
| 11. Rule profiles/presets | yes | yes | no | yes | config overlay, keep base profile as current behavior |
| 12. Documentation mapping | yes | yes | yes | yes | docs refs can be metadata first |
| 13. Baseline support | no | yes | yes | yes | depends on fingerprints and suppression states |
| 14. Versioning | yes | yes | yes | yes | should begin early, but behavior change stays minimal |

## Compatibility-safe Metadata First

These can be introduced first with minimal runtime risk because they do not
change how existing MemoX findings are produced.

### Top-level policy metadata

Add optional blocks to `policy.yaml`:

```yaml
versions:
  policy_schema: 2
  result_schema: 2
  formatter_schema: 1

message_catalog: {}
remediation_catalog: {}
documentation_map: {}
rule_profiles: {}
exit_policy: {}
suppression: {}
baseline: {}
```

Compatibility rule:

- absent block => current behavior
- present but unused block => parsed and stored only

### Per-rule metadata

Add optional metadata to normalized rules:

```yaml
rules:
  - id: no_else
    type: forbidden_pattern
    severity: error
    metadata:
      category: style
      capability_ids: [message_catalog, docs_ref]
      message_ids:
        default: no_else.default
      remediation_ids:
        - early_return
      docs_ref: no_else
      suppressible: true
      baseline_key: logical_line
      autofix:
        available: false
        reason: "No safe generic rewrite yet."
```

### Legacy-guard metadata

Extend legacy guard definition exposure in code, not behavior:

- optional class vars or methods for:
  - `CATEGORY`
  - `DOCS_REF`
  - `CAPABILITY_IDS`
  - `SUPPRESSIBLE`
  - `AUTOFIX_METADATA`

Do not require legacy guards to implement all of these at once.

## Changes That Require Schema Work

These are the schema changes phase 2 will need:

### Normalized rule schema

`core/rule_schema.py` will need optional support for:

- `metadata` block on every normalized rule
- optional message ids per pattern or contract case
- optional remediation ids
- optional docs refs
- optional capability ids
- optional suppression/baseline/autofix metadata

This should stay additive:

- existing rules continue parsing unchanged
- MemoX policy can adopt new fields gradually

### Top-level policy schema

`policy.yaml` should gain optional top-level blocks for:

- `versions`
- `message_catalog`
- `remediation_catalog`
- `documentation_map`
- `rule_profiles`
- `exit_policy`
- `suppression`
- `baseline`

Recommendation:

- do **not** introduce a mandatory third policy file in phase 2
- keep new metadata in `policy.yaml` first
- only split into additional catalog files later if size becomes a real problem

## Changes That Require Result Model Work

The current `Violation` and `GuardResult` model is too small for the requested
phase-2 features.

### Violation additions

Planned additive fields on `Violation`:

- `rule_id`
- `message_id`
- `message_args`
- `category`
- `docs_ref`
- `suggestion_ids`
- `fingerprint`
- `suppression_state`
- `baseline_state`
- `source` (`normalized`, `legacy`, `internal`)
- `autofix`

Keep these existing fields stable:

- `file_path`
- `line_number`
- `line_content`
- `message`
- `guard_id`
- `severity`
- `scope`

### GuardResult additions

Planned additive fields on `GuardResult`:

- `source`
- `capability_ids`
- `effective_severity_policy`
- `suppressed_count`
- `baselined_count`
- `internal_error_count`
- `profile`
- `tool_errors`

### Separate tool/runtime errors from findings

Current state:

- config/CLI errors use `GuardCliError`
- guard crashes become synthetic violations with `<internal>` path

Recommended phase-2 direction:

- keep `GuardCliError` for command-line failure handling
- introduce a separate `ToolError` or `RuntimeErrorRecord` model for:
  - config errors
  - schema errors
  - guard execution crashes
  - suppression/baseline load errors
- keep the current crash-to-violation fallback until formatter migration is ready

## Changes That Require CLI or Output Work

These should happen only after the result envelope is stable.

### Output formatter abstraction

Current state:

- `Reporter` renders terminal, JSON, and Markdown directly

Planned direction:

- introduce a shared report envelope
- split formatter logic into explicit classes, for example:
  - `TerminalFormatter`
  - `JsonFormatter`
  - `MarkdownFormatter`
- keep `Reporter` as the compatibility facade until migration is complete

### CLI changes that should be delayed

Delay these until the underlying model exists:

- `--profile`
- `--baseline`
- `--write-baseline`
- `--suppressions`
- `--exit-policy`
- `--format`
- `--show-docs`
- `--show-suggestions`

Keep these stable throughout phase 2:

- `--policy`
- `--config`
- `--rules`
- `--scope`
- `--family`
- `--guard`
- `--validate-config`
- `--json`
- `--md`
- `--quiet`
- `--fail-on-warnings`

## Safe Incremental Phases

### Phase 2.1 — Version and Metadata Envelope

Goal:

- add optional policy/rule metadata without changing runtime behavior

Primary files:

- `tools/guard/core/rule_schema.py`
- `tools/guard/core/guard_registry.py`
- `tools/guard/core/base_guard.py`
- `tools/guard/policies/memox/policy.yaml`
- docs under `tools/guard/docs/`

Deliverables:

- `versions` block
- normalized rule `metadata` support
- legacy guard metadata exposure path
- parsed but behavior-neutral message/remediation/docs/profile/autofix/suppression
  metadata

Why first:

- this is the lowest-risk layer
- it creates the data model needed by all later phases

Verification:

- `python -m pytest tools/guard/tests`
- `python tools/guard/run.py --scope all --quiet`

### Phase 2.2 — Result Envelope and Error Taxonomy

Goal:

- expand finding identity and separate non-finding tool errors

Primary files:

- `tools/guard/core/guard_result.py`
- `tools/guard/core/guard_registry.py`
- `tools/guard/core/rule_executor.py`
- legacy guard helpers in `tools/guard/core/base_guard.py`

Deliverables:

- additive `Violation` fields
- additive `GuardResult` fields
- `fingerprint` generation
- initial `ToolError` / runtime error taxonomy

Compatibility rule:

- `Violation.message` remains required
- existing `to_dict()` keys remain present
- new JSON fields are additive

Dependency:

- depends on phase 2.1 metadata ids

### Phase 2.3 — Output Formatter Abstraction

Goal:

- decouple result rendering from `Reporter` without changing default output

Primary files:

- `tools/guard/core/reporter.py`
- new `tools/guard/core/formatters/` package

Deliverables:

- formatter interface
- report envelope shared by terminal/json/markdown
- compatibility-preserving `Reporter` facade
- golden tests for output contracts

Why here:

- formatters should consume the stable result envelope from phase 2.2

### Phase 2.4 — Message Catalog, Remediation Catalog, Severity Policy Metadata

Goal:

- resolve message ids and remediation ids into structured output while keeping
  current strings stable

Primary files:

- `tools/guard/core/rule_schema.py`
- `tools/guard/core/rule_executor.py`
- `tools/guard/core/reporter.py` or new formatters
- `tools/guard/policies/memox/policy.yaml`

Deliverables:

- optional `message_catalog`
- optional `remediation_catalog`
- optional `documentation_map`
- structured severity metadata:
  - `default_severity`
  - `effective_severity`
  - `severity_source`

Compatibility rule:

- if no catalog entry exists, use the existing inline message string
- do not add new severity levels in this phase

Dependency:

- depends on phases 2.1 through 2.3

### Phase 2.5 — Suppression and Baseline Foundation

Goal:

- support opt-in noise control without altering default MemoX behavior

Primary files:

- new `tools/guard/core/suppression.py`
- new `tools/guard/core/baseline.py`
- `tools/guard/core/guard_registry.py`
- `tools/guard/core/reporter.py` or new formatters
- `tools/guard/policies/memox/policy.yaml`
- optional baseline file under `tools/guard/` or configurable path

Deliverables:

- exact-match suppression format first
- fingerprint-based baseline format
- finding states:
  - active
  - suppressed
  - baselined
- counts surfaced in results

Recommended first suppression shape:

- match by `guard_id`
- path glob
- optional `message_id`
- optional `reason`
- optional expiry or owner later, not in the first cut

Recommended first baseline behavior:

- read-only comparison first
- no automatic baseline writing by default

Dependency:

- depends on stable fingerprints from phase 2.2

### Phase 2.6 — Rule Profiles/Presets and Exit Policy

Goal:

- make runtime policy overlays explicit without changing the base MemoX flow

Primary files:

- `tools/guard/run.py`
- new `tools/guard/core/profile_resolver.py`
- new `tools/guard/core/exit_policy.py`
- `tools/guard/policies/memox/policy.yaml`

Deliverables:

- `rule_profiles` block in `policy.yaml`
- profile overlay logic for:
  - guard enablement
  - severity overrides
  - optional suppression/baseline toggles
- configurable exit policy over post-filter counts

Compatibility rule:

- implicit base profile == current MemoX behavior
- existing exit behavior remains the default:
  - `0` success
  - `1` findings that violate current thresholds
  - `2` CLI/config errors

Dependency:

- depends on suppression/baseline state if exit policy is expected to ignore
  suppressed or baselined findings

### Phase 2.7 — Autofix Contract and Documentation Mapping Completion

Goal:

- finish the metadata contract for rule guidance without building an execution
  engine

Primary files:

- `tools/guard/core/rule_schema.py`
- `tools/guard/core/guard_result.py`
- `tools/guard/policies/memox/policy.yaml`
- docs under `tools/guard/docs/`

Deliverables:

- structured autofix metadata:
  - `available`
  - `safe`
  - `kind`
  - `reason`
  - `manual_steps`
- docs refs attached to findings and guard definitions
- formatter support for docs/suggestion/autofix metadata

Explicit limitation:

- no `--apply-fixes`
- no file mutation engine
- no auto-editing of source files in phase 2

## Recommended Data Shapes

These are the most likely stable additions for phase 2.

### `policy.yaml`

```yaml
versions:
  policy_schema: 2
  result_schema: 2

message_catalog:
  no_else.default:
    template: "Use early return, guard clause, or switch expression instead of else."
    docs_ref: no_else
    remediation_ids: [early_return]

remediation_catalog:
  early_return:
    title: "Remove else branch"
    summary: "Use an early return or guard clause."
    manual_steps:
      - "Return early from the exceptional branch."

documentation_map:
  no_else:
    title: "No else rule"
    path: "tools/guard/docs/rule_schema_v2.md"

rule_profiles:
  base: {}
  ci_strict:
    severity_overrides:
      widget_length: error

exit_policy:
  default:
    fail_on:
      - error

suppression:
  rules: []

baseline:
  path: "tools/guard/baselines/memox.json"
```

### `Violation`

```python
Violation(
    file_path='lib/foo.dart',
    line_number=10,
    line_content='} else {',
    message='Use early return instead of else.',
    guard_id='no_else',
    severity=Severity.ERROR,
    scope=GuardScope.GLOBAL,
    message_id='no_else.default',
    message_args={},
    category='style',
    docs_ref='no_else',
    suggestion_ids=['early_return'],
    fingerprint='...',
    suppression_state='active',
    baseline_state='new',
    source='normalized',
    autofix=None,
)
```

## Foundational vs Optional Later Layers

### Foundational phase-2 layers

These should happen in phase 2:

- version envelope
- metadata shell
- result/violation expansion
- error taxonomy
- formatter abstraction
- message/remediation/docs metadata resolution
- suppression and baseline foundation
- profiles and exit policy
- autofix contract metadata

### Optional later layers

These should **not** be bundled into phase 2:

- autofix execution engine
- inline suppression pragmas in source files
- semantic or fuzzy baselines
- SARIF or additional formatter targets unless explicitly needed
- new generic rule engines unrelated to the requested phase-2 areas
- guard-family discovery redesign beyond current `global` / `local`

## Recommended Implementation Order

1. Phase 2.1 — metadata and version envelope
2. Phase 2.2 — result model and fingerprints
3. Phase 2.3 — formatter abstraction
4. Phase 2.4 — message/remediation/docs/severity metadata
5. Phase 2.5 — suppression and baseline
6. Phase 2.6 — profiles and exit policy
7. Phase 2.7 — autofix contract completion

This order minimizes breakage because:

- metadata is available before behavior depends on it
- results stabilize before formatters and CLI logic consume them
- suppression and baseline wait for stable finding identity
- exit policy waits for post-filter counts to exist
- autofix remains metadata-only and does not destabilize runtime execution

## Risks to Watch

1. JSON output churn
   - mitigation: additive fields only until a versioned formatter is in place

2. Legacy guard adoption cost
   - mitigation: make metadata optional and defaultable at the `BaseGuard` layer

3. Policy bloat in `policy.yaml`
   - mitigation: keep new blocks optional first; only split catalogs later if
     size becomes a real maintenance issue

4. Suppression and baseline misuse
   - mitigation: make both opt-in, explicit, and visible in output

5. Exit-policy surprises in MemoX CI
   - mitigation: keep the current default exit semantics as the base profile

## Recommended Verification Per Phase

For every implementation slice in phase 2:

```bash
python -m pytest tools/guard/tests
python tools/guard/run.py --scope all --quiet
```

Add targeted tests for:

- schema validation
- JSON/Markdown/terminal snapshots
- suppression and baseline matching
- profile overlay resolution
- exit policy evaluation

## Recommended Next Prompt

Implement phase 2.1 from `tools/guard/docs/refactor_plan_v3_phase2.md` only:

- add version metadata and optional top-level policy metadata blocks
- extend normalized rule parsing with an additive `metadata` section
- expose additive legacy guard metadata in `GuardDefinition`
- do not change current violation output, exit behavior, suppression behavior, or
  formatter behavior yet
