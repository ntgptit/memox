# 🛡️ MemoX Guard — AI Output Validation Tool

> **Mục đích**: Python CLI tool kiểm tra tính đúng đắn của code sau khi AI tool
> (Claude Code / Codex) hoàn thành task. Chạy như CI gate hoặc manual check.
>
> **Thiết kế**: Abstract Factory pattern — 2 families of guards:
> - **Global guards**: reusable cho mọi Flutter project (no-else, hardcoded values, SOLID...)
> - **Local guards**: project-specific (MemoX folder structure, color palette, widget mapping...)
>
> Thêm guard mới = thêm 1 file vào đúng family. Không sửa factory, không sửa guard cũ.
>
> **Tái sử dụng**: Copy `global_guards/` nguyên vẹn sang project khác.
> Chỉ viết lại `local_guards/` và `config.yaml` cho project mới.

---

## 📂 FOLDER STRUCTURE

```
tools/
└── guard/
    ├── run.py                             # CLI entry point
    ├── config.yaml                        # Project-specific config (THAY ĐỔI KHI REUSE)
    ├── project_rules.yaml                 # Local guard definitions (colors, structure, widgets)
    ├── requirements.txt                   # pyyaml, rich
    │
    ├── core/                              # ━━━ Engine (KHÔNG BAO GIỜ SỬA) ━━━
    │   ├── __init__.py
    │   ├── base_guard.py                  # Abstract BaseGuard class
    │   ├── guard_family.py                # Abstract GuardFamily (Abstract Factory interface)
    │   ├── guard_registry.py              # Discovers families → creates all guards
    │   ├── guard_result.py                # Violation, GuardResult dataclasses
    │   ├── file_scanner.py                # Glob scanner: find files, exclude generated
    │   ├── path_constants.py              # Load from config.yaml → PathConstants object
    │   └── reporter.py                    # Output: terminal, JSON, Markdown
    │
    ├── global_guards/                     # ━━━ Family 1: Portable (COPY NGUYÊN VẸN) ━━━
    │   ├── __init__.py
    │   ├── family.py                      # GlobalGuardFamily(GuardFamily)
    │   ├── no_else_guard.py
    │   ├── no_hardcoded_color_guard.py
    │   ├── no_hardcoded_duration_guard.py
    │   ├── no_hardcoded_radius_guard.py
    │   ├── no_hardcoded_size_guard.py
    │   ├── no_hardcoded_font_size_guard.py
    │   ├── shared_widget_guard.py         # configurable via config.yaml
    │   ├── widget_length_guard.py
    │   ├── const_constructor_guard.py
    │   ├── import_direction_guard.py
    │   ├── async_builder_guard.py
    │   ├── icon_style_guard.py
    │   ├── l10n_guard.py
    │   ├── naming_convention_guard.py
    │   └── no_hardcoded_string_guard.py
    │
    ├── local_guards/                      # ━━━ Family 2: MemoX-only (VIẾT LẠI CHO PROJECT MỚI) ━━━
    │   ├── __init__.py
    │   ├── family.py                      # LocalGuardFamily(GuardFamily)
    │   ├── folder_structure_guard.py      # Kiến trúc folder/file đúng spec
    │   ├── color_palette_guard.py         # Chỉ dùng màu trong palette cho trước
    │   ├── design_token_usage_guard.py    # Token classes phải đúng naming + đúng file
    │   ├── feature_completeness_guard.py  # Feature phải có đủ data/domain/presentation
    │   ├── drift_table_guard.py           # Drift tables phải có đủ required columns
    │   ├── provider_naming_guard.py       # Provider naming convention đúng spec
    │   ├── shared_widget_mapping_guard.py # Đúng widget cho đúng context (AppCard, StudyTopBar...)
    │   └── srs_field_guard.py             # Cards table phải có đủ SRS fields
    │
    └── tests/
        ├── core/
        │   ├── test_guard_registry.py
        │   └── test_file_scanner.py
        ├── global_guards/
        │   ├── test_no_else_guard.py
        │   └── ...
        └── local_guards/
            ├── test_folder_structure_guard.py
            └── ...
```

### Tại sao tách thành 2 families?

```
global_guards/                          local_guards/
├── Không biết MemoX là gì               ├── Biết MemoX folder structure
├── Không biết Drift hay Isar            ├── Biết Drift tables cần columns nào
├── Không biết palette màu               ├── Biết ColorTokens chỉ cho phép 6 seed colors
├── Chỉ check coding conventions         ├── Check business rules cụ thể
├── Copy nguyên sang React, Go, Rust...  ├── Viết lại 100% cho project mới
└── Config qua config.yaml (generic)     └── Config qua project_rules.yaml (specific)
```

---

## ⚙️ CONFIG — Project-Specific (thay đổi khi reuse)

```yaml
# tools/guard/config.yaml
# ━━━ GENERIC CONFIG — thay đổi khi reuse sang project khác ━━━

# ── Project Info ──
project_name: "MemoX"
language: "dart"                        # dart | kotlin | swift | typescript
source_root: "lib"
test_root: "test"

# ── Path Patterns ──
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

# ── Global Guard Thresholds (portable) ──
thresholds:
  max_widget_lines: 80
  max_file_lines: 300
  max_file_lines_hard: 500
  min_const_ratio: 0.7

# ── Guard Toggles ──
# Global guards: ON by default, turn off if not relevant cho project
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
  const_constructor: true
  import_direction: true
  icon_style: true
  async_builder: true
  l10n: true
  naming_convention: true

# Local guards: project-specific, đọc rules từ project_rules.yaml
local_guards:
  folder_structure: true
  color_palette: true
  design_token_usage: true
  feature_completeness: true
  drift_table: true
  provider_naming: true
  shared_widget_mapping: true
  srs_field: true

# ── Severity Overrides ──
severity_overrides:
  widget_length: "warning"
  const_constructor: "warning"
  folder_structure: "info"
  icon_style: "warning"
```

```yaml
# tools/guard/project_rules.yaml
# ━━━ MEMOX-SPECIFIC RULES — viết lại 100% cho project mới ━━━
# Local guards đọc file này để biết "project cần gì cụ thể"

# ── Allowed Color Palette ──
# Chỉ những hex values này được phép xuất hiện trong token files
# Guard sẽ check: color_tokens.dart chỉ chứa colors trong list này
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

# ── Required Folder Structure ──
# Guard sẽ check: mỗi feature PHẢI có đúng structure này
folder_structure:
  # Top-level required directories
  required_root_dirs:
    - "lib/core"
    - "lib/shared"
    - "lib/features"

  # Required features
  required_features:
    - "folders"
    - "decks"
    - "cards"
    - "study"
    - "statistics"
    - "settings"
    - "search"

  # Each feature must have these subdirs
  feature_layers:
    - "data"
    - "domain"
    - "presentation"

  # data/ must contain
  data_subdirs:
    - "tables"        # Drift
    - "daos"
    - "mappers"
    - "repositories"

  # domain/ must contain
  domain_subdirs:
    - "entities"
    - "repositories"
    - "usecases"

  # presentation/ must contain
  presentation_subdirs:
    - "screens"
    - "widgets"
    - "providers"

  # Core required structure
  core_required_dirs:
    - "lib/core/theme/tokens"
    - "lib/core/theme/color_schemes"
    - "lib/core/theme/component_themes"
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

# ── Drift Table Required Fields ──
# Guard check: mỗi table PHẢI có ít nhất các columns này
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

# ── Design Token File Mapping ──
# Guard check: token class phải nằm đúng file
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

# ── Shared Widget → Context Mapping ──
# Guard check: trong study mode screens, PHẢI dùng StudyTopBar không phải AppBar tự build
shared_widget_mapping:
  study_screens:
    path_pattern: "features/study/presentation/screens/*_mode_screen.dart"
    required_widgets:
      - "StudyTopBar"
      - "SessionCompleteView"
    forbidden_widgets:
      - "AppBar("
      - "Scaffold(appBar:"

  list_screens:
    path_pattern: "features/*/presentation/screens/*_screen.dart"
    required_widgets: []
    forbidden_in_list_context:
      - "Dismissible("   # dùng AppSlidableRow

# ── Provider Naming Convention ──
provider_naming:
  # Providers for repositories: xxxRepositoryProvider
  repository_pattern: "^\\w+RepositoryProvider$"
  # Providers for use cases: xxxUseCaseProvider
  usecase_pattern: "^\\w+UseCaseProvider$"
  # Controllers: xxxControllerProvider
  controller_pattern: "^\\w+ControllerProvider$"
```

---

## 🏗️ CORE — Abstract Factory Pattern

### Class Diagram

```
                    ┌───────────────────┐
                    │   GuardRegistry    │  ← orchestrator
                    │   (discovers       │
                    │    families)       │
                    └─────────┬─────────┘
                              │ discovers & delegates
                    ┌─────────┴─────────┐
                    │                   │
          ┌─────────▼────────┐ ┌────────▼─────────┐
          │   GuardFamily    │ │   GuardFamily     │  ← abstract factory
          │   (abstract)     │ │   (abstract)      │
          └─────────┬────────┘ └────────┬──────────┘
                    │                   │
        ┌───────────▼──────┐  ┌─────────▼──────────┐
        │ GlobalGuardFamily │  │ LocalGuardFamily   │  ← concrete factories
        │ (portable rules)  │  │ (project rules)    │
        └───────────┬──────┘  └─────────┬──────────┘
                    │                   │
            ┌───────▼───────┐   ┌───────▼────────┐
            │ NoElseGuard   │   │ FolderStructure │  ← concrete products
            │ HardcodedColor│   │ ColorPalette    │
            │ WidgetLength  │   │ DriftTable      │
            │ ...           │   │ ...             │
            └───────────────┘   └────────────────┘
```

**Key change từ Factory → Abstract Factory:**
- `BaseGuard` thêm `SCOPE` (GLOBAL/LOCAL) và nhận `project_rules` optional
- `GuardFamily` (abstract) thay thế `GuardFactory` — mỗi family tự discover guards của mình
- `GlobalGuardFamily` — tạo guards từ `global_guards/`, KHÔNG đọc `project_rules.yaml`
- `LocalGuardFamily` — tạo guards từ `local_guards/`, LUÔN đọc `project_rules.yaml`
- `GuardRegistry` — orchestrator, collect guards từ tất cả families
- CLI thêm `--family global|local` flag để chạy 1 family cụ thể

### BaseGuard (Abstract Product — thêm SCOPE + project_rules)

```python
# tools/guard/core/base_guard.py
# THAY ĐỔI: thêm GuardScope enum, Violation/GuardResult có scope field,
# BaseGuard nhận project_rules, is_enabled check đúng family key

from abc import ABC
from dataclasses import dataclass, field
from enum import Enum
from pathlib import Path
from typing import ClassVar


class Severity(Enum):
    ERROR = "error"
    WARNING = "warning"
    INFO = "info"


class GuardScope(Enum):
    GLOBAL = "global"     # portable across projects
    LOCAL = "local"       # project-specific


@dataclass
class Violation:
    file_path: str
    line_number: int
    line_content: str
    message: str
    guard_id: str
    severity: Severity
    scope: GuardScope = GuardScope.GLOBAL

    @property
    def location(self) -> str:
        return f"{self.file_path}:{self.line_number}"


@dataclass
class GuardResult:
    guard_id: str
    guard_name: str
    description: str
    scope: GuardScope = GuardScope.GLOBAL
    violations: list[Violation] = field(default_factory=list)
    files_scanned: int = 0
    duration_ms: float = 0.0

    @property
    def passed(self) -> bool:
        return not any(v.severity == Severity.ERROR for v in self.violations)

    @property
    def error_count(self) -> int:
        return sum(1 for v in self.violations if v.severity == Severity.ERROR)

    @property
    def warning_count(self) -> int:
        return sum(1 for v in self.violations if v.severity == Severity.WARNING)


class BaseGuard(ABC):
    """
    Abstract base for all guards (global + local).
    Subclass sets: GUARD_ID, GUARD_NAME, DESCRIPTION, DEFAULT_SEVERITY, SCOPE.
    Implement check_file() for per-file regex, or check_project() for cross-file analysis.
    """

    GUARD_ID: ClassVar[str] = ""
    GUARD_NAME: ClassVar[str] = ""
    DESCRIPTION: ClassVar[str] = ""
    DEFAULT_SEVERITY: ClassVar[Severity] = Severity.ERROR
    SCOPE: ClassVar[GuardScope] = GuardScope.GLOBAL

    def __init__(self, config: dict, path_constants: "PathConstants",
                 project_rules: dict | None = None):
        self.config = config
        self.paths = path_constants
        self.project_rules = project_rules or {}
        self.severity = self._resolve_severity()

    def _resolve_severity(self) -> Severity:
        overrides = self.config.get("severity_overrides", {})
        if val := overrides.get(self.GUARD_ID):
            return Severity(val)
        return self.DEFAULT_SEVERITY

    @property
    def is_enabled(self) -> bool:
        family_key = "global_guards" if self.SCOPE == GuardScope.GLOBAL else "local_guards"
        return self.config.get(family_key, {}).get(self.GUARD_ID, True)

    def check_file(self, file_path: Path, lines: list[str]) -> list[Violation]:
        return []

    def check_project(self, all_files: list[Path]) -> list[Violation]:
        return []

    @property
    def is_file_level(self) -> bool:
        return True
```

### GuardFamily (Abstract Factory)

```python
# tools/guard/core/guard_family.py

from abc import ABC, abstractmethod
from pathlib import Path
from typing import Type
from .base_guard import BaseGuard, GuardScope


class GuardFamily(ABC):
    """
    Abstract Factory interface. Each family discovers + creates its own guards.
    Adding a new family: create folder + family.py, register in GuardRegistry.
    """

    FAMILY_ID: str = ""
    FAMILY_NAME: str = ""
    SCOPE: GuardScope = GuardScope.GLOBAL
    GUARDS_DIR: str = ""   # e.g. "global_guards"

    def __init__(self, config: dict, path_constants: "PathConstants",
                 project_rules: dict | None = None):
        self.config = config
        self.path_constants = path_constants
        self.project_rules = project_rules

    @abstractmethod
    def create_guards(self) -> list[BaseGuard]:
        ...

    def _discover_classes(self) -> list[Type[BaseGuard]]:
        import importlib, inspect
        guards_dir = Path(__file__).parent.parent / self.GUARDS_DIR
        classes = []
        for py_file in sorted(guards_dir.glob("*.py")):
            if py_file.name.startswith("_") or py_file.name == "family.py":
                continue
            module_name = f"{self.GUARDS_DIR}.{py_file.stem}"
            try:
                module = importlib.import_module(module_name)
            except ImportError:
                continue
            for _, obj in inspect.getmembers(module, inspect.isclass):
                if issubclass(obj, BaseGuard) and obj is not BaseGuard and obj.GUARD_ID:
                    classes.append(obj)
        return classes
```

### Concrete Factories

```python
# tools/guard/global_guards/family.py

from core.base_guard import BaseGuard, GuardScope
from core.guard_family import GuardFamily

class GlobalGuardFamily(GuardFamily):
    """Portable guards. Copy to any project. Never reads project_rules."""
    FAMILY_ID = "global"
    FAMILY_NAME = "Global Guards (portable)"
    SCOPE = GuardScope.GLOBAL
    GUARDS_DIR = "global_guards"

    def create_guards(self) -> list[BaseGuard]:
        return [
            cls(config=self.config, path_constants=self.path_constants, project_rules=None)
            for cls in self._discover_classes()
            if cls(config=self.config, path_constants=self.path_constants).is_enabled
        ]


# tools/guard/local_guards/family.py

from core.base_guard import BaseGuard, GuardScope
from core.guard_family import GuardFamily

class LocalGuardFamily(GuardFamily):
    """MemoX-specific guards. Reads project_rules.yaml. Rewrite for new project."""
    FAMILY_ID = "local"
    FAMILY_NAME = "Local Guards (MemoX-specific)"
    SCOPE = GuardScope.LOCAL
    GUARDS_DIR = "local_guards"

    def create_guards(self) -> list[BaseGuard]:
        if not self.project_rules:
            return []
        return [
            cls(config=self.config, path_constants=self.path_constants,
                project_rules=self.project_rules)
            for cls in self._discover_classes()
            if cls(config=self.config, path_constants=self.path_constants,
                   project_rules=self.project_rules).is_enabled
        ]
```

### GuardRegistry (Orchestrator)

```python
# tools/guard/core/guard_registry.py

import importlib
from typing import Type
from .base_guard import BaseGuard, GuardScope
from .guard_family import GuardFamily
from .path_constants import PathConstants


class GuardRegistry:
    """Discovers families → delegates creation → collects all guards."""

    FAMILY_MODULES: list[tuple[str, str]] = [
        ("global_guards.family", "GlobalGuardFamily"),
        ("local_guards.family", "LocalGuardFamily"),
    ]

    def __init__(self, config: dict, path_constants: PathConstants,
                 project_rules: dict | None = None):
        self.config = config
        self.path_constants = path_constants
        self.project_rules = project_rules
        self._families = self._init_families()

    def _init_families(self) -> list[GuardFamily]:
        families = []
        for mod_path, cls_name in self.FAMILY_MODULES:
            try:
                mod = importlib.import_module(mod_path)
                cls: Type[GuardFamily] = getattr(mod, cls_name)
                families.append(cls(self.config, self.path_constants, self.project_rules))
            except (ImportError, AttributeError) as e:
                print(f"[warn] Family {mod_path}.{cls_name}: {e}")
        return families

    def create_all(self) -> list[BaseGuard]:
        guards = []
        for family in self._families:
            guards.extend(family.create_guards())
        guards.sort(key=lambda g: (g.SCOPE.value, g.GUARD_ID))
        return guards

    def create_by_ids(self, ids: list[str]) -> list[BaseGuard]:
        return [g for g in self.create_all() if g.GUARD_ID in ids]

    def create_by_scope(self, scope: GuardScope) -> list[BaseGuard]:
        return [g for g in self.create_all() if g.SCOPE == scope]

    def list_available(self) -> list[dict]:
        return [
            {"id": g.GUARD_ID, "name": g.GUARD_NAME, "scope": g.SCOPE.value,
             "severity": g.severity.value, "enabled": g.is_enabled, "description": g.DESCRIPTION}
            for g in self.create_all()
        ]
```

### CLI (Updated — `--family` flag, load project_rules.yaml)

```python
# tools/guard/run.py
"""
Usage:
  python tools/guard/run.py                          # all guards
  python tools/guard/run.py --family global           # only global
  python tools/guard/run.py --family local             # only local (MemoX-specific)
  python tools/guard/run.py --guard no_else,color_palette  # specific guards
  python tools/guard/run.py --list                     # list with scope
  python tools/guard/run.py -v --json report.json      # verbose + CI JSON
"""

import argparse, sys, time, yaml
from pathlib import Path
from core.base_guard import GuardResult, GuardScope
from core.file_scanner import FileScanner
from core.guard_registry import GuardRegistry
from core.path_constants import PathConstants
from core.reporter import Reporter


def load_yaml(path: Path) -> dict:
    if not path.exists():
        return {}
    with open(path, "r", encoding="utf-8") as f:
        return yaml.safe_load(f) or {}

def find_project_root() -> Path:
    current = Path(__file__).resolve().parent
    while current != current.parent:
        if (current / "pubspec.yaml").exists():
            return current
        current = current.parent
    return Path(__file__).resolve().parent.parent.parent

def main():
    parser = argparse.ArgumentParser(description="Guard — AI Output Validator")
    parser.add_argument("--verbose", "-v", action="store_true")
    parser.add_argument("--guard", "-g", type=str)
    parser.add_argument("--family", "-f", choices=["global", "local"])
    parser.add_argument("--list", "-l", action="store_true")
    parser.add_argument("--json", type=str)
    parser.add_argument("--md", type=str)
    parser.add_argument("--scope", "-s", default="all",
                        choices=["all", "core", "shared", "features"])
    parser.add_argument("--config", "-c", type=str)
    parser.add_argument("--rules", "-r", type=str)
    args = parser.parse_args()

    sd = Path(__file__).resolve().parent
    config = load_yaml(Path(args.config) if args.config else sd / "config.yaml")
    project_rules = load_yaml(Path(args.rules) if args.rules else sd / "project_rules.yaml")
    pc = PathConstants.from_config(config, find_project_root())
    registry = GuardRegistry(config, pc, project_rules)

    if args.list:
        for g in registry.list_available():
            st = "✅" if g["enabled"] else "⏸️"
            print(f"  {st} [{g['scope']:<6}] {g['id']:<35} [{g['severity']}] {g['description']}")
        return

    if args.guard:
        guards = registry.create_by_ids(args.guard.split(","))
    elif args.family:
        guards = registry.create_by_scope(
            GuardScope.GLOBAL if args.family == "global" else GuardScope.LOCAL)
    else:
        guards = registry.create_all()

    scanner = FileScanner(pc)
    files = scanner.scan(args.scope)
    results = []
    for g in guards:
        t0 = time.perf_counter()
        vs = []
        if g.is_file_level:
            for fp in files:
                vs.extend(g.check_file(fp, scanner.read_file(fp)))
        else:
            vs = g.check_project(files)
        results.append(GuardResult(
            guard_id=g.GUARD_ID, guard_name=g.GUARD_NAME, description=g.DESCRIPTION,
            scope=g.SCOPE, violations=vs, files_scanned=len(files),
            duration_ms=(time.perf_counter() - t0) * 1000))

    Reporter.print_terminal(results, args.verbose)
    if args.json: Reporter.write_json(results, Path(args.json))
    if args.md: Reporter.write_markdown(results, Path(args.md))
    sys.exit(1 if any(not r.passed for r in results) else 0)

if __name__ == "__main__":
    main()
```

### PathConstants, FileScanner, Reporter — giữ nguyên logic từ bản cũ
> Reporter thêm group output by scope (Global Guards / Local Guards sections)

from abc import ABC, abstractmethod
from dataclasses import dataclass, field
from enum import Enum
from pathlib import Path
from typing import ClassVar


class Severity(Enum):
    ERROR = "error"        # blocks CI
    WARNING = "warning"    # report, don't block
    INFO = "info"          # suggestion


@dataclass
class Violation:
    """Single rule violation."""
    file_path: str
    line_number: int
    line_content: str
    message: str
    guard_id: str
    severity: Severity

    @property
    def location(self) -> str:
        return f"{self.file_path}:{self.line_number}"


@dataclass
class GuardResult:
    """Result of running one guard across all files."""
    guard_id: str
    guard_name: str
    description: str
    violations: list[Violation] = field(default_factory=list)
    files_scanned: int = 0
    duration_ms: float = 0.0

    @property
    def passed(self) -> bool:
        return not any(v.severity == Severity.ERROR for v in self.violations)

    @property
    def error_count(self) -> int:
        return sum(1 for v in self.violations if v.severity == Severity.ERROR)

    @property
    def warning_count(self) -> int:
        return sum(1 for v in self.violations if v.severity == Severity.WARNING)


class BaseGuard(ABC):
    """
    Abstract base for all guard rules.

    Subclass contract:
    1. Set GUARD_ID (unique snake_case identifier)
    2. Set GUARD_NAME (human-readable)
    3. Set DESCRIPTION (one-line explanation)
    4. Set DEFAULT_SEVERITY
    5. Implement check_file() or check_project()

    The factory discovers guards by scanning the guards/ directory.
    Adding a new guard = adding a new file with a class that extends BaseGuard.
    No registration needed.
    """

    # ── Subclass MUST override these ──
    GUARD_ID: ClassVar[str] = ""
    GUARD_NAME: ClassVar[str] = ""
    DESCRIPTION: ClassVar[str] = ""
    DEFAULT_SEVERITY: ClassVar[Severity] = Severity.ERROR

    def __init__(self, config: dict, path_constants: "PathConstants"):
        self.config = config
        self.paths = path_constants
        self.severity = self._resolve_severity()

    def _resolve_severity(self) -> Severity:
        """Config can override default severity per guard."""
        overrides = self.config.get("severity_overrides", {})
        override_value = overrides.get(self.GUARD_ID)
        if override_value:
            return Severity(override_value)
        return self.DEFAULT_SEVERITY

    @property
    def is_enabled(self) -> bool:
        """Check if this guard is enabled in config."""
        guards_config = self.config.get("guards", {})
        return guards_config.get(self.GUARD_ID, True)

    # ── Override ONE of these ──

    def check_file(self, file_path: Path, lines: list[str]) -> list[Violation]:
        """
        Check a single file. Override for line-by-line regex guards.
        Most guards override this method.

        Args:
            file_path: Path to the .dart file
            lines: File content split by newline (0-indexed)

        Returns:
            List of violations found in this file
        """
        return []

    def check_project(self, all_files: list[Path]) -> list[Violation]:
        """
        Check the entire project at once. Override for cross-file guards
        (e.g., import direction, file structure).

        Args:
            all_files: All .dart files in scope (already filtered)

        Returns:
            List of violations found across the project
        """
        return []

    @property
    def is_file_level(self) -> bool:
        """
        If True, factory calls check_file() per file.
        If False, factory calls check_project() once with all files.
        Override to return False for project-level guards.
        """
        return True
```

### PathConstants (Loaded from config)

```python
# tools/guard/core/path_constants.py

from dataclasses import dataclass, field
from pathlib import Path
import fnmatch


@dataclass
class PathConstants:
    """
    All path-related constants loaded from config.yaml.
    Change config → change paths. Guard logic stays untouched.
    """
    project_root: Path
    source_root: str
    test_root: str
    core_dir: str
    shared_dir: str
    features_dir: str
    exclude_patterns: list[str]
    feature_subdirs: list[str]
    feature_data_subdirs: list[str]
    feature_domain_subdirs: list[str]
    feature_presentation_subdirs: list[str]

    # ── Derived paths ──

    @property
    def lib_path(self) -> Path:
        return self.project_root / self.source_root

    @property
    def core_path(self) -> Path:
        return self.project_root / self.core_dir

    @property
    def shared_path(self) -> Path:
        return self.project_root / self.shared_dir

    @property
    def features_path(self) -> Path:
        return self.project_root / self.features_dir

    @property
    def test_path(self) -> Path:
        return self.project_root / self.test_root

    def is_excluded(self, file_path: Path) -> bool:
        """Check if file matches any exclude pattern."""
        relative = str(file_path.relative_to(self.project_root))
        return any(
            fnmatch.fnmatch(relative, pattern)
            for pattern in self.exclude_patterns
        )

    def is_in_core(self, file_path: Path) -> bool:
        return self.core_path in file_path.parents or file_path.parent == self.core_path

    def is_in_shared(self, file_path: Path) -> bool:
        return self.shared_path in file_path.parents or file_path.parent == self.shared_path

    def is_in_features(self, file_path: Path) -> bool:
        return self.features_path in file_path.parents

    def get_feature_name(self, file_path: Path) -> str | None:
        """Extract feature name from path: lib/features/folders/... → 'folders'"""
        try:
            relative = file_path.relative_to(self.features_path)
            return relative.parts[0] if relative.parts else None
        except ValueError:
            return None

    def get_layer(self, file_path: Path) -> str | None:
        """Extract layer: data, domain, or presentation."""
        try:
            relative = file_path.relative_to(self.features_path)
            if len(relative.parts) >= 2:
                layer = relative.parts[1]
                if layer in ("data", "domain", "presentation"):
                    return layer
            return None
        except ValueError:
            return None

    @classmethod
    def from_config(cls, config: dict, project_root: Path) -> "PathConstants":
        paths = config.get("paths", {})
        return cls(
            project_root=project_root,
            source_root=config.get("source_root", "lib"),
            test_root=config.get("test_root", "test"),
            core_dir=paths.get("core_dir", "lib/core"),
            shared_dir=paths.get("shared_dir", "lib/shared"),
            features_dir=paths.get("features_dir", "lib/features"),
            exclude_patterns=paths.get("exclude_patterns", []),
            feature_subdirs=paths.get("feature_subdirs", []),
            feature_data_subdirs=paths.get("feature_data_subdirs", []),
            feature_domain_subdirs=paths.get("feature_domain_subdirs", []),
            feature_presentation_subdirs=paths.get("feature_presentation_subdirs", []),
        )
```

### FileScanner

```python
# tools/guard/core/file_scanner.py

from pathlib import Path


class FileScanner:
    """Scan project for Dart files, respecting exclusions."""

    def __init__(self, path_constants: "PathConstants"):
        self.paths = path_constants

    def scan(self, scope: str = "all") -> list[Path]:
        """
        Scan for .dart files.

        Args:
            scope: "all" | "core" | "shared" | "features" | "lib"

        Returns:
            Sorted list of .dart file Paths, with generated files excluded
        """
        root = self._resolve_scope(scope)
        if not root.exists():
            return []

        files = sorted(root.rglob("*.dart"))
        return [f for f in files if not self.paths.is_excluded(f)]

    def _resolve_scope(self, scope: str) -> Path:
        scope_map = {
            "all": self.paths.lib_path,
            "lib": self.paths.lib_path,
            "core": self.paths.core_path,
            "shared": self.paths.shared_path,
            "features": self.paths.features_path,
        }
        return scope_map.get(scope, self.paths.lib_path)

    def read_file(self, file_path: Path) -> list[str]:
        """Read file lines. Returns empty list if file unreadable."""
        try:
            return file_path.read_text(encoding="utf-8").splitlines()
        except (OSError, UnicodeDecodeError):
            return []
```

### GuardFactory (Auto-Discovery)

```python
# tools/guard/core/guard_factory.py

import importlib
import inspect
from pathlib import Path
from typing import Type

from .base_guard import BaseGuard


class GuardFactory:
    """
    Auto-discovers and instantiates all Guard classes.

    Convention: every .py file in guards/ that contains a class
    extending BaseGuard is auto-registered. No manual list needed.

    Adding a new guard:
    1. Create guards/my_new_guard.py
    2. Define class MyNewGuard(BaseGuard) with GUARD_ID, etc.
    3. Done. Factory picks it up automatically.
    """

    GUARDS_PACKAGE = "guards"

    def __init__(self, config: dict, path_constants: "PathConstants"):
        self.config = config
        self.path_constants = path_constants

    def create_all(self) -> list[BaseGuard]:
        """Discover, instantiate, and filter enabled guards."""
        guard_classes = self._discover_guard_classes()
        guards = []

        for cls in guard_classes:
            instance = cls(config=self.config, path_constants=self.path_constants)
            if instance.is_enabled:
                guards.append(instance)

        # Sort by GUARD_ID for deterministic output
        guards.sort(key=lambda g: g.GUARD_ID)
        return guards

    def create_by_ids(self, guard_ids: list[str]) -> list[BaseGuard]:
        """Create only specific guards by ID (for targeted runs)."""
        all_guards = self.create_all()
        return [g for g in all_guards if g.GUARD_ID in guard_ids]

    def _discover_guard_classes(self) -> list[Type[BaseGuard]]:
        """Scan guards/ directory for BaseGuard subclasses."""
        guards_dir = Path(__file__).parent.parent / self.GUARDS_PACKAGE
        classes = []

        for py_file in sorted(guards_dir.glob("*.py")):
            if py_file.name.startswith("_"):
                continue

            module_name = f"{self.GUARDS_PACKAGE}.{py_file.stem}"
            try:
                module = importlib.import_module(module_name)
            except ImportError as e:
                print(f"[warn] Failed to import {module_name}: {e}")
                continue

            for _, obj in inspect.getmembers(module, inspect.isclass):
                if (
                    issubclass(obj, BaseGuard)
                    and obj is not BaseGuard
                    and obj.GUARD_ID  # skip if GUARD_ID not set
                ):
                    classes.append(obj)

        return classes

    def list_available(self) -> list[dict]:
        """List all discovered guards with metadata (for --list flag)."""
        guard_classes = self._discover_guard_classes()
        return [
            {
                "id": cls.GUARD_ID,
                "name": cls.GUARD_NAME,
                "description": cls.DESCRIPTION,
                "severity": cls.DEFAULT_SEVERITY.value,
            }
            for cls in sorted(guard_classes, key=lambda c: c.GUARD_ID)
        ]
```

### Reporter (Output Formats)

```python
# tools/guard/core/reporter.py

import json
from dataclasses import asdict
from pathlib import Path

from .base_guard import GuardResult, Severity


class Reporter:
    """
    Output guard results in multiple formats.
    Terminal (colored), JSON (CI), Markdown (PR comment).
    """

    # ── Terminal (default) ──

    @staticmethod
    def print_terminal(results: list[GuardResult], verbose: bool = False) -> None:
        """Pretty-print to terminal with colors."""
        total_errors = sum(r.error_count for r in results)
        total_warnings = sum(r.warning_count for r in results)
        total_files = max(r.files_scanned for r in results) if results else 0

        print(f"\n{'='*60}")
        print(f"  Guard Results — {len(results)} guards, {total_files} files scanned")
        print(f"{'='*60}\n")

        for result in results:
            icon = "✅" if result.passed else "❌"
            counts = f"{result.error_count}E {result.warning_count}W"
            print(f"  {icon} {result.guard_name:<35} [{counts}]  ({result.duration_ms:.0f}ms)")

            if verbose or not result.passed:
                for v in result.violations:
                    sev_icon = {"error": "🔴", "warning": "🟡", "info": "🔵"}[v.severity.value]
                    print(f"     {sev_icon} {v.location}")
                    print(f"        {v.message}")
                    if verbose:
                        print(f"        │ {v.line_content.strip()}")

        print(f"\n{'─'*60}")
        print(f"  Total: {total_errors} errors, {total_warnings} warnings")

        if total_errors > 0:
            print(f"  ❌ FAILED — {total_errors} error(s) must be fixed")
        else:
            print(f"  ✅ PASSED — all guards clear")

        print(f"{'─'*60}\n")

    # ── JSON (CI integration) ──

    @staticmethod
    def write_json(results: list[GuardResult], output_path: Path) -> None:
        """Write results as JSON for CI pipelines."""
        data = {
            "passed": all(r.passed for r in results),
            "total_errors": sum(r.error_count for r in results),
            "total_warnings": sum(r.warning_count for r in results),
            "guards": [
                {
                    "id": r.guard_id,
                    "name": r.guard_name,
                    "passed": r.passed,
                    "errors": r.error_count,
                    "warnings": r.warning_count,
                    "violations": [
                        {
                            "file": v.file_path,
                            "line": v.line_number,
                            "message": v.message,
                            "severity": v.severity.value,
                        }
                        for v in r.violations
                    ],
                }
                for r in results
            ],
        }
        output_path.write_text(json.dumps(data, indent=2, ensure_ascii=False))

    # ── Markdown (PR comment) ──

    @staticmethod
    def write_markdown(results: list[GuardResult], output_path: Path) -> None:
        """Write results as Markdown for PR comments."""
        lines = ["# 🛡️ Guard Report\n"]
        total_errors = sum(r.error_count for r in results)

        if total_errors == 0:
            lines.append("✅ **All guards passed.**\n")
        else:
            lines.append(f"❌ **{total_errors} error(s) found.**\n")

        for r in results:
            if r.passed and not r.violations:
                continue
            icon = "✅" if r.passed else "❌"
            lines.append(f"\n## {icon} {r.guard_name}\n")
            for v in r.violations:
                lines.append(f"- `{v.location}` — {v.message}")

        output_path.write_text("\n".join(lines))
```

### CLI Entry Point

```python
# tools/guard/run.py

"""
MemoX Guard — AI Output Validation Tool

Usage:
  python tools/guard/run.py                     # run all guards
  python tools/guard/run.py --verbose            # show violation details
  python tools/guard/run.py --guard no_else      # run specific guard only
  python tools/guard/run.py --guard no_else,l10n # run multiple specific guards
  python tools/guard/run.py --list               # list all available guards
  python tools/guard/run.py --json report.json   # output JSON for CI
  python tools/guard/run.py --md report.md       # output Markdown for PR
  python tools/guard/run.py --scope features     # scan only features/
  python tools/guard/run.py --fix-hints          # show fix suggestions
"""

import argparse
import sys
import time
from pathlib import Path

import yaml

from core.base_guard import GuardResult
from core.file_scanner import FileScanner
from core.guard_factory import GuardFactory
from core.path_constants import PathConstants
from core.reporter import Reporter


def load_config(config_path: Path) -> dict:
    with open(config_path, "r", encoding="utf-8") as f:
        return yaml.safe_load(f)


def find_project_root() -> Path:
    """Walk up from script location to find pubspec.yaml."""
    current = Path(__file__).resolve().parent
    while current != current.parent:
        if (current / "pubspec.yaml").exists():
            return current
        current = current.parent
    # Fallback: assume 2 levels up from tools/guard/
    return Path(__file__).resolve().parent.parent.parent


def run_guards(
    config: dict,
    path_constants: PathConstants,
    scope: str,
    guard_ids: list[str] | None,
) -> list[GuardResult]:
    """Execute guards and return results."""
    factory = GuardFactory(config, path_constants)

    if guard_ids:
        guards = factory.create_by_ids(guard_ids)
    else:
        guards = factory.create_all()

    scanner = FileScanner(path_constants)
    all_files = scanner.scan(scope)

    results = []

    for guard in guards:
        start = time.perf_counter()
        violations = []

        if guard.is_file_level:
            for file_path in all_files:
                lines = scanner.read_file(file_path)
                file_violations = guard.check_file(file_path, lines)
                violations.extend(file_violations)
        else:
            violations = guard.check_project(all_files)

        duration_ms = (time.perf_counter() - start) * 1000

        results.append(GuardResult(
            guard_id=guard.GUARD_ID,
            guard_name=guard.GUARD_NAME,
            description=guard.DESCRIPTION,
            violations=violations,
            files_scanned=len(all_files),
            duration_ms=duration_ms,
        ))

    return results


def main():
    parser = argparse.ArgumentParser(description="MemoX Guard — AI Output Validator")
    parser.add_argument("--verbose", "-v", action="store_true", help="Show violation line content")
    parser.add_argument("--guard", "-g", type=str, help="Run specific guard(s), comma-separated IDs")
    parser.add_argument("--list", "-l", action="store_true", help="List all available guards")
    parser.add_argument("--json", type=str, help="Output JSON report to file")
    parser.add_argument("--md", type=str, help="Output Markdown report to file")
    parser.add_argument("--scope", "-s", type=str, default="all",
                        choices=["all", "core", "shared", "features"],
                        help="Scope of files to scan")
    parser.add_argument("--config", "-c", type=str, default=None, help="Custom config path")
    args = parser.parse_args()

    # Load config
    script_dir = Path(__file__).resolve().parent
    config_path = Path(args.config) if args.config else script_dir / "config.yaml"
    config = load_config(config_path)

    # Resolve paths
    project_root = find_project_root()
    path_constants = PathConstants.from_config(config, project_root)

    # List mode
    if args.list:
        factory = GuardFactory(config, path_constants)
        for g in factory.list_available():
            status = "✅" if config.get("guards", {}).get(g["id"], True) else "⏸️"
            print(f"  {status} {g['id']:<30} [{g['severity']}]  {g['description']}")
        return

    # Run guards
    guard_ids = args.guard.split(",") if args.guard else None
    results = run_guards(config, path_constants, args.scope, guard_ids)

    # Output
    Reporter.print_terminal(results, verbose=args.verbose)

    if args.json:
        Reporter.write_json(results, Path(args.json))
        print(f"  📄 JSON report: {args.json}")

    if args.md:
        Reporter.write_markdown(results, Path(args.md))
        print(f"  📄 Markdown report: {args.md}")

    # Exit code for CI
    has_errors = any(not r.passed for r in results)
    sys.exit(1 if has_errors else 0)


if __name__ == "__main__":
    main()
```

---

## 🛡️ GUARD IMPLEMENTATIONS — Mỗi file 1 guard

### Guard 1: NoElseGuard

```python
# tools/guard/guards/no_else_guard.py

import re
from pathlib import Path
from core.base_guard import BaseGuard, Violation, Severity


class NoElseGuard(BaseGuard):
    GUARD_ID = "no_else"
    GUARD_NAME = "No else keyword"
    DESCRIPTION = "Cấm else/else-if. Dùng early return, switch expression, hoặc reassign."
    DEFAULT_SEVERITY = Severity.ERROR

    # Matches: } else {, } else if (...) {
    ELSE_PATTERN = re.compile(r"\}\s*else\s*(\{|if\s*\()")

    # False positives to skip
    SKIP_PATTERNS = [
        re.compile(r"//.*else"),          # commented out
        re.compile(r"///.*else"),          # doc comment
        re.compile(r"['\"].*else.*['\"]"),  # string literal
    ]

    def check_file(self, file_path: Path, lines: list[str]) -> list[Violation]:
        violations = []

        for i, line in enumerate(lines):
            if not self.ELSE_PATTERN.search(line):
                continue

            # Skip false positives
            if any(p.search(line) for p in self.SKIP_PATTERNS):
                continue

            violations.append(Violation(
                file_path=str(file_path),
                line_number=i + 1,
                line_content=line,
                message="Dùng early return, guard clause, hoặc switch expression thay vì else.",
                guard_id=self.GUARD_ID,
                severity=self.severity,
            ))

        return violations
```

### Guard 2: NoHardcodedColorGuard

```python
# tools/guard/guards/no_hardcoded_color_guard.py

import re
from pathlib import Path
from core.base_guard import BaseGuard, Violation, Severity


class NoHardcodedColorGuard(BaseGuard):
    GUARD_ID = "no_hardcoded_color"
    GUARD_NAME = "No hardcoded colors"
    DESCRIPTION = "Cấm Color(0x...) và Colors.xxx. Dùng context.colors hoặc context.customColors."
    DEFAULT_SEVERITY = Severity.ERROR

    PATTERNS = [
        re.compile(r"Color\(\s*0x[0-9A-Fa-f]+\s*\)"),
        re.compile(r"Colors\.\w+"),
        re.compile(r"Color\.fromRGBO\("),
        re.compile(r"Color\.fromARGB\("),
    ]

    # Whitelist: files where hardcoded colors ARE allowed
    WHITELIST_PATHS = [
        "tokens/color_tokens.dart",           # token definitions
        "color_schemes/custom_colors.dart",    # theme extension
        "color_schemes/app_color_scheme.dart",
    ]

    def check_file(self, file_path: Path, lines: list[str]) -> list[Violation]:
        # Skip whitelisted files
        path_str = str(file_path)
        if any(wl in path_str for wl in self.WHITELIST_PATHS):
            return []

        violations = []
        for i, line in enumerate(lines):
            # Skip comments
            stripped = line.strip()
            if stripped.startswith("//") or stripped.startswith("///"):
                continue

            for pattern in self.PATTERNS:
                if pattern.search(line):
                    violations.append(Violation(
                        file_path=str(file_path),
                        line_number=i + 1,
                        line_content=line,
                        message=f"Hardcoded color detected. Dùng context.colors.* hoặc context.customColors.*",
                        guard_id=self.GUARD_ID,
                        severity=self.severity,
                    ))
                    break  # 1 violation per line max

        return violations
```

### Guard 3: NoHardcodedDurationGuard

```python
# tools/guard/guards/no_hardcoded_duration_guard.py

import re
from pathlib import Path
from core.base_guard import BaseGuard, Violation, Severity


class NoHardcodedDurationGuard(BaseGuard):
    GUARD_ID = "no_hardcoded_duration"
    GUARD_NAME = "No hardcoded durations"
    DESCRIPTION = "Cấm Duration(milliseconds: N). Dùng DurationTokens.*"
    DEFAULT_SEVERITY = Severity.ERROR

    PATTERN = re.compile(r"Duration\(\s*(milliseconds|seconds|minutes)\s*:\s*\d+\s*\)")

    WHITELIST_PATHS = [
        "tokens/duration_tokens.dart",
    ]

    def check_file(self, file_path: Path, lines: list[str]) -> list[Violation]:
        if any(wl in str(file_path) for wl in self.WHITELIST_PATHS):
            return []

        violations = []
        for i, line in enumerate(lines):
            stripped = line.strip()
            if stripped.startswith("//"):
                continue
            if self.PATTERN.search(line):
                violations.append(Violation(
                    file_path=str(file_path),
                    line_number=i + 1,
                    line_content=line,
                    message="Hardcoded duration. Dùng DurationTokens.*",
                    guard_id=self.GUARD_ID,
                    severity=self.severity,
                ))
        return violations
```

### Guard 4: NoHardcodedRadiusGuard

```python
# tools/guard/guards/no_hardcoded_radius_guard.py

import re
from pathlib import Path
from core.base_guard import BaseGuard, Violation, Severity


class NoHardcodedRadiusGuard(BaseGuard):
    GUARD_ID = "no_hardcoded_radius"
    GUARD_NAME = "No hardcoded border radius"
    DESCRIPTION = "Cấm BorderRadius.circular(N). Dùng RadiusTokens.*"
    DEFAULT_SEVERITY = Severity.ERROR

    PATTERN = re.compile(r"BorderRadius\.circular\(\s*\d+\.?\d*\s*\)")

    WHITELIST_PATHS = [
        "tokens/radius_tokens.dart",
    ]

    def check_file(self, file_path: Path, lines: list[str]) -> list[Violation]:
        if any(wl in str(file_path) for wl in self.WHITELIST_PATHS):
            return []

        violations = []
        for i, line in enumerate(lines):
            stripped = line.strip()
            if stripped.startswith("//"):
                continue
            if self.PATTERN.search(line):
                violations.append(Violation(
                    file_path=str(file_path),
                    line_number=i + 1,
                    line_content=line,
                    message="Hardcoded radius. Dùng RadiusTokens.*",
                    guard_id=self.GUARD_ID,
                    severity=self.severity,
                ))
        return violations
```

### Guard 5: SharedWidgetGuard

```python
# tools/guard/guards/shared_widget_guard.py

import re
from pathlib import Path
from core.base_guard import BaseGuard, Violation, Severity


class SharedWidgetGuard(BaseGuard):
    GUARD_ID = "shared_widget"
    GUARD_NAME = "Shared widget enforcement"
    DESCRIPTION = "Cấm dùng raw widgets khi shared widget tồn tại."
    DEFAULT_SEVERITY = Severity.ERROR

    # Map: forbidden raw usage → required shared widget
    FORBIDDEN_RAW = {
        r"\bCard\(": "Dùng AppCard thay vì raw Card()",
        r"\.when\(\s*data\s*:": "Dùng AppAsyncBuilder thay vì raw .when(data:...)",
        r"\bElevatedButton\(": "Dùng PrimaryButton thay vì raw ElevatedButton()",
        r"\bCircularProgressIndicator\(": "Dùng LoadingIndicator thay vì raw CircularProgressIndicator()",
        r"ScaffoldMessenger\.of\(": "Dùng Toast thay vì raw ScaffoldMessenger",
        r"\bDismissible\(": "Dùng AppSlidableRow thay vì raw Dismissible()",
    }

    # Don't check these paths (shared widget implementations themselves)
    WHITELIST_PATHS = [
        "shared/widgets/",
    ]

    def __init__(self, config, path_constants):
        super().__init__(config, path_constants)
        self._compiled = {
            re.compile(pattern): message
            for pattern, message in self.FORBIDDEN_RAW.items()
        }

    def check_file(self, file_path: Path, lines: list[str]) -> list[Violation]:
        if any(wl in str(file_path) for wl in self.WHITELIST_PATHS):
            return []

        violations = []
        for i, line in enumerate(lines):
            stripped = line.strip()
            if stripped.startswith("//"):
                continue
            for pattern, message in self._compiled.items():
                if pattern.search(line):
                    violations.append(Violation(
                        file_path=str(file_path),
                        line_number=i + 1,
                        line_content=line,
                        message=message,
                        guard_id=self.GUARD_ID,
                        severity=self.severity,
                    ))
                    break
        return violations
```

### Guard 6: WidgetLengthGuard

```python
# tools/guard/guards/widget_length_guard.py

import re
from pathlib import Path
from core.base_guard import BaseGuard, Violation, Severity


class WidgetLengthGuard(BaseGuard):
    GUARD_ID = "widget_length"
    GUARD_NAME = "Widget build() length"
    DESCRIPTION = "Widget build() method không được vượt max_widget_lines."
    DEFAULT_SEVERITY = Severity.WARNING

    BUILD_START = re.compile(r"Widget\s+build\s*\(")
    
    def check_file(self, file_path: Path, lines: list[str]) -> list[Violation]:
        max_lines = self.config.get("thresholds", {}).get("max_widget_lines", 80)
        violations = []
        i = 0

        while i < len(lines):
            if self.BUILD_START.search(lines[i]):
                start_line = i
                brace_count = 0
                found_open = False

                for j in range(i, len(lines)):
                    brace_count += lines[j].count("{") - lines[j].count("}")
                    if "{" in lines[j]:
                        found_open = True
                    if found_open and brace_count <= 0:
                        build_length = j - start_line + 1
                        if build_length > max_lines:
                            violations.append(Violation(
                                file_path=str(file_path),
                                line_number=start_line + 1,
                                line_content=lines[start_line],
                                message=f"build() is {build_length} lines (max {max_lines}). Tách thành composable widgets.",
                                guard_id=self.GUARD_ID,
                                severity=self.severity,
                            ))
                        i = j + 1
                        break
                else:
                    i += 1
            else:
                i += 1

        return violations
```

### Guard 7: ImportDirectionGuard (Project-level)

```python
# tools/guard/guards/import_direction_guard.py

import re
from pathlib import Path
from core.base_guard import BaseGuard, Violation, Severity


class ImportDirectionGuard(BaseGuard):
    GUARD_ID = "import_direction"
    GUARD_NAME = "Import direction (SOLID)"
    DESCRIPTION = "Presentation không import data. Domain không import data hoặc presentation."
    DEFAULT_SEVERITY = Severity.ERROR

    IMPORT_PATTERN = re.compile(r"import\s+'package:\w+/features/(\w+)/(\w+)/")

    @property
    def is_file_level(self) -> bool:
        return True

    def check_file(self, file_path: Path, lines: list[str]) -> list[Violation]:
        current_layer = self.paths.get_layer(file_path)
        if not current_layer:
            return []

        violations = []
        for i, line in enumerate(lines):
            match = self.IMPORT_PATTERN.search(line)
            if not match:
                continue

            imported_layer = match.group(2)

            # RULES:
            # domain → CANNOT import data, presentation
            # presentation → CANNOT import data
            # data → can import domain (implementing interfaces)
            forbidden = False
            if current_layer == "domain" and imported_layer in ("data", "presentation"):
                forbidden = True
            if current_layer == "presentation" and imported_layer == "data":
                forbidden = True

            if forbidden:
                violations.append(Violation(
                    file_path=str(file_path),
                    line_number=i + 1,
                    line_content=line,
                    message=f"{current_layer}/ không được import {imported_layer}/. Vi phạm Dependency Inversion.",
                    guard_id=self.GUARD_ID,
                    severity=self.severity,
                ))

        return violations
```

### Guard 8: L10nGuard

```python
# tools/guard/guards/l10n_guard.py

import re
from pathlib import Path
from core.base_guard import BaseGuard, Violation, Severity


class L10nGuard(BaseGuard):
    GUARD_ID = "l10n"
    GUARD_NAME = "No hardcoded user-facing strings"
    DESCRIPTION = "User-facing strings phải dùng context.l10n.*. Cấm hardcode trong Text()."
    DEFAULT_SEVERITY = Severity.WARNING

    # Match: Text('...' or Text("..."
    # But NOT: Text(variable) or Text(context.l10n.xxx)
    TEXT_HARDCODED = re.compile(r"""Text\(\s*['"]""")

    WHITELIST_PATHS = [
        "test/",
        "constants/",
    ]

    def check_file(self, file_path: Path, lines: list[str]) -> list[Violation]:
        if any(wl in str(file_path) for wl in self.WHITELIST_PATHS):
            return []

        violations = []
        for i, line in enumerate(lines):
            stripped = line.strip()
            if stripped.startswith("//"):
                continue
            if self.TEXT_HARDCODED.search(line):
                violations.append(Violation(
                    file_path=str(file_path),
                    line_number=i + 1,
                    line_content=line,
                    message="Hardcoded string trong Text(). Dùng context.l10n.*",
                    guard_id=self.GUARD_ID,
                    severity=self.severity,
                ))
        return violations
```

### Guard 9: IconStyleGuard

```python
# tools/guard/guards/icon_style_guard.py

import re
from pathlib import Path
from core.base_guard import BaseGuard, Violation, Severity


class IconStyleGuard(BaseGuard):
    GUARD_ID = "icon_style"
    GUARD_NAME = "Icons must be outlined"
    DESCRIPTION = "Chỉ dùng Icons.*_outlined. Cấm filled icons."
    DEFAULT_SEVERITY = Severity.WARNING

    # Match Icons.xxx but NOT Icons.xxx_outlined
    FILLED_ICON = re.compile(r"Icons\.(\w+)(?<!_outlined)\b")

    # Known exceptions (no outlined variant, or intentionally filled)
    EXCEPTIONS = {
        "Icons.close", "Icons.add", "Icons.check", "Icons.arrow_back",
        "Icons.arrow_forward", "Icons.more_vert", "Icons.more_horiz",
    }

    WHITELIST_PATHS = [
        "design/app_icons.dart",
    ]

    def check_file(self, file_path: Path, lines: list[str]) -> list[Violation]:
        if any(wl in str(file_path) for wl in self.WHITELIST_PATHS):
            return []

        violations = []
        for i, line in enumerate(lines):
            stripped = line.strip()
            if stripped.startswith("//"):
                continue

            for match in self.FILLED_ICON.finditer(line):
                full_match = f"Icons.{match.group(1)}"
                if full_match in self.EXCEPTIONS:
                    continue
                if "_outlined" in match.group(1):
                    continue

                violations.append(Violation(
                    file_path=str(file_path),
                    line_number=i + 1,
                    line_content=line,
                    message=f"{full_match} → dùng {full_match}_outlined",
                    guard_id=self.GUARD_ID,
                    severity=self.severity,
                ))
                break
        return violations
```

### Guard 10: AsyncBuilderGuard

```python
# tools/guard/guards/async_builder_guard.py

import re
from pathlib import Path
from core.base_guard import BaseGuard, Violation, Severity


class AsyncBuilderGuard(BaseGuard):
    GUARD_ID = "async_builder"
    GUARD_NAME = "AsyncValue must use AppAsyncBuilder"
    DESCRIPTION = "Cấm raw .when(data:...). Dùng AppAsyncBuilder."
    DEFAULT_SEVERITY = Severity.ERROR

    # Matches: .when(\n  data: OR .when(data:
    WHEN_PATTERN = re.compile(r"\.when\s*\(")

    WHITELIST_PATHS = [
        "shared/widgets/feedback/app_async_builder.dart",
    ]

    def check_file(self, file_path: Path, lines: list[str]) -> list[Violation]:
        if any(wl in str(file_path) for wl in self.WHITELIST_PATHS):
            return []

        violations = []
        for i, line in enumerate(lines):
            if self.WHEN_PATTERN.search(line):
                violations.append(Violation(
                    file_path=str(file_path),
                    line_number=i + 1,
                    line_content=line,
                    message="Raw .when() detected. Dùng AppAsyncBuilder widget.",
                    guard_id=self.GUARD_ID,
                    severity=self.severity,
                ))
        return violations
```

---

## 📋 GUARD REGISTRY — Quick Reference

```
ID                      │ Type     │ Severity │ Checks
────────────────────────┼──────────┼──────────┼──────────────────────────────────
no_else                 │ file     │ error    │ } else { hoặc } else if (
no_hardcoded_color      │ file     │ error    │ Color(0x...), Colors.xxx
no_hardcoded_duration   │ file     │ error    │ Duration(milliseconds: N)
no_hardcoded_radius     │ file     │ error    │ BorderRadius.circular(N)
no_hardcoded_size       │ file     │ error    │ SizedBox(height: N), width: N (literal)
no_hardcoded_string     │ file     │ error    │ hardcode trong AppBar title, Dialog title
no_hardcoded_font_size  │ file     │ error    │ fontSize: N (literal number)
shared_widget           │ file     │ error    │ raw Card(), .when(), ElevatedButton(), etc.
widget_length           │ file     │ warning  │ build() > max_widget_lines
const_constructor       │ file     │ warning  │ StatelessWidget thiếu const constructor
import_direction        │ file     │ error    │ domain imports data, presentation imports data
icon_style              │ file     │ warning  │ Icons.xxx thiếu _outlined
async_builder           │ file     │ error    │ raw .when(data:...) thay vì AppAsyncBuilder
l10n                    │ file     │ warning  │ Text('hardcoded string')
file_structure          │ project  │ info     │ feature/ thiếu data/domain/presentation
naming_convention       │ file     │ warning  │ file names không snake_case
raw_card                │ file     │ error    │ Card( thay vì AppCard(
```

---

## 🔄 THÊM GUARD MỚI — Quy trình

```
1. Tạo file: tools/guard/guards/my_new_guard.py

2. Implement:
   class MyNewGuard(BaseGuard):
       GUARD_ID = "my_new_rule"
       GUARD_NAME = "Human readable name"
       DESCRIPTION = "What this checks"
       DEFAULT_SEVERITY = Severity.ERROR  # or WARNING, INFO

       def check_file(self, file_path, lines):
           # ... return violations

3. (Optional) Thêm vào config.yaml:
   guards:
     my_new_rule: true

4. Done. Factory tự discover, không cần register.
```

**Không file nào khác bị sửa đổi.**

---

## 🚀 CI INTEGRATION

```yaml
# .github/workflows/guard.yml (hoặc tương đương)

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

```bash
# Tích hợp vào CLAUDE.md / AGENTS.md:
# Thêm vào commands section:

# Run guard after every task
python tools/guard/run.py --scope features

# Run specific guard only
python tools/guard/run.py --guard no_else,shared_widget
```

---

## 🔁 REUSE CHO PROJECT KHÁC

```
1. Copy toàn bộ tools/guard/ vào project mới

2. Sửa config.yaml:
   - project_name
   - source_root (nếu không phải "lib")
   - paths (core_dir, shared_dir, features_dir)
   - exclude_patterns (thêm generators cụ thể)
   - thresholds (adjust per project)

3. Sửa guards cần thay đổi:
   - shared_widget_guard.py → đổi FORBIDDEN_RAW map theo shared widgets mới
   - icon_style_guard.py → đổi EXCEPTIONS nếu cần

4. Thêm guards mới nếu project có rules riêng

5. KHÔNG sửa: core/, run.py, reporter.py, factory
```
