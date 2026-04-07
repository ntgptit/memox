from __future__ import annotations

from pathlib import Path

from tools.guard.core.base_guard import BaseGuard
from tools.guard.core.guard_result import GuardScope, Severity, Violation


class FeatureCompletenessGuard(BaseGuard):
    GUARD_ID = 'feature_completeness'
    GUARD_NAME = 'Feature completeness'
    DESCRIPTION = 'Features should contain non-empty data/domain/presentation substructures.'
    DEFAULT_SEVERITY = Severity.WARNING
    SCOPE = GuardScope.LOCAL

    @property
    def is_file_level(self) -> bool:
        return False

    def check_project(self, all_files: list[Path]) -> list[Violation]:
        scope = self.config.get('_runtime', {}).get('scope', 'all')
        features_rel = self.paths.relative_path(self.paths.features_dir)

        if not self.paths.path_is_within_scope(features_rel, scope):
            return []

        rules = self.project_rules.get('folder_structure', {})
        violations: list[Violation] = []

        for feature in rules.get('required_features', []):
            feature_dir = self.paths.features_dir / feature

            if not feature_dir.exists():
                continue

            for layer in rules.get('feature_layers', []):
                layer_dir = feature_dir / layer

                if not layer_dir.exists():
                    continue

                subdir_key = f'{layer}_subdirs'

                for subdir in rules.get(subdir_key, []):
                    subdir_dir = layer_dir / subdir

                    if not subdir_dir.exists():
                        continue

                    has_dart_files = any(subdir_dir.rglob('*.dart'))

                    if has_dart_files:
                        continue

                    violations.append(
                        Violation(
                            file_path=self.paths.relative_path(subdir_dir),
                            line_number=1,
                            line_content='',
                            message=f'{feature}/{layer}/{subdir} đang rỗng.',
                            guard_id=self.GUARD_ID,
                            severity=self.severity,
                            scope=self.SCOPE,
                        ),
                    )

        return violations
