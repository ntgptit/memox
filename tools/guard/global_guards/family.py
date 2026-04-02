from __future__ import annotations

from tools.guard.core.base_guard import BaseGuard
from tools.guard.core.guard_family import GuardFamily
from tools.guard.core.guard_result import GuardScope


class GlobalGuardFamily(GuardFamily):
    FAMILY_ID = 'global'
    FAMILY_NAME = 'Global Guards'
    SCOPE = GuardScope.GLOBAL
    GUARDS_DIR = 'global_guards'

    def create_guards(self) -> list[BaseGuard]:
        guards: list[BaseGuard] = []

        for guard_class in self._discover_classes():
            guard = guard_class(
                config=self.config,
                path_constants=self.path_constants,
                project_rules=None,
            )

            if not guard.is_enabled:
                continue

            guards.append(guard)

        return guards
