from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path, PurePosixPath


@dataclass(slots=True, frozen=True)
class ScopeDefinition:
    """Describes one named scan scope: which roots to walk, which extensions to accept,
    and optional per-scope include/exclude glob patterns.

    Fields
    ------
    id              Scope identifier used on the CLI (e.g. ``core``, ``features``).
    roots           Repo-relative paths that are walked when this scope is active.
    extensions      File suffixes that are accepted (each must start with ``'.'``).
    include_patterns
                    If non-empty, a file must match *at least one* of these glob
                    patterns (relative to repo root) to be included.
    exclude_patterns
                    Scope-specific excludes applied *in addition* to the global
                    ``paths.exclude_patterns`` list.
    """

    id: str
    roots: tuple[str, ...]
    extensions: tuple[str, ...]
    include_patterns: tuple[str, ...]
    exclude_patterns: tuple[str, ...]


def _validate_scope(scope_id: str, raw: object) -> None:
    """Raise ``ValueError`` with a clear message when a scope entry is malformed."""
    if not isinstance(raw, dict):
        raise ValueError(
            f"scan_targets['{scope_id}'] must be a mapping, got {type(raw).__name__}",
        )

    roots = raw.get('roots')
    if not isinstance(roots, list) or not roots:
        raise ValueError(
            f"scan_targets['{scope_id}'].roots must be a non-empty list",
        )

    for root in roots:
        if not isinstance(root, str) or not root.strip():
            raise ValueError(
                f"scan_targets['{scope_id}'].roots: each entry must be a non-empty string",
            )

    raw_exts = raw.get('extensions')
    if raw_exts is not None:
        if not isinstance(raw_exts, list):
            raise ValueError(
                f"scan_targets['{scope_id}'].extensions must be a list",
            )
        for ext in raw_exts:
            if not isinstance(ext, str) or not ext.startswith('.'):
                raise ValueError(
                    f"scan_targets['{scope_id}'].extensions: '{ext}' must be a string starting with '.'",
                )

    for key in ('include', 'exclude'):
        value = raw.get(key)
        if value is not None and not isinstance(value, list):
            raise ValueError(
                f"scan_targets['{scope_id}'].{key} must be a list",
            )


def _parse_scope(
    scope_id: str,
    raw: dict,
    default_extensions: tuple[str, ...],
) -> ScopeDefinition:
    raw_exts = raw.get('extensions')
    extensions = tuple(raw_exts) if raw_exts is not None else default_extensions
    return ScopeDefinition(
        id=scope_id,
        roots=tuple(raw['roots']),
        extensions=extensions,
        include_patterns=tuple(raw.get('include', [])),
        exclude_patterns=tuple(raw.get('exclude', [])),
    )


def _build_scope_definitions(
    config: dict,
    default_extensions: tuple[str, ...],
) -> dict[str, ScopeDefinition]:
    """Return scope definitions from ``scan_targets`` config, or fall back to the
    legacy ``paths.*`` keys so old configs keep working without modification."""
    raw_targets = config.get('scan_targets')

    if raw_targets is None:
        # Backward-compatible fallback: reconstruct the five original scopes from the
        # legacy paths config so callers that haven't added scan_targets yet still work.
        paths_conf = config.get('paths', {})
        source_root = config.get('source_root', 'lib')
        test_root = config.get('test_root', 'test')
        raw_targets = {
            'all':      {'roots': [source_root, test_root]},
            'core':     {'roots': [paths_conf.get('core_dir', 'lib/core')]},
            'shared':   {'roots': [paths_conf.get('shared_dir', 'lib/shared')]},
            'features': {'roots': [paths_conf.get('features_dir', 'lib/features')]},
            'test':     {'roots': [test_root]},
        }

    if not isinstance(raw_targets, dict):
        raise ValueError("scan_targets must be a mapping of scope-id → scope config")

    definitions: dict[str, ScopeDefinition] = {}
    for scope_id, raw in raw_targets.items():
        _validate_scope(scope_id, raw)
        definitions[scope_id] = _parse_scope(scope_id, raw, default_extensions)

    return definitions


@dataclass(slots=True)
class PathConstants:
    """Resolved paths and scope definitions for one project root.

    Named directory fields (``core_dir``, ``shared_dir``, ``features_dir``,
    ``source_root``, ``test_root``) are kept for backward compatibility with
    guards that reference them directly.  Scope-to-path resolution is now driven
    by ``scope_definitions`` rather than hardcoded if/elif chains.
    """

    root_dir: Path
    source_root: Path
    test_root: Path
    core_dir: Path
    shared_dir: Path
    features_dir: Path
    layer_root_segment: str
    layer_offset: int
    exclude_patterns: tuple[str, ...]
    scope_definitions: dict[str, ScopeDefinition]
    default_extensions: tuple[str, ...]

    @classmethod
    def from_config(cls, root_dir: Path, config: dict) -> 'PathConstants':
        paths = config.get('paths', {})
        source_root = root_dir / config.get('source_root', 'lib')
        test_root   = root_dir / config.get('test_root', 'test')
        layer_detection = paths.get('layer_detection', {})
        features_dir = paths.get('features_dir', 'lib/features')
        layer_root_segment = layer_detection.get(
            'root_segment',
            PurePosixPath(features_dir).name,
        )
        layer_offset = layer_detection.get('layer_offset', 2)

        # ``language_extensions`` is the project-wide default; individual scopes
        # may override it via their own ``extensions`` key.
        default_extensions = tuple(config.get('language_extensions', ['.dart']))

        scope_defs = _build_scope_definitions(config, default_extensions)

        return cls(
            root_dir=root_dir,
            source_root=source_root,
            test_root=test_root,
            core_dir=root_dir / paths.get('core_dir', 'lib/core'),
            shared_dir=root_dir / paths.get('shared_dir', 'lib/shared'),
            features_dir=root_dir / paths.get('features_dir', 'lib/features'),
            layer_root_segment=layer_root_segment,
            layer_offset=layer_offset,
            exclude_patterns=tuple(paths.get('exclude_patterns', [])),
            scope_definitions=scope_defs,
            default_extensions=default_extensions,
        )

    # ------------------------------------------------------------------
    # Path helpers
    # ------------------------------------------------------------------

    def relative_path(self, file_path: Path) -> str:
        try:
            return file_path.resolve().relative_to(self.root_dir.resolve()).as_posix()
        except ValueError:
            return file_path.as_posix()

    def source_relative_path(self, file_path: Path) -> str:
        try:
            return file_path.resolve().relative_to(self.source_root.resolve()).as_posix()
        except ValueError:
            return self.relative_path(file_path)

    def is_excluded(self, file_path: Path) -> bool:
        """Return True when a file matches the *global* exclude patterns."""
        relative = PurePosixPath(self.relative_path(file_path))
        return any(relative.match(pattern) for pattern in self.exclude_patterns)

    def matches_source_pattern(self, file_path: Path, pattern: str) -> bool:
        source_relative = PurePosixPath(self.source_relative_path(file_path))
        return source_relative.match(pattern)

    # ------------------------------------------------------------------
    # Scope helpers
    # ------------------------------------------------------------------

    def get_scope_definition(self, scope: str) -> ScopeDefinition | None:
        """Return the ``ScopeDefinition`` for *scope*, or ``None`` if unknown."""
        return self.scope_definitions.get(scope)

    @property
    def scope_ids(self) -> tuple[str, ...]:
        return tuple(self.scope_definitions.keys())

    def scope_roots(self, scope: str) -> list[Path]:
        """Return the list of root directories to walk for *scope*.

        Falls back to treating *scope* as a repo-relative path when no matching
        definition exists (preserves the original behaviour for ad-hoc scopes).
        """
        defn = self.scope_definitions.get(scope)
        if defn is not None:
            return [self.root_dir / root for root in defn.roots]
        return [self.root_dir / scope]

    def scope_extensions(self, scope: str) -> tuple[str, ...]:
        """Return the file extensions accepted for *scope*."""
        defn = self.scope_definitions.get(scope)
        return defn.extensions if defn is not None else self.default_extensions

    def path_is_within_scope(self, path_str: str, scope: str) -> bool:
        """Return True when *path_str* (repo-relative, POSIX) is at or under any
        root directory of *scope*.

        Used by guards that need to decide whether to check a given path based on
        the active scope, without hard-coding scope names.
        """
        for root in self.scope_roots(scope):
            root_rel = self.relative_path(root)
            if path_str == root_rel or path_str.startswith(root_rel + '/'):
                return True
        return False

    # ------------------------------------------------------------------
    # Layer detection (used by import_direction_guard)
    # ------------------------------------------------------------------

    def get_layer(self, file_path: Path) -> str | None:
        parts = PurePosixPath(self.relative_path(file_path)).parts

        if not self.layer_root_segment:
            return None

        if self.layer_root_segment not in parts:
            return None

        layer_index = parts.index(self.layer_root_segment) + self.layer_offset

        if len(parts) <= layer_index:
            return None

        return parts[layer_index]
