from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
import time

from tools.guard.core.file_scanner import FileScanner
from tools.guard.core.guard_result import GuardScope, Violation
from tools.guard.core.rule_executor import RuleExecutor
from tools.guard.global_guards.family import GlobalGuardFamily
from tools.guard.local_guards.family import LocalGuardFamily


@dataclass(slots=True, frozen=True)
class GuardDefinition:
    guard_id: str
    guard_name: str
    description: str
    scope: GuardScope
    source: str
    enabled: bool


class GuardRegistry:
    def __init__(
        self,
        config: dict,
        path_constants: 'PathConstants',
        project_rules: dict,
    ) -> None:
        self.config = config
        self.paths = path_constants
        self.project_rules = project_rules
        self.scanner = FileScanner(path_constants)
        self.executor = RuleExecutor(config=config, paths=path_constants)

    def _families_for(self, family: str) -> list[object]:
        families = []

        if family in {'all', 'global'}:
            families.append(
                GlobalGuardFamily(
                    config=self.config,
                    path_constants=self.paths,
                    project_rules=self.project_rules,
                ),
            )

        if family in {'all', 'local'}:
            families.append(
                LocalGuardFamily(
                    config=self.config,
                    path_constants=self.paths,
                    project_rules=self.project_rules,
                ),
            )

        return families

    def create_guards(
        self,
        family: str = 'all',
        guard_ids: set[str] | None = None,
    ) -> list['BaseGuard']:
        guards = [
            guard
            for family_instance in self._families_for(family)
            for guard in family_instance.create_guards()
        ]

        if not guard_ids:
            return guards

        return [guard for guard in guards if guard.GUARD_ID in guard_ids]

    def list_guard_definitions(self, family: str = 'all') -> list[GuardDefinition]:
        definitions: dict[str, GuardDefinition] = {}

        for rule in self.executor.rules:
            scope = GuardScope(rule.scope)

            if family == 'global' and scope != GuardScope.GLOBAL:
                continue

            if family == 'local' and scope != GuardScope.LOCAL:
                continue

            definitions[rule.id] = GuardDefinition(
                guard_id=rule.id,
                guard_name=rule.name,
                description=rule.description,
                scope=scope,
                source='normalized',
                enabled=rule.enabled and self.config.get(
                    f'{rule.scope}_guards',
                    {},
                ).get(rule.id, True),
            )

        normalized_ids = set(definitions)

        for family_instance in self._families_for(family):
            for guard_class in family_instance.discover_guard_classes():
                if guard_class.GUARD_ID in normalized_ids:
                    continue

                scope = guard_class.SCOPE
                definitions[guard_class.GUARD_ID] = GuardDefinition(
                    guard_id=guard_class.GUARD_ID,
                    guard_name=guard_class.GUARD_NAME,
                    description=guard_class.DESCRIPTION,
                    scope=scope,
                    source='legacy',
                    enabled=self.config.get(
                        f'{scope.value}_guards',
                        {},
                    ).get(guard_class.GUARD_ID, True),
                )

        return sorted(definitions.values(), key=lambda item: item.guard_id)

    def run(
        self,
        family: str = 'all',
        guard_ids: set[str] | None = None,
        scope: str = 'all',
    ) -> list['GuardResult']:
        files = self.scanner.scan(scope=scope)

        # Run config-driven normalized rules first.
        results = self.executor.run(files=files, family=family, guard_ids=guard_ids)

        # Skip legacy guard classes whose IDs have been migrated to the executor.
        normalized_ids = self.executor.rule_ids

        for guard in self.create_guards(family=family, guard_ids=guard_ids):
            if guard.GUARD_ID in normalized_ids:
                continue
            started_at = time.perf_counter()
            violations = []
            files_scanned = len(files)

            try:
                if guard.is_file_level:
                    for file_path in files:
                        violations.extend(guard.check_file(file_path, self._read_lines(file_path)))

                if not guard.is_file_level:
                    violations.extend(guard.check_project(files))
            except Exception as exc:  # pragma: no cover - safety net
                violations.append(
                    Violation.internal_error(
                        guard_id=guard.GUARD_ID,
                        scope=guard.SCOPE,
                        error=exc,
                    ),
                )

            duration_ms = (time.perf_counter() - started_at) * 1000
            results.append(guard.create_result(violations, files_scanned, duration_ms))

        return results

    @staticmethod
    def _read_lines(file_path: Path) -> list[str]:
        return file_path.read_text(encoding='utf-8').splitlines()
