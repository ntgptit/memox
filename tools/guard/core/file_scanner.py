from __future__ import annotations

from pathlib import Path, PurePosixPath

from tools.guard.core.path_constants import PathConstants


class FileScanner:
    def __init__(self, path_constants: PathConstants) -> None:
        self.paths = path_constants

    def scan(
        self,
        scope: str = 'all',
        extensions: tuple[str, ...] | None = None,
    ) -> list[Path]:
        """Return all files under *scope* that pass extension and pattern filters.

        Parameters
        ----------
        scope:
            A scope id defined in ``scan_targets`` config, or a repo-relative
            path used as a one-off root.
        extensions:
            Explicit extension allowlist.  When ``None`` (the default), the
            extensions declared for *scope* in the config are used, falling back
            to the project-wide ``language_extensions``.
        """
        effective_extensions = (
            extensions if extensions is not None else self.paths.scope_extensions(scope)
        )
        defn = self.paths.get_scope_definition(scope)
        files: list[Path] = []

        for root in self.paths.scope_roots(scope):
            if not root.exists():
                continue

            for file_path in sorted(root.rglob('*')):
                if not file_path.is_file():
                    continue

                if file_path.suffix not in effective_extensions:
                    continue

                if self.paths.is_excluded(file_path):
                    continue

                if defn is not None and not self._passes_scope_filters(file_path, defn):
                    continue

                files.append(file_path)

        return files

    def _passes_scope_filters(self, file_path: Path, defn: 'ScopeDefinition') -> bool:
        """Apply per-scope include/exclude patterns.  Returns False to reject the file."""
        if not defn.include_patterns and not defn.exclude_patterns:
            return True

        relative = PurePosixPath(self.paths.relative_path(file_path))

        if defn.include_patterns:
            if not any(relative.match(p) for p in defn.include_patterns):
                return False

        if defn.exclude_patterns:
            if any(relative.match(p) for p in defn.exclude_patterns):
                return False

        return True
