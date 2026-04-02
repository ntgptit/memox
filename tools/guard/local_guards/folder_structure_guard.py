from __future__ import annotations

from pathlib import Path

from tools.guard.core.base_guard import BaseGuard
from tools.guard.core.guard_result import GuardScope, Severity, Violation


class FolderStructureGuard(BaseGuard):
    GUARD_ID = 'folder_structure'
    GUARD_NAME = 'Folder structure'
    DESCRIPTION = 'Project folders should match the MemoX structure contract.'
    DEFAULT_SEVERITY = Severity.INFO
    SCOPE = GuardScope.LOCAL

    @property
    def is_file_level(self) -> bool:
        return False

    def check_project(self, all_files: list[Path]) -> list[Violation]:
        rules = self.project_rules.get('folder_structure', {})
        scope = self.config.get('_runtime', {}).get('scope', 'all')
        violations: list[Violation] = []

        if scope in {'all', 'core', 'shared', 'features'}:
            for path in rules.get('required_root_dirs', []):
                if scope == 'core' and not path.startswith('lib/core'):
                    continue

                if scope == 'shared' and not path.startswith('lib/shared'):
                    continue

                if scope == 'features' and not path.startswith('lib/features'):
                    continue

                target = self.paths.root_dir / path

                if target.exists():
                    continue

                violations.append(
                    self._violation(path, f'Thư mục bắt buộc bị thiếu: {path}'),
                )

        if scope in {'all', 'core'}:
            for path in rules.get('core_required_dirs', []):
                target = self.paths.root_dir / path

                if target.exists():
                    continue

                violations.append(
                    self._violation(path, f'Core structure thiếu thư mục: {path}'),
                )

        if scope not in {'all', 'features'}:
            return violations

        features_root = self.paths.features_dir

        for feature in rules.get('required_features', []):
            feature_dir = features_root / feature

            if not feature_dir.exists():
                violations.append(
                    self._violation(
                        feature_dir,
                        f'Feature bắt buộc bị thiếu: {feature}',
                    ),
                )
                continue

            for layer in rules.get('feature_layers', []):
                layer_dir = feature_dir / layer

                if not layer_dir.exists():
                    violations.append(
                        self._violation(layer_dir, f'{feature}/ thiếu layer {layer}/'),
                    )
                    continue

                subdir_key = f'{layer}_subdirs'

                for subdir in rules.get(subdir_key, []):
                    subdir_path = layer_dir / subdir

                    if subdir_path.exists():
                        continue

                    violations.append(
                        self._violation(
                            subdir_path,
                            f'{feature}/{layer}/ thiếu thư mục {subdir}/',
                        ),
                    )

        return violations

    def _violation(self, file_path: str | Path, message: str) -> Violation:
        normalized_path = str(file_path).replace('\\', '/')

        if isinstance(file_path, Path):
            normalized_path = self.paths.relative_path(file_path)

        return Violation(
            file_path=normalized_path,
            line_number=1,
            line_content='',
            message=message,
            guard_id=self.GUARD_ID,
            severity=self.severity,
            scope=self.SCOPE,
        )
