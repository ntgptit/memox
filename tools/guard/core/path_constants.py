from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path, PurePosixPath


@dataclass(slots=True)
class PathConstants:
    root_dir: Path
    source_root: Path
    test_root: Path
    core_dir: Path
    shared_dir: Path
    features_dir: Path
    exclude_patterns: tuple[str, ...]

    @classmethod
    def from_config(cls, root_dir: Path, config: dict) -> 'PathConstants':
        paths = config.get('paths', {})
        source_root = root_dir / config.get('source_root', 'lib')
        test_root = root_dir / config.get('test_root', 'test')
        return cls(
            root_dir=root_dir,
            source_root=source_root,
            test_root=test_root,
            core_dir=root_dir / paths.get('core_dir', 'lib/core'),
            shared_dir=root_dir / paths.get('shared_dir', 'lib/shared'),
            features_dir=root_dir / paths.get('features_dir', 'lib/features'),
            exclude_patterns=tuple(paths.get('exclude_patterns', [])),
        )

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
        relative = PurePosixPath(self.relative_path(file_path))
        return any(relative.match(pattern) for pattern in self.exclude_patterns)

    def scope_roots(self, scope: str) -> list[Path]:
        if scope == 'all':
            return [self.source_root, self.test_root]

        if scope == 'core':
            return [self.core_dir]

        if scope == 'shared':
            return [self.shared_dir]

        if scope == 'features':
            return [self.features_dir]

        if scope == 'test':
            return [self.test_root]

        return [self.root_dir / scope]

    def get_layer(self, file_path: Path) -> str | None:
        parts = PurePosixPath(self.relative_path(file_path)).parts

        if 'features' not in parts:
            return None

        feature_index = parts.index('features')

        if len(parts) <= feature_index + 2:
            return None

        return parts[feature_index + 2]

    def matches_source_pattern(self, file_path: Path, pattern: str) -> bool:
        source_relative = PurePosixPath(self.source_relative_path(file_path))
        return source_relative.match(pattern)
