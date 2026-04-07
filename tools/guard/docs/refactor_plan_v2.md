# Guard Engine Refactor Plan v2

**Date:** 2026-04-07
**Scope:** `tools/guard/` Python code and YAML config only.
**Goal:** Separate a reusable guard engine from MemoX-specific policy without breaking existing behavior.

---

## 1. Current State Assessment

### 1.1 Directory Snapshot

```
tools/guard/
├── run.py                         # Entry point — mostly generic, leaks "MemoX" in --help
├── config.yaml                    # Engine + MemoX policy mixed together
├── project_rules.yaml             # MemoX-specific rule data
├── requirements.txt
├── core/
│   ├── base_guard.py              # REUSABLE — pure abstraction
│   ├── guard_family.py            # REUSABLE — auto-discovery, importlib
│   ├── guard_registry.py          # REUSABLE — orchestration loop
│   ├── guard_result.py            # REUSABLE — pure data types
│   ├── path_constants.py          # MIXED — data-driven struct, hardcoded scope names
│   ├── file_scanner.py            # MIXED — generic scanner, hardcoded .dart default
│   └── reporter.py                # REUSABLE — output formatting
├── global_guards/                 # MIXED — generic guard logic, MemoX policy embedded
│   └── family.py
├── local_guards/                  # MIXED — MemoX-specific guards reading from project_rules
│   └── family.py
└── tests/
    ├── core/
    ├── global_guards/
    └── local_guards/
```

---

### 1.2 Hardcoded Areas Inventory

#### A. Scope literals in `core/path_constants.py:scope_roots()` (lines 33–43)

```python
if scope == 'all':   return [self.source_root, self.test_root]
if scope == 'core':  return [self.core_dir]
if scope == 'shared':return [self.shared_dir]
if scope == 'features': return [self.features_dir]
if scope == 'test':  return [self.test_root]
return [self.root_dir / scope]       # fallback: treat scope as relative path
```

**Problem:** Scope names ('core', 'shared', 'features', 'all', 'test') and their path mappings are engine-level code that embeds MemoX folder semantics.

#### B. Named path fields in `core/path_constants.py` (dataclass fields)

```python
core_dir: Path      # → lib/core
shared_dir: Path    # → lib/shared
features_dir: Path  # → lib/features
```

**Problem:** These three named fields are MemoX-specific. Another project might have `src/`, `packages/`, `modules/` etc.

#### C. Additional scope name checks in `local_guards/folder_structure_guard.py` (lines 25–56)

```python
if scope in {'all', 'core', 'shared', 'features'}:
if scope == 'core' and not path.startswith('lib/core'): continue
if scope == 'shared' and not path.startswith('lib/shared'): continue
if scope == 'features' and not path.startswith('lib/features'): continue
if scope in {'all', 'core'}:
if scope not in {'all', 'features'}:
```

**Problem:** Scope names appear in two different places (engine + guard), creating coupling.

#### D. Default file extension `.dart` in `core/file_scanner.py` (line 10)

```python
def scan(self, scope: str = 'all', extensions: tuple[str, ...] = ('.dart',)) -> list[Path]:
```

**Problem:** Default is language-specific. Nothing prevents a Kotlin/Swift/JS project from reusing the engine, but the default is wrong.

#### E. Family key names hardcoded in `core/base_guard.py` (lines 37–42)

```python
family_key = 'global_guards'
if self.SCOPE == GuardScope.LOCAL:
    family_key = 'local_guards'
return self.config.get(family_key, {}).get(self.GUARD_ID, True)
```

**Problem:** `'global_guards'` and `'local_guards'` are strings tied to `config.yaml` keys. A third family would require code change.

#### F. Guard discovery path relative to `__file__` in `core/guard_family.py` (line 27)

```python
guard_root = Path(__file__).resolve().parents[1] / self.GUARDS_DIR
```

**Problem:** Discovery is locked to sibling directories of `core/`. Adding a profile-specific guard directory (e.g., `profiles/memox/guards/`) is not possible without overriding this method.

#### G. Tool description string in `run.py` (line 25)

```python
parser = argparse.ArgumentParser(description='MemoX AI output guard tool')
```

Minor. Cosmetic but signals tight project coupling.

#### H. Hardcoded path prefix strings in global guard whitelists

| Guard | Hardcoded path constant | Location |
|---|---|---|
| `no_hardcoded_color_guard.py` | `lib/core/theme/tokens/color_tokens.dart`, `lib/core/theme/color_schemes/custom_colors.dart`, `lib/core/theme/color_schemes/app_color_scheme.dart`, `test/` | Class-level `WHITELIST` tuple |
| `no_hardcoded_duration_guard.py` | `lib/core/theme/tokens/duration_tokens.dart`, `test/` | Class-level `WHITELIST` tuple |
| `no_hardcoded_font_size_guard.py` | `lib/core/theme/tokens/typography_tokens.dart`, `test/` | Class-level `WHITELIST` |
| `no_hardcoded_radius_guard.py` | `lib/core/theme/tokens/radius_tokens.dart`, `test/` | Class-level `WHITELIST` |
| `no_hardcoded_size_guard.py` | `lib/core/theme/tokens/size_tokens.dart`, `lib/core/theme/tokens/spacing_tokens.dart`, `test/` | Class-level `WHITELIST` |
| `no_hardcoded_string_guard.py` | `test/`, `lib/core/constants/`, `l10n/` | Class-level `WHITELIST` |
| `shared_widget_guard.py` | `lib/shared/widgets/`, `test/` | Class-level `WHITELIST` |

#### I. Hardcoded MemoX widget/class/symbol names in global guards

| Guard | Hardcoded symbols |
|---|---|
| `shared_widget_guard.py` | `AppCard`, `AppAsyncBuilder`, `PrimaryButton`, `LoadingIndicator`, `AppTextField`, `AppListTile`, `AppSwitchTile`, `AppEditDeleteMenu`, `AppPressable`, `AppTapRegion`, `Toast`, `AppSlidableRow` |
| `async_builder_guard.py` | `AppAsyncBuilder`, `app_async_builder.dart` |
| `icon_style_guard.py` | 11 icon name exceptions (`close`, `add`, `check`, `remove`, etc.) |
| `import_direction_guard.py` | Layer names `data`, `domain`, `presentation` hardcoded in regex and conditionals |
| `l10n_guard.py` | `lib/core/constants/` whitelist |

#### J. Hardcoded MemoX symbols in local guards (fallback / in-code values)

| Guard | Hardcoded symbols |
|---|---|
| `screen_scaffold_guard.py` | `AppScaffold(`, `SliverScaffold(` as required widgets; `Scaffold(` as forbidden |
| `text_style_guard.py` | `lib/core/theme/` as whitelist; specific `TextStyle` forbidden patterns |
| `provider_naming_guard.py` | Provider suffix patterns (`RepositoryProvider`, `UseCaseProvider`, `ControllerProvider`) |
| `legacy_state_notifier_guard.py` | 3 forbidden patterns fully in-code (no project_rules fallback) |
| `records_patterns_guard.py` | `Tuple2`, `Tuple3`, `Pair` forbidden class names |
| `safe_area_keyboard_guard.py` | `AppTextField`, `TextField` as input tokens; `AppScaffold`, `AppDialog`, etc. as safe-area tokens |
| `touch_target_guard.py` | `AppPressable`, `InlineTextLinkButton`, `ExpandableTile`, `SizeTokens.touchTarget` etc. |

---

### 1.3 Classification: Engine vs. Policy

| Concern | Engine (reusable) | MemoX Policy |
|---|---|---|
| `guard_result.py` | ✅ fully generic | — |
| `reporter.py` | ✅ fully generic | — |
| `base_guard.py` | ✅ except hardcoded `global_guards`/`local_guards` key names | family key names |
| `guard_family.py` | ✅ except discovery path anchoring | — |
| `guard_registry.py` | ✅ fully generic | — |
| `file_scanner.py` | ✅ except `.dart` default | language/extension |
| `path_constants.py` | ✅ struct + helpers | named fields (`core_dir`, `shared_dir`, `features_dir`) + scope literals |
| `run.py` | ✅ mostly generic | "MemoX" description, default paths |
| `config.yaml` | engine keys (`source_root`, `test_root`, `thresholds`, `exclude_patterns`) | `project_name`, named path dirs, `global_guards`/`local_guards` enable map, `severity_overrides` |
| `project_rules.yaml` | — | ✅ entirely MemoX policy |
| Guard whitelists | — | all path literals, widget names, token names |
| `folder_structure_guard.py` scope checks | — | scope name strings, path prefix checks |
| Layer rules in `import_direction_guard.py` | layer concept (generic) | `data`/`domain`/`presentation` as the only valid layers |

---

## 2. Refactor Plan

### Guiding Principles

1. **Run after every phase.** `python tools/guard/run.py --scope all` must pass before and after each phase.
2. **No rename before extraction.** Extract data first, then restructure, then rename.
3. **No new abstraction layer** unless the concrete duplication requires it.
4. **Tests pass throughout.** `pytest tools/guard/tests/` stays green.
5. **Backwards-compatible CLI.** `--scope`, `--family`, `--guard`, `--config`, `--rules` flags unchanged.

---

### Phase 1 — Extract MemoX policy from guard code into `project_rules.yaml`

**What:** Move all class-level `WHITELIST`, `FORBIDDEN_RAW`, and other MemoX-specific constants out of global guard source files into `project_rules.yaml`. Guards read from `self.project_rules` (already done for local guards; extend to global guards).

**Why phase 1:** Pure data migration. No structural change, no import change, no API change. Easiest rollback.

#### 1a. Global guard whitelists → `project_rules.yaml`

Add a top-level `global_guard_policy:` key in `project_rules.yaml`:

```yaml
global_guard_policy:
  no_hardcoded_color:
    whitelist:
      - "lib/core/theme/tokens/color_tokens.dart"
      - "lib/core/theme/color_schemes/custom_colors.dart"
      - "lib/core/theme/color_schemes/app_color_scheme.dart"
      - "test/"
  no_hardcoded_duration:
    whitelist:
      - "lib/core/theme/tokens/duration_tokens.dart"
      - "test/"
  no_hardcoded_font_size:
    whitelist:
      - "lib/core/theme/tokens/typography_tokens.dart"
      - "test/"
  no_hardcoded_radius:
    whitelist:
      - "lib/core/theme/tokens/radius_tokens.dart"
      - "test/"
  no_hardcoded_size:
    whitelist:
      - "lib/core/theme/tokens/size_tokens.dart"
      - "lib/core/theme/tokens/spacing_tokens.dart"
      - "test/"
  no_hardcoded_string:
    whitelist:
      - "test/"
      - "lib/core/constants/"
      - "l10n/"
  shared_widget:
    whitelist:
      - "lib/shared/widgets/"
      - "test/"
    forbidden_raw:
      - pattern: "\\bCard\\("
        message: "Use AppCard instead of raw Card()"
      - pattern: "\\.when\\s*\\("
        message: "Use AppAsyncBuilder instead of raw .when(...)"
      # ... remaining entries
  async_builder:
    whitelist:
      - "app_async_builder.dart"
      - "test/"
  icon_style:
    allowed_non_outlined:
      - close
      - add
      - check
      - remove
      - arrow_back
      - arrow_forward
      - chevron_right
      - drag_handle
      - expand_more
      - more_vert
      - more_horiz
  import_direction:
    layers:
      - data
      - domain
      - presentation
    forbidden_imports:
      domain: [data, presentation]
      presentation: [data]
```

Each guard then reads its policy block via:

```python
policy = self.project_rules.get('global_guard_policy', {}).get(self.GUARD_ID, {})
whitelist = tuple(policy.get('whitelist', self.WHITELIST))  # fallback to class constant during migration
```

#### 1b. Local guard in-code symbols → `project_rules.yaml`

Guards that have in-code symbol lists without a `project_rules` counterpart:

| Guard | New `project_rules.yaml` key |
|---|---|
| `screen_scaffold_guard.py` | `screen_scaffold.required_widgets`, `screen_scaffold.forbidden_widgets` |
| `text_style_guard.py` | `text_style.whitelist`, `text_style.forbidden_patterns` |
| `provider_naming_guard.py` | `provider_naming.required_suffixes` |
| `legacy_state_notifier_guard.py` | `legacy_state_notifier.forbidden_patterns` |
| `records_patterns_guard.py` | `records_patterns.forbidden_classes` |
| `safe_area_keyboard_guard.py` | `safe_area_keyboard.input_tokens`, `safe_area_keyboard.safe_tokens` |
| `touch_target_guard.py` | `touch_target.required_tokens` |

**Acceptance criteria for Phase 1:**
- [ ] `python tools/guard/run.py --scope all` exits with same result as before
- [ ] `pytest tools/guard/tests/` green
- [ ] No class-level `WHITELIST` constant survives in global guards that embeds a `lib/` path prefix
- [ ] No MemoX widget/symbol name is hardcoded in any guard `.py` file (outside of a fallback default read from `project_rules`)

---

### Phase 2 — Generalize `path_constants.py` scope mapping

**What:** Replace the `if scope == 'core': ...` chain in `scope_roots()` with a data-driven lookup. Add a `scope_map:` key to `config.yaml`. Keep named convenience fields (`core_dir`, `shared_dir`, `features_dir`) for now as aliases.

**config.yaml addition:**

```yaml
scope_map:
  all:      ["lib", "test"]
  core:     ["lib/core"]
  shared:   ["lib/shared"]
  features: ["lib/features"]
  test:     ["test"]
```

**`path_constants.py` change:**

```python
@classmethod
def from_config(cls, root_dir: Path, config: dict) -> 'PathConstants':
    ...
    scope_map = {
        name: [root_dir / p for p in paths_list]
        for name, paths_list in config.get('scope_map', {}).items()
    }
    return cls(..., scope_map=scope_map)

def scope_roots(self, scope: str) -> list[Path]:
    if scope in self._scope_map:
        return self._scope_map[scope]
    return [self.root_dir / scope]   # unchanged fallback
```

The three named fields (`core_dir`, `shared_dir`, `features_dir`) stay as computed properties for now (used by local guards).

**Also fix `folder_structure_guard.py`:** Replace the hardcoded scope-name checks with a config-driven approach. Each required directory entry in `project_rules.yaml` gets an optional `scope_filter:` tag so the guard filters by scope generically.

**Acceptance criteria for Phase 2:**
- [ ] `scope_roots()` contains no hardcoded scope name strings
- [ ] `folder_structure_guard.py` contains no `path.startswith('lib/core')` checks
- [ ] Existing scopes (`--scope core`, `--scope shared`, `--scope features`, `--scope test`, `--scope all`) produce identical file lists as before
- [ ] Tests green

---

### Phase 3 — Split `config.yaml` into engine config and MemoX profile

**What:** Create `tools/guard/profiles/memox/policy.yaml` for MemoX-only settings. `config.yaml` retains only engine-level keys.

**Engine keys stay in `config.yaml`:**

```yaml
language: dart
source_root: lib
test_root: test
scope_map:  { ... }
paths:
  exclude_patterns: [ ... ]
thresholds:
  max_widget_lines: 80
  max_file_lines: 300
  max_file_lines_hard: 500
  min_const_ratio: 0.7
```

**MemoX keys move to `profiles/memox/policy.yaml`:**

```yaml
project_name: MemoX
paths:
  core_dir: lib/core
  shared_dir: lib/shared
  features_dir: lib/features
global_guards:
  no_else: true
  no_hardcoded_color: true
  ...
local_guards:
  button_usage: true
  ...
severity_overrides:
  widget_length: warning
  ...
```

**`run.py` change:** Add `--profile` argument defaulting to `tools/guard/profiles/memox/policy.yaml`. The profile YAML is merged into `config` before `PathConstants` and `GuardRegistry` are constructed:

```python
parser.add_argument('--profile', default='tools/guard/profiles/memox/policy.yaml')
...
profile = load_yaml(REPO_ROOT / args.profile)
config = deep_merge(config, profile)   # profile wins on conflict
```

`deep_merge` is a 10-line helper: recursively merge dicts, second dict wins.

**Backwards compatibility:** Default value of `--profile` preserves current behavior. No CLI change needed for existing callers (`python tools/guard/run.py --scope all` still works).

**Acceptance criteria for Phase 3:**
- [ ] `config.yaml` contains no `project_name`, no `global_guards`/`local_guards` enable map, no `severity_overrides`, no named path dirs
- [ ] `profiles/memox/policy.yaml` contains all moved keys
- [ ] `python tools/guard/run.py --scope all` (no explicit `--profile`) identical output
- [ ] `python tools/guard/run.py --scope all --profile tools/guard/profiles/memox/policy.yaml` identical output
- [ ] Tests green (update config fixture paths if needed)

---

### Phase 4 — Generalize `base_guard.py` family key lookup

**What:** Replace the hardcoded `'global_guards'` / `'local_guards'` string literals in `is_enabled` with the guard's own `SCOPE` value mapped through the profile.

**Option A (simplest):** Derive the config key from `SCOPE.value`:

```python
@property
def is_enabled(self) -> bool:
    family_key = f'{self.SCOPE.value}_guards'   # 'global_guards' or 'local_guards'
    return self.config.get(family_key, {}).get(self.GUARD_ID, True)
```

This is a one-line change that removes the hardcoded string without any config change.

**Option B (fully data-driven):** Add a `families:` key to the profile mapping scope → config key:

```yaml
families:
  global: global_guards
  local: local_guards
```

Option A is preferred for Phase 4 — it solves the coupling in one line and avoids over-engineering.

**Acceptance criteria for Phase 4:**
- [ ] `base_guard.py` contains no string literals `'global_guards'` or `'local_guards'`
- [ ] Adding a new `GuardScope.INFRA = 'infra'` and `infra_guards:` in profile works without touching `base_guard.py`
- [ ] Tests green

---

### Phase 5 — Generalize `file_scanner.py` default extension

**What:** Move the `.dart` default into the profile. The engine scanner reads `language_extensions` from config.

**profile addition:**

```yaml
language_extensions: [".dart"]
```

**`file_scanner.py` change:**

```python
def scan(self, scope: str = 'all') -> list[Path]:
    extensions = tuple(self.config.get('language_extensions', ['.dart']))
    ...
```

The `extensions` parameter on `scan()` is removed (it was never called with a custom value anyway). Guards that needed to filter by extension do so through their own path patterns, not by scanner extension override.

**Acceptance criteria for Phase 5:**
- [ ] `file_scanner.py` has no `.dart` string literal
- [ ] `language_extensions` in profile drives scanning
- [ ] Tests green

---

### Phase 6 — Introduce generic guard base types (optional, lower priority)

**What:** For guard families where 3+ guards share the same structural pattern, extract a generic base. This reduces boilerplate and makes adding new project-specific guards trivial — new rules need only YAML entries, not new Python files.

#### Generic types to introduce

| Generic Base | Covers | Pattern |
|---|---|---|
| `PatternForbiddenGuard` | `no_else`, `no_hardcoded_color`, `no_hardcoded_duration`, `no_hardcoded_radius`, `no_hardcoded_size`, `no_hardcoded_font_size`, `no_hardcoded_string`, `legacy_state_notifier` | Regex match → violation, optional whitelist |
| `RequiredWidgetGuard` | `shared_widget`, `screen_scaffold`, `safe_area_keyboard` | Forbidden pattern in file unless whitelisted; requires replacement |
| `FileLengthGuard` | `widget_length`, `widget_class_length` | Count lines within a detected block boundary |
| `NamingConventionGuard` | `naming_convention`, `provider_naming` | File name / symbol name matches regex |
| `RequiredTokensGuard` | `performance_contract`, `typography_scale`, `responsive_text_scale` | File must contain all tokens from a list |
| `FolderStructureGuard` | `folder_structure`, `feature_completeness` | Already project-level; merge into one configurable guard |

**Implementation approach:** Each generic base lives in `core/generic_guards/`. Existing concrete guard classes inherit from the generic base and pass their policy dict. The concrete class stays in `global_guards/` or `local_guards/` — no discovery change needed.

```python
# core/generic_guards/pattern_forbidden_guard.py
class PatternForbiddenGuard(BaseGuard):
    def check_file(self, file_path: Path, lines: list[str]) -> list[Violation]:
        policy = self._get_policy()
        whitelist = tuple(policy.get('whitelist', []))
        patterns = [(re.compile(e['pattern']), e['message']) for e in policy.get('forbidden', [])]
        ...

# global_guards/no_hardcoded_color_guard.py
class NoHardcodedColorGuard(PatternForbiddenGuard):
    GUARD_ID = 'no_hardcoded_color'
    ...
    # No logic — all from project_rules['global_guard_policy']['no_hardcoded_color']
```

**Acceptance criteria for Phase 6:**
- [ ] Each generic base class has its own unit test in `tests/core/`
- [ ] At least `PatternForbiddenGuard` and `RequiredWidgetGuard` are implemented and all covered guards delegate to them
- [ ] No behavior change in output for any guard covered
- [ ] Tests green

---

## 3. Target Structure (post all phases)

```
tools/guard/
├── run.py                         # --profile flag added; description generalized
├── config.yaml                    # Engine-only: language_extensions, source_root, test_root,
│                                  # scope_map, thresholds, exclude_patterns
├── requirements.txt
├── profiles/
│   └── memox/
│       ├── policy.yaml            # project_name, paths (core/shared/features dirs),
│       │                          # global_guards enable map, local_guards enable map,
│       │                          # severity_overrides
│       └── rules.yaml             # (renamed from project_rules.yaml) — all MemoX domain data
├── core/
│   ├── base_guard.py              # SCOPE.value-derived family key; no hardcoded strings
│   ├── guard_family.py            # unchanged
│   ├── guard_registry.py          # unchanged
│   ├── guard_result.py            # unchanged
│   ├── path_constants.py          # scope_map driven; named dirs as computed properties
│   ├── file_scanner.py            # language_extensions from config
│   ├── reporter.py                # unchanged
│   ├── generic_guards/            # (Phase 6 only)
│   │   ├── pattern_forbidden_guard.py
│   │   ├── required_widget_guard.py
│   │   ├── file_length_guard.py
│   │   ├── naming_convention_guard.py
│   │   ├── required_tokens_guard.py
│   │   └── folder_structure_guard.py
│   └── __init__.py
├── global_guards/                 # unchanged location; guards read policy from project_rules
│   ├── family.py
│   ├── no_else_guard.py           # pattern from policy; no hardcoded WHITELIST
│   └── ... (all existing guards)
├── local_guards/                  # unchanged location
│   ├── family.py
│   └── ... (all existing guards)
├── docs/
│   └── refactor_plan_v2.md        # this file
└── tests/
    ├── core/
    ├── global_guards/
    └── local_guards/
```

### What stays the same
- All `GUARD_ID` values — no renaming
- CLI interface (`--scope`, `--family`, `--guard`, `--config`, `--rules`, `--quiet`, `--json`, `--md`, `--fail-on-warnings`)
- Test file locations and import paths
- Guard discovery mechanism (`_discover_classes` via importlib)
- `GuardScope.GLOBAL` / `GuardScope.LOCAL` values

---

## 4. Migration Order and Dependencies

```
Phase 1 (data extraction)
  ↓  no structural change, safest
Phase 2 (scope_map)
  ↓  path_constants change; must update folder_structure_guard.py together
Phase 3 (config split)
  ↓  run.py change + new profiles/ dir; update test fixtures
Phase 4 (family key)
  ↓  one-liner in base_guard.py
Phase 5 (language extensions)
  ↓  one-liner in file_scanner.py + profile entry
Phase 6 (generic guard types)   ← can be done independently of Phase 3-5
```

Phases 1–5 are sequential. Phase 6 is independent and can proceed in parallel once Phase 1 is complete (the generic bases need the policy data to be in `project_rules`).

---

## 5. Compatibility Strategy

### CLI backwards compatibility
- `--config` and `--rules` stay unchanged. `--profile` is additive with a default that points to `profiles/memox/policy.yaml`.
- The merge order is: `config.yaml` → `policy.yaml` → CLI overrides. Profile wins on key conflict.
- After Phase 3, `config.yaml` alone (without `--profile`) produces a valid but incomplete engine config (no guards enabled, no severity overrides) — this is acceptable because the `--profile` default covers the common case.

### Import path stability
- No `tools.guard.core.*` import paths change through Phases 1–5.
- Phase 6 adds `tools.guard.core.generic_guards.*` but does not remove existing paths.

### Test fixture strategy
- Tests that construct `PathConstants` directly should continue to pass because the dataclass fields are not removed — only made optional/computed in Phase 2.
- Tests that load `config.yaml` by path need their fixture path updated in Phase 3 (core test fixtures may need to reference `profiles/memox/policy.yaml`).

### Rollback
- Each phase is a separate commit.
- Phases 1 and 4–5 are pure code edits with no file moves — trivially reversible.
- Phase 2 is a code edit + YAML addition — reversible by reverting both.
- Phase 3 creates a new file and modifies two existing files — reversible by reverting all three.

---

## 6. Risk Points

| Risk | Impact | Mitigation |
|---|---|---|
| `folder_structure_guard.py` scope filter logic uses `path.startswith('lib/core')` — if Phase 2 scope_map and guard are updated separately, the guard breaks | HIGH | Update guard and `path_constants.py` in the same commit |
| `project_rules.yaml` grows large after Phase 1 — whitelist duplication across guards | MEDIUM | Group under `global_guard_policy:` namespace; one block per guard |
| Tests that mock `config` directly will miss `global_guard_policy` if Phase 1 guards use fallback class constants | LOW | Phase 1 keeps class constants as fallback; tests pass until Phase 6 removes them |
| Phase 3 `deep_merge` could silently overwrite engine thresholds if profile redefines them | MEDIUM | `deep_merge` must not overwrite engine-only keys; add key whitelist or document the contract |
| Phase 6 generic base changes guard behavior if policy YAML keys are wrong | HIGH | Keep concrete guard class active as test oracle; add parity test before removing it |
| `guard_family.py` discovery anchors to `Path(__file__).parents[1]` — profiles/memox/guards/ not discoverable without override | LOW | Phase 6 only; add optional `additional_guard_dirs` to config if needed |

---

## 7. Guards Suitable for Generic Conversion (Phase 6 detail)

### Tier 1 — Nearly zero logic, all data (best candidates)

| Guard | Conversion effort | Generic type |
|---|---|---|
| `no_hardcoded_color_guard.py` | minimal | `PatternForbiddenGuard` |
| `no_hardcoded_duration_guard.py` | minimal | `PatternForbiddenGuard` |
| `no_hardcoded_font_size_guard.py` | minimal | `PatternForbiddenGuard` |
| `no_hardcoded_radius_guard.py` | minimal | `PatternForbiddenGuard` |
| `no_hardcoded_size_guard.py` | minimal | `PatternForbiddenGuard` |
| `no_hardcoded_string_guard.py` | minimal | `PatternForbiddenGuard` |
| `legacy_state_notifier_guard.py` | minimal | `PatternForbiddenGuard` |
| `naming_convention_guard.py` | minimal | `NamingConventionGuard` |

### Tier 2 — Some logic, mostly data

| Guard | Notes |
|---|---|
| `shared_widget_guard.py` | pattern→message map; minor comment-skip logic |
| `screen_scaffold_guard.py` | two-condition check (forbidden + required) |
| `widget_length_guard.py` | brace-tracking logic not data-driven; keep as-is |
| `typography_scale_guard.py` | already reads `project_rules`; just needs `RequiredTokensGuard` |
| `performance_contract_guard.py` | already reads `project_rules`; just needs `RequiredTokensGuard` |

### Tier 3 — Keep as concrete (non-trivial logic)

| Guard | Reason to keep concrete |
|---|---|
| `import_direction_guard.py` | Layer graph traversal logic |
| `widget_length_guard.py` | Brace-depth tracking |
| `widget_class_length_guard.py` | Brace-depth tracking |
| `drift_table_guard.py` | AST-like column parsing |
| `riverpod_syntax_guard.py` | Multi-condition file classification |
| `test_coverage_guard.py` | Cross-directory correlation logic |
| `feature_completeness_guard.py` | Directory existence + content check |
| `folder_structure_guard.py` | Multi-layer structure validation |

---

## 8. Checklist Summary

### Phase 1 — Policy data extraction
- [ ] Add `global_guard_policy:` section to `project_rules.yaml` covering all 7 global guard whitelists
- [ ] Add entries for 7 local guards that have in-code symbol lists
- [ ] Update each affected guard to read from `self.project_rules` with class-constant fallback
- [ ] `python tools/guard/run.py --scope all` output unchanged
- [ ] `pytest tools/guard/tests/` green

### Phase 2 — Scope map
- [ ] Add `scope_map:` to `config.yaml`
- [ ] Refactor `PathConstants.scope_roots()` to use `_scope_map` dict
- [ ] Update `folder_structure_guard.py` to use config-driven scope filter
- [ ] Verify all 5 named scopes produce same file lists as before
- [ ] `pytest tools/guard/tests/` green

### Phase 3 — Profile split
- [ ] Create `profiles/memox/policy.yaml` with moved keys
- [ ] Trim `config.yaml` to engine-only keys
- [ ] Add `--profile` to `run.py` with default pointing to memox profile
- [ ] Implement `deep_merge` helper in `run.py`
- [ ] Update test fixtures that reference `config.yaml` directly
- [ ] `python tools/guard/run.py --scope all` output unchanged
- [ ] `pytest tools/guard/tests/` green

### Phase 4 — Family key derivation
- [ ] Replace `'global_guards'`/`'local_guards'` literals in `base_guard.py` with `f'{self.SCOPE.value}_guards'`
- [ ] Verify `is_enabled` logic unchanged for all guards
- [ ] `pytest tools/guard/tests/` green

### Phase 5 — Language extensions
- [ ] Add `language_extensions: [".dart"]` to `config.yaml`
- [ ] Remove `.dart` literal from `file_scanner.py:scan()` default
- [ ] `pytest tools/guard/tests/` green

### Phase 6 — Generic guard types (separate work item)
- [ ] Implement `PatternForbiddenGuard` in `core/generic_guards/`
- [ ] Convert Tier 1 guards to use it; verify parity with original output
- [ ] Implement `RequiredTokensGuard`; convert `performance_contract`, `typography_scale`
- [ ] Implement `RequiredWidgetGuard`; convert `shared_widget`, `screen_scaffold`
- [ ] Add generic guard base unit tests
- [ ] `pytest tools/guard/tests/` green

---

*End of refactor plan.*
