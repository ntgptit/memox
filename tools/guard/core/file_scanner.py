from __future__ import annotations

from pathlib import Path

from tools.guard.core.path_constants import PathConstants


class FileScanner:
    def __init__(self, path_constants: PathConstants) -> None:
        self.paths = path_constants

    def scan(self, scope: str = 'all', extensions: tuple[str, ...] = ('.dart',)) -> list[Path]:
        files: list[Path] = []

        for root in self.paths.scope_roots(scope):
            if not root.exists():
                continue

            for file_path in sorted(root.rglob('*')):
                if not file_path.is_file():
                    continue

                if file_path.suffix not in extensions:
                    continue

                if self.paths.is_excluded(file_path):
                    continue

                files.append(file_path)

        return files
