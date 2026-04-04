# MemoX Guard — AI Output Validation Tool

> Python CLI tool that validates AI-generated Flutter code against project conventions.
> Runs as CI gate or manual check after each task.

---

## Architecture

**Abstract Factory pattern** with 2 guard families:

- **Global guards** (`global_guards/`): Portable Flutter conventions. Copy to any project.
- **Local guards** (`local_guards/`): MemoX-specific rules. Rewrite for new projects.

Adding a new guard = adding 1 file to the correct family. No factory changes needed.

---

## Folder Structure

```text
tools/guard/
├── run.py                             # CLI entry point
├── config.yaml                        # Generic config (paths, thresholds, toggles)
├── project_rules.yaml                 # MemoX-specific rules (colors, structure, widgets)
├── requirements.txt                   # pyyaml, rich
│
├── core/                              # Engine (do not modify)
│   ├── base_guard.py                  # Abstract BaseGuard + GuardScope enum
│   ├── guard_family.py                # Abstract GuardFamily (Abstract Factory)
│   ├── guard_registry.py              # Discovers families → creates all guards
│   ├── guard_result.py                # Violation, GuardResult dataclasses
│   ├── file_scanner.py                # Glob scanner with exclusions
│   ├── path_constants.py              # Loaded from config.yaml
│   └── reporter.py                    # Output: terminal, JSON, Markdown
│
├── global_guards/                     # Family 1: Portable (copy as-is)
│   ├── family.py                      # GlobalGuardFamily(GuardFamily)
│   ├── no_else_guard.py
│   ├── no_hardcoded_color_guard.py
│   ├── no_hardcoded_duration_guard.py
│   ├── no_hardcoded_radius_guard.py
│   ├── no_hardcoded_size_guard.py
│   ├── no_hardcoded_font_size_guard.py
│   ├── no_hardcoded_string_guard.py
│   ├── shared_widget_guard.py
│   ├── widget_length_guard.py
│   ├── widget_class_length_guard.py
│   ├── const_constructor_guard.py
│   ├── import_direction_guard.py
│   ├── async_builder_guard.py
│   ├── icon_style_guard.py
│   ├── l10n_guard.py
│   └── naming_convention_guard.py
│
├── local_guards/                      # Family 2: MemoX-only (rewrite for new project)
│   ├── family.py                      # LocalGuardFamily(GuardFamily)
│   ├── folder_structure_guard.py
│   ├── color_palette_guard.py
│   ├── design_token_usage_guard.py
│   ├── feature_completeness_guard.py
│   ├── drift_table_guard.py
│   ├── provider_naming_guard.py
│   ├── shared_widget_mapping_guard.py
│   ├── srs_field_guard.py
│   ├── riverpod_syntax_guard.py
│   ├── button_usage_guard.py
│   ├── legacy_state_notifier_guard.py
│   ├── l10n_source_guard.py
│   ├── text_style_guard.py
│   ├── test_coverage_guard.py
│   ├── freezed_json_model_guard.py
│   ├── records_patterns_guard.py
│   ├── safe_area_keyboard_guard.py
│   ├── screen_scaffold_guard.py
│   ├── refresh_retry_guard.py
│   ├── touch_target_guard.py
│   ├── responsive_layout_test_guard.py
│   ├── responsive_text_scale_guard.py
│   ├── typography_scale_guard.py
│   └── performance_contract_guard.py
│
└── tests/                             # Full test coverage
    ├── core/
    │   ├── test_guard_registry.py
    │   └── test_file_scanner.py
    ├── global_guards/
    │   └── test_*.py (one per guard)
    └── local_guards/
        └── test_*.py (one per guard)
```

### Why 2 families?

| Global guards | Local guards |
|---------------|-------------|
| Don't know MemoX exists | Know MemoX folder structure |
| Don't know Drift or table schemas | Know Drift tables need specific columns |
| Don't know color palette | Know ColorTokens allows only 6 seed colors |
| Check coding conventions only | Check business rules |
| Copy to React, Go, Rust projects | Rewrite 100% for new project |
| Config via `config.yaml` (generic) | Config via `project_rules.yaml` (specific) |

---

## CLI Usage

```bash
# Run all guards
python tools/guard/run.py

# Run with scope (maps to lib/ subdirectory)
python tools/guard/run.py --scope core
python tools/guard/run.py --scope shared
python tools/guard/run.py --scope features
python tools/guard/run.py --scope all          # default

# Run only one family
python tools/guard/run.py --family global
python tools/guard/run.py --family local

# Run specific guard(s)
python tools/guard/run.py --guard no_else,shared_widget

# List all available guards
python tools/guard/run.py --list

# Verbose (show violation line content)
python tools/guard/run.py -v

# CI output
python tools/guard/run.py --json report.json
python tools/guard/run.py --md report.md

# Custom config
python tools/guard/run.py --config custom_config.yaml --rules custom_rules.yaml
```

---

## Config

### `config.yaml` — Generic (change when reusing)

```yaml
project_name: "MemoX"
language: "dart"
source_root: "lib"
test_root: "test"

paths:
  core_dir: "lib/core"
  shared_dir: "lib/shared"
  features_dir: "lib/features"
  exclude_patterns:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "**/*.config.dart"
    - "**/l10n/generated/**"
    - "**/gen/**"

thresholds:
  max_widget_lines: 80
  max_file_lines: 300
  max_file_lines_hard: 500
  min_const_ratio: 0.7

global_guards:
  no_else: true
  no_hardcoded_color: true
  no_hardcoded_duration: true
  no_hardcoded_radius: true
  no_hardcoded_size: true
  no_hardcoded_font_size: true
  no_hardcoded_string: true
  shared_widget: true
  widget_length: true
  widget_class_length: true
  const_constructor: true
  import_direction: true
  icon_style: true
  async_builder: true
  l10n: true
  naming_convention: true

local_guards:
  folder_structure: true
  color_palette: true
  design_token_usage: true
  feature_completeness: true
  drift_table: true
  provider_naming: true
  shared_widget_mapping: true
  srs_field: true
  riverpod_syntax: true
  button_usage: true
  legacy_state_notifier: true
  l10n_source: true
  text_style: true
  test_coverage: true
  freezed_json_model: true
  records_patterns: true
  safe_area_keyboard: true
  screen_scaffold: true
  refresh_retry: true
  touch_target: true
  responsive_layout_test: true
  responsive_text_scale: true
  typography_scale: true
  performance_contract: true

severity_overrides:
  widget_length: "warning"
  const_constructor: "warning"
  folder_structure: "info"
  icon_style: "warning"
```

### `project_rules.yaml` — MemoX-Specific (rewrite for new project)

```yaml
color_palette:
  seed_colors:
    - name: "indigo"
      hex: "0xFF5C6BC0"
    - name: "teal"
      hex: "0xFF4DB6AC"
    - name: "rose"
      hex: "0xFFE57373"
    - name: "amber"
      hex: "0xFFFFB74D"
    - name: "slate"
      hex: "0xFF78909C"
    - name: "sage"
      hex: "0xFF81C784"

  semantic_colors:
    success_light: "0xFF4DB6AC"
    success_dark: "0xFF80CBC4"
    warning_light: "0xFFFFB74D"
    warning_dark: "0xFFFFCC80"
    error_light: "0xFFE57373"
    error_dark: "0xFFEF9A9A"
    mastery_light: "0xFF66BB6A"
    mastery_dark: "0xFF81C784"

  status_colors:
    new: "0xFF9E9E9E"
    learning: "0xFFFFB74D"
    reviewing: "0xFF5C6BC0"
    mastered: "0xFF4DB6AC"

folder_structure:
  required_root_dirs:
    - "lib/core"
    - "lib/shared"
    - "lib/features"
  required_features:
    - "folders"
    - "decks"
    - "cards"
    - "study"
    - "statistics"
    - "settings"
    - "search"
  feature_layers: ["data", "domain", "presentation"]
  data_subdirs: ["tables", "daos", "mappers", "repositories"]
  domain_subdirs: ["entities", "repositories", "usecases"]
  presentation_subdirs: ["screens", "widgets", "providers"]
  core_required_dirs:
    - "lib/core/theme/tokens"
    - "lib/core/theme/color_schemes"
    - "lib/core/theme/text_themes"
    - "lib/core/responsive"
    - "lib/core/router"
    - "lib/core/constants"
    - "lib/core/utils"
    - "lib/core/extensions"
    - "lib/core/mixins"
    - "lib/core/errors"
    - "lib/core/database"
    - "lib/core/database/tables"
    - "lib/core/database/daos"
    - "lib/core/backup"
    - "lib/core/services"
    - "lib/core/providers"
    - "lib/core/types"

drift_tables:
  folders_table:
    required_columns: ["id", "name", "parentId", "colorValue", "createdAt", "updatedAt", "sortOrder"]
  decks_table:
    required_columns: ["id", "name", "folderId", "colorValue", "tags", "createdAt", "updatedAt"]
  cards_table:
    required_columns: ["id", "deckId", "front", "back", "status", "easeFactor", "interval", "repetitions", "nextReviewDate"]
  study_sessions_table:
    required_columns: ["id", "deckId", "mode", "startedAt", "totalCards", "correctCount", "wrongCount"]
  card_reviews_table:
    required_columns: ["id", "cardId", "sessionId", "mode", "isCorrect", "reviewedAt"]

design_tokens:
  "ColorTokens": "lib/core/theme/tokens/color_tokens.dart"
  "TypographyTokens": "lib/core/theme/tokens/typography_tokens.dart"
  "SpacingTokens": "lib/core/theme/tokens/spacing_tokens.dart"
  "SizeTokens": "lib/core/theme/tokens/size_tokens.dart"
  "RadiusTokens": "lib/core/theme/tokens/radius_tokens.dart"
  "ElevationTokens": "lib/core/theme/tokens/elevation_tokens.dart"
  "DurationTokens": "lib/core/theme/tokens/duration_tokens.dart"
  "EasingTokens": "lib/core/theme/tokens/easing_tokens.dart"
  "OpacityTokens": "lib/core/theme/tokens/opacity_tokens.dart"

shared_widget_mapping:
  study_screens:
    path_pattern: "features/study/presentation/screens/*_mode_screen.dart"
    required_widgets: ["StudyTopBar", "SessionCompleteView"]
    forbidden_widgets: ["AppBar(", "Scaffold(appBar:"]
  list_screens:
    path_pattern: "features/*/presentation/screens/*_screen.dart"
    required_widgets: []
    forbidden_in_list_context: ["Dismissible("]

provider_naming:
  repository_pattern: "^\\w+RepositoryProvider$"
  usecase_pattern: "^\\w+UseCaseProvider$"
  controller_pattern: "^\\w+ControllerProvider$"
```

---

## Guard Registry — Complete Reference

### Global Guards (16)

| ID | Severity | What it checks |
|----|----------|---------------|
| `no_else` | error | `} else {` or `} else if (` |
| `no_hardcoded_color` | error | `Color(0x...)`, `Colors.xxx`, `Color.fromRGBO/ARGB` |
| `no_hardcoded_duration` | error | `Duration(milliseconds: N)` |
| `no_hardcoded_radius` | error | `BorderRadius.circular(N)` |
| `no_hardcoded_size` | error | `SizedBox(height: N)`, `width: N` (literal) |
| `no_hardcoded_font_size` | error | `fontSize: N` (literal number) |
| `no_hardcoded_string` | error | Hardcoded strings in AppBar title, Dialog title |
| `shared_widget` | error | Raw `Card()`, `.when()`, `ElevatedButton()`, `Dismissible()`, `ScaffoldMessenger` |
| `widget_length` | warning | `build()` method exceeds `max_widget_lines` |
| `widget_class_length` | warning | Widget class exceeds max lines |
| `const_constructor` | warning | StatelessWidget missing `const` constructor |
| `import_direction` | error | Domain imports data/presentation, presentation imports data |
| `icon_style` | warning | `Icons.xxx` missing `_outlined` suffix |
| `async_builder` | error | Raw `.when()` instead of `AppAsyncBuilder` |
| `l10n` | warning | `Text('hardcoded string')` |
| `naming_convention` | warning | File names not snake_case |

### Local Guards (24)

| ID | Severity | What it checks |
|----|----------|---------------|
| `folder_structure` | info | Feature missing `data/domain/presentation` structure |
| `color_palette` | error | Colors outside allowed palette in token files |
| `design_token_usage` | error | Token class in wrong file |
| `feature_completeness` | error | Feature missing required subdirs |
| `drift_table` | error | Drift table missing required columns |
| `provider_naming` | warning | Provider naming convention |
| `shared_widget_mapping` | error | Wrong widget in context (e.g., `AppBar` in study screen) |
| `srs_field` | error | Cards table missing SRS fields |
| `riverpod_syntax` | error | Non-annotation Riverpod syntax |
| `button_usage` | error | Raw button widgets instead of shared buttons |
| `legacy_state_notifier` | error | Legacy StateNotifier usage |
| `l10n_source` | warning | Missing l10n keys or wrong ARB structure |
| `text_style` | error | Hardcoded text styles instead of theme |
| `test_coverage` | warning | Feature missing test files |
| `freezed_json_model` | error | Freezed/JSON model conventions |
| `records_patterns` | warning | Dart 3.5 records/patterns usage opportunities |
| `safe_area_keyboard` | warning | Missing SafeArea or keyboard handling |
| `screen_scaffold` | error | Screen scaffold conventions |
| `refresh_retry` | warning | Missing refresh/retry in async screens |
| `touch_target` | warning | Touch targets below minimum size |
| `responsive_layout_test` | warning | Missing responsive layout tests |
| `responsive_text_scale` | error | Missing text scale in app shell |
| `typography_scale` | error | Font sizes outside constrained type scale |
| `performance_contract` | warning | Performance anti-patterns |

---

## Core Architecture

### BaseGuard

```python
class GuardScope(Enum):
    GLOBAL = "global"
    LOCAL = "local"

class BaseGuard(ABC):
    GUARD_ID: ClassVar[str] = ""
    GUARD_NAME: ClassVar[str] = ""
    DESCRIPTION: ClassVar[str] = ""
    DEFAULT_SEVERITY: ClassVar[Severity] = Severity.ERROR
    SCOPE: ClassVar[GuardScope] = GuardScope.GLOBAL

    def __init__(self, config, path_constants, project_rules=None):
        ...

    def check_file(self, file_path: Path, lines: list[str]) -> list[Violation]:
        """Override for per-file checks."""
        return []

    def check_project(self, all_files: list[Path]) -> list[Violation]:
        """Override for cross-file checks."""
        return []

    @property
    def is_file_level(self) -> bool:
        return True  # False → calls check_project instead
```

### GuardFamily (Abstract Factory)

```python
class GuardFamily(ABC):
    FAMILY_ID: str
    SCOPE: GuardScope
    GUARDS_DIR: str

    @abstractmethod
    def create_guards(self) -> list[BaseGuard]: ...

    def _discover_classes(self) -> list[Type[BaseGuard]]:
        """Auto-discovers guard classes from GUARDS_DIR."""
        ...
```

- `GlobalGuardFamily`: creates guards from `global_guards/`, never reads `project_rules.yaml`
- `LocalGuardFamily`: creates guards from `local_guards/`, always reads `project_rules.yaml`

### GuardRegistry (Orchestrator)

```python
class GuardRegistry:
    def create_all(self) -> list[BaseGuard]: ...
    def create_by_ids(self, ids: list[str]) -> list[BaseGuard]: ...
    def create_by_scope(self, scope: GuardScope) -> list[BaseGuard]: ...
    def list_available(self) -> list[dict]: ...
```

### Reporter

Output formats:
- **Terminal**: Colored output with pass/fail icons, violation details
- **JSON**: For CI pipelines (`--json report.json`)
- **Markdown**: For PR comments (`--md report.md`)

---

## Adding a New Guard

```
1. Decide family: global (portable) or local (MemoX-specific)

2. Create file in the correct directory:
   tools/guard/global_guards/my_guard.py   # or
   tools/guard/local_guards/my_guard.py

3. Implement:
   class MyGuard(BaseGuard):
       GUARD_ID = "my_guard"
       GUARD_NAME = "Human readable name"
       DESCRIPTION = "What this checks"
       DEFAULT_SEVERITY = Severity.ERROR
       SCOPE = GuardScope.GLOBAL  # or LOCAL

       def check_file(self, file_path, lines):
           # return list of Violations

4. (Optional) Add toggle to config.yaml:
   global_guards:  # or local_guards:
     my_guard: true

5. Done. Family auto-discovers it.
```

---

## CI Integration

```yaml
# .github/workflows/guard.yml
- name: Run Guard Checks
  run: |
    pip install pyyaml rich
    python tools/guard/run.py --json guard-report.json

- name: Comment PR with results
  if: failure()
  run: |
    python tools/guard/run.py --md guard-report.md
    gh pr comment $PR_NUMBER --body-file guard-report.md
```

---

## Reuse for Another Project

```
1. Copy tools/guard/ to new project
2. Edit config.yaml: project_name, paths, thresholds, guard toggles
3. Rewrite project_rules.yaml with new project's rules
4. Rewrite local_guards/ for new project's conventions
5. Keep global_guards/ and core/ unchanged
```
