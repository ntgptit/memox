# MemoX Codex Agent Workflow

Use this workflow when a MemoX task is non-trivial and the user explicitly
allows subagents or parallel work.

Machine-readable preset files:

- repo-local pointer: `docs/codex-agent-workflow.toml`
- global preset bundle: `$CODEX_HOME/agent-presets/memox/`

## Default agent pool

1. `Agent 1: Coordinator / Architect`
   - model: `gpt-5.4`
   - owns architecture decisions, contract freeze, shared widget and theme
     changes, provider-graph overlap, sync boundaries, final integration, final
     review, and commit
2. `Agent 2: Core / Contract worker`
   - model: `gpt-5.3-codex`
   - upgrade to `gpt-5.4` when the task changes risky sync, import validation,
     migration contracts, or cross-layer public APIs
3. `Agent 3: UI / Presentation worker`
   - model: `gpt-5.3-codex`
   - owns screen-level UI, empty and error states, l10n consumption, shared
     widget usage, and feature-local presentation files
4. `Agent 4: Persistence / Repo / Tests worker`
   - model: `gpt-5.3-codex`
   - upgrade to `gpt-5.4` when the task touches Drift schema, Google sync,
     backup flow, batch data semantics, or cross-feature repositories
5. `Agent 5: Verifier / QA`
   - model: `gpt-5.4-mini`
   - owns guard, analyze, codegen confirmation, and test triage

## When to keep work in Agent 1

- `lib/core/theme/**`
- `lib/shared/widgets/**`
- `lib/app.dart`
- app router wiring
- cross-feature Riverpod provider graphs
- Google backup or sync boundaries that affect more than one feature
- generated files and final integration edits

## Control loop

1. `Agent 1` inspects the task, reads local rules, and freezes the contract:
   - goal
   - owned paths
   - forbidden paths
   - use case or repository API
   - result and error shape
   - verification scope
2. `Agent 1` spawns bounded workers only after the contract is frozen.
3. `Agent 2`, `Agent 3`, and `Agent 4` work in parallel only when their write
   scopes do not overlap.
4. `Agent 1` integrates the results and resolves mismatches.
5. Run codegen when required:
   - `dart run build_runner build --delete-conflicting-outputs`
   - `flutter gen-l10n`
6. `Agent 5` validates in this order:
   - `python tools/guard/run.py --scope <derived_scope>`
   - `flutter analyze`
   - relevant `flutter test` commands
7. If validation fails, `Agent 1` routes the failure back to the owner:
   - parser, use case, domain contract -> `Agent 2`
   - UI, design tokens, l10n, widget usage -> `Agent 3`
   - DAO, repository, migration, sync semantics, tests -> `Agent 4`
   - architecture mismatch or overlapping ownership -> `Agent 1`

## Preset usage

When the preset bundle is present, use it in this order:

1. read `docs/codex-agent-workflow.toml`
2. read `$CODEX_HOME/agent-presets/memox/workflow.toml`
3. auto-select a profile from task text and changed-path hints when possible
4. read the role files named in the workflow preset
5. spawn agents from the preset instead of rebuilding role definitions ad hoc

Example selector command:

```bash
python C:\Users\ntgpt\.codex\skills\codex-agent-control\scripts\load_preset.py \
  --preset-dir C:\Users\ntgpt\.codex\agent-presets\memox \
  --repo-preset D:\workspace\memox\docs\codex-agent-workflow.toml \
  --auto-profile \
  --task "Add bulk import cards from CSV" \
  --changed-path lib/features/cards/presentation \
  --changed-path lib/features/cards/data \
  --pretty
```

## Available profiles

`memox-default`
- Use for ordinary feature work where UI, use-case, and persistence changes are
  all present but none of them dominate risk.

`ui-heavy`
- Use for screen-heavy or interaction-heavy work where design-system
  consistency, empty/loading/error states, and visual hierarchy are the main
  risk.
- This profile upgrades `Agent 3` to `gpt-5.4` and narrows the active worker
  set to UI plus minimal core support.

`sync-heavy`
- Use for import/export, backup, restore, conflict handling, retry behavior,
  or Google sync work.
- This profile upgrades `Agent 2` and `Agent 4` to `gpt-5.4` and keeps more
  sync policy decisions in `Agent 1`.
- The selector will typically choose this profile when the task mentions
  `sync`, `backup`, `restore`, `import`, `export`, `csv`, `offline`, or
  `conflict`.

`migration-risk`
- Use for Drift schema changes, migration logic, repository contract updates,
  or cross-feature persistence refactors.
- This profile reduces parallel write concurrency, upgrades the data path, and
  increases verification strictness.
- The selector will typically choose this profile when the task mentions
  `migration`, `schema`, `drift`, `database`, `dao`, or when changed paths hit
  tables or DAO folders.

## Ownership rules

- No two workers may edit the same provider graph, route entry, or shared
  surface.
- `Agent 3` must not introduce ad hoc Material controls when a shared MemoX
  widget exists.
- `Agent 4` should not add a Drift migration unless `Agent 1` explicitly froze
  that decision.
- If a worker needs a forbidden path, it should stop and report that fact rather
  than widen scope.

## MemoX verification contract

For Dart, test, guard, or repo-instruction changes, `Agent 1` must ensure the
smallest valid guard scope runs before the task is considered done:

- `lib/core/**` -> `python tools/guard/run.py --scope core`
- `lib/shared/**` -> `python tools/guard/run.py --scope shared`
- `lib/features/**` -> `python tools/guard/run.py --scope features`
- `test/**` -> `python tools/guard/run.py --scope test`
- mixed or uncertain scope -> `python tools/guard/run.py --scope all`

`flutter analyze` is required for Dart changes, and `flutter test` should be
targeted unless the task is cross-cutting.

## Example: bulk import cards from CSV

Use the agent pool like this:

1. `Agent 1` freezes:
   - duplicate policy
   - CSV validation result model
   - use case and repository signatures
   - whether Drift schema change is actually required
2. `Agent 2` owns import parsing and validation orchestration.
3. `Agent 3` owns import screen, preview, mapping, empty, loading, and error
   states.
4. `Agent 4` owns repository wiring, batch insert semantics, and targeted tests.
5. `Agent 5` runs codegen if needed, then guard, analyze, and tests.
