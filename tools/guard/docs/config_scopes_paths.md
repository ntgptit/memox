# Guard tool — scope and path configuration

This document describes the `scan_targets` and `language_extensions` configuration
keys added in the scope/path refactor and explains how to use them, migrate from the
previous implicit setup, and add project layouts without modifying Python code.

---

## Background

Before this change, scope-to-directory mappings were encoded directly in
`PathConstants.scope_roots()` as a hardcoded `if/elif` chain:

```python
# old code — DO NOT copy
if scope == 'core':   return [self.core_dir]
if scope == 'shared': return [self.shared_dir]
...
```

File extensions were similarly hardcoded as `.dart` defaults inside the scanner.

Both concerns are now fully config-driven.

---

## New configuration keys

### `language_extensions` (top-level, optional)

Declares the file suffixes accepted project-wide.  Individual scopes may override
this value with their own `extensions` key.

```yaml
language_extensions:
  - ".dart"
```

If omitted, the engine falls back to `[".dart"]` so existing configs keep working.

---

### `scan_targets` (top-level, optional)

A mapping of **scope id → scope config**.  Each entry defines one named scope that
can be passed to `--scope` on the CLI.

```yaml
scan_targets:
  <scope-id>:
    roots:      <list of repo-relative directories>   # required
    extensions: <list of file suffixes>               # optional; overrides language_extensions
    include:    <list of glob patterns>               # optional; file must match ≥1
    exclude:    <list of glob patterns>               # optional; added to global excludes
```

If `scan_targets` is absent the tool synthesises the five legacy scopes from the
`paths.*` keys (see [Backward compatibility](#backward-compatibility) below).

---

## Schema reference

| Key | Type | Required | Description |
|-----|------|----------|-------------|
| `roots` | `list[str]` | **yes** | Repo-relative directories walked when this scope is active. Must be non-empty; each entry must be a non-empty string. |
| `extensions` | `list[str]` | no | File suffixes to accept for this scope. Each must start with `.`. Defaults to `language_extensions`. |
| `include` | `list[str]` | no | Glob patterns (relative to repo root). If present, a file must match **at least one** to be kept. |
| `exclude` | `list[str]` | no | Glob patterns applied **in addition** to the global `paths.exclude_patterns` list. |

### Validation

The tool raises `ValueError` with a descriptive message on startup when:

- `scan_targets` is not a mapping
- A scope entry is not a mapping
- `roots` is missing, not a list, or empty
- A root entry is not a non-empty string
- `extensions` is not a list
- An extension does not start with `.`
- `include` or `exclude` is not a list

---

## MemoX default scopes

The current MemoX `policy.yaml` declares these five scopes that match the original CLI
contract (`--scope all|core|shared|features|test`):

```yaml
scan_targets:
  all:
    roots:
      - "lib"
      - "test"
  core:
    roots:
      - "lib/core"
  shared:
    roots:
      - "lib/shared"
  features:
    roots:
      - "lib/features"
  test:
    roots:
      - "test"
```

All scopes inherit `language_extensions: [".dart"]` and are subject to the global
`paths.exclude_patterns` list.

---

## Backward compatibility

### Old configs without `scan_targets`

If `scan_targets` is **not** present in a policy config, the engine automatically
reconstructs the five legacy scopes from the existing `paths.*` keys:

```yaml
# old format — still works
source_root: "lib"
test_root: "test"
paths:
  core_dir: "lib/core"
  shared_dir: "lib/shared"
  features_dir: "lib/features"
```

This means existing CI commands such as `python tools/guard/run.py --scope core`
continue to work without any config changes.

### `file_scanner.scan(extensions=...)` parameter

The `extensions` parameter is still accepted and overrides the config-derived value
when provided explicitly.  Existing call sites are unaffected.

---

## How scope filtering works in guards

Guards that previously contained hardcoded scope-name checks like
`if scope not in {'all', 'features'}` now use the helper:

```python
self.paths.path_is_within_scope(path_str, scope)
```

This returns `True` when `path_str` (a repo-relative POSIX string) is at or under
any root directory of the given scope.  It works generically for any scope defined
in config — no guard code needs updating when a new scope is added.

**Example:**

| `path_str` | `scope` | scope roots | result |
|---|---|---|---|
| `lib/core/theme` | `core` | `[lib/core]` | `True` |
| `lib/features/cards` | `core` | `[lib/core]` | `False` |
| `lib/core/theme` | `all` | `[lib, test]` | `True` |
| `test/helpers` | `features` | `[lib/features]` | `False` |

---

## Examples

### Add a new scope for l10n files only

```yaml
language_extensions:
  - ".dart"

scan_targets:
  # ... existing scopes ...
  l10n:
    roots:
      - "lib/l10n"
    extensions:
      - ".arb"
```

Run: `python tools/guard/run.py --scope l10n`

### Restrict a scope to presentation layer only

```yaml
scan_targets:
  presentation:
    roots:
      - "lib/features"
    include:
      - "**/presentation/**/*.dart"
```

### Add a scope that excludes generated code per-scope (in addition to global)

```yaml
scan_targets:
  strict:
    roots:
      - "lib"
    exclude:
      - "**/generated/**"
      - "**/*.gen.dart"
```

### Different project layout (non-Flutter)

A project using `src/` instead of `lib/` needs only a config change:

```yaml
source_root: "src"
test_root: "tests"
language_extensions:
  - ".kt"

paths:
  core_dir: "src/core"
  shared_dir: "src/shared"
  features_dir: "src/features"
  exclude_patterns:
    - "**/build/**"

scan_targets:
  all:
    roots:
      - "src"
      - "tests"
  core:
    roots:
      - "src/core"
```

No Python code changes are required.

---

## Migration notes for existing projects

1. **Nothing to do if you don't add `scan_targets`.** The backward-compat fallback
   reconstructs the same five scopes automatically.

2. **Add `scan_targets` when you need new scopes or per-scope extension control.**
   Copy the MemoX default block from `policies/memox/policy.yaml` and extend it.

3. **Add `language_extensions` once** if you want the project default to be explicit
   rather than relying on the `".dart"` fallback.

4. **Custom scope names** that were previously passed as bare paths
   (`--scope lib/my_module`) still work — unknown scope ids fall back to treating
   the value as a repo-relative root path.
