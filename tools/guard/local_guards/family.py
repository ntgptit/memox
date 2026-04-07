from __future__ import annotations

from tools.guard.core.base_guard import BaseGuard
from tools.guard.core.guard_family import GuardFamily
from tools.guard.core.guard_result import GuardScope


class LocalGuardFamily(GuardFamily):
    FAMILY_ID = 'local'
    FAMILY_NAME = 'Local Guards'
    SCOPE = GuardScope.LOCAL
    GUARDS_DIR = 'local_guards'

    def create_guards(self) -> list[BaseGuard]:
        guards: list[BaseGuard] = []

        for guard_class in self.discover_guard_classes():
            guard = guard_class(
                config=self.config,
                path_constants=self.path_constants,
                project_rules=self.project_rules,
            )

            if not guard.is_enabled:
                continue

            guards.append(guard)

        return guards
